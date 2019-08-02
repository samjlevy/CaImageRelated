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
              
mazeRegion = 'stem_arm';
switch mazeRegion
    case 'stem'
        taskSegment = 'stem_only';
        tbtname = 'trialbytrial.mat';
    case 'arm'
        taskSegment = 'side_arm';
        tbtname = 'armTrialbytrial.mat';
    case 'delay'
        taskSegment = 'delay';
        tbtname = 'trialbytrialDELAY.mat';
    case 'stem_arm'
        taskSegment = 'stem_arm';
        tbtname = 'trialbytrialLAP.mat';
end
    
correctOnly = true;

%First assess all the data that exists
for mouseI = 1:numMice
    if exist(fullFile(MouseRefFolder{mouseI},'DNMPdataTable.mat'),'file')~=2
        DNMPdataTable = MakeDNMPdataTable(MouseRefFolder{mouseI});
        save(fullfile(MouseRefFolder{mouseI},'DNMPdataTable.mat'),'DNMPdataTable')
    end
end

%Now make a struct of all data from a day with the data we want
for mouseI = 1:numMice
    %if exist(fullfile(MouseRefFolder{mouseI},'daybyday.mat'),'file')~=2
        [daybyday, sortedSessionInds, useDataTable] = MakeDayByDay(MouseRefFolder{mouseI},...
            accuracyThresh, getFluoresence, deleteSilentCells);
        save(fullfile(MouseRefFolder{mouseI},'daybyday.mat'),'daybyday','sortedSessionInds','useDataTable','-v7.3')
    %end   
end
    
%Now refine that struct into a trialbytrial
%tbtName = 'trialbytrial.mat';
%tbtname = 'trialbytrialLAP.mat';
for mouseI = 1:numMice 
    makeTBT = 1;
    savedir = uigetdir(cd,['Choose directory to save trialbytrial for ' mice{mouseI}]);
    if exist(fullfile(savedir,tbtname),'file')==2
        makeTBT = 0;
        ssa = input('Found existing trialbytrial, replace? (y/n) > ','s')
        if strcmpi(ssa,'y')
            makeTBT = 1;
        end
    end
        
    if makeTBT==1
        [trialbytrial, allfiles, sortedSessionInds, realdays] = MakeTrialByTrial2(MouseRefFolder{mouseI},taskSegment,correctOnly);
        
        %cd(savedir)
        save(fullfile(savedir,tbtname),'trialbytrial','allfiles','sortedSessionInds','realdays','-v7.3')
    end
    disp(['Done making tbt for mouse ' num2str(mouseI)])
end

%Make tbt for arms
for mouseI = 1:numMice
    load(fullfile(MouseRefFolder{mouseI},'daybyday.mat'))
    fixedEpochs = AdjustArmXboundsDNMP(daybyday);%, stemXlims
    armEpochs = fixedEpochs;
    save(fullfile(MouseRefFolder{mouseI},'ArmEpochsCorrected.mat'),'armEpochs')
    
    [armtrialbytrial, allfiles, sortedSessionInds, realdays] = MakeTrialByTrial2(MouseRefFolder{mouseI},'matFile',correctOnly);
    savedir = uigetdir(cd,'Choose directory to save trialbytrial');
    save(fullfile(savedir,'armTrialbytrial.mat'),'armtrialbytrial','allfiles','sortedSessionInds','realdays')
end
    
