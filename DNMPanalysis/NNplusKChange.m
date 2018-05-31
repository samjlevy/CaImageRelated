function [numChange, pctChange, dayPairs] = NNplusKChange(traitLogical, dayUse)
%This looks at the change in number of cells that satisfy trait logical
%from day N to day N plus X. Does not do any logical filtering, so if you
%want to filter by dayUse, do that to the input first.
%Day use is only included to get the change in pct. of active that day

numDays = size(traitLogical,2);
dayPairs = combnk(1:numDays,2);
numDayPairs = size(dayPairs,1);

numEachDay = sum(traitLogical,1);
numActiveEachDay = sum(dayUse,1);
pctEachDay = numEachDay ./ numActiveEachDay;

numChange = nan(numDayPairs,1);
pctChange = nan(numDayPairs,1);
for dpI = 1:numDayPairs
    numChange(dpI) = numActiveEachDay(dayPairs(dpI,2)) - numActiveEachDay(dayPairs(dpI,1));
    pctChange(dpI) = pctEachDay(dayPairs(dpI,2)) - pctEachDay(dayPairs(dpI,1));
end

end
