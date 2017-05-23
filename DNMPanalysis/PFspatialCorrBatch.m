function [corrs, pvals] = PFspatialCorrBatch(PFsA, PFsB, posThresh, spikeThresh, PSAbool)

numCells = size(PFsA.stats.PFnHits,1);

try
    load('Pos_align.mat','PSAbool')
catch
    [FileName,PathName] = uigetfile('Gimme file with PSAbool');
    load(fullfile(PathName,FileName),'PSAbool')
end

[GoodOccMap]=GoodOccMapShared(PFsA.maps.RunOccMap, PFsB.maps.RunOccMap, posThresh);

[GoodCellsA, activeCellsA] = CellsAboveThresh2(PSAbool, PFsA, spikeThresh, GoodOccMap);
[GoodCellsB, activeCellsB] = CellsAboveThresh2(PSAbool, PFsB, spikeThresh, GoodOccMap);
allUseCells = (GoodCellsA .* activeCellsB) | (GoodCellsB .* activeCellsA);

corrs = [];nan(numCells,1);
pvals = [];nan(numCells,1);
for thisCell = 1:numCells
    if allUseCells(thisCell) == 1
    PFa = PFsA.maps.TMap_gauss{1,thisCell}(GoodOccMap);
    PFb = PFsB.maps.TMap_gauss{1,thisCell}(GoodOccMap);
    %[corrs(thisCell,1), pvals(thisCell,1)] = corr(PFa, PFb, 'rows','complete'); 
    [corrs2, pvals2] = corr(PFa, PFb, 'rows','complete'); 
    corrs = [corrs; corrs2];
    pvals = [pvals; pvals2];
    end
    
end

end