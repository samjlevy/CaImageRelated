function [fitVal,daysPlot] = FitLineForPlotting(values,days)

[~,~,fitLine, ~, ~, ~] = fitLinRegSL(values,days);

daysPlot = unique(fitLine(:,1));
    
for ddI = 1:length(daysPlot)
    fitVal(ddI) = fitLine(find(days==daysPlot(ddI),1,'first'),2);
end

end