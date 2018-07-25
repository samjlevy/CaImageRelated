function all_PSAbool_aligned = PoolPSA2(all_PSAbool, sortedSessionInds)

numCells = size(sortedSessionInds,1);
numSess = size(sortedSessionInds,2);

sessRowLogical = sortedSessionInds > 0;

for sessI = 1:numSess    
    dummyRow = false(1,size(all_PSAbool{sessI},2));
    
    %all_PSAbool_aligned{sessI} = false(numCells,size(all_PSAbool{sessI},2));
    
    numCellsHere = size(all_PSAbool{sessI},1);
    all_PSAbool{sessI}(numCellsHere+1,:) = dummyRow;
    
    theseBlanks = sortedSessionInds(:,sessI) == 0;
    sortedSessionInds(theseBlanks,sessI) = numCellsHere+1;
    
    all_PSAbool_aligned{sessI,1} = all_PSAbool{sessI}(sortedSessionInds(:,sessI),:);
    %all_PSAbool_aligned{sessI}(sessRowLogical(:,sessI),:) = ...
    %    all_PSAbool{sessI}(sortedSessionInds(:,sessI),:);
    
end

end