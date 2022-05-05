function [pvCorrs, meanCorr, numCellsUsed, numNans] = PVcorrsWrapperMedium(...
    cellTMap_unsmoothed,condPairs,dayPairs,traitLogical,cellsUseOption,corrType,binComb)
% This version allows more multi-level control over cells included; add
% more qualifiers as cells in traitLogical, correspondingly how to use them
% with cellsUseOption
if ~iscell(traitLogical)
    tl = traitLogical; 
    traitLogical = cell(1);
    traitLogical{1} = tl;
end
if ~iscell(cellsUseOption)
    tl = cellsUseOption; 
    cellsUseOption = cell(1);
    cellsUseOption{1} = tl;
end
nTls = numel(traitLogical);

for tlI = 1:nTls


numCondPairs = size(condPairs,1);
numDayPairs = size(dayPairs,1);
numCells = size(cellTMap_unsmoothed,1);

pvCorrs = cell(numDayPairs,numCondPairs);

for cpI = 1:numCondPairs
    for dpI = 1:numDayPairs
        cellsUseHere = true(numCells,1);
        
        for tlI = 1:nTls
             traitLogicalA = traitLogical{tlI}(:,dayPairs(dpI,1),condPairs(cpI,1));
             traitLogicalB = traitLogical{tlI}(:,dayPairs(dpI,2),condPairs(cpI,2));
             
             switch cellsUseOption{tlI}
                case 'activeEither'
                    cellsUse = traitLogicalA + traitLogicalB > 0;
                case 'activeBoth'
                    cellsUse = traitLogicalA + traitLogicalB == 2;
             end
            
             cellsUseHere = cellsUseHere & cellsUse;
        end
               
            
        trialReliA = cellsUseHere; trialReliB = cellsUseHere;
        if sum(trialReliA)==0
            disp(['For cond pair ' num2str(cpI) ', dayPair ' num2str(dpI) ', no cells, skipping'])
        else
        
        TMapMinA = cellTMap_unsmoothed(:,dayPairs(dpI,1),condPairs(cpI,1));
        TMapMinB = cellTMap_unsmoothed(:,dayPairs(dpI,2),condPairs(cpI,2));
        
        [pvCorrs{dpI,cpI},meanCorr{dpI,cpI},numCellsUsed{dpI,cpI},numNans{dpI,cpI}] = ...
            PopVectorCorrsSmallTMaps(TMapMinA,TMapMinB,trialReliA,trialReliB,'activeBoth',corrType,binComb);
        
        end
    end
end

end