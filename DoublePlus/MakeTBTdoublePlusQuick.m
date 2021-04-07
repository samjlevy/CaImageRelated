function MakeTBTdoublePlusQuick(daybyday,allfiles,sortedSessionInds)

mainFolder = 'F:\DoublePlus';
load(fullfile(mainFolder,'behLimits.mat'))

numSess = length(daybyday.all_x_adj_cm);

for sessI = 1:numSess 
    if sessI==1 
        tempTBT.trialsX = {};
        tempTBT.trialsY = {};
        tempTBT.trialPSAbool = {};
        tempTBT.trialRawTrace = {};
        tempTBT.sessID = [];
        tempTBT.sessDay = [];
        tempTBT.lapNumber = [];
        tempTBT.isCorrect = [];
        tempTBT.allowedFix = [];
        tempTBT.MazeID = [];
        tempTBT.startArm = {};
        tempTBT.endArm = {};
        tempTBT.rewardArm = {};
        tempTBT.lapSequence = {};
        tempTBT.rule = {};
    end
    lapsSoFar = length(tempTBT.trialsX);
    
if ~isempty(daybyday.behavior{sessI})    
    
    numTrials = height(daybyday.behavior{sessI});
        
    lapStarts = daybyday.behavior{sessI}.LapStart;
    lapStops = daybyday.behavior{sessI}.LapStop;
    
    % Verify order
    if any(diff(lapStarts)<1)
        disp('Lap starts out of order')
        keyboard
    end
    if any(diff(lapStops)<1)
        disp('Lap stops out of order')
        keyboard
    end
    if any([lapStops - lapStarts]<1)
        disp('Lap start/stop out of order')
        keyboard
    end
    
    mazeSize = daybyday.mazeSize{sessI};
    switch mazeSize
        case {'Small','small'}
            mazeAnchor = load(fullfile(mainFolder,'smallPosAnchor.mat'));
            startLims = smallStarts;
            rewardLims = smallRewards;
            
            nArmBins = 6;
            smAnchor = load(fullfile(mainFolder,'smallPosAnchor.mat'));
            [dataBins,smPlotBins] = SmallPlusBounds(smAnchor.posAnchorIdeal,nArmBins);
            [centerBound, armBound] = ArmEndBounds(dataBins,[0 0],2);
        case {'Large','large'}
            mazeAnchor = load(fullfile(mainFolder,'mainPosAnchor.mat'));
            startLims = largeStarts;
            rewardLims = largeRewards;
            
            
            nArmBins = 14;
            lgAnchor = load(fullfile(mainFolder,'mainPosAnchor.mat'));
            [dataBins,lgPlotBins] = SmallPlusBounds(lgAnchor.posAnchorIdeal,nArmBins);
            [centerBound, armBound] = ArmEndBounds(dataBins,[0 0],2);
    end
    mazeEndBounds = [{centerBound}, armBound(:)'];
    boundLabels = {'m','n','e','s','w'};
    
    % Make some TBT
    for trialI = 1:numTrials
        
        noNans = false;
        while noNans == false
        lapStart = lapStarts(trialI);
        lapStop = lapStops(trialI);
        
        lapSeq = daybyday.behavior{sessI}.ArmSequence{trialI};
        
        xPosLap = daybyday.all_x_adj_cm{sessI}(lapStart:lapStop);
        yPosLap = daybyday.all_y_adj_cm{sessI}(lapStart:lapStop);
        
        if isnan(xPosLap(1))
            nanX = isnan(xPosLap);
            stopNan = find(nanX==0,1,'first');
            if stopNan < 10
                daybyday.behavior{sessI}.LapStart(trialI) = lapStart + stopNan-1;
                lapStarts = daybyday.behavior{sessI}.LapStart;
            else 
                disp('lot of nans...')
                keyboard
            end
        else
            noNans = true;
        end
        end
        
        % First point in bounds (last transition to in)
        switch lapSeq(1)
            case {'S','s'}
                startLimH = startLims(strcmpi(startLocs,'South'),2);
                startPoint = startLims(strcmpi(startLocs,'South'),:);
                outBounds = yPosLap < startLimH;
                inBounds = yPosLap >= startLimH;
                
                midPoint = mean([startLimH dataBins.Y(1,1)]);
                preMid = yPosLap < midPoint;
                postMid = yPosLap >= midPoint;
            case {'N','n'}
                startLimH = startLims(strcmpi(startLocs,'North'),2);
                startPoint = startLims(strcmpi(startLocs,'North'),:);
                outBounds = yPosLap > startLimH;
                inBounds = yPosLap <= startLimH;
                
                midPoint = mean([startLimH dataBins.Y(1,2)]);
                preMid = yPosLap > midPoint;
                postMid = yPosLap <= midPoint;
            otherwise
                switch lapSeq(1)
                    case {'E','e'}
                        startLimH = rewardLims(strcmpi(rewardLocs,'East'),1);
                        startPoint = rewardLims(strcmpi(rewardLocs,'East'),:);
                        outBounds = xPosLap > rewardLims(strcmpi(rewardLocs,'East'),1);
                        inBounds = xPosLap <= rewardLims(strcmpi(rewardLocs,'East'),1);
                        
                        midPoint = mean([startLimH dataBins.X(1,3)]);
                        preMid = yPosLap > midPoint;
                        postMid = yPosLap <= midPoint;
                    case {'W','w'} 
                        startLimH = rewardLims(strcmpi(rewardLocs,'West'),1);
                        startPoint = rewardLims(strcmpi(rewardLocs,'East'),:);
                        outBounds = xPosLap < rewardLims(strcmpi(rewardLocs,'West'),1);
                        inBounds = xPosLap >= rewardLims(strcmpi(rewardLocs,'West'),1);
                        
                        midPoint = mean([startLimH dataBins.X(1,1)]);
                        preMid = yPosLap < midPoint;
                        postMid = yPosLap >= midPoint;
                    otherwise
                        
                disp('bad start maybe')
                keyboard
                end
        end
        boundsStatus = nan(size(yPosLap));
        boundsStatus(outBounds) = 0;
        boundsStatus(inBounds) = 1;
        % aa = [outBounds(:), inBounds(:)];
        %{
        figure; plot(xPosLap,yPosLap,'.'); hold on; 
        plot([-10 10],startLimH*[1 1],'k')
        plot([-10 10],midPoint*[1 1],'r')
        
        %}
        %goesIn = find((inBounds(2:end) - outBounds(1:end-1))==0 & (inBounds(2:end) | outBounds(1:end-1))); % 2nd is to catch NaN pos
        try
            goesIn = find(diff(boundsStatus)==1);
            if isempty(goesIn)
                ptDists = GetPtFromPtsDist(startPoint,[xPosLap(:) yPosLap(:)]);
                [minDist,minInd] = min(ptDists);
                goesIn = minInd-1;
            end

            midStatus = nan(size(yPosLap));
            midStatus(preMid) = 0;
            midStatus(postMid) = 1;

            entersMid = find(diff(midStatus)==1);

            %Calling lap start the last time it leaves starting area before the
            %first time it enters the mid
            %entersMid(entersMid <= goesIn(1)) = [];
            firstMidEnter = entersMid(1);
            goesIn(goesIn>firstMidEnter) = [];
            parsedLapStart = goesIn(end)+1;
        catch
            if strcmpi(input(['Failed to start, expected ' lapSeq(1) '; enter a new frame num (y/n)? >>'],'s'),'y')
              goesIn = str2double(input('Enter start frame number: ','s'))-1;
              parsedLapStart = goesIn(end)+1;
            else
                disp('Not getting a start')
            end
        end
        
        
        % Last point in bounds (first transition to out)
        % Looking for crossings from in to out
        boundsStatus = nan(size(xPosLap));
        if lapSeq(end) == 'm'
            lapSeq(end) = [];
        end
        
        switch lapSeq(end)
            case {'E','e'}
                outBounds = xPosLap > rewardLims(strcmpi(rewardLocs,'East'),1);
                inBounds = xPosLap <= rewardLims(strcmpi(rewardLocs,'East'),1);
            case {'W','w'}
                outBounds = xPosLap < rewardLims(strcmpi(rewardLocs,'West'),1);
                inBounds = xPosLap >= rewardLims(strcmpi(rewardLocs,'West'),1);
            otherwise
                switch lapSeq(end)
                    case {'S','s'}
                        startLimH = startLims(strcmpi(startLocs,'South'),2);
                        outBounds = yPosLap < startLimH;
                        inBounds = yPosLap >= startLimH;
                    case {'N','n'}
                        startLimH = startLims(strcmpi(startLocs,'North'),2);
                        outBounds = yPosLap > startLimH;
                        inBounds = yPosLap <= startLimH;
                    otherwise
                        disp('Lap end sequence issue')
                        keyboard
               
                disp('Did not find an expected lap stop; which of these sequence inds would you like to use?')
                
                end
        end
        boundsStatus(outBounds) = 0;
        boundsStatus(inBounds) = 1;
        % aa = [outBounds(:), inBounds(:)];
        %{
        figure; plot(xPosLap,yPosLap,'.'); hold on; 
        plot([-10 10],startLimH*[1 1],'k')
        % plot([-10 10],midPoint*[1 1],'r')
        
        %}
        
        %goesOut = find((inBounds(2:end) - outBounds(1:end-1))==0 & (inBounds(2:end) | outBounds(1:end-1))); % 2nd is to catch NaN pos
        goesOut = find(diff(boundsStatus)==-1);
        if isempty(goesOut)
            if boundsStatus(end) == 1
                goesOut = length(boundsStatus);
            end
        end
        
        parsedLapEnd = goesOut(1);
        
        % Verify...
        if parsedLapEnd < parsedLapStart
            goesOut = goesOut(goesOut > parsedLapStart);
            goesOut(1);
            
        end
        
        if isempty(goesOut)
            disp('Parsing error...')
            
            ppFig = figure; plot(xPosLap,yPosLap,'.')
            hold on
            plot(xPosLap(parsedLapStart),yPosLap(parsedLapStart),'*r')
            plot(xPosLap(parsedLapEnd),yPosLap(parsedLapEnd),'*g')
            title(['start at ' num2str(parsedLapStart) ', end at ' num2str(parsedLapEnd)])
            
            disp('Still something a bit weird here...')
            [uniqueSeq,seqEpochs] = SingleTrialSequence(xPosLap,yPosLap,mazeEndBounds,5);
            seqEpochs(uniqueSeq == 0,:) = [];
            uniqueSeq(uniqueSeq==0) = [];
            bb = arrayfun(@(x) [boundLabels{x} ' '],uniqueSeq,'UniformOutput',false); cc = [bb{:}]; cc = cc(1:end-1);
            dd = 1:length(bb); ee = mat2cell(dd,1,ones(1,length(uniqueSeq))); ff = cellfun(@(x) [num2str(x) ' '],ee,'UniformOutput',false);
            gg = [ff{:}]; gg = gg(1:end-1);
            disp(['Sequence was: ' lapSeq])
            disp('Sequence found is :')
            disp(cc)
            disp(gg)
             
            %{
            if strcmpi(input('Fix the start? (y/n)>> ','s'),'y')
                goodInd = false;
                while goodInd == false
                    startEnt = str2double(input('Index of which pt in sequence? >>','s'))
                    if startEnt > 0 & startEnt <=(length(uniqueSeq)-1)
                        goodInd = true;
                        %???
                    end
                end
            end
            %}
            %{
            switch input('Sequence good (y) or change the end(n)? >>','s')
                case {'Y','y','1'}
                    % Get the boundaries that are closest to what we're
                    % looking for
                    
                    
                case {'N','n','0'}
                    if strcmpi(input('Fix the end? (y/n)>> ','s'),'y')
                    goodInd = false;
                  %}  
                while goodInd == false
                    indEnt = str2double(input('Index of which pt in sequence? >>','s'));
                    if (indEnt > 1) && (indEnt <=length(uniqueSeq))
                        disp('pop')
                        goodInd = true;
                        goesOut(goesOut < seqEpochs(indEnt,1)) = [];
                        parsedLapEnd = goesOut(1);
                    end
                end
            %end
            
            if parsedLapEnd < parsedLapStart
                disp('Parsing error...')
                keyboard
            end
            
            close(ppFig)
        end
        
        framesKeepHere = parsedLapStart:parsedLapEnd;   
        thisTrial = lapsSoFar+trialI;
        lapFrames = lapStart:lapStop; %Index within this lap
        framesKeepAll = lapFrames(framesKeepHere); % Index within whole session       
        
        % Something to pick out sessInd
        if sessI == 1
            sessInd = 1;
        else
            if trialI == 1
                sessInd = tempTBT.sessNumber(thisTrial-1)+1;
            elseif iscell(daybyday.sessType{sessI})
                if daybyday.behavior{sessI}.SessInd(trialI) ~= daybyday.behavior{sessI}.SessInd(trialI-1)
                    sessInd = tempTBT.sessNumber(thisTrial-1)+1;
                end
            end
        end
        
        if iscell(daybyday.sessType{sessI})
            if length(daybyday.sessType{sessI})>1
                rule = daybyday.sessType{sessI}{daybyday.behavior{sessI}.SessInd(trialI)};
            elseif length(daybyday.sessType{sessI})==1
                rule = daybyday.sessType(sessI);
            end
        elseif ischar(daybyday.sessType{sessI})
            rule = daybyday.sessType{sessI};
        end
            
        tempTBT.trialsX{thisTrial,1} = xPosLap(framesKeepHere);
        tempTBT.trialsY{thisTrial,1} = yPosLap(framesKeepHere);
        tempTBT.trialPSAbool{thisTrial,1} = daybyday.PSAbool{sessI}(:,framesKeepAll);
        tempTBT.trialRawTrace{thisTrial,1} = daybyday.RawTrace{sessI}(:,framesKeepAll);
        tempTBT.trialDFDTtrace{thisTrial,1} = daybyday.DFDTtrace{sessI}(:,framesKeepAll);
        tempTBT.sessID(thisTrial,1) = sessI;
        tempTBT.sessNumber(thisTrial,1) = sessInd;
        tempTBT.lapNumber(thisTrial,1) = trialI;
        tempTBT.isCorrect(thisTrial,1) = daybyday.behavior{sessI}.Correct(trialI);
        tempTBT.allowedFix(thisTrial,1) = daybyday.behavior{sessI}.AllowedFix(trialI);
        tempTBT.MazeID = [];
        tempTBT.startArm{thisTrial,1} = lapSeq(1);
        tempTBT.endArm{thisTrial,1} = lapSeq(end);
        tempTBT.rewardArm = {};
        tempTBT.lapSequence{thisTrial,1} = lapSeq;
        tempTBT.rule{thisTrial,1} = rule;
    end
    
    disp(['Finished assembling sess ' num2str(sessI)])
    
end
end
    
dlaps{1} = strcmpi(tempTBT.startArm,'n');
dlaps{2} = strcmpi(tempTBT.startArm,'s');

for ti = 1:2
    trialbytrialAll(ti).trialsX = [tempTBT(1).trialsX(dlaps{ti})];
    trialbytrialAll(ti).trialsY = [tempTBT(1).trialsY(dlaps{ti})];
    trialbytrialAll(ti).trialPSAbool = [tempTBT.trialPSAbool(dlaps{ti})];
    trialbytrialAll(ti).trialRawTrace = [tempTBT.trialRawTrace(dlaps{ti})];
    trialbytrialAll(ti).trialDFDTtrace = [tempTBT.trialDFDTtrace(dlaps{ti})];
    trialbytrialAll(ti).sessID = [tempTBT.sessID(dlaps{ti})];
    trialbytrialAll(ti).sessNumber = [tempTBT.sessNumber(dlaps{ti})];
    trialbytrialAll(ti).lapNumber = [tempTBT.lapNumber(dlaps{ti})];
    trialbytrialAll(ti).isCorrect = logical([tempTBT.isCorrect(dlaps{ti})]);
    trialbytrialAll(ti).allowedFix = [tempTBT.allowedFix(dlaps{ti})];
    trialbytrialAll(ti).MazeID = tempTBT.MazeID;
    trialbytrialAll(ti).startArm = [tempTBT.startArm(dlaps{ti})];
    trialbytrialAll(ti).endArm = [tempTBT.endArm(dlaps{ti})];
    trialbytrialAll(ti).rewardArm = tempTBT.rewardArm;
    trialbytrialAll(ti).lapSequence = [tempTBT.lapSequence(dlaps{ti})];
    trialbytrialAll(ti).rule = [tempTBT.rule(dlaps{ti})];
end

for ti = 1:2
    correctTrials = trialbytrialAll(ti).isCorrect;
    
    trialbytrial(ti).trialsX = [trialbytrialAll(ti).trialsX(correctTrials)];
    trialbytrial(ti).trialsY = [trialbytrialAll(ti).trialsY(correctTrials)];
    trialbytrial(ti).trialPSAbool = [trialbytrialAll(ti).trialPSAbool(correctTrials)];
    trialbytrial(ti).trialRawTrace = [trialbytrialAll(ti).trialRawTrace(correctTrials)];
    trialbytrial(ti).trialDFDTtrace = [trialbytrialAll(ti).trialDFDTtrace(correctTrials)];
    trialbytrial(ti).sessID = [trialbytrialAll(ti).sessID(correctTrials)];
    trialbytrial(ti).sessNumber = [trialbytrialAll(ti).sessNumber(correctTrials)];
    trialbytrial(ti).lapNumber = [trialbytrialAll(ti).lapNumber(correctTrials)];
    trialbytrial(ti).isCorrect = [trialbytrialAll(ti).isCorrect(correctTrials)];
    trialbytrial(ti).allowedFix = [trialbytrialAll(ti).allowedFix(correctTrials)];
    %trialbytrial(ti).MazeID = [trialbytrialAll(ti).MazeID(correctTrials)];
    trialbytrial(ti).startArm = [trialbytrialAll(ti).startArm(correctTrials)];
    trialbytrial(ti).endArm = [trialbytrialAll(ti).endArm(correctTrials)];
    %trialbytrial(ti).rewardArm = [trialbytrialAll(ti).rewardArm(correctTrials)];
    trialbytrial(ti).lapSequence = [trialbytrialAll(ti).lapSequence(correctTrials)];
    trialbytrial(ti).rule = [trialbytrialAll(ti).rule(correctTrials)];
    
end
    

%cd(mouseDir)
%load('fullReg.mat','fullReg')
%allfiles = fullReg.RegSessions;
%load('realDays.mat','realDays')
realDays = daybyday.realDays;
mouseDir = cd;
save(fullfile(mouseDir,'trialbytrial.mat'),'trialbytrial','trialbytrialAll','allfiles','sortedSessionInds','realDays','-v7.3')

end