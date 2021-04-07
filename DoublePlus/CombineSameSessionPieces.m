function CombineSameSessionPieces

% Put together position data
paFiles = dir('posAnchored*.mat');
for paI = 1:length(paFiles)
    paVars{paI} = load(paFiles(paI).name,'epochs','DVTtime','x_adj_cm','y_adj_cm','whichMaze');
end

DVTtime = paVars{1}.DVTtime;
x_adj_cm = zeros(size(paVars{1}.x_adj_cm));
y_adj_cm = zeros(size(paVars{1}.y_adj_cm));
whichMaze = zeros(size(paVars{1}.whichMaze));
    
for paI = 1:length(paFiles)
    thisEpoch = paVars{paI}.epochs;
    x_adj_cm(thisEpoch(1):thisEpoch(2)) = paVars{paI}.x_adj_cm(thisEpoch(1):thisEpoch(2));
    y_adj_cm(thisEpoch(1):thisEpoch(2)) = paVars{paI}.y_adj_cm(thisEpoch(1):thisEpoch(2));
    whichMaze(thisEpoch(1):thisEpoch(2)) = paVars{paI}.whichMaze(thisEpoch(1):thisEpoch(2));
    mazeEpochs{paI} = thisEpoch;
end
   
save('posAnchoredAll.mat','x_adj_cm','y_adj_cm','DVTtime','whichMaze','mazeEpochs')
    
AlignImagingToTracking2_SL('pos_file','posAnchoredAll.mat','fps_brainimage',20,...
    'xPositions','x_adj_cm','yPositions','y_adj_cm')

% Put together multiple behavior sheets
%{
st = questdlg('Which session type is this?','Sess Type','Turn Right','Go East','Other');
switch st
    case 'Turn Right'
        sessType = 1;
    case 'Go East'
        sessType = 2;
    case 'Other'
        if strcmpi(st,'Other'); st = input('What is the session type?','s'); end
        sessType = 3;
end
%}
xlFiles = dir('*_BrainTime_*.xlsx');
bigTable = readtable(xlFiles(1).name);
for paI = 2:length(paFiles)
    bigTable = [bigTable; readtable(xlFiles(paI).name)];
end

nTrials = size(bigTable,1);
bigTable.TrialNum(:) = [1:nTrials]';

sParts = strsplit(xlFiles(1).name,'_');
sName = [];
for sI = 1:length(sParts)-1
    sName = [sName, sParts{sI}];
    sName = [sName, '_'];
end
sName = [sName(1:end-1), '_all.xlsx'];

%writetable(bigTable,sName)

%copyfile(sName,'PlusBehavior_BrainTime_Finalized.xlsx')

end