function cellArrMeanByCS = MeanCellArr(cellArr,condSet)

cellArrMeanByCS = [];
numBins = length(cellArr{1,1});
for csI = 1:length(condSet)
    for dpI = 1:size(cellArr,1)
        tempMat = [cellArr{dpI,condSet{csI}'}];
        realMat = reshape(tempMat,numBins,length(condSet{csI}))';
        cellArrMeanByCS{dpI,csI} = mean(realMat,1);
    end
end

end