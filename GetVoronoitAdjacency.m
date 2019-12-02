function voronoiAdj = GetVoronoiAdjacency(vorIndices)

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