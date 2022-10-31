condPlot = [1 2 3 4];

plotBins.X = []; plotBins.Y = [];
for condI = 1:numel(condsUse)
    plotBins.X = [plotBins.X; lgPlotHere{condsUse(condI)}.X];
    plotBins.Y = [plotBins.Y; lgPlotHere{condsUse(condI)}.Y];
end

edgeI = 11;
mouseI = 5;
dpH = 8;

cellPairsHH = [];
[cellPairsHH(:,1),cellPairsHH(:,2)] = ind2sub([numCells(mouseI) numCells(mouseI)],cellPairsOverDays{mouseI}{dpH});
pairsHere = cellPairsHH;

singleCellPairCorrs = singleCellAllCorrsRho{mouseI}{1}{dpH}(pairsHere);

temporalCorrChanges = corrDiffs{mouseI}{2}{dpH};
temporalDayB = corrsAllAB{mouseI}{2}{dpH}(:,2);
temporalDayA = corrsAllAB{mouseI}{2}{dpH}(:,1);

stayedTempCorr = (temporalDayB > edgeThreshes(edgeI)) &...
    (temporalDayA > edgeThreshes(edgeI));

uniqueCellsHere = unique(pairsHere(stayedTempCorr,:));

potentialCellPairs = pairsHere(stayedTempCorr,:); %index into vvv to look for low spatial correlation
pcpTempCorrs = [temporalDayA(stayedTempCorr), temporalDayB(stayedTempCorr)];
pcpSpatialCorrs = [singleCellAllCorrsRho{mouseI}{1}{dpH}(potentialCellPairs)];
reH = [trialReliAll{mouseI}(potentialCellPairs(:,1),dayPairsHere(dpH,1)), trialReliAll{mouseI}(potentialCellPairs(:,2),dayPairsHere(dpH,1))];
miH = [MI{mouseI}(potentialCellPairs(:,1),dayPairsHere(dpH,1)), MI{mouseI}(potentialCellPairs(:,2),dayPairsHere(dpH,1))];
vv = [pcpTempCorrs, pcpSpatialCorrs, reH, miH];

figure; plot(mean(pcpSpatialCorrs,2))
%figure; histogram(pcpSpatialCorrs)
%figure; histogram(mean(pcpSpatialCorrs,2))

%%

find(sum(pcpSpatialCorrs < 0.2,2)==2)

%%

%pairI = 1;

cellPair = potentialCellPairs(pairI,:);

dayPairHere = dayPairsHere(dpH,:);

sessI = dayPairHere(1);
cellI = cellPair(1);
activityPlotStuff;
aga = gcf; aga.Renderer = 'painters';
%set(gcf,'Position',[9.5000 417 515 397.5000])
set(gcf,'Position',[9 369.6667 472 348])
cellI = cellPair(2);
activityPlotStuff;
aha = gcf; aha.Renderer = 'painters';
%set(gcf,'Position',[681 446.5000 552.5000 364])
set(gcf,'Position',[521 373 472 348])

sessI = dayPairHere(2);
cellI = cellPair(1);
activityPlotStuff;
set(gcf,'Position', [334.5000 51.5000 472 348])
set(gcf,'Renderer','painters');
cellI = cellPair(2);
activityPlotStuff;
%set(gcf,'Position', [1.0655e+03 61 522.5000 341.5000])
set(gcf,'Position', [750.3333 37.6667 522.6667 341.3333])
set(gcf,'Renderer','painters');
figure(aga);
figure(aha);

disp(['Day pair ' num2str(dayPairHere)...
    ', cellI ' num2str(cellPair(1)) ' corr ' num2str( singleCellAllCorrsRho{mouseI}{1}{dpH}(cellPair(1)) )...
    ', cellJ ' num2str(cellPair(2)) ' corr ' num2str( singleCellAllCorrsRho{mouseI}{1}{dpH}(cellPair(2)) )...
    ', tempCorr day 1 ' num2str( pcpTempCorrs(pairI,1) ) ', tempCorr day 2 ' num2str( pcpTempCorrs(pairI,2) ) ])


%% Within day pair finding notes

% Within day pair finding notes
mouseI = 5;
dpH = 9;
dayHere = 9; dayHereInd = find(dayPairsHere(dpH,:)==dayHere);

%singleCellPairCorrs = singleCellAllCorrsRho{mouseI}{1}{dpH}(pairsHere);
%spatialCorrsHere = corrsAllAB{mouseI}{1}{dpH}(:,dayHereInd);
spatialCorrsHere = spatialCorrsR{mouseI}{dayHere};
%temporalDayB = corrsAllAB{mouseI}{2}{dpH}(:,dayHereInd);
temporalCorrsHere = temporalCorrsR{mouseI}{dayHere};
% Cell 1 corr, cell2 corr, temporalCorr
% How to find triplets where all 3 high spatial corr, but 1 pair high temp other low temp? 
spatialCorrM = nan(numCells(mouseI));
%spatialCorrM(cellPairsOverDays{mouseI}{dpH}) = spatialCorrsHere;
cellPairsIndsH = sub2ind([numCells(mouseI) numCells(mouseI)],cellPairsUsed{mouseI}{dayHere}(:,1),cellPairsUsed{mouseI}{dayHere}(:,2));
spatialCorrM(cellPairsIndsH) = spatialCorrsHere;
spatialCorrM(:,:,2) = spatialCorrM';
scm = nansum(spatialCorrM,3);
scm(sum(isnan(spatialCorrM),3)==2) = NaN;
spatialCorrM = scm;

temporalCorrM = nan(numCells(mouseI));
%temporalCorrM(cellPairsOverDays{mouseI}{dpH}) = temporalDayB;
%temporalCorrM(cellPairsOverDays{mouseI}{dpH}) = temporalCorrsHere;
temporalCorrM(cellPairsIndsH) = temporalCorrsHere;
temporalCorrM(:,:,2) = temporalCorrM';
tcm = nansum(temporalCorrM,3);
tcm(sum(isnan(temporalCorrM),3)==2) = NaN;
temporalCorrM = tcm;

spatialCorrThresh = 0.75;
tCorrUp = 0.15;
tCorrDown = -0;
possiblePlot = [];
for cellI = 1:numCells(mouseI)
    % Ask if there are two partners that have spatial corr above threhs
    sAboveThresh = spatialCorrM(cellI,:) > spatialCorrThresh;

    % Ask if among those, there is a temporal corr above some thresh and a temporal corr below another thresh
    tAboveThresh = temporalCorrM(cellI,:) > tCorrUp;
    tBelowThresh = temporalCorrM(cellI,:) < tCorrDown; 

    tAboveThresh = tAboveThresh & sAboveThresh;
    tBelowThresh = tBelowThresh & sAboveThresh;

    if any(tAboveThresh) && any(tBelowThresh)
        %keyboard
        combsHere = GetAllCombs(find(tAboveThresh),find(tBelowThresh));
        
        possiblePlot = [possiblePlot; cellI*ones(size(combsHere,1),1), combsHere];
        % Could add MI scores, etc.
    end
end
%[possiblePlot] = FilterUniqueCombs(possiblePlot);
MM = [];
for ii = 1:size(possiblePlot,1)
    for jj = 1:size(possiblePlot,2)
        MM(ii,jj) = MI{mouseI}(possiblePlot(ii,jj),dayHere);
    end
end
MIthresh = 0.65;
MIkeep = sum(MM > 0.7,2) == 3;
possiblePlot = [possiblePlot(MIkeep,:), MM(MIkeep,:)];

tripPlot = 22; % 57
% trialReliThresholding
trialReliPos = [];
for ii = 1:3
    for condI = 1:4
        trialReliPos(:,ii,condI) = trialReli{mouseI}(possiblePlot(:,ii),dayHere,condI);
    end
end
tThresh = 0.2;
abtt = sum(sum(trialReliPos > tThresh,2)==3,3)>0;
possiblePlot = possiblePlot(abtt,:);

tripPlot = 50; % 82 99 


dayI = dayHere;

%% 
cellI = possiblePlot(tripPlot,1);
PlotDoublePlusRaster(cellTBT{mouseI},cellI,dayI,condPlot,armLabels,armLims,true)
suptitleSL(['Mouse ' num2str(mouseI) ', Cell ' num2str(cellI), ', session ' num2str(dayI)])
set(gcf,'Position',[4.3333 168.3333 428.0000 312])
set(gcf,'Renderer','painters')

cellI = possiblePlot(tripPlot,2);
PlotDoublePlusRaster(cellTBT{mouseI},cellI,dayI,condPlot,armLabels,armLims,true)
suptitleSL(['Mouse ' num2str(mouseI) ', Cell ' num2str(cellI), ', session ' num2str(dayI)])
set(gcf,'Position',[409 165 428.0000 312])
set(gcf,'Renderer','painters')

cellI = possiblePlot(tripPlot,3);
PlotDoublePlusRaster(cellTBT{mouseI},cellI,dayI,condPlot,armLabels,armLims,true)
suptitleSL(['Mouse ' num2str(mouseI) ', Cell ' num2str(cellI), ', session ' num2str(dayI)])
set(gcf,'Position',[839.6667 170.3333 428.0000 312])

cellA = possiblePlot(tripPlot,1);
cellB = possiblePlot(tripPlot,2);
cellC = possiblePlot(tripPlot,3);
disp(['Temporal corr A-B: ' num2str(temporalCorrM(cellA,cellB)) ', cell A-C: '  num2str(temporalCorrM(cellA,cellC)) ', cell B-C: '  num2str(temporalCorrM(cellB,cellC))])
disp(['Spatial corr A-B: ' num2str(spatialCorrM(cellA,cellB)) ', cell A-C: '  num2str(spatialCorrM(cellA,cellC)) ', cell B-C: '  num2str(spatialCorrM(cellB,cellC))])
%{
PlotDoublePlusRaster(trialbytrial,cellPlot,3,[1 2 3 4],{'n','w','s','e'},[])
suptitleSL(['Cell ' num2str(cellPlot)])

originalCellHere = sortedSessionInds(cellPlot,3);
%}

footPrints = load('C:\Users\Sam\Desktop\DoublePlus\Styx\StyxFootprints\NeuronFootprint180329.mat')

for cellI = 1:570; cellROIs{cellI} = squeeze(cell_registered_struct.spatial_footprints_corrected{dayHere}(cellI,:,:)); end
cellOutlines = cellfun(@(x) bwboundaries(x),cellROIs,'UniformOutput',false);
cellOutlinesPatch = cellfun(@(x) [x{1}; x{1}(end,:)],cellOutlines,'UniformOutput',false);

originalIndsA = cellSSI{mouseI}(cellA,dayHere);
originalIndsB = cellSSI{mouseI}(cellB,dayHere);
originalIndsC = cellSSI{mouseI}(cellC,dayHere);
origCells = [originalIndsA, originalIndsB, originalIndsC];
figure; axis; hold on
for cellI = 1:570
    if cellI == originalIndsA ||...
            cellI == originalIndsB ||...
            cellI == originalIndsC
    else
        outlineColor = [0    0.4471    0.7412];
        patchColor = [0.3020    0.7451    0.9333];
        % Draw the patch
        patch(cellOutlinesPatch{cellI}(:,1),cellOutlinesPatch{cellI}(:,2),patchColor,'FaceAlpha',0.4,'EdgeColor','none')
        % Draw the outline
        plot(cellOutlinesPatch{cellI}(:,1),cellOutlinesPatch{cellI}(:,2),'Color',outlineColor,'LineWidth',0.5)
    end
end
outlineColor = [0.8510    0.3255    0.0980];
patchColor = [1.0000    0.4118    0.1608];
for cellI = 1:3
    % Draw the patch
    patch(cellOutlinesPatch{origCells(cellI)}(:,1),cellOutlinesPatch{origCells(cellI)}(:,2),patchColor,'FaceAlpha',0.2,'EdgeColor','none')
    % Draw the outline
    plot(cellOutlinesPatch{origCells(cellI)}(:,1),cellOutlinesPatch{origCells(cellI)}(:,2),'Color',outlineColor,'LineWidth',0.75)

    %text(mean(cellOutlinesPatch{origCells(cellI)}(:,1)),mean(cellOutlinesPatch{origCells(cellI)}(:,2)),num2str(origCells(cellI)))
    text(mean(cellOutlinesPatch{origCells(cellI)}(:,1)),mean(cellOutlinesPatch{origCells(cellI)}(:,2)),num2str(possiblePlot(tripPlot,cellI)))
end
xlabel('FOV X (um)')
ylabel('FOV Y (um)')
set(gcf,'Renderer','painters')

%% Notes for finding cell pairs across days
mouseI = 6;
dpH = 4;
dayPair = dayPairsHere(dpH,:);

cellPairsHH = [];
[cellPairsHH(:,1),cellPairsHH(:,2)] = ind2sub([numCells(mouseI) numCells(mouseI)],cellPairsOverDays{mouseI}{dpH});
pairsHere = cellPairsHH;

cellPairsIndsHA = sub2ind([numCells(mouseI) numCells(mouseI)],cellPairsUsed{mouseI}{dayPair(1)}(:,1),cellPairsUsed{mouseI}{dayPair(1)}(:,2));

spatialCorrsHereA = spatialCorrsR{mouseI}{dayPair(1)};
spatialCorrMA = nan(numCells(mouseI),numCells(mouseI));
spatialCorrMA(cellPairsIndsHA) = spatialCorrsHereA;
spatialCorrMA(:,:,2) = spatialCorrMA'; % Pairs are unique combs, so have to combine to fill the square matrix
scm = nansum(spatialCorrMA,3);
scm(sum(isnan(spatialCorrMA),3)==2) = NaN;
spatialCorrMA = scm;

temporalCorrsHereA = temporalCorrsR{mouseI}{dayPair(1)};
temporalCorrMA = nan(numCells(mouseI),numCells(mouseI));
temporalCorrMA(cellPairsIndsHA) = temporalCorrsHereA;
temporalCorrMA(:,:,2) = temporalCorrMA';
tcm = nansum(temporalCorrMA,3);
tcm(sum(isnan(temporalCorrMA),3)==2) = NaN;
temporalCorrMA = tcm;

cellPairsIndsHB = sub2ind([numCells(mouseI) numCells(mouseI)],cellPairsUsed{mouseI}{dayPair(2)}(:,1),cellPairsUsed{mouseI}{dayPair(2)}(:,2));

spatialCorrsHereB = spatialCorrsR{mouseI}{dayPair(2)};
spatialCorrMB = nan(numCells(mouseI),numCells(mouseI));
spatialCorrMB(cellPairsIndsHB) = spatialCorrsHereB;
spatialCorrMB(:,:,2) = spatialCorrMB'; % Pairs are unique combs, so have to combine to fill the square matrix
scm = nansum(spatialCorrMB,3);
scm(sum(isnan(spatialCorrMB),3)==2) = NaN;
spatialCorrMB = scm;

temporalCorrsHereB = temporalCorrsR{mouseI}{dayPair(2)};
temporalCorrMB = nan(numCells(mouseI),numCells(mouseI));
temporalCorrMB(cellPairsIndsHB) = temporalCorrsHereB;
temporalCorrMB(:,:,2) = temporalCorrMB';
tcm = nansum(temporalCorrMB,3);
tcm(sum(isnan(temporalCorrMB),3)==2) = NaN;
temporalCorrMB = tcm;

% Now filter for a triplet of cells which are all well correlated on day A,
% but one becomes temporally uncorrelated day B
spatialCorrThresh = 0.75;
tCorrUp = 0.15;
tCorrDown = -0.0;
MIthresh = 0.65;
reliThreshH = 0.25;
yesSpatialA = spatialCorrMA > spatialCorrThresh;
yesTemporalA = temporalCorrMA > tCorrUp;
yesSpatialB = spatialCorrMB > spatialCorrThresh;
yesTemporalB = temporalCorrMB > tCorrUp;
noTemporalB = temporalCorrMB < tCorrDown;
yesSpatialYesTemporalA = yesSpatialA & yesTemporalA;
yesSpatialYesTemporalB = yesSpatialB & yesTemporalB;
yesSpatialNotTemporalB = yesSpatialB & noTemporalB;
staySpatialAndTemporal = yesSpatialYesTemporalA & yesSpatialYesTemporalB;
staySpatialNotTemporal = yesSpatialYesTemporalA & yesSpatialNotTemporalB;

%MI, reli thresh here
MIgood = (repmat(MI{mouseI}(:,dayPair(1)),1,numCells(mouseI)) > MIthresh) &...
         (repmat(MI{mouseI}(:,dayPair(2))',numCells(mouseI),1) > MIthresh);
reliGood = (repmat(sum(trialReli{mouseI}(:,dayPair(1),:) > reliThreshH,3) > 0,1,numCells(mouseI))) &... 
           (repmat(sum(trialReli{mouseI}(:,dayPair(2),:) > reliThreshH,3)' > 0, numCells(mouseI),1));
staySpatialAndTemporal = staySpatialAndTemporal & MIgood & reliGood;
staySpatialNotTemporal = staySpatialNotTemporal & MIgood & reliGood;

% Get the combinations of these
%{
possiblePlot = [];
for cellI = 1:numCells(mouseI)
    indsA = find(staySpatialAndTemporal(cellI,:));
    indsB = find(staySpatialNotTemporal(cellI,:));
    if any(indsA) && any(indsB)
        combsHere = GetAllCombs(indsA,indsB);
        possiblePlot = [possiblePlot; cellI*ones(size(combsHere,1),1), combsHere];
    end
end
%}
% No examples of this happening, so we'll just get 2 independent cells
