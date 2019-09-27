MakeTBTwrapperAlternation

mainFolder = 'C:\Users\Sam\Desktop\TwoMazeAlternationData';
mice = {'Marble19'};

numMice = length(mice);
getFluoresence = 0;
deleteSilentCells = 1; %Delete silent cells eliminates those lost from excluded reg sessions
              
correctOnly = true;

%First assess all the data that exists
for mouseI = 1:numMice
    mousePath = fullfile(mainFolder,mice{mouseI});
    if exist(fullfile(mousePath,'AlternationDataTable.mat'),'file')~=2
        AlternationDataTable = MakeAlternationDataTable1(base_path);
        save(fullfile(mousePath,'AlternationDataTable.mat'),'AlternationDataTable')
    end
end

%Now make a struct of all data from a day with the data we want
for mouseI = 1:numMice
    mousePath = fullfile(mainFolder,mice{mouseI});
    if exist(fullfile(mousePath,'daybyday.mat'),'file')~=2
        [daybyday, sortedSessionInds, useDataTable] = MakeDayByDayAlternation(mousePath, getFluoresence, deleteSilentCells);
    end   
end
    
%Now refine that struct into a trialbytrial
for mouseI = 1:numMice 
    mousePath = fullfile(mainFolder,mice{mouseI});
    makeTBT = 1;
    if exist(fullfile(mousePath,'trialbytrial.mat'),'file')==2
        makeTBT = 0;
        ssa = input('Found existing trialbytrial, replace? (y/n) > ','s');
        if strcmpi(ssa,'y')
            makeTBT = 1;
        end
    end
        
    if makeTBT==1
        [trialbytrial, allfiles, sortedSessionInds, realdays]= MakeTBTalternation(mousePath,getFluoresence,correctOnly);
    end
    
end