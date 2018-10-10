function DNMPdataTable = MakeDNMPdataTable(fullRegPath)

%Get some full reg stuff

load(fullfile(fullRegPath,'fullReg.mat'))
load(fullfile(fullRegPath,'realDays.mat'))
load(fullfile(fullRegPath,'sessType.mat'))

if size(fullReg.RegSessions,2) > size(fullReg.RegSessions,1)
    fullReg.RegSession = fullReg.RegSessions';
end

fdPts = strsplit(fullRegPath,'\');
finalDataRoot = fullfile(fdPts{1:end-1});

DNMPdataTable = table(allFilesNames,realDays,sessType(:,2),nan(length(realDays),1),'VariableNames',{'FolderName','RealDay','SessType','Accuracy'});

%Put things in the right order
[~,sortOrder] = sort(DNMPdataTable.RealDay,'ascend');
if sum(diff(sortOrder,[],1) < 1)==0
    disp('Files are in order in real days')
else
    disp('Resorting data table by real days order')
    DNMPdataTable = DNMPdataTable(sortOrder);
end

%Fill in Accuracy with original sheet
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
                    sessionAccuracy(fullfile(finalDataRoot,DNMPdataTable.FolderName{missingAcc(maI)}),'*Finalized.xlsx');
        end
    end
end

%Check for pos file and finalized excel sheer
for ffI = 1:height(DNMPdataTable)
    DNMPdataTable.HasPos(ffI) = exist(fullfile(finalDataRoot,DNMPdataTable.FolderName{ffI},'Pos_align.mat'),'file') == 2;
    
    xlSheet = ls(fullfile(finalDataRoot,DNMPdataTable.FolderName{ffI},'*_Finalized.xlsx'));
    DNMPdataTable.HasFinalBeh(ffI) = any(xlSheet);
end


figHa = figure;
ut = uitable(figHa);
tt = table2cell(DNMPdataTable);
[tt{:,size(tt,2)+1}] = deal(true);
ut.Data = tt;
labels = DNMPdataTable.Properties.VariableNames; labels{length(labels)+1} = 'Keep Session';
ut.ColumnName = labels;
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

rowsDelete = cell2mat(ut.Data(:,end)) == 0;

DNMPdataTable(rowsDelete,:) = [];
disp(['deleted ' num2str(sum(rowsDelete)) ' entries'])
   
end