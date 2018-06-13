function [minCells,whichTL,whichDay] = FindCellNumTraitLogical(traitLogicalArr)

sizeArrs = cell2mat(cellfun(@size,traitLogicalArr,'UniformOutput',false)');
if sum(sum(diff(sizeArrs,1,1))) > 0
    disp('ERROR: a traitLogical is the wrong size')
end

numTLs = length(traitLogicalArr);
numDays = size(traitLogicalArr{1},2);

minEachDay = cellfun(@(x) min(x,[],1),traitLogicalArr,'UniformOutput',false);


