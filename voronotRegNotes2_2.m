function voronotRegNotes2_2()
% Building things out to function to start testing alignments of image
% parts, jittering base image
% Still no plains for A==B,B==C,A~=C misalignments
distanceThreshold = 3;
nPeaksCheck = 3;
vorAdjacencyMax = 2;
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
    vorAdjTiers{cornerI} = GetAllTierAdjacency(vorAdjacency{cornerI},vorAdjacencyMax);
    edgePolys{cornerI} = GetVoronoiEdges(vorVertices{cornerI},allCenters{cornerI},vorIndices{cornerI});
    vorAdjTiers{cornerI}(vorAdjTiers{cornerI}==0) = NaN;
    vorAdjTiers{cornerI}(edgePolys{cornerI},:) = NaN;
    vorTwo{cornerI} = vorAdjTiers{cornerI}<=2; %logical
    neuronTracker{cornerI} = repmat([1:numCells(cornerI)]',1,numCells(cornerI));
end
clear NeuronImage 
clear NeuronImageC
% We'll have to load these again later to evaluate

% Find registration from each corner to each other corner
tic
for ccI = 1:4
    %NeuronImageA = NeuronImageC{ccI};
    numCellsA = numCells(ccI);
    allCentersA = allCenters{ccI};
    
    % Get datas
    allAnglesA = allAngles{ccI}';
    allDistancesA = allDistances{ccI}';
    neuronTrackerA = neuronTracker{ccI}';
    vorTwoA = vorTwo{ccI}';
    numVorTwoPartnersA = sum(vorTwoA,2);
    % Reorganize
    anglesTwoA = allAnglesA(vorTwoA);
    distTwoA = allDistancesA(vorTwoA);
    cellRowA = neuronTrackerA(vorTwoA);
    
    for ccJ = 1:4
        disp('Angle/dist difference setup')
        
        %NeuronImageB = NeuronImageC{ccJ};
        numCellsB = numCells(ccJ);
        allCentersB = allCenters{ccJ};
        
        % Get datas
        allAnglesB = allAngles{ccJ}';
        allDistancesB = allDistances{ccJ}';
        neuronTrackerB = neuronTracker{ccJ}';
        vorTwoB = vorTwo{ccJ}';
        numVorTwoPartnersB = sum(vorTwoB,2);
        % Reorganize
        anglesTwoB = allAnglesB(vorTwoB);
        distTwoB = allDistancesB(vorTwoB);
        cellRowB = neuronTrackerB(vorTwoB);
    
        % Register them: Find offset clusters
        angleBinWidth = 1;
        distBinWidth = 1;
        %[uniqueCellsUse,uniqueCellsUseMax,totalAligns,meanAligns] = ...
        %    findClusters(anglesTwoA,distTwoA,cellRowA,anglesTwoB,distTwoB,cellRowB,angleBinWidth,distBinWidth,nClustersCheck);
        % Get differences of all angles and distances from each other
        angleDiffs = anglesTwoA(:) - anglesTwoB(:)'; % ( anglesTwoA(i),anglesTwoB(j) )
        distanceDiffs = abs(distTwoA(:) - distTwoB(:)');
        [angleDiffsRect] = RectifyAngleDiffs(rad2deg(angleDiffs),'deg'); %%% slow?
        %angleDiffsAbs = round(abs(angleDiffsRect),4); % In degrees from here
        angleDiffsAbs = abs(angleDiffsRect);
        
        clear angleDiffs angleDiffsRect
tic
        cellCellA = repmat(cellRowA(:),1,length(cellRowB));
        cellCellB = repmat(cellRowB(:)',length(cellRowA),1);
        
        cellRowA2 = cellRowA;
        cellRowB2 = (cellRowB-1)*numCellsA;
        cellCellA2 = repmat(cellRowA2(:),1,length(cellRowB2));
        cellCellB2 = repmat(cellRowB2(:)',length(cellRowA2),1);
        
        intCellIDs = cellCellA2 + cellCellB2;   % Creates a unique integer identifier for each 
        
        imagCellIDs = cellCellA + cellCellB*1i; % Creates a unique identifier for each A-B voronoi-tier 2 cell pair
  toc      
        % Find peaks in the distribution of angle/radius differences
        %angleBinWidth = 1;
        %distBinWidth = 1;
        disp('Histcounts...')
        tic
        [angleRadDiffDistribution,yEdges,xEdges,angleBinAssigned,distBinAssigned] = histcounts2(angleDiffsAbs,distanceDiffs); %%% slow
        toc
        [diffDistSorted,sordIdx] = sort(angleRadDiffDistribution(:),'descend');
        
        theseBins = sordIdx(1:nPeaksCheck);
        ptsTheseBins = angleRadDiffDistribution(theseBins);
        ARDdistSz = size(angleRadDiffDistribution);
        
        clear angleRadDiffDistribution
        
        for pcI = 1:nPeaksCheck
            disp('Peak evaluation initialization')
            tic
            %thisBin = sordIdx(pcI);
            thisBin = theseBins(pcI);
            %[bRow,bCol] = ind2sub(size(angleRadDiffDistribution),thisBin);
            [bRow,bCol] = ind2sub(ARDdistSz,thisBin);
            %nPtsHere(pcI) = angleRadDiffDistribution(thisBin);
            nPtsHere(pcI) = ptsTheseBins(pcI);
            
            thisAngleBin = mean([yEdges(bRow) yEdges(bRow+1)]);
            thisDistBin = mean([xEdges(bCol) xEdges(bCol+1)]);
            
            % Get the cell pairs that ended up in this bin
            angleDiffsHere = angleBinAssigned==bRow;
            distDiffsHere = distBinAssigned==bCol;
            angleDistHere = angleDiffsHere & distDiffsHere;
            
            imagCellIdsHere = cellCellA(angleDistHere) + cellCellB(angleDistHere)*1i;
            intCellIdsHere = cellCellA2(angleDistHere) + cellCellB2(angleDistHere);
                % maybe there's a logical here to get still present from all

            [uniqueCellPairs,~,ic] = unique(imagCellIdsHere);
            toc
            
            disp('Peak quality checking')
            tic
            [uniqueCellsUse{pcI},uniqueCellsUseMax{pcI},totalAligns(pcI),meanAligns(pcI)] =...
                initClusterStats(uniqueCellPairs,ic,numCellsA,numCellsB);
            uniqueCellsUsePairs{pcI} = [real(uniqueCellsUse{pcI}) imag(uniqueCellsUse{pcI})];
            toc
        
            disp('Peak quality evaluation')
            tic
            % Explained angle/distance variance by this bin
            unexplainedAngles = abs(angleDiffsAbs-thisAngleBin);
            unexplainedDist = abs(distanceDiffs-thisDistBin);

            %[uniqueInAllImag] = ismember(imagCellIDs(:),imagCellIdsHere(:)); % index in all original pairs that showed up here %%%% slow?
            B = uint8(intCellIDs);
            D = uint8(unique(intCellIdsHere));
            [uniqueInAllImag] = ismembc(B,D); % logical for all the vorTwo pairs for cells included here % faster
       
            totalUEangles = unexplainedAngles(uniqueInAllImag);
            totalUEdist = unexplainedDist(uniqueInAllImag);
            hereUEangles = unexplainedAngles(angleDistHere);
            hereUEdist = unexplainedDist(angleDistHere);
            
            leftoverUEangles(ccI,ccJ,pcI) = sum(sum(unexplainedAngles)) - sum(totalUEangles);
            leftoverUEdist(ccI,ccJ,pcI) = sum(sum(unexplainedDist)) - sum(totalUEdist);
            
            numVorApartners{ccI,ccJ,pcI} = numVorTwoPartnersA(uniqueCellsUsePairs{pcI}(:,1));
            numVorBpartners{ccI,ccJ,pcI} = numVorTwoPartnersB(uniqueCellsUsePairs{pcI}(:,2));
            
            sumUEangles(ccI,ccJ,pcI) = sum(hereUEangles); 
            sumUEdist(ccI,ccJ,pcI) = sum(hereUEdist); 
            meanUEangles(ccI,ccJ,pcI) = mean(hereUEangles); 
                stdUEangles(pcI) = std(hereUEangles);
            meanUEdist(ccI,ccJ,pcI) = mean(hereUEdist); 
                stdUEdist(pcI) = std(hereUEdist);
            propUEangles(ccI,ccJ,pcI) = sum(hereUEangles)/sum(totalUEangles);
            propUEdist(ccI,ccJ,pcI) = sum(hereUEdist)/sum(totalUEdist); % 
            numPairedCells(ccI,ccJ,pcI) = length(uniqueCellsUse{pcI});
            toc
            clear unexplainedAngles unexplainedDist totalUEangles totalUEdist uniqueInAllImag 
        end
        
        clear distanceDiffs distBinAssigned angleBinAssigned imagCellIDs intCellIDs
        
        for pcI = 1:nPeaksCheck
            % Make a transformation based on these alignment pairs
            disp('Evaluate the registration success')
            
            anchorCellsA = uniqueCellsUsePairs{pcI}(:,1);
            anchorCellsB = uniqueCellsUsePairs{pcI}(:,2);
            
            % Run this registration and check how well it went
            [tform{pcI}, reg_shift_centers, closestPairs, nanDistances, regStats{pcI}] =...
                testRegistration(anchorCellsA,allCentersA,anchorCellsB,allCentersB,distanceThreshold);
            
            % Set up some regStats to evaluate
            regMats.pctMatchedCells(ccI,ccJ,pcI) = mean([regStats{pcI}.pctAllMatchedA regStats{pcI}.pctAllMatchedB]); 
            regMats.pctMatchedAnchors(ccI,ccJ,pcI) = mean([regStats{pcI}.pctMatchAnchorsA regStats{pcI}.pctMatchAnchorsB]);
            regMats.meanVorTwoPartners(ccI,ccJ,pcI) = mean([numVorApartners{ccI,ccJ,pcI}; numVorBpartners{ccI,ccJ,pcI}]);
            regMats.UEanglePerAnchor(ccI,ccJ,pcI) = sumUEangles(ccI,ccJ,pcI) / length(anchorCellsA);
            regMats.UEdistPerAnchor(ccI,ccJ,pcI) = sumUEdist(ccI,ccJ,pcI) / length(anchorCellsA);
            regMats.UEanglePerVorTwo(ccI,ccJ,pcI) = sumUEangles(ccI,ccJ,pcI) / sum(min([numVorApartners{ccI,ccJ,pcI}, numVorBpartners{ccI,ccJ,pcI}],[],2));
            regMats.UEdistPerVorTwo(ccI,ccJ,pcI) = sumUEdist(ccI,ccJ,pcI) / sum(min([numVorApartners{ccI,ccJ,pcI}, numVorBpartners{ccI,ccJ,pcI}],[],2));
        end
        
        rr = [];
        % Get maxes for each pcI for each ccI,ccJ for data in correlation matrix
        
    end % ccJ
end % ccI

regMats.UEanglePerVorTwoPerAnchor = regMats.UEanglePerVorTwo ./ numPairedCells;

keyboard

lbls = cellfun(@(x) ['Peak ' num2str(x)],mat2cell([1:nPeaksCheck],1,ones(1,nPeaksCheck)),'UniformOutput',false);
figure;
for ccI = 1:4
    subplot(1,4,ccI)
    bar(squeeze(regMats.pctMatchedCells(ccI,:,:)))
    title(['Corner ' num2str(ccI) ' vs....'])
    xlabel('vs. Corner n')
    legend(lbls) % This needs to not be hardcoded...
end
suptitleSL('pct Matched cells')

figure;
for ccI = 1:4
    subplot(1,4,ccI)
    bar(squeeze(regMats.UEanglePerVorTwoPerAnchor(ccI,:,:)))
    title(['Corner ' num2str(ccI) ' vs....'])
    xlabel('vs. Corner n')
    legend(lbls) % This needs to not be hardcoded...
end
suptitleSL('explained angle diffs per vorTwoCell per anchor cell')
    
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [uniqueCellsUse,uniqueCellsUseMax,totalAligns,meanAligns] = initClusterStats(uniqueCellPairs,ic,numCellsA,numCellsB);
% In the self-to-self, matched cells should all be where real and imaginary components are equal
realHere = real(uniqueCellPairs);
imagHere = imag(uniqueCellPairs);
same = realHere == imagHere; % sum(same) should equal the number of cells not labeled as edge cells

% Restrict match counts by number of cells in a/b min([numCellsA numCellsB])
nMaxMatch = min([numCellsA numCellsB]);

% How many pairs in this alignment bin for each cell?
cellIdCounts = histcounts(ic,[0.5:1:(max(ic)+0.5)]); % cellIdCounts(same) histogram of pts from known matches in this angleDiff/distDiff bin
[sortedCellCounts,sortedCountsOrder] = sort(cellIdCounts,'descend');
uniqueCellsUseMax = uniqueCellPairs(sortedCountsOrder(1:nMaxMatch));
sortedNumAlignPartners = cumsum(sortedCellCounts); % Num alignments in this bin each cell

% Refine to eliminate overlapped cells, take whichever comes first in sortedCountsOrder
uReal = real(uniqueCellsUseMax);
uImag = imag(uniqueCellsUseMax);
firstUR = false(length(uReal),1);
firstUI = false(length(uReal),1);
for ii = 1:length(uReal)
    firstUR(find(uReal==uReal(ii),1,'first')) = true;
    firstUI(find(uImag==uImag(ii),1,'first')) = true;
end
uKeep = firstUR & firstUI;

uniqueCellsUse = uniqueCellsUseMax(uKeep); % Cell pairs for alignment

totalAligns = sum(sortedNumAlignPartners(uKeep));
meanAligns = mean(sortedNumAlignPartners(uKeep)); % Num 2nd tier partner cells
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tform, reg_shift_centers, closestPairs, nanDistances, regStats] = testRegistration(anchorCellsA,allCentersA,anchorCellsB,allCentersB,distThresh)
            
basePairCenters = allCentersA(anchorCellsA,:);
regPairCenters = allCentersB(anchorCellsB,:);
numAnchorCells = length(anchorCellsA);

tform = fitgeotrans(regPairCenters,basePairCenters,'affine');
reg_shift_centers = [];
[reg_shift_centers(:,1),reg_shift_centers(:,2)] = transformPointsForward(tform,allCentersB(:,1),allCentersB(:,2));

% Run pt To pt assignment
[closestPairs,pairDistances,allDistances,nanDistances,regStats] = evaluateRegistration(allCentersA,reg_shift_centers,anchorCellsA,anchorCellsB,distThresh);
regStats.pairDistances = pairDistances;
regStats.allDistances = allDistances;

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [closestPairs,pairDistances,allDistances,nanDistances,regStats] =...
    evaluateRegistration(allCentersA,reg_shift_centers,anchorCellsA,anchorCellsB,distThresh)

numAnchorCells = length(anchorCellsA);
[distH,~] = GetAllPtToPtDistances([allCentersA(:,1); reg_shift_centers(:,1)],[allCentersA(:,2); reg_shift_centers(:,2)],[]);
distanceMatrix = distH(1:length(allCentersA),length(allCentersA)+(1:length(reg_shift_centers))); clear distH
allDistances = distanceMatrix;
distanceMatrix(distanceMatrix > distThresh) = NaN;
[closestPairs,nanDistances] = findDistanceMatches(distanceMatrix,[]);% otherCriteria
% Need to recreate evaluation criteria here which ask how well
imagAssignedByDist = closestPairs(:,1)+closestPairs(:,2)*1i;

% Matching of anchor cells
% ismember(a,b) where data in a is found in b
[matchedAnchorCellsA] = ismember(closestPairs(:,1),anchorCellsA);
regStats.pctMatchAnchorsA = sum(matchedAnchorCellsA)/numAnchorCells;
[matchedAnchorCellsB] = ismember(closestPairs(:,2),anchorCellsB);
regStats.pctMatchAnchorsB = sum(matchedAnchorCellsB)/numAnchorCells;

try
[inds] = sub2ind(size(allDistances),closestPairs(:,1),closestPairs(:,2));
catch
    keyboard
end
pairDistances = allDistances(inds);

% How many other cells does this transform match
baseVec = 1:length(allCentersA);
[baseCells] = ismember(baseVec,anchorCellsA);
nonAnchorCellsA = baseVec(baseCells==0);
matchedOtherCellsA = ismember(nonAnchorCellsA,closestPairs(:,1));
regStats.pctMatchedOtherA = sum(matchedOtherCellsA)/length(nonAnchorCellsA);
regVec = 1:size(reg_shift_centers,1);
[regCells] = ismember(regVec,anchorCellsB);
nonAnchorCellsB = regVec(regCells==0);
matchedOtherCellsB = ismember(nonAnchorCellsB,closestPairs(:,2));
regStats.pctMatchedOtherB = sum(matchedOtherCellsB)/length(nonAnchorCellsB);

regStats.allMatchedA = ismember(baseVec,closestPairs(:,1));
regStats.pctAllMatchedA = sum(regStats.allMatchedA)/length(baseVec);
regStats.allMatchedB = ismember(regVec,closestPairs(:,2));
regStats.pctAllMatchedB = sum(regStats.allMatchedB)/length(regVec);

end