function [trialbytrial, allfiles, sortedSessionInds, realdays]= MakeTBTalternation(mousePath,getFluoresence,correctOnly)
%Task segment has to be one of the options in GetBlockDNMPbehavior

fdPts = strsplit(mousePath,'\');
finalDataRoot = fullfile(fdPts{1:end-1});
mouseName = fdPts{end};

load(fullfile(mousePath,'daybyday.mat'))

numSess = length(daybyday.all_x_adj_cm);

namesUse = {'left';  'right'};
          
fieldsUse = {'LapStart' 'ChoiceEnter';...
             };
      %{       
for tI = 1:length(namesUse)
    %trialbytrial(tI).name = namesUse{tI};
    trialbytrial(tI).trialsX = {};
    trialbytrial(tI).trialsY = {};
    trialbytrial(tI).trialPSAbool = {};
    trialbytrial(tI).trialRawTrace = {};
    trialbytrial(tI).sessID = [];
    trialbytrial(tI).lapNumber = [];
    trialbytrial(tI).isCorrect = [];
end
%}
%if any(cell2mat(cellfun(@any,daybyday.excludeFrames,'UniformOutput',false)))
    
    
for sessI = 1:numSess
    sessType = useDataTable.SessType{sessI};
    
    numMazes = length(unique(daybyday.behavior{1}.MazeID));
    mazesUse = unique(daybyday.behavior{1}.MazeID);
    
    excludeFrames = 0;
    if any(daybyday.excludeFrames{sessI})
        ex = input(['Found exclude frames for sesion ' useDataTable.FolderName{sessI} ', use them? (y/n) >> '],'s');
        if strcmpi(ex,'y') || strcmpi(ex,'1')
            excludeFrames = 1;
        end
    end
    
    for mazeI = 1:length(mazesUse)
        namesHere = cellfun(@(x) strcat(x,num2str(mazesUse(mazeI))),namesUse,'UniformOutput',false);
        
        trialsHere = daybyday.behavior{sessI}.MazeID==mazesUse(mazeI);
        
        for dirI = 1:length(namesHere)
            ttI = dirI+length(namesHere)*(mazeI-1);
            
            if sessI==1
                trialbytrial(ttI).trialsX = {};
                trialbytrial(ttI).trialsY = {};
                trialbytrial(ttI).trialPSAbool = {};
                trialbytrial(ttI).trialRawTrace = {};
                trialbytrial(ttI).sessID = [];
                trialbytrial(ttI).lapNumber = [];
                trialbytrial(ttI).isCorrect = [];
            end
            
            trialbytrial(ttI).name = {dirI};
            correctDirection = strcmpi(daybyday.behavior{sessI}.TurnDir,namesHere{dirI}(1)) & trialsHere;
            
            if correctOnly==1
                correctDirection = correctDirection & daybyday.behavior{sessI}.TrialCorrect;
            end
            
            theseLaps = find(correctDirection);
            for lapI = 1:length(theseLaps)
                thisLap = theseLaps(lapI);
                lapStart = daybyday.behavior{sessI}.(fieldsUse{1})(thisLap); 
                lapEnd = daybyday.behavior{sessI}.(fieldsUse{2})(thisLap);
                theseFrames = lapStart:lapEnd;
                
                if excludeFrames==1
                    excludeHere = find(daybyday.excludeFrames{sessI}(lapStart:lapEnd));
                    if any(excludeHere)
                        theseFrames(excludeHere) = [];
                    end 
                end
        
                trialbytrial(ttI).trialsX = [trialbytrial(ttI).trialsX; {daybyday.all_x_adj_cm{sessI}(theseFrames)}];
                trialbytrial(ttI).trialsY = [trialbytrial(ttI).trialsY; {daybyday.all_y_adj_cm{sessI}(theseFrames)}];
                trialbytrial(ttI).trialPSAbool = [trialbytrial(ttI).trialPSAbool; {daybyday.PSAbool{sessI}(:,theseFrames)}];
                if getFluoresence==1
                    trialbytrial(ttI).trialRawTrace = [trialbytrial(ttI).trialRawTrace; daybyday.RawTrace{sessI}(:,theseFrames)];
                end
            end
            
            trialbytrial(ttI).sessID = [trialbytrial(ttI).sessID; sessI*ones(length(theseLaps),1)];
            trialbytrial(ttI).lapNumber = [trialbytrial(ttI).lapNumber; theseLaps];
            trialbytrial(ttI).isCorrect = [trialbytrial(ttI).isCorrect; daybyday.behavior{sessI}.TrialCorrect(theseLaps)];
        end  
    end
end

rootPath = strsplit(mousePath,'\'); rootPath = fullfile(rootPath{1:end-1});
allfiles = cellfun(@(x) fullfile(rootPath,x),useDataTable.FolderName,'UniformOutput',false);
realdays = useDataTable.RealDay;

sdbd = input('Save trialbytrial? (y/n) >> ','s');
if strcmpi(sdbd,'y')
    save(fullfile(mousePath,'trialbytrial.mat'),'trialbytrial','allfiles','sortedSessionInds','realdays','-v7.3')
    disp('saved trialbytrial')
end

disp('done')

end