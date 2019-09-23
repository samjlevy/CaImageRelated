function adjVerts = GetAdjacentPolyVertices(vertices,indices,adjacencyMat,targetCell)

adjacentCells = find(adjacencyMat(targetCell,:));

adjVerts = [];
for cellI = 1:length(adjacentCells)
    adjVerts = [adjVerts; vertices(indices{adjacentCells(cellI)},:)];
end

badPts = adjVerts==Inf | isnan(adjVerts);
adjVerts(logical(sum(badPts,2)),:) = [];

end