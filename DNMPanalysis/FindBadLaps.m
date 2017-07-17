function FindBadLaps(x_adj_cm, y_adj_cm, epochs)

for thisE = 1:length(epochs)
    nowInds = [];
    indInds = [];
    for ee = 1:length(epochs(thisE).starts)
        nowInds = [nowInds, epochs(thisE).starts(ee):epochs(thisE).stops(ee)]; %#ok<AGROW>
        indInds = [indInds, ee*ones(1,(epochs(thisE).stops(ee)-epochs(thisE).starts(ee)+1))]; %#ok<AGROW>
    end
    
    figure(badFig);
    plot(x_adj_cm,y_adj_cm,'.k','MarkerSize',8)
    hold on
    plot(x_adj_cm(nowInds),y_adj_cm(nowInds),'.m', 'MarkerSize', 10)
    plot(x_adj_cm(epochs(thisE).starts),y_adj_cm(epochs(thisE).starts),'.y', 'MarkerSize', 10)
    plot(x_adj_cm(epochs(thisE).stops),y_adj_cm(epochs(thisE).stops),'.y', 'MarkerSize', 10)
    set(gca,'Color',[0.8 0.8 0.8]);

    movingOn=0;
    while movingOn==0
        anyBad = input('any points are bad? 1/0 >');
        if anyBad == 1
        title('Click next to a bad point')
        [xBad, yBad] = ginput(1);   
        [ idx ] = findclosest2D (x_adj_cm(nowInds), y_adj_cm(nowInds), xBad, yBad);
        hold off
        badFig = figure('name','FindBad');
        set(gca,'Color',[0.8 0.8 0.8]);
        plot(x_adj_cm,y_adj_cm,'.k','MarkerSize',8)
        hold on
        badLap = epochs(thisE).starts(indInds(idx)):epochs(thisE).stops(indInds(idx));
        plot(x_adj_cm(badLap), y_adj_cm(badLap), '.m', 'MarkerSize', 10)
        plot(x_adj_cm([badLap(1) badLap(end)]), y_adj_cm([badLap(1) badLap(end)]), '.y', 'MarkerSize', 10)
        
        doneFinding = 0;
        plotHere = 1;
        while doneFinding == 0
            figure(badFig);
            title('finding a new start')
            set(gca,'Color',[0.8 0.8 0.8]);
            plot(x_adj_cm,y_adj_cm,'.k','MarkerSize',8)
            hold on
            badLap = epochs(thisE).starts(indInds(idx)):epochs(thisE).stops(indInds(idx));
            plot(x_adj_cm(badLap), y_adj_cm(badLap), '.m', 'MarkerSize', 10)
            plot(x_adj_cm(badLap(plotHere:end)), y_adj_cm(badLap(plotHere:end)), '.c', 'MarkerSize', 10)
            plot(x_adj_cm([badLap(1) badLap(end)]), y_adj_cm([badLap(1) badLap(end)]), '.y', 'MarkerSize', 10)
            plot(x_adj_cm(badLap(plotHere)), y_adj_cm(badLap(plotHere)), '.r', 'MarkerSize', 10)
            plot(x_adj_cm(badLap(plotHere)), y_adj_cm(badLap(plotHere)), 'or', 'MarkerSize', 10)

            ss = input('Next point or previous? (a/d, m for done) > ','s');
            switch ss
                case 'a'
                    if plotHere > 1; plotHere = plotHere - 1; end
                case 'd'
                    if plotHere < length(badLap); plotHere = plotHere + 1; end
                case 'm'
                    doneFinding = 1;  
                    epochs(thisE).starts(badLap) = badLap(plotHere);
            end
        end
        
        else
            movingOn = 1;
        end     
        
    end
    
    close(badFig);
end
end

