function AlternationDataTable = MakeAlternationDataTable1(base_path)

ffpts = strsplit(base_path,'\');

%mousePath = 'C:\Users\Sam\Desktop\TwoMazeAlternationData\Marble19';
%baseSess = 'marble19_190818';
%baseDir = fullfile(mousePath,baseSess);

mousePath = fullfile(ffpts{1:end-1});
baseSess = ffpts{end};

%numMice = length(mice);
getFluoresence = 1;
deleteSilentCells = 1;


load(fullfile(base_path,'fullReg.mat'))
load(fullfile(base_path,'realDays.mat'))
load(fullfile(base_path,'sessType.mat'))

%sessionsHere = [fullReg.baseSession; fullReg.RegSessions(:)]
%sessionNamePts = cellfun(@(x) strsplit(x,'\'),sessionsHere,'UniformOutput',false);
%sessionNames = cellfun(@(x) x{end},sessionNamePts,'UniformOutput',false);
sessionNames = sessType(:,1);

numRegistered = size(fullReg.sessionInds,2);
if numRegistered ~= length(sessionNames)
    badReg = input('num Registered and sess available are different. Continue? (y/n) >> ','s');
    if strcmpi(badReg,'n'); return; end
end

disp('Assuming that registration order is the same as folder order')
disp('For now assuming that order of session registration is real day order')

vNames = {'FolderName','RealDay','SessType','Accuracy'};
AlternationDataTable = table(sessionNames,realDays(:),sessType(:,2),nan(length(realDays),1),...
    'VariableNames',vNames);

missingAcc = find(isnan(AlternationDataTable.Accuracy) | isempty(AlternationDataTable.Accuracy));
if any(missingAcc)
    %Some accuracy is missing, filling it in
    for maI = 1:length(missingAcc)
        if any(strcmpi(sessType{maI,2},{'OneMaze','TwoMaze'}))
            cd(fullfile(mousePath,AlternationDataTable.FolderName{missingAcc(maI)}))
            ffile = ls('*_Finalized.xlsx');
            behtable = readtable(ffile);
            allAcc = [];
            for epochI = 1:length(unique(behtable.Epoch))
                %Accuracy 
                allAcc = [allAcc; sum(behtable.Correct(behtable.Epoch==epochI)& ~behtable.AllowedFix(behtable.Epoch==epochI))/...
                    sum(~behtable.AllowedFix(behtable.Epoch==epochI))];
            end 
        else
            load(fullfile(mousePath,AlternationDataTable.FolderName{missingAcc(maI)},'behaviorParse.mat'),'trialCorrect')
            allAcc = [];
            for epochI = 1:length(trialCorrect)
                allAcc = [allAcc; trialCorrect{epochI}];
            end
        end
        AlternationDataTable.Accuracy(missingAcc(maI)) = sum(allAcc) / length(allAcc);
    end
end

for ffI = 1:height(AlternationDataTable)
    AlternationDataTable.HasPos(ffI) = exist(fullfile(mousePath,AlternationDataTable.FolderName{ffI},'Pos_brain.mat'),'file') == 2;
    if AlternationDataTable.HasPos(ffI)==0
        disp(['Error: missing positions for ' sessionNames{ffI} ])
    end
    
    cd(fullfile(mousePath,sessionNames{ffI}))
    xlSheet = ls('*Finalized.xlsx');
    AlternationDataTable.HasFinalBeh(ffI) = any(xlSheet);
    if any(xlSheet)==0
        disp(['Error: missing behaviorStruct for ' sessionNames{ffI} ])
    end
end

figHa = figure;
ut = uitable(figHa);
tt = table2cell(AlternationDataTable);
[tt{:,size(tt,2)+1}] = deal(true);
ut.Data = tt;
labels = AlternationDataTable.Properties.VariableNames; labels{length(labels)+1} = 'Keep Session';
ut.ColumnName = labels;
ut.Parent.Position = [300 300 700 450];
ut.Position = [20 20 640 400];
ut.ColumnEditable = logical([0 0 0 0 0 0 1]);
ut.ColumnWidth = {110 50 90 70 70 100 100};

donePick = 0;
while donePick == 0
    de = input('Done picking editable columns? (y/n) > ','s');
    if strcmpi(de,'y') || strcmpi(de,'1')
        donePick = 1;
    end
end

rowsDelete = cell2mat(ut.Data(:,end)) == 0;

AlternationDataTable(rowsDelete,:) = [];
disp(['deleted ' num2str(sum(rowsDelete)) ' entries'])
  
close(figHa)

if any(strcmpi(sessType{maI,2},{'OneMaze','TwoMaze'}))
    PlusMazeDataTable = AlternationDataTable;
    save(fullfile(base_path,'PlusMazeDataTable.mat'),'PlusMazeDataTable')
else
    save(fullfile(base_path,'AlternationDataTable.mat'),'AlternationDataTable')
end

end

