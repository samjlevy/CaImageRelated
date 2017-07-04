thisCell = 119;

plotLabels = {'Study Left','Study Right','Test Left','Test Right'};

rastPlot = figure('name','Raster Plot');
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
            plot([x_adj_cm(thesePoints(point)) x_adj_cm(thesePoints(point))],...
                 [0 5]+5*(thisLap-1),'k')
        end
    end
    
    title(plotLabels{cond})
    subHand(cond).YTick = (1:length(starts))*5-2.5;
    subHand(cond).YTickLabel = {1:length(starts)};
    ylabel('Lap number')
    xlabel('X position (cm)')
    xlim([25 60])
    ylim([0 5*length(starts)])

end