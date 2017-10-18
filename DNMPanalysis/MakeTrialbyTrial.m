function MakeTrialbyTrial(base_path, DNMPorAll)

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

numframes = cell2mat(cellfun(@length, position.all_x_adj_cm, 'UniformOutput',false));
[bounds, ~, correct] = GetMultiSessDNMPbehavior(allfiles, numframes);

correctBounds = StructCorrect(bounds, correct);

trialbytrial = PoolTrialsAcrossSessions(correctBounds,position.all_x_adj_cm,...
    position.all_y_adj_cm,all_PSAbool,sortedSessionInds);

%check exists before saving
if exist(fullfile(base_path,'trialbytrial.mat'),'file')==2
    disp('Already have a trialbytrial.mat, pick a new name here')
    keyboard
else
save(fullfile(base_path,'trialbytrial.mat'),...
    'trialbytrial','sortedSessionInds','allfiles','base_path')
end

end