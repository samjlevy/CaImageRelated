dayI = sessI;
PlotDotplotDoublePlus2(cellTBT{mouseI},cellI,condPlot,dayI,'dynamic',[],3)%
MakePlotPrettySL(gca);
suptitleSL(['Cell ' num2str(cellI), ', session ' num2str(sessI)])
there = [cellTMap{mouseI}{cellI,dayI,:}]; there = there(:)';%there = [NaN; there(:)]';
gradientLims = []; titles = [];
[figHand] = PlusMazePVcorrHeatmap3(there,lgPlotAll,'jet',gradientLims,titles);
suptitleSL(['Cell ' num2str(cellI), ', session ' num2str(sessI)])
figHand.Position=[243.5000 207 447 405];
MakePlotPrettySL(gca);
PlotDoublePlusRaster(cellTBT{mouseI},cellI,dayI,condPlot,armLabels)
suptitleSL(['Cell ' num2str(cellI), ', session ' num2str(sessI)])