function [DI, anov] = LookAtSplitters3(TMap_unsmoothed, condPairs)
%Use condpairs to indicated which pairs of conditions to compare, where
%each row is a pair, each column entry is a condition to compare.

numCells = size(TMap_unsmoothed, 1);
numDays = size(TMap_unsmoothed, 3);
numBins = length(TMap_unsmoothed{1,1,1});

numCondPairs = size(condPairs,1);

DI = nan(numCells,numDays,numCondPairs);
anov.p = nan(numCells,numDays,numCondPairs);
anov.F = nan(numCells,numDays,numCondPairs);
for dayI = 1:numDays
    for cpI = 1:numCondPairs
        for cellI = 1:numCells
            fr1 = TMap_unsmoothed{cellI,condPairs(cpI,1),dayI};
            fr2 = TMap_unsmoothed{cellI,condPairs(cpI,2),dayI};
            
            if any(fr1) || any(fr2)
                DI(cellI, dayI, cpI) =...
                    (mean(fr2) - mean(fr1)) / (mean(fr2) + mean(fr1));
                
                firingActivity = [fr1 fr2]';
                groupLabel = [zeros(numBins,1); ones(numBins,1)];
                binLabel = [1:numBins 1:numBins]';
                [p, tbl] = anovan(firingActivity, [groupLabel binLabel],...
                    'varnames',{'Condition','spatBin'},'display','off'); 
                anov.p(cellI, dayI, cpI) = p(1);
                anov.F(cellI, dayI, cpI) = tbl{2,7};
            end
        end
    end
end

end