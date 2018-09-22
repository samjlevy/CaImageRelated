function pctDailyTrait = TraitDailyPct(traitLogical,dayUse)

numToday = sum(traitLogical,1);
cellsToday = sum(dayUse,1);

pctDailyTrait = numToday./cellsToday;

end

