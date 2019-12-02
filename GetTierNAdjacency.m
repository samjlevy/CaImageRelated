function tierNadj = GetTierNAdjacency(adjMat,tierN)
%adjMat is an adjacency matrix, n x n pts
%tierN says howmany levels up do we want to go
%tierNadj is a logical matrix that says 1 this cell is tierN away from
%other cell
adjMat = logical(adjMat);
nPts = size(adjMat,1);

%Iterative that tells what's up to n levels of connections away
tierNadj = false(nPts,nPts);
for ptI = 1:nPts
    newAdj = [];
    adjHere = find(adjMat(ptI,:));
    for nn = 1:tierN
        nextAdj = adjMat(adjHere,:);
        nextAdjInds = find(sum(nextAdj,1)>0);
        alreadyHave = ismember(nextAdjInds,adjHere);
        nextAdjInds(alreadyHave) = [];
        adjHere = [adjHere(:); nextAdjInds(:)];
    end
    adjHere(adjHere==ptI) = [];
    tierNadj(ptI,adjHere) = true;
end

end