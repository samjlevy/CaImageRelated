function FixTBTallEachIndexing
% This script is to replace/fix the indexing from trialbytrialAll to
% trialbytrialAllEach
% The output of this function sorts trials exclusively by which arm they
% happen on. Multiple "trials"/arm passes can happen from the same trial if
% the mouse is allowed to make corrections until it gets it right, but
% it will only take the first complete arm pass from each trial. So a trial
% that runs n w s w e will generate passes n w(1) e; n/s only get kept for
% start purposes. This will also mark which arm this lap started on, which
% arm it ended on, whether it was correct etc.

% Error arm entries:
errorBoundsTurn{1}.Y = lgDataBins.bounds.east.Y; errorBoundsTurn{1}.X = lgDataBins.bounds.east.X;
errorBoundsTurn{2}.Y = lgDataBins.bounds.west.Y; errorBoundsTurn{2}.X = lgDataBins.bounds.west.X;
errorBoundsPlace{1}.Y = lgDataBins.bounds.west.Y; errorBoundsPlace{1}.X = lgDataBins.bounds.west.X;
errorBoundsPlace{2}.Y = lgDataBins.bounds.west.Y; errorBoundsPlace{2}.X = lgDataBins.bounds.west.X;

for mouseI = 1:numMice
    load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'), 'trialbytrialAll')
    [errorTbtAllEachT] = BreakUpTrialbyTrial(trialbytrialAll,[1;2],errorBoundsTurn,'firstlast');
    [errorTbtAllEachP] = BreakUpTrialbyTrial(trialbytrialAll,[1;2],errorBoundsPlace,'firstlast');
    errorTBTallEach = errorTbtAllEachT; 
    for condI = 1:2
        for sessI =4:6
            sessTrials = errorTBTallEach(condI).sessID == sessI;
            errorTBTallEach(condI).trialsX(sessTrials,1) = errorTbtAllEachP(condI).trialsX(sessTrials,1);
            errorTBTallEach(condI).trialsY(sessTrials,1) = errorTbtAllEachP(condI).trialsY(sessTrials,1);
            errorTBTallEach(condI).trialPSAbool(sessTrials,1) = errorTbtAllEachP(condI).trialPSAbool(sessTrials,1);
            errorTBTallEach(condI).trialDFDTtrace(sessTrials,1) = errorTbtAllEachP(condI).trialDFDTtrace(sessTrials,1);
            errorTBTallEach(condI).trialRawTrace(sessTrials,1) = errorTbtAllEachP(condI).trialRawTrace(sessTrials,1);
        end
    end
    save(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'),'errorTBTallEach','-append')
end

% all order: n w s e
finalConds = ['n' 'w' 's' 'e'];
    % These are the conds in the final tbt; all E will end up in the same
    % cond (4), sort them for splitters based on start arm that trial

% All trial types, including error entries on fixed laps, = 
% - N/S trial starts from trialbytrialAllEach
% - W/E trial ends from trialbytrialAllEach for correct laps
% - W/E trial ends for error laps from errorTBTallEach
% - W/E entries from corrected laps from errorTBTallEach
% Original index can come from either trialbytrialAll or ...tbtAllEach
% - go through all that, gather all data needed, then just re-sort by lap number within sessions? 

load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'), 'trialbytrialAll','trialbytrialAllEach','errorTBTallEach')
ff = fieldnames(trialbytrialAllEach);
tbtForSplitters = struct([]);
for ffI = 1:length(ff)
    for condI = 1:4
        tbtForSplitters(condI).(ff{ffI}) = [];
        tbtForSplitters(condI).ArmName = finalConds(condI);
    end
end

for condI = 1:2
    nTrials = length(trialbytrialAll(condI).trialsX);
    for ffI = 1:length(ff)
        tbtForSplitters(condI*2-1).(ff{ffI}) = trialbytrialAllEach(condI*2-1).(ff{ffI});
    end
    tbtForSplitters(condI*2-1).sourceLap = [1:nTrials]';
    tbtForSplitters(condI*2-1).sourceCond = condI*ones(nTrials,1);
    
    for trialI = 1:nTrials
        seqHere = trialbytrialAll(condI).lapSequence{trialI};
        sessNum = trialbytrialAll(condI).sessID(trialI);
        
        % Set up expected sequence stuff
        sourceConds = ['n' 'w' 's' 'e']; % use with find to get ind in AllEach
        errorConds = ['e' 'w']; % same, but for errorTBTallEach
        if sum(sessNum == 4:6)==1
            sourceConds = ['n' 'e' 's' 'e']; %same, second step for aa=find..., aa(condI)
            errorConds = ['w' 'w'];
        end
        
        switch condI
            case 1
                startArm = 'n';
                endArm = 'w';
                errorArm = 'e';
                if sum(sessNum == 4:6)==1
                    endArm = 'e';
                    errorArm = 'w';
                end
            case 2
                startArm = 's';
                endArm = 'e';
                errorArm = 'w';
        end
        
        % Start arm data
        % Data from all each
        	% Do nothing, grabbed all together from trialbytrialAllEach
        
        % End arm data
        % Do need to run through this, conds 2/4 sometimes have empties
        destCond = find(finalConds==seqHere(end));
        destLap = length(tbtForSplitters(destCond).trialsX)+1;
        switch seqHere(end)
            case endArm
                % Get data from tbtAllEach, index should be same
                sourceCond = find(sourceConds==seqHere(end));
                if length(sourceCond)>1; sourceCond = sourceCond(condI); end
                for ffI = 1:length(ff)
                    switch class(trialbytrialAllEach(condI*2).(ff{ffI}))
                        case {'double','logical'}
                            tbtForSplitters(destCond).(ff{ffI})(destLap,1) = trialbytrialAllEach(sourceCond).(ff{ffI})(trialI,1);
                        case 'cell'
                            tbtForSplitters(destCond).(ff{ffI}){destLap,1} = trialbytrialAllEach(sourceCond).(ff{ffI}){trialI,1};
                    end
                end
                tbtForSplitters(destCond).sourceLap(destLap,1) = trialI;
                tbtForSplitters(destCond).sourceCond(destLap,1) = condI;
            case errorArm
                % Get data from errorTBTallEach
                %sourceCond = find(errorConds==seqHere(end));
                %sourceCond = sourceCond(condI);
                sourceCond = condI;
                for ffI = 1:length(ff)
                    switch class(trialbytrialAllEach(condI*2).(ff{ffI}))
                        case {'double','logical'}
                            tbtForSplitters(destCond).(ff{ffI})(destLap,1) = errorTBTallEach(sourceCond).(ff{ffI})(trialI,1);
                        case 'cell'
                            tbtForSplitters(destCond).(ff{ffI}){destLap,1} = errorTBTallEach(sourceCond).(ff{ffI}){trialI,1};
                    end
                end
                tbtForSplitters(destCond).sourceLap(destLap,1) = trialI;
                tbtForSplitters(destCond).sourceCond(destLap,1) = condI;
        end
        
        % Allowed fix and error entry datas
        if length(seqHere) > 3 && seqHere(end)~=errorArm
            % Verify error arm in this sequence
            if sum(seqHere==errorArm)>0
                % Get data from errorTBTallEach, verify lap number is right
                if errorTBTallEach(condI).lapNumber(trialI) == trialbytrialAllEach(condI*2).lapNumber(trialI)
                    destCond = find(finalConds==errorArm);
                    destLap = length(tbtForSplitters(destCond).trialsX)+1;
                    %sourceCond = find(errorConds==seqHere(end));
                    %if length(sourceCond)>1; sourceCond = sourceCond(condI); end
                    sourceCond = condI;
                    tbtForSplitters(destCond).sourceLap(destLap,1) = trialI;
                    tbtForSplitters(destCond).sourceCond(destLap,1) = condI;
                    for ffI = 1:length(ff)
                        switch class(trialbytrialAllEach(condI*2).(ff{ffI}))
                            case {'double','logical'}
                                tbtForSplitters(destCond).(ff{ffI})(destLap,1) = errorTBTallEach(sourceCond).(ff{ffI})(trialI,1);
                            case 'cell'
                                tbtForSplitters(destCond).(ff{ffI}){destLap,1} = errorTBTallEach(sourceCond).(ff{ffI}){trialI,1};
                        end
                    end
                else
                    keyboard
                end
                
            end
        end
            
        %{
        for ii = 1:20
        trialI = randi(259);
        
        condI = 2;
        lapI = trialI;
        condJ = condI;
        sessH = tbtForSplitters(condJ*2-1).sessID(lapI);
        figure; plot(trialbytrialAll(condJ).trialsX{lapI},trialbytrialAll(condJ).trialsY{lapI},'.k')
        hold on
        plot(tbtForSplitters(condJ*2-1).trialsX{lapI},tbtForSplitters(condJ*2-1).trialsY{lapI},'.g')
        xlim([-60 60]); ylim([-60 60])
        
        lapH = find(tbtForSplitters(2).sourceLap==lapI &...
                    tbtForSplitters(2).sessID==sessH &...
                    tbtForSplitters(2).sourceCond==condJ);
        if any(lapH)
            plot(tbtForSplitters(2).trialsX{lapH},tbtForSplitters(2).trialsY{lapH},'.c')
        end
        
        lapH = find(tbtForSplitters(4).sourceLap==lapI &...
                    tbtForSplitters(4).sessID==sessH &...
                    tbtForSplitters(4).sourceCond==condJ);
        if any(lapH)
            plot(tbtForSplitters(4).trialsX{lapH},tbtForSplitters(4).trialsY{lapH},'.m')
        end
        title(['lap ' num2str(trialI)])
        
        end
       %} 
       
        %Error is probably that source lap is doing absolute lap number, which is not unique across cond 1 vs 2
    end
end

for condI = 1:4
    for tii = 1:length(tbtForSplitters(condI).lapSequence)
        lss = tbtForSplitters(condI).lapSequence{tii};
        if length(lss)==2
            if sum(lss=='m')==0
                lss = [lss(1) 'm' lss(2)];
                tbtForSplitters(condI).lapSequence{tii} = lss;
            end
        end
    end
end
   

save(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'),'tbtForSplitters','-append')

% mouse 5, cond 2, trial 63 is coded wrong 
% mouse 6, cond 1, trials 28 and 101 cut off too early
    % Easiest solution is probably just to walk through each lap, get the
    % appropriate data for the trialtype where it's stored (validate
    % correct, allowed fix, etc,
    % maybe also take this opportunity to cut out the little lap nubs that
    % don't really have a full entry/part of the lap sequence
    seqLengths = cellfun(@numel,trialbytrialAll(condI).lapSequence);  
    longSeq = find(seqLengths>3);
    
    for lapJ = 1:length(longSeq)
        lapI = longSeq(lapJ);
        seqHere = trialbytrialAll(condI).lapSequence{lapI};
        % Check if extra arm entries are E or W
        
    
    
    


for sessI = 1:9
    % n w s e conds in tbtAllEach
    %eachConds = {'n' 'w' 's' 'e'};
    eachConds = 'nwse';
    if sum(sessI == 4:6)>0
        % different set of tbtAll -> tbtAllEach expectations
        %eachConds = {'n' 'e' 's' 'e'};
        eachConds = 'nese';
    end
    
    % Go through each trial and find laps, where they should end up
    for condI = 1:2
        switch condI
            case 1
                armsSeek = 'nwe';
                tbtAllCondIndices = [1 2 NaN];
                if sum(sessI == 4:6)>0
                    armsSeek = 'new';
                    tbtAllCondIndices = [1 2 NaN];
                end
                startArmEachCond = 1;
            case 2
                armsSeek = 'sew';
                tbtAllCondIndices = [3 4 NaN];
                if sum(sessI == 4:6)>0
                    % Do nothing
                end
                startArmEachCond = 3;
        end
        To get these error arm entries, we'll have to go back through with breakuptbt
        with the appropriate bins, seek the first complete pass through those bins,
        sort into our breakup tbt 
        Maybe the right move is to do this, then grab our sorted lap stuff?
        % In mouse2, cond 1, entri 91 our test case for getting lap
        % information right combining across these
        
        lapsH = trialbytrialAll(condI).sessID==sessI;
        lapInds = find(lapsH);
        lapNumsH = trialbytrialAll(condI).lapNumber(lapsH);
        
        % Can safely ignore start arm activity, that should be safely in
        % the all each, just make sure the start/end arm, lap number info
        % is correct
        
        lapsHeach = trialbytrialAllEach(condNum).sessID==sessI;
        lapIndsEach = find(lapsHeach);
            
        for trialI = 1:length(lapInds)
            seqHere = trialbytrialAll(condI).lapSequence{trialI};
            seqHere(seqHere=='m') = [];

            thisLapInd = lapInds(trialI);
                
            % Whole lap pos
            lapX = trialbytrialAll(condI).trialsX{thisLapInd};
            lapY = trialbytrialAll(condI).trialsY{thisLapInd};

            for condJ = 1:3
                condSeek = armsSeek(condJ);
                condNum = tbtAllCondIndices(condJ); % index in tbtAllEach for correct trials...
            
                if sum(seqHere==condSeek)>0 % Mouse entered this arm this lap
                    
                    
                if condJ < 3 % Get the pass from trialbytrialAllEach
                    
                elseif condJ == 3 % Get the pass from trialbytriallErrorEach
                    
                    % Lap start and end should be easy to find
                    thisCond = startArmEachCond;

                    thisLapIndEach = lapIndsEach(trialI);
                    if thisLapIndEach ~= thisLapInd
                        keyboard
                    end
                    
                    % Expected each pos
                    eachX = trialbytrialAllEach(thisCond).trialsX{thisLapIndEach};
                    eachY = trialbytrialAllEach(thisCond).trialsY{thisLapIndEach};

                    distThresh = 0.01;
                    [indsAligned] = ValidateEachPosAlignment(lapX,lapY,eachX,eachY,distThresh);
                    
                    ll(condJ).indInTbtAll(thisLapIndEach,1) = thisLapInd;
                    ll(condJ).posIndsTbtlap{thisLapIndEach,1} = indsAligned;
                    ll(condJ).isLapStart(thisLapIndEach,1) = true;
                else
                    condsH = find(seqHere==armsSeek(3));
                    if sum(sessI==4:6)==1
                        condsH = condsH(condI);
                    end
                    
                    % Mark whether this is the end of the lap
                end
            end
        end
    end
end

for condI = 1:2
    for sessI = 1:9
        lapsH = trialbytrialAll(condI).sessID==sessI;
        lapInds = find(lapsH);
        lapNumsH = trialbytrialAll(condI).lapNumber(lapsH);
        
        % In trialbytrialAllEach, conds 1 and 3 are easy (n/s)
        % Start arms
        condCheck = [1 3];
        for condJ = 1:2
            condJJ = condCheck(condJ);
            
            lapsHeach = trialbytrialAllEach(condJJ).sessID==sessI;
            lapIndsEach = find(lapsHeach);
            
            for lapI = 1:length(lapNumsH)
                
                ll(condJJ).lapInTbtAll(lapIndsEach(lapI)) = lapInds(lapI);
                
                lapX = trialbytrialAll(condI).trialsX{lapInds(lapI)};
                lapY = trialbytrialAll(condI).trialsY{lapInds(lapI)};
            
                eachX = trialbytrialAllEach(condJJ).trialsX{lapIndsEach(lapI)};
                eachY = trialbytrialAllEach(condJJ).trialsY{lapIndsEach(lapI)};
                
                
                xDiffs = eachX(:)-lapX(:)';
                yDiffs = eachY(:)-lapY(:)';
                
                distDiffs = hypot(xDiffs,yDiffs);
                [dd,dInd] = min(distDiffs,[],2);
                
                %{
                figure;
                plot(lapX,lapY,'.k')
                hold on
                plot(eachX,eachY,'.r')
                
                plot(lapX(dInd(1)),lapY(dInd(1)),'*g')
                plot(lapX(dInd(end)),lapY(dInd(end)),'*g')
                %}
                
                if sum(dd~=0)>0
                    keyboard
                end
                
                dInd(dd~=0) = [];
                if length(dInd) == length(unique(dInd))
                    ll(condJJ).tbtAllInds{lapIndsEach(lapI),1} = dInd(:);
                else
                    keyboard
                    ll(condJJ).tbtAllInds{lapIndsEach(lapI),1} = AssignDistMatches(distDiffs,0.01);
                end
                
            end
             
        % whats the deal for east on place days?
        % End arms
        condCheck = [2 4];
        for condJ = 1:2
            condJJ = condCheck(condJ);
                
            lapsHeach = trialbytrialAllEach(condJJ).sessID==sessI;
            lapIndsEach = find(lapsHeach);
            
            for lapI = 1:length(lapNumsH)
                