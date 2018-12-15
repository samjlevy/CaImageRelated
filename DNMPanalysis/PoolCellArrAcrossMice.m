function pooledCellArr = PoolCellArrAcrossMice(cellArr)
%Assumes this cell arr is just 1 x numMice

pooledCellArr = [];
for aa = 1:length(cellArr)
    pooledCellArr = [pooledCellArr; cellArr{aa}];
end

end