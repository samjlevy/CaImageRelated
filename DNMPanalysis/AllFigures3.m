%% Proportion of each splitter type

hh = figure;
numDataPts = length(pooledSplitProp{tgI});
grps = repmat(1:length(traitGroups{1}),numDataPts,1); grps = grps(:);
dataHere = [pooledSplitProp{:}]; dataHere = dataHere(:);
%colorsHere = repmat(colorsHere,8,1);        
%repmat for the color in colorAssc, put into circle colors
xLabels = traitLabels;
scatterBoxSL(dataHere, grps, 'xLabel', xLabels, 'plotBox', true) % 'circleColors', colorsHere, 'transparency', 0.5
ylabel('Proportion of Splitter Cells')
title('Proportion of Cells Each Splitter Type, all mice all days')

barXpos = hh.Children.XTick;
for pcI = 1:numPairsCompare
    %plot a bar across the pair of compare inds
    
    %mark it significant or not with hSplitterPropDiffs, pVal in pSplitterPropDiffs
    
end