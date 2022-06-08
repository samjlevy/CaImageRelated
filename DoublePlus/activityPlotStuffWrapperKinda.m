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


%%

% Within day pair finding notes
mouseI = 5;
dpH = 9;
dayHere = 9; dayHereInd = find(dayPairsHere(dpH,:)==dayHere);

cellPairsHH = [];
[cellPairsHH(:,1),cellPairsHH(:,2)] = ind2sub([numCells(mouseI) numCells(mouseI)],cellPairsOverDays{mouseI}{dpH});
pairsHere = cellPairsHH;

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

tripPlot = 1;

dayI = dayHere;

%% 
cellI = possiblePlot(tripPlot,1);
PlotDoublePlusRaster(cellTBT{mouseI},cellI,dayI,condPlot,armLabels,armLims)
suptitleSL(['Mouse ' num2str(mouseI) ', Cell ' num2str(cellI), ', session ' num2str(dayI)])
set(gcf,'Position',[4.3333 168.3333 416.6667 310])

cellI = possiblePlot(tripPlot,2);
PlotDoublePlusRaster(cellTBT{mouseI},cellI,dayI,condPlot,armLabels,armLims)
suptitleSL(['Mouse ' num2str(mouseI) ', Cell ' num2str(cellI), ', session ' num2str(dayI)])
set(gcf,'Position',[409 165 432.6667 312])

cellI = possiblePlot(tripPlot,3);
PlotDoublePlusRaster(cellTBT{mouseI},54,dayI,condPlot,armLabels,armLims)
suptitleSL(['Mouse ' num2str(mouseI) ', Cell ' num2str(cellI), ', session ' num2str(dayI)])
set(gcf,'Position',[839.6667 170.3333 428.0000 312])


PlotDoublePlusRaster(trialbytrial,cellPlot,3,[1 2 3 4],{'n','w','s','e'},[])
suptitleSL(['Cell ' num2str(cellPlot)])

originalCellHere = sortedSessionInds(cellPlot,3);