function cellArrMeanByCS = MeanCellArr(cellArr,condSet)

cellArrMeanByCS = [];
numBins = length(cellArr{1,1});
for csI = 1:length(condSet)
    for dpI = 1:size(cellArr,1)
        tempMat = [cellArr{dpI,condSet{csI}'}];
        if size(cellArr{1,1},1)==1
            realMat = reshape(tempMat,numBins,length(condSet{csI}))';
            cellArrMeanByCS{dpI,csI} = mean(realMat,1);
        else
            %it's bin i vs bin j
            realMat = reshape(tempMat,numBins,numBins,length(condSet{csI}));
            cellArrMeanByCS{dpI,csI} = mean(realMat,3);
        end
    end
end

end