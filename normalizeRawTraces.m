function normalizedTraces = normalizeRawTraces(rawTraces,cellDim)

%assumes each row in the matrix is a 

if any(cellDim); if strcmpi(cellDim,'column')
    rawTraces = rawTraces';
end; end

numCells = size(rawTraces,1);
numTs = size(rawTraces,2);
normalizedTraces = zeros(numCells,numTs);

for cellI = 1:numCells
    tc = rawTraces(cellI,:);
    rc = (tc - min(tc));
    normalizedTraces(cellI,:) = rc/max(rc);
end

end
    
    