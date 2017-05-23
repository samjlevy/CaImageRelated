function [PixCorrs, corrP, ShuffleCorrs, goodCells] = PopVectorCorr2(PFsA, PFsB, posThresh,...
    hitThresh, excludeSilent,numShuffles,PSAbool)
%excludeSilent: if neither cell fires, leave it out of the correlation
%excludeSilent can also be a vector (logical or indices) of cells to include
if ~exist('excludeSilent','var')
    excludeSilent=1;
end
if length(excludeSilent)==1
    if excludeSilent==1
        [conditionHits, ~] = CellsInConditions(PSAbool, PFsA, PFsB);
        hitsA = conditionHits(:,1) >= hitThresh;
        hitsB = conditionHits(:,2) >= hitThresh;
        goodCells = (hitsA + hitsB) > 0;
    elseif excludeSilent==0
        goodCells = ones(size(PFsA.stats.PFnHits,1),1);
    end
else
    if length(excludeSilent) == size(PFsA.stats.PFnHits,1)
        goodCells = excludeSilent;
    else 
        disp('ExcludeSilent not the right length, using all cells')
        goodCells = ones(size(PFsA.stats.PFnHits,1));
    end
end

[GoodPix]=GoodOccMapShared(PFsA.maps.RunOccMap, PFsB.maps.RunOccMap, posThresh); 

%goodCells = ones(size(PFsA.stats.PFnHits,1),1);
%if excludeSilent==1 && length(excludeSilent)==1
%    hitsA = sum(PFsA.stats.PFnHits,2) >= hitThresh;
%    hitsB = sum(PFsB.stats.PFnHits,2) >= hitThresh;
%    goodCells = (hitsA + hitsB) > 0;
%end    

PixCorrs = nan(length(GoodPix),1);
corrP = nan(length(GoodPix),1);
for thisPixel = 1:length(GoodPix)
    [x,y]=ind2sub(size(PFsA.maps.TMap_gauss),GoodPix(thisPixel));
    PVa = reshape(PFsA.PopVectors(x,y,logical(goodCells)),1,sum(goodCells));
    PVb = reshape(PFsB.PopVectors(x,y,logical(goodCells)),1,sum(goodCells));
    PixCorrs(thisPixel) = corr(PVa', PVb'); %[ , corrP(thisPixel)] ,'type','Spearman'
end

%Shuffle trial IDs for p-val
ShuffleCorrs = nan(length(GoodPix),numShuffles);

for shuffPixel = 1:length(GoodPix)
    [x,y]=ind2sub(size(PFsA.maps.TMap_gauss),GoodPix(shuffPixel));
    PVa = PFsA.PopVectors(x,y,logical(goodCells));
    PVb = PFsB.PopVectors(x,y,logical(goodCells));
    
    for thisShuffle = 1:numShuffles
        shuffledPVs = zeros(sum(goodCells),1);
        reassign = randperm(length(shuffledPVs)); 
        reassign = reassign(1:round(length(reassign)/2));
        shuffledPVs(reassign) = 1;
        
        shuffledA(shuffledPVs == 0) = PVa(shuffledPVs == 0); %A
        shuffledA(shuffledPVs == 1) = PVb(shuffledPVs == 1); %B
        shuffledB(shuffledPVs == 0) = PVb(shuffledPVs == 0); %B
        shuffledB(shuffledPVs == 1) = PVa(shuffledPVs == 1); %A
        ShuffleCorrs(shuffPixel,thisShuffle) = corr(shuffledA', shuffledB');%,'type','Spearman'
    end
end
%}
end
