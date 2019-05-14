function [axHand,statsOut] = PlotPVcurvesDayDiffs(CSpooledPVcorrs,CSpooledPVdaysApart,binsUse,dayDiffMin,condSetColors,condSetLabels,plotRaw,axHand)
%Plots all day pairs

%Deal with too long day pairs
global dayLagLimit
if any(dayLagLimit)
    for csI = 1:length(CSpooledPVcorrs)
        badDayLags = CSpooledPVdaysApart{csI} > dayLagLimit;
        CSpooledPVcorrs{csI}(badDayLags,:) = [];
        CSpooledPVdaysApart{csI}(badDayLags,:) = [];
    end
end

if any(dayDiffMin)
    for csI = 1:length(CSpooledPVcorrs)
        badDayLags = CSpooledPVdaysApart{csI} < dayDiffMin;
        CSpooledPVcorrs{csI}(badDayLags,:) = [];
        CSpooledPVdaysApart{csI}(badDayLags,:) = [];
    end
end

minDays = min(cell2mat(cellfun(@min,CSpooledPVdaysApart,'UniformOutput',false)));
maxDays = max(cell2mat(cellfun(@max,CSpooledPVdaysApart,'UniformOutput',false)));

%Mean to just the bins we want
for csI = 1:length(CSpooledPVcorrs)
    CSpooledPVcorrs{csI} = nanmean(CSpooledPVcorrs{csI}(:,binsUse),2);
end

%Rest of the plotting
if isempty(axHand)
    figure;
    axHand = axes;
end

numConds = length(CSpooledPVcorrs);
%numDays = unique(;

csOffset = [];
if isempty(plotRaw)
    plotDots = false;
else
    if length(plotRaw) == 2
        csOffset = plotRaw{2};
        plotDots = plotRaw{1};
    else
        plotDots = plotRaw;
    end
end

if isempty(csOffset)
    csMod = linspace(1,numConds,numConds); csMod = (csMod - mean(csMod))/7;
else
    csMod = (1:numConds)*csOffset; csMod = csMod - mean(csMod);
end

plot([minDays-0.5 maxDays+0.5],[0 0],'k'); hold on
for csI = 1:length(condSetColors)
    for dayI = minDays:maxDays
        daysUse = CSpooledPVdaysApart{csI}==dayI;
        errorLine(csI,dayI) = standarderrorSL(CSpooledPVcorrs{csI}(daysUse));
        meanLine(csI,dayI) = nanmean(CSpooledPVcorrs{csI}(daysUse));
        if plotDots == true
            scatter(dayI+csMod(csI)*ones(sum(daysUse),1),CSpooledPVcorrs{csI}(daysUse),'filled',...
                'MarkerFaceColor',condSetColors{csI},'SizeData',20,'MarkerFaceAlpha',0.4);
        end
        
        [statsOut.eachCond{csI}.diffFromZeroSign(dayI).pVal,statsOut.eachCond{csI}.diffFromZeroSign(dayI).hVal,stt]=...
            signtest(CSpooledPVcorrs{csI}(daysUse));
        try 
            statsOut.eachCond{csI}.diffFromZeroSign(dayI).zVal = stt.zval; 
        catch
            statsOut.eachCond{csI}.diffFromZeroSign(dayI).zVal = []; 
        end
    end
end  
    
pp = [];
for csI = 1:length(condSetColors)
    pp(csI) = errorbar(minDays:maxDays,meanLine(csI,:),errorLine(csI,:),'Color',condSetColors{csI},'LineWidth',2);
end

if ~isempty(condSetLabels)
    legend(pp,condSetLabels,'location','southwest')
end

xlim([minDays-0.5 maxDays+0.5])
xlabel('Day Difference')
ylabel('Correlation')

comparisons = combnk(1:length(condSetColors),2);
statsOut.comparisons = comparisons;
for compI = 1:size(comparisons,1)
    for dayI = minDays:maxDays
        withinDayA = CSpooledPVdaysApart{comparisons(compI,1)}==dayI;
        withinDayB = CSpooledPVdaysApart{comparisons(compI,2)}==dayI;
    
        datA = CSpooledPVcorrs{comparisons(compI,1)}(withinDayA);
        datB = CSpooledPVcorrs{comparisons(compI,2)}(withinDayB);
        try
            [p,h,stats] = signrank(datA,datB);
            statsOut.signranktests{compI}(dayI).pVal = p;
            statsOut.signranktests{compI}(dayI).hVal = h;
            statsOut.signranktests{compI}(dayI).zVal = [];
            try
                statsOut.signranktests{compI}(dayI).zVal = stats.zval;
            end
        end
        [statsOut.ranksumtests{compI}(dayI).pVal,statsOut.ranksumtests{compI}(dayI).hVal,sstats]=...
            ranksum(datA,datB);
        statsOut.ranksumtests{compI}(dayI).zVal = [];
        try statsOut.ranksumtests{compI}(dayI).zVal = sstats.zval; end
    end
end


end