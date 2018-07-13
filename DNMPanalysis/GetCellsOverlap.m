function [activeCellsOverlap, overlapWithModel, overlapWithTest] = GetCellsOverlap(traitLogicalOne, traitLogicalTwo, dayPairs)
%Looks at which cells overlap by dayPairs in tl1 and tl2. E.g., put in
%splittersLR in tl1 and cellSSI>0 in tl2

numDays = size(cellSSE,2);
if isempty(dayPairs)
    dayPairs = GetAllCombs(1:numDays, 1:numDays);
end


for dpI = 1:size(dayPairs,1)
    cellsInModel = traitLogicalOne(:,dayPairs(dpI,1));
    cellsInTest = traitLogicalTwo(:,dayPairs(dpI,2));
    
    numInModel(dpI,1) = sum(cellsInModel);
    numInTest(dpI,1) = sum(cellsInTest);
    
    activeCellsOverlap(dpI,1) = sum(sum([cellsInModel, cellsInTest],2) == 2);
    
    overlapWithModel(dpI,1) = activeCellsOverlap(dpI,1)/numInModel(dpI,1);
    overlapWithTest(dpI,1) = activeCellsOverlap(dpI,1)/numInTest(dpI,1);
end

