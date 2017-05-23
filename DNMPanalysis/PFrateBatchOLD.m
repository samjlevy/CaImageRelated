function [PFratesA, GoodPFpixelsA, rateDistA] = PFrateBatchOLD(PlaceFieldsA, GoodOccMap)

[numCellsA,numFieldsA] = size(PlaceFieldsA.stats.PFnHits);
PFratesA = nan(numCellsA, numFieldsA);
GoodPFpixelsA = cell(numCellsA, numFieldsA);
rateDistA = cell(numCellsA, numFieldsA);

for cellA = 1:numCellsA
    for fieldA = 1:numFieldsA
        [PFratesA(cellA, fieldA), GoodPFpixelsA{cellA, fieldA},...
            rateDistA{cellA, fieldA}] =...
            PFrate( PlaceFieldsA.stats.PFpixels{cellA,fieldA},...
                    PlaceFieldsA.maps.TMap_gauss{1,cellA}, GoodOccMap);
    end
end

end