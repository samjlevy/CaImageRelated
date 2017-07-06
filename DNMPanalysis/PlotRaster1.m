function rastPlot = PlotRaster1(x_adj_cm,epochs,PSAbool,thisCell)
%thisCell = 119;

plotLabels = {'Study Left','Study Right','Test Left','Test Right'};
plotColors = [1 0 0.65;... %magenta
              0 0.65 1;... %cyan
              1 0 0;... %red
              0 0 1];   %blue
              

rastPlot = figure('name','Raster Plot','Position',[100 50 1000 800]);

for cond=1:4
    subHand(cond)=subplot(2,2,cond);
    starts = epochs(cond).starts;
    stops = epochs(cond).stops;
    for thisLap = 1:length(starts)
        thesePoints = find(PSAbool(thisCell,starts(thisLap):stops(thisLap)))...
                        + starts(thisLap)-1;
        %rastPlot;
        hold on
        for point = 1:length(thesePoints)
            plot(60-[x_adj_cm(thesePoints(point)) x_adj_cm(thesePoints(point))],...
                 [0 5]+5*(thisLap-1),'Color',plotColors(cond,:))
        end
    end
    
    title(plotLabels{cond})
    subHand(cond).YTick = (1:length(starts))*5-2.5;
    subHand(cond).YTickLabel = {1:length(starts)};
    ylabel('Lap number')
    xlabel('X position (cm)')
    %xlim([25 60])
    xlim([0 35])
    ylim([0 5*length(starts)])

end

labelBorder = uicontrol('style','text','BackgroundColor',[0 0 0],...
    'Position',[460,748,106,29],'Parent',rastPlot);

cellLabel = uicontrol('style','text','String',...
    ['Cell # ' num2str(thisCell)],...
    'BackgroundColor',[1 1 1],'FontWeight','bold',...
    'Position',[463,750,100,25],'FontSize',12,'Parent',rastPlot);

end
