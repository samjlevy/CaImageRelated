function [PFratesA, GoodPFpixelsA, rateDistA] = PFrateBatch(PlaceFieldsA, GoodOccMap)

numCellsA = size(PlaceFieldsA.stats.PFnHits,1);
numFieldsA = size(PlaceFieldsA.stats.PFnHits,2);
PFratesA = nan(numCellsA, numFieldsA);
GoodPFpixelsA = cell(numCellsA, numFieldsA);
rateDistA = cell(numCellsA, numFieldsA);
for cellA = 1:numCellsA
    for fieldA = 1:numFieldsA
        [PFratesA(cellA, fieldA), GoodPFpixelsA{cellA, fieldA},...
            rateDistA{cellA, fieldA}] =...
            PFrate( PlaceFieldsA.stats.PFpixels{cellA,fieldA},...
                    PlaceFieldsA.stats.TMap_gauss{1,cellA}, GoodOccMap);
    end
end

end