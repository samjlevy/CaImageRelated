MakeTBTwrapperDoublePlus

mainFolder = 'G:\DoublePlus';
mainFolder = 'E:\DoublePlus';
mice = {'Kerberos','Marble07','Marble11','Pandora','Styx','Titan'};

locInds = {1 'center'; 2 'north'; 3 'south'; 4 'east'; 5 'west'};

numMice = length(mice);
getFluoresence = 1;
deleteSilentCells = 1;
              
correctOnly = true;

%First assess all the data that exists
for mouseI = 1:numMice
    mousePath = fullfile(mainFolder,mice{mouseI});
    if exist(fullfile(mousePath,'DNMPdataTable.mat'),'file')~=2
        DoublePlusDataTable = MakeDoublePlusDataTable(fullfile(mainFolder,mice{mouseI}),mainFolder);
        save(fullfile(mousePath,'DoublePlusDataTable.mat'),'DoublePlusDataTable')
    end
end

%Now make a struct of all data from a day with the data we want
for mouseI = 1:numMice
    mousePath = fullfile(mainFolder,mice{mouseI});
    if exist(fullfile(mousePath,'daybyday.mat'),'file')~=2
        [daybyday, sortedSessionInds, useDataTable] = MakeDayByDayDoublePlus(mousePath, getFluoresence, deleteSilentCells);
    end   
end
    
%Now refine that struct into a trialbytrial

%saveName = fullfile(mousePath,'trialbytrial.mat');
%taskSegment = 'arm_only';

for mouseI = 1:numMice 
    mousePath = fullfile(mainFolder,mice{mouseI});
    saveName = fullfile(mousePath,'trialbytrialLAP.mat');
    taskSegment = 'whole_trial';
    makeTBT = 1;
    if exist(saveName,'file')==2
        makeTBT = 0;
        ssa = input('Found existing trialbytrial, replace? (y/n) > ','s');
        if strcmpi(ssa,'y')
            makeTBT = 1;
        end
    end
        
    if makeTBT==1
        [trialbytrial, allfiles, sortedSessionInds, realdays]= MakeTBTdoublePlus(mousePath,locInds,taskSegment);
    end
    save(fullfile(mousePath,'trialbytrialLAP.mat'),'trialbytrial','errorTBT','allfiles','sortedSessionInds','realdays','-v7.3')
end