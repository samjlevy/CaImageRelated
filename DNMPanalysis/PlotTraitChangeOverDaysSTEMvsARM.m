function [figHand,statsOut] = PlotTraitChangeOverDaysSTEMvsARM(pooledTraitChangesSTEM,pooledDaysApartSTEM,pooledTraitChangesARM,...
    pooledDaysApartARM,colorsUse,labels,figHand,ylims,yLabel)

numTgs = length(pooledTraitChangesSTEM);
subRows = ceil(numTgs/3);

for tgI = 1:numTgs
    subplot(subRows,3,tgI)
    
    colorHere = colorsUse{tgI};
    colorsUseHereA = colorHere+0.15; colorsUseHereA(colorsUseHereA > 1)=1;
    colorsUseHereB = colorHere-0.15; colorsUseHereB(colorsUseHereB < 0)=0;
    colorsUseHere = {colorsUseHereA; colorsUseHereB};
    labelsHere = {[labels{tgI} '-STEM']; [labels{tgI} '-ARM']};
    
    [statsOutTemp] = PlotTraitChangeOverDaysOne({pooledTraitChangesSTEM{tgI} pooledTraitChangesARM{tgI}},...
        pooledDaysApartSTEM,colorsUseHere,labelsHere,yLabel,ylims);
    
    statsOut.slopeDiffComp(tgI) = statsOutTemp.slopeDiffComp;
    statsOut.signtests(tgI) = statsOutTemp.signtests;
    statsOut.rankSumAll(tgI) = statsOutTemp.rankSumAll;
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
for tgI = 1:numTgs
    [~, ~, ~, statsOut.stem.slopeRR(tgI), statsOut.stem.slopePval(tgI), ~] =...
        fitLinRegSL(pooledTraitChangesSTEM{tgI}, pooledDaysApartSTEM);
    
    [statsOut.stem.slopeDiffZero(tgI).Fval,statsOut.stem.slopeDiffZero(tgI).dfNum,...
     statsOut.stem.slopeDiffZero(tgI).dfDen,statsOut.stem.slopeDiffZero(tgI).pVal] =...
        slopeDiffFromZeroFtest(pooledTraitChangesSTEM{tgI}, pooledDaysApartSTEM);
    
    [~, ~, ~, statsOut.arm.slopeRR(tgI), statsOut.arm.slopePval(tgI), ~] =...
        fitLinRegSL(pooledTraitChangesARM{tgI}, pooledDaysApartARM);
    
    [statsOut.arm.slopeDiffZero(tgI).Fval,statsOut.arm.slopeDiffZero(tgI).dfNum,...
     statsOut.arm.slopeDiffZero(tgI).dfDen,statsOut.arm.slopeDiffZero(tgI).pVal] =...
        slopeDiffFromZeroFtest(pooledTraitChangesARM{tgI}, pooledDaysApartARM);
end

end