function MakeTrialbyTrial(base_path, reg_paths, DNMPorAll, correctOnly)
%Use DNMPorAll to indicate just DNMP sessions or all sessions in reg_paths
%Use correctOnly to only grab correct trials or grab all trials including errors


switch DNMPorAll
    case 'DNMP'
        regUseType = 'sessionType';
        regUseInput = [];
        [allfiles, position, all_PSAbool, correctBounds, badLaps, sortedSessionInds, lapNumber]...
    = GetMegaStuff2(base_path, [], regUseType, regUseInput);
    case 'All'
        regUseType = 'vector';
        regUseInput = ones(length(reg_paths),1);
        load(fullfile(base_path,'fullReg.mat'))
        if length(reg_paths) < length(fullReg.RegSessions)
            regUseInput = zeros(length(fullReg.RegSessions),1);
            for rpI = 1:length(reg_paths)
                thisFRRS = find(strcmpi(reg_paths{rpI},fullReg.RegSessions));
                regUseInput(thisFRRS) = 1;
            end
        end
        [allfiles, position, all_PSAbool, correctBounds, badLaps, sortedSessionInds, lapNumber]...
            = GetMegaStuff2(base_path, reg_paths, regUseType, regUseInput);
end

%[allfiles, position, all_PSAbool, correctBounds, badLaps, sortedSessionInds, lapNumber]...
%    = GetMegaStuff2(base_path, [], regUseType, regUseInput);

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