function [corrs, pvals] = PFspatialCorrBatch(PFsA, PFsB, posThresh, spikeThresh)

numCells = size(PFsA.stats.PFnHits,1);

[GoodPix]=GoodOccMapShared(PFsA.maps.RunOccMap, PFsB.maps.RunOccMap, posThresh);

corrs = nan(numCells,1);
pvals = nan(numCells,1);
for thisCell = 1:numCells
    PFa = PFsA.maps.TMap_gauss{1,thisCell}(GoodPix);
    PFb = PFsB.maps.TMap_gauss{1,thisCell}(GoodPix);
    [corrs(thisCell,1), pvals(thisCell,1)] = corr(PFa, PFb); 
end

end