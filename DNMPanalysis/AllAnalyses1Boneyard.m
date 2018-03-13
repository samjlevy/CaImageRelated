%% Splitter Cells: ANOVA version
for mouseI = 1:numMice
    TMap_unsmoothed = [];
    load(fullfile(mainFolder,mice{mouseI},'PFsLin.mat'),'TMap_unsmoothed')
    cellTMap{mouseI} = TMap_unsmoothed;
end

condPairs = [1 2; 3 4; 1 3; 2 4]; %Study LvR, Test LvR, Left SvT, Right SvT

%Find out if a cell splits
for mouseI = 1:numMice
    [discriminationIndex{mouseI}, anov{mouseI}] = LookAtSplitters3(cellTMap{mouseI}, condPairs);
    
    cellSplitsAtAll{mouseI} = zeros(size(anov{mouseI}.p(:,:,1)));
    for cpI = 1:size(condPairs,1)
        thisCellSplits{mouseI}{cpI} = anov{mouseI}.p(:,:,cpI) < pThresh;
        cellSplitsAtAll{mouseI} = cellSplitsAtAll{mouseI} + thisCellSplits{mouseI}{cpI};
        
        cellsUse = logical(sum(threshAndConsec{mouseI}(:,:,condPairs(cpI,:)),3) > 0); %Activity thresholded
        numSplitters{mouseI}(cpI,1:numDays(mouseI)) = sum(thisCellSplits{mouseI}{cpI}.*cellsUse,1);
        pctSplitters{mouseI}(cpI,1:numDays(mouseI)) = numSplitters{mouseI}(cpI,:)./sum(cellsUse,1);
        
        thisCellSplits{mouseI}{cpI} = logical(thisCellSplits{mouseI}{cpI}.*dayUse{mouseI}); %Activity threshold. Probably fine here?
    end
    
end
 
%Get logical splitting kind
for mouseI = 1:numMice
    splittersLR{mouseI} = thisCellSplits{mouseI}{1} + thisCellSplits{mouseI}{2} > 0;
    splittersST{mouseI} = thisCellSplits{mouseI}{3} + thisCellSplits{mouseI}{4} > 0;

    [splittersLRonly{mouseI}, splittersSTonly{mouseI}, splittersBOTH{mouseI},...
        splittersOne{mouseI}, splittersNone{mouseI}] = ...
        GetSplittingTypes(splittersLR{mouseI}, splittersST{mouseI});
    
    cellsActiveToday{mouseI} = sum(dayUse{mouseI},1);
    splitterProps{mouseI} = [sum(splittersNone{mouseI},1)./cellsActiveToday{mouseI};... %None
                             sum(splittersLRonly{mouseI},1)./cellsActiveToday{mouseI};... %LR only
                             sum(splittersSTonly{mouseI},1)./cellsActiveToday{mouseI};... %ST only
                             sum(splittersBOTH{mouseI},1)./cellsActiveToday{mouseI}]; %Both only
end


%Daily splitter ranges
for mouseI = 1:numMice
    numDailySplittersLR{mouseI} = sum(splittersLR{mouseI},1);
    rangeDaliSplittersLR(mouseI,:) = [mean(numDailySplittersLR{mouseI}) standarderrorSL(numDailySplittersLR{mouseI})];
    pctDailySplittersLR{mouseI} = stuff;
end

%Evaluate splitting: days bias numbers and center of mass per cell
for mouseI = 1:numMice
    [splitterLR{mouseI}, splitterST{mouseI}, splitterBOTH{mouseI}] =...
        SplitterCenterOfMass(dayUse, splittersLR, splittersST, splittersBOTH);  
end