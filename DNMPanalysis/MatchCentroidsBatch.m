function [matches, matchesExclusive]=MatchCentroidsBatch(CentroidsA,CentroidsB,rowAlign)
%Batch version of match centroids
%if rows in CentroidsA are not aligned rows of centroidsB, use rowAlign

if ~exist('rowAlign','var')
    rowsA = [1:size(CentroidsA,1)]';
    rowsB = rowsA;
    rowAlign = [rowsA, rowsB];
end
rowsA = rowAlign(:,1);
rowsB = rowAlign(:,2);

numRows = size(rowAlign,1);

matches = cell(numRows,1);
matchesExclusive = cell(numRows,1);

for thisRow = 1:numRows
    theseA = [CentroidsA{rowsA(thisRow),:}];
    theseB = [CentroidsB{rowsB(thisRow),:}];
    if any(theseA) && any(theseB)
        [matches{thisRow,1}, matchesExclusive{thisRow,1}]...
            = MatchCentroids(CentroidsA, rowsA(thisRow), CentroidsB, rowsB(thisRow));
    end
end

end