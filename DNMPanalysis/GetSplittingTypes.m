function [splittersLRonly, splittersSTonly, splittersBoth, splittersOne, splittersNone] = ...
    GetSplittingTypes(splittersLR, splittersST, dayUse)

splittersLRonly = splittersLR; splittersLRonly(splittersST==1) = 0;
splittersSTonly = splittersST; splittersSTonly(splittersLR==1) = 0;
splittersBoth = (splittersLR + splittersST) == 2;
splittersOne = (splittersLR + splittersST) == 1;
splittersNone = dayUse; splittersNone(splittersLR | splittersST) = 0;
    
end