function [trialbytrial, allfiles, sortedSessionInds, realdays]= MakeTBTdoublePlus(mousePath,locInds,segmentUse)
%Task segment has to be one of the options in GetBlockDNMPbehavior

fdPts = strsplit(mousePath,'\');
finalDataRoot = fullfile(fdPts{1:end-1});
mouseName = fdPts{end};

load(fullfile(mousePath,'daybyday.mat'))

numSess = length(daybyday.all_x_adj_cm);

switch segmentUse
    case 'arm_only'
namesUse = {'north';  'south';  'east'; 'west'};%'midFromN'; 'midFromS'
fieldsUse = {'startLap' 'enterMid';...
             'startLap' 'enterMid';...
             'leaveMid' 'endLap';...
             'leaveMid' 'endLap'};
            %'enterMid' 'leaveMid'

beFieldsMarker = {'startLap' 'enterMid';...
                  'enterMid' 'leaveMid';...
                  'leaveMid' 'endLap'};
              
              
    case {'whole_trial';'on_maze'}
        namesUse = {'north';'south'};
        fieldsUse = {'startLap' 'endLap';...
                     'startLap' 'endLap'};
        withinLapLabel = {'startLap' 'enterMid';...
                          'enterMid' 'leaveMid';...
                          'leaveMid' 'endLap'};
        beFieldsMarker = {'startLap' 'enterMid';...
                  'enterMid' 'leaveMid';...
                  'leaveMid' 'endLap'};
end
              
              
for tI = 1:length(namesUse)
    trialbytrial(tI).name = namesUse{tI};
    trialbytrial(tI).trialsX = {};
    trialbytrial(tI).trialsY = {};
    trialbytrial(tI).trialPSAbool = {};
    trialbytrial(tI).trialRawTrace = {};
    trialbytrial(tI).sessID = [];
    trialbytrial(tI).lapNumber = [];
    trialbytrial(tI).isCorrect = [];
    trialbytrial(tI).withinLapMarker = [];
end

errorNames = {'eventuallyCorrectNorthStart','eventuallyCorrectSouthStart',...
                  'errorNorthWrongChoice','errorSouthWrongChoice','allOtherErrors'};
for eI = 1:length(errorNames)
    errorTBT(eI).name = errorNames{eI};
    %errorTBT(eI).lapEpochs = {};
    errorTBT(eI).trialsX = {};
    errorTBT(eI).trialsY = {};
    errorTBT(eI).trialPSAbool = {};
    errorTBT(eI).trialRawTrace = {};
    errorTBT(eI).sessID = [];
    errorTBT(eI).lapNumber = [];
    errorTBT(eI).withinLapMarker = [];
end
              
for sessI = 1:numSess
    sessType = useDataTable.SessType{sessI};
    goodSequences = PlusGoodSequences(sessType,locInds);

    southInd = find(strcmpi(locInds(:,2),'south'));
    northInd = find(strcmpi(locInds(:,2),'north'));
    eastInd = find(strcmpi(locInds(:,2),'east'));
    westInd = find(strcmpi(locInds(:,2),'west'));

    if iscell(daybyday.behavior{sessI})
        numTrials = length(daybyday.behavior{sessI});
    elseif istable(daybyday.behavior{sessI})
        numTrials = height(daybyday.behavior{sessI});
    end
    %Reorganize into cell arrays
    startMaze = []; startLap = []; enterMid = [];
    leaveMid = []; endLap = []; leaveMaze = [];
    isCorrect = []; goodSequence = []; trialDetail  = [];
    trialPhases = []; trialLength = []; rightLength = [];
    for trialI = 1:numTrials
        startMaze{trialI,1} = daybyday.behavior{sessI}(trialI).startMaze;
        startLap{trialI,1} = daybyday.behavior{sessI}(trialI).startLap;
        enterMid{trialI,1} = daybyday.behavior{sessI}(trialI).enterMid;
        leaveMid{trialI,1} = daybyday.behavior{sessI}(trialI).leaveMid;
        endLap{trialI,1} = daybyday.behavior{sessI}(trialI).endLap;
        leaveMaze{trialI,1} = daybyday.behavior{sessI}(trialI).leaveMaze;
        
        isCorrect(trialI,1) = daybyday.behavior{sessI}(trialI).isCorrect;
        goodSequence(trialI,1) = daybyday.behavior{sessI}(trialI).goodSequence;
        
        trialDetail{trialI,1} = daybyday.behavior{sessI}(trialI).order.allDetail;
        trialPhases{trialI,1} = daybyday.behavior{sessI}(trialI).order.all;
        
        trialLength(trialI,1) = length(trialDetail{trialI});
        rightLength(trialI,1) = trialLength(trialI) == 3;
    end    
    
    %might be able to bundle in the stuff here with ttI loop
    southStart = cell2mat(cellfun(@(x) x(1)==southInd,trialDetail,'UniformOutput',false));
    northStart = cell2mat(cellfun(@(x) x(1)==northInd,trialDetail,'UniformOutput',false));
    
    getsToEast = cell2mat(cellfun(@(x) any(find(x==eastInd)),trialDetail,'UniformOutput',false));
    getsToWest = cell2mat(cellfun(@(x) any(find(x==westInd)),trialDetail,'UniformOutput',false));
    getsToSouth = cell2mat(cellfun(@(x) any(find(x==southInd)),trialDetail,'UniformOutput',false));
    getsToNorth = cell2mat(cellfun(@(x) any(find(x==northInd)),trialDetail,'UniformOutput',false));
    
    errorSouthStart = southStart & isCorrect==0;
    errorNorthStart = northStart & isCorrect==0;
    
    switch sessType
        case 'turn'
            getsThere = northStart & getsToWest | southStart & getsToEast;
            
            errorNorthWrongChoice = northStart & rightLength & getsToEast;
            errorSouthWrongChoice = southStart & rightLength & getsToWest;
        case 'place'
            getsThere = northStart & getsToEast | southStart & getsToEast;
            
            errorNorthWrongChoice = northStart & rightLength & getsToWest;
            errorSouthWrongChoice = southStart & rightLength & getsToWest;
    end
    
    switch segmentUse
        case 'arm_only'
            lapType = {northStart; southStart; getsToEast; getsToWest};
        case {'whole_trial';'on_maze'}
            lapType = {northStart; southStart};
    end
    
    eventuallyCorrect = goodSequence==0 & getsThere;
    
    eventuallyCorrectNorthStart = eventuallyCorrect & northStart & getsThere;
    eventuallyCorrectSouthStart = eventuallyCorrect & southStart & getsThere;
    
    %errorSouthDoesntMakeIt = errorSouthStart & eventuallyCorrect==0;
    %errorNorthDoesntMakeIt = errorNorthStart & eventuallyCorrect==0;
    
    allOtherErrors = (errorNorthWrongChoice | errorSouthWrongChoice |...
                      eventuallyCorrectNorthStart | eventuallyCorrectSouthStart)==0 & isCorrect==0;
    
    %Bundle it all up nicely
    for ttI = 1:length(namesUse)        
        theseLaps = find(lapType{ttI} & goodSequence);% & isCorrect
        
        trialbytrial(ttI).sessID = [trialbytrial(ttI).sessID; sessI*ones(length(theseLaps),1)];
        trialbytrial(ttI).lapNumber = [trialbytrial(ttI).lapNumber; theseLaps];
        trialbytrial(ttI).isCorrect = [trialbytrial(ttI).sessID; isCorrect(theseLaps)];
        
        for lapI = 1:length(theseLaps)
            thisLap = theseLaps(lapI);
            lapStart = daybyday.behavior{sessI}(thisLap).(fieldsUse{ttI,1}); 
            lapEnd = daybyday.behavior{sessI}(thisLap).(fieldsUse{ttI,2});
            
            trialbytrial(ttI).trialsX = [trialbytrial(ttI).trialsX; daybyday.all_x_adj_cm{sessI}(lapStart:lapEnd)];
            trialbytrial(ttI).trialsY = [trialbytrial(ttI).trialsY; daybyday.all_y_adj_cm{sessI}(lapStart:lapEnd)];
            trialbytrial(ttI).trialPSAbool = [trialbytrial(ttI).trialPSAbool; daybyday.PSAbool{sessI}(:,lapStart:lapEnd)];
            trialbytrial(ttI).trialRawTrace = [trialbytrial(ttI).trialRawTrace; daybyday.RawTrace{sessI}(:,lapStart:lapEnd)];
            
            if exist('withinLapLabel','var')
                if ~exist('wllOffset','var')
                    wllOffset = zeros(size(withinLapLabel));
                end
                
                withinLapMarker = [];
                for wlI = 1:size(withinLapLabel)
                    eStart = daybyday.behavior{sessI}(thisLap).(withinLapLabel{wlI,1})+wllOffset(wlI,1);
                    eEnd = daybyday.behavior{sessI}(thisLap).(withinLapLabel{wlI,2})+wllOffset(wlI,2);
                    eLength = eEnd-eStart+1;
                    withinLapMarker = [withinLapMarker; wlI*ones(eLength,1);];
                end
                trialbytrial(ttI).withinLapMarker = [trialbytrial(ttI).withinLapMarker; withinLapMarker];
            end
        end    
    end
    
    %Errors
    errorLapType = {eventuallyCorrectNorthStart; eventuallyCorrectSouthStart;...
                    errorNorthWrongChoice; errorSouthWrongChoice; allOtherErrors};
    for eeI = 1:length(errorNames)        
        theseLaps = find(errorLapType{eeI});
        
        errorTBT(eeI).sessID = [errorTBT(eeI).sessID; sessI*ones(length(theseLaps),1)];
        errorTBT(eeI).lapNumber = [errorTBT(eeI).lapNumber; theseLaps];
        
        for lapI = 1:length(theseLaps)
            thisLap = theseLaps(lapI);
            lapDetail = trialDetail{thisLap};
            lapPhases = trialPhases{thisLap};
        
            lapAllFrames = daybyday.behavior{sessI}(thisLap);
            
            behPile = [];
            bfm = {beFieldsMarker{:}};
            for aa = 1:length(bfm)
                %getStuff(aa) = any(lapAllFrames.(bfm{aa})); 
                framesHere = lapAllFrames.(bfm{aa});
                behPile = [behPile; framesHere(:)];
            end
            
            nErrorLaps = length(errorTBT(eeI).trialsX);
            elUse = nErrorLaps+1;
            
            bStart = min(behPile); 
            bEnd = max(behPile);
            
            errorTBT(eeI).trialsX{elUse} = daybyday.all_x_adj_cm{sessI}(bStart:bEnd);
            errorTBT(eeI).trialsY{elUse} = daybyday.all_y_adj_cm{sessI}(bStart:bEnd);
            errorTBT(eeI).trialPSAbool{elUse} = daybyday.PSAbool{sessI}(:,bStart:bEnd);
            errorTBT(eeI).trialRawTrace{elUse} = daybyday.RawTrace{sessI}(:,bStart:bEnd);
                
            errorTBT(eeI).phaseSequence{elUse} = lapPhases;
            errorTBT(eeI).lapDetail{elUse} = lapDetail;
        end
    end 
        %{
        for lapI = 1:length(theseLaps)
            thisLap = theseLaps(lapI);
            lapDetail = trialDetail{thisLap};
            lapPhases = trialPhases{thisLap}; 
            phaseInd = [1 1 1];
                        
            %errorTBT(eeI).lapEpochs = [errorTBT(eeI).lapEpochs; {}];
            nErrorLaps = length(errorTBT(eeI).lapEpochs);
            elUse = nErrorLaps+1;
            for ldI = 1:length(lapDetail)
                bStart = daybyday.behavior{sessI}(thisLap).(beFieldsMarker{lapPhases(ldI),1})(phaseInd(lapPhases(ldI)));
                bEnd = daybyday.behavior{sessI}(thisLap).(beFieldsMarker{lapPhases(ldI),2})(phaseInd(lapPhases(ldI)));
                    
                errorTBT(eeI).lapEpochs{elUse}{ldI,1} = [bStart bEnd];
                
                phaseInd(lapPhases(ldI)) = phaseInd(lapPhases(ldI))+1;
                
                errorTBT(eeI).trialsX{elUse}{ldI,1} = daybyday.all_x_adj_cm{sessI}(bStart:bEnd);
                errorTBT(eeI).trialsY{elUse}{ldI,1} = daybyday.all_y_adj_cm{sessI}(bStart:bEnd);
                errorTBT(eeI).trialPSAbool{elUse}{ldI,1} = daybyday.PSAbool{sessI}(:,bStart:bEnd);
                errorTBT(eeI).trialRawTrace{elUse}{ldI,1} = daybyday.RawTrace{sessI}(:,bStart:bEnd);
                
                errorTBT(eeI).phaseSequence{elUse} = lapPhases;
                errorTBT(eeI).lapDetail{elUse} = lapDetail;
            end
            
        end 
        %}
     
end

rootPath = strsplit(mousePath,'\'); rootPath = fullfile(rootPath{1:end-1});
allfiles = cellfun(@(x) fullfile(rootPath,x),useDataTable.FolderName,'UniformOutput',false);
realdays = useDataTable.RealDay;

saveName = fullfile(mousePath,'trialbytrialLAP.mat');
sdbd = input(['Save trialbytrial as * ' saveName ' * (y/n) >> '],'s');
if strcmpi(sdbd,'y')
    save(saveName,'trialbytrial','errorTBT','allfiles','sortedSessionInds','realdays','-v7.3')
    disp('saved trialbytrial')
end

disp('done')

end

