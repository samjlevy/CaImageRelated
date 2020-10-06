function [outputs] = voronoiRegNotes2_8fun(imPathA,imPathB,distanceThreshold,vorTierCheck,nBlocksX,nBlocksY,pctDownsample)
% Building things out to function to start testing alignments of image
% parts, jittering base image cell centers by a small random amount
% Could also try manipulating the angle or distance offsets to see the
% effects, though not sure what to predict there
% Still no plains for A==B,B==C,A~=C misalignments
outputs = [];
disp('Loading Neuron ROI Images')
if ischar(imPathA)
load(imPathA, 'NeuronImage');
NeuronImageA = NeuronImage;
elseif iscell(imPathB)
    NeuronImageA = imPathA;
    clear imPathA
end
if ischar(imPathB)
load(imPathB, 'NeuronImage');
NeuronImageB = NeuronImage;
elseif iscell(imPathB)
    NeuronImageB = imPathB;
    clear imPathB
end
NeuronImageBorig = NeuronImageB;
clear NeuronImage
disp('Done Loading Neuron ROI Images')

numCellsA = length(NeuronImageA);
numCellsB = length(NeuronImageB);
allCentersA = getAllCellCenters(NeuronImageA,true);
allCentersB = getAllCellCenters(NeuronImageB,true);

% Get distribution of major axis length
axisLengthsA = getAllCellMajorAxis(NeuronImageA,true);
axisLengthsB = getAllCellMajorAxis(NeuronImageB,true);

% Basic starting parameters
nPeaksCheck = 1;
vorAdjacencyMax = vorTierCheck;
triesPerDS = 5;
triesPerJitter = 5;
angleBinWidth = 1;
distBinWidth = 1;

% Break each image into chunks how many depends on how many cells, maybe how much memory?
cellsPerBlock = 400;
xPctOverlap = 0.5; % nBlocksX = 3; 
yPctOverlap = 0.5; % nBlocksY = 3;
nBlocks = nBlocksX*nBlocksY;

nBlocksA = nBlocks;
nBlocksB = nBlocks;

disp('Parameter Setting:')
disp(['vorTier using: ' num2str(vorAdjacencyMax)])
disp(['num blocks x,y: ' num2str(nBlocksX) ', ' num2str(nBlocksY)])
disp(['pct cells removed by downsampling: ' num2str(pctDownsample)])

midXa = mean(allCentersA(:,1)); aLimsX = [min(allCentersA(:,1))-0.5 max(allCentersA(:,1))+0.5];
midYa = mean(allCentersA(:,2)); aLimsY = [min(allCentersA(:,2))-0.5 max(allCentersA(:,2))+0.5];
midXb = mean(allCentersB(:,1)); bLimsX = [min(allCentersB(:,1))-0.5 max(allCentersB(:,1))+0.5];
midYb = mean(allCentersB(:,2)); bLimsY = [min(allCentersB(:,2))-0.5 max(allCentersB(:,2))+0.5];

[aBlocksX(1,:),aBlocksX(2,:)] = slidingWindowBoundaries(aLimsX,nBlocksX,[],xPctOverlap,'pct'); aBlocksX = aBlocksX';
[aBlocksY(1,:),aBlocksY(2,:)] = slidingWindowBoundaries(aLimsY,nBlocksY,[],yPctOverlap,'pct'); aBlocksY = aBlocksY';
[bBlocksX(1,:),bBlocksX(2,:)] = slidingWindowBoundaries(bLimsX,nBlocksX,[],xPctOverlap,'pct'); bBlocksX = bBlocksX';
[bBlocksY(1,:),bBlocksY(2,:)] = slidingWindowBoundaries(bLimsY,nBlocksY,[],yPctOverlap,'pct'); bBlocksY = bBlocksY';

for ccX = 1:nBlocksX
    for ccY = 1:nBlocksY
        cellAssignA{ccX,ccY} = (allCentersA(:,1) >= aBlocksX(ccX,1) & allCentersA(:,1) <= aBlocksX(ccX,2)) & ...
                               (allCentersA(:,2) >= aBlocksY(ccY,1) & allCentersA(:,2) <= aBlocksY(ccY,2));
        cellAssignB{ccX,ccY} = (allCentersB(:,1) >= bBlocksX(ccX,1) & allCentersB(:,1) <= bBlocksX(ccX,2)) & ...
                               (allCentersB(:,2) >= bBlocksY(ccY,1) & allCentersB(:,2) <= bBlocksY(ccY,2));
                           
        % Grid midpoints for reference
        aGridsX(ccX,ccY) = mean([bBlocksX(ccX,1) bBlocksX(ccX,2)]);
        aGridsY(ccX,ccY) = mean([bBlocksY(ccY,1) bBlocksY(ccY,2)]);
        bGridsX(ccX,ccY) = mean([bBlocksX(ccX,1) bBlocksX(ccX,2)]);
        bGridsY(ccX,ccY) = mean([bBlocksY(ccY,1) bBlocksY(ccY,2)]);
    end
end
cellAssignAbig = cell2mat([cellAssignA(:)']); % big logical matrix of these assignments
cellAssignBbig = cell2mat([cellAssignB(:)']);

%{
figure; imagesc(create_AllICmask(NeuronImageA))
hold on
plot(allCentersA(:,1),allCentersA(:,2),'.g')
%plot(min(aLimsX)*[1 1],aLimsY,'g'); plot(max(aLimsX)*[1 1],aLimsY,'g'); plot(aLimsX,min(aLimsY)*[1 1],'g'); plot(aLimsX,max(aLimsY)*[1 1],'g')
blocksPlot = [1 1; 2 2; 3 3];
for ccX = 1:size(blocksPlot,1)
rectangle('Position',[aBlocksX(blocksPlot(ccX,1),1) aBlocksY(blocksPlot(ccX,2),1) diff(aBlocksX(blocksPlot(ccX,1),:)) diff(aBlocksY(blocksPlot(ccX,2),:))],...
    'EdgeColor','r','LineStyle','--','LineWidth',1.5)
end
title('Base Cells'); axis xy; axis off


figure; imagesc(create_AllICmask(NeuronImageBorig))
hold on
plot(allCentersB(:,1),allCentersB(:,2),'.g')
%plot(min(bLimsX)*[1 1],bLimsY,'g'); plot(max(bLimsX)*[1 1],bLimsY,'g'); plot(bLimsX,min(bLimsY)*[1 1],'g'); plot(bLimsX,max(bLimsY)*[1 1],'g')
blocksPlot = [1 1; 2 2; 3 3];
for ccX = 1:size(blocksPlot,1)
rectangle('Position',[bBlocksX(blocksPlot(ccX,1),1) bBlocksY(blocksPlot(ccX,2),1) diff(bBlocksX(blocksPlot(ccX,1),:)) diff(bBlocksY(blocksPlot(ccX,2),:))],...
    'EdgeColor','r','LineStyle','--','LineWidth',1.5)
end
title('Cells-to-be-Registered'); axis xy; axis off
%}

%{
figure; voronoi(allCentersA(:,1),allCentersA(:,2)); set(gca,'XTick',[]); set(gca,'YTick',[]); title('Base Cells Voronoi Diagram'); axis equal
figure; voronoi(allCentersB(:,1),allCentersB(:,2)); set(gca,'XTick',[]); set(gca,'YTick',[]); title('Reg. Cells Voronoi Diagram'); axis equal
%}

% Rotate and re-find centers
rotateDeg = 90;
NeuronImageB = cellfun(@(x) imrotate(x,rotateDeg),NeuronImageB,'UniformOutput',false);
allCentersB = getAllCellCenters(NeuronImageB,true);

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
    useCentersA = allCentersA(cellAssignA{blockA},:); % 0.006752 seconds
    numUseCellsA = size(useCentersA,1);
    [allAnglesA,allDistancesA,vorTwoLogicalA,neuronTrackerA] = setupForAligns(useCentersA,vorAdjacencyMax,true); % 0.152467 seconds
    [anglesTwoA,distTwoA,cellRowA] = gatherTwoAligns(allAnglesA,allDistancesA,vorTwoLogicalA,neuronTrackerA); % 0.007361 seconds
    numVorTwoPartnersA = sum(vorTwoLogicalA,2);
    
    %{
    [vorAdjTiers,edgePolys] = GetAllVorAdjacency(useCentersA);
    figure; voronoi(useCentersA(:,1),useCentersA(:,2))
    hold on
    demoCell = 2;
    plot(useCentersA(demoCell,1),useCentersA(demoCell,2),'dr','MarkerSize',20)
    dcOne = vorAdjTiers(demoCell,:)==1;
    dcTwo = vorAdjTiers(demoCell,:)==2;
    plot(useCentersA(dcOne,1),useCentersA(dcOne,2),'.b','MarkerSize',20)
    plot(useCentersA(dcTwo,1),useCentersA(dcTwo,2),'.','Color',[0.2   0.8    0.2],'MarkerSize',20)
    
    %}
    
    for blockB = 1:nBlocks
        try
        waitX = blockB + nBlocks*(blockA-1);
        waitbar(waitX/(nBlocks^2+1),hh,['Working on ' num2str(waitX) '/' num2str(nBlocks^2) '...'])
        end
        % Prep block B
        useCentersB = allCentersB(cellAssignB{blockB},:);
        numUseCellsB = size(useCentersB,1);
        [allAnglesB,allDistancesB,vorTwoLogicalB,neuronTrackerB] = setupForAligns(useCentersB,vorAdjacencyMax,true);
        [anglesTwoB,distTwoB,cellRowB] = gatherTwoAligns(allAnglesB,allDistancesB,vorTwoLogicalB,neuronTrackerB);
        numVorTwoPartnersB = sum(vorTwoLogicalB,2);
        
        % Creates a unique integer identifier for each A-B voronoi-tier 2 cell pair parent
        intCellIDs = generateUniqueIntIDs(cellRowA,cellRowB); % 0.269518 seconds
      
        % Start finding the alignment cluster
        [angleDiffsAbs,distanceDiffs] = getAngleDistDiffs(anglesTwoA,distTwoA,anglesTwoB,distTwoB); % 0.461880 seconds
        [~,C{blockA,blockB}] = kmeans([angleDiffsAbs(distanceDiffs<dThreshUse) distanceDiffs(distanceDiffs<dThreshUse)],1); % 0.991896 seconds
        
        %{
        tic
        [angleRadDiffDistribution,yEdges,angleBinAssigned] =...
            histcounts(angleDiffsAbs(distanceDiffs<dThreshUse),[0:1:180]); % 0.183596 seconds
        toc
        %}
        
        %{
        abinn = [0.5:1:179.5]; dbinn = [0:0.25:20];
        [angleRadDiffDistribution,yEdges,xEdges,angleBinAssigned,distBinAssigned] = histcounts2(angleDiffsAbs(distanceDiffs<20),distanceDiffs(distanceDiffs<20),abinn,dbinn); %%% slow
        aa=figure('Position',[420 181 793 444]); imagesc(angleRadDiffDistribution)
        set(gca,'XTickLabel',dbinn(aa.Children.XTick))
        colormap jet
        xlabel('Difference of Distances')
        ylabel('Difference of Angles')
        title('Count of tier-2 voronoi pairs')
        
        figure; histogram(angleDiffsAbs(distanceDiffs<1),abinn)
        xlabel('Difference of Angles')
        ylabel('Number tier-2 voronoi pairs')
        
        ylim([8000 10000])
        xlim([0 180])
        %}
        
        binWidth = 1;
        anglePeak(blockA,blockB) = C{blockA,blockB}(1);
        thisAngleBin = C{blockA,blockB}(1)+((binWidth/2)*[-1 1]);
        thisDistBin = 0;
        angleDiffsHere = (angleDiffsAbs <= max(thisAngleBin)) & (angleDiffsAbs >= min(thisAngleBin));
        distDiffsHere = distanceDiffs < dThreshUse;
        angleDistHere = angleDiffsHere & distDiffsHere; % Logical identifier for angle and dist differences in current histogram bin
        %{
        figure; imagesc(angleDistHere)
        draw a box around zoom region
        set lims for that zoom region, axis equal
        title('Tier-2 voronoi pairs that fit this bin')
        %}
        
        %imagCellIdsHere = imagCellIDs(angleDistHere); % All the unique cell pair identifiers for vorTwoPairs with angle/dist in this bin
        intCellIdsHere = intCellIDs(angleDistHere);
        
        [uniqueCellPairsInts,~,ic] = unique(intCellIdsHere);
        uniqueCellPairs = intsToCells(uniqueCellPairsInts,numUseCellsA,numUseCellsB);
        
        %disp('Peak quality checking')
        [uniqueCellsUsePairs,uniqueCellsUseMax,totalAligns,meanAligns] =...
            initClusterStats(uniqueCellPairs,ic,numUseCellsA,numUseCellsB);
        % This step ranks the possible cell pairs by the number of
        % tier 2 angle/distance difference pairs that were in our peak bin,
        % allowing each cell from each image to only be used once
        
        
        alignCells{blockA,blockB} = uniqueCellsUsePairs;
        
        %{
        B = uint8(intCellIDs);
        D = uint8(unique(intCellIdsHere));
        % disp verify this is really working...
        [uniqueInAllInts] = ismembc(B,D); % 0.599302 seconds
            % logical of all vor two pairs for any belonging to the cell pair that had at least 1 used this bins        
        
        %disp('Peak quality evaluation')
        % Explained angle/distance variance by this bin
        % unexplainedAngles = abs(angleDiffsAbs-thisAngleBin);
        % unexplainedDist = abs(distanceDiffs-thisDistBin);
        % %{
        
        
        evalStats{blockA,blockB} = EvaluatePeakQuality(abs(angleDiffsAbs-anglePeak(blockA,blockB)),abs(distanceDiffs-thisDistBin),angleDistHere,uniqueInAllInts);
            % 0.889029 seconds
            % This should be refined to the unique cells used here?
        evalStats{blockA,blockB}.numPairedCells = length(uniqueCellsUsePairs);
        evalStats{blockA,blockB}.numVorApartners = numVorTwoPartnersA(uniqueCellsUsePairs(:,1));
        evalStats{blockA,blockB}.numVorBpartners = numVorTwoPartnersB(uniqueCellsUsePairs(:,2));         
       %}
        
        % Refine anchor cells to those with good voronoi alignment across image blocks
        basePairCenters = useCentersA(alignCells{blockA,blockB}(:,1),:);
        regPairCenters = useCentersB(alignCells{blockA,blockB}(:,2),:);
        
        % Refine anchor cells to those with good voronoi alignment across image blocks
        [wellAligned{blockA,blockB},goodMatches{blockA,blockB},diffLogs{blockA,blockB},cellTripLog{blockA,blockB}] =...
            targetedAlignmentSame(basePairCenters,regPairCenters); % 0.02s
        %{
        figure; imagesc(create_AllICmask(NeuronImageA(cellAssignA{blockA}))); axis xy; hold on
        plot(basePairCenters(:,1),basePairCenters(:,2),'.r','MarkerSize',10)
        xlim([0 325]); ylim([0 275])
        title('Candidate Anchors A')
            
        aCellsHereT = find(cellAssignA{blockA});
        aCellsHere = aCellsHereT(alignCells{blockA,blockB}(:,1));
        outlinesA = cellfun(@bwboundaries,NeuronImageA(aCellsHere),'UniformOutput',false);
        for oaI = 1:length(outlinesA)
            plot(outlinesA{oaI}{1}(:,2),outlinesA{oaI}{1}(:,1),'r','LineWidth',1)
        end
        
        figure; imagesc(create_AllICmask(NeuronImageB(cellAssignB{blockB}))); axis xy; hold on
        plot(regPairCenters(:,1),regPairCenters(:,2),'.r','MarkerSize',10)
        camroll(90)
        title('Candidate Anchors B')
        ylim([300 625]); xlim([0 275])
            
        bCellsHereT = find(cellAssignB{blockB});
        bCellsHere = bCellsHereT(alignCells{blockA,blockB}(:,2));
        outlinesB = cellfun(@bwboundaries,NeuronImageB(bCellsHere),'UniformOutput',false);
        for obI = 1:length(outlinesB)
            plot(outlinesB{obI}{1}(:,2),outlinesB{obI}{1}(:,1),'r','LineWidth',1)
        end

        figure; imagesc(create_AllICmask(NeuronImageA(cellAssignA{blockA}))); axis xy; hold on
        plot(basePairCenters(:,1),basePairCenters(:,2),'.r','MarkerSize',10)
        xlim([0 325]); ylim([0 275])
        title('Refined Anchors A')
        outlinesAref = outlinesA(wellAligned{blockA,blockB});
        for oaI = 1:length(outlinesAref)
            plot(outlinesAref{oaI}{1}(:,2),outlinesAref{oaI}{1}(:,1),'g','LineWidth',1)
        end
        
        figure; imagesc(create_AllICmask(NeuronImageB(cellAssignB{blockB}))); axis xy; hold on
        plot(regPairCenters(:,1),regPairCenters(:,2),'.r','MarkerSize',10)
        camroll(90)
        title('Refined Anchors B')
        ylim([300 625]); xlim([0 275])
        outlinesBref = outlinesB(wellAligned{blockA,blockB});
        for obI = 1:length(outlinesBref)
            plot(outlinesBref{obI}{1}(:,2),outlinesBref{obI}{1}(:,1),'g','LineWidth',1)
        end
        %}
            
        % Test it, see how well the registration went% Evaluate that transformation: 
        anchorCellsA{blockA,blockB} = alignCells{blockA,blockB}(wellAligned{blockA,blockB},1); % Refined
        anchorCellsB{blockA,blockB} = alignCells{blockA,blockB}(wellAligned{blockA,blockB},2);
        
        % Translate anchorCells back to original cell indices
        cellIndsA = find(cellAssignA{blockA});
        alignIndsA = alignCells{blockA,blockB}(:,1);
        anchorIndsA = find(wellAligned{blockA,blockB});
        allAnchorCellsA{blockA,blockB} = cellIndsA(alignIndsA(anchorIndsA));
        
        cellIndsB = find(cellAssignB{blockB});
        alignIndsB = alignCells{blockA,blockB}(:,2);
        anchorIndsB = find(wellAligned{blockA,blockB});
        allAnchorCellsB{blockA,blockB} = cellIndsB(alignIndsB(anchorIndsB));
        
        allAnchorCellsPairs{blockA,blockB} = [allAnchorCellsA{blockA,blockB}, allAnchorCellsB{blockA,blockB}];
        
        if length(anchorCellsB{blockA,blockB}) > 2 % Minimum required for affine transformation
            [tform{blockA,blockB}, reg_shift_centers{blockA,blockB}, closestPairs{blockA,blockB}, ~, ~] =...
                testRegistration(anchorCellsA{blockA,blockB},useCentersA,anchorCellsB{blockA,blockB},useCentersB,distanceThreshold); % 0.045812 seconds
            
            % Translated back to original indices
            closestCellsAll{blockA,blockB}(:,1) = cellIndsA(closestPairs{blockA,blockB}(:,1));
            closestCellsAll{blockA,blockB}(:,2) = cellIndsB(closestPairs{blockA,blockB}(:,2));
            
            reg_shift_centers_all{blockA,blockB} = nan(numCellsB,2);
            reg_shift_centers_all{blockA,blockB}(cellIndsB,:) = reg_shift_centers{blockA,blockB};
        end
        
        %{
            figure; imagesc(create_AllICmask(NeuronImageA)); axis xy; title('A')
            hold on
            plot(useCentersA(anchorCellsA,1),useCentersA(anchorCellsA,2),'*r')
            
            figure; imagesc(create_AllICmask(NeuronImageB)); axis xy; title('B')
            hold on
            plot(useCentersB(anchorCellsB,1),useCentersB(anchorCellsB,2),'*r')
        %}
        %{
            figure; imagesc(create_AllICmask(NeuronImageA)); axis xy; title('A')
            hold on
            plot(allCentersA(cellIndsA,1),allCentersA(cellIndsA,2),'m*')
            plot(allCentersA(cellIndsA(alignIndsA),1),allCentersA(cellIndsA(alignIndsA),2),'c*')
            plot(allCentersA(cellIndsA(alignIndsA(anchorIndsA)),1),allCentersA(cellIndsA(alignIndsA(anchorIndsA)),2),'k*')
        %}
        % %cells registered from a, %registered from b
        
        %{
        figure; imagesc(create_AllICmask(NeuronImageA(cellAssignA{blockA}))); axis xy; hold on
        plot(useCentersA(:,1),useCentersA(:,2),'.k','MarkerSize',10)
        xlim([0 325]); ylim([0 275])
        title(['Initial Registration for A block' num2str(blockA) ', B block ' num2str(blockB) ', distanceThreshold ' num2str(distanceThreshold)])
        plot(reg_shift_centers{blockA,blockB}(:,1),reg_shift_centers{blockA,blockB}(:,2),'*r','MarkerSize',8)
        plot(reg_shift_centers{blockA,blockB}(closestPairs{blockA,blockB}(:,2),1),reg_shift_centers{blockA,blockB}(closestPairs{blockA,blockB}(:,2),2),'*g','MarkerSize',8)
        plot(useCentersA(closestPairs{blockA,blockB}(:,1),1),useCentersA(closestPairs{blockA,blockB}(:,1),2),'.g','MarkerSize',10)
        %}
    end
end
try; close(hh); end
toc

%{
figure; plot(allCentersA(:,1),allCentersA(:,2),'*g')
hold on
plot(allCentersA(closestCellsAll{1,2}(:,1),1),allCentersA(closestCellsAll{1,2}(:,1),2),'*r')
plot(allCentersA(closestCellsAll{2,2}(:,1),1),allCentersA(closestCellsAll{2,2}(:,1),2),'*b')
title('A')

figure; plot(allCentersB(:,1),allCentersB(:,2),'*g')
hold on
plot(allCentersB(closestCellsAll{1,2}(:,2),1),allCentersB(closestCellsAll{1,2}(:,2),2),'*r')
plot(allCentersB(closestCellsAll{2,2}(:,2),1),allCentersB(closestCellsAll{2,2}(:,2),2),'*b')
title('B')
%}

% Get the inds of cells in B registered to A
logAblank = zeros(numCellsA,1);
for blockA = 1:nBlocks
    for blockB = 1:nBlocks
        %{
        hereCellsA = find(cellAssignA{blockA});
        hereCellsB = find(cellAssignB{blockB});
        
        pairsHere = closestPairs{blockA,blockB};
        
        nClaimedMatches(blockA,blockB) = size(closestPairs{blockA,blockB},1);
        
        regToA = logAblank;
        if any(pairsHere)
            regHereA = hereCellsA(pairsHere(:,1)); % indices in all cells a
            regHereB = hereCellsB(pairsHere(:,2)); % indices in all cells b

            regToA(regHereA) = regHereB; % Which b cell, original inds, this b cell got matched to 
        end
        allIndsReg{blockA,blockB} = regToA;
        %}
        
        regToA = logAblank;
        if any(closestPairs{blockA,blockB})
            regToA(closestCellsAll{blockA,blockB}(:,1)) = closestCellsAll{blockA,blockB}(:,2);
        end
        allIndsReg{blockA,blockB} = regToA;
        
        %useCentersA = allCentersA(cellAssignA{blockA},:);
        %useCentersB = allCentersB(cellAssignB{blockB},:);
        %{
        figure; 
        subplot(1,2,1)
        %plot(allCentersA(hereCellsA,1),allCentersA(hereCellsA,2),'*g')
        plot(allCentersA(:,1),allCentersA(:,2),'*g')
        hold on
        plot(allCentersA(hereCellsA(pairsHere(:,1)),1),allCentersA(hereCellsA(pairsHere(:,1)),2),'*b')
        % plot(allCentersA(regHereA,1),allCentersA(regHereA,2),'*r') % same thing
        subplot(1,2,2)
        plot(allCentersB(hereCellsB,1),allCentersB(hereCellsB,2),'*g')
        
        %}
    end
end
% allIndsReg is for this cell a, index of cell B that fits for this transform pair

% Slow version:
bl = NaN;
agreeCellsPos = bl*ones(nBlocks^2);
disagreeCellsPos = bl*ones(nBlocks^2);
numPossible = bl*ones(nBlocks^2);
for blockAj = 1:nBlocks
    for blockBj = 1:nBlocks
        %rowInd = nBlocks*(blockAj-1) + blockBj;
        colInd = nBlocks*(blockAj-1) + blockBj;
         %{
            figure; 
                    useCentersA = allCentersA(cellAssignA{blockAj},:);
                    useCentersB = allCentersB(cellAssignB{blockBj},:);
                    rCentersB = reg_shift_centers{blockAj,blockBj};
                    plot(useCentersA(:,1),useCentersA(:,2),'*g')
                    hold on
                    plot(rCentersB(:,1),rCentersB(:,2),'*r')
                    %plot(rCentersB(closestPairs{blockAj,blockBj}(:,2),1),rCentersB(closestPairs{blockAj,blockBj}(:,2),2),'*m')
                    plot(allCentersA(find(cellsRegJ),1),allCentersA(find(cellsRegJ),2),'*b')
                    title(['blockA ' num2str(blockAj) ', blockB ' num2str(blockBj) ', rowInd ' num2str(rowInd)])
            %}
        
        % Transform J at (blockAj, blockBj):
        cellsRegJ = allIndsReg{blockAj,blockBj};
        
        for blockAk = 1:nBlocks
            for blockBk = 1:nBlocks
                %colInd = nBlocks*(blockAk-1) + blockBk;
                rowInd = nBlocks*(blockAk-1) + blockBk;
                %{
                    figure;
                    useCentersA = allCentersA(cellAssignA{blockAk},:);
                    useCentersB = allCentersB(cellAssignB{blockBk},:);
                    rCentersB = reg_shift_centers{blockAk,blockBk};
                    plot(useCentersA(:,1),useCentersA(:,2),'*g')
                    hold on
                    plot(rCentersB(:,1),rCentersB(:,2),'*r')
                    %plot(rCentersB(closestPairs{blockAk,blockBk}(:,2),1),rCentersB(closestPairs{blockAk,blockBk}(:,2),2),'*m')
                    plot(allCentersA(find(cellsRegK),1),allCentersA(find(cellsRegK),2),'*b')
                    title(['blockA ' num2str(blockAk) ', blockB ' num2str(blockBk) ', colInd ' num2str(colInd)])
                %}
                
                % Transform K:
                cellsRegK = allIndsReg{blockAk,blockBk};
                
                % Where can these transforms agree on registered cells:
                allMaybeAgree = cellsRegJ | cellsRegK;
                possibleToAgree = cellsRegJ>0 & cellsRegK>0; % Claimed registration for both transforms
                numPossible(rowInd,colInd) = sum(possibleToAgree);
                
                % Which ones do they agree
                regDoesAgree = (cellsRegJ == cellsRegK) & possibleToAgree;
                regDisagree = (cellsRegJ ~= cellsRegK) & possibleToAgree;
                
                agreeCellsPos(rowInd,colInd) = sum(regDoesAgree)/sum(possibleToAgree);
                disagreeCellsPos(rowInd,colInd) = sum(regDisagree)/sum(possibleToAgree);
                
                if rowInd == colInd
                    agreeCellsPos(rowInd,colInd) = bl;
                    disagreeCellsPos(rowInd,colInd) = bl;
                    numPossible(rowInd,colInd) = bl;
                end
                if sum(cellsRegJ)==0 || sum(cellsRegK)==0
                    agreeCellsPos(rowInd,colInd) = bl;
                    disagreeCellsPos(rowInd,colInd) = bl;
                    numPossible(rowInd,colInd) = bl;
                end
                
                theseTransformSubscripts{1}{rowInd,colInd} = [blockAj blockBj];
                theseTransformSubscripts{2}{rowInd,colInd} = [blockAk blockBk];
                
                %if blockAj == 5 && blockBj == 5 && blockAk == 5 blockBk == 8
                %    keyboard
                %end
                %{
                figure; 
                plot(allCentersA(allMaybeAgree,1),allCentersA(allMaybeAgree,2),'*c')
                hold on
                plot(allCentersA(possibleToAgree,1),allCentersA(possibleToAgree,2),'*b')
                plot(allCentersA(regDoesAgree,1),allCentersA(regDoesAgree,2),'*g')
                plot(allCentersA(regDisagree,1),allCentersA(regDisagree,2),'*r')
                %}
                %{
                figure;
                plot(allCentersA(possibleToAgree,1),allCentersA(possibleToAgree,2),'*m')
                %plot(reg_shift_centers{blockAj,blockBj}(:,1),reg_shift_centers{blockAj,blockBj}(:,2),'*b')
                plot(reg_shift_centers{blockAj,blockBj}(closestPairs{blockAj,blockBj}(:,2),1),reg_shift_centers{blockAj,blockBj}(closestPairs{blockAj,blockBj}(:,2),2),'*b')
                hold on
                %plot(reg_shift_centers{blockAk,blockBk}(:,1),reg_shift_centers{blockAk,blockBk}(:,2),'*r')
                plot(reg_shift_centers{blockAk,blockBk}(closestPairs{blockAk,blockBk}(:,2),1),reg_shift_centers{blockAk,blockBk}(closestPairs{blockAk,blockBk}(:,2),2),'*r')
                %}
            end
        end
        
    end
end
theseTransformIndices{1} = cellfun(@(x) sub2ind([nBlocksA,nBlocksB],x(1),x(2)),theseTransformSubscripts{1});
theseTransformIndices{2} = cellfun(@(x) sub2ind([nBlocksA,nBlocksB],x(1),x(2)),theseTransformSubscripts{2});

%{
figure; imagesc(agreeCellsPos)
colorbar
figure; imagesc(disagreeCellsPos)
colorbar
%}

agreeDisagreeDiff = (agreeCellsPos - disagreeCellsPos);
% For the transformation in row i, what is the agreement with transformations from column j

%figure; imagesc_nan(agreeDisagreeDiff)

% Start agregating agreeable transformations
adDiff = agreeDisagreeDiff;
adDiff(isnan(adDiff)) = 0;

agreementThresh = 0.5; % proportion of agreed cell aligns to disagree is > 50%

%{
figure; 
imagesc(create_AllICmask(NeuronImageA(cellAssignA{1})))
axis xy; hold on
plot(allCentersA(cellAssignA{1},1),allCentersA(cellAssignA{1},2),'.g')
xlim([0 325]); ylim([0 275])
plot(reg_shift_centers{1,1}(:,1),reg_shift_centers{1,1}(:,2),'.b')
plot(reg_shift_centers{1,2}(:,1),reg_shift_centers{1,2}(:,2),'.r')

aBlock = 1;
bBlok = 1;
baseImage = create_AllICmask(NeuronImageA(cellAssignA{aBlock}));
RA = imref2d(size(baseImage));
[regImage_shifted,~] = ...
    cellfun(@(x) imwarp(x,tform{aBlock,bBlock},'OutputView',RA,'InterpolationMethod','nearest'),NeuronImageB,'UniformOutput',false);
reg_mask_shifted = create_AllICmask(regImage_shifted(cellAssignB{bBlock}));
[zoomOverlay,zoomOverlayRef] = imfuse(baseImage,reg_mask_shifted,'ColorChannels',[1 2 0]);
figure; imshow(zoomOverlay,zoomOverlayRef);
axis xy;
title(['Transformation with Block A ' num2str(aBlock) ' and Block B ' num2str(bBlock)])
xlim([0 325]); ylim([0 275])

bBlock = 2;
[regImage_shifted,~] = ...
    cellfun(@(x) imwarp(x,tform{aBlock,bBlock},'OutputView',RA,'InterpolationMethod','nearest'),NeuronImageB,'UniformOutput',false);
reg_mask_shifted = create_AllICmask(regImage_shifted(cellAssignB{bBlock}));
[zoomOverlay,zoomOverlayRef] = imfuse(baseImage,reg_mask_shifted,'ColorChannels',[1 2 0]);
figure; imshow(zoomOverlay,zoomOverlayRef);
axis xy;
title(['Transformation with Block A ' num2str(aBlock) ' and Block B ' num2str(bBlock)])
xlim([0 450]); ylim([0 350])

%badTFrow = 5; badTFcol = 12;
badTFrow = 41; badTFcol = 44;
tformOne = theseTransformIndices{1}{badTFrow,badTFcol};
tformTwo = theseTransformIndices{2}{badTFrow,badTFcol};

aBlock = tformOne(1);
bBlock = tformOne(2);
baseImage = create_AllICmask(NeuronImageA(cellAssignA{aBlock}));
RA = imref2d(size(baseImage));
[regImage_shifted,~] = ...
    cellfun(@(x) imwarp(x,tform{aBlock,bBlock},'OutputView',RA,'InterpolationMethod','nearest'),NeuronImageB,'UniformOutput',false);
reg_mask_shifted = create_AllICmask(regImage_shifted(cellAssignB{bBlock}));
[zoomOverlay,zoomOverlayRef] = imfuse(baseImage,reg_mask_shifted,'ColorChannels',[1 2 0]);
figure; imshow(zoomOverlay,zoomOverlayRef);
axis xy;
title(['Transformation with Block A ' num2str(aBlock) ' and Block B ' num2str(bBlock)])
xlim([0 600]); ylim([0 500])

aBlock = tformTwo(1);
bBlock = tformTwo(2);
baseImage = create_AllICmask(NeuronImageA(cellAssignA{aBlock}));
RA = imref2d(size(baseImage));
[regImage_shifted,~] = ...
    cellfun(@(x) imwarp(x,tform{aBlock,bBlock},'OutputView',RA,'InterpolationMethod','nearest'),NeuronImageB,'UniformOutput',false);
reg_mask_shifted = create_AllICmask(regImage_shifted(cellAssignB{bBlock}));
[zoomOverlay,zoomOverlayRef] = imfuse(baseImage,reg_mask_shifted,'ColorChannels',[1 2 0]);
figure; imshow(zoomOverlay,zoomOverlayRef);
axis xy;
title(['Transformation with Block A ' num2str(aBlock) ' and Block B ' num2str(bBlock)])
xlim([0 600]); ylim([0 500])

figure;
plot(reg_shift_centers{tformOne(1),tformOne(2)}(closestPairs{tformOne(1),tformOne(2)}(:,2),1),...
     reg_shift_centers{tformOne(1),tformOne(2)}(closestPairs{tformOne(1),tformOne(2)}(:,2),2),'.r')   
hold on
plot(reg_shift_centers{tformTwo(1),tformTwo(2)}(closestPairs{tformTwo(1),tformTwo(2)}(:,2),1),...
     reg_shift_centers{tformTwo(1),tformTwo(2)}(closestPairs{tformTwo(1),tformTwo(2)}(:,2),2),'.b')   

RA = imref2d(size(baseImage));
[regImage_shiftedOne,~] = ...
    cellfun(@(x) imwarp(x,tform{tformOne(1),tformOne(2)},'OutputView',RA,'InterpolationMethod','nearest'),NeuronImageB,'UniformOutput',false);
[regImage_shiftedTwo,~] = ...
    cellfun(@(x) imwarp(x,tform{tformTwo(1),tformTwo(2)},'OutputView',RA,'InterpolationMethod','nearest'),NeuronImageB,'UniformOutput',false);
%reg_mask_shiftedOne = create_AllICmask(regImage_shiftedOne(closestCellsAll{tformOne(1),tformOne(2)}(:,2)));
%reg_mask_shiftedTwo = create_AllICmask(regImage_shiftedTwo(closestCellsAll{tformTwo(1),tformTwo(2)}(:,2)));
reg_mask_shiftedOne = create_AllICmask(regImage_shiftedOne(cellAssignB{tformOne(2)}));
reg_mask_shiftedTwo = create_AllICmask(regImage_shiftedTwo(cellAssignB{tformTwo(2)}));
[zoomOverlay,zoomOverlayRef] = imfuse(reg_mask_shiftedOne,reg_mask_shiftedTwo,'ColorChannels',[1 2 0]);
figure; imshow(zoomOverlay,zoomOverlayRef);
axis xy


outlinesOne = cellfun(@bwboundaries,regImage_shiftedOne(cellAssignB{tformOne(2)}),'UniformOutput',false);
outlinesTwo = cellfun(@bwboundaries,regImage_shiftedTwo(cellAssignB{tformTwo(2)}),'UniformOutput',false);
figure; axis; hold on
for oaI = 1:length(outlinesOne)
    plot(outlinesOne{oaI}{1}(:,2),outlinesOne{oaI}{1}(:,1),'r','LineWidth',1)
end
for oaI = 1:length(outlinesTwo)
    plot(outlinesTwo{oaI}{1}(:,2),outlinesTwo{oaI}{1}(:,1),'b','LineWidth',1)
end
%}

% adDiff is the agreement between transforms at the (blockA blockB) indices
% specified by (theseTransformIndices{1} theseTransformIndices{2}) << indicies are into the full nBlocksA*nBlocksB indices)
% treat adDiff > agreementThresh as an adjacency matrix, is it to find all
% transforms that have overlaps with other transforms. 
% positiveAgreement is interpreted as the transform at (row) agrees with
% the transform at col. So positiveAgreement(2,1)==1 
positiveAgreement = adDiff > agreementThresh;
overlappedGoodTransforms = GetAllTierAdjacency(positiveAgreement,[]); 
overlappedGoodTransforms(isinf(overlappedGoodTransforms)) = 0; % These represent pairs of transforms
tformsUsePairs = find(sum(overlappedGoodTransforms,1)); % This assumes they're all connected
%tformsUsePairsAB = [theseTransformIndices{1}(tformsUsePairs(:)) theseTransformIndices{2}(tformsUsePairs(:))]
maybetfs = unique(theseTransformIndices{2}(tformsUsePairs(:)));
tformsUse = maybetfs;

%{
G = graph(overlappedGoodTransforms>0);
bins = conncomp(G); % Bins lists a component identity for each entry, so any int that's used more than once should be checked
sum(bins==1)
%}
disp('This is where unconnected clusters of alignments would be discovered')

% Gather all agreeing anchors from tforms, check for conflicts; 
aggregateAnchorPairs = nan(numCellsA,length(tformsUse));
for tfI = 1:length(tformsUse)
    aggregateAnchorPairs(allAnchorCellsPairs{tformsUse(tfI)}(:,1),tfI) = allAnchorCellsPairs{tformsUse(tfI)}(:,2);
    numAnchorPairs(tfI) = size(allAnchorCellsPairs{tformsUse(tfI)},1);
end
aapStd = nanstd(aggregateAnchorPairs,0,2); % If stdev is zero, all entries agree
aapStd(sum(isnan(aggregateAnchorPairs),2)==length(tformsUse)) = 0; % To delete rows that only had nans
conflictAnchorCells = find(aapStd~=0); 
if any(conflictAnchorCells)
    keyboard
    disp('Found conflicting anchor cells, do not yet have a solution for this')
end
% Eliminate transforms whose anchors are entirely covered by another...
nAnchorsThresh = 5;
badTforms = numAnchorPairs < nAnchorsThresh;
tformsUse(badTforms) = [];
aggregateAnchorPairs(:,badTforms) = [];

% Then once anchor conflicts are resolved...
%{
badTforms = nansum(aggregateAnchorPairs,1)==0;
aggregateAnchorPairs(:,badTforms) = [];
tformsUse(badTforms) = [];
%}
anchorPairUse = nanmean(aggregateAnchorPairs,2);
% Delete tforms missing anchor pairs
tfSrcBig = repmat(tformsUse(:)',numCellsA,1);
tfSrcBig(isnan(aggregateAnchorPairs)) = NaN; % tforms that supplied this anchor pair 
finalAnchorPairs = [[1:numCellsA]', anchorPairUse];

% Hail Mary mega transform:
haveAnchor = finalAnchorPairs(~isnan(anchorPairUse));
megaTform = fitgeotrans(allCentersB(finalAnchorPairs(haveAnchor,2),:),allCentersA(haveAnchor,:),'affine');
hmRS = affineTransform(megaTform,allCentersB);

RA = imref2d(size(NeuronImageA{1}));
regShiftedImages = cellfun(@(x) imwarp(x,megaTform,'OutputView',RA,'InterpolationMethod','nearest'),...
                    NeuronImageB,'UniformOutput',false);
baseImage = create_AllICmask(NeuronImageA);
regShiftedImage = create_AllICmask(regShiftedImages);
[zoomOverlay,zoomOverlayRef] = imfuse(baseImage,regShiftedImage,'ColorChannels',[1 2 0]);
figure; imshow(zoomOverlay,zoomOverlayRef); axis xy
title('Final image overlay')

[statsOut] = EvaluateVoronoiIntegrity(allCentersB,hmRS);
badPts = find(sum(statsOut.inPreNotPost,2)>=2); % Two connections off this pt that are missing later

% Try registering
[distances,~] = GetAllPtToPtDistances2(allCentersA(:,1),allCentersA(:,2),hmRS(:,1),hmRS(:,2),[]);
[minIndsBaseRS,baseRSdistances] = findDistanceMatches(distances,[]);

haveDistance = distances; 
haveDistance(haveDistance>distanceThreshold) = NaN;
distInds = find(haveDistance);
[cellA,cellB] = ind2sub(size(haveDistance),distInds);

[vals,indsMat,indKept] = RankedUniqueInds(haveDistance(distInds),[cellA cellB],'ascend');

goodVal = ~isnan(vals);
goodInds = indsMat(goodVal,:);

finalRegPairs = [[1:numCellsA]',nan(numCellsA,1)];
finalRegPairs(goodInds(:,1),2) = goodInds(:,2);


%for imi = 1:1452; plot([allCentersA(indsMat(imi,1),1) hmRS(indsMat(imi,2),1)],...
%                       [allCentersA(indsMat(imi,1),2) hmRS(indsMat(imi,2),2)],'m'); end
outputs.reg_shift_centers = hmRs;
outputs.tform = megaTform; 
outputs.anchors = finalAnchorPairs;
outputs.regShiftedImages = regShiftedImages;
outputs.distances = distances;
outputs.finalRegPairs = finalRegPairs;
%{
% Alternate work (tform before reg) starts here
% Get anchor COMs, distance of pts from anchorCOM, regShift of both
for blockA = 1:nBlocksA
    useCentersA = allCentersA(cellAssignA{blockA},:);
    for blockB = 1:nBlocksB
        useCentersB = allCentersB(cellAssignB{blockB},:);
        
        % Center of mass of anchor cells
        anchorCentersA = useCentersA(anchorCellsA{blockA,blockB},:);
        anchorCentersB = useCentersB(anchorCellsB{blockA,blockB},:);
        
        if any(anchorCentersB)
        anchorsCOM{blockA,blockB} = centerOfMassPts(anchorCentersB);
        AanchorsCOM{blockA,blockB} = centerOfMassPts(anchorCentersA);
        % transformed aCOM
        anchorsCOMfwd{blockA,blockB} = affineTransform(tform{blockA,blockB},anchorsCOM{blockA,blockB});
        
        % Distance image B pts from anchorCom
        cellsB_aCOM_ds{blockA,blockB} = GetPtFromPtsDist(anchorsCOM{blockA,blockB},useCentersB);
        cellsB_aCOM_dists{blockA,blockB} = nan(numCellsB,1);
        cellsB_aCOM_dists{blockA,blockB}(cellAssignB{blockB}) = cellsB_aCOM_ds{blockA,blockB};
        
        % Distance from reg_shifts to aCOM
        regShift_aCOM_dists{blockA,blockB} = GetPtFromPtsDist(anchorsCOMfwd{blockA,blockB},reg_shift_centers_all{blockA,blockB});
        end
    end
end

% Could use initial preview of regShifts to further refine transforms


% For all cells other than anchor cells, use the minimum of
% cellsB_aCOM_dists to decide with transform to use
cellsB_aCOM_dists_mat = cell2mat(cellsB_aCOM_dists(tformsUse(:)'));
[~,tfMinDist] = min(cellsB_aCOM_dists_mat,[],2);
finalRegShiftCenters = cell2mat(cellfun(@(x,y) reg_shift_centers_all{x}(y,:),mat2cell(tformsUse(tfMinDist),ones(numCellsB,1),1),...
                                                                      mat2cell([1:numCellsB]',ones(numCellsB,1),1),...
    'UniformOutput',false));

% Check voronoi integrity
[statsOut] = EvaluateVoronoiIntegrity(allCentersB,finalRegShiftCenters);

badPts = find(sum(statsOut.inPreNotPost,2)>=2); % Two connections off this pt that are missing later

%{
for this pt
    get all the triangles it's involved in, their angles
    see if substituting one of the reg shift options from the other transforms that include this pt procuces a lower angle difference off those points
%}


% Original version starts here
% Filter out conflicts; we'll fix them later
alignmentCluster = [allIndsReg{tformsUse}]; % All index B claims to match this cell A
acUse = alignmentCluster;
acUse(acUse==0) = NaN;
acStd = nanstd(acUse,0,2); % If stdev is zero, all entries agree
acStd(sum(isnan(acUse),2)==length(tformsUse)) = 0; % To delete rows that only had nans
conflictCells = find(acStd~=0);
anyAligns = nansum(acUse > 0,2); % How many transforms contributed; which ones: acUse(15,find(~isnan(acUse(15,:))))
    % Could use this to identify how often a transform creates a violation from the mean
% Resolve possible conflicts here: multiple reg cells trying to get the same base cell
acMn = nanmean(acUse,2);
%[numRegUsed] = histcounts(acMn,0.5:1:max(acMn)+0.5);
numRegUsed = numUniqueInts(acMn,1:numCellsB);
multiUsedReg = find(numRegUsed>1);
for murI = 1:length(multiUsedReg)
    thisRegC = multiUsedReg(murI);
    multiRows = find(acMn==thisRegC);
    if length(multiRows)<2
        disp('Again an indexing issue...')
        keyboard
    end
    [maxTs,maxInd] = max(anyAligns(multiRows));
    if sum(anyAligns(multiRows)==maxTs)==1
        % Delete the others
        multiRows(maxInd) = [];
        acUse(multiRows,:) = NaN;
    else
        % Delete all these entries, solve it later
        acUse(multiRows,:) = NaN;
    end
end
acMn = nanmean(acUse,2);
numRegUsed = numUniqueInts(acMn,1:numCellsB);
multiUsedReg = find(numRegUsed>1);
if any(multiUsedReg)
    disp('Problem: still have multiple assignments to same base')
    keyboard
end

bigAligns = nanmean(acUse,2);
bigAligns(conflictCells) = NaN;

% Find how far off pts are, use it to find bad tforms
meanRegPct = abs(acUse - repmat(bigAligns,1,length(tformsUse))); 
tformGroupAvg = nanmean(meanRegPct,1); 

% Reject tforms that don't contribute
acUse(conflictCells,:) = NaN;
badTforms = nansum(acUse,1)==0;
acUse(:,badTforms) = [];
tformsUse(badTforms) = [];
goodTforms = false(nBlocksA,nBlocksB);
goodTforms(tformsUse) = true;

% Gather all anchors from tforms, check for conflicts; 
%   maybe do this before reg_shift conflicts?
aggregateAnchorPairs = nan(numCellsA,length(tformsUse));
for tfI = 1:length(tformsUse)
    aggregateAnchorPairs(allAnchorCellsPairs{tformsUse(tfI)}(:,1),tfI) = allAnchorCellsPairs{tformsUse(tfI)}(:,2);
end
aapStd = nanstd(aggregateAnchorPairs,0,2); % If stdev is zero, all entries agree
aapStd(sum(isnan(aggregateAnchorPairs),2)==length(tformsUse)) = 0; % To delete rows that only had nans
conflictAnchorCells = find(aapStd~=0); 
if any(conflictAnchorCells)
    keyboard
    disp('Found conflicting anchor cells, do not yet have a solution for this')
end
% Then once anchor conflicts are resolved...
%{
badTforms = nansum(aggregateAnchorPairs,1)==0;
aggregateAnchorPairs(:,badTforms) = [];
tformsUse(badTforms) = [];
%}
anchorPairUse = nanmean(aggregateAnchorPairs,2);
% Delete tforms missing anchor pairs
tfSrcBig = repmat(tformsUse(:)',numCellsA,1);
tfSrcBig(isnan(aggregateAnchorPairs)) = NaN; % tforms that supplied this anchor pair 
finalAnchorPairs = [[1:numCellsA]', anchorPairUse];


% Get the current set of alignments: 
%where there's more than one transform that offers the right point, take the one that's closest
tformCenters = cell(1,length(tformsUse));
baseCenters = cell(1,length(tformsUse));
baseToRegshiftDists = zeros(numCellsA,length(tformsUse));
for tfI = 1:length(tformsUse)
    cellsH = find(~isnan(acUse(:,tfI)));
    % tformCenters is in cellA indices
    tformCenters{tfI} = nan(numCellsA,2); % zeros(numCellsA,2);
    tformCenters{tfI}(cellsH,:) = reg_shift_centers_all{tformsUse(tfI)}(acUse(cellsH,tfI),:); % Not sure if this indexing is right
    tformCenters{tfI} = mat2cell(tformCenters{tfI},ones(numCellsA,1),2);
    baseCenters{tfI} = mat2cell(allCentersA,ones(numCellsA,1),2);
    
    % center distances
    baseToRegshiftDists(:,tfI) = cell2mat(cellfun(@(x,y) hypot(abs(x(1) - y(1)),abs(x(2) - y(2))),baseCenters{tfI},tformCenters{tfI},'UniformOutput',false));
end
baseToRegshiftDists(isnan(acUse)) = NaN;
% Get the transformation that produced closest registered cell
[baseRSminDist,colMin] = min(baseToRegshiftDists,[],2); % Column/tform with the minimum distance to base cell
colMin(isnan(baseRSminDist)) = NaN; % Nan out entries that don't have registered cells
% This will actually find a non-contributing tform by reg shift to base distances
tformCentersReArr = [tformCenters{:}];
aAlignedFinalRegShiftCenters = nan(numCellsA,2);
indsUse = sub2ind(size(tformCentersReArr),find(~isnan(colMin)),colMin(~isnan(colMin)));
aAlignedFinalRegShiftCenters(~isnan(colMin),:) = cell2mat(tformCentersReArr(indsUse)); % Reg shift centers in image a indices
finalRegPairs(:,1) = 1:numCellsA;
finalRegPairs(:,2) = nan(numCellsA,1);
finalRegPairs(~isnan(colMin),2) = acUse(indsUse);

haveAnchorsInds = find(finalAnchorPairs(:,2)>0);
sameAnchorAndReg = finalAnchorPairs(haveAnchorsInds,2) == finalRegPairs(haveAnchorsInds,2);
if sum(sameAnchorAndReg) ~= length(sameAnchorAndReg)
    disp('Disagreement between anchor and regpairs')
    bb = haveAnchorsInds(sameAnchorAndReg==0); % Inds of cells that conflict
    for ii = 1:length(bb); isConflictCell(ii) = sum(conflictCells==bb(ii)); end % Which of these were identified as conflict cells
    [finalAnchorPairs(bb,1) finalAnchorPairs(bb,2) finalRegPairs(bb,2)]
    if sum(isnan(finalRegPairs(bb,2)))==length(bb)
        disp('Nvm, we are ok, reg shift says not in range so far')
    else
        keyboard
    end
end

% Get the transform these came from
tformSourceAinds = nan(numCellsA,1);
tformSourceAinds(~isnan(colMin)) = tformsUse(colMin(~isnan(colMin))); %colMin(~isnan(colMin)); 
tformSourceRS = nan(numCellsB,1);
haveMatch = ~isnan(finalRegPairs(:,2));
tformSourceRS(finalRegPairs(haveMatch,2)) = tformSourceAinds(haveMatch);
% sum(~isnan(tformSource))==sum(~isnan(finalRegPairs(:,2)))

finalRegShiftCenters = nan(numCellsB,2);
for cellI = 1:size(finalRegPairs,1)
    rCell = finalRegPairs(cellI,2);
    if ~isnan(finalRegPairs(cellI,2))
        finalRegShiftCenters(rCell,:) = reg_shift_centers_all{tformSourceAinds(cellI)}(rCell,:);
        verifyCenter = tformCenters{colMin(cellI)}{cellI};
        if sum(finalRegShiftCenters(rCell,:) - verifyCenter)~=0
            disp('Some reg shift center indexing went wrong')
        end
    end
end

% Figure out what's matched, what's missing
registeredBaseCells_log = ~isnan(finalRegPairs(:,2)); % logical
registeredBaseCells = find(registeredBaseCells_log);
unmatchedBaseCells_log = isnan(finalRegPairs(:,2)); % logical
unmatchedBaseCells = find(unmatchedBaseCells_log); % index

registeredRegCells = sort(finalRegPairs(:,2));
registeredRegCells(isnan(registeredRegCells)) = [];
registeredRegCells_log = false(numCellsB,1);
registeredRegCells_log(registeredRegCells) = true;
unmatchedRegCells_log = ~registeredRegCells_log;
unmatchedRegCells = find(unmatchedRegCells_log);

regCheckup = [sum(~isnan(finalRegPairs(:,2))) sum(~isnan(tformSourceRS)) sum(~isnan(tformSourceAinds)) sum(~isnan(finalRegShiftCenters(:,1)))];
if std(regCheckup~=0)
    disp('something registerd wrong so far...')
    keyboard
end

% Alternate version of above: assign reg cell by saying: among those within
% the distance threshold, take this reg_shift cell which is closest to the
% transformed center-of-mass of the anchor cells for that transformation
% Get center-of-mass of anchor cells and it's transformation
for blockA = 1:nBlocksA
    useCentersA = allCentersA(cellAssignA{blockA},:);
    for blockB = 1:nBlocksB
        useCentersB = allCentersB(cellAssignB{blockB},:);
        
        % Center of mass of anchor cells
        anchorCentersA = useCentersA(anchorCellsA{blockA,blockB},:);
        anchorCentersB = useCentersB(anchorCellsB{blockA,blockB},:);
        if any(anchorCentersB)
        anchorsCOM{blockA,blockB} = centerOfMassPts(anchorCentersB);
        AanchorsCOM{blockA,blockB} = centerOfMassPts(anchorCentersA);
        % transformed aCOM
        anchorsCOMfwd{blockA,blockB} = affineTransform(tform{blockA,blockB},anchorsCOM{blockA,blockB});
        
        % Distance from reg_shifts to aCOM
        regShift_aCOM_dists{blockA,blockB} = GetPtFromPtsDist(anchorsCOMfwd{blockA,blockB},reg_shift_centers_all{blockA,blockB});
        end
    end
end


% Assign matched cells by getting the reg_shift cell according to some distance metric:
% - closest distance to base cell
% - closest distance to shifted COM of anchor cells
pooledUnregDists_baseRS = [];
pooledUnregDists_RSanchorCOM = [];
pooledUnregInds = [];
pooledTF = [];
unbaseInds = repmat(unmatchedBaseCells(:),1,length(unmatchedRegCells));
unregInds = repmat(unmatchedRegCells(:)',length(unmatchedBaseCells),1);
for tfI = 1:length(tformsUse)
    thisTF = tformsUse(tfI);
    % Distances from base to reg_shift cells
    [baseRegDists{tfI},~] = GetAllPtToPtDistances2(allCentersA(:,1),allCentersA(:,2),...
        reg_shift_centers_all{thisTF}(:,1),reg_shift_centers_all{thisTF}(:,2),[]);
    
    baseRegDists{tfI}(baseRegDists{tfI}>distanceThreshold) = NaN;
    
    % Get only the indices where unregistered base_reg_shift diststs
    unregEntries_baseRS = baseRegDists{tfI}(unmatchedBaseCells,unmatchedRegCells);
    tfInds = thisTF*ones(length(unmatchedBaseCells),length(unmatchedRegCells));
    
    % Get reg_shift cells within distance threshold and closest to shifted COM of anchors
    brdSubstitute = repmat(regShift_aCOM_dists{thisTF}(:)',numCellsA,1);
    unregEntries_RSanchorCOM = brdSubstitute(unmatchedBaseCells,unmatchedRegCells);
    
    % Pool these dists, inds
    pooledUnregDists_baseRS = [pooledUnregDists_baseRS; unregEntries_baseRS(:)];
    pooledUnregDists_RSanchorCOM = [pooledUnregDists_RSanchorCOM(:); unregEntries_RSanchorCOM(:)];
    pooledUnregInds = [pooledUnregInds; unbaseInds(:) unregInds(:)];
    pooledTF = [pooledTF; tfInds(:)];
end
pooledUnregInds(isnan(pooledUnregDists_baseRS),:) = [];
pooledTF(isnan(pooledUnregDists_baseRS),:) = [];
pooledUnregDists_RSanchorCOM(isnan(pooledUnregDists_baseRS)) = [];
pooledUnregDists_baseRS(isnan(pooledUnregDists_baseRS)) = []; % This has to come last

rsMinCriterion = 'baseRSdist';
switch rsMinCriterion
    case 'baseRSdist'
        % Base - reg_shift distance
        [pooledUnregDistsSorted_baseRS,srtIdx] = sort(pooledUnregDists_baseRS,'ascend');
        pooledUnregIndsSorted = pooledUnregInds(srtIdx,:);
        pooledTFsorted = pooledTF(srtIdx);
        [vals,indsMat,indKept] = RankedUniqueInds(pooledUnregDistsSorted_baseRS,pooledUnregIndsSorted,[]);
        tfKept = pooledTFsorted(indKept);

    case 'rsAnchorCOMdist'
        % Reg_shift - shifted anchorCOM distance
        [pooledUnregDistsSorted_RSanchorCOM,srtIdx] = sort(pooledUnregDists_RSanchorCOM,'ascend');
        pooledUnregIndsSorted = pooledUnregInds(srtIdx,:);
        pooledTFsorted = pooledTF(srtIdx);
        [vals,indsMat,indKept] = RankedUniqueInds(pooledUnregDistsSorted_RSanchorCOM,pooledUnregIndsSorted,[]);
        tfKept = pooledTFsorted(indKept);       
end

% Update final reg assignments
finalRegPairs(indsMat(:,1),2) = indsMat(:,2);

% Check that indexing worked
if sum(registeredBaseCells_log(indsMat(:,1)))~=0 ||...
        sum(registeredRegCells_log(indsMat(:,2)))~=0
    disp('Problem: did not revise only unregistered cells...')
    keyboard
end

% Verify transform source was correct; can't actually verify since tform
% inds is only based on acUse up to the point it was generated
tformSourceAinds(indsMat(:,1)) = tfKept;
tformSourceRS(indsMat(:,2)) = tfKept;
for cellI = 1:size(finalRegPairs,1)
    rCell = finalRegPairs(cellI,2);
    if ~isnan(rCell)
        finalRegShiftCenters(rCell,:) = reg_shift_centers_all{tformSourceAinds(cellI)}(rCell,:);
        %verifyCenter = tformCenters{colMin(cellI)}{cellI};
        %verifyCenter = tformCenters{tformsUse==tformSourceAinds(cellI)}{cellI};
        %tformSourceRS
        %{
        if sum(finalRegShiftCenters(rCell,:) - verifyCenter)~=0
            disp('Some reg shift center indexing went wrong')
            keyboard
        end
        %}
    end
end
%}

% Evaluate again what we have, what we missed
registeredBaseCells_log = ~isnan(finalRegPairs(:,2)); % logical
registeredBaseCells = find(registeredBaseCells_log);
unmatchedBaseCells_log = isnan(finalRegPairs(:,2)); % logical
unmatchedBaseCells = find(unmatchedBaseCells_log); % index

registeredRegCells = sort(finalRegPairs(:,2));
registeredRegCells(isnan(registeredRegCells)) = [];
registeredRegCells_log = false(numCellsB,1);
registeredRegCells_log(registeredRegCells) = true;
unmatchedRegCells_log = ~registeredRegCells_log;
unmatchedRegCells = find(unmatchedRegCells_log);

regCheckup = [sum(~isnan(finalRegPairs(:,2))) sum(~isnan(tformSourceRS)) sum(~isnan(tformSourceAinds)) sum(~isnan(finalRegShiftCenters(:,1)))];
if std(regCheckup~=0)
    disp('something registerd wrong so far...')
    keyboard
end

% Do a final transformation of remaining unmatched reg cells: chose
% transform by proximity to anchorsCOMfwd

% Final assignments
% Get a transform, reg shift center for unregistered base cells
% Distance of unregistered base cells from anchorCOMs (replication from above)
rs_aCOM_dists = [];
for tfI = 1:length(tformsUse)
    thisTF = tformsUse(tfI);
    
    rs_aCOM_dists = [rs_aCOM_dists, regShift_aCOM_dists{thisTF}(unmatchedRegCells_log)];
end
[minDists,minDistTform] = min(rs_aCOM_dists,[],2);
missing_aCOMdist = find(sum(isnan(rs_aCOM_dists),2)==length(tformsUse));

unmatchedFound = unmatchedRegCells; 
unmatchedFound(missing_aCOMdist) = [];
minDistTform(missing_aCOMdist) = [];
rs_aCOM_dists(missing_aCOMdist,:) = [];

tformSourceRS(unmatchedFound) = tformsUse(minDistTform);
for tfI = 1:length(tformsUse)
    thisTF = tformsUse(tfI);
    hCells = minDistTform==tfI;
    
    finalRegShiftCenters(unmatchedFound(hCells),:) = reg_shift_centers_all{thisTF}(unmatchedFound(hCells),:);
end
if sum(~isnan(tformSourceRS)) ~= sum(~isnan(finalRegShiftCenters(:,1))) ||...
   sum(~isnan(tformSourceRS)) ~= numCellsB ||...
   sum(~isnan(finalRegShiftCenters(:,1))) ~= numCellsB
    disp('Missed something along the way...')
end

aAlignedFinalRegShiftCenters = nan(numCellsA,2);
haveFinalReg = ~isnan(finalRegPairs(:,2));
aAlignedFinalRegShiftCenters(haveFinalReg,:) = finalRegShiftCenters(finalRegPairs(haveFinalReg,2),:);

% Outputs:
% - finalRegPairs [cellA, cellB]; NaN in cell B where not found within distanceThreshold
% - tformSourceRS - at each ind, which transform was best for aligning cell B 
% - tformSourceAinds - same but for cells paird with A
% - finalRegShiftCenters - centers for all B cells in the A coordinate frame
% - aAlignedFinalRegShiftCenters - same but for B cells matched to A
% - tformsUse
% - tform
outputs.finalRegPairs = finalRegPairs;
outputs.tformSourceRS = tformSourceRS;
outputs.tformSourceAinds = tformSourceAinds;
outputs.finalRegShiftCenters = finalRegShiftCenters;
outputs.aAlignedFinalRegShiftCenters = aAlignedFinalRegShiftCenters;
outputs.tform = tform;
outputs.cellAssignA = cellAssignA;
outputs.cellAssignB = cellAssignB;
outputs.aBlocksX = aBlocksX;
outputs.aBlocksY = aBlocksY;
outputs.bBlocksX = bBlocksX;
outputs.bBlocksY = bBlocksY;

% Voronoi at this stage:
%{
centersAreg = allCentersA(haveFinalReg,:);
centersBreg = finalRegShiftCenters(finalRegPairs(haveFinalReg,2),:);
centersBregOriginal = allCentersB(finalRegPairs(haveFinalReg,2),:);

ptDists = GetEachPairDistances(centersAreg,centersBreg);
[vorAreg,~] = GetAllVorAdjacency(centersAreg);
[vorBreg,~] = GetAllVorAdjacency(centersBreg);
[vorBorig,~] = GetAllVorAdjacency(centersBregOriginal);
%}
% Say how good each block's reg was
for blockA = 1:nBlocksA
    for blockB = 1:nBlocksB
        claimedMatch = allIndsReg{blockA,blockB}>0;
        actualMatch = registeredBaseCells_log;
        
        goodRegAttempts{blockA,blockB} = claimedMatch & actualMatch;
        
        regAttemptsPossible(blockA,blockB) = min([sum(cellAssignA{blockA}) sum(cellAssignB{blockB})]);
    end
end
numGoodRegAttempts = cellfun(@sum,goodRegAttempts);
pctGoodRegAttempts = numGoodRegAttempts ./ regAttemptsPossible;
if any(any(pctGoodRegAttempts > 1))
    keyboard
    disp('Something wrong here, getting a bad number...')
end
outputs.pctGoodRegAttempts = pctGoodRegAttempts;

RA = imref2d(size(NeuronImageA{1}));
regShiftedOutlines = cellfun(@(x,y) imwarp(x,y,'OutputView',RA,'InterpolationMethod','nearest'),...
                    NeuronImageB,tform(tformSourceRS'),'UniformOutput',false);
baseImage = create_AllICmask(NeuronImageA);
regShiftedImage = create_AllICmask(regShiftedOutlines);
[zoomOverlay,zoomOverlayRef] = imfuse(baseImage,regShiftedImage,'ColorChannels',[1 2 0]);
figure; imshow(zoomOverlay,zoomOverlayRef); axis xy
title('Final image overlay')
hold on
plot(allCentersA(haveFinalReg,1),allCentersA(haveFinalReg,2),'.k','MarkerSize',8)
%}
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [wellAligned,goodMatches,diffLogs,cellTripLog] = targetedAlignmentSame(basePairCenters,regPairCenters)
% This takes 2 sets of paired points and asks if the angles between those
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

%{
% assumes you have the cells plotted already...
%Base cells
for mtvI = 1:length(moreThanOneVor)
    tCell = moreThanOneVor(mtvI);
    pHere = find(claimedMatch(tCell,:));
    for ppI = 1:length(pHere)
        plot([basePairCenters(tCell,1) basePairCenters(pHere(ppI),1)],[basePairCenters(tCell,2) basePairCenters(pHere(ppI),2)],'r','LineWidth',1.5)
    end
end
plot(basePairCenters(:,1),basePairCenters(:,2),'.k','MarkerSize',10)

%Reg cells
for mtvI = 1:length(moreThanOneVor)
    tCell = moreThanOneVor(mtvI);
    pHere = find(claimedMatch(tCell,:));
    for ppI = 1:length(pHere)
        plot([regPairCenters(tCell,1) regPairCenters(pHere(ppI),1)],[regPairCenters(tCell,2) regPairCenters(pHere(ppI),2)],'r','LineWidth',1.5)
    end
end
plot(regPairCenters(:,1),regPairCenters(:,2),'.k','MarkerSize',10)
%}
goodMatches = zeros(size(basePairCenters,1),1);
diffAfBlog = [];
diffBfAlog = [];
cellTripLog = [];
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
        %{
        plot(basePairCenters([tripFind tripFind(1)],1),basePairCenters([tripFind tripFind(1)],2),'g','LineWidth',2)
        plot(basePairCenters(:,1),basePairCenters(:,2),'.k','MarkerSize',10)
        
        plot(regPairCenters([tripFind tripFind(1)],1),regPairCenters([tripFind tripFind(1)],2),'g','LineWidth',2)
        plot(regPairCenters(:,1),regPairCenters(:,2),'.k','MarkerSize',10)
        %}
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
                
                cellTripLog = [cellTripLog; aCell, tripFind];
                %{
                plot(basePairCenters([tripFind tripFind(1)],1),basePairCenters([tripFind tripFind(1)],2),'g','LineWidth',2)
                plot(basePairCenters(:,1),basePairCenters(:,2),'.k','MarkerSize',10)
                %}
                %{
                plot(regPairCenters([tripFind tripFind(1)],1),regPairCenters([tripFind tripFind(1)],2),'g','LineWidth',2)
                plot(regPairCenters(:,1),regPairCenters(:,2),'.k','MarkerSize',10)
                %}
            end
        end
    end
end

wellAligned = goodMatches>0;
diffLogs.diffAfBlog = diffAfBlog;
diffLogs.diffBfAlog = diffBfAlog;
% Get the distribution here
%hh = mat2cell(ptRsB.angles,ones(185,1),3);
%jj = cellfun(@(x) ptRsA.angles-x,hh,'UniformOutput',false);

%{
ptRsA.angles(:,1) - ptRsB.angles(:,1)

dtt = delaunay(basePairCenters(:,1),basePairCenters(:,2));
ptt = GetThreePtRelations(basePairCenters(:,1),basePairCenters(:,2),dtt);
testh = 2;
figure;
subplot(1,3,1)
triplot(dtt(testh,:),basePairCenters(:,1),basePairCenters(:,2))
hold on
plot(basePairCenters(dtt(testh,1),1),basePairCenters(dtt(testh,1),2),'*m')
ptt.angles(testh,:)

dtt(2,1)

aa = cellfun(@(x) polyarea(basePairCenters(x,1),basePairCenters(x,2)),{dtt(2,:)})
P1 = [basePairCenters(dtt(2,1),1),basePairCenters(dtt(2,1),2)]
P2 = [basePairCenters(dtt(2,2),1),basePairCenters(dtt(2,2),2)]
P3 = [basePairCenters(dtt(2,3),1),basePairCenters(dtt(2,3),2)]
a1 = rad2deg(atan2(2*aa,dot(P2-P1,P3-P1)))


anglesAc = mat2cell(ptRsA.angles,ones(size(DTaSorted,1),1),3);
anglesAc = cellfun(@(x) sort(abs(x)),anglesAc,'UniformOutput',false);
anglesBc = mat2cell(ptRsB.angles,ones(size(DTbSorted,1),1),3);
anglesBc = cellfun(@(x) sort(abs(x)),anglesBc,'UniformOutput',false);
anglesAx = sort(abs(ptRsA.angles),2);

angleDiffss= cellfun(@(x) anglesAx-x,anglesBc','UniformOutput',false);
angleDiffsSums = cell2mat(cellfun(@(x) sum(abs(x),2),angleDiffss,'UniformOutput',false));

ai = repmat([1:size(DTaSorted,1)],1,size(DTbSorted,1));
bi = repmat([1:size(DTbSorted,1)],size(DTaSorted,1),1);
indMat = [ai(:) bi(:)];

[vals,indsMat,indKept] = RankedUniqueInds(angleDiffsSums(:),indMat,'ascend');

areasA = cellfun(@(x) polyarea(basePairCenters(x,1),basePairCenters(x,2)),mat2cell(DTaSorted,ones(size(DTaSorted,1),1),3));
areasB = cellfun(@(x) polyarea(regPairCenters(x,1),regPairCenters(x,2)),mat2cell(DTbSorted,ones(size(DTbSorted,1),1),3));
areaDiffs = abs(cell2mat(arrayfun(@(x) areasA-x,areasB','UniformOutput',false)));

angleAreaSum = areaDiffs + angleDiffsSums;
[vals,indsMat,indKept] = RankedUniqueInds(angleAreaSum(:),indMat,'ascend');

[sortedAnglesA,sortAidx] = sort(ptRsA.angles,2);
for ii = 1:size(DTaSorted,1); sortedOrientationsA(ii,:) = ptRsA.angleOrientations(ii,sortAidx(ii,:)); end
[sortedAnglesB,sortBidx] = sort(ptRsB.angles,2);
for ii = 1:size(DTbSorted,1); sortedOrientationsB(ii,:) = ptRsB.angleOrientations(ii,sortBidx(ii,:)); end
% Need to verify these are actually aligned where they should be
sortedOrientationsB = sortedOrientationsB + 90;
sortedOrientationsB(sortedOrientationsB > 360) = sortedOrientationsB(sortedOrientationsB > 360) - 360;
sortAngBcell = mat2cell(sortedAnglesB,ones(size(sortBidx,1),1),3);
sortedAngleDiffs = cell2mat(cellfun(@(x) sum(abs(sortedAnglesA-x),2),sortAngBcell','UniformOutput',false));
sortOrBcell = mat2cell(sortedOrientationsB,ones(size(sortBidx,1),1),3);
sortedOrientationDiffs= cell2mat(cellfun(@(x) sum(abs(sortedOrientationsA-x),2),sortOrBcell','UniformOutput',false));

angleOrientationSum = sortedAngleDiffs + sortedOrientationDiffs + areaDiffs;
[vals,indsMat,indKept] = RankedUniqueInds(angleOrientationSum(:),indMat,'ascend');

triplot(DTbSorted(indsMat(2,2),:),regPairCenters(:,1),regPairCenters(:,2),'m','LineWidth',2)
triplot(DTaSorted(indsMat(2,1),:),basePairCenters(:,1),basePairCenters(:,2),'m','LineWidth',2)
%}
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [angleDiffsAbs,distanceDiffs] = getAngleDistDiffs(anglesTwoA,distTwoA,anglesTwoB,distTwoB)

angleDiffs = anglesTwoA(:) - anglesTwoB(:)'; % ( anglesTwoA(i),anglesTwoB(j) ) % 0.044758 seconds
distanceDiffs = abs(distTwoA(:) - distTwoB(:)'); % Difference between distances of tier 2 vor points from each other % 0.044505 seconds
[angleDiffsRect] = RectifyAngleDiffs(rad2deg(angleDiffs),'deg'); %%% slow? % 0.333605 seconds
angleDiffsAbs = abs(angleDiffsRect); % 0.051833 seconds

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
%vorAdjacency = GetVoronoiAdjacency(vorIndices,vorVertices);
vorAdjacency = GetVoronoiAdjacency2(allCenters);
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
evalStats.propUEdist = sum(hereUEdist)/sum(totalUEdist);

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
function ptsForward=affineTransform(tform,ptsTransform)

%tform = fitgeotrans(regPairCenters,basePairCenters,'affine');
[ptsForward(:,1),ptsForward(:,2)] = transformPointsForward(tform,ptsTransform(:,1),ptsTransform(:,2));

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [closestPairs,pairDistances,allDistances,nanDistances,regStats] =...
    evaluateRegistration(allCentersA,reg_shift_centers,anchorCellsA,anchorCellsB,distThresh)

numAnchorCells = length(anchorCellsA);
[distH,~] = GetAllPtToPtDistances([allCentersA(:,1); reg_shift_centers(:,1)],[allCentersA(:,2); reg_shift_centers(:,2)],[]);
distanceMatrix = distH(1:length(allCentersA),length(allCentersA)+(1:length(reg_shift_centers))); clear distH
% hypot(abs(allCentersA(1,1) - reg_shift_centers(1,1)),abs(allCentersA(1,2) - reg_shift_centers(1,2)))
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