function voronoiRegNotes2_5()
% Building things out to function to start testing alignments of image
% parts, jittering base image cell centers by a small random amount
% Could also try manipulating the angle or distance offsets to see the
% effects, though not sure what to predict there
% Still no plains for A==B,B==C,A~=C misalignments

%keyboard

imPathA = 'C:\Users\samwi_000\Desktop\Pandora\180629\FinalOutput.mat';
imPathB = 'C:\Users\samwi_000\Desktop\Pandora\180630\FinalOutput.mat';
load('C:\Users\samwi_000\Desktop\Pandora\trialbytrial.mat','sortedSessionInds')

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

% Rotate and re-find centers
NeuronImageB = cellfun(@(x) imrotate(x,90),NeuronImageB,'UniformOutput',false);
allCentersB = getAllCellCenters(NeuronImageB,true);

% Grid midpoints for reference
aMidsX = mean(aBlocksX,2);  aMidsY = mean(aBlocksY,2);
[aGridsX,aGridsY] = meshgrid(aMidsX,aMidsY);
bMidsX = mean(bBlocksX,2);  bMidsY = mean(bBlocksY,2);
[bGridsX,bGridsY] = meshgrid(bMidsX,bMidsY);
bGridsXrot = bGridsY;
bGridsYrot = fliplr(bGridsX);

% Get some baselines to evaluate registration
% Distance Jitter
%notes 2_3
jDistA = 100;
jDistB = 100;

% Downsample jitter - this could tell a minimum number of cells needed to have a good cluster
%notes 2_4

% Try to register
ardHold = [];
ardHoldD = [];
abinn = [0:1:180];
dbinn = [0:1:10];
dThreshUse = distanceThreshold;
hh = waitbar(0,'Starting to register');
tic
for blockA = 1:nBlocks
    % Prep block A
    useCentersA = allCentersA(cellAssignA{blockA},:);
    [allAnglesA,allDistancesA,vorTwoLogicalA,neuronTrackerA] = setupForAligns(useCentersA,vorAdjacencyMax);
    [anglesTwoA,distTwoA,cellRowA] = gatherTwoAligns(allAnglesA,allDistancesA,vorTwoLogicalA,neuronTrackerA);
    numVorTwoPartnersA = sum(vorTwoLogicalA,2);
    
    for blockB = 1:nBlocks
        try
        waitX = blockB + nBlocks*(blockA-1);
        waitbar(waitX/(nBlocks^2+1),hh,['Working on ' num2str(waitX) '/' num2str(nBlocks^2) '...'])
        end
        % Prep block B
        useCentersB = allCentersB(cellAssignB{blockB},:);
        [allAnglesB,allDistancesB,vorTwoLogicalB,neuronTrackerB] = setupForAligns(useCentersB,vorAdjacencyMax);
        [anglesTwoB,distTwoB,cellRowB] = gatherTwoAligns(allAnglesB,allDistancesB,vorTwoLogicalB,neuronTrackerB);
        numVorTwoPartnersB = sum(vorTwoLogicalB,2);
        
        % Creates a unique integer identifier for each A-B voronoi-tier 2 cell pair parent
        intCellIDs = generateUniqueIntIDs(cellRowA,cellRowB); 
        
        % Start finding the alignment cluster
        [angleDiffsAbs,distanceDiffs] = getAngleDistDiffs(anglesTwoA,distTwoA,anglesTwoB,distTwoB);
        
        [~,C{blockA,blockB}] = kmeans([angleDiffsAbs(distanceDiffs<dThreshUse) distanceDiffs(distanceDiffs<dThreshUse)],1);
        %{
        [angleRadDiffDistribution,yEdges,xEdges,angleBinAssigned,distBinAssigned] =...
            histcounts2(angleDiffsAbs(distanceDiffs<10),distanceDiffs(distanceDiffs<10),abinn,dbinn); %%% slow
        
        if isempty(ardHold)
            ardHold = angleRadDiffDistribution;
        else
            ardHold = ardHold + angleRadDiffDistribution;
        end
        %}
        %{
        [angleRadDist,yEdges,angleBinAssigned] = histcounts(angleDiffsAbs(distanceDiffs<3),abinn);  
        if isempty(ardHoldD)
            ardHoldD = angleRadDist;
        else
            ardHoldD = ardHoldD + angleRadDist;
        end
        %}
    end
end
try; close(hh); end
toc

clustAngles = cellfun(@(x) x(1),C,'UniformOutput',true);
clustDists = cellfun(@(x) x(2),C,'UniformOutput',true);

% How do we get the appropriate range of angles here?
%{
thisDistBin = 0;
binWidth = 1;
thisAngleBin = 90;
binHere = thisAngleBin+(binWidth/2)*[-1 1];

blockA = 1;
blockB = 1;
%}
thisDistBin = dThreshUse/2; thisDistBin = 0;
binWidth = 1;
thisAngleBin = mean(mean(clustAngles)); 
binHere = thisAngleBin+(binWidth/2)*[-1 1];
for blockA = 1:nBlocks
    % Prep block A
    useCentersA = allCentersA(cellAssignA{blockA},:);
    numUseCellsA = size(useCentersA,1);
    [allAnglesA,allDistancesA,vorTwoLogicalA,neuronTrackerA] = setupForAligns(useCentersA,vorAdjacencyMax,true);
    [anglesTwoA,distTwoA,cellRowA] = gatherTwoAligns(allAnglesA,allDistancesA,vorTwoLogicalA,neuronTrackerA);
    numVorTwoPartnersA = sum(vorTwoLogicalA,2);
    
    for blockB = 1:nBlocks
        %waitX = blockB + nBlocks*(blockA-1);
        %waitbar(waitX/(nBlocks^2),['Working on ' num2str(waitX) '/' num2str(nBocks^2) '...'])
        
        % Prep block B
        useCentersB = allCentersB(cellAssignB{blockB},:);
        numUseCellsB = size(useCentersB,1);
        [allAnglesB,allDistancesB,vorTwoLogicalB,neuronTrackerB] = setupForAligns(useCentersB,vorAdjacencyMax,true);
        [anglesTwoB,distTwoB,cellRowB] = gatherTwoAligns(allAnglesB,allDistancesB,vorTwoLogicalB,neuronTrackerB);
        numVorTwoPartnersB = sum(vorTwoLogicalB,2);
       
        % Creates a unique integer identifier for each A-B voronoi-tier 2 cell pair parent
        intCellIDs = generateUniqueIntIDs(cellRowA,cellRowB); % VorTwo
        %intCellIDall = generateUniqueIntIDs(1:numUseCellsA,1:numUseCellsB); % Basically a well-structured sub2ind, with inds in subscript locations
          
        [angleDiffsAbs,distanceDiffs] = getAngleDistDiffs(anglesTwoA,distTwoA,anglesTwoB,distTwoB);
        
        angleDiffsHere = (angleDiffsAbs <= max(binHere)) & (angleDiffsAbs >= min(binHere));
        distDiffsHere = distanceDiffs < dThreshUse;
        angleDistHere = angleDiffsHere & distDiffsHere; % Logical identifier for angle and dist differences in current histogram bin
        
        %imagCellIdsHere = imagCellIDs(angleDistHere); % All the unique cell pair identifiers for vorTwoPairs with angle/dist in this bin
        intCellIdsHere = intCellIDs(angleDistHere);
        
        [uniqueCellPairsInts,~,ic] = unique(intCellIdsHere);
        uniqueCellPairs = intsToCells(uniqueCellPairsInts,numUseCellsA,numUseCellsB);
        
        disp('Peak quality checking')
        [uniqueCellsUsePairs,uniqueCellsUseMax,totalAligns,meanAligns] =...
            initClusterStats(uniqueCellPairs,ic,numUseCellsA,numUseCellsB);
        alignCells{blockA,blockB} = uniqueCellsUsePairs;

        B = uint8(intCellIDs);
        D = uint8(unique(intCellIdsHere));
        % disp verify this is really working...
        [uniqueInAllInts] = ismembc(B,D); 
            % logical of all vor two pairs for any belonging to the cell pair that had at least 1 used this bins        
        
        disp('Peak quality evaluation')
        % Explained angle/distance variance by this bin
        % unexplainedAngles = abs(angleDiffsAbs-thisAngleBin);
        % unexplainedDist = abs(distanceDiffs-thisDistBin);
        % %{
        evalStats{blockA,blockB} = EvaluatePeakQuality(abs(angleDiffsAbs-thisAngleBin),abs(distanceDiffs-thisDistBin),angleDistHere,uniqueInAllInts);
            % This should be refind to the unique cells used here?
        evalStats{blockA,blockB}.numPairedCells = length(uniqueCellsUsePairs);
        evalStats{blockA,blockB}.numVorApartners = numVorTwoPartnersA(uniqueCellsUsePairs(:,1));
        evalStats{blockA,blockB}.numVorBpartners = numVorTwoPartnersB(uniqueCellsUsePairs(:,2));         
        %}
        
        [minInds,nanDistances] = findDistanceMatches(distances,otherCriteria)
        
        % Evaluate that transformation, Run this registration and check how well it went
        anchorCellsA = uniqueCellsUsePairs(:,1);
        anchorCellsB = uniqueCellsUsePairs(:,2);

        [tform{blockA,blockB}, reg_shift_centers{blockA,blockB}, closestPairs{blockA,blockB}, nanDistances{blockA,blockB}, regStats{blockA,blockB}] =...
            testRegistration(anchorCellsA,useCentersA,anchorCellsB,useCentersB,distanceThreshold);
        
    end
end

% Test if transforming the mid points produces an appropriate expected grid 
for blockA = 1:nBlocks
    for blockB = 1:nBlocks
        [gridMidTestX(blockA,blockB),gridMidTestY(blockA,blockB)] = transformPointsForward(tform{blockA,blockB},bGridsXrot(blockB),bGridsYrot(blockB));
    end
end

[allAnglesAA,allDistancesAA,vorTwoLogicalAA,neuronTrackerAA] = setupForAligns(allCentersA,vorAdjacencyMax);
[allAnglesBB,allDistancesBB,vorTwoLogicalBB,neuronTrackerBB] = setupForAligns(allCentersB,vorAdjacencyMax);

cellsBoth = sum(sortedSessionInds(:,[2 3])>0,2)==2;
tbtPairs = [sortedSessionInds(cellsBoth,2:3)];
   tic
for cbI = 1:size(tbtPairs,1)
    cellA = tbtPairs(cbI,1);
    cellB = tbtPairs(cbI,2);
    
    % Get the tier2 angles, distances for cell and B
    [anglesTwoAA,distTwoAA,cellRowAA] = gatherTwoAligns(allAnglesAA(cellA,:),allDistancesAA(cellA,:),vorTwoLogicalAA(cellA,:),neuronTrackerAA(cellA,:));
    [anglesTwoBB,distTwoBB,cellRowBB] = gatherTwoAligns(allAnglesBB(cellB,:),allDistancesBB(cellB,:),vorTwoLogicalBB(cellB,:),neuronTrackerBB(cellB,:));
    
    % Get the differences here A vs B
    [angleDiffsAbs,distanceDiffs] = getAngleDistDiffs(anglesTwoAA,distTwoAA,anglesTwoBB,distTwoBB);
    
    % Compare to what was found automatically    
    explainedHere = angleDiffsAbs - 90;
    
    nRight(cbI) = sum(sum(angleDiffsAbs >= min(binHere) & angleDiffsAbs <= max(binHere)));
    pctRight(cbI) = nRight(cbI) / (length(anglesTwoAA)*length(anglesTwoBB));
    posRight(cbI) = nRight(cbI) / min([length(anglesTwoAA) length(anglesTwoBB)]);
    
   
    
    %How....?
        
end
toc

        angleDiffsHere = (angleDiffsAbs <= max(binHere)) & (angleDiffsAbs >= min(binHere));
        distDiffsHere = distanceDiffs < dThreshUse;
        angleDistHere = angleDiffsHere & distDiffsHere; % Logical identifier for angle and dist differences in current histogram bin
        
        %imagCellIdsHere = imagCellIDs(angleDistHere); % All the unique cell pair identifiers for vorTwoPairs with angle/dist in this bin
        intCellIdsHere = intCellIDs(angleDistHere);


% Test voronoi alignment of the registered cells
nAnchorsHere = size(alignCells{1},1);
useCentersA = allCentersA(cellAssignA{1},:);
basePairCenters = useCentersA(alignCells{1}(:,1),:);
useCentersB = allCentersB(cellAssignB{1},:);
regPairCenters = useCentersB(alignCells{1}(:,2),:);
[baseAngles,baseDistances,baseVorTwo,ntBase] = setupForAligns(basePairCenters,vorAdjacencyMax,false);
[regAngles,regDistances,regVorTwo,ntReg] = setupForAligns(regPairCenters,vorAdjacencyMax,false);
[baseVorTiers,~] = GetAllVorAdjacency(basePairCenters); % All adjacency
[regVorTiers,] = GetAllVorAdjacency(regPairCenters);

baseVorOne = baseVorTiers==1;
regVorOne = regVorTiers==1;
[vorCa,~] = GetAllVorAdjacency(useCentersA);
[vorCb,~] = GetAllVorAdjacency(useCentersB);
aVorOne = vorCa==1;
bVorOne = vorCb==1;

aa = figure; imagesc(create_AllICmask(NeuronImageA(cellAssignA{1,1}))); axis xy
hold on
plot(basePairCenters(:,1),basePairCenters(:,2),'.r')
datacursormode on
dcm_obj = datacursormode(bb);
set( dcm_obj, 'UpdateFcn', @clickedPtIndex );

hold on
ci = 79
plot(basePairCenters(ci,1),basePairCenters(ci,2),'r*')
sum(baseVorTwo(ci,:))
plot(basePairCenters(baseVorTwo(ci,:),1),basePairCenters(baseVorTwo(ci,:),2),'*m')
plot(basePairCenters(baseVorOne(ci,:),1),basePairCenters(baseVorOne(ci,:),2),'*g')

figure; voronoi(basePairCenters(:,1),basePairCenters(:,2))

bb = figure; imagesc(create_AllICmask(NeuronImageB(cellAssignB{1,1}))); axis xy
hold on
plot(regPairCenters(:,1),regPairCenters(:,2),'.r')
datacursormode on
dcm_obj = datacursormode(bb);
set( dcm_obj, 'UpdateFcn', @clickedPtIndex );
hold on
ci = 79
plot(regPairCenters(ci,1),regPairCenters(ci,2),'r*')
sum(regVorTwo(ci,:))
plot(regPairCenters(regVorTwo(ci,:),1),regPairCenters(regVorTwo(ci,:),2),'*m')
plot(regPairCenters(regVorOne(ci,:),1),regPairCenters(regVorOne(ci,:),2),'*g')



% Steps outlined in Evernote 200812 to identify similar angles
[wellAligned,goodMatches,diffLogs,cellTripLog] = targetedAlignmentSame(basePairCenters,regPairCenters);
%{
aa = figure; imagesc(create_AllICmask(NeuronImageA(cellAssignA{1,1}))); axis xy
hold on
plot(basePairCenters(:,1),basePairCenters(:,2),'.r')
plot(basePairCenters(find(goodMatches),1),basePairCenters(find(goodMatches),2),'*g')
title('Base refined anchor cells')

bb = figure; imagesc(create_AllICmask(NeuronImageB(cellAssignB{1,1}))); axis xy
hold on
plot(regPairCenters(:,1),regPairCenters(:,2),'.r')
plot(regPairCenters(find(goodMatches),1),regPairCenters(find(goodMatches),2),'*g')
title('reg refined anchor cells')
%}

% Index back into this whole population
anchorCellsA = alignCells{1}(find(goodMatches),1);
anchorCellsB = alignCells{1}(find(goodMatches),2);

anchorsLogicalA = false(size(useCentersA,1),1); anchorsLogicalA(anchorCellsA) = true;
anchorsLogicalB = false(size(useCentersB,1),1); anchorsLogicalB(anchorCellsB) = true;
cellsMissedA = ~anchorsLogicalA;
cellsMissedB = ~anchorsLogicalB;

gAnchorsA = basePairCenters(wellAligned,:); % gAnchorsAA = useCentersA(anchorCellsA,:); % should be the same...
gAnchorsB = regPairCenters(wellAligned,:); % gAnchorBB = useCentersB(anchorCellsB,:);

% Difference should be some threshold within the range established by diffLogs
[~,AorB] = min([sum(cellsMissedA) sum(cellsMissedB)]);
switch AorB
    case 1
        ptsCheck = find(cellsMissedA);
    case 2
        ptsCheck = find(cellsMissedB);
end

for pcI = 1:length(ptsCheck)
    pHere = ptsCheck(pcI);
    
    % Diff from all these anchor points like 
    diffsBfromA = ptRsA.angles - dAnglesB;  % Could keep this as the set NOT to end up in...
            [diffBfA,dBAidx] = min(mean(abs(diffsBfromA),2)); 
            BmatchA = dBAidx == DTaInd;
%hh = mat2cell(ptRsB.angles,ones(185,1),3);
%jj= cellfun(@(x) ptRsA.angles-x,hh,'UniformOutput',false);
% Sequential could make a cool plotting animation...

end

%{
baseVorOne = GetVoronoiAdjacency2(basePairCenters);
regVorOne = GetVoronoiAdjacency2(basePairCenters);


DTa = delaunay(basePairCenters(:,1),basePairCenters(:,2)); 
DTaSorted = sort(DTa,2,'ascend');
DTb = delaunay(regPairCenters(:,1),regPairCenters(:,2));   
DTbSorted = sort(DTb,2,'ascend');

% Get angles between anchor points
ptRsA = GetThreePtRelations(basePairCenters(:,1),basePairCenters(:,2),DTaSorted); % For this triplet of points, its the angle off the middle pt
ptRsB = GetThreePtRelations(regPairCenters(:,1),regPairCenters(:,2),DTbSorted);

% Refine anchor vor to where it claims it's aligned
%{
bbb = baseVorOne*4;
gg = bbb-regVorOne;
%[ii,jj] = ind2sub([98 98],find(gg==3)); % A 3 where vorAdjOne in base matches vorAdjOne in reg
claimedMatch = gg==3;
%}
claimedMatch = baseVorOne & regVorOne;

%either = baseVorOne | regVorOne;
%leftOut = either; leftOut(claimedMatch) = false;
% sum(sum(either)) == sum(sum(claimedMatch)) + sum(sum(leftOut))

% leftOut:
% DT in vorOne:
%{
DTinVorOneBase = sub2ind(nAnchorsHere*[1 1],DTaSorted(:,1),DTaSorted(:,2));
DTinVorOneBase = [DTinVorOneBase; sub2ind(nAnchorsHere*[1 1],DTaSorted(:,2),DTaSorted(:,3))];
DTinVorOneBase = [DTinVorOneBase; sub2ind(nAnchorsHere*[1 1],DTaSorted(:,3),DTaSorted(:,1))];
DTinvorOneBaseLogical = false(nAnchorsHere); 
DTinvorOneBaseLogical(DTinVorOneBase) = 1;
%}

% Get these angles...
moreThanOneVor = find(sum(claimedMatch,2)>1);
goodMatches = zeros(size(basePairCenters,1),1);
diffAfBlog = [];
diffBfAlog = [];
for mmI = 1:length(moreThanOneVor)
    aCell = moreThanOneVor(mmI);
    basePartners = find(baseVorOne(aCell,:));
    regPartners = find(regVorOne(aCell,:));
    
    haveBoth = basePartners == regPartners(:);
    cellsInBoth = basePartners(logical(sum(haveBoth,1)));
    
    otherPairs = nchoosek(cellsInBoth,2);
    for opI = 1:size(otherPairs,1)
        % Find the index of this triplet in DTa and DTb so we can check angles
        % Sort to make this easier
        tripFind = sort([aCell otherPairs(opI,:)],'ascend');
        
        DTaInd = find(sum(DTaSorted==tripFind,2)==3); % Index of this triplet in DTa
        DTbInd = find(sum(DTbSorted==tripFind,2)==3); % ...DTb
        
        if any(DTaInd) && any(DTbInd) % There was a delaunay triplet with these cells
            % The angles in this delaunay triangle
            dAnglesA = ptRsA.angles(DTaInd,:);
            dAnglesB = ptRsB.angles(DTbInd,:);

            % How do they compare to set from other map?
            diffsAfromB = ptRsB.angles - dAnglesA;
            [diffAfB,dABidx] = min(mean(abs(diffsAfromB),2)); % Index of the minimum of the mean of smallest angle differences for triplets
            AmatchB = dABidx == DTbInd; % Matches the index from other? True if this is the best match among other delaunay triplets

            diffsBfromA = ptRsA.angles - dAnglesB;
            [diffBfA,dBAidx] = min(mean(abs(diffsBfromA),2)); 
            BmatchA = dBAidx == DTaInd;

            diffAfBlog = [diffAfBlog; diffAfB];
            diffBfAlog = [diffBfAlog; diffBfA];
            % Here we could also check distances

            if AmatchB && BmatchA
                % Nice, found a match,conclude these pts are good
                goodMatches(tripFind) = goodMatches(tripFind) + 1;
            end
        end
    end
end

%}


%{
aa = figure; imagesc(create_AllICmask(NeuronImageA(cellAssignA{1,1}))); axis xy
hold on
plot(basePairCenters(:,1),basePairCenters(:,2),'.r')
plot(basePairCenters(find(goodMatches),1),basePairCenters(find(goodMatches),2),'*g')
title('Base refined anchor cells')

bb = figure; imagesc(create_AllICmask(NeuronImageB(cellAssignB{1,1}))); axis xy
hold on
plot(regPairCenters(:,1),regPairCenters(:,2),'.r')
plot(regPairCenters(find(goodMatches),1),regPairCenters(find(goodMatches),2),'*g')
title('reg refined anchor cells')

%}

% From here we have to option to try a new transform with these refined
% anchor cells, or to try iterating outwards and find all possible matches
% Iterating out: Either way, need to turn that code from above into a function
    % Just iterate on possible anchors where vor said a match but were left out of the delaunay
    % Step through each anchor that still has a 0 in 
    % All other cells: get a delaunay on the entire set of rois, try to match

DTaAll = delaunay(useCentersA(:,1),useCentersA(:,2));

anchorCellsA = alignCells{1}(find(goodMatches),1);
anchorCellsB = alignCells{1}(find(goodMatches),2);
[tf, rscs, cps, nds, rss] =...
            testRegistration(anchorCellsA,useCentersA,anchorCellsB,useCentersB,distanceThreshold);
figure; imagesc(create_AllICmask(NeuronImageA(cellAssignA{1,1}))); axis xy
hold on
plot(useCentersA(:,1),useCentersA(:,2),'.r')
plot(rscs(:,1),rscs(:,2),'.g')
plot(useCentersA(cps(:,1),1),useCentersA(cps(:,1),2),'*c')
plot(useCentersA(anchorCellsA,1),useCentersA(anchorCellsA,2),'*m')






for ab = 1:length(ii)
    plot(basePairCenters([ii(ab) jj(ab)],1),basePairCenters([ii(ab) jj(ab)],2),'r') 
end


for ab = 1:length(ii)
    plot(regPairCenters([ii(ab) jj(ab)],1),regPairCenters([ii(ab) jj(ab)],2),'r') 
end
% Run pt To pt assignment
[closestPairs,pairDistances,allDistances,nanDistances,regStats] = evaluateRegistration(allCentersA,reg_shift_centers,anchorCellsA,anchorCellsB,distThresh);

figure; 
subplot(1,2,1); imagesc(create_AllICmask(NeuronImageA)); axis xy
hold on; plot(aGridsX(:),aGridsY(:)); plot(aGridsX(1),aGridsY(1),'r*'); plot(aGridsX(9),aGridsY(9),'g*');
subplot(1,2,2); imagesc(create_AllICmask(NeuronImageB)); axis xy
hold on; plot(bGridsXrot(:),bGridsYrot(:)); plot(bGridsXrot(1),bGridsYrot(1),'r*'); plot(bGridsXrot(9),bGridsYrot(9),'g*');

figure; 
subplot(1,2,1); imagesc(create_AllICmask(NeuronImageA(cellAssignA{1,1}))); axis xy
hold on; plot(aGridsX(1),aGridsY(1),'r*');
useCentersA = allCentersA(cellAssignA{1},:);
plot(useCentersA(alignCells{1,1}(:,1),1),useCentersA(alignCells{1,1}(:,1),2),'*g')
plot(useCentersA(alignCells{1,1}(1,1),1),useCentersA(alignCells{1,1}(1,1),2),'*r')
plot(reg_shift_centers{1,1}(alignCells{1,1}(1,2),1),reg_shift_centers{1,1}(alignCells{1,1}(1,2),2),'m*')


figure; 
subplot(1,2,1); imagesc(create_AllICmask(NeuronImageA(cellAssignA{1,1}))); axis xy
useCentersA = allCentersA(cellAssignA{1},:);
basePairCenters = useCentersA(alignCells{1}(:,1),:);
hold on;
plot(basePairCenters(:,1),basePairCenters(:,2),'*g')


subplot(1,2,2); imagesc(create_AllICmask(NeuronImageB(cellAssignB{1,1}))); axis xy
hold on;
useCentersB = allCentersB(cellAssignB{1},:);
regPairCenters = useCentersB(alignCells{1}(:,2),:);
plot(regPairCenters(:,1),regPairCenters(:,2),'*g')



subplot(1,2,1); plot(useCentersA(alignCells{1}(cf,1),1),useCentersA(alignCells{1}(cf,1),2),'*r')


cf = findclosest2D(basePairCenters(:,1),basePairCenters(:,2),70,19);
cff = findclosest2D(basePairCenters(:,1),basePairCenters(:,2),43,52);
cfff = findclosest2D(basePairCenters(:,1),basePairCenters(:,2),53,170);

plot(basePairCenters(cf,1),basePairCenters(cf,2),'*r')

dg = findclosest2D(regPairCenters(:,1),regPairCenters(:,2),30,531);
dgg = findclosest2D(regPairCenters(:,1),regPairCenters(:,2),60,560);
dggg = findclosest2D(regPairCenters(:,1),regPairCenters(:,2),180,550);

[cf dg; cff dgg; cfff dggg]

subplot(1,2,2); plot(useCentersB(alignCells{1}(cf,2),1),useCentersB(alignCells{1}(cf,2),2),'*r')


cf = 96;
subplot(1,2,1); plot(useCentersA(alignCells{1}(cf,1),1),useCentersA(alignCells{1}(cf,1),2),'*r')
subplot(1,2,2); plot(useCentersB(alignCells{1}(cf,2),1),useCentersB(alignCells{1}(cf,2),2),'*r')

plot(regPairCenters(alignCells{1}(cf,2),1),regPairCenters(alignCells{1}(cf,2),2),'*r')

for ii = 1:10
    [xx,yy] = ginput(1);
    sd = findclosest2D(regPairCenters(:,1),regPairCenters(:,2),xx,yy);
    subplot(1,2,1);
    plot(basePairCenters(sd,1),basePairCenters(sd,2),'*m')
    subplot(1,2,2);
    plot(regPairCenters(sd,1),regPairCenters(sd,2),'*m')
end

bCenters = getAllCellCenters(NeuronImage,true);

cellsBoth = sum(sortedSessionInds(:,[2 3])>0,2)==2;
tbtPairs = [sortedSessionInds(cellsBoth,2:3)];
    
        
    

regPairCenters = allCentersB(anchorCellsB,:);
numAnchorCells = length(anchorCellsA);

ttform = fitgeotrans(regPairCenters,basePairCenters,'affine');
reg_shift_centers = [];
[rsc(:,1),rsc(:,2)] = transformPointsForward(ttform,regPairCenters(:,1),regPairCenters(:,2));

regR = rsc(alignCells{1}(:,2),:);
plot(regR(96,1),regR(96,2),'*c')

plot(rsc(:,1),rsc(:,2),'*m')

bpcs = [basePairCenters(cf,:); basePairCenters(cff,:); basePairCenters(cfff,:)];
rpcs = [regPairCenters(dg,:); regPairCenters(dgg,:); regPairCenters(dggg,:)];

ttform = fitgeotrans(rpcs,bpcs,'affine');

[rscc(:,1),rscc(:,2)] = transformPointsForward(ttform,rpcs(:,1),rpcs(:,2));

plot(gridMidTestX(1,1),gridMidTestY(1,1),'*c')

subplot(1,2,2); imagesc(create_AllICmask(NeuronImageB(cellAssignB{1,1}))); axis xy
hold on; plot(bGridsXrot(1),bGridsYrot(1),'r*');
useCentersB = allCentersB(cellAssignB{1},:);
plot(useCentersB(cellPairs{1,1}(:,2),1),useCentersB(cellPairs{1,1}(:,2),2),'*g')
plot(useCentersB(cellPairs{1,1}(1,2),1),useCentersB(cellPairs{1,1}(1,2),2),'*r')



subplot(1,2,1);
plot(gridMidTestX(:),gridMidTestY(:),'*c')

figure; 
plot(bGridsXrot(:),bGridsYrot(:))
hold on
plot(bGridsXrot(1),bGridsYrot(1),'r*')
plot(bGridsXrot(9),bGridsYrot(9),'g*')

     disp('Also this time lets deal all the flags leftover on things to check')
   
    end

   

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
%end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [wellAligned,goodMatches,diffLogs,cellTripLog] = targetedAlignmentSame(basePairCenters,regPairCenters)
% This takes 2 sets of paired points and asks if the engles between those
% points (at dulaunay triangles) actually is similar between them
% Good matches says how many well-match delaunay triangles was it involved
% in, wellAligned is a logical of that
[baseVorTiers,] = GetAllVorAdjacency(basePairCenters);
baseVorOne = baseVorTiers==1;
[regVorTiers,] = GetAllVorAdjacency(regPairCenters);
regVorOne = regVorTiers==1;

DTa = delaunay(basePairCenters(:,1),basePairCenters(:,2)); 
DTaSorted = sort(DTa,2,'ascend');
DTb = delaunay(regPairCenters(:,1),regPairCenters(:,2));   
DTbSorted = sort(DTb,2,'ascend');

% Get angles between anchor points
ptRsA = GetThreePtRelations(basePairCenters(:,1),basePairCenters(:,2),DTaSorted); % For this triplet of points, its the angle off the middle pt
ptRsB = GetThreePtRelations(regPairCenters(:,1),regPairCenters(:,2),DTbSorted);

claimedMatch = baseVorOne & regVorOne;

% Get these angles...
moreThanOneVor = find(sum(claimedMatch,2)>1);
goodMatches = zeros(size(basePairCenters,1),1);
diffAfBlog = [];
diffBfAlog = [];
for mmI = 1:length(moreThanOneVor)
    aCell = moreThanOneVor(mmI);
    basePartners = find(baseVorOne(aCell,:));
    regPartners = find(regVorOne(aCell,:));
    
    haveBoth = basePartners == regPartners(:);
    cellsInBoth = basePartners(logical(sum(haveBoth,1)));
    
    otherPairs = nchoosek(cellsInBoth,2);
    for opI = 1:size(otherPairs,1)
        % Find the index of this triplet in DTa and DTb so we can check angles
        % Sort to make this easier
        tripFind = sort([aCell otherPairs(opI,:)],'ascend');
        
        DTaInd = find(sum(DTaSorted==tripFind,2)==3); % Index of this triplet in DTa
        DTbInd = find(sum(DTbSorted==tripFind,2)==3); % ...DTb
        
        if any(DTaInd) && any(DTbInd) % There was a delaunay triplet with these cells
            % The angles in this delaunay triangle
            dAnglesA = ptRsA.angles(DTaInd,:);
            dAnglesB = ptRsB.angles(DTbInd,:);

            % How do they compare to set from other map?
            diffsAfromB = ptRsB.angles - dAnglesA;
            [diffAfB,dABidx] = min(mean(abs(diffsAfromB),2)); % Index of the minimum of the mean of smallest angle differences for triplets
            AmatchB = dABidx == DTbInd; % Matches the index from other? True if this is the best match among other delaunay triplets

            diffsBfromA = ptRsA.angles - dAnglesB;  % Could keep this as the set NOT to end up in...
            [diffBfA,dBAidx] = min(mean(abs(diffsBfromA),2)); 
            BmatchA = dBAidx == DTaInd;

            % Here we could also check distances

            if AmatchB && BmatchA
                % Nice, found a match,conclude these pts are good
                goodMatches(tripFind) = goodMatches(tripFind) + 1;
                
                diffAfBlog = [diffAfBlog; diffAfB];
                diffBfAlog = [diffBfAlog; diffBfA];
                
                cellTripLog = [aCell, tripFind];
            end
        end
    end
end

minAligned = goodMatches>0;
diffLogs.diffAfBlog = diffAfBlog;
diffLogs.diffBfAlog = diffBfAlog;
% Get the distribution here
%hh = mat2cell(ptRsB.angles,ones(185,1),3);
%jj = cellfun(@(x) ptRsA.angles-x,hh,'UniformOutput',false);


end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [angleDiffsAbs,distanceDiffs] = getAngleDistDiffs(anglesTwoA,distTwoA,anglesTwoB,distTwoB)
            
 angleDiffs = anglesTwoA(:) - anglesTwoB(:)'; % ( anglesTwoA(i),anglesTwoB(j) )
distanceDiffs = abs(distTwoA(:) - distTwoB(:)'); % Difference between distances of tier 2 vor points from each other
[angleDiffsRect] = RectifyAngleDiffs(rad2deg(angleDiffs),'deg'); %%% slow?
angleDiffsAbs = abs(angleDiffsRect);

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function intCellIDs = generateUniqueIntIDs(cellRowA,cellRowB)

numCellsA = max(cellRowA);
    
cellCellA = repmat(cellRowA(:),1,length(cellRowB)); % By Row, vor2cells partners of cell n
cellCellB = repmat(cellRowB(:)',length(cellRowA),1); % By column, vor2cells partners of cell n
    
cellRowB2 = (cellRowB-1)*numCellsA;
cellCellA = repmat(cellRowA(:),1,length(cellRowB2));
cellCellB = repmat(cellRowB2(:)',length(cellRowA),1);

intCellIDs = cellCellA + cellCellB;   % Creates a unique integer identifier for each A-B voronoi-tier 2 cell pair parent
end        
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function uniqueCellPairsFixed = intsToCells(uniqueCellPairs,numCellsA,numCellsB)
% Converts unique integer IDs back to indices from the original
%cellRowB2 = (cellRowB-1)*numCellsA;

[uniqueCellPairsFixed(:,1),uniqueCellPairsFixed(:,2)] = ind2sub([numCellsA numCellsB],uniqueCellPairs);
%{
[uniqueCellPairsFixed(:,1),uniqueCellPairsFixed(:,2)]

uniqueCellPairsFixed(:,1) = rem(uniqueCellPairs,numCellsA);
uniqueCellPairsFixed(uniqueCellPairsFixed==0,1) = numCellsA;
uniqueCellPairsFixed(:,2) = floor(uniqueCellPairs/numCellsA)+1;
disp('Double check this line')
%}
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [allAngles,allDistances,vorTwo,neuronTracker] = setupForAligns(allCenters,vorAdjacencyMax,excludeEdges)

if isempty(excludeEdges)
    excludeEdges = false;
    disp('Including edge vors')
end

numCells = size(allCenters,1);
allDistances = GetAllPtToPtDistances(allCenters(:,1),allCenters(:,2),[]);
allAngles = GetAllPtToPtAngles(allCenters);
[vorAdjTiers,edgePolys] = GetAllVorAdjacency(allCenters);
vorAdjTiers(vorAdjTiers==0) = NaN;
if excludeEdges==true
    vorAdjTiers(edgePolys,:) = NaN;
end
vorTwo = vorAdjTiers<=vorAdjacencyMax; %logical
neuronTracker = repmat([1:numCells]',1,numCells)';

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [vorAdjTiers,edgePolys] = GetAllVorAdjacency(allCenters)
[vorVertices,vorIndices] = voronoin(allCenters);
vorAdjacency = GetVoronoiAdjacency(vorIndices,vorVertices);
%voronoiAdj = GetVoronoiAdjacency2(allCenters);
vorAdjTiers = GetAllTierAdjacency(vorAdjacency,[]);
edgePolys = GetVoronoiEdges(vorVertices,allCenters,vorIndices);
%vorAdjTiers(vorAdjTiers==0) = NaN;

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

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tform, reg_shift_centers, closestPairs, nanDistances, regStats] = testRegistration(anchorCellsA,allCentersA,anchorCellsB,allCentersB,distThresh)
% Anchor cells is an index?
if size(anchorCellsA,2)==1
    basePairCenters = allCentersA(anchorCellsA,:);
    regPairCenters = allCentersB(anchorCellsB,:);
elseif size(anchorCellsA,2)==2
    basePairCenters = anchorCellsA;
    regPairCenters = anchorCellsB;
end
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