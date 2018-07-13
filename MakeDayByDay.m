function MakeDayByDay(fileTablePath,fullRegPath)

%finalDataRoot = 'G:\SLIDE\Processed Data'; %MyPassport white drive
finalDataRoot = 'G:\SLIDE\Processed Data\Callisto';

DNMPdataTable = table(realdays{:,1},realdays{:,2},cell(21,1),'VariableNames',{'FolderName','RealDay','SessType'})
%'VariableNames',{'FolderName','RealDay','SessType'}

%Get some full reg stuff
load(fullfile(fullRegPath,'fullReg.mat'))

if size(fullReg.RegSessions,2) > size(fullReg.RegSessions,1)
    fullReg.RegSession = fullReg.RegSessions';
end

fullRegFiles = [fullReg.BaseSession; fullReg.RegSessions(:)];


%Put things in the right order
[~,sortOrder] = sort(cell2mat(DNMPdataTable.RealDay),'ascend');
if sum(diff(sortOrder,[],1) < 1)==0
    disp('Files are in order in real days')
else
    disp('Resorting data table by real days order')
    DNMPdataTable = DNMPdataTable(sortOrder);
end

%Fill in Accuracy
missingAcc = find(isnan(DNMPdataTable.Accuracy) | isempty(DNMPdataTable.Accuracy));
if any(missingAcc)
    %Some accuracy is missing, filling it in
    for maI = 1:length(missingAcc)
        switch DNMPdataTable.SessType{missingAcc(maI)}
            case 'ForcedUnforced'
                %DNMPdataTable.Accuracy(missingAcc(maI)) = sessionAccuractForcedUnforced( );
                DNMPdataTable.Accuracy(missingAcc(maI)) = 1;
            case 'DNMP'
                DNMPdataTable.Accuracy(missingAcc(maI)) =...
                    sessionAccuracy(fullfile(finalDataRoot,DNMPdataTable.FolderName(missingAcc(maI))));
                
        end
    end
end

%Choose which files being included

whichFilesUse = cell2mat(cellfun(@(x) strcmpi(x,'DNMP'),[DNMPdataTable.SessType],'UniformOutput',false))...
    .* DNMPdataTable.Accuracy>=0.7;
%Check that these files are all in fullReg.sessionInds

useDataTable = table([DNMPdataTable.FolderName(whichFilesUse)],...
                     DNMPdataTable.RealDay(whichFilesUse),...
                     [DNMPdataTable.SessType(whichFilesUse)],...
                     DNMPdataTable.Accuracy(whichFilesUse),...
                     'VariableNames',{'FolderName','RealDay','SessType','Accuracy'});

%Get the sort order for fullReg.sessionInds that corresponds to DNMPdataTable
fullRegFilesPts = cellfun(@(x) strsplit(x,'\'),fullRegFiles,'UniformOutput',false);
fullRegFilesEnds = cellfun(@(x) x{end},fullRegFilesPts,'UniformOutput',false);

for ssI = 1:height(useDataTable)
    useDataTable.fullRegInd(ssI) = find(strcmpi(fullRegFilesEnds,useDataTable.FolderName(ssI)));
end

%Load all the data
for ff = 1:height(useDataTable)
    load(fullfile(finalDataRoot,useDataTable.FolderName(ff),'Pos_align.mat'))
    
    lapbylap.all_x_adj_cm{ff,1} = x_adj_cm;
    lapbylap.all_y_adj_cm{ff,1} = y_adj_cm;
    all_PSAbool{ff,1} = PSAbool;
    
    xlsfile = ls(fullfile(thisDir,'*Finalized.xlsx'));
    
    [lapbylap.frames{ff,1}, lapbylap.txt{ff,1}] = xlsread(fullfile(allfiles{ff},xls_file), 1);
    
    if getFluoresence == 1
        load(fullfile(finalDataRoot,useDataTable.FolderName(ff),'Pos_brain.mat'))
        load(fullfile(finalDataRoot,useDataTable.FolderName(ff),'FinalOutput.mat'),'
        load(fullfile(finalDataRoot,useDataTable.FolderName(ff),'FToffsetSam.mat'
        
        
    end
end




end
    
    
    






