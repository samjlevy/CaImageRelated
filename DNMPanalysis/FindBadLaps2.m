function [fixedEpochs, reporter] = FindBadLaps2(xPos, yPos, epochs)
inEpochs = epochs;

badFig = figure('name','FindBad','Position',[300 100 560*2 420*2]);
for thisE = 1:length(epochs)
    
    movingOn=0;
    while movingOn==0
    
    nowInds = [];
    indInds = [];
    for ee = 1:length(epochs(thisE).starts)
        nowInds = [nowInds, epochs(thisE).starts(ee):epochs(thisE).stops(ee)]; %#ok<AGROW>
        indInds = [indInds, ee*ones(1,(epochs(thisE).stops(ee)-epochs(thisE).starts(ee)+1))]; %#ok<AGROW>
    end
    
    figure(badFig);
    hold off
    plot(xPos,yPos,'.k','MarkerSize',8)
    hold on
    plot(xPos(nowInds),yPos(nowInds),'.m', 'MarkerSize', 10)
    plot(xPos(epochs(thisE).starts),yPos(epochs(thisE).starts),'.y', 'MarkerSize', 10)
    plot(xPos(epochs(thisE).stops),yPos(epochs(thisE).stops),'.y', 'MarkerSize', 10)
    set(gca,'Color',[0.8 0.8 0.8]);

    
    anyBad = input('any points are bad? 1/0 >');
    if anyBad == 1
        title('Click next to a bad point')
        figure(badFig)
        [xBad, yBad] = ginput(1);   
        [ idx ] = findclosest2D (xPos(nowInds), yPos(nowInds), xBad, yBad);
        
        meansX = [mean(xPos(epochs(thisE).starts)) mean(xPos(epochs(thisE).stops))];
        meansY = [mean(yPos(epochs(thisE).starts)) mean(yPos(epochs(thisE).stops))];
        [ startORend ] = findclosest2D (meansX, meansY, xBad, yBad);
        %use start or end as a switch to adjust starts or stops
        
        [newStart, newStop] = ManualLapAdjuster(xPos,yPos,start,stop);
        
        
        
    elseif anyBad==0
        movingOn = 1;
    elseif anyBad==2
        keyboard
    else
        movingOn = 0;
    end     
        
    end
    
    %Identify which were changed by comparing to original
    reporter{thisE} = diff([epochs(thisE).starts inEpochs(thisE).starts],1,2) |...
                      diff([epochs(thisE).stops inEpochs(thisE).stops],1,2)  ;  
end

close(badFig);

fixedEpochs = epochs;

end

