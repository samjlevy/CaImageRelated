function [daybyday, sortedSessionInds, useDataTable] = MakeDayByDay(basePath,accuracyThresh, getFluoresence, deleteSilentCells)

fdPts = strsplit(basePath,'\');
finalDataRoot = fullfile(fdPts{1:end-1});

load(fullfile(basePath,'DNMPdataTable.mat'))
load(fullfile(basePath,'fullReg.mat'))


%Choose which files being included: these should have user input options
whichFilesUse = cell2mat(cellfun(@(x) strcmpi(x,'DNMP'),[DNMPdataTable.SessType],'UniformOutput',false))...
                & DNMPdataTable.Accuracy >= accuracyThresh...
                & DNMPdataTable.HasPos == 1 ...
                & DNMPdataTable.HasFinalBeh;
                

figHa = figure;
ut = uitable(figHa);
DNMPdataTable.KeepSession = whichFilesUse;
tt = table2cell(DNMPdataTable);

ut.Data = tt;
ut.ColumnName = DNMPdataTable.Properties.VariableNames;
ut.Parent.Position = [300 300 700 450];
ut.Position = [20 20 640 400];
ut.ColumnEditable = logical([0 0 0 0 0 0 1]);
ut.ColumnWidth = {110 50 90 70 70 100 100};

donePick = 0;
while donePick == 0
    de = input('Done picking editable columns? (y/n) > ','s');
    if strcmpi(de,'y')
        donePick = 1;
    end
end
try
close(figHa);
end

useDataTable = DNMPdataTable(whichFilesUse,1:6);

%Get the sort order for fullReg.sessionInds that corresponds to DNMPdataTable
fullRegFiles = [fullReg.BaseSession; fullReg.RegSessions(:)];
fullRegFilesPts = cellfun(@(x) strsplit(x,'\'),fullRegFiles,'UniformOutput',false);
fullRegFilesEnds = cellfun(@(x) x{end},fullRegFilesPts,'UniformOutput',false);

useDataDelete = false(height(useDataTable),1);
for ssI = 1:height(useDataTable)
    ssIind = find(strcmpi(fullRegFilesEnds,useDataTable.FolderName(ssI)));
    if isempty(ssIind)
        useDataDelete(ssI) = true;
        disp(['File ' useDataTable.FolderName(ssI) ' is not registered, deleting'])
    else
        useDataTable.fullRegInd(ssI) = ssIind;
    end
end
useDataTable(useDataDelete,:) = [];

%Load all the data
for ff = 1:height(useDataTable)
    thisDir = fullfile(finalDataRoot,useDataTable.FolderName{ff});
    disp(['Working on file ' thisDir])
    %Make cell registration alignment matrix
    sortedSessionInds(:,ff) = fullReg.sessionInds(:,useDataTable.fullRegInd(ff));

    %Load Imaging data
    load(fullfile(thisDir,'Pos_align.mat'))
    
    daybyday.all_x_adj_cm{ff,1} = x_adj_cm;
    daybyday.all_y_adj_cm{ff,1} = y_adj_cm;
    
    %Get behavior indices
    xlsfile = ls(fullfile(thisDir,'*Finalized.xlsx'));
    
    [daybyday.frames{ff,1}, daybyday.txt{ff,1}] = xlsread(fullfile(thisDir,xlsfile), 1);
    
    %Load fluoresence, align to PSAbool(adjusted)
    if getFluoresence == 1
        %Get the aligned frame numbers to use
        load(fullfile(thisDir,'Pos_brain.mat'),'PSAboolUseIndices')
        %Load the fluoresence activity
        load(fullfile(thisDir,'FinalOutput.mat'),'NeuronTraces')
        
        all_Fluoresence{ff,1} = NeuronTraces.RawTrace(:,PSAboolUseIndices);       
    end
    
    %Check for imaging exclude, delete bad frames
    if exist(fullfile(thisDir,'excludeFromImaging.mat'),'file')==2
        ssaa = input(['Found imaging exclude frames for ' useDataTable.FolderName{ff} ', include them? (y/n) '],'s')
        if strcmpi(ssaa,'y')
            %Assumes this refers to the original FinalOutput PSAbool
            load(fullfile(thisDir,'excludeFromImaging.mat'))

            load(fullfile(thisDir,'Pos_brain.mat'),'PSAboolUseIndices')

            daybyday.imagingFramesDelete{ff} = logical(sum(PSAboolUseIndices == excludeFromImaging',1));

            %PSAbool(:,imagingFramesDelete) = [];
            %all_Fluoresence{ff,1}(:,imagingFramesDelete) = [];
            %daybyday.all_x_adj_cm{ff,1}(imagingFramesDelete) = [];
            %daybyday.all_y_adj_cm{ff,1}(imagingFramesDelete) = [];
            
            %Still need to do something for frames/txt
        end
    else
        daybyday.imagingFramesDelete{ff} = [];
    end
    
    all_PSAbool{ff,1} = logical(PSAbool);
    
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
    


%save daybyday.mat daybyday sortedSessionInds useDataTable -v7.3

end
    
    
    






