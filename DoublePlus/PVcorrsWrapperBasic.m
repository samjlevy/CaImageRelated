function [pvCorrs, meanCorr, numCellsUsed, numNans] = PVcorrsWrapperBasic(...
    cellTMap_unsmoothed,condPairs,dayPairs,traitLogical,cellsUseOption,corrType)

numCondPairs = size(condPairs,1);
numDayPairs = size(dayPairs,1);

for cpI = 1:numCondPairs
    for dpI = 1:numDayPairs
        
        trialReliA = traitLogical(:,dayPairs(dpI,1),condPairs(cpI,1));
        trialReliB = traitLogical(:,dayPairs(dpI,2),condPairs(cpI,2));
        
        TMapMinA = cellTMap_unsmoothed(:,dayPairs(dpI,1),condPairs(cpI,1));
        TMapMinB = cellTMap_unsmoothed(:,dayPairs(dpI,2),condPairs(cpI,2));
        
        [pvCorrs{dpI,cpI},meanCorr{dpI,cpI},numCellsUsed{dpI,cpI},numNans{dpI,cpI}] = ...
            PopVectorCorrsSmallTMaps(TMapMinA,TMapMinB,trialReliA,trialReliB,cellsUseOption,corrType);
    end
end

end