function [Corrs, sigMat] = PopVectorCorrsWrapper1(TMap_unsmoothed, shuffleFolder,...
    traitLogical, cellsUse, corrType, condPairs, dayPairs, pThresh, sigTails)

[Corrs{mouseI}, numCellsUsed{mouseI}, dayPairs{mouseI}, condPairs{mouseI}] =...
        PopVectorCorrs1(TMap_unsmoothed,traitLogical, 'activeEither', corrType, condPairs, dayPairs);


numCondPairs = size(condPairs,1);

corrsReorgSorted = PopVectorCorrsSig1(shuffleFolder, traitLogical, cellsUse,...
    corrType, condPairs, dayPairs);

numShuffles = size(corrsReorgSorted{1},3);

pBounds = round([numShuffles*(1 - pThresh/2) numShuffles*(pThresh/2)]); %Outside of shuffles
pInd = round(numShuffles*pThresh); %assumes lower than shuffles

for cpI = 1:numCondPairs
    upper975 = corrsReorgSorted{cpI}(:,:,pBounds(1));
    aboveBounds = squeeze(Corrs(:,cpI,:)) > upper975;
    
    lower975 = corrsReorgSorted{cpI}(:,:,pBounds(2));
    belowBounds = squeeze(Corrs(:,cpI,:)) < lower975;
    
    exceedsP{cpI} = aboveBounds | belowBounds;
    
    lower95 = corrsReorgSorted{cpI}(:,:,pInd);
    belowP{cpI} = squeeze(Corrs(:,cpI,:)) < lower95;
end

switch sigTails 
    case {'two','twoTails'}
        sigMat = exceedsP;
    case {'one','oneTail'}
        sigMat = belowP;
    case 'useAll'
        sigMat = cell(size(exceedsP));
        %set to all 1s
end
       
%Sort by days apart
for mouseI = 1:numMice
    daysApart{mouseI} = diff(dayPairs{mouseI},1,2);
    sameDays = find(daysApart{mouseI} == 0);
    cc = cell2mat(struct2cell(Conds));
    for condI = 1:size(cc,1)
        cpUse(condI) = find(condPairs{mouseI}(:,1)==cc(condI,1) & condPairs{mouseI}(:,2)==cc(condI,2)); 
    end
    WithinDayCorrs{mouseI} = Corrs{mouseI}(sameDays,cpUse,:);
    
end
    
%Real days apart
for mouseI = 1:numMice
    actualDayPairs{mouseI} = cellRealDays{mouseI}(dayPairs{mouseI});
    actualDaysApart{mouseI} = diff(actualDayPairs{mouseI},1,2);
end