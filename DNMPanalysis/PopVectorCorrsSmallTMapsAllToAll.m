function  [Corrs,meanCorr,numCellsUsed,numNans] = PopVectorCorrsSmallTMapsAllToAll(TMapA,TMapB,traitLogicalA,traitLogicalB,cellsUseOption,corrType)
%Expects small tmaps to be 1 column of the tmaps for each cell on 1 day in
%one condition

if isempty('corrType')
    corrType = 'Spearman';  
    disp('Using Spearman corr')
end

%binComb = 'self';
binComb = 'allToAll';

numCells = size(TMapA, 1);
numBins = length(TMapA{1});

switch cellsUseOption
    case 'activeEither'
        cellsUse = traitLogicalA + traitLogicalB > 0;
    case 'activeBoth'
        cellsUse = traitLogicalA + traitLogicalB == 2;
    case 'includeSilent'
        cellsUse = true(numCells,1);
end

TRatesA = cell2mat(TMapA(cellsUse));
TRatesB = cell2mat(TMapB(cellsUse));


numCellsUsed = sum(cellsUse);

numNans = 0;
Corrs = nan(1,numBins);
meanCorr = NaN;
if sum(cellsUse) > 1
    switch binComb
        case 'self'
            for binI = 1:numBins
                Corrs(1,binI) = corr(TRatesA(:,binI),TRatesB(:,binI),'type',corrType);

                if any(isnan(Corrs(1,binI)))
                    numNans = numNans + 1;
                    Corrs(1,binI) = 0;
                end
            end
        if sum(sum(TRatesA))==0 || sum(sum(TRatesB))==0
            numNans = 100;
        end
        case 'allToAll'
            Corrs = nan(1,numBins);
            for binI = 1:numBins
                for binJ = 1:numBins
                    Corrs(binJ,binI) = corr(TRatesA(:,binI),TRatesB(:,binJ),'type',corrType);
                end
                if any(isnan(Corrs(1,binI)))
                    numNans = numNans + 1;
                    Corrs(1,binI) = 0;
                end
            end
    end
    meanCorr = nanmean(Corrs);
    %if isnan(meanCorr)
    %    keyboard
    %end
else
    keyboard
end

end