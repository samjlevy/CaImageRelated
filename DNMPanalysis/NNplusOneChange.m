function [numChange, pctChange] = NNplusOneChange(traitLogical, dayUse)
%This looks at the change in number of cells that satisfy trait logical
%from day N to day N plus X. Does not do any logical filtering, so if you
%want to filter by dayUse, do that to the input first.
%Day use is only included to get the change in pct. of active that day

numEachDay = sum(traitLogical,1);
numActiveEachDay = sum(dayUse,1);
pctEachDay = numEachDay ./ numActiveEachDay;

numChange = diff(numEachDay);
pctChange = diff(pctEachDay);

end
