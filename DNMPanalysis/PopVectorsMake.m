function [PopVectors] = PopVectorsMake(RateMaps, GoodPixels)
%Rate map should be TMap_unsmoothed, TMap_counts, FMap, etc.

numCells = max([size(RateMaps)]);

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

end
        
        
   