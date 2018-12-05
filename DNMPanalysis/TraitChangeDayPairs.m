function traitChange = TraitChangeDayPairs(traitPcts,dayPairs)

for dpI = 1:size(dayPairs)
    traitChange(dpI,1) = traitPcts(dayPairs(dpI,2)) - traitPcts(dayPairs(dpI,1));
end

end