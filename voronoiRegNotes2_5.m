function voronoiRegNotes2_5()
% Building things out to function to start testing alignments of image
% parts, jittering base image cell centers by a small random amount
% Could also try manipulating the angle or distance offsets to see the
% effects, though not sure what to predict there
% Still no plains for A==B,B==C,A~=C misalignments

keyboard

imPathA = 'F:\DoublePlus\Pandora\Pandora_180629\FinalOutput.mat';
imPathB = 'F:\DoublePlus\Pandora\Pandora_180630\FinalOutput.mat';

distanceThreshold = 3;
nPeaksCheck = 3;
vorAdjacencyMax = 2;

load(imPathA, 'NeuronImage');
NeuronImageA = NeuronImage;
load(imPathB, 'NeuronImage');
NeuronImageB = NeuronImage;
clear NeuronImage
%load('C:\Users\samwi_000\Desktop\FinalOutput.mat', 'NeuronImage')
% Rotate NeuronImageB?

numCellsA = length(NeuronImageA);
numCellsB = length(NeuronImageB);
allCentersA = getAllCellCenters(NeuronImageA,true);
allCentersB = getAllCellCenters(NeuronImageB,true);

% Get distribution of major axis length
axisLengthsA = getAllCellMajorAxis(NeuronImageA,true);
axisLengthsB = getAllCellMajorAxis(NeuronImageB,true);

% Basic starting parameters
distanceThreshold = 3;
nPeaksCheck = 1;
vorAdjacencyMax = 2;
triesPerDS = 5;
triesPerJitter = 5;
angleBinWidth = 1;
distBinWidth = 1;

% Break each image into chunks how many depends on how many cells, maybe how much memory?
cellsPerBlock = 400;
nBlocks = 9;

midXa = mean(allCentersA(:,1)); aLimsX = [min(allCentersA(:,1)) max(allCentersA(:,1))];
midYa = mean(allCentersA(:,2)); aLimsY = [min(allCentersA(:,2)) max(allCentersA(:,2))];
midXb = mean(allCentersB(:,1)); bLimsX = [min(allCentersB(:,1)) max(allCentersB(:,1))];
midYb = mean(allCentersB(:,2)); bLimsY = [min(allCentersB(:,2)) max(allCentersB(:,2))];
aWidth = aLimsX(2) - aLimsX(1); aHeight = aLimsY(2) - aLimsY(1);
bWidth = bLimsX(2) - bLimsX(1); bHeight = bLimsY(2) - bLimsY(1);

aBlocksX = [min(aLimsX) midXa; midXa+(aWidth/2/2)*[-1 1]; midXa max(aLimsX)];
aBlocksY = [min(aLimsY) midYa; midYa+(aHeight/2/2)*[-1 1]; midYa max(aLimsY)];
bBlocksX = [min(bLimsX) midXb; midXb+(bWidth/2/2)*[-1 1]; midXb max(bLimsX)];
bBlocksY = [min(bLimsY) midYb; midYb+(bHeight/2/2)*[-1 1]; midYb max(bLimsY)];

for ccX = 1:3
    for ccY = 1:3
        cellAssignA{ccX,ccY} = (allCentersA(:,1) >= aBlocksX(ccX,1) & allCentersA(:,1) <= aBlocksX(ccX,2)) & ...
                               (allCentersA(:,2) >= aBlocksY(ccY,1) & allCentersA(:,2) <= aBlocksY(ccY,2));
        cellAssignB{ccX,ccY} = (allCentersB(:,1) >= bBlocksX(ccX,1) & allCentersB(:,1) <= bBlocksX(ccX,2)) & ...
                               (allCentersB(:,2) >= bBlocksY(ccY,1) & allCentersB(:,2) <= bBlocksY(ccY,2));
    end
end

% Distance Jitter
%notes 2_3
jDistA = 100;
jDistB = 100;

% Downsample jitter - this could tell a minimum number of cells needed to have a good cluster
%notes 2_4

% Try to register
hh = waitbar(0,'Starting to register');
for blockA = 1:nBlocks
    % Prep block A
    useCentersA = allCentersA(cellAssignA{blockA},:);
    [allAnglesA,allDistancesA,vorTwoLogicalA,neuronTrackerA] = setupForAligns(useCentersA,vorAdjacencyMax);
    [anglesTwoA,distTwoA,cellRowA] = gatherTwoAligns(allAnglesA,allDistancesA,vorTwoLogicalA,neuronTrackerA);
    numVorTwoPartnersA = sum(vorTwoLogicalA,2);
    
    for blockB = 1:nBlocks
        waitX = blockB + nBlocks*(blockA-1);
        waitbar(waitX/(nBlocks^2),['Working on ' num2str(waitX) '/' num2str(nBocks^2) '...'])
        
        % Prep block B
        useCentersB = allCentersB(cellAssignB{blockB},:);
        [allAnglesB,allDistancesB,vorTwoLogicalB,neuronTrackerB] = setupForAligns(useCentersB,vorAdjacencyMax);
        [anglesTwoB,distTwoB,cellRowB] = gatherTwoAligns(allAnglesB,allDistancesB,vorTwoLogicalB,neuronTrackerB);
        numVorTwoPartnersB = sum(vorTwoLogicalB,2);
        
        intCellIDs = generateUniqueIntIDs(cellRowA,cellRowB); % Creates a unique integer identifier for each A-B voronoi-tier 2 cell pair parent
        
        %[uniqueCellsUsePairs,thisAngleBin,thisDistBin,angleDiffsAbs,distanceDiffs] = coreClusterFinder(anglesTwoA,distTwoA,cellRowA,anglesTwoB,distTwoB,cellRowB,distanceThreshold
        
        angleDiffs = anglesTwoA(:) - anglesTwoB(:)'; % ( anglesTwoA(i),anglesTwoB(j) )
        distanceDiffs = abs(distTwoA(:) - distTwoB(:)'); % Difference between distances of tier 2 vor points from each other
        [angleDiffsRect] = RectifyAngleDiffs(rad2deg(angleDiffs),'deg'); %%% slow?
        angleDiffsAbs = abs(angleDiffsRect);
        
        clear angleDiffs angleDiffsRect
        
        [angleRadDiffDistribution,yEdges,xEdges,angleBinAssigned,distBinAssigned] = histcounts2(angleDiffsAbs,distanceDiffs); %%% slow
        disp('this is where we really work from')
        disp('Also this time lets deal all the flags leftover on things to check')
        %{
        [angleRadDistribution,yEdges,angleBinAssigned] = histcounts(angleDiffsAbs(distanceDiffs<=distanceThreshold));          
        %}
        
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
        
        gg = allDistancesA(:) - allDistancesB(:);
        angleBinLog(iterI,tryI) = thisAngleBin;
        distBinLog(iterI,tryI) = thisDistBin;
        distChangeLong(iterI,tryI) = std(gg);
        
        % Get the cell pairs that ended up in this bin
        angleDiffsHere = angleBinAssigned==bRow;
        distDiffsHere = distBinAssigned==bCol;
        angleDistHere = angleDiffsHere & distDiffsHere; % Logical identifier for angle and dist differences in current histogram bin
        
        %imagCellIdsHere = imagCellIDs(angleDistHere); % All the unique cell pair identifiers for vorTwoPairs with angle/dist in this bin
        intCellIdsHere = intCellIDs(angleDistHere);

        [uniqueCellPairs,~,ic] = unique(intCellIdsHere);
        uniqueCellPairs = intsToCells(uniqueCellPairs,numCellsA);
        B = uint8(intCellIDs);
        D = uint8(unique(intCellIdsHere));
        % disp verify this is really working...
        [uniqueInAllInts] = ismembc(B,D); % logical of all vor two pairs for any belonging to the cell pair that had at least 1 
        
        disp('Peak quality checking')
        [uniqueCellsUsePairs,uniqueCellsUseMax,totalAligns,meanAligns] =...
            initClusterStats(uniqueCellPairs,ic,numCellsA,numCellsB);
        
        disp('Peak quality evaluation')
        % Explained angle/distance variance by this bin
        % unexplainedAngles = abs(angleDiffsAbs-thisAngleBin);
        % unexplainedDist = abs(distanceDiffs-thisDistBin);
        % %{
        evalStats = EvaluatePeakQuality(abs(angleDiffsAbs-thisAngleBin),abs(distanceDiffs-thisDistBin),angleDistHere,uniqueInAllImag);
            % This should be refind to the unique cells used here?
        evalStats.numVorApartners{dsI,tryI} = numVorTwoPartnersA(uniqueCellsUsePairs(:,1));
        evalStats.numVorBpartners{dsI,tryI} = numVorTwoPartnersB(uniqueCellsUsePairs(:,2));         
        %}
        
        % Evaluate that transformation, Run this registration and check how well it went
        anchorCellsA = uniqueCellsUsePairs(:,1);
        anchorCellsB = uniqueCellsUsePairs(:,2);

        [tform, reg_shift_centers, closestPairs, nanDistances, regStats] =...
            testRegistration(anchorCellsA,useCentersA,anchorCellsB,useCentersB,distanceThreshold);
        
        
    end
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
function intCellIDs = generateUniqueIntIDs(cellRowA,cellRowB)
numCellsA = length(cellRowA);
    
cellCellA = repmat(cellRowA(:),1,length(cellRowB)); % By Row, vor2cells partners of cell n
cellCellB = repmat(cellRowB(:)',length(cellRowA),1); % By column, vor2cells partners of cell n
    
cellRowB2 = (cellRowB-1)*numCellsA;
cellCellA = repmat(cellRowA(:),1,length(cellRowB2));
cellCellB = repmat(cellRowB2(:)',length(cellRowA),1);

intCellIDs = cellCellA + cellCellB;   % Creates a unique integer identifier for each A-B voronoi-tier 2 cell pair parent
end        
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function uniqueCellPairsFixed = intsToCells(uniqueCellPairs,numCellsA)
% Converts unique integer IDs back to indices from the original
%cellRowB2 = (cellRowB-1)*numCellsA;

uniqueCellPairsFixed(:,1) = uniqueCellPairs(:,1);
uniqueCellPairsFixed(:,2) = floor(uniqueCellPairs(:,2)/numCellsA)+1;
disp('Double check this line')

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [allAngles,allDistances,vorTwo,neuronTracker] = setupForAligns(allCenters,vorAdjacencyMax)

numCells = size(allCenters,1);
allDistances = GetAllPtToPtDistances(allCenters(:,1),allCenters(:,2),[]);
allAngles = GetAllPtToPtAngles(allCenters);
[vorVertices,vorIndices] = voronoin(allCenters);
vorAdjacency = GetVoronoiAdjacency(vorIndices,vorVertices);
vorAdjTiers = GetAllTierAdjacency(vorAdjacency,vorAdjacencyMax);
edgePolys = GetVoronoiEdges(vorVertices,allCenters,vorIndices);
vorAdjTiers(vorAdjTiers==0) = NaN;
vorAdjTiers(edgePolys,:) = NaN;
vorTwo = vorAdjTiers<=2; %logical
neuronTracker = repmat([1:numCells]',1,numCells)';

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [anglesTwo,distTwo,cellRow] = gatherTwoAligns(allAngles,allDistances,vorTwoLogical,neuronTracker)

anglesTwo = allAngles(vorTwoLogical);
distTwo = allDistances(vorTwoLogical);
cellRow = neuronTracker(vorTwoLogical);

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [uniqueCellsUse,uniqueCellsUseMax,totalAligns,meanAligns] = initClusterStats(uniqueCellPairs,ic,numCellsA,numCellsB);
% In the self-to-self, matched cells should all be where real and imaginary components are equal
realHere = uniqueCellPairs(:,1);
imagHere = uniqueCellPairs(:,2);
same = realHere == imagHere; % sum(same) should equal the number of cells not labeled as edge cells

% Restrict match counts by number of cells in a/b min([numCellsA numCellsB])
nMaxMatch = min([numCellsA numCellsB]);

% How many pairs in this alignment bin for each cell?
cellIdCounts = histcounts(ic,[0.5:1:(max(ic)+0.5)]); % cellIdCounts(same) histogram of pts from known matches in this angleDiff/distDiff bin
[sortedCellCounts,sortedCountsOrder] = sort(cellIdCounts,'descend');
uniqueCellsUseMax = uniqueCellPairs(sortedCountsOrder(1:nMaxMatch),:);
sortedNumAlignPartners = cumsum(sortedCellCounts); % Num alignments in this bin each cell

% Refine to eliminate overlapped cells, take whichever comes first in sortedCountsOrder
uReal = uniqueCellsUseMax(:,1);
uImag = uniqueCellsUseMax(:,2);
firstUR = false(length(uReal),1);
firstUI = false(length(uReal),1);
for ii = 1:length(uReal)
    firstUR(find(uReal==uReal(ii),1,'first')) = true;
    firstUI(find(uImag==uImag(ii),1,'first')) = true;
end
uKeep = firstUR & firstUI;

uniqueCellsUse = uniqueCellsUseMax(uKeep,:); % Cell pairs for alignment

totalAligns = sum(sortedNumAlignPartners(uKeep));
meanAligns = mean(sortedNumAlignPartners(uKeep)); % Num 2nd tier partner cells

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [evalStats] = EvaluatePeakQuality(unexplainedAngles,unexplainedDist,angleDistHere,uniqueInAllImag)

totalUEangles = unexplainedAngles(uniqueInAllImag);
totalUEdist = unexplainedDist(uniqueInAllImag);
hereUEangles = unexplainedAngles(angleDistHere);
hereUEdist = unexplainedDist(angleDistHere);

evalStats.leftoverUEangles = sum(sum(unexplainedAngles)) - sum(totalUEangles);
evalStats.leftoverUEdist = sum(sum(unexplainedDist)) - sum(totalUEdist);

evalStats.sumUEangles = sum(hereUEangles);
evalStats.sumUEdist = sum(hereUEdist);
evalStats.meanUEangles = mean(hereUEangles);
evalStats.stdUEangles = std(hereUEangles);
evalStats.meanUEdist = mean(hereUEdist);
evalStats.stdUEdist = std(hereUEdist);
evalStats.propUEangles = sum(hereUEangles)/sum(totalUEangles);
evalStats.propUEdist = sum(hereUEdist)/sum(totalUEdist); %
evalStats.numPairedCells = length(uniqueCellsUse);

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