function [minCells,whichTL,whichDay] = FindMinNumCellOverlap(traitLogicalArr, dayPairs)%, dayPairs
%finds the minimum number of cells that satisfy each traitLogical across
%all day pairs

sizeArrs = cell2mat(cellfun(@size,traitLogicalArr,'UniformOutput',false)');
if sum(sum(diff(sizeArrs,1,1))) > 0
    disp('ERROR: a traitLogical is the wrong size')
end

numTLs = length(traitLogicalArr);
numDays = size(traitLogicalArr{1},2);
if isempty(dayPairs)
    dayPairs = GetAllCombs(1:numDays, 1:numDays);
end

numEachDay = cellfun(@(x) sum(x,1),traitLogicalArr,'UniformOutput',false);

minEachDay = cell2mat(cellfun(@min,numEachDay,'UniformOutput',false));

[minCells, whichTL] = min(minEachDay);
[~, whichDay] = min(numEachDay{whichTL});

%if isempty(dayPairs)
%    dayPairs = GetAllCombs(1:numDays, 1:numDays);
%end
end

activeCellsOverlap{dcI}{mouseI}(dpI,1) = sum(sum(traitLogicalUse{dcI}{mouseI}(:,cellSessPairs{mouseI}(dpI,:)),2)==2);