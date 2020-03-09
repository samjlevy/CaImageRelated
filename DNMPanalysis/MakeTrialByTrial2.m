function [trialbytrial, allfiles, sortedSessionInds, realdays]= MakeTrialByTrial2(basePath,taskSegment,correctOnly,xlims)
%Task segment has to be one of the options in GetBlockDNMPbehavior

cd(basePath)
load(fullfile(basePath,'daybyday.mat'))

numSess = length(daybyday.all_x_adj_cm);

useExtFile = false;
if strcmpi(taskSegment,'matFile')
    taskSegment = 'whole_lap';
    useExtFile = true;
    [efName,efPath] = uigetfile;
    extFile = load(fullfile(efPath,efName));
    extFields = fieldnames(extFile);
    extBounds = extFile(1).(extFields{1});
end

%First go through and gather all the data
for sessI = 1:numSess
    %Get all the data for this session
    if strcmpi(useDataTable.SessType(sessI),'DNMP')
    [bounds(sessI), ~, ~, ~, correct, lapNum]...
        = GetBlockDNMPbehavior2( daybyday.frames{sessI}, daybyday.txt{sessI},...
        taskSegment, length(daybyday.all_x_adj_cm{sessI}));
    elseif strcmpi(useDataTable.SessType(sessI),'ForcedUnforced')
        [bounds(sessI), ~, ~, ~, correct, lapNum]...
        = GetBlockForcedUnforcedBhvr2( daybyday.frames{sessI}, daybyday.txt{sessI},...
        taskSegment, length(daybyday.all_x_adj_cm{sessI}));
    end
    
    ss = fieldnames(bounds(sessI));
    if useExtFile == true        
        if length(ss) == length(extBounds{sessI})
            for blck = 1:length(ss)
                if size(bounds(sessI).(ss{blck}),1) == length(extBounds{sessI}(blck).starts) 
                     bounds(sessI).(ss{blck}) = [extBounds{sessI}(blck).starts(:) extBounds{sessI}(blck).stops(:)];
                else
                    disp('wrong length number of timestamps')
                    keyboard
                end
            end
        else
            disp('wrong number of bounds')
            keyboard
        end
    end
    
    %Reorganize it
    for block = 1:length(ss)
        correctBounds(sessI).(ss{block}) =...
            [bounds(sessI).(ss{block})(correct.(ss{block}),1)...
            bounds(sessI).(ss{block})(correct.(ss{block}),2)];
        
        lapNumber(sessI).(ss{block}).all = lapNum.(ss{block});
        
        lapNumber(sessI).(ss{block}).correct =...
            lapNum.(ss{block})(correct.(ss{block}));
        
        badLaps(sessI).(ss{block}) =...
            [bounds(sessI).(ss{block})(correct.(ss{block})==0,1)...
            bounds(sessI).(ss{block})(correct.(ss{block})==0,2)];
        
        lapNumber(sessI).(ss{block}).wrong=...
            lapNum.(ss{block})(correct.(ss{block})==0);
    end
    
    lapLengths = structfun(@(x) size(x,1),bounds(sessI));
    if any(lapLengths<5)
        disp(num2str(lapLengths))
        kppSess = input('These are the numbers of laps, keep this session? (y/n)>>','s');
        keepSess(sessI) = strcmpi(kppSess,'y');
    end
end

if correctOnly == false 
    correctBounds = bounds;
    ss = fieldnames(lapNumber);
    for sessI = 1:numSess
    for condI = 1:length(ss)
        lapNumber(sessI).(ss{condI}).correct = true(length(lapNumber(sessI).(ss{condI}).all),1);
    end
    end
end

%Then make some formatting adjustments
[fixedLapNumber] = AdjustLapNumbers(lapNumber);

%Get rid of any exclude frames
[correctBounds,fixedLapNumber] = RemoveExcludeFrames(daybyday.imagingFramesDelete,...
    correctBounds,daybyday.frames,fixedLapNumber);

%And put it all together
trialbytrial = PoolTrialsAcrossSessions(correctBounds,daybyday.all_x_adj_cm,...
    daybyday.all_y_adj_cm,daybyday.PSAbool,daybyday.RawTrace,[],fixedLapNumber);
    %no sortedSessionInds, already organized in daybyday

rootPath = strsplit(basePath,'\'); rootPath = fullfile(rootPath{1:end-1});
allfiles = cellfun(@(x) fullfile(rootPath,x),useDataTable.FolderName,'UniformOutput',false);
realdays = useDataTable.RealDay;
%sortedSessionInds comes in with daybyday

%save('trialbytrial.mat','trialbytrial','allfiles','sortedSessionInds','realdays','-v7.3')
end

