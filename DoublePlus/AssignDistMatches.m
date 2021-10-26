function [] = AssignDistMatches(distDiffs,threshBelow)
% Indexes along rows
nRows = size(distDiffs,1);
nCols = size(distDiffs,2);

dds = distDiffs < threshBelow;

for rowI = 1:nRows
    