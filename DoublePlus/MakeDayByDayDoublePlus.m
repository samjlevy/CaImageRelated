function [daybyday, sortedSessionInds, useDataTable] = MakeDayByDayDoublePlus(mousePath, getFluoresence, deleteSilentCells)
%Delete silent cells is only for cells elimiated through not including
%certain registration sessions

cd(mousePath)

fdPts = strsplit(mousePath,'\');
finalDataRoot = fullfile(fdPts{1:end-1});
mouseName = fdPts{end};

load(fullfile(mousePath,'DoublePlusDataTable.mat'))

%Choose which files being included: these should have user input options
whichFilesUse = DoublePlusDataTable.HasPos == 1 & DoublePlusDataTable.HasFinalBeh;
                
figHa = figure;
ut = uitable(figHa);
DoublePlusDataTable.KeepSession = whichFilesUse;
tt = table2cell(DoublePlusDataTable);

ut.Data = tt;
ut.ColumnName = DoublePlusDataTable.Properties.VariableNames;
ut.Parent.Position = [300 300 700 450];
ut.Position = [20 20 640 400];
ut.ColumnEditable = logical([0 0 0 0 0 0 1]);
ut.ColumnWidth = {110 50 90 70 70 100 100};

donePick = 0;
while donePick == 0
    de = input('Done picking editable columns? (y/n) > ','s');
    if strcmpi(de,'y')
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

useDataTable = DoublePlusDataTable(whichFilesUse,1:6);

%Get the sort order for fullReg.sessionInds that corresponds to DoublePlusDataTable
disp('Checking registration')
%Load the registration
footFolder = fullfile(mousePath,[mouseName 'Footprints']);
footFile = ls(fullfile(footFolder,'cellRegistered*.mat'));
load(fullfile(footFolder,footFile))
sortedSessionInds = cell_registered_struct.cell_to_index_map;
%Load the registration log
txtFile = ls(fullfile(footFolder,'logFile*.txt'));
tFile = fullfile(footFolder,txtFile);
fileID = fopen(tFile);
allText = textscan(fileID,'%s');
fclose(fileID);
%check to see that they map to the DataTable
sessionLines = find(cell2mat(cellfun(@(x) strcmp(x,'Session'),allText,'UniformOutput',false)));
dashLines = find(cell2mat(cellfun(@(x) strcmp(x,'-'),allText,'UniformOutput',false)));
dashFollowSess = find(sum((sessionLines'+2)==dashLines,2));
sessTxt = allText{1}(sessionLines(dashFollowSess)+3); %#ok<FNDSB>
for stI = 1:size(sessTxt,1)
    strpts = strsplit(sessTxt{stI},'\');
    dateHere = strpts{end}(end-9:end-4);
    regSess{stI} = [mouseName '_' dateHere];
end

%useDataDelete = false(height(useDataTable),1);
%for ssI = 1:height(useDataTable)
%    ssIind = find(strcmpi(fullRegFilesEnds,useDataTable.FolderName(ssI)));
%    if isempty(ssIind)
%        useDataDelete(ssI) = true;
%        disp(['File ' useDataTable.FolderName(ssI) ' is not registered, deleting'])
%    else
%        useDataTable.fullRegInd(ssI) = ssIind;
%    end
%end
%useDataTable(useDataDelete,:) = [];

%Load all the data
for ff = 1:height(useDataTable)
    thisDir = fullfile(mousePath,useDataTable.FolderName{ff});
    disp(['Working on file ' thisDir])
    %Make cell registration alignment matrix
    %sortedSessionInds(:,ff) = fullReg.sessionInds(:,useDataTable.fullRegInd(ff));

    %Load Imaging data
    load(fullfile(thisDir,'Pos_align.mat'))
    
    daybyday.all_x_adj_cm{ff,1} = x_adj_cm;
    daybyday.all_y_adj_cm{ff,1} = y_adj_cm;
    
    %Get behavior indices
    load(fullfile(thisDir,'behaviorStruct.mat'))
    
    daybyday.behavior{ff,1} = lapParsed;
    
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
        ssaa = input(['Found imaging exclude frames for ' useDataTable.FolderName{ff} ', include them? (y/n) '],'s');
        if strcmpi(ssaa,'y')
            %Assumes this refers to the original FinalOutput PSAbool
            load(fullfile(thisDir,'excludeFromImaging.mat'))

            load(fullfile(thisDir,'Pos_brain.mat'),'PSAboolUseIndices')

            daybyday.imagingFramesDelete{ff} = logical(sum(PSAboolUseIndices == excludeFromImaging',1));

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
    
sdbd = input('Save daybyday? (y/n) >> ','s');
if strcmpi(sdbd,'y')
    save(fullfile(mousePath,'daybyday.mat'),'daybyday','sortedSessionInds','useDataTable','-v7.3')
end

disp('done this daybyday')

end
    
    
    






