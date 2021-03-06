function [minCells,whichTL,whichDay] = FindCellNumTraitLogical(traitLogicalArr)%, dayPairs

sizeArrs = cell2mat(cellfun(@size,traitLogicalArr,'UniformOutput',false)');
if sum(sum(diff(sizeArrs,1,1))) > 0
    disp('ERROR: a traitLogical is the wrong size')
end

numTLs = length(traitLogicalArr);
numDays = size(traitLogicalArr{1},2);

numEachDay = cellfun(@(x) sum(x,1),traitLogicalArr,'UniformOutput',false);

minEachDay = cell2mat(cellfun(@min,numEachDay,'UniformOutput',false));

[minCells, whichTL] = min(minEachDay);
[~, whichDay] = min(numEachDay{whichTL});

%if isempty(dayPairs)
%    dayPairs = GetAllCombs(1:numDays, 1:numDays);
%end
end

