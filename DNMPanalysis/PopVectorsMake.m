function [PopVectors] = PopVectorsMake(RateMaps, keepNans)
%Rate map should be TMap_unsmoothed, TMap_counts, FMap, etc.
%Eliminate isnans is defaulted to yes
%Good pixels is optional, will make a vector for every cell at every pixel , GoodPixels
if ~exist('keepNans','var')
    keepNans = 0;
elseif keepNans == 1
    keepNans = NaN;
    disp('keeping NaNs')
end
    
numCells = max([size(RateMaps)]);
%{
if ~exist('GoodPixels','var')
    allPix = ones(size(RateMaps{1,1}));
    GoodPixels = find(allPix);
end

%Preallocate

PopVectors = cell(size(RateMaps{1,1}));
blankVector = nan(numCells,1);
[PopVectors{GoodPixels}] = deal(blankVector);
for thisCell = 1:numCells
    for thisPixel = 1:length(GoodPixels)
        PopVectors{GoodPixels(thisPixel)}(thisCell) =...
            RateMaps{1,thisCell}(GoodPixels(thisPixel));
        if isnan(RateMaps{1,thisCell}(GoodPixels(thisPixel)))
            PopVectors{GoodPixels(thisPixel)}(thisCell) = 0;
        end
    end
end
%}

PopVectors=reshape([RateMaps{1,:}],size(RateMaps{1},1),size(RateMaps{1},2), numCells);

PopVectors(isnan(PopVectors)) = keepNans;
    
end
        
        
   