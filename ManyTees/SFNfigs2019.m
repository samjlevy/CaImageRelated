
%Build this out for multiple mice, multiple sessions
dualSplitters = find(sum(squeeze(numBinsAboveShuffle>0),2)==2);



for mI = 1:2
thisCellSplits{mI} = thisCellSplits{mI} & dayUse{mI};
splitDir{mI} = squeeze(meanRateDiff{mI});
splitAbs{mI} = splitDir{mI}./abs(splitDir{mI});
splitMaze{mI} = squeeze(cell2mat(cellfun(@any,binsAboveShuffle{mI},'UniformOutput',false)))>0;
end

for mI = 1:2
splitsSameWay{mI} = (splitAbs{mI}(:,1) == splitAbs{mI}(:,2)) & (splitMaze{mI}(:,1) & splitMaze{mI}(:,2)) & thisCellSplits{mI};
%splitsOpposite = sum(splitAbs,2)==0 & thisCellSplits;
splitsOpposite{mI} = (splitAbs{mI}(:,1) == -1*splitAbs{mI}(:,2)) & (splitMaze{mI}(:,1) & splitMaze{mI}(:,2));
splitsOne{mI} = (sum(splitMaze{mI},2)==1) & thisCellSplits{mI};
splitsNone{mI} = thisCellSplits{mI}==0 & dayUse{mI};
end

%Pie charts
for mI = 1:2
activeToday{mI} = sum(dayUse{mI});
propSame{mI} = sum(splitsSameWay{mI})/activeToday{mI};
propOpp{mI} = sum(splitsOpposite{mI})/activeToday{mI};
propOne{mI} = sum(splitsOne{mI})/activeToday{mI};
propNone{mI} = sum(splitsNone{mI})/activeToday{mI};
end
props = [propSame propOpp propOne propNone];
propLabels = {'same','opposite','one','none'};
figure;
pp = pie(props,propLabels);

%Not really working... getting too many or too few cells
for mI = 1:2
tac = squeeze(threshAndConsec{mI});
propOneA{mI} = sum(splitsOne{mI} & splitMaze{mI}(:,1) & dayUse{mI})/activeToday{mI}; %/activeToday; sum(tac(:,[1 2]),2)>0
propOneB{mI} = sum(splitsOne{mI} & splitMaze{mI}(:,2) & dayUse{mI})/activeToday{mI}; % )/activeToday; sum(tac(:,[3 4]),2)>0
props{mI} = [propSame{mI} propOpp{mI} propOneA{mI} propOneB{mI} propNone{mI}];
sum(props{mI})
propLabels = {'same','opposite','oneA','oneB','none'};
figure;
pp = pie(props{mI},propLabels);
title(['Two Maze Alternation Splitter Props ' mice{mI}])
end


%Example splitters
load('daybyday.mat')

tt = find(splitsOne);
ii = 0;
ii = ii+1;
cellJ = tt(ii);
presentDays = 1;
mazeLoc = 'stem';
mazeType = 'ContT';
trajPlotType = 'line';
spikesPlot = 'wholeLap';
colorRadius = [];


[figg] = PlotSplittingDotPlot2(daybyday,cellTBT{1},cellJ,presentDays,mazeLoc,mazeType,trajPlotType,spikesPlot,colorRadius);
