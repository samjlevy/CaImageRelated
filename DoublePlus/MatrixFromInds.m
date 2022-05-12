function [dataMat] = MatrixFromInds(numCells,data,inds,fillEmptiesWith)

% fillEmptiesWith is the value you want all cells in the 
% matrix to start as (e.g. 0, 1, NaN)

dataMat = fillEmptiesWith*ones(numCells);
[cellPairsInds] = sub2ind([1 1]*numCells,inds(:,1),inds(:,2));
[cellPairsIndss] = sub2ind([1 1]*numCells,inds(:,2),inds(:,1));
dataMat(cellPairsInds) = data;
dataMat(cellPairsIndss) = data;

end