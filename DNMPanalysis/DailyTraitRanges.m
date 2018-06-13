function [numDaily, daysTrait, rangeDaily, pctDaily, rangePctDaily, traitAllDays] = ...
    DailyTraitRanges(traitLogical, traitDayBias, dayUse)

cellsActiveToday = sum(dayUse,1);

numDaily = sum(traitLogical,1);
daysTrait = sum(traitLogical,2);
rangeDaily = [ mean(numDaily) standarderrorSL(numDaily)];
pctDaily = numDaily./cellsActiveToday;
rangePctDaily = [mean(pctDaily) standarderrorSL(pctDaily)];
traitAllDays = traitDayBias/sum(sum(dayUse,2) > 1);

end
    