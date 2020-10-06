function voronoiRegNotes2_7()
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
nBlocksX = 3; xPctOverlap = 0.5;
nBlocksY = 3; yPctOverlap = 0.5;
nBlocks = nBlocksX*nBlocksY;

nBlocksA = nBlocks;
nBlocksB = nBlocks;

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
disp('Check we have grabbed all cells')

% Rotate and re-find centers
rotateDeg = 90;
NeuronImageB = cellfun(@(x) imrotate(x,rotateDeg),NeuronImageB,'UniformOutput',false);
allCentersB = getAllCellCenters(NeuronImageB,true);

%{
% Grid midpoints for reference
aMidsX = mean(aBlocksX,2);  aMidsY = mean(aBlocksY,2);
[aGridsX,aGridsY] = meshgrid(aMidsX,aMidsY);
bMidsX = mean(bBlocksX,2);  bMidsY = mean(bBlocksY,2);
[bGridsX,bGridsY] = meshgrid(bMidsX,bMidsY);
%}

aGridPosX = repmat(1:nBlocksX,3,1);
aGridPosY = repmat([1:nBlocksY]',1,3);
bGridPosX = repmat(1:nBlocksX,3,1);
bGridPosY = repmat([1:nBlocksY]',1,3);
bGridPosXrot = bGridPosX;
bGridPosYrot = bGridPosY;
    
% Rotate pts
bShiftX = bGridsX - mean(bGridsX(:));
bShiftY = bGridsY - mean(bGridsY(:));
% Rotate your point(s)
ptCell = mat2cell([bShiftX(:) bShiftY(:)],ones(nBlocks,1),2);
R = [cosd(-rotateDeg) -sind(-rotateDeg); sind(-rotateDeg) cosd(-rotateDeg)];
bGridsRot = cell2mat(cellfun(@(x) (R*x')',ptCell,'UniformOutput',false));
% Translate back
bGridsXrot = bGridsRot(:,1) + mean(bGridsY(:));
bGridsYrot = bGridsRot(:,2) + mean(bGridsX(:));

% Adjacency for gridsX,gridsY...
[neswCode, adjMatA, relativePosA] = gridAdjacency(aGridPosX,aGridPosY,aGridsX,aGridsY);
[~, adjMatB, relativePosB] = gridAdjacency(bGridPosX,bGridPosY,bGridsX,bGridsY);
[~, adjMatBrot, relativePosBrot] = gridAdjacency(bGridPosXrot,bGridPosYrot,bGridsXrot,bGridsYrot);


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
    useCentersA = allCentersA(cellAssignA{blockA},:); % 0.006752 seconds
    numUseCellsA = size(useCentersA,1);
    [allAnglesA,allDistancesA,vorTwoLogicalA,neuronTrackerA] = setupForAligns(useCentersA,vorAdjacencyMax,true); % 0.152467 seconds
    [anglesTwoA,distTwoA,cellRowA] = gatherTwoAligns(allAnglesA,allDistancesA,vorTwoLogicalA,neuronTrackerA); % 0.007361 seconds
    numVorTwoPartnersA = sum(vorTwoLogicalA,2);
    
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
            histcounts(angleDiffsAbs(distanceDiffs<dThreshUse),abinn); % 0.183596 seconds
        toc
        %}
        
        binWidth = 1;
        anglePeak(blockA,blockB) = C{blockA,blockB}(1);
        thisAngleBin = C{blockA,blockB}(1)+((binWidth/2)*[-1 1]);
        thisDistBin = 0;
        angleDiffsHere = (angleDiffsAbs <= max(thisAngleBin)) & (angleDiffsAbs >= min(thisAngleBin));
        distDiffsHere = distanceDiffs < dThreshUse;
        angleDistHere = angleDiffsHere & distDiffsHere; % Logical identifier for angle and dist differences in current histogram bin
        
        %imagCellIdsHere = imagCellIDs(angleDistHere); % All the unique cell pair identifiers for vorTwoPairs with angle/dist in this bin
        intCellIdsHere = intCellIDs(angleDistHere);
        
        [uniqueCellPairsInts,~,ic] = unique(intCellIdsHere);
        uniqueCellPairs = intsToCells(uniqueCellPairsInts,numUseCellsA,numUseCellsB);
        
        %disp('Peak quality checking')
        [uniqueCellsUsePairs,uniqueCellsUseMax,totalAligns,meanAligns] =...
            initClusterStats(uniqueCellPairs,ic,numUseCellsA,numUseCellsB);
        
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
            [tform{blockA,blockB}, reg_shift_centers{blockA,blockB}, closestPairs{blockA,blockB}, nanDistances{blockA,blockB}, regStats{blockA,blockB}] =...
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
        rowInd = nBlocks*(blockAj-1) + blockBj;
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
                colInd = nBlocks*(blockAk-1) + blockBk;
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

% treat adDiff > agreementThresh as an adjacency matrix, is it to find all
% transforms that have overlaps with other transforms. 
overlappedGoodTransforms = GetAllTierAdjacency(adDiff > agreementThresh,[]); 
overlappedGoodTransforms(isinf(overlappedGoodTransforms)) = 0;
tformsUse = find(sum(overlappedGoodTransforms,1)); % This assumes they're all connected
disp('This is where unconnected clusters of alignments would be discovered')
% tformsUse = find(sum(adDiff > agreementThresh,1));
% tformInd = blockB*(nBlocksB-1)+blockA

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

% Voronoi at this stage:
centersAreg = allCentersA(haveFinalReg,:);
centersBreg = finalRegShiftCenters(finalRegPairs(haveFinalReg,2),:);
centersBregOriginal = allCentersB(finalRegPairs(haveFinalReg,2),:);

ptDists = GetEachPairDistances(centersAreg,centersBreg);
[vorAreg,~] = GetAllVorAdjacency(centersAreg);
[vorBreg,~] = GetAllVorAdjacency(centersBreg);
[vorBorig,~] = GetAllVorAdjacency(centersBregOriginal);

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
% Get the code from old cell register to transform the images and fit them to base display

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