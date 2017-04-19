function rateDiffAB = PFrateChangeBatch(PlaceFieldsA, PlaceFieldsB, matches, hitThresh, posThresh)

[GoodOccMap]=GoodOccMapShared...
    ( PlaceFieldsA.maps.RunOccMap, PlaceFieldsB.maps.RunOccMap, posThresh);

useCellsA = CellsAboveThresh(PlaceFieldsA.maps.PFnHits, hitThresh);
useCellsB = CellsAboveThresh(PlaceFieldsB.maps.PFnHits, hitThresh);
allUseCells = useCellsA & useCellsB;

%Rates for both blocks
[PFratesA, GoodPFpixelsA, rateDistA] = PFrateBatch(PlaceFieldsA, GoodOccMap);
[PFratesB, GoodPFpixelsB, rateDistB] = PFrateBatch(PlaceFieldsB, GoodOccMap);

rateDiffAB = nan(size(allUseCells));

numCells = size(useAllCells,1);
for thisCell = 1:numCells
    theseMatches = [matches{thisCell,1}];
    if ~isempty(theseMatches)
        for match = 1:length(theseMatches)
            if theseMatches(match)~=0 %...
                %&& useCellsA(thisCell,theseMatches(match))...
                %&& useCellsB(thisCell,match)
                rateA = PFratesA(thisCell,theseMatches(match));
                rateB = PFratesB(thisCell,match);
                rateDiffAB(thisCell,theseMatches(match)) = ...
                    (rateB - rateA) / (rateB + rateA);
            end
        end
    end
end

end