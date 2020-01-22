function [trialbytrial, allfiles, sortedSessionInds, realdays]= MakeTBTwithinDayPlus(mousePath,getFluoresence,correctOnly)
%Task segment has to be one of the options in GetBlockDNMPbehavior

fdPts = strsplit(mousePath,'\');
finalDataRoot = fullfile(fdPts{1:end-1});
mouseName = fdPts{end};

load(fullfile(mousePath,'daybyday.mat'))

numSess = length(daybyday.all_x_adj_cm);

%Need some additional behavior
numEpochs = 3;

namesUse = {'left';  'right'};
          
fieldsUse = {'LapStart' 'LapStop'};
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
    
    if exist('daybyday.behavior{1}.MazeID','var')==0
        for epochI = 1:numEpochs
            nn = useDataTable.FolderName(sessI);
            mazeHere(epochI) = str2double(input(...
                ['In session ' num2str(sessI) ', ' nn{1} ', which maze for epoch ' num2str(epochI) '>>'],...
                's'));
            %rewardArm{epochI} = 
            daybyday.behavior{sessI}.MazeID(find(daybyday.behavior{sessI}.Epoch==epochI)) = mazeHere(epochI);
        end
    end
        
    excludeFrames = 0;
    if any(daybyday.excludeFrames{sessI})
        ex = input(['Found exclude frames for sesion ' useDataTable.FolderName{sessI} ', use them? (y/n) >> '],'s');
        if strcmpi(ex,'y') || strcmpi(ex,'1')
            excludeFrames = 1;
        end
    end
    
    for epochI = 1:numEpochs
        %namesHere = cellfun(@(x) strcat(x,num2str(mazesUse(mazeI))),namesUse,'UniformOutput',false);
        ttI = epochI;
        
        trialsHere = daybyday.behavior{sessI}.Epoch==epochI;
        
        if sessI==1
            trialbytrial(ttI).trialsX = {};
            trialbytrial(ttI).trialsY = {};
            trialbytrial(ttI).trialPSAbool = {};
            trialbytrial(ttI).trialRawTrace = {};
            trialbytrial(ttI).sessID = [];
            trialbytrial(ttI).lapNumber = [];
            trialbytrial(ttI).isCorrect = [];
            trialbytrial(ttI).allowedFix = [];
            trialbytrial(ttI).MazeID = [];
            trialbytrial(ttI).startArm = {};
            trialbytrial(ttI).endArm = {};
            trialbytrial(ttI).rewardArm = {};
        end
        
        %trialbytrial(ttI).name = namesHere{dirI};
        correctDirection = trialsHere;
        if correctOnly==1
            correctDirection = correctDirection & daybyday.behavior{sessI}.Correct & daybyday.behavior{sessI}.AllowedFix==0;
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
        trialbytrial(ttI).allowedFix = [trialbytrial(ttI).allowedFix; daybyday.behavior{sessI}.AllowedFix(theseLaps)];
        
        %Parse some behavior
        trialbytrial(ttI).MazeID = [trialbytrial(ttI).MazeID; daybyday.behavior{sessI}.MazeID(theseLaps)];
        trialbytrial(ttI).startArm = [trialbytrial(ttI).startArm; cellfun(@(x) x(1),daybyday.behavior{sessI}.ArmSequence(theseLaps),'UniformOutput',false)];
        trialbytrial(ttI).endArm = [trialbytrial(ttI).endArm; cellfun(@(x) x(end),daybyday.behavior{sessI}.ArmSequence(theseLaps),'UniformOutput',false)];
        lapsCheck = find(trialbytrial(ttI).sessID==sessI);
        [trialbytrial(ttI).rewardArm{lapsCheck,1}] = deal(mode([trialbytrial(ttI).endArm{lapsCheck}]));
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