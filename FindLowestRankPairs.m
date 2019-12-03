function [pairsHave, distHere, ranks] = FindLowestRankPairs(distMat)

numRows = size(distMat,1);
numCols = size(distMat,2);

%[~,rowMinInd] = min(distMat,[],2);
%[~,colMin] = min(distMat,[],1);

%In cases, where the row and col min agree, use that, iteratively sort back
%(what does that mean...)

%Hacky way: sort every thing by distance, march through until we have one
%of each index in each column
allDist = distMat(:);
allInds(:,1) = repmat([1:numRows]',numCols,1);
colTemp = repmat(1:numCols,numRows,1);
allInds(:,2) = colTemp(:);

[distSorted,sortOrder] = sort(allDist,'ascend');
indPairsSorted = allInds(sortOrder,:);

pairsGet = min([numRows numCols]);
pairsKeep = false(length(allDist),1);
pairsHave = [];

indCheck = 0;
while(sum(pairsKeep) < pairsGet)
    indCheck = indCheck + 1;

    %There's a smarter way to do this...
    pairsKeep(indCheck) = true;
    pairsHave = indPairsSorted(pairsKeep,:);
    
    %rowsHave = histcounts(pairsHave(:,1),0.5:1:numRows+0.5);
    %colsHave = histcounts(pairsHave(:,2),0.5:1:numCols+0.5);
    %Hist counts runs too slowly
    rowsHave = sum(pairsHave(:,1)==1:numRows,1);
    colsHave = sum(pairsHave(:,2)==1:numCols,1);
    
    if any(rowsHave>1) || any(colsHave>1)
        pairsHave(end,:) = [];
        pairsKeep(indCheck) = false;
    end
end

distHere = distSorted(pairsKeep);
ranks = find(pairsKeep);

end