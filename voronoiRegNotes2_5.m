function voronoiRegNotes2_5()
% Building things out to function to start testing alignments of image
% parts, jittering base image cell centers by a small random amount
% Could also try manipulating the angle or distance offsets to see the
% effects, though not sure what to predict there
% Still no plains for A==B,B==C,A~=C misalignments

keyboard

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
hh = waitbar(0,'Starting to register');
ardHold = [];
ardHoldD = [];
abinn = [0:1:180];
dbinn = [0:1:10];
dThreshUse = distanceThreshold;
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
thisDistBin = dThreshUse/2; thisDistBin = 0;
binWidth = 1;
thisAngleBin = mean(mean(clustAngles)); % thisAngleBin = 90;
binHere = thisAngleBin+(binWidth/2)*[-1 1];
for blockA = 1:nBlocks
    % Prep block A
    useCentersA = allCentersA(cellAssignA{blockA},:);
    numUseCellsA = size(useCentersA,1);
    [allAnglesA,allDistancesA,vorTwoLogicalA,neuronTrackerA] = setupForAligns(useCentersA,vorAdjacencyMax);
    [anglesTwoA,distTwoA,cellRowA] = gatherTwoAligns(allAnglesA,allDistancesA,vorTwoLogicalA,neuronTrackerA);
    numVorTwoPartnersA = sum(vorTwoLogicalA,2);
    
    for blockB = 1:nBlocks
        %waitX = blockB + nBlocks*(blockA-1);
        %waitbar(waitX/(nBlocks^2),['Working on ' num2str(waitX) '/' num2str(nBocks^2) '...'])
        
        % Prep block B
        useCentersB = allCentersB(cellAssignB{blockB},:);
        numUseCellsB = size(useCentersB,1);
        [allAnglesB,allDistancesB,vorTwoLogicalB,neuronTrackerB] = setupForAligns(useCentersB,vorAdjacencyMax);
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