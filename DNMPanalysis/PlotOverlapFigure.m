function [overlapFig] = PlotOverlapFigure(imageA,imageB,overlapCells,colorList)

outlinesA = cellfun(@bwboundaries,imageA,'UniformOutput',false);
outlinesB = cellfun(@bwboundaries,imageB,'UniformOutput',false);

overlapFig = figure; axis; hold on
xlim([0.5 size(imageA{1},2)+0.5]);
ylim([0.5 size(imageA{1},1)+0.5]);
set(gca,'ydir','reverse')
for oaI = 1:length(outlinesA)
    plot(outlinesA{oaI}{1}(:,2),outlinesA{oaI}{1}(:,1),'r','LineWidth',1)
end
for obI = 1:length(outlinesB)
    plot(outlinesB{obI}{1}(:,2),outlinesB{obI}{1}(:,1),'b','LineWidth',1)
end

colorInd = 0; 
%colorUse = 'm';
colorUse = 'g';
for ocI = 1:size(overlapCells,1)
    polyA = polyshape(outlinesA{overlapCells(ocI,1)}{1}(:,2),outlinesA{overlapCells(ocI,1)}{1}(:,1));
    polyB = polyshape(outlinesB{overlapCells(ocI,2)}{1}(:,2),outlinesB{overlapCells(ocI,2)}{1}(:,1));
    
    matchedArea = intersect(polyA,polyB);
    
    %Or cycle through colors [0.4902 0.1804 0.5608]
    if any(colorList)
        colorInd = colorInd + 1;
        if colorInd > size(colorList,1); colorInd = 1; end
        colorUse = colorList(colorInd,:);
    end
    
    patch(matchedArea.Vertices(:,1),matchedArea.Vertices(:,2),colorUse,'EdgeColor','none','FaceAlpha',0.45)
end
    
end