function [figHand,statsOut] = PlotPVcurvesDiffRawDays(cellArrMeanByCS,uniqueDayDiffs,cellRealDays,binsUse,colorsPlot)
%cellArrMeanByCS{slI}{pvtI} - assumes sublevel cells are mice, one
%dimensional (already meaned across bins of interest)
%uniqueDayDiffs{slI}{pvtI}
numMice = length(cellArrMeanByCS);
numCondSets = size(cellArrMeanByCS{1},2);
numCondDiffs = numCondSets - 1;

cellRealDays = cellfun(@(x) x-(x(1)-1),cellRealDays,'UniformOutput',false);

%Bin corrs (mean across bins in binsUse)
for mouseI = 1:numMice
    meanedCorrs = cellfun(@(x) mean(x(binsUse)),cellArrMeanByCS{mouseI},'UniformOutput',false);
    binnedCorrs{mouseI} = cell2mat(meanedCorrs);
end

%Get corr differences
withinCorrsPooledAcrossMice = cell(numCondSets-1);
daysPooledAcrossMice = cell(numCondSets-1);
for mouseI = 1:numMice
    for cdI = 2:numCondSets
        PVcorrsDiff{mouseI}{cdI-1,1} = binnedCorrs{mouseI}(:,1) - binnedCorrs{mouseI}(:,cdI); 
        
        withinDayPVdiff{mouseI}{cdI-1} = PVcorrsDiff{mouseI}{cdI-1,1}(uniqueDayDiffs{mouseI}==0);
        
        withinCorrsPooledAcrossMice{cdI-1} = [withinCorrsPooledAcrossMice{cdI-1}; withinDayPVdiff{mouseI}{cdI-1}];
        daysPooledAcrossMice{cdI-1} = [daysPooledAcrossMice{cdI-1}; cellRealDays{mouseI}];
    end
end

%Plot
figHand = [];
statsOut = [];
figHand = figure('Position',[703 362 292 269]);
plot([0 max(daysPooledAcrossMice{1})],[0 0],'k'); hold on
for cdI = 1:numCondDiffs
    %figHand{cdI} = figure; 
    for mouseI = 1:numMice
        plot(cellRealDays{mouseI},withinDayPVdiff{mouseI}{cdI},'Color',colorsPlot{cdI})
        hold on
    end
end

for cdI = 1:numCondDiffs
    [fitVal,daysPlot] = FitLineForPlotting(withinCorrsPooledAcrossMice{cdI},daysPooledAcrossMice{cdI});
    plot(daysPlot,fitVal,'Color',colorsPlot{cdI},'LineWidth',2); hold on
    
    [~, ~, ~, RR, statsOut.slope.pVal(cdI), ~] =...
        fitLinRegSL(withinCorrsPooledAcrossMice{cdI},daysPooledAcrossMice{cdI});
    statsOut.slope.RR(cdI) = RR.Ordinary;
    [statsOut.slopeDiffZero.Fval(cdI),statsOut.slopeDiffZero.dfNum(cdI),...
     statsOut.slopeDiffZero.dfDen(cdI),statsOut.slopeDiffZero.pVal(cdI)] =...
            slopeDiffFromZeroFtest(withinCorrsPooledAcrossMice{cdI},daysPooledAcrossMice{cdI});
        
    [statsOut.spearmanSlope.rho(cdI),statsOut.spearmanSlope.pVal(cdI)] = ...
     corr(daysPooledAcrossMice{cdI},withinCorrsPooledAcrossMice{cdI},'Type','Spearman');
    %title( ['Corr RR= ' num2str(statsOut.slope.RR(cdI)), ' p=' num2str(statsOut.slope.pVal(cdI))...
    %        ' slope~=0 pVal=' num2str(statsOut.slopeDiffZero.pVal(cdI))])
    
    ylabel('Correlation')
    xlabel('Recording Day')
end
xlim([1 max(cell2mat(cellfun(@max,daysPooledAcrossMice,'UniformOutput',false)))])


comps = combnk(1:numCondDiffs,2);
for compI = 1:size(comps,1)
    %daysCheck = unique(daysPooledAcrossMice{comps(compI,1)});
    
    [statsOut.signranks{compI}.pVal,statsOut.signranks{compI}.hVal,...
     stats,statsOut.signranks{compI}.whichWon,statsOut.signranks{compI}.eachDayPair] =...
     SignRankTestAllDayPairs(...
        withinCorrsPooledAcrossMice{comps(compI,1)},...
        withinCorrsPooledAcrossMice{comps(compI,2)},...
        daysPooledAcrossMice{comps(compI,1)});
    try
    statsOut.signranks{compI}.zVal = stats.zval;
    end
    
    [statsOut.signrankall{compI}.pVal, statsOut.signrankall{compI}.hVal,...
        stats] = signrank(...
        withinCorrsPooledAcrossMice{comps(compI,1)},...
        withinCorrsPooledAcrossMice{comps(compI,2)});
    try
    statsOut.signrankall{compI}.zVal = stats.zval;
    end

end

end