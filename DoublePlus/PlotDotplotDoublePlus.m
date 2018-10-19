function figHand = PlotDotplotDoublePlus(daybyday,cellPlot,realDays) 


figHand=figure('Position',[65 398 1775 580]);
for sessI = 1:3
    bStarts = []; bStops = [];
    lapsFetch = [daybyday.behavior{sessI}(:).goodSequence] & [daybyday.behavior{sessI}(:).isCorrect];
    bStarts = [daybyday.behavior{sessI}(lapsFetch).startLap];
    bStops = [daybyday.behavior{sessI}(lapsFetch).endLap];
    
    xPos = []; yPos = []; PSAhere = [];
    for bI = 1:length(bStarts)
        xPos = [xPos daybyday.all_x_adj_cm{sessI}(bStarts(bI):bStops(bI))];
        yPos = [yPos daybyday.all_y_adj_cm{sessI}(bStarts(bI):bStops(bI))];
        PSAhere = [PSAhere daybyday.PSAbool{sessI}(cellPlot,bStarts(bI):bStops(bI))];
    end
    PSAhere = logical(PSAhere);
    
    subplot(1,3,sessI)
    plot(xPos,yPos,'.k','MarkerSize',5)
    hold on
    plot(xPos(PSAhere),yPos(PSAhere),'.r','MarkerSize',8)
    axis equal
    xlim([-60 60])
    ylim([-60 60])
    title(['Day ' num2str(realDays(sessI))])
end

end