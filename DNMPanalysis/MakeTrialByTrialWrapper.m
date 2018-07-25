MakeTrialByTrialWrapper

rootProcessedFolder = 'G:\SLIDE\Processed Data';
mice = {'Bellatrix','Polaris','Calisto','Nix'};
MouseRefFolder = {'G:\SLIDE\Processed Data\Bellatrix\Bellatrix_160831';...
                  'G:\SLIDE\Processed Data\Polaris\Polaris_160831';...
                  'G:\SLIDE\Processed Data\Callisto\Calisto_161026';...
                  'G:\SLIDE\Processed Data\Nix\Nix_180502'};
numMice = length(mice);

accuracyThresh = 0.7;
getFluoresence = 1;
deleteSilentCells = 1;
              
%First assess all the data that exists
for mouseI = 1:numMice
    if exist(fullFile(MouseRefFolder{mouseI},'DNMPdataTable.mat'),'file')~=2
        DNMPdataTable = MakeDNMPdataTable(MouseRefFolder{mouseI});
        save(fullfile(MouseRefFolder{mouseI},'DNMPdataTable.mat'),'DNMPdataTable')
    end
end

%Now make a struct of all data from a day with the data we want
for mouseI = 1:numMice
    if exist(fullfile(MouseRefFolder{mouseI},'daybyday.mat'),'file')~=2
        [daybyday, sortedSessionInds, useDataTable] = MakeDayByDay(MouseRefFolder{mouseI},...
            accuracyThresh, getFluoresence, deleteSilentCells);
        save(fullfile(MouseRefFolder{mouseI},'daybyday.mat'),'daybyday','sortedSessionInds','useDataTable','-v7.3')
    end   
end
    
%Now refine that struct into a trialbytrial
for mouseI = 1:numMice
    
    MakeTrialByTrial2(basePath,taskSegment,correctOnly)