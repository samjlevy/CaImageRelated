function [daybyday, sortedSessionInds] = MakeDayByDayDoublePlus2(mousePath, getFluoresence, deleteSilentCells)
%Delete silent cells eliminates those lost from excluded reg sessions
cd(mousePath)

fdPts = strsplit(mousePath,'\');
finalDataRoot = fullfile(fdPts{1:end-1});
mouseName = fdPts{end};

load(fullfile(mousePath,'fullReg.mat'))
numFiles = length(fullReg.RegSessions);
PlusMazeDataTable = table;

load('realDays.mat')
load('sessType.mat')

% Evaluate where we are on data processing
HasPos = false(numFiles,1);
HasFinalBeh = false(numFiles,1);
behFileName = cell(numFiles,1);
for ffI = 1:numFiles
    posBrainHere = exist(fullfile(fullReg.RegSessions{ffI},'Pos_brain.mat'),'file')==2;
    switch posBrainHere
        case true
            HasPos(ffI) = true;
        case false
        disp(['Did not find Pos_brain.mat for * ' fullReg.RegSessions{ffI} ' *, making now'])
        cd(fullReg.RegSessions{ffI})
        AlignImagingToTracking2_SL('pos_file','posAnchored.mat','fps_brainimage',20,'xPositions','x_adj_cm','yPositions','y_adj_cm')
        HasPos(ffI) = true;
    end
    
    finalFile = dir(fullfile(fullReg.RegSessions{ffI},'*Finalized.xlsx'));
    if isempty(finalFile)
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
    elseif length(finalFile)==1
        HasFinalBeh(ffI) = true;
        behFileName{ffI} = fullfile(finalFile.folder,finalFile.name);
    else 
        disp('Not right behavior files...')
        keyboard
    end
end
PlusMazeDataTable.HasPos = HasPos;
PlusMazeDataTable.HasFinalBeh = HasFinalBeh;

%Choose which files being included: these should have user input options
whichFilesUse = PlusMazeDataTable.HasPos == 1 & PlusMazeDataTable.HasFinalBeh == 1;
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

sortedSessionInds = fullReg.sessionInds(:,whichFilesUse);

%Load all the data
for sessN = 1:length(filesLoad)
    sessI = filesLoad(sessN);
    thisDir = fullReg.RegSessions{sessI};
    disp(['Working on file ' thisDir])
    %Make cell registration alignment matrix
    %sortedSessionInds(:,ff) = fullReg.sessionInds(:,useDataTable.fullRegInd(ff));

    %Load Imaging data
    load(fullfile(thisDir,'Pos_brain.mat'))
    
    daybyday.all_x_adj_cm{sessN,1} = xBrain;
    daybyday.all_y_adj_cm{sessN,1} = yBrain;
    
    %Get behavior indices
    xlsFile = behFileName{sessI};
    lapParsed = readtable(xlsFile);
    te = false;
    try
    lapParsed.Properties.VariableNames{1} = 'TrialNum';
    
    daybyday.behavior{sessN,1} = lapParsed;
    
    daybyday.behavior{sessN}.TrialCorrect = lapParsed.Correct;
    catch
        disp('This table seems empty')
        te = true;
    end
    
    excludeFramesBrain = [];
    if exist(fullfile(thisDir,'excludeFrames.mat'),'file')==2
        load(fullfile(thisDir,'excludeFrames.mat'))
        disp('Loaded exclude frames for sessI')
    end
    daybyday.excludeFrames{sessN} = excludeFramesBrain;
    
    daybyday.realDays(sessN) = realDays(sessI);
    daybyday.sessType{sessN} = sessType{sessI};
    switch realDays(sessI)>0
        case true
            daybyday.mazeSize{sessN} = 'Large';
        case false
            daybyday.mazeSize{sessN} = 'Small';
    end

    %Load fluoresence, align to PSAbool(adjusted)
    if getFluoresence == 1
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
daybyday.PSAbool = PoolPSA2(all_PSAbool, sortedSessionInds);

if getFluoresence == 1
    daybyday.RawTrace = PoolPSA2(all_Fluoresence.RawTrace, sortedSessionInds);
    daybyday.DFDTtrace = PoolPSA2(all_Fluoresence.DFDTtrace, sortedSessionInds);
end
    
sdbd = input('Save daybyday? (y/n) >> ','s');
if strcmpi(sdbd,'y')
    save(fullfile(mousePath,'daybyday.mat'),'daybyday','sortedSessionInds','-v7.3')
end

disp('done this daybyday')

end
    
    
    






