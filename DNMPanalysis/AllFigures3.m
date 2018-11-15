cpsPlot = [1 2 3];
tgsPlot = pairsCompareInd(cpsPlot,:)'; tgsPlot = tgsPlot(:);

%% Proportion of each splitter type
hh = figure;
numDataPts = length(pooledSplitProp{tgI});
%grps = repmat(1:length(traitGroups{1}),numDataPts,1); grps = grps(:);
grps = repmat(1:length(tgsPlot),numDataPts,1); grps = grps(:);
%dataHere = [pooledSplitProp{:}]; 
dataHere = [pooledSplitProp{tgsPlot}]; 
dataHere = dataHere(:);
%colorsHere = repmat(colorsHere,8,1);        
colorsHere = colorAssc(tgsPlot);
allColors = cellfun(@(x) repmat(x,numDataPts,1),colorsHere,'UniformOutput',false)';
colorsUse = []; for aa = 1:length(allColors); colorsUse = [colorsUse; allColors{aa}]; end
%repmat for the color in colorAssc, put into circle colors
xLabels = traitLabels(tgsPlot);
scatterBoxSL(dataHere, grps, 'xLabel', xLabels, 'plotBox', true, 'circleColors', colorsUse, 'transparency', 0.8) % 'circleColors', colorsHere, 
ylabel('Proportion of Splitter Cells')
title('Proportion of Cells Each Splitter Type, all mice all days')
hold on
ylim([0 1.1])
heightBump = 0.03;
barXpos = hh.Children.XTick;
for pcI = 1:length(cpsPlot)
    %plot a bar across the pair of compare inds
    possibleHeight = max(round(cell2mat(cellfun(@max,pooledSplitProp(pairsCompareInd(cpsPlot(pcI),:)),'UniformOutput',false)),1));
    possibleHeight = possibleHeight + heightBump;
    plot(barXpos(pairsCompareInd(cpsPlot(pcI),:)),[possibleHeight possibleHeight],'k','LineWidth',2)
    
    %mark it significant or not with hSplitterPropDiffs, pVal in pSplitterPropDiffs
    switch hSplitterPropDiffs(cpsPlot(pcI))
        case 1
            if pSplitterPropDiffs(cpsPlot(pcI)) < 0.001
                textPlot = 'p < 0.001';
            else
                textPlot = ['p = ' num2str(pSplitterPropDiffs(cpsPlot(pcI)))];
            end
        case 0
            textPlot = 'n.s.';
    end
    text(mean(barXpos(pairsCompareInd(cpsPlot(pcI),:))),possibleHeight+0.025,textPlot,'Color','k','HorizontalAlignment','center')
end

%% Change in Proportion of Each splitter type by days apart
%Comparison
gg=figure('Position',[65 410 1813 510]);
sRows = 1;
sCols = 3;
for pcI = 1:length(cpsPlot)
    subplot(sRows,sCols,pcI)
    pcIndsHere = pairsCompareInd(cpsPlot(pcI),:);
    %plot data
    plot(pooledDaysApartFWD-0.1,pooledSplitPctChangeFWD{pcIndsHere(1)},'.','Color',colorAssc{pcIndsHere(1)},'MarkerSize',12)
    hold on
    plot(pooledDaysApartFWD+0.1,pooledSplitPctChangeFWD{pcIndsHere(2)},'.','Color',colorAssc{pcIndsHere(2)},'MarkerSize',12)
    %plot reg fit line    
    plot(splitterFitPlotDays,splitterFitPlotPct{pcIndsHere(1)},'Color',colorAssc{pcIndsHere(1)},'LineWidth',2)
    plot(splitterFitPlotDays,splitterFitPlotPct{pcIndsHere(2)},'Color',colorAssc{pcIndsHere(2)},'LineWidth',2)
    
    ylim([-0.5 0.5])
    xlim([0.5 max(pooledDaysApartFWD)-0.5]) %cell2mat(cellfun(@max,cellRealDays,'UniformOutput',false))
    xlabel('Days Apart')
    ylabel('Proportion Change')
    %indicate the r2 of each line
    %switch slopeDiffRank(pcI)>=(1*numPerms-numPerms*pThresh); case 1; diffTxt='ARE'; case 0; diffTxt ='ARE NOT'; end
    %title([pairsCompare{pcI,1} ' vs ' pairsCompare{pcI,2} ', slopes ' diffTxt ' diff at p = ' num2str(1-slopeDiffRank(pcI)/1000)])
    switch pVal(cpsPlot(pcI))<pThresh; case 1; diffTxt='ARE'; case 0; diffTxt ='are NOT'; end
    title([pairsCompare{pcIndsHere(1)} ' vs ' pairsCompare{pcIndsHere(2)} ', slopes ' diffTxt ' diff at p = ' num2str(pVal(cpsPlot(pcI)))])
    legend(pairsCompare{pcIndsHere(1)},pairsCompare{pcIndsHere(2)})
end
suptitleSL('Changes by days apart in proportion of splitting type')

%% Comparison of days forwards and back?