function figHand = PlotDotplotDoublePlus(daybyday,cellPlot,realDays,figOrientation) 
if isempty(figOrientation)
    figOrientation = 'horizontal';
end
switch figOrientation
    case 'horizontal'
        numRows = 1;
        numCols = 3;
        figPos = [65 398 1775 580];
    case 'vertical'
        numRows = 3;
        numCols = 1;
        figPos = [1076 67 633 915];
end

if ~strcmpi(figOrientation,'individual')
    figHand=figure('Position',figPos);
    blkSize = 5;
    redSize = 8;
end

if strcmpi(figOrientation,'individual')
   blkSize = 3;
   redSize = 5;    
end

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
    
    if strcmpi(figOrientation,'individual')
        figHand{sessI} = figure;%('Position',indivPos);
    else
        subplot(numRows,numCols,sessI)
    end
    plot(xPos,yPos,'.k','MarkerSize',blkSize)
    hold on
    plot(xPos(PSAhere),yPos(PSAhere),'.r','MarkerSize',redSize)
    axis equal
    xlim([-60 60])
    ylim([-60 60])
    title(['Day ' num2str(realDays(sessI))])
end

end