function [fixedEpochs] = AddressLapPts(x_adj_cm,y_adj_cm,epochs)

disp('Add a velocity thresholder here...')
for thisE = 1:length(epochs)
    
    movingOn=0;
    while movingOn==0
    
    numLaps = length(epochs(thisE).starts);
    
    nowInds = [];
    indInds = [];
    for ee = 1:length(epochs(thisE).starts)
        nowInds = [nowInds, epochs(thisE).starts(ee):epochs(thisE).stops(ee)]; %#ok<AGROW>
        indInds = [indInds, ee*ones(1,(epochs(thisE).stops(ee)-epochs(thisE).starts(ee)+1))]; %#ok<AGROW>
    end
     
    badFig = figure('name','FindBad','Position',[300 100 560*1.5 420*1.5]);
    plot(x_adj_cm,y_adj_cm,'.k','MarkerSize',8)
    hold on
    plot(x_adj_cm(nowInds),y_adj_cm(nowInds),'.m', 'MarkerSize', 10)
    plot(x_adj_cm(epochs(thisE).starts),y_adj_cm(epochs(thisE).starts),'.y', 'MarkerSize', 10)
    plot(x_adj_cm(epochs(thisE).stops),y_adj_cm(epochs(thisE).stops),'.y', 'MarkerSize', 10)
    set(gca,'Color',[0.8 0.8 0.8]);
    plot(mazeBoundary(:,1),mazeBoundary(:,2),'g')
    
    switch num2str(input('Are there any bad pts to fix? (0/1)>>','s'))
        case 0
            movingOn = 1;
        case 1
             figure(badFig)
            title('Click next to a bad point')
               [xBad, yBad] = ginput(1);   
       [ idx ] = findclosest2D (x_adj_cm(nowInds), y_adj_cm(nowInds), xBad, yBad);
       badLap = epochs(thisE).starts(indInds(idx)):epochs(thisE).stops(indInds(idx));
        badLapNum = indInds(idx);
        
        figure(badFig);
        hold off
        set(gca,'Color',[0.8 0.8 0.8]);
        plot(x_adj_cm,y_adj_cm,'.k','MarkerSize',8)
        hold on
        plot(x_adj_cm(badLap), y_adj_cm(badLap), '.m', 'MarkerSize', 10)
        plot(x_adj_cm([badLap(1) badLap(end)]), y_adj_cm([badLap(1) badLap(end)]), '.y', 'MarkerSize', 10)
        
        title('Draw a polygon around the pts that are bad')
        [h] = impoly;
        pb = getPosition(h);
        
        [inB,onB] = inpolygon(x_adj_cm(badLap), y_adj_cm(badLap),pb(:,1),pb(:,2));
        inpoly = inB | onB;
        
        plot(x_adj_cm(badLap(inpoly)), y_adj_cm(badLap(inpoly)), '.g', 'MarkerSize', 10)
        
        keyboard
        disp(['You selected ' num2str(sum(inpoly)) ' pts');
        if strcmpi(input('View pts? (y/n)>>','s'),'y');
            disp(['Lap spans ' num2str(epochs(thisE).starts(badLapNum)) ' to ' num2str(epochs(thisE).stops(badLapNum)) ', bad pts are:'])
            disp(num2str(find(inPoly)+epochs(thisE).starts(badLapNum)-1))
        end
        disp('What do do with the bad points?')
        
        % Interpolate
        
        % Delete, only possible if include lapstart or end
    end
    
    end
end
fixedEpochs = epochs;

end