function [firstDay] = GetFirstDayTrait(traitLogical)

numCells = size(traitLogical,1);

firstDay = nan(numCells,1);
for cellI = 1:numCells
    firstDayHere = [];
    firstDayHere = find(traitLogical(cellI,:),1,'first');
    if any(firstDayHere)
        firstDay(cellI,1) = firstDayHere;
    end
end

end