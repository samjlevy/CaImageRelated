function [figHandOut,statsOut] = PlotChangeByDaysApartFWDonly(traitChange,dayDiffs,plotColors,condLabels,figHand)

if isempty(figHand)
    figHandOut = figure;
else
    figHandOut = figHand;
end
%offset = [-0.1 0 0.1];
condSetComps = combnk(1:length(traitChange),2);
numConds = length(traitChange);
offset = linspace(1,numConds,numConds); offset = (offset - mean(offset))/10;
plot([0 max(dayDiffs)+0.75],[0 0],'k')  
for csI = 1:numConds
    [~,~,~,DiffZeropVal(csI)] = slopeDiffFromZeroFtest(traitChange{csI},dayDiffs);
    plot(dayDiffs+offset(csI),traitChange{csI},'.','Color',plotColors{csI});
    hold on
end
for csI = 1:numConds
    [plotReg,daysPlot] = FitLineForPlotting(traitChange{csI},dayDiffs);
    pp{csI} = plot(daysPlot,plotReg,'Color',plotColors{csI},'LineWidth',2,...
        'DisplayName',[condLabels{csI} ', p = ' num2str(DiffZeropVal(csI))]);
end
for cscI = 1:size(condSetComps,1)
    [~,~,~,twoSlopepVal(cscI)] = TwoSlopeFTest(traitChange{condSetComps(cscI,1)}, traitChange{condSetComps(cscI,2)},...
        dayDiffs, dayDiffs);
    titleText{cscI,1} = [plotColors{condSetComps(cscI,1)} ' vs ' plotColors{condSetComps(cscI,2)} ': p = ' num2str(twoSlopepVal(cscI))];
end

statsOut.DiffZeropVal = DiffZeropVal;
statsOut.twoSlopepVal = twoSlopepVal;

legend([pp{:}],'Location','ne')
title(titleText)
end