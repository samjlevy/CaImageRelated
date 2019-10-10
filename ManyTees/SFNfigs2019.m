
%Build this out for multiple mice, multiple sessions
dualSplitters = find(sum(squeeze(numBinsAboveShuffle>0),2)==2);

splitDir = squeeze(meanRateDiff);
splitAbs = splitDir./abs(splitDir);

splitsSameWay = splitAbs(:,1) == splitAbs(:,2); splitsSameWay(thisCellSplits==0)=0;
splitsOpposite = sum(splitAbs,2)==0; splitsOpposite(thisCellSplits==0)=0;
splitsOne = sum(squeeze(numBinsAboveShuffle>0),2)==1;
splitsNone = thisCellSplits==0 & dayUse==1;

%Pie charts


%Example splitters
cellJ = dualSplitters(1);
presentDays = 1;
mazeLoc = 'stem';
mazeType = 'ContT';
trajPlotType = 'line';
spikesPlot = 'wholeLap';
colorRadius = [];

[figg] = PlotSplittingDotPlot2(daybyday,trialbytrial,cellJ,presentDays,mazeLoc,mazeType,trajPlotType,spikesPlot,colorRadius);