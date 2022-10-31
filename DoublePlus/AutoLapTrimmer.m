function [trimmedBehavior] = AutoLapTrimmer(xAll,yAll,mazeBoundaries,nBoundRegions,originalBehavior,buffer)

% This is a function to auto trim a lap down to the longest sequence of
% points that spans the whole region, adds a buffer of pts to the start or
% end buffer pts long (to handle interpolation)

% This to be run during make daybyday to finalize behavior time stamps
trimmedBehavior = originalBehavior;
numLaps = numel(originalBehavior.LapStart);
deleteLaps = false(numLaps,1);

armLabels = 'nwse';
for rr = 1:numel(armLabels)
    %{
    bbHere = mazeBoundaries.labels == armLabels(rr);
    xPts = mazeBoundaries.X(bbHere,:); yPts = mazeBoundaries.Y(bbHere,:);
    xPts = xPts(:); yPts = yPts(:);
    ptDistances = hypot(abs(xPts - mean(xPts)),abs(yPts - mean(yPts)));
    [srtedDists,srtOrder] = sort(ptDistances,1,'descend');

    xPsorted = xPts(srtOrder); yPsorted = yPts(srtOrder);

    armBoundX{rr} = xPsorted(1:4);
    armBoundY{rr} = yPsorted(1:4);
    %}

    bbHere = mazeBoundaries.labels == armLabels(rr);
    xPts = mazeBoundaries.X(bbHere,:); yPts = mazeBoundaries.Y(bbHere,:);
    xPts = xPts(:); yPts = yPts(:);
    k = convhull(xPts,yPts);
    
    armBoundX{rr} = xPts(k(1:end-1));
    armBoundY{rr} = yPts(k(1:end-1));


end

for lapI = 1:numLaps

    thisLap = [originalBehavior.LapStart(lapI) originalBehavior.LapStop(lapI)];
    lapFrames = thisLap(1):thisLap(2);
    armSeq = originalBehavior.ArmSequence{lapI};

    if (numel(armSeq) == 1) || originalBehavior.ArmSequence{lapI}(end)=='m'
        if (numel(armSeq) == 1)
        disp('Found a lap length 1')
        elseif originalBehavior.ArmSequence{lapI}(end)=='m'
            disp('Lap ends in M')
        end
        gtg = figure('Position',[87 177 560 420]);
        plot(xAll,yAll,'.k')
        hold on
        plot(xAll(lapFrames),yAll(lapFrames),'.m')
        plot(xAll(lapFrames(1)),yAll(lapFrames(1)),'.y')
        plot(xAll(lapFrames(end)),yAll(lapFrames(end)),'.c')
        %plot(armBoundX{armInd},armBoundY{armInd},'*g')
        title(['Supposed sequence: ' originalBehavior.ArmSequence{lapI} ', frames ' num2str(thisLap)])
        disp(['This lap bounds are ' num2str(originalBehavior.LapStart(lapI)) '-' num2str(originalBehavior.LapStop(lapI))])
        disp(['Prev lap ends ' num2str(originalBehavior.LapStop(lapI-1)) ', next lap starts ' num2str(originalBehavior.LapStart(lapI+1))])

        switch input('Delete this lap (d), not (n), or other (o)','s')
            case 'd'
                deleteLaps(lapI) = true;
                try 
                    close(gtg);                
                end
            case 'n'
                try 
                    close(gtg);                
                end
            case 'o'
                keyboard
        end
    end

    if deleteLaps(lapI) == false
    % Trim off chunk of start lap
    startArm = originalBehavior.ArmSequence{lapI}(1);
    if sum(originalBehavior.ArmSequence{lapI} == startArm) > 1
        % Restrict to first start epoch
        firstNotStartOrMid = find(armSeq~=startArm & armSeq~='m',1,'first');
        thisLap = [thisLap(1) originalBehavior.SeqEpochs{lapI}(firstNotStartOrMid-1,2)];
        lapFrames = thisLap(1):thisLap(2);
    end
    armInd = find(armLabels == originalBehavior.ArmSequence{lapI}(1));
    try
    [inArm,onArm] = inpolygon(xAll(thisLap(1):thisLap(2)),yAll(thisLap(1):thisLap(2)),armBoundX{armInd},armBoundY{armInd});
    catch
        keyboard
    end
    inArm = inArm | onArm;

    if sum(inArm)==0
        disp(['Something is really wrong with lap ' num2str(lapI)])
        
        keyboard
    end

    [onsets,offsets] = GetBinaryWindows(inArm);
    % For each of these, check if it fills the full arm havePts == nBoundRegions
    epochComplete = false(numel(onsets),1);
    
    for inI = 1:numel(onsets)
        havePts = CheckForPtsInRegion(xAll(lapFrames(onsets(inI):offsets(inI))),yAll(lapFrames(onsets(inI):offsets(inI))),armBoundX{armInd},armBoundY{armInd},originalBehavior.ArmSequence{lapI}(1),nBoundRegions);
        epochComplete(inI) = sum(havePts) == nBoundRegions;
    end
    
    
    %in theory only one should fullfill this;
    % count the lap start as either the current lap start, or start of this epoch - buffer
    switch sum(epochComplete)
        case 1
            lapStartP = lapFrames(onsets(find(epochComplete,1,'first')));
            lapStart = max([lapStartP-buffer, thisLap(1)]);
        case 0
            eFig = figure('Position',[32 236 1747 420]);
            for eI = 1:numel(onsets)
                subplot(1,numel(onsets),eI)
                plot(xAll,yAll,'.k')
                hold on
                hold on
                plot(xAll(thisLap(1):thisLap(2)),yAll(thisLap(1):thisLap(2)),'.m')
                plot(xAll(lapFrames(onsets(eI):offsets(eI))),yAll(lapFrames(onsets(eI):offsets(eI))),'.c')
                plot(armBoundX{armInd},armBoundY{armInd},'*g')
                title(['Epoch ' num2str(eI) ', frames ' num2str(lapFrames(onsets(eI))) ' - ' num2str(lapFrames(offsets(eI)))]) 
            end
            switch input('Use a start here (u), something else (o)>','s')
                case 'u'
                    eKeep = str2double(input('Enter the number of the epoch start to use:','s'));
                    lapStartP = lapFrames(onsets(eKeep));
                    lapStart = min([lapStartP-buffer, thisLap(1)]);
                otherwise
                    keyboard
            end
            try
                close(eFig);
            end
        otherwise
            % For starts, use the first one
            lapStartP = lapFrames(onsets(find(epochComplete,1,'first')));
            lapStart = max([lapStartP-buffer, thisLap(1)]);
            % For lap end, use the first one too?
    end

    trimmedBehavior.LapStart(lapI) = lapStart;
    if lapStart > trimmedBehavior.SeqEpochs{lapI}(1,2)
        %  This may not work since we
    % might lose an epoch that isn't complete...
        keyboard
    else
        trimmedBehavior.SeqEpochs{lapI}(1,1) = lapStart;
    end
    %repeat the whole thing for the last sequence on the lap

    thisLap = [trimmedBehavior.LapStart(lapI) originalBehavior.LapStop(lapI)];
    lapFrames = thisLap(1):thisLap(2);
    armSeq = originalBehavior.ArmSequence{lapI};

    % Trim off chunk of start lap
    endArm = originalBehavior.ArmSequence{lapI}(1);
    if sum(originalBehavior.ArmSequence{lapI} == endArm) > 1
        % Restrict to first start epoch
        lastNotEndOrMid = find(armSeq~=startArm & armSeq~='m',1,'last');
        thisLap = [originalBehavior.SeqEpochs{lapI}(lastNotEndOrMid-1,2) thisLap(2)];
        lapFrames = thisLap(1):thisLap(2);
    end

    if originalBehavior.ArmSequence{lapI}(end)~='m'
    armInd = find(armLabels == originalBehavior.ArmSequence{lapI}(end));
    if isempty(armInd)
        att = figure('Position',[208 115 560 420]);
        plot(xAll,yAll,'.k')
        hold on
        plot(xAll(thisLap(1):thisLap(2)),yAll(thisLap(1):thisLap(2)),'.m')
        disp(['Sequence here: ' originalBehavior.ArmSequence{lapI}])
        disp(['Bad sequence here, lap ends in ' originalBehavior.ArmSequence{lapI}(end) ' and this is not accounted for'])
        if strcmpi(input('Change the behavioral sequence listed?','s'),'y')
            newSeq = input('What is the correct sequence:','s')
            originalBehavior.ArmSequence{lapI} = newSeq;
            armInd = find(armLabels == originalBehavior.ArmSequence{lapI}(end));
            if isempty(armInd)
                disp('Still does not work')
                keyboard
            end
        else
            keyboard
        end
    end
    try
        close(att);        
    end

    [inArm,onArm] = inpolygon(xAll(thisLap(1):thisLap(2)),yAll(thisLap(1):thisLap(2)),armBoundX{armInd},armBoundY{armInd});
    inArm = inArm | onArm;
    [onsets,offsets] = GetBinaryWindows(inArm);
    % For each of these, check if it fills the full arm havePts == nBoundRegions
    epochComplete = false(numel(onsets),1);
    for inI = 1:numel(onsets)
        havePts = CheckForPtsInRegion(xAll(lapFrames(onsets(inI):offsets(inI))),yAll(lapFrames(onsets(inI):offsets(inI))),armBoundX{armInd},armBoundY{armInd},originalBehavior.ArmSequence{lapI}(end),nBoundRegions);
        epochComplete(inI) = sum(havePts) == nBoundRegions;
    end


    switch sum(epochComplete)
        case 1
            lapEndP = lapFrames(offsets(find(epochComplete,1,'first')));
            lapEnd = min([lapEndP+buffer, thisLap(2)]);
        case 0
            %keyboard
            eFig = figure('Position',[32 236 1747 420]);
            for eI = 1:numel(onsets)
                subplot(1,numel(onsets),eI)
                plot(xAll,yAll,'.k')
                hold on
                plot(xAll(thisLap(1):thisLap(2)),yAll(thisLap(1):thisLap(2)),'.m')
                plot(xAll(lapFrames(onsets(eI):offsets(eI))),yAll(lapFrames(onsets(eI):offsets(eI))),'.c')
                plot(armBoundX{armInd},armBoundY{armInd},'*g')
                title(['Epoch ' num2str(eI) ', frames ' num2str(lapFrames(onsets(eI))) ' - ' num2str(lapFrames(offsets(eI)))]) 
            end
            switch input('Use an end here (u), something else (o)>','s')
                case 'u'
                    eKeep = str2double(input('Enter the number of the epoch end to use:','s'));
                    lapEndP = lapFrames(offsets(eKeep));
                    lapEnd = min([lapEndP+buffer, thisLap(2)]);
                otherwise
                    keyboard
            end
            try
                close(eFig);
            end
        otherwise
            % For starts, use the first one
            lapEndP = lapFrames(offsets(find(epochComplete,1,'first')));
            lapEnd = min([lapEndP+buffer, thisLap(2)]);
            % For lap end, use the first one too?
    end

    trimmedBehavior.LapStop(lapI) = lapEnd;
    if lapEnd < trimmedBehavior.SeqEpochs{lapI}(end,1)
        cch = figure('Position',[32 236 1747 420]);
        plot(xAll,yAll,'.k')
        hold on
        plot(xAll(thisLap(1):lapEnd),yAll(thisLap(1):lapEnd),'.c')
        if strcmpi(input('Does this look ok? (y/n)','s'),'y')
            % Do nothing, keep going
            try
                close(cch);    
            end
        else
            keyboard
        end
    else
        trimmedBehavior.SeqEpochs{lapI}(end,2) = lapEnd;
    end
    end

    end
    %{
        figure; 
        plot(xAll,yAll,'.k')
        hold on
        plot(xAll(thisLap(1):thisLap(2)),yAll(thisLap(1):thisLap(2)),'.m')
        plot(xAll(lapFrames(inArm)),yAll(lapFrames(inArm)),'.c')
        plot(armBoundX{armInd},armBoundY{armInd},'*r')
    %}
    
end

trimmedBehavior.ArmSequence(deleteLaps) = [];
trimmedBehavior.LapStart(deleteLaps) = [];
trimmedBehavior.LapStop(deleteLaps) = [];
trimmedBehavior.SeqEpochs(deleteLaps) = [];

%{
figure;
plot(xAll,yAll,'.k')
hold on
for lapI = 1:numLaps
    plot(xAll(trimmedBehaviorTable.LapStart(lapI):trimmedBehaviorTable.LapStop(lapI)),yAll(trimmedBehaviorTable.LapStart(lapI):trimmedBehaviorTable.LapStop(lapI)),'.m')
end
%}
end


function havePts = CheckForPtsInRegion(xHr,yHr,boundsX,boundsY,armH,nBoundRegions)
havePts = false(nBoundRegions,1);
switch armH
    case {'s','n'}
        yCheck = linspace(min(boundsY),max(boundsY),nBoundRegions+1);
        havePts = false(nBoundRegions,1);
        for yy = 1:nBoundRegions
            havePts(yy) = any( (yHr >= yCheck(yy)) & (yHr <= yCheck(yy+1)) );
        end
    case {'e','w'}
        xCheck = linspace(min(boundsX),max(boundsX),nBoundRegions+1);

        for xx = 1:nBoundRegions
            havePts(xx) = any( (xHr >= xCheck(xx)) & (xHr <= xCheck(xx+1)) );
        end
end

end
