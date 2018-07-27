function [trialbytrial, allfiles, sortedSessionInds, realdays]= MakeTrialByTrial2(basePath,taskSegment,correctOnly)
%Task segment has to be one of the options in GetBlockDNMPbehavior

load(fullfile(basePath,'daybyday.mat'))

numSess = length(daybyday.all_x_adj_cm);


%First go through and gather all the data
for sessI = 1:numSess
    %Get all the data for this session
    [bounds(sessI), ~, ~, ~, correct, lapNum]...
        = GetBlockDNMPbehavior2( daybyday.frames{sessI}, daybyday.txt{sessI},...
        taskSegment, length(daybyday.all_x_adj_cm{sessI}));
  
    %Reorganize it
    ss = fieldnames(bounds(sessI));
    for block = 1:4
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
end

%Then make some formatting adjustments
[fixedLapNumber] = AdjustLapNumbers(lapNumber);

if correctOnly == false 
    correctBounds = bounds(sessI);
end

%Get rid of any exclude frames
[correctBounds,fixedLapNumber] = RemoveExcludeFrames(daybyday.imagingFramesDelete,...
    correctBounds,daybyday.frames,fixedLapNumber);

%And put it all together
trialbytrial = PoolTrialsAcrossSessions(correctBounds,daybyday.all_x_adj_cm,...
    daybyday.all_y_adj_cm,daybyday.PSAbool,daybyday.RawTrace,[],fixedLapNumber);

rootPath = strsplit(basePath,'\'); rootPath = fullfile(rootPath{1:end-1});
allfiles = cellfun(@(x) fullfile(rootPath,x),useDataTable.FolderName,'UniformOutput',false);
realdays = useDataTable.RealDay;
%sortedSessionInds comes in with daybyday

end

