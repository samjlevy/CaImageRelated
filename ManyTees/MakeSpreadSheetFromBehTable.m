function MakeSpreadSheetFromBehTable

fileHere = ls('behaviorParse.mat');
if isempty(fileHere)
    disp('No file')
end

load(fileHere)

fullDat = [];
lapDirec = {};

for epochI = 1:length(behTable)
    trialNums = (1:length(behTable{epochI}))+size(fullDat,1);
    mazeVec = epochI*ones(length(trialNums),1);
    
    lapDirec = [lapDirec(:); lapDirections{epochI}(:)];
    
    datHere = [trialNums(:), behTable{epochI}, mazeVec];
    fullDat = [fullDat; datHere];
end

AlternationDataTable = array2table(fullDat,'VariableNames',{'TrialNum',behLabels{1}{:},'MazeID'});
AlternationDataTable.TurnDir = lapDirec;


cc = table2cell(AlternationDataTable);
cc = [{'Trial #',behLabels{1}{:},'MazeID','TurnDir'}; cc];

xlswrite('AlternationSheet.xlsx',cc)

end