function LogicalTraitDayChange(traitLogical, dayUse)

numCells = size(dayUse,1);
numSess = size(dayUse,2);
%numConds = size(traitLogical, ??);

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
                
        
    
    
    