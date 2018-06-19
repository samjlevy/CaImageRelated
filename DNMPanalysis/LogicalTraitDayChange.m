function [traitEntrance, changeNums, changePct] = LogicalTraitDayChange(traitLogical, dayUse)
%Within cell

numCells = size(dayUse,1);
numSess = size(dayUse,2);
%numConds = size(traitLogical, ??);

daysHere = sum(dayUse,2);

traitEntrance = zeros(numCells,1);
for cellI = 1:numCells
    if daysHere(cellI) > 1
        cellTrait = traitLogical(cellI,:);
        cellHere = logical(dayUse(cellI,:));

        traitEntrance(cellI) = sum(diff(cellTrait(cellHere)));
    end
end

%Coming   no change/middle    leaving
changeNums = [sum(traitEntrance(daysHere>1))>1, sum(traitEntrance(daysHere>1)==0),...
                  sum(traitEntrance(daysHere>1))<1];
changePct = changeNums/sum(daysHere>1);

end



%{
%for condI = 1:numConds
for cellI = 1:numCells
    daysHere = find(dayUse(cellI,:));
    logicalHere = traitLogical(cellI,:);
    daysLogical = find(logicalHere);
    if any(daysHere)
        for dhI = 1:length(daysHere)
            if daysHere(dhI) < numSess
                daynnchange = daysLogical(daysHere(dhI+1)) - daysLogical(daysHere(dhI));
                (cellI) = (cellI) + daynnchange;
                
        
    
    
  %}  