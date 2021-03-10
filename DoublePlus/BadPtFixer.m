function [fixedEpochs] = BadPtFixer(x_adj_cm, y_adj_cm, epochs, mazeBoundary)
%quick analysis, lap by lap, of any pts outside

for thisE = 1:length(epochs)
    
    %deleteLaps = false(length(epochs(thisE).starts),1);
    numLaps = length(epochs(thisE).starts);
    
    %{
    % All inds aggregated
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
    %}
    
    for lapI = 1:numLaps
        % Check for lap start nans
        theseF = epochs(thisE).starts(lapI):epochs(thisE).stops(lapI);
        anyNan = isnan(x_adj_cm(theseF)) | isnan(y_adj_cm(theseF));
        
        if anyNan(1)==true
            firstNans = find(anyNan==0,1,'first');
            if firstNans < 10
                deleteFrames = 1:firstNans-1;
                theseF(deleteFrames) = [];
                epochs(thisE).starts(lapI) = theseF(1);
                disp(['Fixed a start NaN, lap ' num2str(lapI)])
            end
        end
        
        % Check for lap end nans
        theseF = epochs(thisE).starts(lapI):epochs(thisE).stops(lapI);
        anyNan = isnan(x_adj_cm(theseF)) | isnan(y_adj_cm(theseF));
        if anyNan(end)==true
            lastNans = find(anyNan==0,1,'last');
            if (length(theseF) - lastNans) < 10
                deleteFrames = (lastNans+1):length(theseF);
                theseF(deleteFrames) = [];
                epochs(thisE).stops(lapI) = theseF(end);
                disp(['Fixed a end NaN, lap ' num2str(lapI)])
            end
        end
            
        % Check for nans in the middle
        theseF = epochs(thisE).starts(lapI):epochs(thisE).stops(lapI);
        anyNan = isnan(x_adj_cm(theseF)) | isnan(y_adj_cm(theseF));
        if sum(anyNan) > 0
            keyboard
            disp(['Fixed a middle NaN, lap ' num2str(lapI)])
        end 
    end
    
    startX = x_adj_cm(epochs(thisE).starts);
    stopX = x_adj_cm(epochs(thisE).stops);
    startY = y_adj_cm(epochs(thisE).starts);
    stopY = y_adj_cm(epochs(thisE).stops);
    lapInds = [1:numLaps, 1:numLaps];
    xps = [startX(:); stopX(:)];
    yps = [startY(:); stopY(:)];
    
    [inB,onB] = inpolygon(xps,yps,mazeBoundary(:,1),mazeBoundary(:,2));
    outofBound = ~(inB | onB);
    
    % plot(xps(outofBound),yps(outofBound),'.r')
    outofBoundStart = outofBound(1:numLaps);
    outofBoundStop = outofBound(numLaps+(1:numLaps));
    for lapI=1:numLaps
        if outofBoundStart(lapI) == true
             %ptDists = GetPtFromPtsDist([startX(lapI) startY(lapI)],otherPts)
             theseF = epochs(thisE).starts(lapI):epochs(thisE).stops(lapI);
             [inB,onB] = inpolygon(x_adj_cm(theseF),y_adj_cm(theseF),mazeBoundary(:,1),mazeBoundary(:,2));
             inBound = inB | onB;
             firstIn = find(inBound,1,'first');
             if firstIn < 10
                 epochs(thisE).starts(lapI) = theseF(firstIn);
                 disp(['Fixed a start out of bounds for lap ' num2str(lapI)])
             else
                 keyboard
             end
        end
        
        if outofBoundStop(lapI) == true
             theseF = epochs(thisE).starts(lapI):epochs(thisE).stops(lapI);
             numHere = length(theseF);
             [inB,onB] = inpolygon(x_adj_cm(theseF),y_adj_cm(theseF),mazeBoundary(:,1),mazeBoundary(:,2));
             inBound = inB | onB;
             lastIn = find(inBound,1,'last');
             if (numHere-lastIn) < 10
                 epochs(thisE).stops(lapI) = theseF(lastIn);
                 disp(['Fixed a stop out of bounds for lap ' num2str(lapI)])
             else
                 keyboard
             end
        end 
    end
    
end

fixedEpochs = epochs;

end
