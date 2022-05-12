condPlot = [1 2 3 4];

plotBins.X = []; plotBins.Y = [];
for condI = 1:numel(condsUse)
    plotBins.X = [plotBins.X; lgPlotHere{condsUse(condI)}.X];
    plotBins.Y = [plotBins.Y; lgPlotHere{condsUse(condI)}.Y];
end

edgeI = 11;
mouseI = 2;
dpH = 5;

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
 
 figure; plot(mean(pcpSpatialCorrs,2))
 %figure; histogram(pcpSpatialCorrs)
 %figure; histogram(mean(pcpSpatialCorrs,2))
 
 %%
 
 find(sum(pcpSpatialCorrs < 0.2,2)==2)
  
 %%
 
pairI = 250; 

cellPair = potentialCellPairs(pairI,:);

dayPairHere = dayPairsHere(dpH,:);

sessI = dayPairHere(1);       
cellI = cellPair(1);
activityPlotStuff;
set(gcf,'Position',[9.5000 417 515 397.5000])
cellI = cellPair(2);
activityPlotStuff;
set(gcf,'Position',[681 446.5000 552.5000 364])

sessI = dayPairHere(2);       
cellI = cellPair(1);
activityPlotStuff;
set(gcf,'Position', [334.5000 51.5000 472 348])
cellI = cellPair(2);
activityPlotStuff;
set(gcf,'Position', [1.0655e+03 61 522.5000 341.5000])

disp(['Day pair ' num2str(dayPairHere)...
    ', cellI ' num2str(cellPair(1)) ' corr ' num2str( singleCellAllCorrsRho{mouseI}{1}{dpH}(cellPair(1)) )...
    ', cellJ ' num2str(cellPair(2)) ' corr ' num2str( singleCellAllCorrsRho{mouseI}{1}{dpH}(cellPair(2)) )...
    ', tempCorr day 1 ' num2str( pcpTempCorrs(pairI,1) ) ', tempCorr day 2 ' num2str( pcpTempCorrs(pairI,2) ) ])


% repeat for day 2

