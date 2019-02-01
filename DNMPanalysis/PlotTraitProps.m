function [axHand,statsOut] = PlotTraitProps(pooledSplitProp,plotWhich,comparisons,plotColors,traitLabels,axHand) 
%plotWhich = comparisonsAll;
if isempty(axHand)
    figure;
    axHand = axes;
end

if ~iscell(comparisons)
    comps = comparisons; comparisons = [];
    for aa = 1:size(comparisons,1)
        comparisons{aa,1} = comps(aa,:);
    end
end

%Plot the scatter
numDataPts = length(pooledSplitProp{1});
grps = repmat(1:length(plotWhich),numDataPts,1); grps = grps(:);
dataHere = [pooledSplitProp{plotWhich}]; 
dataHere = dataHere(:);
xLabels = traitLabels(plotWhich);
if ~isempty(plotColors)
    colorsHere = plotColors(plotWhich);
    allColors = cellfun(@(x) repmat(x,numDataPts,1),colorsHere,'UniformOutput',false)';
    colorsUse = []; for aa = 1:length(allColors); colorsUse = [colorsUse; allColors{aa}]; end
    scatterBoxSL(dataHere, grps, 'xLabel', xLabels, 'plotBox', true, 'circleColors', colorsUse, 'transparency', 0.8,'plotHandle',axHand)  
else
    scatterBoxSL(dataHere, grps, 'xLabel', xLabels, 'plotBox', true, 'transparency', 0.8,'plotHandle',axHand)  
end
ylabel('Proportion of Splitter Cells')
hold on
ylim([-0.05 1.1])

%Plot some stats stuff
heightBump = 0.03;
barXpos = axHand.XTick;
barX = [];
barHeights = [];
for pcI = 1:size(comparisons,1)
    compHere = comparisons{pcI};
    
    %comps = combnk(compHere,2);
    %for compI = 1:size(comps,1)
    splitPropDiffs{pcI} = pooledSplitProp{plotWhich(compHere(2))} - pooledSplitProp{plotWhich(compHere(1))};
    [statsOut.pPropDiffs(pcI),statsOut.hPropDiffs(pcI)] = signtest(splitPropDiffs{pcI}); %h = 1 reject (different)
    
    %plot a bar across the pair of compare inds
    possibleHeight = max(round(cell2mat(cellfun(@max,pooledSplitProp(plotWhich(compHere)),'UniformOutput',false)),1));
    possibleHeight = possibleHeight + heightBump;
       
    possibleX = barXpos(compHere);
    
    if pcI > 1
    [foundOverlap, overlapAtAll] = CheckOverlap(barX,possibleX);
    if any(overlapAtAll)
        possibleHeight = max(barHeights(find(overlapAtAll)))+0.07;
    end
    end
    barX = [barX; possibleX];
    barHeights = [barHeights; possibleHeight];
   
    plot(barXpos(compHere),[possibleHeight possibleHeight],'k','LineWidth',2)
    
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
    text(mean(possibleX),possibleHeight+0.03,textPlot,'Color','k','HorizontalAlignment','center')
end

statsOut.propMeans = cell2mat(cellfun(@mean,pooledSplitProp,'UniformOutput',false));
statsOut.propSEMs = cell2mat(cellfun(@standarderrorSL,pooledSplitProp,'UniformOutput',false));

end