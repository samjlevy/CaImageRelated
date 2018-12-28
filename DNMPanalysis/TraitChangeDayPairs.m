function [traitChange, pctChange] = TraitChangeDayPairs(traitPcts,dayPairs)
%Could be pcts, or a difference between some other traits or correlations

for dpI = 1:size(dayPairs,1)
    traitChange(dpI,1) = traitPcts(dayPairs(dpI,2)) - traitPcts(dayPairs(dpI,1));
    pctChange(dpI,1) = traitChange(dpI,1)/traitPcts(dayPairs(dpI,1)); 
end

end