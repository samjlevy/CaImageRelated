function rateDiffAB = PFrateChangeBatch(PFsA, PFsB, hitThresh, posThresh, PSAbool)
%numCells = size(PFsA.stats.PFnHits,1);
try
    load('Pos_align.mat','PSAbool')
catch
    [FileName,PathName] = uigetfile('Gimme file with PSAbool');
    load(fullfile(PathName,FileName),'PSAbool')
end

[GoodOccMap]=GoodOccMapShared(PFsA.maps.RunOccMap, PFsB.maps.RunOccMap, posThresh);

[GoodCellsA, activeCellsA] = CellsAboveThresh2(PSAbool, PFsA, hitThresh, GoodOccMap);
[GoodCellsB, activeCellsB] = CellsAboveThresh2(PSAbool, PFsB, hitThresh, GoodOccMap);
allUseCells = (GoodCellsA .* activeCellsB) | (GoodCellsB .* activeCellsA);
%allUseCells = logical(ones(numCells,1));

%Rates for both blocks
[PFratesA, ~] = PFrateBatch(PFsA, GoodOccMap);
[PFratesB, ~] = PFrateBatch(PFsB, GoodOccMap);

rateDiffAB = (PFratesA(allUseCells) - PFratesB(allUseCells))...
    ./(PFratesA(allUseCells) + PFratesB(allUseCells));

%rateDiffAB = zeros(numCells,1);

%for thisCell = 1:numCells
%    if allUseCells(thisCell) == 1
%        rateA = PFratesA(thisCell);
%        rateB = PFratesB(thisCell);
%        rateDiffAB(thisCell) = (rateB - rateA) / (rateB + rateA);
%    end
%end

end