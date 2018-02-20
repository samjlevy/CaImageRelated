function MakeTrialbyTrial(base_path, reg_paths, DNMPorAll, correctOnly, deleteSilentCells)
%Use DNMPorAll to indicate just DNMP sessions or all sessions in reg_paths
%Use correctOnly to only grab correct trials or grab all trials including errors
%Here silent cells are only those that aren't found once sessions are taken out
if nargin < 5 || isempty(deleteSilentCells)
   disp('No answer on delete silent cells. Leaving them in, be careful')
   deleteSilentCells = 0;
end

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

%Reorganization will get rid of cells that only appeared on days that
%weren't included, can leave lots of blank entries. Delete those so that
%looking at size doesn't mess anything up
if deleteSilentCells == 1
    disp('Deleteing silent cells')
    deleteTheseCells = find(sum(sortedSessionInds,2)==0);
     
    sortedSessionInds(deleteTheseCells, :) = [];
    
    for condI = 1:length(trialbytrial)
        for trialI = 1:length(trialbytrial(condI).trialPSAbool)
            trialbytrial(condI).trialPSAbool{trialI}(deleteTheseCells, :) = [];
        end
    end
end

realDaysFile = fullfile(base_path,'realDays.mat');
try
    if exist(realDaysFile,'file')==2
        disp('found realDays, attempting to use it')
    else
        [ffile, ffpath] = uigetfile('Find realDays file');
        realDaysFile = fullfile(ffpath, ffile);
    end
    load(realDaysFile,'realdays')
    
    dateAlign = realdays;
    realdays = [];
    
    for fileI = 1:length(allfiles)
        dateS = strsplit(allfiles{fileI},'\'); dateS = dateS{end};
        thisInd = find(strcmpi(dateS,{dateAlign{:,1}}));
        realdays(fileI,1) = dateAlign{thisInd,2};
    end
catch
    disp('Some part of real days failed')
    realDays = [];
end

%check exists before saving
final_path = uigetdir(base_path,'Where to save?');
filename = 'trialbytrial.mat';
while exist(fullfile(final_path,filename),'file')==2
    disp('Already have a trialbytrial.mat, pick a new name here')
    answer = inputdlg('New name','Already exists',1,{[filename(1:end-4) '-2.mat']});
    filename = answer{1};
end

save(fullfile(final_path,filename),...
    'trialbytrial','sortedSessionInds','allfiles','base_path','final_path','realdays')

end