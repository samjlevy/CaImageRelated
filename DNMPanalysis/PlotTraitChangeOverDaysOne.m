function [statsOut] = PlotTraitChangeOverDaysOne(pooledTraitChanges,pooledDaysApart,colorsHere,labels,yLabel,ylims)

numConds = length(pooledTraitChanges);

plot([0.5 max(pooledDaysApart)+0.5],[0 0],'k')
hold on

pp = [];
csMod = linspace(1,numConds,numConds); csMod = (csMod - mean(csMod))/10;
for condI = 1:numConds
    pp(condI) = plot(pooledDaysApart+csMod(condI),pooledTraitChanges{condI},'.',...
        'Color',colorsHere{condI},'MarkerSize',10,'DisplayName',labels{condI});
    
    [fitVal,daysPlot] = FitLineForPlotting(pooledTraitChanges{condI},pooledDaysApart);
    plot(daysPlot,fitVal,'Color',colorsHere{condI},'LineWidth',2)
   
    xlim([0.5 max(pooledDaysApart)+0.5])
    xlabel('Day Lag')
    ylim(ylims)
    ylabel(yLabel)
    
    %title([labels{comparisons(compI,1)} ' vs ' labels{comparisons(compI,1)}])
    legend(pp)
end

comps = combnk(1:numConds,2);
for compI = 1:size(comps,1)
    %Slopes different from each other?
    [statsOut.slopeDiffComp(compI).Fval,statsOut.slopeDiffComp(compI).dfNum,...
     statsOut.slopeDiffComp(compI).dfDen,statsOut.slopeDiffComp(compI).pVal] =...
        TwoSlopeFTest(pooledTraitChanges{comps(compI,1)},pooledTraitChanges{comps(compI,2)},...
                      pooledDaysApart,pooledDaysApart);
                  
    %Sign test each day
    [statsOut.signtests(compI).pVal,statsOut.signtests(compI).hVal,...
     statsOut.signtests(compI).whichWon,statsOut.signtests(compI).eachDayPair] =...
        SignTestAllDayPairs(pooledTraitChanges{comps(compI,1)},...
        pooledTraitChanges{comps(compI,2)},pooledDaysApart);
    
    %Rank sum all
    [statsOut.rankSumAll(compI).pVal, statsOut.rankSumAll(compI).hVal] = ...
        ranksum(pooledTraitChanges{comps(compI,1)},pooledTraitChanges{comps(compI,2)});
    statsOut.rankSumAll(compI).whichWon = WhichWonRanks(pooledTraitChanges{comps(compI,1)},pooledTraitChanges{comps(compI,2)});
    
    for aa = 1:2
        [~, ~, ~, statsOut.slope(compI).slopeRR(aa), statsOut.slope(compI).slopePval(aa), ~] =...
            fitLinRegSL(pooledTraitChanges{comps(compI,aa)}, pooledDaysApart);
    
        [statsOut.slope(compI).slopeDiffZero(aa).Fval,statsOut.slope(compI).slopeDiffZero(aa).dfNum,...
         statsOut.slope(compI).slopeDiffZero(aa).dfDen,statsOut.slope(compI).slopeDiffZero(aa).pVal] =...
            slopeDiffFromZeroFtest(pooledTraitChanges{comps(compI,aa)}, pooledDaysApart);
    end
end
statsOut.comps = comps;
end