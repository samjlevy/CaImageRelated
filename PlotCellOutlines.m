function [figHand] = PlotCellOutlines(imageA,cellsFill,bkgColor,outlineColor,fillColor,fillAlpha)

warning('off','MATLAB:polyshape:repairedBySimplify')

if isempty(fillColor)
    fillColor = outlineColor;
end
if isempty(fillAlpha)
    fillAlpha = 0.4;
end
if strcmpi(cellsFill,'all')
    cellsFill = 1:length(imageA);
end

outlinesA = cellfun(@bwboundaries,imageA,'UniformOutput',false);

figHand = figure;
axis; hold on

xlim([0.5 size(imageA{1},2)+0.5]);
ylim([0.5 size(imageA{1},1)+0.5]);
set(gca,'ydir','reverse')
set(gca,'color',bkgColor)
for oaI = 1:length(outlinesA)
    plot(outlinesA{oaI}{1}(:,2),outlinesA{oaI}{1}(:,1),outlineColor,'LineWidth',1)
end

for ocI = 1:length(cellsFill)
    polyA = polyshape(outlinesA{cellsFill(ocI)}{1}(:,2),outlinesA{cellsFill(ocI)}{1}(:,1));    
    patch(polyA.Vertices(:,1),polyA.Vertices(:,2),fillColor,'EdgeColor','none','FaceAlpha',fillAlpha)
end

figHand.Children.XTick = [];
figHand.Children.YTick = [];

warning('on','MATLAB:polyshape:repairedBySimplify')
end