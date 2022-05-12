function [spatialCorrsR, spatialCorrsP,cellPairsUsed] = MakeSpatialCorrs1(tmaps,cellPairsTest,traitLogical)

nDays = size(traitLogical,2);
nCells = size(traitLogical,1);

for sessI = 1:nDays
    
    if ~isempty(cellPairsTest)
        cellPairsUsed{sessI} = cellPairsTest{sessI};
    else
        cellsActive = traitLogical(:,sessI); 
        cellPairsUsed{sessI} = nchoosek(find(cellsActive),2);
    end
        
    numCellPairsHere = size(cellPairsUsed{sessI},1);
    
    spatialCorrsR{sessI} = nan(numCellPairsHere,1);
    spatialCorrsP{sessI} = nan(numCellPairsHere,1);
    for cellPairI = 1:numCellPairsHere
        [spatialCorrsR{sessI}(cellPairI,1),spatialCorrsP{sessI}(cellPairI,1)] =...
            corr(tmaps{cellPairsUsed{sessI}(cellPairI,1),sessI},tmaps{cellPairsUsed{sessI}(cellPairI,2),sessI},'type','Spearman');
    end
    
    disp(['Done sess ' num2str(sessI)])
end

end