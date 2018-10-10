function DoublePlusDataTable = MakeDoublePlusDataTable(mousePath,mainFolder)

cd(mousePath)

sessHere = dir;
sessHere(1:2) = [];
fpFolder = find(cellfun(@any,cellfun(@(x) strfind(x,'Footprints'),{sessHere.name},'UniformOutput',false)));

footFolder = sessHere(fpFolder).name;
sessHere(fpFolder) = [];

sessionNames = {sessHere.name}';

footFile = ls(fullfile(footFolder,'cellRegistered*.mat'));
load(fullfile(footFolder,footFile))

realDays = [3 7 8]';
sessType = {'turn','turn','turn'}';
%load('realDays.mat')
load(fullfile(mainFolder,'groupAssign.mat'))

numRegistered = size(cell_registered_struct.cell_to_index_map,2);
if numRegistered ~= length(sessHere)
    badReg = input('num Registered and sess available are different. Continue? (y/n) >> ','s');
    if strcmpi(badReg,'n'); return; end
end

disp('Assuming that registration order is the same as folder order')


DoublePlusDataTable = table(sessionNames,realDays,sessType,nan(length(realDays),1),'VariableNames',{'FolderName','RealDay','SessType','Accuracy'});

%Put things in the right order
%[~,sortOrder] = sort(DoublePlusDataTable.RealDay,'ascend');
%if sum(diff(sortOrder,[],1) < 1)==0
    disp('Files are in order in real days')
%else
%    disp('Resorting data table by real days order')
%    DoublePlusDataTable = DoublePlusDataTable(sortOrder);
%end

%Check for pos file and finalized excel sheer
for ffI = 1:height(DoublePlusDataTable)
    DoublePlusDataTable.HasPos(ffI) = exist(fullfile(mousePath,DoublePlusDataTable.FolderName{ffI},'Pos_align.mat'),'file') == 2;
    if DoublePlusDataTable.HasPos(ffI)==0
        disp(['Error: missing positions for ' sessionNames{ffI} ])
    end
    
    xlSheet = ls(fullfile(mousePath,sessionNames{ffI},'behaviorStruct.mat'));
    DoublePlusDataTable.HasFinalBeh(ffI) = any(xlSheet);
    if any(xlSheet)==0
        disp(['Error: missing behaviorStruct for ' sessionNames{ffI} ])
    end
end

%Fill in Accuracy with original sheet
missingAcc = find(isnan(DoublePlusDataTable.Accuracy) | isempty(DoublePlusDataTable.Accuracy));
if any(missingAcc)
    %Some accuracy is missing, filling it in
    for maI = 1:length(missingAcc)
        load(fullfile(mousePath,sessionNames{missingAcc(maI)},'behaviorStruct.mat'))
        DoublePlusDataTable.Accuracy(missingAcc(maI)) = sum([lapParsed(:).isCorrect]) / length(lapParsed);
    end
end


figHa = figure;
ut = uitable(figHa);
tt = table2cell(DoublePlusDataTable);
[tt{:,size(tt,2)+1}] = deal(true);
ut.Data = tt;
labels = DoublePlusDataTable.Properties.VariableNames; labels{length(labels)+1} = 'Keep Session';
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

DoublePlusDataTable(rowsDelete,:) = [];
disp(['deleted ' num2str(sum(rowsDelete)) ' entries'])
  
close(figHa)
end