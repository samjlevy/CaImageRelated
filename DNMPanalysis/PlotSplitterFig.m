function PlotSplitterFig(TMap, pairsPlot, LRpairs, STpairs, xLimit, figHand)
%pairs plot is the pairs to plot against each other. It will split in half
%along the column dim and mean the included things if theres more than one
%per pair. E.g., [1 2 3 4] will plot mean(1 2) against mean(3 4)
%Indicate which rows of pairs are LR and ST
% EG. pairsPlot = [1 2 3 4; 1 3 2 4]; LRpairs = 1; ST pairs = 2;
%Use xThresh to say how wide to make the x axis, or leave it empty for auto
%determined
posLims = [0.5 1];

plotColors = {'g'  'r'   'c'  'm'};
            %Left Right Study Test

if isempty(figHand)
    figure;
end

if isempty(xLimit)
        %maxHere = max([propsA(:); propsB(:)]);
        maxHere = max([TMap{:}]);
        xLimit = posLims(min(find(posLims > maxHere)));
end

numPlots = size(pairsPlot,1);
numRows = 2; 
numCols = 1;

numBins = length(TMap{1});

for plotI = 1:numPlots
    hh = subplot(numRows, numCols, plotI); %axes;
    propsA = [TMap{pairsPlot(plotI,1:size(pairsPlot,2)/2)}];
    propsB = [TMap{pairsPlot(plotI,size(pairsPlot,2)/2+1:end)}];
    
    propsA = [propsA(1:numBins)' propsA(numBins+1:end)'];
    propsB = [propsB(1:numBins)' propsB(numBins+1:end)'];
    
    propsA = mean(propsA,2);
    propsB = mean(propsB,2);
    
    if sum(LRpairs==plotI) == 1
        %LRorST = 1;
        colorH = plotColors([1 2]); 
        axLab = 'LEFT                RIGHT';
    elseif sum(STpairs==plotI) == 1
        %LRorST = 2;
        colorH = plotColors([3 4]); 
        axLab = 'STUDY               TEST';
    end
    
    for binI = 1:numBins
        rectangle('Position',[-propsA(binI) binI propsA(binI) 1],'FaceColor',colorH{1});
        rectangle('Position',[0 binI propsB(binI)  1],'FaceColor',colorH{2});
    end
    
    xlim([-xLimit xLimit])
    box on
    xlabel(axLab); ylabel('Bin #')
    hh.YTick = 1.5:1:numBins+0.5;
    hh.YTickLabel = cellstr(num2str([1:numBins]'))';
    ylim([1 numBins+1])
    title('Transient Likelihood')
end

end
   

