function MakeTrialbyTrial(base_path, reg_paths, DNMPorAll, correctOnly)
%Use DNMPorAll to indicate just DNMP sessions or all sessions in reg_paths
%Use correctOnly to only grab correct trials or grab all trials including errors


switch DNMPorAll
    case 'DNMP'
        regUseType = 'sessionType';
        regUseInput = [];
    case 'All'
        regUseType = 'vector';
        regUseInput = ones(length(reg_paths),1);
end


[allfiles, position, all_PSAbool, correctBounds, badLaps, sortedSessionInds, lapNumber]...
    = GetMegaStuff2(base_path, [], regUseType, regUseInput);

[fixedLapNumber] = AdjustLapNumbers(lapNumber);

numframes = cell2mat(cellfun(@length, position.all_x_adj_cm, 'UniformOutput',false));
[bounds, ~, correct] = GetMultiSessDNMPbehavior(allfiles, numframes);

if any(strcmpi(correctOnly,{'all','allTrials','no'}))
    fakeCorrect = AllBoundsCorrect(correct); %All ones
    correct = fakeCorrect;
    fakeLapNumber = AllLapNumbersCorrect(fixedLapNumber);
    fixedLapNumber = fakeLapNumber;
end

correctBounds = StructCorrect(bounds, correct);

trialbytrial = PoolTrialsAcrossSessions(correctBounds,position.all_x_adj_cm,...
    position.all_y_adj_cm,all_PSAbool,sortedSessionInds,fixedLapNumber);

%check exists before saving
if exist(fullfile(base_path,'trialbytrial.mat'),'file')==2
    disp('Already have a trialbytrial.mat, pick a new name here')
    keyboard
else
save(fullfile(base_path,'trialbytrial.mat'),...
    'trialbytrial','sortedSessionInds','allfiles','base_path')
end

end