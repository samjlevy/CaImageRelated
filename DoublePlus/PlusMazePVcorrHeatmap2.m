function figHand = PlusMazePVcorrHeatmap2(plotRateMaps,plotBinVertices,colorMapUse)

binX = plotBinVertices{1};
binY = plotBinVertices{2};
numPlotBins = size(plotBinVertices{1},1);

xBounds = [min(min(binX)) max(max(binX))];
yBounds = [min(min(binY)) max(max(binY))];

figure; cmap = colormap(colorMapUse); close;
%cRange = [min(min(plotRateMaps)) max(max(plotRateMaps))];
cRange = [0 0.4];
cInd = linspace(min(cRange),max(cRange),size(cmap,1));

figHand = figure; hold on
for binI = 1:numPlotBins
    binXhere = [binX(binI,:) binX(binI,1)];
    binYhere = [binY(binI,:) binY(binI,1)];
    colorHere = cmap(findclosest(plotRateMaps(binI),cInd),:);
    patch(binXhere,binYhere,colorHere,'EdgeColor','k','LineWidth',1)
    
    %Bin outline
    %plot(,,'k','LineWidth',1)
end

xlim(xBounds+[-1 1])
ylim(yBounds+[-1 1])

colorbar('Ticks',[0 0.5 1],'TickLabels',[min(cRange) mean(cRange) max(cRange)]);
colormap(colorMapUse)

end