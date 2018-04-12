function reactivates = TraitReactivation(dayUse,traitLogical)
%Row 1 is number, row 2 is proportion

%numCells = size(traitLogical,1);
numSess = size(traitLogical,2);

for dayI = 1:numSess-1
    dayLogical = traitLogical(:,dayI);
    reactivates(1,dayI) = sum(dayUse(dayLogical,dayI+1));
    reactivates(2,dayI) = sum(dayUse(dayLogical,dayI+1)) / sum(dayLogical);
end

end