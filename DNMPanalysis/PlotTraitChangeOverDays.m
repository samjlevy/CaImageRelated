function [figHand,statsOut] = PlotTraitChangeOverDays(pooledTraitChanges,pooledDaysApart,comparisons,colorsUse,labels,figHand)

numComps = size(comparisons(1));
for compI = 1:numComps
    subplot(1,numComps,compI)
    plot(pooledDaysApart-0.1,pooledTraitChanges{comparisons(compI,1)},'.',...
        'Color',colorsUse{comparisons(compI,1)},'MarkerSize',10)
    hold on
    plot(pooledDaysApart+0.1,pooledTraitChanges{comparisons(compI,2)},'.',...
        'Color',colorsUse{comparisons(compI,2)},'MarkerSize',10)
    
    [fitVal,daysPlot] = FitLineForPlotting(pooledTraitChanges{comparisons(compI,1)},pooledDaysApart);
    plot(daysPlot,fitVal,'Color',colorsUse{comparisons(compI,1)},'LineWidth',2)
   
    [fitVal,daysPlot] = FitLineForPlotting(pooledTraitChanges{comparisons(compI,2)},pooledDaysApart);
    plot(daysPlot,fitVal,'Color',colorsUse{comparisons(compI,2)},'LineWidth',2)
    
    xlim
    ylabel
    xlabel
    
    title([labels{comparisons(compI,1)} ' vs ' labels{comparisons(compI,1)}])
    legend(traitLabels{pcIndsHere(1)},traitLabels{pcIndsHere(2)})
    
    
    
    %Slopes differenf from each other?
    [Fval(pcI),dfNum(pcI),dfDen(pcI),pVal(pcI)] = TwoSlopeFTest(pooledSplitPctChangeFWD{pairsCompareInd(pcI,1)},...
                                                pooledSplitPctChangeFWD{pairsCompareInd(pcI,2)},pooledDaysApartFWD,pooledDaysApartFWD);
    statsOut.slopeDiffComp(compI).Fval
    statsOut.slopeDiffComp(compI).dfNum
    statsOut.slopeDiffComp(compI).dfDen
    statsOut.slopeDiffComp(compI).Pval
end

% Slopes of each of these lines
for tgI = 1:length(pooledTraitChanges)
    %Here's the slope of each line
    statsOut.slopePval(tgI)
    statsOut.slopeDiffZero(tgI).Fval
    statsOut.slopeDiffZero(tgI).dfNum
    statsOut.slopeDiffZero(tgI).dnDen
    statsOut.slopeDiffZero(tgI).pVal
    
    
    [splitDiffZFval{tgI},splitDiffZdfNum{tgI},splitDiffZdfDen{tgI},splitDiffZpVal{tgI}] = slopeDiffFromZeroFtest(pooledSplitPctChangeFWD{tgI}, pooledDaysApartFWD);
end



end




