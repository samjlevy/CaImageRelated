function [figHand,statsOut] = PlotTraitChangeOverDays(pooledTraitChanges,pooledDaysApart,comparisons,colorsUse,labels,figHand)

numComps = size(comparisons,1);
for compI = 1:numComps
    subplot(1,numComps,compI)
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
    ylim([-0.6 0.6])
    ylabel('Pct. Change')
    
    title([labels{comparisons(compI,1)} ' vs ' labels{comparisons(compI,1)}])
    legend([pp(1) pp(2)])
    
    %Slopes differenf from each other?
    [statsOut.slopeDiffComp(compI).Fval,statsOut.slopeDiffComp(compI).dfNum,...
     statsOut.slopeDiffComp(compI).dfDen,statsOut.slopeDiffComp(compI).Pval] =...
        TwoSlopeFTest(pooledTraitChanges{comparisons(compI,1)},pooledTraitChanges{comparisons(compI,2)},...
                      pooledDaysApart,pooledDaysApart);
                  
    %Sign test each day
    [statsOut.signtests.pVal{compI},statsOut.signtests.hVal{compI},...
     statsOut.signtests.whichWon{compI},statsOut.signtests.eachDayPair{compI}] =...
        SignTestAllDayPairs(pooledTraitChanges{comparisons(compI,1)},...
        pooledTraitChanges{comparisons(compI,2)},pooledDaysApart);
end

% Slopes of each of these lines
for tgI = 1:length(pooledTraitChanges)
    [~, ~, ~, statsOut.slopeRR(tgI), statsOut.slopePval(tgI), ~] =...
        fitLinRegSL(pooledTraitChanges{tgI}, pooledDaysApart);
    
    [statsOut.slopeDiffZero(tgI).Fval,statsOut.slopeDiffZero(tgI).dfNum,...
     statsOut.slopeDiffZero(tgI).dnDen,statsOut.slopeDiffZero(tgI).pVal] =...
        slopeDiffFromZeroFtest(pooledTraitChanges{tgI}, pooledDaysApart);
end

end