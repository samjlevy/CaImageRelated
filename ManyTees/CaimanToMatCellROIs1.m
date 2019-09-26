function [cellROIs] = CaimanToMatCellROIs1(A,imSize)
%Takes the output from caiman and translates it into our standard image in a cell array

numCells = size(A,2);
cellROIs = cell(numCells,1);
for cellI=1:numCells
    cellROIs{cellI} = full(reshape(A(:,cellI),imSize(1),imSize(2)));
end

end