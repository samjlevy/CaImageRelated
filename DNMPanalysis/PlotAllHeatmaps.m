function PlotAllHeatmaps(base_path, useCells, titles)

load(fullfile(base_path),'PFsLin.mat')

if isempty(useCells)
    useCells = find(~cellfun(@isempty,{TMap_gauss{:,1}}));
end

numCells = length(useCells);

vBord = 0.001;
blockHeight = (1 - 0.04 - vBord*(numCells+1)) / numCells;
hBord = 0.01;
blockWidth = (1 - 0.025*2 - hBord*5)/4;

tuningCurves = figure;
tuningCurves.OuterPosition = [0 0 850 1000];
tuningCurves.PaperPositionMode = 'auto';


for tc = 1:numCells
    thisCell = useCells(tc);
    theseTMaps = {TMap_gauss{thisCell,:}};
    maxRate = max([theseTMaps{:}]);
    
    for condType = 1:4
        %left bottom width height
        pv = [hBord + 0.025 + (hBord+blockWidth)*(condType-1)...
              1 - 0.04 - (vBord + blockHeight)*tc...
              blockWidth...
              blockHeight];
        aa(tc,condType) = subplot('Position',pv);
        imagesc(fliplr(theseTMaps{condType}))
        colormap jet
        caxis([0 maxRate]);
        aa(tc,condType).YTick = []; aa(tc,condType).YTickLabel = [];
        aa(tc,condType).XTick = []; aa(tc,condType).XTickLabel = [];
        if condType==1
            aa(tc,condType).YTick = mean(aa(tc,condType).YLim);
            aa(tc,condType).YTickLabel = (num2str(thisCell)); %tc
        end
        
        if tc == 1
            title(titles{condType});
        end
    end
end

end