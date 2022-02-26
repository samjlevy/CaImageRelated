function [cad] = cellAndDeal(cellSize,dealToEach)

cad = cell(cellSize);
[cad{:}] = deal(dealToEach);
