function voronoiAdj = GetVoronoiAdjacency(vorIndices,vorVerts)

if any(vorVerts)
notInf = find(sum(~isinf(vorVerts),2)==2); %Indices that don't have inf
fixedIndices = cellfun(@(x) x(logical(sum(x(:)==notInf(:)',2))),vorIndices,'UniformOutput',false);
vorIndices = fixedIndices;
end

%Same operation, just to verify logic...
%{
indLocsX = cellfun(@(x) vorVerts(x,1),vorIndices,'UniformOutput',false);
badIndX = cellfun(@(x) ~isinf(x),indLocsX,'UniformOutput',false);
indLocsY = cellfun(@(x) vorVerts(x,2),vorIndices,'UniformOutput',false);
badIndY = cellfun(@(x) ~isinf(x),indLocsY,'UniformOutput',false);
noInfInds = cellfun(@(x,y) x & y,badIndX,badIndY,'UniformOutput',false);
fixedVerts2 = cellfun(@(x,y) x(y),vorIndices,noInfInds,'UniformOutput',false);
%}

numCells = length(vorIndices);

voronoiAdj = false(numCells,numCells);
for cellI = 1:numCells
    %if edgePolys(cellI)==0
    for cellJ = 1:numCells
        if cellI ~= cellJ
            voronoiAdj(cellI,cellJ) = any(ismember(vorIndices{cellI},vorIndices{cellJ}));
        end
    end
    %end
end

end