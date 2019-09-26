function [figHand,statsOut] = PlotPVcurvesRawDays(pvCorrs,cellRealDays,binsUse,colorsPlot)
%cellArrMeanByCS{slI}{pvtI} - assumes sublevel cells are mice, one
%dimensional (already meaned across bins of interest)
%uniqueDayDiffs{slI}{pvtI}
numMice = length(pvCorrs);
numCondSets = size(pvCorrs{1},2);
numBins = size(pvCorrs{1}{1}{1},2);

cellRealDays = cellfun(@(x) x-(x(1)-1),cellRealDays,'UniformOutput',false);
allDays = vertcat(cellRealDays{:});
meanLineDays = unique(allDays);

%Bin corrs (mean across bins in binsUse)
meanedCorrs = [];
csPooledCorrs = [];
csMeanedCorrs = [];
for mouseI = 1:numMice
    for csI = 1:numCondSets
        meanedCorrs{mouseI}{csI} = cellfun(@(x) mean(x(:,binsUse),2),pvCorrs{mouseI}{csI},'UniformOutput',false);
        csPooledCorrs{mouseI}{csI} = cell2mat(meanedCorrs{mouseI}{csI});
        csMeanedCorrs{mouseI}(:,csI) = mean(csPooledCorrs{mouseI}{csI},2);
    end
end

%Plot
figHand = [];
statsOut = [];
figHand = figure('Position',[703 362 292 269]);
%plot([0 max(daysPooledAcrossMice{1})],[0 0],'k'); hold on
allCorrs = [];
allAllCorrs = [];
for csI = 1:numCondSets
    %figHand{cdI} = figure; 
    allCorrs{csI} = [];
    allAllCorrs{csI} = [];
    for mouseI = 1:numMice
        % %{
        corrsHere = csMeanedCorrs{mouseI}(:,csI);
        plot(cellRealDays{mouseI},corrsHere,'--','Color',colorsPlot{csI})
        hold on
        allCorrs{csI} = [allCorrs{csI}; corrsHere(:)];
        %}
        % %{
        for ccI = 1:size(csPooledCorrs{mouseI}{csI},2)
            corrsHere2 = csPooledCorrs{mouseI}{csI}(:,ccI);
            %plot(cellRealDays{mouseI},corrsHere,'--','Color',colorsPlot{csI})
            %hold on
            allAllCorrs{csI} = [allAllCorrs{csI}; corrsHere2(:)];
        end
        %}
    end
    for dayI = 1:length(meanLineDays)
        meanCorr(dayI,csI) = mean(allCorrs{csI}(allDays==meanLineDays(dayI)));
    end
end
for csJ = 1:numCondSets
    [fitVal,daysPlot] = FitLineForPlotting(allCorrs{csJ},allDays);
    plot(daysPlot,fitVal,'Color',colorsPlot{csJ},'LineWidth',2)
    %plot(meanLineDays,meanCorr(:,csJ),'Color',colorsPlot{csJ},'LineWidth',2)
    [statsOut.spearmanCorr.rho(csJ),statsOut.spearmanCorr.pVal(csJ)] = corr(allDays,allCorrs{csJ},'type','Spearman');
end

ylabel('Correlation')
xlabel('Recording Day')

xlim([min(allDays)-0.5 max(allDays)+0.5])


comps = combnk(1:numCondSets,2);
statsOut.comps = comps;
for compI = 1:size(comps,1)
    %daysCheck = unique(daysPooledAcrossMice{comps(compI,1)});
    %{
    [statsOut.signranks{compI}.pVal,statsOut.signranks{compI}.hVal,...
     stats,statsOut.signranks{compI}.whichWon,statsOut.signranks{compI}.eachDayPair] =...
     SignRankTestAllDayPairs(...
        withinCorrsPooledAcrossMice{comps(compI,1)},...
        withinCorrsPooledAcrossMice{comps(compI,2)},...
        daysPooledAcrossMice{comps(compI,1)});
    try
    statsOut.signranks{compI}.zVal = stats.zval;
    end
    %}
    try
    [statsOut.signrankall{compI}.pVal, statsOut.signrankall{compI}.hVal,...
        stats] = signrank(allAllCorrs{comps(compI,1)},allAllCorrs{comps(compI,2)});
    end
    [statsOut.ranksumall{compI}.pVal, statsOut.ranksumall{compI}.hVal,...
        stats] = ranksum(allAllCorrs{comps(compI,1)},allAllCorrs{comps(compI,2)});
    statsOut.ranksumall{compI}.zVal = stats.zval;
    
    
end
%}

end