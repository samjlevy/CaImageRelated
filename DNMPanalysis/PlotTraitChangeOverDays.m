function [figHand,statsOut] = PlotTraitChangeOverDays(pooledTraitChanges,pooledDaysApart,comparisons,colorsUse,labels,figHand,ylims,yLabel)

if isnumeric(comparisons)
    numComps = size(comparisons,1);
    comparisons = mat2cell(comparisons,ones(numComps,1),size(comparisons,2));
elseif iscell(comparisons)
    numComps = length(comparisons);
end

for compI = 1:numComps
    subplot(1,numComps,compI)
    [statsOutTemp] = PlotTraitChangeOverDaysOne(pooledTraitChanges(comparisons{compI}),pooledDaysApart,...
        colorsUse(comparisons{compI}),labels(comparisons{compI}),yLabel,ylims);
    
    statsOut.slopeDiffComp{compI} = statsOutTemp.slopeDiffComp;
    statsOut.signtests{compI} = statsOutTemp.signtests;
    statsOut.rankSumAll{compI} = statsOutTemp.rankSumAll;
    statsOut.comps{compI} = statsOutTemp.comps;
    %{
    plot([0.5 max(pooledDaysApart)+0.5],[0 0],'k')
    hold on
    
    pp(1) = plot(pooledDaysApart-0.1,pooledTraitChanges{comparisons(compI,1)},'.',...
        'Color',colorsUse{comparisons(compI,1)},'MarkerSize',10,'DisplayName',labels{comparisons(compI,1)});
    pp(2) = plot(pooledDaysApart+0.1,pooledTraitChanges{comparisons(compI,2)},'.',...
        'Color',colorsUse{comparisons(compI,2)},'MarkerSize',10,'DisplayName',labels{comparisons(compI,2)});
    
    [fitVal,daysPlot] = FitLineForPlotting(pooledTraitChanges{comparisons(compI,1)},pooledDaysApart);
    plot(daysPlot,fitVal,'Color',colorsUse{comparisons(compI,1)},'LineWidth',2)
   
    [fitVal,daysPlot] = FitLineForPlotting(pooledTraitChanges{comparisons(compI,2)},pooledDaysApart);
    plot(daysPlot,fitVal,'Color',colorsUse{comparisons(compI,2)},'LineWidth',2)
    
    xlim([0.5 max(pooledDaysApart)+0.5])
    xlabel('Day Lag')
    ylim(ylims)
    ylabel(yLabel)
    
    title([labels{comparisons(compI,1)} ' vs ' labels{comparisons(compI,1)}])
    legend([pp(1) pp(2)])
    
    %Slopes different from each other?
    [statsOut.slopeDiffComp(compI).Fval,statsOut.slopeDiffComp(compI).dfNum,...
     statsOut.slopeDiffComp(compI).dfDen,statsOut.slopeDiffComp(compI).pVal] =...
        TwoSlopeFTest(pooledTraitChanges{comparisons(compI,1)},pooledTraitChanges{comparisons(compI,2)},...
                      pooledDaysApart,pooledDaysApart);
                  
    %Sign test each day
    [statsOut.signtests(compI).pVal,statsOut.signtests(compI).hVal,...
     statsOut.signtests(compI).whichWon,statsOut.signtests(compI).eachDayPair] =...
        SignTestAllDayPairs(pooledTraitChanges{comparisons(compI,1)},...
        pooledTraitChanges{comparisons(compI,2)},pooledDaysApart);
    
    %Rank sum all
    [statsOut.rankSumAll(compI).pVal, statsOut.rankSumAll(compI).hVal] = ...
        ranksum(pooledTraitChanges{comparisons(compI,1)},pooledTraitChanges{comparisons(compI,2)});
    %}
end

% Slopes of each of these lines
for tgI = 1:length(pooledTraitChanges)
    [~, ~, ~, statsOut.slopeRR(tgI), statsOut.slopePval(tgI), ~] =...
        fitLinRegSL(pooledTraitChanges{tgI}, pooledDaysApart);
    
    [statsOut.slopeDiffZero(tgI).Fval,statsOut.slopeDiffZero(tgI).dfNum,...
     statsOut.slopeDiffZero(tgI).dfDen,statsOut.slopeDiffZero(tgI).pVal] =...
        slopeDiffFromZeroFtest(pooledTraitChanges{tgI}, pooledDaysApart);
end

end