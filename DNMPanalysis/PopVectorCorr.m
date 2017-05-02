function [PixCorrs, corrP] = PopVectorCorr(PFsA, PFsB, posThresh, excludeSilent)
%excludeSilent: if neither cell fires, leave it out of the correlation
%excludeSilent can also be a vector (logical or indices) of cells to include
if ~exist('excludeSilent','var')
    excludeSilent=0;
elseif exist('excludeSilent','var')
    if length(excludeSilent)==1
        %do nothing
    else
        if length(excludeSilent) == size(PFsA.stats.PFnHits,1)
            goodCells = excludeSilent;
        else 
            goodCells = zeros(size(PFsA.stats.PFnHits,1));
            goodCells(excludeSilent) = 1;
        end
    end
end

[GoodPix]=GoodOccMapShared(PFsA.maps.RunOccMap, PFsB.maps.RunOccMap, posThresh); 

[PopVectorsA] = PopVectorsMake(PFsA.maps.TMap_gauss, GoodPix);
[PopVectorsB] = PopVectorsMake(PFsB.maps.TMap_gauss, GoodPix);

goodCells = ones(size(PFsA.stats.PFnHits,1),1);
if excludeSilent==1 && length(excludeSilent==1)
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

%Shuffle trial IDs for p-val
ShuffleCorrs = nan(length(GoodPix),numShuffles);
for shuffPixel = 1:length(GoodPix)
    PVa = PopVectorsA{GoodPix(shuffPixel)}(logical(goodCells));
    PVb = PopVectorsB{GoodPix(shuffPixel)}(logical(goodCells));
    
    for thisShuffle = 1:numShuffles
        shuffledPVs = zeros(length(PopVectorsA{GoodPix(1)}(logical(goodCells))),1);
        reassign = randperm(length(shuffledPVs)); 
        reassign = reassign(1:round(length(reassign)/2));
        shuffledPVs(reassign) = 1;
        
        shuffledA(shuffledPVs == 0) = PVa(shuffledPVs == 0); %A
        shuffledA(shuffledPVs == 1) = PVb(shuffledPVs == 1); %B
        shuffledB(shuffledPVs == 0) = PVb(shuffledPVs == 0); %B
        shuffledB(shuffledPVs == 1) = PVa(shuffledPVs == 1); %A
        [ShuffleCorrs(shuffPixel,thisShuffle), ~] = corr(shuffledA', shuffledB');
    end
end


end
