
%Build this out for multiple mice, multiple sessions
dualSplitters = find(sum(squeeze(numBinsAboveShuffle>0),2)==2);



for mI = 1:numMice
thisCellSplits{mI} = thisCellSplits{mI} & dayUse{mI};
splitDir{mI} = squeeze(meanRateDiff{mI});
splitAbs{mI} = splitDir{mI}./abs(splitDir{mI});
splitMaze{mI} = squeeze(cell2mat(cellfun(@any,binsAboveShuffle{mI},'UniformOutput',false)))>0;
end

for mI = 1:numMice
splitsSameWay{mI} = (splitAbs{mI}(:,1) == splitAbs{mI}(:,2)) & (splitMaze{mI}(:,1) & splitMaze{mI}(:,2)) & thisCellSplits{mI};
splitsOpposite{mI} = sum(splitAbs{mI},2)==0 & thisCellSplits{mI};
%splitsOpposite{mI} = (splitAbs{mI}(:,1) == -1*splitAbs{mI}(:,2)) & (splitMaze{mI}(:,1) & splitMaze{mI}(:,2));
splitsOne{mI} = (sum(splitMaze{mI},2)==1) & thisCellSplits{mI};
splitsNone{mI} = thisCellSplits{mI}==0 & dayUse{mI};
%splitsNone{mI} = thisCellSplits{mI}==0 & sum(trialReli{mI},3)>0;
end

%Pie charts
for mI = 2:numMice
activeToday{mI} = sum(dayUse{mI});
%activeToday{mI} = sum(sum(trialReli{mI},3)>0);
propSame{mI} = sum(splitsSameWay{mI})/activeToday{mI};
propOpp{mI} = sum(splitsOpposite{mI})/activeToday{mI};
propOne{mI} = sum(splitsOne{mI})/activeToday{mI};
propNone{mI} = sum(splitsNone{mI})/activeToday{mI};
props = [propSame{mI} propOpp{mI} propOne{mI} propNone{mI}];
propLabels = {'same','opposite','one','none'};
figure;
pp = pie(props,propLabels);
title(['Two Maze Alternation Splitter Props ' mice{mI}])
end


%Not really working... getting too many or too few cells
for mI = 2:numMice
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


dataAll = [squeeze(shuffledResults.correctPct{1}(1,1,:)); squeeze(shuffledResults.correctPct{2}(1,2,:))];
grps = [ones(1000,1); 2*ones(1000,1)];
aa = figure;
scatterBoxSL(dataAll(:),grps,'plotBox',false,'ylabel','Trials Decoded Correctly','xLabels',{'2 From 1';'1 From 2'})
hold on
plot([0.8 1.2],[1 1]*decodingResults.correctPct{1}(1),'k','LineWidth',2)
plot([1.8 2.2],[1 1]*decodingResults.correctPct{2}(2),'k','LineWidth',2)
text(1.25,0.5,num2str(decodingResults.correctPct{1}(1)))
text(2.25,0.5,num2str(decodingResults.correctPct{2}(2)))
ylim([0 1])
title('Decoding 1 maze from activity on other')
aa.Children = MakePlotPrettySL(aa.Children);