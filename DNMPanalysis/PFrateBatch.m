function [PFratesA, rateDistA] = PFrateBatch(PlaceFieldsA, GoodOccMap)

numCellsA = size(PlaceFieldsA.stats.PFnHits,1);
PFratesA = zeros(numCellsA, 1);
rateDistA = cell(numCellsA, 1);

for cellA = 1:numCellsA
    [PFratesA(cellA), rateDistA{cellA, 1}] =...
        PFrate( PlaceFieldsA.maps.TMap_gauss{1,cellA}, GoodOccMap);
end

end