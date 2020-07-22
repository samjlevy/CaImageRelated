function voronotRegNotes2_3()
% Building things out to function to start testing alignments of image
% parts, jittering base image cell centers by a small random amount
% Could also try manipulating the angle or distance offsets to see the
% effects, though not sure what to predict there
% Still no plains for A==B,B==C,A~=C misalignments

%keyboard

distanceThreshold = 3;
nPeaksCheck = 1;
vorAdjacencyMax = 2;
triesPerJitter = 10;
load('C:\Users\samwi_000\Desktop\FinalOutput.mat', 'NeuronImage')

% Make an image that's the middle 400 cells
allCenters = getAllCellCenters(NeuronImage,[]);
imSz = size(NeuronImage{1});
com = mean(allCenters,1);
distFromCenter = hypot(abs(allCenters(:,1)-com(1)),abs(allCenters(:,2)-com(2)));
[distSort,srtI] = sort(distFromCenter,'ascend');
ptsKeep = srtI(1:400);

centImage = NeuronImage(ptsKeep);
allCenters = getAllCellCenters(centImage,[]);
numCellsA = size(allCenters,1);
clear NeuronImage
imRotated = cellfun(@(x) imrotate(x,90),centImage,'UniformOutput',false);
imCenters = getAllCellCenters(imRotated,[]);
numCellsB = size(imCenters,1);

% Set up baseline information
disp('Setting up baseline informaiton')
tic
[allAngles,allDistances,vorTwoLogical,neuronTracker] = setupForAligns(allCenters);
numVorTwoPartnersA = sum(vorTwoLogical,2);
[anglesTwoA,distTwoA,cellRowA] = gatherTwoAligns(allAngles,allDistances,vorTwoLogical,neuronTracker);
toc

% Try to register each
jMin = 0.1;
jStep = 0.05;
jMax = 10;
jittersTry = jMin:jStep:jMax;
tic
jj = 0;
doneJittering = 0;
while doneJittering==0
    jj = jj+1;
    
    thisJitterRadius = jittersTry(jj);
    disp(['Now testing jitter radius ' num2str(thisJitterRadius) ' pixels'])
    
    for tt = 1:triesPerJitter
        % Get the random offsets
        
        randsUse = [];
        while size(randsUse,1)<numCellsB
            %{
            randHere = (rand(1,2)*2*thisJitterRadius)-thisJitterRadius;
            
            % Keep radius within a circular radius
            if hypot(abs(randHere(1)),abs(randHere(2))) < thisJitterRadius 
                randsUse = [randsUse; randHere];
            end
            %}
            
            % Set radius at a particular dist
            % Uniform distribution of radii
            %rhoRnd = rand(numCellsB,1)*thisJitterRadius;
            % All cells same radius
            rhoRnd = ones(numCellsB,1)*thisJitterRadius;
            thetaRnd = (rand(numCellsB,1)-0.5)*pi;
            [randsUse(:,1),randsUse(:,2)] = pol2cart(thetaRnd,rhoRnd);
            
        end
        jCenters = imCenters + randsUse;
        
        % Try aligning cells, see what happens
            % fit transform with cell to cell
            % get closest matches
        
        % Then try finding our registration
        [allAnglesB,allDistancesB,vorTwoLogicalB,neuronTrackerB] = setupForAligns(jCenters);
        numVorTwoPartnersB = sum(vorTwoLogicalB,2);
        [anglesTwoB,distTwoB,cellRowB] = gatherTwoAligns(allAnglesB,allDistancesB,vorTwoLogicalB,neuronTrackerB);

        angleBinWidth = 1;
        distBinWidth = 1;
        
        angleDiffs = anglesTwoA(:) - anglesTwoB(:)'; % ( anglesTwoA(i),anglesTwoB(j) )
        distanceDiffs = abs(distTwoA(:) - distTwoB(:)'); % Difference between distances of tier 2 vor points from each other
        [angleDiffsRect] = RectifyAngleDiffs(rad2deg(angleDiffs),'deg'); %%% slow?
        %angleDiffsAbs = round(abs(angleDiffsRect),4); % In degrees from here
        angleDiffsAbs = abs(angleDiffsRect);
        
        clear angleDiffs angleDiffsRect
        
        cellCellA = repmat(cellRowA(:),1,length(cellRowB));
        cellCellB = repmat(cellRowB(:)',length(cellRowA),1);
        
        cellRowA2 = cellRowA;
        cellRowB2 = (cellRowB-1)*numCellsA;
        cellCellA2 = repmat(cellRowA2(:),1,length(cellRowB2));
        cellCellB2 = repmat(cellRowB2(:)',length(cellRowA2),1);
        
        intCellIDs = cellCellA2 + cellCellB2;   % Creates a unique integer identifier for each 
        imagCellIDs = cellCellA + cellCellB*1i; % Creates a unique identifier for each A-B voronoi-tier 2 cell pair
        
        [angleRadDiffDistribution,yEdges,xEdges,angleBinAssigned,distBinAssigned] = histcounts2(angleDiffsAbs,distanceDiffs); %%% slow
        
        [diffDistSorted,sordIdx] = sort(angleRadDiffDistribution(:),'descend');
        
        theseBins = sordIdx(1:nPeaksCheck);
        ptsTheseBins = angleRadDiffDistribution(theseBins);
        ARDdistSz = size(angleRadDiffDistribution);
        
        clear angleRadDiffDistribution
        
        disp('Peak evaluation initialization')
        pcI = 1;
        thisBin = theseBins(pcI);
        [bRow,bCol] = ind2sub(ARDdistSz,thisBin);
        nPtsHere(pcI) = ptsTheseBins(pcI);
            
        thisAngleBin = mean([yEdges(bRow) yEdges(bRow+1)]);
        thisDistBin = mean([xEdges(bCol) xEdges(bCol+1)]);
        
        gg = allDistances(:) - allDistancesB(:);
        angleBinLog(jj,tt) = thisAngleBin;
        distBinLog(jj,tt) = thisDistBin;
        distChangeLong(jj,tt) = std(gg);
        
        % Get the cell pairs that ended up in this bin
        angleDiffsHere = angleBinAssigned==bRow;
        distDiffsHere = distBinAssigned==bCol;
        angleDistHere = angleDiffsHere & distDiffsHere;
        
        imagCellIdsHere = cellCellA(angleDistHere) + cellCellB(angleDistHere)*1i;
        intCellIdsHere = cellCellA2(angleDistHere) + cellCellB2(angleDistHere);
        % maybe there's a logical here to get still present from all

        [uniqueCellPairs,~,ic] = unique(imagCellIdsHere);
        
        disp('Peak quality checking')
        [uniqueCellsUse,uniqueCellsUseMax,totalAligns,meanAligns] =...
            initClusterStats(uniqueCellPairs,ic,numCellsA,numCellsB);
        uniqueCellsUsePairs = [real(uniqueCellsUse) imag(uniqueCellsUse)];
        
        disp('Peak quality evaluation')
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
        
        leftoverUEangles(jj,tt) = sum(sum(unexplainedAngles)) - sum(totalUEangles);
        leftoverUEdist(jj,tt) = sum(sum(unexplainedDist)) - sum(totalUEdist);
        
        numVorApartners{jj,tt} = numVorTwoPartnersA(uniqueCellsUsePairs(:,1));
        numVorBpartners{jj,tt} = numVorTwoPartnersB(uniqueCellsUsePairs(:,2));
        
        sumUEangles(jj,tt) = sum(hereUEangles);
        sumUEdist(jj,tt) = sum(hereUEdist);
        meanUEangles(jj,tt) = mean(hereUEangles);
        stdUEangles(jj,tt) = std(hereUEangles);
        meanUEdist(jj,tt) = mean(hereUEdist);
        stdUEdist(jj,tt) = std(hereUEdist);
        propUEangles(jj,tt) = sum(hereUEangles)/sum(totalUEangles);
        propUEdist(jj,tt) = sum(hereUEdist)/sum(totalUEdist); %
        numPairedCells(jj,tt) = length(uniqueCellsUse);

        clear unexplainedAngles unexplainedDist totalUEangles totalUEdist uniqueInAllImag 
        
        % Evaluate that transformation
        anchorCellsA = uniqueCellsUsePairs(:,1);
        anchorCellsB = uniqueCellsUsePairs(:,2);
        
        % Run this registration and check how well it went
        [tform, reg_shift_centers, closestPairs, nanDistances, regStats] =...
            testRegistration(anchorCellsA,allCenters,anchorCellsB,jCenters,distanceThreshold);
        
        % Set up some regStats to evaluate
        %{
        regMats.pctMatchedCells(ccI,ccJ,pcI) = mean([regStats{pcI}.pctAllMatchedA regStats{pcI}.pctAllMatchedB]);
        regMats.pctMatchedAnchors(ccI,ccJ,pcI) = mean([regStats{pcI}.pctMatchAnchorsA regStats{pcI}.pctMatchAnchorsB]);
        regMats.meanVorTwoPartners(ccI,ccJ,pcI) = mean([numVorApartners{ccI,ccJ,pcI}; numVorBpartners{ccI,ccJ,pcI}]);
        regMats.UEanglePerAnchor(ccI,ccJ,pcI) = sumUEangles(ccI,ccJ,pcI) / length(anchorCellsA);
        regMats.UEdistPerAnchor(ccI,ccJ,pcI) = sumUEdist(ccI,ccJ,pcI) / length(anchorCellsA);
        regMats.UEanglePerVorTwo(ccI,ccJ,pcI) = sumUEangles(ccI,ccJ,pcI) / sum(min([numVorApartners{ccI,ccJ,pcI}, numVorBpartners{ccI,ccJ,pcI}],[],2));
        regMats.UEdistPerVorTwo(ccI,ccJ,pcI) = sumUEdist(ccI,ccJ,pcI) / sum(min([numVorApartners{ccI,ccJ,pcI}, numVorBpartners{ccI,ccJ,pcI}],[],2));
        %}
        
        % Say whether the registration was successful or not
        pctCorrect(jj,tt) = sum(closestPairs(:,1) == closestPairs(:,2)) / numCellsA;
        
    end
        
    doneJittering = sum(pctCorrect(jj,:))<2;        
end
    
keyboard
%{
regMats.UEanglePerVorTwoPerAnchor = regMats.UEanglePerVorTwo ./ numPairedCells;

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
%}
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [allAngles,allDistances,vorTwo,neuronTracker] = setupForAligns(allCenters)

numCells = size(allCenters,1);
allDistances = GetAllPtToPtDistances(allCenters(:,1),allCenters(:,2),[]);
allAngles = GetAllPtToPtAngles(allCenters);
[vorVertices,vorIndices] = voronoin(allCenters);
vorAdjacency = GetVoronoiAdjacency(vorIndices,vorVertices);
vorAdjTiers = GetAllTierAdjacency(vorAdjacency,2);
edgePolys = GetVoronoiEdges(vorVertices,allCenters,vorIndices);
vorAdjTiers(vorAdjTiers==0) = NaN;
vorAdjTiers(edgePolys,:) = NaN;
vorTwo = vorAdjTiers<=2; %logical
neuronTracker = repmat([1:numCells]',1,numCells)';

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [anglesTwo,distTwo,cellRow] = gatherTwoAligns(allAngles,allDistances,vorTwoLogical,neuronTracker);

anglesTwo = allAngles(vorTwoLogical);
distTwo = allDistances(vorTwoLogical);
cellRow = neuronTracker(vorTwoLogical);

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