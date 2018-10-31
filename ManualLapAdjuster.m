function [newStart, newStop] = ManualLapAdjuster(xPos,yPos,start,stop)
origStart = start;
origStop = stop;

nowInds = start:stop;
badFig = figure;
plot(xPos,yPos,'.k','MarkerSize',8); hold on
set(gca,'Color',[0.8 0.8 0.8]);
plot(xPos(nowInds),yPos(nowInds),'.m', 'MarkerSize', 10)

doneTrimming = 0;
while doneTrimming==0
    needTrim = input('Does this lap need trimming? (y/n)>>','s');
    if strcmpi(needTrim,'y')
        doneTrimming = 0;
    elseif strcmpi(needTrim,'n')
        doneTrimming = 1;
    end

    if doneTrimming == 0
        
title('Click next to a bad point')
[xBad, yBad] = ginput(1);   
        
meansX = xPos([start stop]);
meansY = yPos([start stop]);
[startORend] = findclosest2D (meansX, meansY, xBad, yBad);
        %use start or end as a switch to adjust starts or stops
        
plot(xPos([start stop]), yPos([start stop]), '.y', 'MarkerSize', 10)
        
switch startORend
    case 1
        plotHere = 1;
        findingA = 'start';
    case 2
        plotHere = length(nowInds);
        findingA = 'end';
end
        
doneFinding = 0;
      
while doneFinding == 0
    figure(badFig); hold off
    title(['finding a new ' findingA])
    set(gca,'Color',[0.8 0.8 0.8]);
    plot(xPos,yPos,'.k','MarkerSize',8); hold on
    plot(xPos(nowInds),yPos(nowInds),'.m', 'MarkerSize', 10)
    switch startORend
        case 1
            stillGood = plotHere:length(nowInds);
        case 2
            stillGood = 1:plotHere;
    end
    plot(xPos(nowInds(stillGood)), yPos(nowInds(stillGood)), '.c', 'MarkerSize', 10)
    plot(xPos([nowInds(1) nowInds(end)]), yPos([nowInds(1) nowInds(end)]), '.y', 'MarkerSize', 10)
    plot(xPos(nowInds(plotHere)), yPos(nowInds(plotHere)), '.r', 'MarkerSize', 10)
    plot(xPos(nowInds(plotHere)), yPos(nowInds(plotHere)), 'or', 'MarkerSize', 10)

    ss = input('Next point or previous? (a/d, j jump, m for done, r for frames) > ','s');
    switch ss
        case 'a'
            if plotHere > 1; plotHere = plotHere - 1; end
        case 'd'
            if plotHere < length(nowInds); plotHere = plotHere + 1; end
        case 'm'
            doneFinding = 1;
            switch startORend
                case 1
                    newStart = nowInds(plotHere);
                    newStop = stop;
                case 2
                    newStop = nowInds(plotHere);
                    newStart = start;
            end
        case 'j'
            figure(badFig);
            [nbx, nby] = ginput(1);
            [ bidx ] = findclosest2D (xPos(nowInds), yPos(nowInds), nbx, nby);
            plotHere = bidx;
        case 'r'
            disp(['This lap is from ' num2str(start) ' to ' num2str(stop)])
    end
end
        start = newStart;
        stop = newStop;
        nowInds = start:stop;
    end
end

end