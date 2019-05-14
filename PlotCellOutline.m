function figHand = PlotCellOutline(filepath,cellNum,squareRadius)
%Plots the outline of a cell, for use with single cell examples
%cellNum needs to be in the num from that day (get from cellSSI)

bkgColor = [0 0 0];
allColor = [0.6510    0.6510    0.6510];
allOutlineColor = [0.9020    0.9020    0.9020];
tCellColor = [0 1 0]; %[0.3020    0.7490    0.9294];
tCellOutlineColor = [1 1 0]; %[0.9294    0.6902    0.1294];

colorsPlot = [bkgColor; allColor; allOutlineColor; tCellColor; tCellOutlineColor];

if iscell(filepath)
    numDays = length(filepath);
else 
    numDays = 1;
    filepath = {filepath};
end

figHand = [];
for dayI = 1:numDays
    cellImages = load(fullfile(filepath{dayI},'FinalOutput.mat'),'NeuronImage');
    numCells = length(cellImages.NeuronImage);
    
    allCells = create_AllICmask(cellImages.NeuronImage);

    allCellsImage = zeros(size(allCells,1),size(allCells,2),3);
    
    %Convert to colors
    [pRows,pCols] = ind2sub(size(allCells),find(allCells));
    for ppI = 1:length(pRows)
        allCellsImage(pRows(ppI),pCols(ppI),:) = colorsPlot(2,:);
    end
    
    %Make outlines
    for cellI = 1:numCells
        bw = bwboundaries(cellImages.NeuronImage{cellI});
        bww = bw{1};
        for ppI = 1:size(bww,1)
            allCellsImage(bww(ppI,1),bww(ppI,2),:) = colorsPlot(3,:);
        end
    end
    
    %Plot the target cell as a unique color, and its outline
    [pRows,pCols] = ind2sub(size(allCells),find(cellImages.NeuronImage{cellNum(dayI)}));
    for ppI = 1:length(pRows)
        allCellsImage(pRows(ppI),pCols(ppI),:) = colorsPlot(4,:);
    end
    bw = bwboundaries(cellImages.NeuronImage{cellNum(dayI)});
    bww = bw{1};
    for ppI = 1:size(bww,1)
        allCellsImage(bww(ppI,1),bww(ppI,2),:) = colorsPlot(5,:);
    end
    
    %Get just the chunk of the image from this cell center to box edges
    cellCenters = getAllCellCenters(cellImages.NeuronImage);
    targetCenter = round(cellCenters(cellNum(dayI),:));
    plotImage = allCellsImage(targetCenter(2)-squareRadius:targetCenter(2)+squareRadius,... 
                              targetCenter(1)-squareRadius:targetCenter(1)+squareRadius, :);  
    
    %Plot this thing
    figHand{dayI} = figure('Position',[702 332 506 405]);
   
    imagesc(plotImage)
    axis off
    box off
    title(['Cell Outline, plot day ' num2str(dayI) ', cell ' num2str(cellNum(dayI))])
end

end