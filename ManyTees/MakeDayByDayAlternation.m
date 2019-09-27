function [daybyday, sortedSessionInds, useDataTable] = MakeDayByDayAlternation(mousePath, getFluoresence, deleteSilentCells)
%Delete silent cells eliminates those lost from excluded reg sessions
cd(mousePath)

fdPts = strsplit(mousePath,'\');
finalDataRoot = fullfile(fdPts{1:end-1});
mouseName = fdPts{end};

load(fullfile(mousePath,'AlternationDataTable.mat'))

%Choose which files being included: these should have user input options
whichFilesUse = AlternationDataTable.HasPos == 1 & AlternationDataTable.HasFinalBeh;
                
figHa = figure;
ut = uitable(figHa);
AlternationDataTable.KeepSession = whichFilesUse;
tt = table2cell(AlternationDataTable);

ut.Data = tt;
ut.ColumnName = AlternationDataTable.Properties.VariableNames;
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

useDataTable = AlternationDataTable(whichFilesUse,1:6);

%Get the sort order for fullReg.sessionInds that corresponds to AlternationDataTable
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

%Load all the data
for sessI = 1:height(useDataTable)
    thisDir = fullfile(mousePath,useDataTable.FolderName{sessI});
    disp(['Working on file ' thisDir])
    %Make cell registration alignment matrix
    %sortedSessionInds(:,ff) = fullReg.sessionInds(:,useDataTable.fullRegInd(ff));

    %Load Imaging data
    load(fullfile(thisDir,'Pos_brain.mat'))
    
    daybyday.all_x_adj_cm{sessI,1} = xBrain;
    daybyday.all_y_adj_cm{sessI,1} = yBrain;
    
    %Get behavior indices
    xlsFile = ls(fullfile(thisDir,'*_Finalized.xlsx'));
    %[frames,txt] = xlsread(fullfile(thisDir,xlsFile));
    lapParsed = readtable(fullfile(thisDir,xlsFile));
    lapParsed.Properties.VariableNames{1} = 'TrialNum';

    daybyday.behavior{sessI,1} = lapParsed;
    
    load(fullfile(thisDir,'behaviorParse.mat'),'trialCorrect')
    TrialCorrect = [];
    for ee = 1:length(trialCorrect)
        TrialCorrect = [TrialCorrect; trialCorrect{ee}];
    end
    daybyday.behavior{sessI}.TrialCorrect = TrialCorrect;
    
    excludeFramesBrain = [];
    if exist(fullfile(thisDir,'excludeFrames.mat'),'file')==2
        load(fullfile(thisDir,'excludeFrames.mat'))
        disp('Loaded exclude frames for sessI')
    end
    daybyday.excludeFrames{sessI} = excludeFramesBrain;

    %Load fluoresence, align to PSAbool(adjusted)
    if getFluoresence == 1
        %Get the aligned frame numbers to use
        load(fullfile(thisDir,'Pos_brain.mat'),'PSAboolUseIndices')
        %Load the fluoresence activity
        load(fullfile(thisDir,'FinalOutput.mat'),'NeuronTraces')
        
        all_Fluoresence{sessI,1} = NeuronTraces.RawTrace(:,PSAboolUseIndices);       
    end
    
    %Check for imaging exclude, delete bad frames
    if exist(fullfile(thisDir,'excludeFromImaging.mat'),'file')==2
        ssaa = input(['Found imaging exclude frames for ' useDataTable.FolderName{sessI} ', include them? (y/n) '],'s');
        if strcmpi(ssaa,'y')
            %Assumes this refers to the original FinalOutput PSAbool
            load(fullfile(thisDir,'excludeFromImaging.mat'))

            load(fullfile(thisDir,'Pos_brain.mat'),'PSAboolUseIndices')

            daybyday.imagingFramesDelete{sessI} = logical(sum(PSAboolUseIndices == excludeFromImaging',1));

            %Still need to do something for frames/txt
        end
    else
        daybyday.imagingFramesDelete{sessI} = [];
    end
    
    all_PSAbool{sessI,1} = logical(PSAboolAdjusted);
    
    disp('Done')
end

if deleteSilentCells == 1
    disp('Deleteing silent cells')
    deleteTheseCells = find(sum(sortedSessionInds,2)==0);
     
    sortedSessionInds(deleteTheseCells, :) = [];
    disp(['deleted ' num2str(length(deleteTheseCells)) ' cells'])
end

%Reshuffle PSAbool into the right registration order
daybyday.PSAbool = PoolPSA2(all_PSAbool, sortedSessionInds);

if getFluoresence == 1
    daybyday.RawTrace = PoolPSA2(all_Fluoresence, sortedSessionInds);
end
    
sdbd = input('Save daybyday? (y/n) >> ','s');
if strcmpi(sdbd,'y')
    save(fullfile(mousePath,'daybyday.mat'),'daybyday','sortedSessionInds','useDataTable','-v7.3')
end

disp('done this daybyday')

end
    
    
    






