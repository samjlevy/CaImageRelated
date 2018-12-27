function [axHand,statsOut] = PlotTraitProps(pooledSplitProp,plotWhich,comparisons,plotColors,traitLabels,axHand) 
%plotWhich = comparisonsAll;
if isempty(axHand)
    figure;
    axHand = axes;
end

numDataPts = length(pooledSplitProp{1});
grps = repmat(1:length(plotWhich),numDataPts,1); grps = grps(:);
dataHere = [pooledSplitProp{plotWhich}]; 
dataHere = dataHere(:);
colorsHere = plotColors(plotWhich);
allColors = cellfun(@(x) repmat(x,numDataPts,1),colorsHere,'UniformOutput',false)';
colorsUse = []; for aa = 1:length(allColors); colorsUse = [colorsUse; allColors{aa}]; end
xLabels = traitLabels(plotWhich);
scatterBoxSL(dataHere, grps, 'xLabel', xLabels, 'plotBox', true, 'circleColors', colorsUse, 'transparency', 0.8,'plotHandle',axHand)  
ylabel('Proportion of Splitter Cells')
hold on
ylim([-0.05 1.1])
heightBump = 0.03;
barXpos = axHand.XTick;
for pcI = 1:size(comparisons,1)
    splitPropDiffs{pcI} = pooledSplitProp{comparisons(pcI,2)} - pooledSplitProp{comparisons(pcI,1)};
    [statsOut.pPropDiffs(pcI),statsOut.hPropDiffs(pcI)] = signtest(splitPropDiffs{pcI}); %h = 1 reject (different)
    
    %plot a bar across the pair of compare inds
    possibleHeight = max(round(cell2mat(cellfun(@max,pooledSplitProp(comparisons(pcI,:)),'UniformOutput',false)),1));
    possibleHeight = possibleHeight + heightBump;
    plot(barXpos(comparisons(pcI,:)),[possibleHeight possibleHeight],'k','LineWidth',2)
    
    switch statsOut.hPropDiffs(pcI)
        case 1
            if statsOut.pPropDiffs(pcI) < 0.001
                textPlot = 'p < 0.001';
            else
                textPlot = ['p = ' num2str(statsOut.pPropDiffs(pcI))];
            end
        case 0
            textPlot = 'n.s.';
    end
    text(mean(barXpos(comparisons(pcI,:))),possibleHeight+0.025,textPlot,'Color','k','HorizontalAlignment','center')
end

statsOut.propMeans = cell2mat(cellfun(@mean,pooledSplitProp,'UniformOutput',false));
statsOut.propSEMs = cell2mat(cellfun(@standarderrorSL,pooledSplitProp,'UniformOutput',false));

end