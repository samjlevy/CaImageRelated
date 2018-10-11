function [trialbytrial, allfiles, sortedSessionInds, realdays]= MakeTBTdoublePlus(mousePath,locInds)
%Task segment has to be one of the options in GetBlockDNMPbehavior

fdPts = strsplit(mousePath,'\');
finalDataRoot = fullfile(fdPts{1:end-1});
mouseName = fdPts{end};

load(fullfile(mousePath,'daybyday.mat'))

numSess = length(daybyday.all_x_adj_cm);

namesUse = {'north';  'south';  'east'; 'west'};%'midFromN'; 'midFromS'
fieldsUse = {'startLap' 'enterMid';...
             'startLap' 'enterMid';...
             'leaveMid' 'endLap';...
             'leaveMid' 'endLap'};
            %'enterMid' 'leaveMid'

beFieldsMarker = {'startLap' 'enterMid';...
                  'enterMid' 'leaveMid';...
                  'leaveMid' 'endLap'};
              
for tI = 1:length(namesUse)
    trialbytrial(tI).name = namesUse{tI};
    trialbytrial(tI).trialsX = {};
    trialbytrial(tI).trialsY = {};
    trialbytrial(tI).trialPSAbool = {};
    trialbytrial(tI).trialRawTrace = {};
    trialbytrial(tI).sessID = [];
    trialbytrial(tI).lapNumber = [];
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
end
              
for sessI = 1:numSess
    sessType = useDataTable.SessType{sessI};
    goodSequences = PlusGoodSequences(sessType,locInds);

    southInd = find(strcmpi(locInds(:,2),'south'));
    northInd = find(strcmpi(locInds(:,2),'north'));
    eastInd = find(strcmpi(locInds(:,2),'east'));
    westInd = find(strcmpi(locInds(:,2),'west'));

    numTrials = length(daybyday.behavior{sessI});
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
    
    eventuallyCorrect = goodSequence==0 & getsThere;
    
    eventuallyCorrectNorthStart = eventuallyCorrect & northStart & getsThere;
    eventuallyCorrectSouthStart = eventuallyCorrect & southStart & getsThere;
    
    %errorSouthDoesntMakeIt = errorSouthStart & eventuallyCorrect==0;
    %errorNorthDoesntMakeIt = errorNorthStart & eventuallyCorrect==0;
    
    allOtherErrors = (errorNorthWrongChoice | errorSouthWrongChoice |...
                      eventuallyCorrectNorthStart | eventuallyCorrectSouthStart)==0 & isCorrect==0;
    
    %Bundle it all up nicely
    lapType = {northStart; southStart; getsToEast; getsToWest};
    for ttI = 1:length(namesUse)        
        theseLaps = find(lapType{ttI} & isCorrect & goodSequence);
        
        trialbytrial(ttI).sessID = [trialbytrial(ttI).sessID; sessI*ones(length(theseLaps),1)];
        trialbytrial(ttI).lapNumber = [trialbytrial(ttI).lapNumber; theseLaps];
        
        for lapI = 1:length(theseLaps)
            thisLap = theseLaps(lapI);
            lapStart = daybyday.behavior{sessI}(thisLap).(fieldsUse{ttI,1}); 
            lapEnd = daybyday.behavior{sessI}(thisLap).(fieldsUse{ttI,2});
            
            trialbytrial(ttI).trialsX = [trialbytrial(ttI).trialsX; daybyday.all_x_adj_cm{sessI}(lapStart:lapEnd)];
            trialbytrial(ttI).trialsY = [trialbytrial(ttI).trialsY; daybyday.all_y_adj_cm{sessI}(lapStart:lapEnd)];
            trialbytrial(ttI).trialPSAbool = [trialbytrial(ttI).trialPSAbool; daybyday.PSAbool{sessI}(:,lapStart:lapEnd)];
            trialbytrial(ttI).trialRawTrace = [trialbytrial(ttI).trialRawTrace; daybyday.RawTrace{sessI}(:,lapStart:lapEnd)];
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

sdbd = input('Save trialbytrial? (y/n) >> ','s');
if strcmpi(sdbd,'y')
    save(fullfile(mousePath,'trialbytrial.mat'),'trialbytrial','errorTBT','allfiles','sortedSessionInds','realdays','-v7.3')
end

disp('done, saved trialbytrial')

end

