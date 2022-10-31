function [fixedEpochs, reporter] = FindBadLaps(x_adj_cm, y_adj_cm, epochs)
inEpochs = epochs;

badFig = figure('name','FindBad','Position',[358 150.5000 883 653.5000]); %[300 100 560*2 420*2]);
for thisE = 1:numel(epochs)
    
    %deleteLaps = false(length(epochs(thisE).starts),1);
    
    movingOn=0;
    while movingOn==0
    
    % All inds aggregated
    nowInds = [];
    indInds = [];
    for ee = 1:length(epochs(thisE).starts)
        nowInds = [nowInds, epochs(thisE).starts(ee):epochs(thisE).stops(ee)]; %#ok<AGROW>
        %indInds = [indInds, ee*ones(1,(epochs(thisE).stops(ee)-epochs(thisE).starts(ee)+1))]; %#ok<AGROW>
        framesHH = epochs(thisE).starts(ee):epochs(thisE).stops(ee);
        indInds = [indInds, ee*ones(1,length(framesHH))];
            % this is which lap...
    end
    anynanH = isnan(x_adj_cm(nowInds)) | isnan(y_adj_cm(nowInds));
    if any(anynanH)
        disp('Found some nan values in laps:')
        badIndss = indInds(anynanH); % labs with nan
        
        lapsWithNan = unique(badIndss);
        for lapI = lapsWithNan
            startH = epochs(thisE).starts(lapI);
            stopH = epochs(thisE).stops(lapI);
            anynanH = isnan(x_adj_cm(startH:stopH)) | isnan(y_adj_cm(startH:stopH));
            if find(anynanH==0,1,'first')-1==sum(anynanH)
                epochs(thisE).starts(lapI) = epochs(thisE).starts(lapI)+find(anynanH==0,1,'first')-1;
            else
                disp('mmmmmm')
                keyboard
            end
        end   
    end
    
    figure(badFig);
    hold off
    plot(x_adj_cm,y_adj_cm,'.k','MarkerSize',8)
    hold on
    plot(x_adj_cm(nowInds),y_adj_cm(nowInds),'.m', 'MarkerSize', 10)
    plot(x_adj_cm(epochs(thisE).starts),y_adj_cm(epochs(thisE).starts),'.y', 'MarkerSize', 10)
    plot(x_adj_cm(epochs(thisE).stops),y_adj_cm(epochs(thisE).stops),'.c', 'MarkerSize', 10)
    set(gca,'Color',[0.8 0.8 0.8]);
    
    anyBad = input('any points are bad? 1/0 >');
    if anyBad == 1
        notAletter=true;
        while notAletter==true
            switch input('Starts/Ends or all? (s/a)>> ','s')
                case 's'
                    indsCheck = [epochs(thisE).starts; epochs(thisE).stops];
                    indIndsH = [1:length(epochs(thisE).starts), 1:length(epochs(thisE).starts)];
                    notAletter=false;
                case 'a'
                    indsCheck = nowInds;
                    indIndsH = indInds;
                    notAletter=false;
                otherwise
                    notAletter = true;
            end
        end
        title('Click next to a bad point')
        figure(badFig)
        [xBad, yBad] = ginput(1);   
        %[ idx ] = findclosest2D (x_adj_cm(nowInds), y_adj_cm(nowInds), xBad, yBad);
        [ idx ] = findclosest2D (x_adj_cm(indsCheck), y_adj_cm(indsCheck), xBad, yBad);
        
        %badLap = epochs(thisE).starts(indInds(idx)):epochs(thisE).stops(indInds(idx));
        %badLapNum = indInds(idx);
        badLap = epochs(thisE).starts(indIndsH(idx)):epochs(thisE).stops(indIndsH(idx));
        badLapNum = indIndsH(idx);
        
        %meansX = [mean(x_adj_cm(epochs(thisE).starts)) mean(x_adj_cm(epochs(thisE).stops))];
        %meansY = [mean(y_adj_cm(epochs(thisE).starts)) mean(y_adj_cm(epochs(thisE).stops))];
        %[ startORend ] = findclosest2D (meansX, meansY, xBad, yBad);
        [ startORend ] = findclosest2D (x_adj_cm([badLap(1) badLap(end)]), y_adj_cm([badLap(1) badLap(end)]), xBad, yBad);
        %use start or end as a switch to adjust starts or stops
        
        figure(badFig);
        hold off
        set(gca,'Color',[0.8 0.8 0.8]);
        plot(x_adj_cm,y_adj_cm,'.k','MarkerSize',8)
        hold on
        %badLap = epochs(thisE).starts(indInds(idx)):epochs(thisE).stops(indInds(idx));
        %badLapNum = indInds(idx);
        plot(x_adj_cm(badLap), y_adj_cm(badLap), '.m', 'MarkerSize', 10)
        plot(x_adj_cm([badLap(1) badLap(end)]), y_adj_cm([badLap(1) badLap(end)]), '.y', 'MarkerSize', 10)
        
        switch startORend
            case 1
                plotHere = 1;
                findingA = 'start';
            case 2
                plotHere = length(badLap);
                findingA = 'end';
        end
        
        doneFinding = 0;
        %bounds = [1 length(badLap)];
        while doneFinding == 0
            figure(badFig);
            title(['finding a new ' findingA])
            set(gca,'Color',[0.8 0.8 0.8]);
            plot(x_adj_cm,y_adj_cm,'.k','MarkerSize',8)
            hold on
            badLap = epochs(thisE).starts(badLapNum):epochs(thisE).stops(badLapNum);
            plot(x_adj_cm(badLap), y_adj_cm(badLap), '.m', 'MarkerSize', 10)
            switch startORend
                case 1
                    stillGood = plotHere:length(badLap); 
                case 2
                    stillGood = 1:plotHere;
            end
            plot(x_adj_cm(badLap(stillGood)), y_adj_cm(badLap(stillGood)), '.c', 'MarkerSize', 10)
            plot(x_adj_cm([badLap(1) badLap(end)]), y_adj_cm([badLap(1) badLap(end)]), '.y', 'MarkerSize', 10)
            plot(x_adj_cm(badLap(plotHere)), y_adj_cm(badLap(plotHere)), '.r', 'MarkerSize', 10)
            plot(x_adj_cm(badLap(plotHere)), y_adj_cm(badLap(plotHere)), 'or', 'MarkerSize', 10)

            ss = input('Next point or previous? (a/d, j jump, m for done, r for frames) > ','s');
            switch ss
                case 'a'
                    if plotHere > 1; plotHere = plotHere - 1; end
                case 'd'
                    if plotHere < length(badLap); plotHere = plotHere + 1; end
                case 'm'
                    doneFinding = 1;  
                    switch startORend
                        case 1
                            epochs(thisE).starts(badLapNum) = badLap(plotHere);
                        case 2
                            epochs(thisE).stops(badLapNum) = badLap(plotHere);
                    end
                    %{
                case 'x'
                    if strcmpi(input('Mark this lap for deletion? (y/n)>>','s'),'y')
                        if strcmpi(input('Really though? (yy)>>','s'),'yy')
                            disp(['Deleting lap ' badLapNum])
                            deleteLaps(badLapNum) = true;
                        end
                    end
                      %}  
                case 'j'
                    figure(badFig);
                    [nbx, nby] = ginput(1);
                    [ bidx ] = findclosest2D (x_adj_cm(badLap), y_adj_cm(badLap), nbx, nby);
                    plotHere = bidx;
                case 'r'
                    disp(['This lap is from ' num2str(epochs(thisE).starts(badLapNum)) ' to ' num2str(epochs(thisE).stops(badLapNum))])
            end
        end
        
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

    %epochs(thisE).starts(deleteLaps) = [];
    %epochs(thisE).stops(deleteLaps) = [];
end

close(badFig);

fixedEpochs = epochs;

end

