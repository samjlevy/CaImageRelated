function voronotRegNotes2()
% Building things out to function to start testing alignments of image
% parts, jittering base image
% Still no plains for A==B,B==C,A~=C misalignments
distanceThreshold = 3;
nPeaksCheck = 3;
load('C:\Users\samwi_000\Desktop\FinalOutput.mat', 'NeuronImage')

% Divide image into quarters, get initial features
allCenters = getAllCellCenters(NeuronImage,[]);
imSz = size(NeuronImage{1});

cornerCells{1} = allCenters(:,1) < (imSz(1)/2) & allCenters(:,2) < (imSz(2)/2);
cornerCells{2} = allCenters(:,1) < (imSz(1)/2) & allCenters(:,2) >= (imSz(2)/2);
cornerCells{3} = allCenters(:,1) >= (imSz(1)/2) & allCenters(:,2) < (imSz(2)/2);
cornerCells{4} = allCenters(:,1) >= (imSz(1)/2) & allCenters(:,2) >= (imSz(2)/2);


allCenters = [];
imrotations = [];
for cornerI = 1:4
    NeuronImageC{cornerI} = NeuronImage(cornerCells{cornerI});
    %{
    NeuronImageC{cornerI} = cellfun(@(x) imrotate(x,imrotations),NeuronImageC{cornerI},'UniformOutput',false);
    %}
    %{
    shuffledOrder = randperm(length(NeuronImageB));
    NeuronImageB = NeuronImageB{shuffledOrder};
    %}
    numCells(cornerI) = length(NeuronImageC{cornerI});
    allCenters{cornerI} = getAllCellCenters(NeuronImageC{cornerI},false);

    [allDistances{cornerI},~] = GetAllPtToPtDistances(allCenters{cornerI}(:,1),allCenters{cornerI}(:,2),[]);
    allAngles{cornerI} = GetAllPtToPtAngles(allCenters{cornerI});
    [vorVertices{cornerI},vorIndices{cornerI}] = voronoin(allCenters{cornerI});
    vorAdjacency{cornerI} = GetVoronoiAdjacency(vorIndices{cornerI},vorVertices{cornerI});
    vorAdjTiers{cornerI} = GetAllTierAdjacency(vorAdjacency{cornerI},5);
    edgePolys{cornerI} = GetVoronoiEdges(vorVertices{cornerI},allCenters{cornerI},vorIndices{cornerI});
    vorAdjTiers{cornerI}(vorAdjTiers{cornerI}==0) = NaN;
    vorAdjTiers{cornerI}(edgePolys{cornerI},:) = NaN;
    vorTwo{cornerI} = vorAdjTiers{cornerI}<=2; %logical
    neuronTracker{cornerI} = repmat([1:numCells(cornerI)]',1,numCells(cornerI));
end
clear NeuronImage


% Find registration from each corner to each other corner
tic
for ccI = 1:4
    NeuronImageA = NeuronImageC{ccI};
    numCellsA = numCells(ccI);
    allCentersA = allCenters{ccI};
    
    % Get datas
    allAnglesA = allAngles{ccI}';
    allDistancesA = allDistances{ccI}';
    neuronTrackerA = neuronTracker{ccI}';
    vorTwoA = vorTwo{ccI}';
    % Reorganize
    anglesTwoA = allAnglesA(vorTwoA);
    distTwoA = allDistancesA(vorTwoA);
    cellRowA = neuronTrackerA(vorTwoA);
    
    for ccJ = 1:4
        NeuronImageB = NeuronImageC{ccJ};
        numCellsB = numCells(ccJ);
        allCentersB = allCenters{ccJ};
        
        % Get datas
        allAnglesB = allAngles{ccJ}';
        allDistancesB = allDistances{ccJ}';
        neuronTrackerB = neuronTracker{ccJ}';
        vorTwoB = vorTwo{ccJ}';
        % Reorganize
        anglesTwoB = allAnglesB(vorTwoB);
        distTwoB = allDistancesB(vorTwoB);
        cellRowB = neuronTrackerB(vorTwoB);
    
        % Register them: Find offset clusters
        % Get differences of all angles and distances from each other
        angleDiffs = anglesTwoA(:) - anglesTwoB(:)'; % ( anglesTwoA(i),anglesTwoB(j) )
        distanceDiffs = abs(distTwoA(:) - distTwoB(:)');
        
        [angleDiffsRect] = RectifyAngleDiffs(rad2deg(angleDiffs),'deg'); %%% slow?
        angleDiffsAbs = round(abs(angleDiffsRect),4); % In degrees from here
        
        cellCellA = repmat(cellRowA(:),1,length(cellRowB));
        cellCellB = repmat(cellRowB(:)',length(cellRowA),1);
        
        imagCellIDs = cellCellA + cellCellB*1i; % Creates a unique identifier for each A-B cell pair
        
        % Find peaks in the distribution of angle/radius differences
        angleBinWidth = 1;
        distBinWidth = 1;
        [angleRadDiffDistribution,yEdges,xEdges,angleBinAssigned,distBinAssigned] = histcounts2(angleDiffsAbs,distanceDiffs); %%% slow
        [diffDistSorted,sordIdx] = sort(angleRadDiffDistribution(:),'descend');
        
        for pcI = 1:nPeaksCheck
            thisBin = sordIdx(pcI);
            [bRow,bCol] = ind2sub(size(angleRadDiffDistribution),thisBin);
            
            nPtsHere(pcI) = angleRadDiffDistribution(thisBin);
            
            % Get the cell pairs that ended up in this bin
            angleDiffsHere = angleBinAssigned==bRow;
            distDiffsHere = distBinAssigned==bCol;
            angleDistHere = angleDiffsHere & distDiffsHere;
            
            imagCellIdsHere = cellCellA(angleDistHere) + cellCellB(angleDistHere)*1i;
                % maybe there's a logical here to get still present from all
            %[uniqueInAllImag] = ismember(imagCellIDs,imagCellIdsHere); % Any index in tier2 diff matrix which goes with found cell pairs

            [uniqueCellPairs,ia,ic] = unique(imagCellIdsHere);
            % In the self-to-self, matched cells should all be where real and imaginary components are equal
            realHere = real(uniqueCellPairs);
            imagHere = imag(uniqueCellPairs);
            same = realHere == imagHere; % sum(same) should equal the number of cells not labeled as edge cells

            % Restrict match counts by number of cells in a/b min([numCellsA numCellsB])
            nMaxMatch = min([numCellsA numCellsB]);
            
            % How many pairs in this alignment bin for each cell?
            cellIdCounts = histcounts(ic,[0.5:1:(max(ic)+0.5)]); % cellIdCounts(same) histogram of pts from known matches in this angleDiff/distDiff bin
            [sortedCellCounts,sortedCountsOrder] = sort(cellIdCounts,'descend');
            
            uniqueCellsUseMax{pcI} = uniqueCellPairs(sortedCountsOrder(1:nMaxMatch));
            
            sortedNumAlignPartners = cumsum(sortedCellCounts); % Num alignments in this bin each cell
            
            % Refine to eliminate overlapped cells, take whichever comes first in sortedCountsOrder
            uReal = real(uniqueCellsUseMax{pcI});
            uImag = imag(uniqueCellsUseMax{pcI});
            firstUR = false(length(uReal),1);
            firstUI = false(length(uReal),1);
            for ii = 1:length(uReal)
                firstUR(find(uReal==uReal(ii),1,'first')) = true;
                firstUI(find(uImag==uImag(ii),1,'first')) = true;
            end
            uKeep = firstUR & firstUI;
            
            uniqueCellsUse{pcI} = uniqueCellsUseMax{pcI}(uKeep); % Cell pairs for alignment
            
            totalAligns(pcI) = sum(sortedNumAlignPartners(uKeep));
            meanAligns(pcI) = mean(sortedNumAlignPartners(uKeep)); % Num 2nd tier partner cells
            
            % Explained angle/distance variance by this bin
            unexplainedAngles = abs(angleDiffsAbs-mean([yEdges(bRow) yEdges(bRow+1)]));
            unexplainedDist = abs(distanceDiffs-mean([xEdges(bCol) xEdges(bCol+1)]));
            [uniqueInAllImag] = ismember(imagCellIDs,imagCellIdsHere); % index in all original pairs that showed up here %%%% slow?
            totalUEangles = unexplainedAngles(uniqueInAllImag);
            totalUEdist = unexplainedDist(uniqueInAllImag);
            hereUEangles = unexplainedAngles(angleDistHere);
            hereUEdist = unexplainedDist(angleDistHere);
            
            meanUEangles(ccI,ccJ,pcI) = mean(hereUEangles); stdUEangles(pcI) = std(hereUEangles);
            meanUEdist(ccI,ccJ,pcI) = mean(hereUEdist); stdUEdist(pcI) = std(hereUEdist);
            propUEangles(ccI,ccJ,pcI) = sum(hereUEangles)/sum(totalUEangles);
            propUEdist(ccI,ccJ,pcI) = sum(hereUEdist)/sum(totalUEdist);
            numPairedCells(ccI,ccJ,pcI) = length(uniqueCellsUse{pcI});
            
        end
        
        for pcI = 1:nPeaksCheck
            % Make a transformation based on these alignment pairs
            anchorCellsA = real(uniqueCellsUse{pcI});
            anchorCellsB = imag(uniqueCellsUse{pcI});
            basePairCenters = allCentersA(anchorCellsA,:);
            regPairCenters = allCentersB(anchorCellsB,:);
            numAnchorCells = length(anchorCellsA);
            
            tform = fitgeotrans(regPairCenters,basePairCenters,'affine'); 
            % Features here will have to be compared when we put split images back together etc.
            tfSave{ccI,ccJ,pcI} = tform;
            %{
            tic
            RA = imref2d(size(NeuronImageA{1})); % This with outputview restricts view and transformation to that of NeuronImageA
            [NeuronImageB_shifted,~] = ...
                cellfun(@(x) imwarp(x,tform,'OutputView',RA,'InterpolationMethod','nearest'),NeuronImageB,'UniformOutput',false);
                %%% slow?
            reg_allMask_shifted = create_AllICmask(NeuronImageB_shifted);
            reg_shift_centers = getAllCellCenters(NeuronImageB_shifted,true);
            reg_shift_centers(sum(reg_shift_centers==0,2)==2,:) = NaN;
            toc
            %}
            reg_shift_centers = [];
            [reg_shift_centers(:,1),reg_shift_centers(:,2)] = transformPointsForward(tform,allCentersB(:,1),allCentersB(:,2));
            
            % Run pt To pt assignment
            % Start assigning cells
            % Ideal case here would be to use the assignments generated in the algorithm from the beginning...
            [closestCell, distance] = findclosest2D(...
                allCentersA(:,1), allCentersA(:,2),...
                reg_shift_centers(:,1), reg_shift_centers(:,2));
            %closest cell is index in base cells for all reg cells
            
            cellsInRange = closestCell(distance < distanceThreshold);
            closestCell(distance >= distanceThreshold) = NaN;
            rinds = 1:numCellsB; %reg cells nums
            inRangeIndices = rinds(distance <= distanceThreshold); %indices of regCells
            cellsMatched = [1:numCellsA]'==cellsInRange;
            matchedCounts = sum(cellsMatched,2);
            overlapped = find(matchedCounts > 1);
            % [minInds,nanDistances] = findDistanceMatches(distances,otherCriteria); This needs to
            % get swapped in
            % Resolve match overlaps by higher correlation
            %{
            for repCell = 1:length(overlapped)
                matchedCells = inRangeIndices(cellsInRange==overlapped(repCell));
                %indices in closestCell, full length regCells
                
                baseReg = fullRegROIavg{1,overlapped(repCell)};
                regMatchedReg = {regAvg_shifted{1,matchedCells}};
                
                areaCorrs = cellfun(@(x) corr(baseReg(:),x(:),'type','Spearman'), regMatchedReg, 'UniformOutput',false);
                areaCorrs = cell2mat(areaCorrs);
                
                useCell = areaCorrs==max(areaCorrs);
                if sum(useCell)==1
                    %good
                    closestCell(matchedCells(~useCell)) = NaN;
                    distance(matchedCells(~useCell)) = NaN;
                else
                    %either both or none, problem; mostly shouldn't happen?
                    disp('something up here, found 2 matches for this cell; probably need a fallback')
                end
                
                % This this need an additional step to re-check distances after
                % forced reassignments? (A,B try to go to X, C to Y, A closer to X,
                % but B closer to Y than C)
                % Could get closest2d by doing a min on the alltoall distance
                % matrix, then keeping a record of indices to relabel as NaN when
                % checking for mins (verify on test pts, and that this isn't
                % already accomplished)
                % Although, what happens if this cascades through multiple
                % steps? How do we make sure to iterate through this in the
                % right order?
            end
            %}
            %{
            base_allMask = create_AllICmask(NeuronImageA);
            [overlay,overlayRef] = imfuse(base_allMask,reg_allMask_shifted,'ColorChannels',[1 2 0]);
            if exist('mixFig','var'); delete(mixFig); clear('mixFig'); end
            mixFig = figure; imshow(overlay,overlayRef)
            title(['Base (red) and reg (green) shifted overlay, ' num2str(sum(distance<distanceThreshold)) ' cell centers < 3um'])
            hold on
            plot(reg_shift_centers(distance<distanceThreshold,1),reg_shift_centers(distance<distanceThreshold,2),'*r')
                    %}
                    %{
             figure; subplot(1,3,1); imagesc(base_allMask); title('NeuronsA');...
             subplot(1,3,2); imagesc(create_AllICmask(NeuronImageB)); title('NeuronsB pre'); ...
             subplot(1,3,3); imagesc(reg_allMask_shifted); title('NeuronsB post');
            %}
            
            % How many anchor cells matched
            worked = zeros(1,numAnchorCells);
            for chCell = 1:numAnchorCells
                %Does closest cell match paired Inds cells?
                worked(chCell) = closestCell(anchorCellsB(chCell)) == anchorCellsA(chCell);
            end
            
            % How many base/reg cells matched
            matchedRegCells = rinds(~isnan(closestCell)); %reg cells
            unmatchedRegCells = rinds(isnan(closestCell));
            if ~(length(matchedRegCells) + length(unmatchedRegCells) == numCellsB)
                disp('Registration counts problem')
                keyboard
            end
            
            bref = ones(numCellsA,1);
            %bref(allClosestCells(matchedRegCells)) = 0; % not sure what allClosestCells was supposed to be...
            bref(closestCell(matchedRegCells)) = 0;
            unmatchedBaseCells = find(bref);
            matchedBaseCells = closestCell(matchedRegCells); %allClosestCells(inRangeIndicesCells);
            
            numMatchedAnchorCells(ccI,ccJ,pcI) = sum(worked);
            numMatchedOtherCells(ccI,ccJ,pcI) = length(closestCell) - sum(worked);
            numMatchedBaseCells(ccI,ccJ,pcI) = length(matchedBaseCells);
            numUnmatchedBaseCells(ccI,ccJ,pcI) = length(unmatchedBaseCells);
            numMatchedRegCells(ccI,ccJ,pcI) = length(matchedRegCells);
            numUnmatchedRegCells(ccI,ccJ,pcI) = length(unmatchedRegCells);
            
            numOverlappedCells(ccI,ccJ,pcI) = length(overlapped);
        end
        
        % Get maxes for each pcI for each ccI,ccJ for data in correlation matrix
        
    end % ccJ
end % ccI
toc

keyboard
% Save outputs and make a correlation matrix
        
        
end