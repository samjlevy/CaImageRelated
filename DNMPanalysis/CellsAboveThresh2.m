function [GoodCells, ActiveCells] = CellsAboveThresh2(PSAbool, PFs, hitThresh, GoodOccMap)

linInd = sub2ind(size(PFs.maps.TMap_gauss{1}),PFs.maps.xBinTotal,PFs.maps.yBinTotal);
GoodRunning = ismember(linInd,GoodOccMap);

GoodInds = PFs.maps.isrunning & GoodRunning;

cellsHits = sum(PSAbool(:,GoodInds),2);
GoodCells = cellsHits >= hitThresh;
ActiveCells = cellsHits > 0;

end
