function [sortedSessionInds] = MakeDayByDayDoublePlus3(pathFileList, mousePath, getFluorescence, deleteSilentCells, registrationUseNames,registrationUseIndices)
%Delete silent cells eliminates those lost from excluded reg sessions
% The overhaul being done here was for realigned data. It runs with fewer
% options, since we want it to just go. Also, it doesn't save out a single
% daybyday struct, it saves out each of those variables separately to make
% it easier to handle saving/loading and updating things later on the fly
% Delete silent cells just operates on sortedSessionInds that got excluded;
% we could safely load that out of existing trialbytrial and use it for
% this purpose
% pathFileList, rather than just directory to full reg, is the list of
% paths for sessions to use. mousepath goes to the root directory to get
% fullreg, etc. pathFileList allows for empty slots and will build the
% daybyday with respect to those

cd(mousePath)

% Get some of the basic data we need
fdPts = strsplit(mousePath,'\');
finalDataRoot = fullfile(fdPts{1:end-1});
mouseName = fdPts{end};

if isempty('registrationUseNames')
    load(fullfile(mousePath,'fullReg.mat'))
    registrationUseNames = fullReg.RegSessions;
    registrationUseIndices = fullReg.sessionInds;
end
%numFiles = length(fullReg.RegSessions);
numFiles = numel(pathFileList);
for ffI = 1:numFiles
    if any(pathFileList{ffI})
        fParts = strsplit(pathFileList{ffI},'\');
        pathFileList{ffI} = fParts{end};
    end
end
PlusMazeDataTable = table;

% These will be the full list for this animal, will be longer than 9
load('realDays.mat') % also has allFilesNames
load('sessType.mat')


% Evaluate where we are on data processing; in this rebuild version should all return true
HasPos = false(numFiles,1);
HasFinalBeh = false(numFiles,1);
behFileName = cell(numFiles,1);
for ffI = 1:numFiles
    if any(pathFileList{ffI})
        sessionFolder = fullfile(mousePath,pathFileList{ffI});
        posBrainHere = exist(fullfile(sessionFolder,'Pos_brain.mat'),'file')==2;
        switch posBrainHere
            case true
                HasPos(ffI) = true;
            case false
                disp(['Did not find Pos_brain.mat for * ' sessionFolder ])
                keyboard
                %{
                cd(sessionFolder)
                % Need the replaced imaging to tracking function here
                HasPos(ffI) = true;
                %}
        end
    
    finalFile = ls(fullfile(sessionFolder,'*Finalized.xlsx'));
    if isempty(finalFile)
        disp(['Did not find Finalized behavior for ' sessionFolder'])
        keyboard
        %{
        btFile = dir(fullfile(fullReg.RegSessions{ffI},'*_BrainTime.xlsx'));
        if length(btFile) == 1
            oldName = btFile.name;
            newName = [oldName(1:end-5) '_Finalized.xlsx'];
            copyfile(fullfile(fullReg.RegSessions{ffI},oldName),...
                     fullfile(fullReg.RegSessions{ffI},newName))
        else
            disp('Found more than one possible braintime file')
            keyboard
        end
        HasFinalBeh(ffI) = true;
        behFileName{ffI} = fullfile(fullReg.RegSessions{ffI},newName);
        %}
    elseif size(finalFile,1)==1
        HasFinalBeh(ffI) = true;
        behFileName{ffI} =  finalFile;% fullfile(finalFile.folder,finalFile.name);
    else 
        disp('Not right behavior files...')
        keyboard
    end

    end
end
PlusMazeDataTable.HasPos = HasPos;
PlusMazeDataTable.HasFinalBeh = HasFinalBeh;

% Evaluate if we have the registration to use, realDays
whichFilesUse = PlusMazeDataTable.HasPos == 1 & PlusMazeDataTable.HasFinalBeh == 1;
wfuInd = find(whichFilesUse);
fileRegInd = zeros(numFiles,1);
fileRealDaysInd = zeros(numFiles,1);
for ffI = 1:numel(wfuInd)
    wfI = wfuInd(ffI);
    regHere = cell2mat(cellfun(@(x) any(strfind(x,pathFileList{wfI})),registrationUseNames,'UniformOutput',false));
    if sum(regHere) == 1
        fileRegInd(wfI) = find(regHere);
    else
        disp('Two matching sessions for reg? Or none?')
        keyboard
    end

    realDaysHere = cell2mat(cellfun(@(x) any(strfind(x,pathFileList{wfI})),allFilesNames,'UniformOutput',false));
    if sum(realDaysHere) == 1
        fileRealDaysInd(wfI) = find(realDaysHere);
    else
        disp('Two matching sessions for realDays? Or none?')
        keyboard
    end
end

%Choose which files being included: these should have user input options
disp(['Using ' num2str(sum(whichFilesUse)) ' out of ' num2str(numFiles) ' registered files'])  
filesLoad = find(whichFilesUse);

%{
figHa = figure;
ut = uitable(figHa);
PlusMazeDataTable.KeepSession = whichFilesUse;
tt = table2cell(PlusMazeDataTable);

ut.Data = tt;
ut.ColumnName = PlusMazeDataTable.Properties.VariableNames;
ut.Parent.Position = [300 300 700 450];
ut.Position = [20 20 640 400];
ut.ColumnEditable = logical([0 0 0 0 0 0 1]);
ut.ColumnWidth = {110 50 90 70 70 100 100};

donePick = 0;
while donePick == 0
    de = input('Done picking editable columns? (y/n) > ','s');
    if strcmpi(de,'y') || strcmpi(de,'1')
        donePick = 1;
       
        numHad = sum(whichFilesUse);
        whichFilesUse = cell2mat(ut.Data(:,7));
        numNow = sum(whichFilesUse);
        disp(['Keeping ' num2str(numNow) ' out of ' num2str(numHad) ' files'])
    end
end
try
close(figHa);
end

useDataTable = PlusMazeDataTable(whichFilesUse,1:6);
%}

% Since for now we're doing it based on registration, don't need to do any
% of this...
%{
%Get the sort order for fullReg.sessionInds that corresponds to PlusMazeDataTable
disp('Checking registration')
%Load the registration
load(fullfile(mousePath,'fullReg.mat'))
fullRegFiles = [fullReg.baseSession; fullReg.RegSessions(:)]; if ischar(fullRegFiles); fullRegFiles = {fullRegFiles}; end
fullRegFilesPts = cellfun(@(x) strsplit(x,'\'),fullRegFiles,'UniformOutput',false);
fullRegFilesEnds = cellfun(@(x) x{end},fullRegFilesPts,'UniformOutput',false);
%{
fullRegFilesDats = cellfun(@(x) strsplit(x,'_'),fullRegFilesEnds,'UniformOutput',false);
fullRegFilesDates = cell2mat(cellfun(@(x) x{end},fullRegFilesDats,'UniformOutput',false));
[~,sortOrder] = 
%}

sortedSessionInds = [];
for regI = 1:size(useDataTable,1)
    useInd = find(strcmpi(fullRegFilesEnds,useDataTable.FolderName(regI)));
    sortedSessionInds(:,regI) = fullReg.sessionInds(:,useInd);
end
%}
oldRealDays = realDays;
oldSessType = sessType;

%sortedSessionInds = fullReg.sessionInds(:,whichFilesUse);
for wfuI = 1:numel(filesLoad)
    hasFiles = cellfun(@(x) any(strfind(x,pathFileList{filesLoad(wfuI)})),registrationUseNames);
    if sum(hasFiles)==1
        ssiUse(wfuI) = find(hasFiles);
    else
        disp('Missing this file for registration?')
        keyboard
    end
end
sortedSessionInds = registrationUseIndices(:,ssiUse);
allFiles = registrationUseNames(whichFilesUse);

numFilesUse = numel(filesLoad);

%Load all the data
all_x_adj_cm = cell(numFilesUse,1);
all_y_adj_cm = cell(numFilesUse,1);
behavior = cell(numFilesUse,1);
sessType = cell(numFilesUse,1);
mazeSize = cell(numFilesUse,1);
realDays = nan(numFilesUse,1);
all_PSAbool = cell(numFilesUse,1);
if getFluorescence == true
    all_Fluoresence.DFDTtrace = cell(numFilesUse,1);
    all_Fluoresence.RawTrace = cell(numFilesUse,1);
end

for sessN = 1:numel(filesLoad)
    sessI = filesLoad(sessN);
    thisDir = fullfile(mousePath,pathFileList{sessI});
    disp(['Working on file ' thisDir])
    %Make cell registration alignment matrix
    %sortedSessionInds(:,ff) = fullReg.sessionInds(:,useDataTable.fullRegInd(ff));

    %Load Imaging data
    
    load(fullfile(thisDir,'Pos_brain.mat'))
    
    all_x_adj_cm{sessN,1} = xBrain;
    all_y_adj_cm{sessN,1} = yBrain;

    % Add velocity
    velHere = hypot(abs(diff(all_x_adj_cm{sessN,1})),abs(diff(all_y_adj_cm{sessN,1})));
    %velHere = hypot(abs(diff(daybyday.all_x_adj_cm{sessN,1})),abs(diff(daybyday.all_y_adj_cm{sessN,1}))) / (1/20);
    velHere = [velHere(1), velHere]; 
    all_velocity{sessN,1} = velHere / (1/20);
    
    %Get behavior indices
    xlsFile = fullfile(thisDir,behFileName{sessI});
    lapParsed = readtable(xlsFile);
    te = false;
    try
    lapParsed.Properties.VariableNames{1} = 'TrialNum';
    
    behavior{sessN,1} = lapParsed;
    behavior{sessN}.TrialCorrect = lapParsed.Correct;

    catch
        disp('This table seems empty')
        te = true;
    end
    
    excludeFramesBrain = [];
    if exist(fullfile(thisDir,'excludeFrames.mat'),'file')==2
        load(fullfile(thisDir,'excludeFrames.mat'))
        disp('Loaded exclude frames for sessI')
        keyboard
        % Make a handler to be sure that these are offset by
        % psabooluseadjusted thing
    end
    excludeFrames{sessN} = excludeFramesBrain;
    
    % Realdays needs to get indexed properly...
    realDays(sessN) = oldRealDays(fileRealDaysInd(sessI));
    sessType{sessN} = oldSessType{fileRealDaysInd(sessI)};

    switch oldRealDays(fileRealDaysInd(sessI))>0
        case true
           mazeSize{sessN} = 'Large';
        case false
           mazeSize{sessN} = 'Small';
    end

    %Load fluoresence, align to PSAbool(adjusted)
    if getFluorescence == 1
        %Get the aligned frame numbers to use
        load(fullfile(thisDir,'Pos_brain.mat'),'PSAboolUseIndices')
        %Load the fluoresence activity
        load(fullfile(thisDir,'FinalOutput.mat'),'NeuronTraces')
        
        all_Fluoresence.RawTrace{sessN,1} = NeuronTraces.RawTrace(:,PSAboolUseIndices);       
        all_Fluoresence.DFDTtrace{sessN,1} = NeuronTraces.DFDTtrace(:,PSAboolUseIndices);       
    end
     
    all_PSAbool{sessN,1} = logical(PSAboolAdjusted);
    
    disp('Done')
end

if deleteSilentCells == 1
    disp('Deleteing silent cells')
    deleteTheseCells = find(sum(sortedSessionInds,2)==0);
     
    sortedSessionInds(deleteTheseCells, :) = [];
    disp(['deleted ' num2str(length(deleteTheseCells)) ' cells'])
end

%Reshuffle PSAbool into the right registration order
%disp('Warning, maybe a bug here?')
all_PSAbool = PoolPSA2(all_PSAbool, sortedSessionInds);

if getFluorescence == 1
    all_Fluoresence.RawTrace = PoolPSA2(all_Fluoresence.RawTrace, sortedSessionInds);
    all_Fluoresence.DFDTtrace = PoolPSA2(all_Fluoresence.DFDTtrace, sortedSessionInds);
end
    
sdbd = input('Save daybyday? (y/n) >> ','s');
%allFiles = filesLoad;
if strcmpi(sdbd,'y')
    save(fullfile(mousePath,'daybyday.mat'),'all_PSAbool','sortedSessionInds','all_Fluoresence',...
        'behavior','mazeSize','all_x_adj_cm','all_y_adj_cm','realDays','sessType','allFiles','all_velocity','-v7.3')
end

disp('done this daybyday')

end
    
    
    






