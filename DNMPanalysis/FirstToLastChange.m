function [numChange, pctChange, totalNumChange] = FirstToLastChange(traitLogical, dayUse, dayPairsUse)
%This looks at the change in number of cells that satisfy trait logical
%from day day one to last day. Does not do any logical filtering, so if you
%want to filter by dayUse, do that to the input first.
%Day use is only included to get the change in pct. of active that day
%Use numDaysUse to indicated how many days on either end to mean across

dayPairs = dayPairsUse;
numDays = size(traitLogical,2);
if isempty(dayPairsUse)
    numDaysUse = 1;
    dayPairs = [1:0+numDaysUse; numDays-(numDaysUse-1):numDays];
end

numEachDay = sum(traitLogical,1);
numActiveEachDay = sum(dayUse,1);
pctEachDay = numEachDay ./ numActiveEachDay;

numChange = mean(numEachDay(dayPairs(2,:))) - mean(numEachDay(dayPairs(1,:)));
pctChange = mean(pctEachDay(dayPairs(2,:))) - mean(pctEachDay(dayPairs(1,:)));
totalNumChange = sum(numEachDay(dayPairs(2,:)))/sum(numActiveEachDay(dayPairs(2,:)))/ - sum(numEachDay(dayPairs(1,:)))/sum(numActiveEachDay(dayPairs(1,:)));

end
