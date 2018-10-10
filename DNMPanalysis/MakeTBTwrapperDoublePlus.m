MakeTBTwrapperDoublePlus

mainFolder = 'G:\DoublePlus';
mice = {'Kerberos','Marble07','Marble11','Pandora','Styx','Titan'};

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
        [daybyday, sortedSessionInds, useDataTable] = MakeDayByDay(mousePath,getFluoresence,deleteSilentCells);
        save(fullfile(mousePath,'daybyday.mat'),'daybyday','sortedSessionInds','useDataTable','-v7.3')
    end   
end
    
%Now refine that struct into a trialbytrial
for mouseI = 1:numMice 
    makeTBT = 1;
    if exist(fullfile(mousePath,'trialbytrial.mat'),'file')==2
        makeTBT = 0;
        ssa = input('Found existing trialbytrial, replace? (y/n) > ','s')
        if strcmpi(ssa,'y')
            makeTBT = 1;
        end
    end
        
    if makeTBT==1
        [trialbytrial, allfiles, sortedSessionInds, realdays] = MakeTrialByTrial2(mousePath,taskSegment,correctOnly);
        savedir = uigetdir(cd,'Choose directory to save trialbytrial');
        %cd(savedir)
        save('trialbytrial.mat','trialbytrial','allfiles','sortedSessionInds','realdays')
    end
    
end