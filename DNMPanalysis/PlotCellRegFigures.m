function [figA,figB,mixFig] = PlotCellRegFigures(imagePathA,varNameA,cellsUseA,imagePathB,varNameB,cellsUseB,otherCellsPlot)
%Can give this a path or variable (must be cell array), if path then tell
%what the variable name is
%otherCellsPlot should be a cell array where, in each cell arr, list the
%cells (indexed to that session) that you want to plot centers. cell 1 goes
%to session a, cell 2 to sess b, 3 is cells from a on overlay, 4 is cells
%from b on overlay
if isempty(otherCellsPlot)
    otherCellsPlot = cell(4,1);
end
if iscell(imagePathA)
    imageA = imagePathA;
else
    load(imagePathA,varNameA)
    imageA = eval(varNameA);
end
if any(cellsUseA)
    imageA = imageA(cellsUseA);
end

if iscell(imagePathB)
    imageB = imagePathB;
else
    load(imagePathB,varNameB)
    imageB = eval(varNameB);
end
if any(cellsUseB)
    imageB = imageB(cellsUseB);
end

% Style original
%{
maskA = create_AllICmask(imageA);
centersA = getAllCellCenters(imageA);

maskB = create_AllICmask(imageB);
centersB = getAllCellCenters(imageB);

figA = figure; imagesc(maskA); title('Session A cell masks')
if length(otherCellsPlot{1})>0
    hold on; plot(centersA(otherCellsPlot{1},1),centersA(otherCellsPlot{1},2),'+')
end

figB = figure; imagesc(maskB); title('Session A cell masks')
if length(otherCellsPlot{2})>0
    hold on; plot(centersB(otherCellsPlot{2},1),centersB(otherCellsPlot{2},2),'+')
end

[overlay,overlayRef] = imfuse(maskA,maskB,'ColorChannels',[1 2 0]);
mixFig = figure; w=imshow(overlay,overlayRef);
if length(otherCellsPlot{3})>0
   hold on; plot(centersA(otherCellsPlot{3},1),centersA(otherCellsPlot{3},2),'+c')
end 
if length(otherCellsPlot{4})>0
   hold on; plot(centersA(otherCellsPlot{4},1),centersA(otherCellsPlot{4},2),'+m')
end 
%}

%Style new
%{
colorList = [...
    0.8500    0.3250    0.0980;...   
    0.4940    0.1840    0.5560;...
    0.4660    0.6740    0.1880;...
    0.6350    0.0780    0.1840;...
         0    0.5000         0;...
    1.0000         0         0;...
    0.7500         0    0.7500;...
    0.2500    0.2500    0.2500;...
         0         1         1;...
         0         1         0;...
    0.9294    0.6902    0.1294];
%}
colorList = [0 1 0];
outlinesA = cellfun(@bwboundaries,imageA,'UniformOutput',false);
figA = figure; axis; hold on
xlim([0.5 size(imageA{1},2)+0.5]);
ylim([0.5 size(imageA{1},1)+0.5]);
set(gca,'ydir','reverse')
for oaI = 1:length(outlinesA)
    plot(outlinesA{oaI}{1}(:,2),outlinesA{oaI}{1}(:,1),'r','LineWidth',1)
end
colorInd = 0;
for ocI = 1:size(otherCellsPlot,1)
    polyA = polyshape(outlinesA{otherCellsPlot(ocI,1)}{1}(:,2),outlinesA{otherCellsPlot(ocI,1)}{1}(:,1));
    colorInd = colorInd + 1;
    if colorInd > size(colorList,1); colorInd = 1; end
    patch(polyA.Vertices(:,1),polyA.Vertices(:,2),colorList(colorInd,:),'EdgeColor','none','FaceAlpha',0.4)
end

outlinesB = cellfun(@bwboundaries,imageB,'UniformOutput',false);
figB = figure; axis; hold on
xlim([0.5 size(imageB{1},2)+0.5]);
ylim([0.5 size(imageB{1},1)+0.5]);
set(gca,'ydir','reverse')
for obI = 1:length(outlinesB)
    plot(outlinesB{obI}{1}(:,2),outlinesB{obI}{1}(:,1),'b','LineWidth',1)
end
colorInd = 0;
for ocI = 1:size(otherCellsPlot,1)
    polyB = polyshape(outlinesB{otherCellsPlot(ocI,2)}{1}(:,2),outlinesB{otherCellsPlot(ocI,2)}{1}(:,1));
    colorInd = colorInd + 1;
    if colorInd > size(colorList,1); colorInd = 1; end
    patch(polyB.Vertices(:,1),polyB.Vertices(:,2),colorList(colorInd,:),'EdgeColor','none','FaceAlpha',0.4)
end
[mixFig] = PlotOverlapFigure(imageA,imageB,otherCellsPlot,[]);

end

