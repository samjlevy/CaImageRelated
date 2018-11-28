function  [Corrs,meanCorr,numCellsUsed,numNans] = PopVectorCorrsSlimTMaps(TMapA,TMapB,traitLogicalA,traitLogicalB,dayPairs,cellsUseOption,corrType)
%Expects each TMap to have cells, days, one condition

if isempty('corrType')
    corrType = 'Spearman';  
    disp('Using Spearman corr')
end

numCells = size(TMapA, 1);
numBins = length(TMapA{1});
numDays = size(TMapA,2);
numDayPairs = size(dayPairs,1);

%Pre-allocate
Corrs = cell(numDayPairs,1);
numNans = cell(numDayPairs,1);
meanCorr = cell(numDayPairs,1);
numCellsUsed = cell(numDayPairs,1);

for dpI = 1:numDayPairs
    %Get cells to use
    switch cellsUseOption
        case 'activeEither'
            cellsUse = traitLogicalA(:,dayPairs(dpI,1)) + traitLogicalB(:,dayPairs(dpI,2)) > 0;
        case 'activeBoth'
            cellsUse = traitLogicalA(:,dayPairs(dpI,1)) + traitLogicalB(:,dayPairs(dpI,2)) == 2;
        case 'includeSilent'
            cellsUse = true(numCells,1);
    end

    TRatesA = cell2mat(TMapA(cellsUse,dayPairs(dpI,1)));
    TRatesB = cell2mat(TMapB(cellsUse,dayPairs(dpI,2)));

    numCellsUsedHere = sum(cellsUse);

    numNansHere = 0;
    corrsHere = nan(1,numBins);
    meanCorrHere = NaN;
    if sum(cellsUse) > 1
        for binI = 1:numBins
            corrsHere(1,binI) = corr(TRatesA(:,binI),TRatesB(:,binI),'type',corrType);

            if any(isnan(corrsHere(1,binI)))
                numNansHere = numNansHere + 1;
            end
        end
        meanCorrHere = nanmean(corrsHere);
        if isnan(meanCorrHere)
            keyboard
        end
    else
        keyboard
    end
    
    Corrs{dpI} = corrsHere;
    numNans{dpI} = numNansHere;
    meanCorr{dpI} = meanCorrHere;
    numCellsUsed{dpI} = numCellsUsedHere;
    
end

end