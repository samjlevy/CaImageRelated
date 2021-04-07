function CombineSameSessPieces

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
    x_adj_cm(thisEpoch(1):thisEpoch(2)) = paVars{1}.x_adj_cm(thisEpoch(1):thisEpoch(2));
    y_adj_cm(thisEpoch(1):thisEpoch(2)) = paVars{1}.y_adj_cm(thisEpoch(1):thisEpoch(2));
    whichMaze(thisEpoch(1):thisEpoch(2)) = paVars{1}.whichMaze(thisEpoch(1):thisEpoch(2));
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


for paI = 1:length(paFiles)
    xx = readtable(xlFiles(paI).name);
    xx.Correct = logical(xx.Correct);
    xx.AllowedFix = logical(xx.AllowedFix);
    nTrialsHere = size(xx,1);
    
    % Detect behavior:
    lapStarts = cellfun(@(x) x(1), xx.ArmSequence);
    lapStops = cellfun(@(x) x(end), xx.ArmSequence);
    if any((lapStarts=='n' | lapStarts=='s')==0)
        disp('Found a problem lap...')
        keyboard
    end
            
    if strcmpi(unique(lapStops(xx.Correct)),'e')
        % Rule is go east
        xx.Rule = repmat({'Place'},nTrialsHere,1);
    elseif sum( (lapStarts(xx.Correct)=='n' & lapStops(xx.Correct)=='w') |...
                (lapStarts(xx.Correct)=='s' & lapStops(xx.Correct)=='e') ) ...
                == sum(xx.Correct)
        % Rule is turn right
        xx.Rule = repmat({'Turn'},nTrialsHere,1);
    else
        stt = input('Did not identify this trial type; what is it? >> ','s');
        xx.Rule = repmat(stt,nTrialsHere,1);
    end
        
    if paI == 1
        xx.SessInd = ones(nTrialsHere,1);
        bigTable = xx;
    else
        switch strcmpi(bigTable.Rule(end,:),xx.Rule(1,:))
            case 0 % If a different trial type from last epoch...
                xx.SessInd = ones(nTrialsHere,1)*(bigTable.SessInd(end)+1);
            case 1
                xx.SessInd = ones(nTrialsHere,1)*(bigTable.SessInd(end));
        end
        bigTable = [bigTable; xx];
    end

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

writetable(bigTable,sName)

copyfile(sName,'PlusBehavior_BrainTime_Finalized.xlsx')

end