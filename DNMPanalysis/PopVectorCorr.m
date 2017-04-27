function [PixCorrs, corrP] = PopVectorCorr(PFsA, PFsB, posThresh, excludeSilent)
%excludeSilent: if neither cell fires, leave it out of the correlation
if ~exist('excludeSilent','var')
    excludeSilent=0;
end

[GoodPix]=GoodOccMapShared(PFsA.maps.RunOccMap, PFsB.maps.RunOccMap, posThresh); 

[PopVectorsA] = PopVectorsMake(PFsA.maps.TMap_gauss, GoodPix);
[PopVectorsB] = PopVectorsMake(PFsB.maps.TMap_gauss, GoodPix);

goodCells = ones(size(PFsA.stats.PFnHits,1),1);
if excludeSilent==1
    hitsA = sum(PFsA.stats.PFnHits,2);
    hitsB = sum(PFsB.stats.PFnHits,2);
    goodCells = (hitsA + hitsB) > 0;
end    

PixCorrs = nan(length(GoodPix),1);
corrP = nan(length(GoodPix),1);
for thisPixel = 1:length(GoodPix)
    PVa = PopVectorsA{GoodPix(thisPixel)}(logical(goodCells));
    PVb = PopVectorsB{GoodPix(thisPixel)}(logical(goodCells));
    [PixCorrs(thisPixel), corrP(thisPixel)] = corr(PVa, PVb);
end

end
