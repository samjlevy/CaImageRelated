%% Process all data

mainFolder = 'C:\Users\Sam\Desktop\DNMPfinalData';
%mainFolder = 'C:\Users\samjl\Desktop\DNMPfinalData';
%mainFolder = 'E:\DNMPfinalData';
mice = {'Bellatrix', 'Polaris', 'Calisto', 'Nix'}; %'Europa'
numMice = length(mice);

mouseDefaultFolder = {'G:\SLIDE\Processed Data\Bellatrix\Bellatrix_160831';...
                      'G:\SLIDE\Processed Data\Polaris\Polaris_160831';...
                      'G:\SLIDE\Processed Data\Callisto\Calisto_161026';...
                      'G:\SLIDE\Processed Data\Nix\Nix_180502'};

%Thresholds
brainFPS = 20;
pThresh = 0.05;
lapPctThresh = 0.25;
consecLapThresh = 3;
%xlims = [25.5 56]; %old
xlims = [8 38];
xlimsArm = [5 35];
numBins = 8;
stemBinEdges = linspace(min(xlims),max(xlims),numBins+1);
armBinEdges = linspace(min(xlimsArm),max(xlimsArm),numBins+1);
minspeed = 0; 
zeronans = 1; 
posThresh = 3;
cmperbin = (max(xlims)-min(xlims))/numBins;
condPairs = [1 3; 2 4; 1 2; 3 4]; % {'Left','Right','Study','Test'}
mazeLocations = {'Stem','Arms'};
performanceThreshold = 0.7;
global dayLagLimit
dayLagLimit = 16;
%global velThresh
%velThresh = 0.5;
%global realDatMarkerSize
%realDatMarkerSize = 16;

disp('Loading stuff')
for mouseI = 1:numMice
    load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'))
    cellTBT{mouseI} = trialbytrial;
    cellSSI{mouseI} = sortedSessionInds;
    cellPresent{mouseI} = cellSSI{mouseI} > 0;
    cellAllFiles{mouseI} = allfiles;
    cellRealDays{mouseI} = realdays;
    
    clear trialbytrial sortedSessionInds allFiles realdays
    
    load(fullfile(mainFolder,mice{mouseI},'armTrialbytrial.mat'))
    cellTBTarm{mouseI} = armtrialbytrial;
    
    clear armtrialbytrial realdays allfiles sortedSessionInds
    
    load(fullfile(mainFolder,mice{mouseI},'trialbytrialDELAY.mat'))
    cellTBTdelay{mouseI} = trialbytrial;
    
    disp(['Mouse ' num2str(mouseI) ' completed'])
end

for mouseI = 1:numMice
    numDays(mouseI) = size(cellSSI{mouseI},2);
    numCells(mouseI) = size(cellSSI{mouseI},1);
end

maxDays = max(numDays);

disp('Getting Accuracy')
for mouseI = 1:numMice
    if exist(fullfile(mainFolder,mice{mouseI},'accuracy.mat'),'file') == 0
        disp(['Getting accuracy for mouse ' num2str(mouseI) ])
        performance = sessionAccuracy(cellAllFiles{mouseI},'*Finalized.xlsx');
        save(fullfile(mainFolder,mice{mouseI},'accuracy.mat'),'performance');
    end
    load(fullfile(mainFolder,mice{mouseI},'accuracy.mat'))
    accuracy{mouseI} = performance;
    accuracyRange(mouseI, 1:2) = [mean(accuracy{mouseI}),...
        std(accuracy{mouseI})/sqrt(length(accuracy{mouseI}))];
    
    load(fullfile(mainFolder,mice{mouseI},'allAccuracy.mat'))
    allDaysAccuracy{mouseI} = allAccuracy;
end

disp('Getting reliability')
dayUse = cell(1,numMice); threshAndConsec = cell(1,numMice); trialReliAll = []; trialReliAllArms = [];
for mouseI = 1:numMice
    saveName = fullfile(mainFolder,mice{mouseI},'trialReliability.mat');
    if exist(saveName,'file')==0
        [dayUse,threshAndConsec,consec] = GetUseCells(cellTBT{mouseI}, lapPctThresh, consecLapThresh, false,[min(stemBinEdges) max(stemBinEdges)],[]);
        [trialReli,aboveThresh,nLapsActive,~] = TrialReliability(cellTBT{mouseI}, lapPctThresh, false,[min(stemBinEdges) max(stemBinEdges)],[]);

        [dayUseArm,threshAndConsecArm,consecArm] = GetUseCells(cellTBTarm{mouseI}, lapPctThresh, consecLapThresh, false,[min(armBinEdges) max(armBinEdges)],[]);
        [trialReliArm,aboveThreshArm,nLapsActiveArm,~] = TrialReliability(cellTBTarm{mouseI}, lapPctThresh, false,[min(armBinEdges) max(armBinEdges)],[]);
    
        save(saveName,'dayUse','threshAndConsec','consec','dayUseArm','threshAndConsecArm','consecArm','trialReli','trialReliArm','nLapsActive','nLapsActiveArm')
        clear('dayUse','threshAndConsec','dayUseArm','threshAndConsecArm','trialReli','trialReliArm','consec','consecArm','nLapsActive','nLapsActiveArm')
    end
    
    [dayUseDelay,threshAndConsecDelay,consecDelay] = GetUseCells(cellTBTdelay{mouseI}, lapPctThresh, consecLapThresh, false,[],[]);
    [trialReliDelay,aboveThreshDelay,nLapsActiveDelay,~] = TrialReliability(cellTBTdelay{mouseI}, lapPctThresh, false,[],[]);
    save(saveName,'dayUseDelay','threshAndConsecDelay','consecDelay','trialReliDelay','aboveThreshDelay','nLapsActiveDelay','-append')
    
    [trialReliAll{mouseI},~,~,~] = TrialReliability(cellTBT{mouseI}, lapPctThresh,true,[min(stemBinEdges) max(stemBinEdges)],[]);
    [trialReliAllArms{mouseI},~,~,~] = TrialReliability(cellTBTarm{mouseI}, lapPctThresh,true,[min(armBinEdges) max(armBinEdges)],[]);
end

for mouseI = 1:numMice
    saveName = fullfile(mainFolder,mice{mouseI},'trialReliability.mat');
    reliability{mouseI} = load(saveName);
    
    dayUse{mouseI} = reliability{mouseI}.dayUse;
    presentInactive{1}{mouseI} = (dayUse{mouseI} + (cellSSI{mouseI}>0)) == 1;
    threshAndConsec{mouseI} = reliability{mouseI}.threshAndConsec;
    consec{mouseI} = reliability{mouseI}.consec;
    cellsActiveToday{mouseI} = sum(dayUse{mouseI},1);
    daysEachCellActive{mouseI} = sum(dayUse{mouseI},2);
    trialReli{mouseI} = reliability{mouseI}.trialReli;
    lapsActive{mouseI} = reliability{mouseI}.nLapsActive;
    
    dayUseArm{mouseI} = reliability{mouseI}.dayUseArm;
    presentInactive{2}{mouseI} = (dayUseArm{mouseI} + (cellSSI{mouseI}>0)) == 1;
    threshAndConsecArm{mouseI} = reliability{mouseI}.threshAndConsecArm;
    consecArm{mouseI} = reliability{mouseI}.consecArm;
    cellsActiveTodayArm{mouseI} = sum(dayUseArm{mouseI},1);    
    daysEachCellActiveArm{mouseI} = sum(dayUseArm{mouseI},2);
    trialReliArm{mouseI} = reliability{mouseI}.trialReliArm;
    lapsActiveArm{mouseI} = reliability{mouseI}.nLapsActiveArm;
    
    dayUseDelay{mouseI} = reliability{mouseI}.dayUseDelay;
    presentInactive{3}{mouseI} = (dayUseDelay{mouseI} + (cellSSI{mouseI}>0)) == 1;
    threshAndConsecDelay{mouseI} = reliability{mouseI}.threshAndConsecDelay;
    consecDelay{mouseI} = reliability{mouseI}.consecDelay;
    cellsActiveTodayDelay{mouseI} = sum(dayUseDelay{mouseI},1);    
    daysEachCellActiveDelay{mouseI} = sum(dayUseDelay{mouseI},2);
    trialReliDelay{mouseI} = reliability{mouseI}.trialReliDelay;
    lapsActiveDelay{mouseI} = reliability{mouseI}.nLapsActiveDelay;
    %daysCellFound{mouseI} = sum(cellSSI{mouseI}>0,2);
    
    clear reliability
end


%Pooled Reliability
disp('Getting pooled reliability')
for mouseI = 1:numMice
    saveName = fullfile(mainFolder,mice{mouseI},'trialReliabilityPooled.mat');
    if exist(saveName,'file')==0
    cellTBTpooled{mouseI} = PoolTBTacrossConds(cellTBT{mouseI},condPairs,{'Left','Right','Study','Test'});
    [dayUsePooled,threshAndConsecPooled,consecPooled] = GetUseCells(cellTBTpooled{mouseI}, lapPctThresh, consecLapThresh);
    [trialReliPooled,aboveThreshPooled,~,~] = TrialReliability(cellTBTpooled{mouseI}, lapPctThresh);
    
    cellTBTarmPooled{mouseI} = PoolTBTacrossConds(cellTBTarm{mouseI},condPairs,{'Left','Right','Study','Test'});
    [dayUseArmPooled,threshAndConsecArmPooled,consecArmPooled] = GetUseCells(cellTBTarmPooled{mouseI}, lapPctThresh, consecLapThresh);
    [trialReliArmPooled,aboveThreshArmPooled,~,~] = TrialReliability(cellTBTarmPooled{mouseI}, lapPctThresh);
    
    save(saveName,'dayUsePooled','threshAndConsecPooled','consecPooled','dayUseArmPooled','threshAndConsecArmPooled','consecArmPooled','trialReliPooled','trialReliArmPooled')
    clear('dayUsePooled','threshAndConsecPooled','dayUseArmPooled','threshAndConsecArmPooled','trialReliPooled','trialReliArmPooled')
    end
    
    reliabilityPooled{mouseI} = load(saveName);
    dayUsePooled{mouseI} = reliabilityPooled{mouseI}.dayUsePooled;
    threshAndConsecPooled{mouseI} = reliabilityPooled{mouseI}.threshAndConsecPooled;
    trialReliPooled{mouseI} = reliabilityPooled{mouseI}.trialReliPooled;
    
    dayUseArmPooled{mouseI} = reliabilityPooled{mouseI}.dayUseArmPooled;
    threshAndConsecArmPooled{mouseI} = reliabilityPooled{mouseI}.threshAndConsecArmPooled;
    trialReliArmPooled{mouseI} = reliabilityPooled{mouseI}.trialReliArmPooled;
    clear reliability
end
%}

for mouseI = 1:numMice
    cellTBT{mouseI} = GetTBTvelocity(cellTBT{mouseI},brainFPS);
    cellTBTarm{mouseI} = GetTBTvelocity(cellTBTarm{mouseI},brainFPS);
end
%Place fields
stemPFs = 'PFsLinPooled.mat';
armPFs = 'PFsLinPooledArm.mat';
delayPFs = 'PFsLinPooledDelay.mat';
for mouseI = 1:numMice
    saveName = fullfile(mainFolder,mice{mouseI},stemPFs);
    %[~, ~, ~, ~, ~, ~, ~] =...
    %        PFsLinTBTdnmp(cellTBT{mouseI}, stemBinEdges, minspeed, saveName, false,condPairs);
    switch exist(saveName,'file')
        case 0
            disp(['no pooled placefields found for ' mice{mouseI} ', making now'])
            [~, ~, ~, ~, ~, ~, ~] =...
            PFsLinTBTdnmp(cellTBT{mouseI}, stemBinEdges, minspeed, saveName, false,condPairs);
       case 2
            disp(['found pooled placefields for ' mice{mouseI} ', all good'])
    end
    
    load(fullfile(mainFolder,mice{mouseI},'PFsLinPooled.mat'),'TMap_unsmoothed','TMap_zRates','TCounts','RunOccMap')
    cellPooledTMap_unsmoothed{1}{mouseI} = TMap_unsmoothed;
    %cellPooledTMap_firesAtAll{1}{mouseI} = TMap_firesAtAll;
    cellPooledTMap_zRates{1}{mouseI} = TMap_unsmoothed; 
    cellTCounts{1}{mouseI} = TCounts;
    cellRunOccMap{1}{mouseI} = RunOccMap;
    
    
    saveName = fullfile(mainFolder,mice{mouseI},armPFs);
     [~, ~, ~, ~, ~, ~, ~] =...
            PFsLinTBTdnmp(cellTBTarm{mouseI}, armBinEdges, minspeed, saveName, false,condPairs);
    switch exist(saveName,'file')
        case 0
            disp(['no pooled placefields for arms found for ' mice{mouseI} ', making now'])
            [~, ~, ~, ~, ~, ~, ~] =...
            PFsLinTBTdnmp(cellTBTarm{mouseI}, armBinEdges, minspeed, saveName, false,condPairs);
       case 2
            disp(['found pooled placefields for arms for ' mice{mouseI} ', all good'])
    end
    
    load(saveName,'TMap_unsmoothed','TMap_zRates')
    cellPooledTMap_unsmoothedArm{1}{mouseI} = TMap_unsmoothed;
    %cellPooledTMap_firesAtAllArm{1}{mouseI} = TMap_firesAtAll;
    cellPooledTMap_zRatesArm{1}{mouseI} = TMap_unsmoothed; 
    cellTCounts{2}{mouseI} = TCounts;
    cellRunOccMap{2}{mouseI} = RunOccMap;
    
    %for mouseI = 1:4
    %for condI = 1:length(cellTBTdelay{mouseI})
    %    delayLengths{mouseI}{condI} = cell2mat(cellfun(@length,cellTBTdelay{mouseI}(condI).trialsX,'UniformOutput',false));
    %    min(delayLengths{mouseI}{condI})
    %end
    %end
    
    delayBinning = 0:20:320;
    saveName = fullfile(mainFolder,mice{mouseI},delayPFs);
    [~, ~, ~, ~, ~, ~, ~] =...
            PFsLinTBTdnmp(cellTBTdelay{mouseI}, delayBinning, 'numFrames', saveName, false,[1; 2]);
    switch exist(saveName,'file')
        case 0
            disp(['no placefields for delay found for ' mice{mouseI} ', making now'])
            [~, ~, ~, ~, ~, ~, ~] =...
            PFsLinTBTdnmp(cellTBTdelay{mouseI}, armBinEdges, minspeed, saveName, false,condPairs);
       case 2
            disp(['found placefields for delay for ' mice{mouseI} ', all good'])
    end
    
    load(saveName,'TMap_unsmoothed','TMap_zRates')
    cellPooledTMap_unsmoothedDelay{1}{mouseI} = TMap_unsmoothed;
    %cellPooledTMap_firesAtAllArm{1}{mouseI} = TMap_firesAtAll;
    cellPooledTMap_zRatesDelay{1}{mouseI} = TMap_unsmoothed; 
    cellTCounts{3}{mouseI} = TCounts;
    cellRunOccMap{3}{mouseI} = RunOccMap;
end

numTrials = [];
for mouseI = 1:numMice
    numTrialCells{mouseI} = CellsActiveEachTrial(cellTBT{mouseI});
    for condI = 1:4
         numTrialCellsPctTotal{mouseI}{condI} = numTrialCells{mouseI}{condI}/numCells(mouseI);
         numTrialCellsPctDay{mouseI}{condI} = numTrialCells{mouseI}{condI}./sum(cellSSI{mouseI}>0,1);
         numTrialCellsPctDayMean(mouseI,condI) = mean(mean(numTrialCellsPctDay{mouseI}{condI}));
     
        sessHere =unique(cellTBT{mouseI}(condI).sessID);
        numTrials{mouseI}(condI,:) = histcounts(cellTBT{mouseI}(condI).sessID,min(sessHere)-0.5:1:max(sessHere)+0.5);
    end
end

%Number of trials original
%{
for mouseI = 1:numMice
    %load(fullfile(mouseDefaultFolder{mouseI},'fullReg.mat'),'fullReg')
    %cellFullReg{mouseI} = fullReg;
    load(fullfile(mouseDefaultFolder{mouseI},'DNMPdataTable.mat'))
    cellDataTable{mouseI} = DNMPdataTable;
    for regI = 1:length(cellRealDays{mouseI})
       regSess = find(cellDataTable{mouseI}.RealDay==cellRealDays{mouseI}(regI));
       folderI = find(contains(cellFullReg{mouseI}.RegSessions,cellDataTable{mouseI}.FolderName(regSess)));
       if isempty(folderI)
           if contains(mouseDefaultFolder{mouseI},cellDataTable{mouseI}.FolderName(regSess))
               regFolder = mouseDefaultFolder{mouseI};
           end
       else
           regFolder = cellFullReg{mouseI}.RegSessions{folderI};
       end
       regFolderFull = fullfile(mouseDefaultFolder{mouseI}(1:2),regFolder(3:end));
       xlFile = ls(fullfile(regFolderFull,'*DNMPsheet.xlsx'));
       if isempty(xlFile)
           disp('bluesheet')
           mouseI
           regI
           xlFile = ls(fullfile(regFolderFull,'*DNMPbluesheet.xlsx'));
       end
       if size(xlFile,1)==1
           [frames,txt,~] = xlsread(fullfile(regFolderFull,xlFile));
           numTrialsFull{mouseI}(regI) = size(frames,1);
       end
       if size(xlFile,1)>1
           disp('too many files')
           mouseI
           regI
       end
       
    end
end
%}
Conds = GetTBTconds(cellTBT{1});

useRealDays=1;
alignDayPairsREV=1;

pooledRealDayDiffs = [];
pooledAllRealDayDiffs = [];
for mouseI = 1:numMice
    dayPairs{mouseI} = combnk(1:numDays(mouseI),2);
    realDayPairs{mouseI} = cellRealDays{mouseI}(dayPairs{mouseI});
    realDayDiffs{mouseI} = diff(realDayPairs{mouseI},1,2);
    pooledRealDayDiffs = [pooledRealDayDiffs; realDayDiffs{mouseI}];
    
    allDayPairs{mouseI} = GetAllCombs(1:numDays(mouseI),1:numDays(mouseI));
    allRealDayPairs{mouseI} = cellRealDays{mouseI}(allDayPairs{mouseI});
    allRealDayDiffs{mouseI} = diff(allRealDayPairs{mouseI},1,2);
    pooledAllRealDayDiffs = [pooledAllRealDayDiffs; allRealDayDiffs{mouseI}];
end

allVels = [];
for mouseI = 1:numMice
    for condI = 1:4
        for trialI = 1:length(cellTBT{mouseI}(condI).trialVel)
            allVels = [allVels; cellTBT{mouseI}(condI).trialVel{trialI}(:)];
        end
    end
end

purp = [0.4902    0.1804    0.5608]; orng = [0.8510    0.3294    0.1020];
colorAssc = { [1 0 0]     [0 0 1]    [1 0 1]       [0 1 1]         purp     orng        [0 1 0]       [0 0 0]};
traitLabels = {'splitLR' 'splitST'  'splitLRonly' 'splitSTonly' 'splitBOTH' 'splitONE' 'splitEITHER' 'dontSplit'};

pctUA = [];
pctUP = [];
pctUAarm = [];
pctUParm = [];
for mouseI = 1:numMice
    nCellsAboveThreshStem = sum(dayUse{mouseI},1);
    nCellsAboveThreshArm = sum(dayUseArm{mouseI},1);
    
    nCellsHere = sum(cellSSI{mouseI}>0,1);
    
    nCellsFiredAtAllStem = sum(sum(trialReli{mouseI},3)>0,1);
    nCellsFiredAtAllArm = sum(sum(trialReliArm{mouseI},3)>0,1);
    
    pctUseActive = nCellsAboveThreshStem ./ nCellsFiredAtAllStem;
    pctUsePresent = nCellsAboveThreshStem ./ nCellsHere;
    
    pctUseActiveArm = nCellsAboveThreshArm ./ nCellsFiredAtAllArm;
    pctUsePResentArm = nCellsAboveThreshArm ./ nCellsHere;
    
    pctUA = [pctUA; pctUseActive(:)];
    pctUP = [pctUP; pctUsePresent(:)];
    pctUAarm = [pctUAarm; pctUseActiveArm(:)];
    pctUParm = [pctUParm; pctUsePResentArm(:)];
end
   
disp(['Stem: cells above thresh/cells present: ' num2str(mean(pctUP)) ' +/- ' num2str(standarderrorSL(pctUP))])
disp(['Stem: cells above thresh/cells active: ' num2str(mean(pctUA)) ' +/- ' num2str(standarderrorSL(pctUA))])
disp(['Arm: cells above thresh/cells present: ' num2str(mean(pctUParm)) ' +/- ' num2str(standarderrorSL(pctUParm))])
disp(['Arm: cells above thresh/cells active: ' num2str(mean(pctUAarm)) ' +/- ' num2str(standarderrorSL(pctUAarm))])

disp('Done all setup stuff')
disp(['velThresh is ' num2str(velThresh)])
%% Change in reliability
% Average all cells trial reliability


% Within cell changes in reliability
for mouseI = 1:numMice
    daysHere = cellSSI{mouseI}>0;
    reliSlopeAllDays{mouseI} = nan(numCells(mouseI),1);
    reliSlopeActiveDays{mouseI} = nan(numCells(mouseI),1);
    reliChangeActiveDayPairs{mouseI} = nan(size(cellSSI{mouseI}));
    reliChangeAllDayPairs{mouseI} = nan(size(cellSSI{mouseI}));
    reliRhoAllDays{mouseI} = nan(numCells(mouseI),1);
    reliPvalAllDays{mouseI} = nan(numCells(mouseI),1);
    reliRhoActiveDays{mouseI} = nan(numCells(mouseI),1);
    reliPvalActiveDays{mouseI} = nan(numCells(mouseI),1);
    
    for cellI = 1:size(cellSSI{mouseI},1)
        % All days found
        daysH = daysHere(cellI,:);
        if sum(daysH) > 1
            dt = trialReliAll{mouseI}(cellI,daysH);
            rd = cellRealDays{mouseI}(daysH);
            %[reliSlopeAllDays{mouseI}(cellI), ~, ~, ~, ~, ~] = fitLinRegSL(dt, rd); %slope, intercept, fitLine, rr, pSlope, pInt
            [reliRhoAllDays{mouseI}(cellI),reliPvalAllDays{mouseI}(cellI)]=corr(dt(:),rd(:),'type','Spearman');
            % pairs of days, 2:end
        end
        
        
        % All days with stem reliability > 0
        daysJ = trialReliAll{mouseI}(cellI,:)>0;
        dy = trialReliAll{mouseI}(cellI,daysJ);
        if sum(daysJ) > 1
            dy = trialReliAll{mouseI}(cellI,daysJ);
            rd = cellRealDays{mouseI}(daysJ);
            %[reliSlopeActiveDays{mouseI}(cellI), ~, ~, ~, ~, ~] = fitLinRegSL(dy, rd);
            [reliRhoActiveDays{mouseI}(cellI),reliPvalActiveDays{mouseI}(cellI)]=corr(dy(:),rd(:),'type','Spearman');
            
            % pairs of days 
            %{
            daysJJ = find(daysJ);
            % trialReliAll > 0
            for dj = 2:length(daysJJ)
                reliChangeActiveDayPairs{mouseI}(cellI,dj) = ...
                    trialReliAll{mouseI}(cellI,daysJJ(dj)) - trialReliAll{mouseI}(cellI,daysJJ(dj-1));
            end
            for dk = 1:length(daysJJ)
                daysHH = find(daysH);
                if daysJJ(dk)>daysHH(1)
                    prevDayHere = daysHH(find(daysHH<daysJJ(dk),1,'last'));
                    reliChangeAllDayPairs{mouseI}(cellI,dk) = ....
                        trialReliAll{mouseI}(cellI,daysJJ(dk)) - trialReliAll{mouseI}(cellI,prevDayHere);
                end
            end
            %}
        end
    end
end

%reliSlopeAllDaysPooled = PoolCellArrAcrossMice(reliSlopeAllDays);
%reliSlopeActiveDaysPooled = PoolCellArrAcrossMice(reliSlopeActiveDays);

reliRhoAllDaysPooled = PoolCellArrAcrossMice(reliRhoAllDays);
reliPvalAllDaysPooled = PoolCellArrAcrossMice(reliPvalAllDays);
reliRhoActiveDaysPooled = PoolCellArrAcrossMice(reliRhoActiveDays);
reliPvalActiveDaysPooled = PoolCellArrAcrossMice(reliPvalActiveDays);

figure; 
subplot(1,2,1)
histogram(reliRhoActiveDaysPooled,[-1:0.05:1])
title(['days allReli>0, All rho values, mean=' num2str(mean(reliRhoActiveDaysPooled)) ', std=' num2str(std(reliRhoActiveDaysPooled))])
xlabel('% trials active')
subplot(1,2,2)
histogram(reliRhoActiveDaysPooled(reliPvalActiveDaysPooled<=0.05),[-1:0.05:1])
title('days allReli>0, Only p<0.05 rho vals')
xlabel('% trials active')
suptitleSL('Slope of allTrialReli over active days, all cells')

%% Single lap correlation notes: ensembles?
numConds = length(cellTBT{1});
tic
singleTrialTMap = SingleTrialPVs(cellTBT{1},[stemBinEdges(1) stemBinEdges(end)],[]);
toc
%for binI = 1:size(singleTrialTMap{1}{1},2)
for sessI = 1:numDays(mouseI)
    trialMat = [];
    condMarker = [];
    trialNums = [];
    lapLabels = {};
    %Pool them all together cells x trials?
    for condI = 1:numConds
        trialsHere = cellTBT{mouseI}(condI).sessID==sessI;
        trialMat = [trialMat, singleTrialTMap{condI}{trialsHere}];
        condMarker = [condMarker, condI*ones(1,sum(trialsHere))];
        trialNums = [trialNums; cellTBT{1}(condI).lapNumber(trialsHere)];
    end
    lapLabels = [lt(condMarker)];
    
    [stCorrsRho,stCorrsPval] = corr(trialMat,'type','Spearman');
    D1 = pdist(trialMat,'cosine');
    I = logical(eye(50));
    stCorrsRho(I) = 0;
    
    figure; imagesc(stCorrsRho); ff = gca;
    ff.XTickLabels;
    ff.XTick = [1:50];
    ff.XTickLabels = lapLabels;
    ff.YTick = [1:50];
    ff.YTickLabels = lapLabels;
       
    
    stCorrsRho = -stCorrsRho;
    Z = linkage(stCorrsRho);
    da = figure; dendrogram(Z,0)
    xt = str2double(string(da.Children.XTickLabel));
    da.Children.XTickLabel = lapLabels(xt);
end
    
% Ensembles:
%Refine TMaps into binary yes/no cell fired
%For each pair of trials, get num cells fired in both out of total unique
%cells fired in both
    
    
%% Splitter cells: Shuffle versions, pooled
numShuffles = 1000;
shuffThresh = 1 - pThresh;
binsMin = 1;
splitDir = 'splitters';
%splitDir = 'splittersSpd01'; % velThreh = 0.5
%splitDir = 'splittersSpd02'; % velThreh = 1

splitterType = {'LR' 'ST'};
splitterCPs = {[1 2] [3 4]};
splitterLoc = {'stem' 'arm'}; %splitterLoc = {'stem'}

unpooledCPs = {[1 2; 3 4];[1 3;2 4]};

%Get/make splitting
binsAboveShuffle = [];
thisCellSplits = [];
CIbounds = [];
whichBinsAboveShuffle = [];
for mouseI = 1:numMice
    shuffleDir = fullfile(mainFolder,mice{mouseI},splitDir);
    if exist(shuffleDir,'dir')==0
        mkdir(shuffleDir)
    end
    
    for stI = 1:length(splitterType)
        for slI = 1:length(splitterLoc)
            switch splitterLoc{slI}
                case 'stem'
                    binEdgesHere = stemBinEdges;
                    splitterFile = fullfile(shuffleDir,['splitters' splitterType{stI} '.mat']);
                    cellTMap = cellPooledTMap_unsmoothed{1}{mouseI}; % Original version
                    %cellTMap = cellPooledTMap_firesAtAll{1}{mouseI};
                    [cellTMap, ~, ~, ~, ~, ~, ~] =...
                        PFsLinTBTdnmp(cellTBT{mouseI}, stemBinEdges, minspeed, [], false,condPairs);
                    tbtHere = cellTBT{mouseI};
                case 'arm'
                    splitterFile = fullfile(shuffleDir,['ARMsplitters' splitterType{stI} '.mat']);
                    binEdgesHere = armBinEdges;
                    cellTMap = cellPooledTMap_unsmoothedArm{1}{mouseI}; % Original version
                    %cellTMap = cellPooledTMap_firesAtAllArm{1}{mouseI};
                    [cellTMap, ~, ~, ~, ~, ~, ~] =...
                        PFsLinTBTdnmp(cellTBTarm{mouseI}, armBinEdges, minspeed, [], false,condPairs);
                    tbtHere = cellTBTarm{mouseI};
            end
            
            %disp(['Getting trial length differences for mouse ' num2str(mouseI)])
            %[trialLengthMeanDiff{slI}{stI}{mouseI}, trialLengthStsdDiff{slI}{stI}{mouseI}, trialLengthRankSumP{slI}{stI}{mouseI}, lengthData{slI}{stI}{mouseI}] =...
            %    TrialLengthWrapper1(tbtHere, splitterType{stI},'pooled', numShuffles, binEdgesHere, shuffThresh);
            
            if exist(splitterFile,'file')==0
            disp(['did not find ' splitterType{stI} ' on ' splitterLoc{slI} ' splitting for mouse ' num2str(mouseI) ', making now'])
            tic
            [binsAboveShuffle, thisCellSplits,CIbounds, whichBinsAboveShuffle] = SplitterWrapper4(tbtHere, cellTMap,  splitterType{stI},...
                'pooled', numShuffles, binEdgesHere, minspeed, shuffThresh, binsMin);
            save(splitterFile,'binsAboveShuffle','thisCellSplits','CIbounds','whichBinsAboveShuffle')
            %save(splitterFile,'CIbounds','whichBinsAboveShuffle','-append')
            toc
            end
            
            % %{
            loadedSplit = load(splitterFile);
            
            binsAboveShuffle{slI}{stI}{mouseI} = loadedSplit.binsAboveShuffle;
            thisCellSplits{slI}{stI}{mouseI} = loadedSplit.thisCellSplits;
            try
            CIbounds{slI}{stI}{mouseI} = loadedSplit.CIbounds;
            whichBinsAboveShuffle{slI}{stI}{mouseI} = loadedSplit.whichBinsAboveShuffle;
            end
            
            [rateDiff{slI}{stI}{mouseI}, rateSplit{slI}{stI}{mouseI}, meanRateDiff{slI}{stI}{mouseI}, DIeach{slI}{stI}{mouseI},...
                DImean{slI}{stI}{mouseI}, DIall{slI}{stI}{mouseI}] =...
                LookAtSplitters4(cellTMap, splitterCPs{stI}, []);
            
            %Splitters for unpooled data
            [unpooledTMap{slI}{mouseI}, ~, ~, ~, ~, ~, ~] =...
            PFsLinTBTdnmp(tbtHere, binEdgesHere, minspeed, [], false,[1;2;3;4]);
            [~, ~, ~, ~,...
                DImeanUnpooled{slI}{stI}{mouseI}, DIallUnPooled{slI}{stI}{mouseI}] =...
                LookAtSplitters4(unpooledTMap{slI}{mouseI}, unpooledCPs{stI}, []);
            %}
            
            disp(['done ' splitterType{stI} ' on ' splitterLoc{slI} ' splitting for mouse ' num2str(mouseI)])
        end
    end
    %}
    %Delay splitters
    
    splitterFile = fullfile(shuffleDir,['splittersLRdelay.mat']);
    if exist(splitterFile,'file')==0
        disp(['did not find delay splitting for mouse ' num2str(mouseI) ', making now'])
        tic
        [binsAboveShuffle, thisCellSplits] = SplitterWrapper4(cellTBTdelay{mouseI}, cellPooledTMap_unsmoothedDelay{1}{mouseI},  [],...
                'delayEpoch', numShuffles, delayBinning, 'numFrames', shuffThresh, binsMin);
        save(splitterFile,'binsAboveShuffle','thisCellSplits')
        toc
    end
    loadedSplit = load(splitterFile);
            
    binsAboveShuffle{3}{1}{mouseI} = loadedSplit.binsAboveShuffle;
    thisCellSplits{3}{1}{mouseI} = loadedSplit.thisCellSplits;
            %}
end
disp('Done loading all splitting')

%%  Half-trials consistency
disp('running half trials for splitters')

for slI = 1:length(splitterLoc)
    for stI = 1:length(splitterType)
        
            halfSplitAsameLog{slI}{stI} = [];
            halfSplitAsameLogReli{slI}{stI} = [];
            halfSplitAsameLogReliAll{slI}{stI} = [];
            halfSplitBsameLog{slI}{stI} = [];
            halfSplitBsameLogReli{slI}{stI} = [];
            halfSplitBsameLogReliAll{slI}{stI} = [];
            
            halfSplitAciLog{slI}{stI} = [];
            halfSplitAciLogReli{slI}{stI} = [];
            halfSplitAciLogReliAll{slI}{stI} = [];
            halfSplitBciLog{slI}{stI} = [];
            halfSplitBciLogReli{slI}{stI} = [];
            halfSplitBciLogReliAll{slI}{stI} = [];
            
            halfSplitAciSigLog{slI}{stI} = [];
            halfSplitAciSigLogReli{slI}{stI} = [];
            halfSplitAciSigLogReliAll{slI}{stI} = [];
            halfSplitBciSigLog{slI}{stI} = [];
            halfSplitBciSigLogReli{slI}{stI} = [];
            halfSplitBciSigLogReliAll{slI}{stI} = [];
            %}
            
            rateDiffCorr.AvB.rhoLog{slI}{stI} = [];
            rateDiffCorr.AvB.rhoLogReli{slI}{stI} = [];
            rateDiffCorr.AvB.rhoLogReliAll{slI}{stI} = [];
            
            rateDiffCorr.AvB.pLog{slI}{stI} = [];
            
            rateDiffCorr.AvAll.rhoLog{slI}{stI} = [];
            rateDiffCorr.AvAll.rhoLogReli{slI}{stI} = [];
            rateDiffCorr.AvAll.rhoLogReliAll{slI}{stI} = [];
            
            rateDiffCorr.AvAll.pLog{slI}{stI} = [];
            
            rateDiffCorr.BvAll.rhoLog{slI}{stI} = [];
            rateDiffCorr.BvAll.rhoLogReli{slI}{stI} = [];
            rateDiffCorr.BvAll.rhoLogReliAll{slI}{stI} = [];
            
            rateDiffCorr.BvAll.pLog{slI}{stI} = [];
        %}
        
         tmapAvBrho = [];
         tmapAvBrhoReli = [];
         tmapAvBrhoReliAll  = [];
         tmapAvBpval  = [];
         
         tmapAvALLrho = [];
         tmapAvALLrhoReli = [];
         tmapAvALLrhoReliAll = [];
         tmapAvALLpval = [];
         
         tmapBvALLrho = [];
         tmapBvALLrhoReli = [];
         tmapBvALLrhoReliAll = [];
         tmapBvALLpval = [];
    end
end


for mouseI = 1:numMice
    [cellUnpooledTmap{mouseI}, ~, ~, ~, ~, ~, ~] =...
            PFsLinTBTdnmp(cellTBT{mouseI}, stemBinEdges, minspeed, [], false,[1;2;3;4]);
     trMax{mouseI} = max(trialReli{mouseI},[],3);
end

tic
for shuffI = 1:100
    disp(['running shuffle ' num2str(shuffI)])
    
for mouseI = 1:numMice 
    for slI = 1:length(splitterLoc)
        switch splitterLoc{slI}
            case 'stem'
                tbtHere = cellTBT{mouseI};
                binEdgesHere = stemBinEdges;
            case 'arm'
                tbtHere = cellTBTarm{mouseI};
                binEdgesHere = armBinEdges;
        end
        
        %Split tbt
        [tbtA, tbtB] = SplitTrialByTrial(tbtHere, 'random');
         
        % Check correlation of place fields
        %{
        [cellTMapA, ~, ~, ~, ~, ~, ~] =...
            PFsLinTBTdnmp(tbtA, binEdgesHere, minspeed, [], false,[1;2;3;4]);
        [cellTMapB, ~, ~, ~, ~, ~, ~] =...
            PFsLinTBTdnmp(tbtB, binEdgesHere, minspeed, [], false,[1;2;3;4]);
        
        
        rhoAvBtmap = nan(numCells(mouseI),numDays(mouseI));
        pAvBtmap = nan(numCells(mouseI),numDays(mouseI));
        rhoAvALLtmap = nan(numCells(mouseI),numDays(mouseI));
        pAvALLtmap = nan(numCells(mouseI),numDays(mouseI));
        rhoBvALLtmap = nan(numCells(mouseI),numDays(mouseI));
        pBvALLtmap = nan(numCells(mouseI),numDays(mouseI));
        
        for cellI = 1:numCells(mouseI)
                for dayI = 1:numDays(mouseI)
                    if sum(trialReli{mouseI}(cellI,dayI,:),3) > 0
                        
                        [rhoAvBtmap(cellI,dayI),pAvBtmap(cellI,dayI)] = corr([cellTMapA{cellI,dayI,:}]',[cellTMapB{cellI,dayI,:}]','type','Spearman');
                        [rhoAvALLtmap(cellI,dayI),pAvALLtmap(cellI,dayI)] = corr([cellTMapA{cellI,dayI,:}]',[cellUnpooledTmap{mouseI}{cellI,dayI,:}]','type','Spearman');
                        [rhoBvALLtmap(cellI,dayI),pBvALLtmap(cellI,dayI)] = corr([cellTMapB{cellI,dayI,:}]',[cellUnpooledTmap{mouseI}{cellI,dayI,:}]','type','Spearman');
                    end
                end
        end
        
        %Logs...
         tmapAvBrho = [tmapAvBrho; rhoAvBtmap(~isnan(rhoAvBtmap))];
         tmapAvBrhoReli = [tmapAvBrhoReli; trialReli{mouseI}(~isnan(rhoAvBtmap))];
         tmapAvBrhoReliAll = [tmapAvBrhoReliAll; trialReliAll{mouseI}(~isnan(rhoAvBtmap))];
         tmapAvBpval = [tmapAvBpval; pAvBtmap(~isnan(rhoAvBtmap))];
         
         tmapAvALLrho = [tmapAvALLrho; rhoAvALLtmap(~isnan(rhoAvALLtmap))];
         tmapAvALLrhoReli = [tmapAvALLrhoReli; trialReli{mouseI}(~isnan(rhoAvALLtmap))];
         tmapAvALLrhoReliAll = [tmapAvALLrhoReliAll; trialReliAll{mouseI}(~isnan(rhoAvALLtmap))];
         tmapAvALLpval = [tmapAvALLpval; pAvALLtmap(~isnan(rhoAvALLtmap))];
         
         tmapBvALLrho = [tmapBvALLrho; rhoBvALLtmap(~isnan(rhoBvALLtmap))];
         tmapBvALLrhoReli = [tmapBvALLrhoReli; trialReli{mouseI}(~isnan(rhoBvALLtmap))];
         tmapBvALLrhoReliAll = [tmapBvALLrhoReliAll; trialReliAll{mouseI}(~isnan(rhoBvALLtmap))];
         tmapBvALLpval = [tmapBvALLpval; pBvALLtmap(~isnan(rhoBvALLtmap))];
            %}
        
         % Make new Tmaps
        [cellTMapA, ~, ~, ~, ~, ~, ~] =...
            PFsLinTBTdnmp(tbtA, binEdgesHere, minspeed, [], false,condPairs);
        [cellTMapB, ~, ~, ~, ~, ~, ~] =...
            PFsLinTBTdnmp(tbtB, binEdgesHere, minspeed, [], false,condPairs);
          %}   
          
        
        for stI = 1:length(splitterType)   
            % Evaluate splitting, compare across and compare to CI bounds...
            
            [rateDiffSplitA{slI}{stI}{mouseI}, ~, meanRateDiffSplitA{slI}{stI}{mouseI}, ...
                DIeachSplitA{slI}{stI}{mouseI}, DImeanSplitA{slI}{stI}{mouseI}, ~] =...
                LookAtSplitters4(cellTMapA, splitterCPs{stI}, []);
            [rateDiffSplitB{slI}{stI}{mouseI}, ~, meanRateDiffSplitB{slI}{stI}{mouseI}, ...
                DIeachSplitB{slI}{stI}{mouseI}, DImeanSplitB{slI}{stI}{mouseI}, ~] =...
                LookAtSplitters4(cellTMapB, splitterCPs{stI}, []);
            
            % Pre-allocate:
            rateDiffCorrs.AvB{mouseI}{stI}{slI}.rho = nan(numCells(mouseI),numDays(mouseI));
            rateDiffCorrs.AvB{mouseI}{stI}{slI}.p = nan(numCells(mouseI),numDays(mouseI));
            rateDiffCorrs.AvAll{mouseI}{stI}{slI}.rho = nan(numCells(mouseI),numDays(mouseI));
            rateDiffCorrs.AvAll{mouseI}{stI}{slI}.p = nan(numCells(mouseI),numDays(mouseI));
            rateDiffCorrs.BvAll{mouseI}{stI}{slI}.rho = nan(numCells(mouseI),numDays(mouseI));
            rateDiffCorrs.BvAll{mouseI}{stI}{slI}.p = nan(numCells(mouseI),numDays(mouseI));
            
            halfSplitAsame{mouseI}{stI}{slI} = nan(numCells(mouseI),numDays(mouseI)); % Splits in the same direction as original map
            halfSplitBsame{mouseI}{stI}{slI} = nan(numCells(mouseI),numDays(mouseI));
            halfSplitAci{mouseI}{stI}{slI} = nan(numCells(mouseI),numDays(mouseI)); % Splits outside of the confidence interval of the original trials
            halfSplitBci{mouseI}{stI}{slI} = nan(numCells(mouseI),numDays(mouseI));
            halfSplitAciSig{mouseI}{stI}{slI} = nan(numCells(mouseI),numDays(mouseI)); % Splits outside of the confidence interval of the original trials where above shuffle
            halfSplitBciSig{mouseI}{stI}{slI} = nan(numCells(mouseI),numDays(mouseI));
            %}
            % Ask how much reliability improves by activity thresholds, try a bunch of different things
            for cellI = 1:numCells(mouseI)
                for dayI = 1:numDays(mouseI)
                    if sum(trialReli{mouseI}(cellI,dayI,:),3) > 0
                        
                        
                        % Correlations of rate differences 
                        
                        [rhoAvB,pValAvB] = corr(rateDiffSplitA{slI}{stI}{mouseI}{cellI,1}(:),rateDiffSplitB{slI}{stI}{mouseI}{cellI,1}(:),'Type','Spearman');  
                        [rhoAvAll,pValAvAll] = corr(rateDiff{slI}{stI}{mouseI}{cellI,1}(:),rateDiffSplitA{slI}{stI}{mouseI}{cellI,1}(:),'Type','Spearman');  
                        [rhoBvAll,pValBvAll] = corr(rateDiff{slI}{stI}{mouseI}{cellI,1}(:),rateDiffSplitB{slI}{stI}{mouseI}{cellI,1}(:),'Type','Spearman');  
                        rateDiffCorrs.AvB{mouseI}{stI}{slI}.rho(cellI,dayI) = rhoAvB;    rateDiffCorrs.AvB{mouseI}{stI}{slI}.p(cellI,dayI) = pValAvB;
                        rateDiffCorrs.AvAll{mouseI}{stI}{slI}.rho(cellI,dayI) = rhoAvAll;    rateDiffCorrs.AvAll{mouseI}{stI}{slI}.p(cellI,dayI) = pValAvAll;
                        rateDiffCorrs.BvAll{mouseI}{stI}{slI}.rho(cellI,dayI) = rhoBvAll;    rateDiffCorrs.BvAll{mouseI}{stI}{slI}.p(cellI,dayI) = pValBvAll;
                        
                        % Are rate differences outside of CIbounds
                        rateSplitsPos = rateDiff{slI}{stI}{mouseI}{cellI,1} > 0;
                        rateSplitsNeg = rateDiff{slI}{stI}{mouseI}{cellI,1} < 0;

                        ciHere = CIbounds{slI}{stI}{mouseI}{cellI,dayI}; % Somehow missing data here?
                        binHere = whichBinsAboveShuffle{slI}{stI}{mouseI}{cellI,dayI};
                            % ciHere: row 1 positive bounds, row 2 negative bound
                        
                        %ciHere = CIbounds{cellI,dayI};
                        %binHere = whichBinsAboveShuffle{cellI,dayI};
                        
                        % Did it split in the same direction as original? (pctBins)
                        halfSplitPosA = sum(rateDiffSplitA{slI}{stI}{mouseI}{cellI,1}(rateSplitsPos) > 0) / sum(rateSplitsPos);
                        halfSplitPosB = sum(rateDiffSplitB{slI}{stI}{mouseI}{cellI,1}(rateSplitsPos) > 0) / sum(rateSplitsPos);
                    
                        halfSplitNegA = sum(rateDiffSplitA{slI}{stI}{mouseI}{cellI,1}(rateSplitsNeg) < 0) / sum(rateSplitsNeg);
                        halfSplitNegB = sum(rateDiffSplitB{slI}{stI}{mouseI}{cellI,1}(rateSplitsNeg) < 0) / sum(rateSplitsNeg);
                        
                        halfSplitAsame{mouseI}{stI}{slI}(cellI,dayI) = nansum([halfSplitPosA halfSplitNegA]) / (any(rateSplitsPos) + any(rateSplitsNeg));
                        halfSplitBsame{mouseI}{stI}{slI}(cellI,dayI) = nansum([halfSplitPosB halfSplitNegB]) / (any(rateSplitsPos) + any(rateSplitsNeg));
                       
                        % Was that split above the confidence interval?
                        halfSplitPosAci = sum(rateDiffSplitA{slI}{stI}{mouseI}{cellI,1}(rateSplitsPos) > ciHere(1,rateSplitsPos)) / sum(rateSplitsPos);
                        halfSplitPosBci = sum(rateDiffSplitB{slI}{stI}{mouseI}{cellI,1}(rateSplitsPos) > ciHere(1,rateSplitsPos)) / sum(rateSplitsPos);
                    
                        halfSplitNegAci = sum(rateDiffSplitA{slI}{stI}{mouseI}{cellI,1}(rateSplitsNeg) < ciHere(2,rateSplitsNeg)) / sum(rateSplitsNeg);
                        halfSplitNegBci = sum(rateDiffSplitB{slI}{stI}{mouseI}{cellI,1}(rateSplitsNeg) < ciHere(2,rateSplitsNeg)) / sum(rateSplitsNeg);
                        
                        halfSplitAci{mouseI}{stI}{slI}(cellI,dayI) =  nansum([halfSplitPosAci halfSplitNegAci]) / (any(rateSplitsPos) + any(rateSplitsNeg));
                        halfSplitBci{mouseI}{stI}{slI}(cellI,dayI) =  nansum([halfSplitPosBci halfSplitNegBci]) / (any(rateSplitsPos) + any(rateSplitsNeg));
                        
                        % Was that split above the confidernce interval in the bins that significantly split?
                        halfSplitPosAciSig(cellI,dayI) = sum(rateDiffSplitA{slI}{stI}{mouseI}{cellI,1}(rateSplitsPos & binHere) > ciHere(1,rateSplitsPos & binHere)) / sum(rateSplitsPos & binHere);
                        halfSplitPosBciSig(cellI,dayI) = sum(rateDiffSplitB{slI}{stI}{mouseI}{cellI,1}(rateSplitsPos & binHere) > ciHere(1,rateSplitsPos & binHere)) / sum(rateSplitsPos & binHere);
                    
                        halfSplitNegAciSig(cellI,dayI) = sum(rateDiffSplitA{slI}{stI}{mouseI}{cellI,1}(rateSplitsNeg & binHere) < ciHere(2,rateSplitsNeg & binHere)) / sum(rateSplitsNeg & binHere);
                        halfSplitNegBciSig(cellI,dayI) = sum(rateDiffSplitB{slI}{stI}{mouseI}{cellI,1}(rateSplitsNeg & binHere) < ciHere(2,rateSplitsNeg & binHere)) / sum(rateSplitsNeg & binHere);
                        
                        halfSplitAciSig{mouseI}{stI}{slI}(cellI,dayI) =  nansum([halfSplitPosAciSig(cellI,dayI) halfSplitNegAciSig(cellI,dayI)]) / (any(rateSplitsPos) + any(rateSplitsNeg));
                        halfSplitBciSig{mouseI}{stI}{slI}(cellI,dayI) =  nansum([halfSplitPosBciSig(cellI,dayI) halfSplitNegBciSig(cellI,dayI)]) / (any(rateSplitsPos) + any(rateSplitsNeg));
                        %}
                        
                    end
                end
            end
            
            % Make a big log so we can filter success accoring to reliability
            
            halfSplitAsameLog{slI}{stI} = [halfSplitAsameLog{slI}{stI}; halfSplitAsame{mouseI}{stI}{slI}(~isnan(halfSplitAsame{mouseI}{stI}{slI}))];
            halfSplitAsameLogReli{slI}{stI} = [halfSplitAsameLogReli{slI}{stI}; trMax{mouseI}(~isnan(halfSplitAsame{mouseI}{stI}{slI}))];
            halfSplitAsameLogReliAll{slI}{stI} = [halfSplitAsameLogReliAll{slI}{stI}; trialReliAll{mouseI}(~isnan(halfSplitAsame{mouseI}{stI}{slI}))];
            halfSplitBsameLog{slI}{stI} = [halfSplitBsameLog{slI}{stI}; halfSplitBsame{mouseI}{stI}{slI}(~isnan(halfSplitBsame{mouseI}{stI}{slI}))];
            halfSplitBsameLogReli{slI}{stI} = [halfSplitBsameLogReli{slI}{stI}; trMax{mouseI}(~isnan(halfSplitBsame{mouseI}{stI}{slI}))];
            halfSplitBsameLogReliAll{slI}{stI} = [halfSplitBsameLogReliAll{slI}{stI}; trialReliAll{mouseI}(~isnan(halfSplitBsame{mouseI}{stI}{slI}))];
            
            halfSplitAciLog{slI}{stI} = [halfSplitAciLog{slI}{stI}; halfSplitAci{mouseI}{stI}{slI}(~isnan(halfSplitAci{mouseI}{stI}{slI}))];
            halfSplitAciLogReli{slI}{stI} = [halfSplitAciLogReli{slI}{stI}; trMax{mouseI}(~isnan(halfSplitAci{mouseI}{stI}{slI}))];
            halfSplitAciLogReliAll{slI}{stI} = [halfSplitAciLogReliAll{slI}{stI}; trialReliAll{mouseI}(~isnan(halfSplitAci{mouseI}{stI}{slI}))];
            halfSplitBciLog{slI}{stI} = [halfSplitBciLog{slI}{stI}; halfSplitBci{mouseI}{stI}{slI}(~isnan(halfSplitBci{mouseI}{stI}{slI}))];
            halfSplitBciLogReli{slI}{stI} = [halfSplitBciLogReli{slI}{stI}; trMax{mouseI}(~isnan(halfSplitBci{mouseI}{stI}{slI}))];
            halfSplitBciLogReliAll{slI}{stI} = [halfSplitBciLogReliAll{slI}{stI}; trialReliAll{mouseI}(~isnan(halfSplitBci{mouseI}{stI}{slI}))];
            
            halfSplitAciSigLog{slI}{stI} = [halfSplitAciSigLog{stI}{slI}; halfSplitAciSig{mouseI}{stI}{slI}(~isnan(halfSplitAciSig{mouseI}{stI}{slI}))];
            halfSplitAciSigLogReli{slI}{stI} = [halfSplitAciSigLogReli{stI}{slI}; trMax{mouseI}(~isnan(halfSplitAciSig{mouseI}{stI}{slI}))];
            halfSplitAciSigLogReliAll{slI}{stI} = [halfSplitAciSigLogReliAll{stI}{slI}; trialReliAll{mouseI}(~isnan(halfSplitAciSig{mouseI}{stI}{slI}))];
            halfSplitBciSigLog{slI}{stI} = [halfSplitBciSigLog{stI}{slI}; halfSplitBciSig{mouseI}{stI}{slI}(~isnan(halfSplitBciSig{mouseI}{stI}{slI}))];
            halfSplitBciSigLogReli{slI}{stI} = [halfSplitBciSigLogReli{stI}{slI}; trMax{mouseI}(~isnan(halfSplitBciSig{mouseI}{stI}{slI}))];
            halfSplitBciSigLogReliAll{slI}{stI} = [halfSplitBciSigLogReliAll{stI}{slI}; trialReliAll{mouseI}(~isnan(halfSplitBciSig{mouseI}{stI}{slI}))];
            %}
            
            rateDiffCorr.AvB.rhoLog{slI}{stI} = [rateDiffCorr.AvB.rhoLog{slI}{stI}; rateDiffCorrs.AvB{mouseI}{stI}{slI}.rho(~isnan(rateDiffCorrs.AvB{mouseI}{stI}{slI}.rho))];
            rateDiffCorr.AvB.rhoLogReli{slI}{stI} = [rateDiffCorr.AvB.rhoLogReli{slI}{stI}; trMax{mouseI}(~isnan(rateDiffCorrs.AvB{mouseI}{stI}{slI}.rho))];
            rateDiffCorr.AvB.rhoLogReliAll{slI}{stI} = [rateDiffCorr.AvB.rhoLogReliAll{slI}{stI}; trialReliAll{mouseI}(~isnan(rateDiffCorrs.AvB{mouseI}{stI}{slI}.rho))];
            
            rateDiffCorr.AvB.pLog{slI}{stI} = [rateDiffCorr.AvB.pLog{slI}{stI}; rateDiffCorrs.AvB{mouseI}{stI}{slI}.p(~isnan(rateDiffCorrs.AvB{mouseI}{stI}{slI}.rho))];
                                                                                
            rateDiffCorr.AvAll.rhoLog{slI}{stI} = [rateDiffCorr.AvAll.rhoLog{slI}{stI}; rateDiffCorrs.AvAll{mouseI}{stI}{slI}.rho(~isnan(rateDiffCorrs.AvAll{mouseI}{stI}{slI}.rho))];
            rateDiffCorr.AvAll.rhoLogReli{slI}{stI} = [rateDiffCorr.AvAll.rhoLogReli{slI}{stI}; trMax{mouseI}(~isnan(rateDiffCorrs.AvAll{mouseI}{stI}{slI}.rho))];
            rateDiffCorr.AvAll.rhoLogReliAll{slI}{stI} = [rateDiffCorr.AvAll.rhoLogReliAll{slI}{stI}; trialReliAll{mouseI}(~isnan(rateDiffCorrs.AvAll{mouseI}{stI}{slI}.rho))];
            
            rateDiffCorr.AvAll.pLog{slI}{stI} = [rateDiffCorr.AvAll.pLog{slI}{stI}; rateDiffCorrs.AvAll{mouseI}{stI}{slI}.p(~isnan(rateDiffCorrs.AvAll{mouseI}{stI}{slI}.rho))];
            
            rateDiffCorr.BvAll.rhoLog{slI}{stI} = [rateDiffCorr.BvAll.rhoLog{slI}{stI}; rateDiffCorrs.BvAll{mouseI}{stI}{slI}.rho(~isnan(rateDiffCorrs.BvAll{mouseI}{stI}{slI}.rho))];
            rateDiffCorr.BvAll.rhoLogReli{slI}{stI} = [rateDiffCorr.BvAll.rhoLogReli{slI}{stI}; trMax{mouseI}(~isnan(rateDiffCorrs.BvAll{mouseI}{stI}{slI}.rho))];
            rateDiffCorr.BvAll.rhoLogReliAll{slI}{stI} = [rateDiffCorr.BvAll.rhoLogReliAll{slI}{stI}; trialReliAll{mouseI}(~isnan(rateDiffCorrs.BvAll{mouseI}{stI}{slI}.rho))];
            
            rateDiffCorr.BvAll.pLog{slI}{stI} = [rateDiffCorr.BvAll.pLog{slI}{stI}; rateDiffCorrs.BvAll{mouseI}{stI}{slI}.p(~isnan(rateDiffCorrs.BvAll{mouseI}{stI}{slI}.rho))];
            %}
            
                        
        end
    end
end

end
toc

trialReliSteps = 0:0.01:0.5;
for slI = 1:length(splitterLoc)
    for stI = 1:length(splitterType)

        for trsI = 1:length(trialReliSteps)
            %{
            aStuff = tmapAvBpval(tmapAvBrhoReli >= trialReliSteps(trsI));
            avbMean(trsI) = mean(aStuff); avbSem(trsI) = standarderrorSL(aStuff);
            
            aStuff = tmapAvALLpval(tmapAvALLrhoReli >= trialReliSteps(trsI));
            bStuff = tmapBvALLpval(tmapBvALLrhoReli >= trialReliSteps(trsI));
            
            AvALLmean(trsI) = mean(aStuff); AvALLsem(trsI) = standarderrorSL(aStuff);
            BvALLmean(trsI) = mean(bStuff); BvALLsem(trsI) = standarderrorSL(bStuff);
            ABvALLmean(trsI) = mean([aStuff; bStuff]); ABALLsem(trsI) = standarderrorSL([aStuff; bStuff]);
            %}
            %figure; plot(trialReliSteps,avbMean)
            
            
            % Pct bins split same direction
            aStuff = ...
                halfSplitAsameLog{slI}{stI}(halfSplitAsameLogReli{slI}{stI} >= trialReliSteps(trsI));
            bStuff = ...
                halfSplitBsameLog{slI}{stI}(halfSplitBsameLogReli{slI}{stI} >= trialReliSteps(trsI));

            halfSplitSameMean{slI,stI}(trsI) = mean([aStuff; bStuff]);
            halfSplitSameStd{slI,stI}(trsI) = standarderrorSL([aStuff; bStuff]);
            
            aStuff = ...
                halfSplitAsameLog{slI}{stI}(halfSplitAsameLogReli{1}{1} >= trialReliSteps(trsI));
            bStuff = ...
                halfSplitBsameLog{slI}{stI}(halfSplitBsameLogReli{1}{1} >= trialReliSteps(trsI));
            cStuff = ...
                halfSplitAsameLog{slI}{stI}(halfSplitAsameLogReli{1}{2} >= trialReliSteps(trsI));
            dStuff = ...
                halfSplitBsameLog{slI}{stI}(halfSplitBsameLogReli{1}{2} >= trialReliSteps(trsI));
            
            hssMean(trsI) =  mean([aStuff; bStuff; cStuff; dStuff]);
            hssSEM(trsI) =  standarderrorSL([aStuff; bStuff; cStuff; dStuff]);
            hssStd(trsI) =  std([aStuff; bStuff; cStuff; dStuff]);
            
            
            % Pct bins split above 95% of shuffles
            aStuff = ...
                halfSplitAciLog{slI}{stI}(halfSplitAciLogReli{slI}{stI} >= trialReliSteps(trsI));
            bStuff = ...
                halfSplitBciLog{slI}{stI}(halfSplitBciLogReli{slI}{stI} >= trialReliSteps(trsI));

            halfSplitCImean{slI,stI}(trsI) = mean([aStuff; bStuff]);
            
            % Pct bins where originally significant here split above 95% of shuffles
            aStuff = ...
                halfSplitAciSigLog{slI}{stI}(halfSplitAciSigLogReli{slI}{stI} >= trialReliSteps(trsI));
            bStuff = ...
                halfSplitBciSigLog{slI}{stI}(halfSplitBciSigLogReli{slI}{stI} >= trialReliSteps(trsI));

            halfSplitCIsigMean{slI,stI}(trsI) = mean([aStuff; bStuff]);
            halfSplitCIsigStd{slI,stI}(trsI) = std([aStuff; bStuff]);
            
            % AvB rateDiffCorr p vals
            aStuff = rateDiffCorr.AvB.pLog{slI}{stI}(rateDiffCorr.AvB.rhoLogReli{slI}{stI} >= trialReliSteps(trsI));
            rateDiffCorrAvBpVals{slI,stI}(trsI) = mean(aStuff);
            
            % AvAll rateDiffCorr p vals
            aStuff = rateDiffCorr.AvAll.pLog{slI}{stI}(rateDiffCorr.AvAll.rhoLogReli{slI}{stI} >= trialReliSteps(trsI));
            rateDiffCorrAvALLpVals{slI,stI}(trsI) = mean(aStuff);
            
            % BvAll rateDiffCorr p vals
            aStuff = rateDiffCorr.BvAll.pLog{slI}{stI}(rateDiffCorr.BvAll.rhoLogReli{slI}{stI} >= trialReliSteps(trsI));
            rateDiffCorrBvALLpVals{slI,stI}(trsI) = mean(aStuff);
            %}
        end
    end
end

figure; 
errorbar(trialReliSteps,hssMean,hssSEM,'r')

figure; 
errorbar(trialReliSteps,halfSplitSameMean{1,1},halfSplitSameStd{1,1},'r')
hold on
errorbar(trialReliSteps,halfSplitSameMean{1,2},halfSplitSameStd{1,2},'b')
ylim([0.6 0.8])
xlabel('Reliability Threshold')
title('Mean pct bins Split same dir')
MakePlotPrettySL(gca);

figure; 
subplot(1,3,1)
    plot(trialReliSteps,halfSplitSameMean{1,1},'r')
    hold on
    plot(trialReliSteps,halfSplitSameMean{1,2},'b')
    xlabel('Max Trial-type reli')
    title('Mean pct bins Split same dir')
subplot(1,3,2)
    plot(trialReliSteps,halfSplitCImean{1,1},'r')
    hold on
    plot(trialReliSteps,halfSplitCImean{1,2},'b')
    title('Mean pct bins Split above shuffle')
subplot(1,3,3)
    plot(trialReliSteps,halfSplitCIsigMean{1,1},'r')
    hold on
    plot(trialReliSteps,halfSplitCIsigMean{1,2},'b')
    title('Mean pct bins Split above shuffle in sig splitter bins')
    suptitleSL('Reliability of half of trials to original')
  
    
figure; 
subplot(1,3,1)
    plot(trialReliSteps,rateDiffCorrAvBpVals{1,1},'r')
    hold on
    plot(trialReliSteps,rateDiffCorrAvBpVals{1,2},'b')
    xlabel('Max Trial-type reli')
    title('Half A vs. Half B')
subplot(1,3,2)
    plot(trialReliSteps,rateDiffCorrAvALLpVals{1,1},'r')
    hold on
    plot(trialReliSteps,rateDiffCorrAvALLpVals{1,2},'b')
    title('Half A vs. Original')
subplot(1,3,3)
    plot(trialReliSteps,rateDiffCorrBvALLpVals{1,1},'r')
    hold on
    plot(trialReliSteps,rateDiffCorrBvALLpVals{1,2},'b')
    title('Half B vs. Original')
suptitleSL('Rate difference correlations')
    
disp('done half trials consistency')
%% Splitter cells: logical each type
dayUseFilter = {dayUse; dayUseArm}; 
%dayUseFilter = {dayUsePooled; dayUseArmPooled};
% All cells ever
%    dayUseFilter = {cellfun(@(x) ones(size(x)),dayUse,'UniformOutput',false); cellfun(@(x) ones(size(x)),dayUseArm,'UniformOutput',false)};
% All cells that pass shuffle/fire at least once
%    dayUseFilter = {cellfun(@(x) sum(x,3)>0,trialReli,'UniformOutput',false); cellfun(@(x) sum(x,3)>0,trialReliArm,'UniformOutput',false)};   
% Cells that pass 0.25 with all trials
%    dayUseFilter = {cellfun(@(x) x>=lapPctThresh,trialReliAll,'UniformOutput',false); cellfun(@(x) x>=lapPctThresh,trialReliAllArms,'UniformOutput',false)}; 
% All cells present that day    
    %dayUseFilter = {cellfun(@(x) x>0,cellSSI,'UniformOutput',false); cellfun(@(x) x>0,cellSSI,'UniformOutput',false)};   %Should just include all cells that pass shuffle...
% thresh but not consec
    dayUseFilter = {cellfun(@(x) sum(x>=lapPctThresh,3)>0,trialReli,'UniformOutput',false); cellfun(@(x) sum(x>=lapPctThresh,3)>0,trialReliArm,'UniformOutput',false);...
                    cellfun(@(x) sum(x>=lapPctThresh,3)>0,trialReliDelay,'UniformOutput',false)}; 

splitterCells = [];
for mouseI = 1:numMice
    for slI = 1:length(splitterLoc)
        for stI = 1:length(splitterType)
            %Filter for active cells
            splitterCells{slI}{stI}{mouseI} = thisCellSplits{slI}{stI}{mouseI}.*dayUseFilter{slI}{mouseI};
            
            %Get different splitting types
            switch splitterType{stI}
                case 'LR'
                    splittersLR{slI}{mouseI} = splitterCells{slI}{stI}{mouseI};
                case 'ST'
                    splittersST{slI}{mouseI} = splitterCells{slI}{stI}{mouseI};
            end            
        end
        [splittersLRonly{slI}{mouseI}, splittersSTonly{slI}{mouseI}, splittersBoth{slI}{mouseI},...
            splittersOne{slI}{mouseI}, splittersAny{slI}{mouseI}, splittersNone{slI}{mouseI}] = ...
            GetSplittingTypes(splittersLR{slI}{mouseI}, splittersST{slI}{mouseI}, dayUseFilter{slI}{mouseI});
            
        %Package into trait logicals
        traitGroups{slI}{mouseI} = {logical(splittersLR{slI}{mouseI});... 
                                    logical(splittersST{slI}{mouseI});... 
                                    logical(splittersLRonly{slI}{mouseI});... 
                                    logical(splittersSTonly{slI}{mouseI}); ...
                                    logical(splittersBoth{slI}{mouseI}); ...
                                    logical(splittersOne{slI}{mouseI});... 
                                    logical(splittersAny{slI}{mouseI}); ...
                                    logical(splittersNone{slI}{mouseI})};
    end
end
numTraitGroups = length(traitGroups{1}{1});

purp = [0.4902    0.1804    0.5608]; % uisetcolor
orng = [0.8510    0.3294    0.1020];
colorAssc = {'r'            'b'        'm'         'c'              purp     orng    'g'      'k'  };
colorAssc = { [1 0 0]     [0 0 1]    [1 0 1]       [0 1 1]         purp     orng        [0 1 0]       [0 0 0]};
traitLabels = {'splitLR' 'splitST'  'splitLRonly' 'splitSTonly' 'splitBOTH' 'splitONE' 'splitEITHER' 'dontSplit'};

pairsCompare = {'splitLR' 'splitST';...
                'splitLRonly' 'splitSTonly';...
                'splitBOTH' 'splitONE';...
                'splitEITHER' 'dontSplit'};
pairsCompareInd = cell2mat(cellfun(@(x) find(strcmpi(traitLabels,x)),pairsCompare,'UniformOutput',false));
numPairsCompare = size(pairsCompare,1);

disp('Done splitter logicals')

for mouseI = 1:numMice
    nSplitters(mouseI) = sum(sum(logical(traitGroups{1}{mouseI}{7})));
    nHere(mouseI) = sum(sum(dayUseFilter{1}{mouseI}));
    
    %everSplitHere{mouseI} = sum( sum(logical(traitGroups{1}{mouseI}{7}),2)>0);
    
    uniqueObservations(mouseI) = sum(sum(cellSSI{mouseI}>0));
end

%% How many each type per day?
pooledSplitProp = [];
splitPropEachDay = [];
for slI = 1:2
    pooledSplitProp{slI} = cell(1,numTraitGroups);
    splitPropEachDay{slI} = [];
    for mouseI = 1:numMice
        splitPropEachDay{slI}{mouseI} = RunGroupFunction('TraitDailyPct',traitGroups{slI}{mouseI},dayUseFilter{slI}{mouseI});
        withinMouseSplitPropEachDayMeans{mouseI} = cellfun(@mean,splitPropEachDay{slI}{mouseI},'UniformOutput',false);
        withinMouseSplitPropEachDaySEMs{mouseI} = cellfun(@standarderrorSL,splitPropEachDay{slI}{mouseI},'UniformOutput',false);
        for tgI = 1:numTraitGroups
            pooledSplitProp{slI}{tgI} = [pooledSplitProp{slI}{tgI}; splitPropEachDay{slI}{mouseI}{tgI}(:)];
        end
    end
end 

% Changes in number of splitters over time
pooledSplitNumChange = []; splitterNumChange = []; %Change in percentage splitter type
pooledSplitPctChange = []; splitterPctChange = []; %Change in percentage over percentage of first day in pair
for slI = 1:2
    pooledSplitNumChange{slI} = cell(numTraitGroups,1);
    pooledSplitPctChange{slI} = cell(numTraitGroups,1);
    
    for mouseI = 1:numMice
        [splitterNumChange{slI}{mouseI}, splitterPctChange{slI}{mouseI}] =...
            cellfun(@(x) TraitChangeDayPairs(x,dayPairs{mouseI}),splitPropEachDay{slI}{mouseI},'UniformOutput',false);        
        for tgI = 1:numTraitGroups
            pooledSplitNumChange{slI}{tgI} = [pooledSplitNumChange{slI}{tgI}; splitterNumChange{slI}{mouseI}{tgI}];
            pooledSplitPctChange{slI}{tgI} = [pooledSplitPctChange{slI}{tgI}; splitterPctChange{slI}{mouseI}{tgI}];
        end
    end
end

disp('Done how many splitters')

%% Splitters by reliability steps
slI = 1;
trialReliSteps = 0:0.01:0.5;
%trialReliSteps = 0:1:12; % For number of laps active

propsRho = []; propsCorrPval = [];
splitNumMean = []; splitNumStd = [];
dayUseFilter = [];
for trsI = 1:length(trialReliSteps)
    
    splitterCells = [];
    for mouseI = 1:numMice
        %dayUseFilter{1}{mouseI} = sum(trialReli{mouseI} >= trialReliSteps(trsI),3)>0; % Original trial-type specific reliability
                	%sum(trialReliArm{mouseI} >= trialReliSteps(trsI),3)>0}; 
        dayUseFilter{1}{mouseI} = trialReliAll{mouseI} >= trialReliSteps(trsI); % Reliability across all trials
        %dayUseFilter{1}{mouseI} = (sum(lapsActive{mouseI},3) >= trialReliSteps(trsI))>0; % number of laps active
        
        numCellsHere{slI}(trsI,mouseI) = sum(sum(dayUseFilter{1}{mouseI}));
        pctCellsHere{slI}(trsI,mouseI) = mean(sum(dayUseFilter{1}{mouseI},1) ./ sum(cellSSI{mouseI}>0,1));
        for stI = 1:length(splitterType)
                %Filter for active cells
                splitterCells{slI}{stI}{mouseI} = thisCellSplits{slI}{stI}{mouseI}.*dayUseFilter{slI}{mouseI};

                %Get different splitting types
                switch splitterType{stI}
                    case 'LR'
                        splittersLR{slI}{mouseI} = splitterCells{slI}{stI}{mouseI};
                    case 'ST'
                        splittersST{slI}{mouseI} = splitterCells{slI}{stI}{mouseI};
                end            
            end
        [splittersLRonly{slI}{mouseI}, splittersSTonly{slI}{mouseI}, splittersBoth{slI}{mouseI},...
            splittersOne{slI}{mouseI}, splittersAny{slI}{mouseI}, splittersNone{slI}{mouseI}] = ...
            GetSplittingTypes(splittersLR{slI}{mouseI}, splittersST{slI}{mouseI}, dayUseFilter{slI}{mouseI});
            
        %Package into trait logicals
        traitGroups{slI}{mouseI} = {logical(splittersLR{slI}{mouseI});... 
                                    logical(splittersST{slI}{mouseI});... 
                                    logical(splittersLRonly{slI}{mouseI});... 
                                    logical(splittersSTonly{slI}{mouseI}); ...
                                    logical(splittersBoth{slI}{mouseI}); ...
                                    logical(splittersOne{slI}{mouseI});... 
                                    logical(splittersAny{slI}{mouseI}); ...
                                    logical(splittersNone{slI}{mouseI})};
                                
        splitPropEachDay{slI}{mouseI} = RunGroupFunction('TraitDailyPct',traitGroups{slI}{mouseI},dayUseFilter{slI}{mouseI});
        splitNumsEachDay{slI}{mouseI} = RunGroupFunction('TraitNums',traitGroups{slI}{mouseI},[]);
        
        
    end
    
    thingsNow = [3     4     5     8];
    for ii = 1:4
        pooledHere = [];
            daysHere = [];
        for mouseI = 1:numMice
             dayss = cellRealDays{mouseI} - (cellRealDays{mouseI}(1)-1);
             splitPropHere = splitPropEachDay{slI}{mouseI}{thingsNow(ii)};
             pooledHere = [pooledHere; splitPropHere(:)];
             daysHere = [daysHere; dayss];   
        end

        [propsRho(trsI,ii),propsCorrPval(trsI,ii)] = corr(daysHere,pooledHere,'type','Spearman');

        snH = [];
        for mouseI = 1:numMice
            snH = [snH; splitNumsEachDay{slI}{mouseI}{thingsNow(ii)}(:)];
        end
        splitNumMean(trsI,ii) = mean(snH);
        splitNumStd(trsI,ii) = std(snH);

    end
end
  
figure;
for ii = 1:4
    subplot(2,2,ii)
    rhoHere = propsRho(:,ii);
    pHere = propsCorrPval(:,ii);
    
    %{
    pGood = pHere<=0.05;
    pBad = pHere > 0.05;
    yyaxis left
    plot(trialReliSteps(pBad),rhoHere(pBad),'.','MarkerSize',6)
    hold on
    plot(trialReliSteps(pGood),rhoHere(pGood),'*')
    ylabel('rho value')
    
    yyaxis right
    plot([trialReliSteps([1 end])],[0.05 0.05],'r--')
    hold on
    plot([trialReliSteps([1 end])],[0.1 0.1],'k--')
    
    plot(trialReliSteps(pBad),pHere(pBad),'.','MarkerSize',6)
    hold on
    plot(trialReliSteps(pGood),pHere(pGood),'*')
    ylabel('p value')
    %}
    
    pGood = pHere<=0.05;
    pMed = (pHere > 0.05) & (pHere<=0.1);
    pBad = pHere > 0.1;
    plot(trialReliSteps(pBad),rhoHere(pBad),'.','MarkerSize',6)
    hold on
    plot(trialReliSteps(pMed),rhoHere(pMed),'+')
    plot(trialReliSteps(pGood),rhoHere(pGood),'*')
    ylabel('rho value')
    
    xlabel('Reliability threshold')
    
    title(traitLabels{thingsNow(ii)})
    
    MakePlotPrettySL(gca);
    %xlim([0 0.3])
end
suptitleSL('Correlations of daily splitter proportions by reliability threshold: number laps active')

figure;
nCellsHere = sum(numCellsHere{1},2);
plot(trialReliSteps,nCellsHere)
ylim([0 15000])
 xlabel('Reliability threshold')
title('Total number cells*days included') 
MakePlotPrettySL(gca)
 
figure;
nCellsHere = mean(pctCellsHere{1},2);
plot(trialReliSteps,nCellsHere)
ylim([0 0.5])
 xlabel('Reliability threshold')
title('Mean prop cells per day')
MakePlotPrettySL(gca)

%{
figure;
for ii = 1:4
    subplot(2,2,ii)
    
    plot([min(trialReliSteps) max(trialReliSteps)],[0 0],'k--')
    hold on
    errorbar(trialReliSteps,splitNumMean(:,ii),splitNumStd(:,ii))
end
        %}

%% Lap duration dist. analysis
% Get lap lengths, binary whether or not a cell fired
% thisCellSplits{slI}{stI}{mouseI} just says did this cell have a bin above shuffle in 

% For each cell, get the lengths of the laps it fired on
lapLengths = [];
cff = [];
cellFired = [];
for mouseI = 1:numMice
    
    for condI = 1:4
        lapLengths{mouseI}{condI} = cell2mat(cellfun(@length,cellTBT{mouseI}(condI).trialsX,'UniformOutput',false));
        cff{mouseI}{condI} = cellfun(@(x) sum(x,2)>0,cellTBT{mouseI}(condI).trialPSAbool,'UniformOutput',false);
        
        cellFired{mouseI}{condI} = cell2mat(cff{mouseI}{condI}')'; % Reorganized: (lapI,cellI)
    end
    lapLengthsZ{mouseI} = cell(1,4); % lap lengths Z scored within a day and across conditions
    
    for dayI = 1:numDays(mouseI)
        lengthsA = [];
        cmA = [];
        for condI = 1:4
            dayTrialsH = cellTBT{mouseI}(condI).sessID==dayI;
            lengthsHere = lapLengths{mouseI}{condI}(dayTrialsH);
            cMarker = condI*ones(size(lengthsHere));
            lengthsA = [lengthsA; lengthsHere];
            cmA = [cmA; cMarker];
            
            lapLengthsDayMean{mouseI}(dayI,condI) = mean(lengthsHere);
        end
        lengthsAz = zscore(lengthsA);
        for condI = 1:4
            lapLengthsZ{mouseI}{condI} = [lapLengthsZ{mouseI}{condI}; lengthsAz(cmA==condI)];
            lapLengthsDayMeanZ{mouseI}(dayI,condI) = mean(lapLengthsZ{mouseI}{condI});
        end
    end
end

% Get the z-scored lengths of laps when a cell fired
cellFiredLapLengths = [];
cellFiredLapLengthsMean = [];
cellFiredLapLengthsZ = [];
cellFiredLapLengthsZmean = [];

xcellFiredLapLengths = [];
xcellFiredLapLengthsMean = [];
xcellFiredLapLengthsZ = [];
xcellFiredLapLengthsZmean = [];
for mouseI = 1:numMice
    for dayI = 1:numDays(mouseI)
        for condI = 1:4
            dayTrialsH = cellTBT{mouseI}(condI).sessID==dayI;
            lapsH{condI,1} = lapLengthsZ{mouseI}{condI}(dayTrialsH);
            
            for cellI = 1:numCells(mouseI)
                % Lengths of laps where this cell fired
                cellFiredH = cellFired{mouseI}{condI}(:,cellI);
                
                cellFiredLapLengths{mouseI}{dayI}{cellI}{condI} = lapLengths{mouseI}{condI}(dayTrialsH(:) & cellFiredH(:));
                cellFiredLapLengthsMean{mouseI}{dayI}{cellI}{condI} = mean( cellFiredLapLengths{mouseI}{dayI}{cellI}{condI} );
                cellFiredLapLengthsZ{mouseI}{dayI}{cellI}{condI} = lapLengthsZ{mouseI}{condI}(dayTrialsH(:) & cellFiredH(:));
                cellFiredLapLengthsZmean{mouseI}{dayI}{cellI}{condI} = mean( cellFiredLapLengthsZ{mouseI}{dayI}{cellI}{condI} );
                
                % Lenghts of laps where this cell DID NOT fire
                xcellFiredH = ~cellFired{mouseI}{condI}(:,cellI);
                
                xcellFiredLapLengths{mouseI}{dayI}{cellI}{condI} = lapLengths{mouseI}{condI}(dayTrialsH(:) & xcellFiredH(:));
                xcellFiredLapLengthsMean{mouseI}{dayI}{cellI}{condI} = mean( xcellFiredLapLengths{mouseI}{dayI}{cellI}{condI} );
                xcellFiredLapLengthsZ{mouseI}{dayI}{cellI}{condI} = lapLengthsZ{mouseI}{condI}(dayTrialsH(:) & xcellFiredH(:));
                xcellFiredLapLengthsZmean{mouseI}{dayI}{cellI}{condI} = mean( xcellFiredLapLengthsZ{mouseI}{dayI}{cellI}{condI} );
            end
        end
    end
end

% Compare lap lengths fired to cell's reliability 
% Likelihood of surviving shuffle given lengths of laps active / diff
% across conditions in laps active
slI = 1;
for stI = 1:length(splitterType)
    
    for mouseI = 1:numMice
        lapLengthsDiff{stI}{mouseI} = nan(size(cellSSI{mouseI}));
        lapLengthsDiffZ{stI}{mouseI} = nan(size(cellSSI{mouseI}));
        xlapLengthsDiff{stI}{mouseI} = nan(size(cellSSI{mouseI}));
        xlapLengthsDiffZ{stI}{mouseI} = nan(size(cellSSI{mouseI}));
        % If a cell was active this day does it survive a shuffle yes or no, what is the mean zscore of lap lengths active 
        for dayI = 1:numDays(mouseI)
            for cellI = 1:numCells(mouseI)
                if sum(trialReli{mouseI}(cellI,dayI,:),3) > 0                    
                    switch splitterType{stI}
                        case 'LR'
                            condsA = Conds.Left;
                            condsB = Conds.Right;
                        case 'ST'
                            condsA = Conds.Study;
                            condsB = Conds.Test;
                    end
                    % meanRateDiff{1}{1} will be negative where splits left, positive where splits right
                    % meanRateDiff{1}{2} will be negative where splits study, positive where splits test
                    if meanRateDiff{slI}{stI}{mouseI}(cellI,dayI) < 0
                        condsC = condsB;
                        condsB = condsA;
                        condsA = condsC;
                    end
                    % This makes it so the sign will be positive if the lap
                    % lengths from the conditions it splits towards are longer than those from the other conditions

                    meanLengthsH = cell2mat(cellFiredLapLengthsMean{mouseI}{dayI}{cellI});
                    %meanLengthsH(isnan(meanLengthsH)) = 0;
                    ZmeanLengthsH = cell2mat(cellFiredLapLengthsZmean{mouseI}{dayI}{cellI});
                    %ZmeanLengthsH(isnan(ZmeanLengthsH)) = 0;
                    
                    % lapLengthsDiff will be positive if B has longer trials than A
                    mlHa = nanmean(meanLengthsH(condsA)); 
                        if isnan(mlHa); mlHa = 0; end
                    mlHb = nanmean(meanLengthsH(condsB));
                        if isnan(mlHb); mlHb = 0; end
                    lapLengthsDiff{stI}{mouseI}(cellI,dayI) = mlHb - mlHa;

                    zmlHa = nanmean(ZmeanLengthsH(condsA)); 
                        if isnan(zmlHa); zmlHa = 0; end
                    zmlHb = nanmean(ZmeanLengthsH(condsB));
                        if isnan(zmlHb); zmlHb = 0; end
                    lapLengthsDiffZ{stI}{mouseI}(cellI,dayI) = zmlHb - zmlHa;
                    
                    % Same but trials it didn't fire on:
                    % Will be positive if lengths of laps it didn't fire on
                    % are longer in condition it splits towards than in those it didn't
                    % and negative if laps it didn't fire on are longer in
                    % the condition it didn't fire on and than in condition it did
                    
                    xmeanLengthsH = cell2mat(xcellFiredLapLengthsMean{mouseI}{dayI}{cellI});
                    %meanLengthsH(isnan(meanLengthsH)) = 0;
                    xZmeanLengthsH = cell2mat(xcellFiredLapLengthsZmean{mouseI}{dayI}{cellI});
                    
                    mlHa = nanmean(xmeanLengthsH(condsA)); 
                        if isnan(mlHa); mlHa = 0; end
                    mlHb = nanmean(xmeanLengthsH(condsB));
                        if isnan(mlHb); mlHb = 0; end
                    xlapLengthsDiff{stI}{mouseI}(cellI,dayI) = mlHb - mlHa;

                    zmlHa = nanmean(xZmeanLengthsH(condsA)); 
                        if isnan(zmlHa); zmlHa = 0; end
                    zmlHb = nanmean(xZmeanLengthsH(condsB));
                        if isnan(zmlHb); zmlHb = 0; end
                    xlapLengthsDiffZ{stI}{mouseI}(cellI,dayI) = zmlHb - zmlHa;
                end
            end
        end
        % rateDiff{slI}{stI}{mouseI}
        %lapLengthsDiff{stI}{mouseI} = lapLengthsDiff{stI}{mouseI} * -1*(meanRateDiff{slI}{stI}{mouseI}>0);
    end
end

% Ok Here actually sort out survival by lap length differences, compare that to thresholding
trialReliSteps = 0:0.01:0.5;
for trsI = 1:length(trialReliSteps)
    
    for mouseI = 1:numMice
        cellHere = sum(trialReli{mouseI}> trialReliSteps(trsI),3)>0 ;
        numHere = sum(cellHere,1);    

        for stI = 1:length(splitterType)
            % Cells that are here and split vs. dont
            hereAndSplit = (thisCellSplits{1}{stI}{mouseI} & cellHere);
            hereAndNosplit = (thisCellSplits{1}{stI}{mouseI} & ~cellHere);

            xMeanLengthDiffsSplit = xlapLengthsDiff{stI}{mouseI};
            xMeanLengthDiffsSplit(hereAndNosplit | ~cellHere) = NaN;
            xMeanLengthDiffsNosplit = xlapLengthsDiff{stI}{mouseI};
            xMeanLengthDiffsNosplit(hereAndSplit | ~cellHere) = NaN;

            xMeanLengthDiffsSplitZ = xlapLengthsDiffZ{stI}{mouseI};
            xMeanLengthDiffsSplitZ(hereAndNosplit | ~cellHere) = NaN;
            xMeanLengthDiffsNosplitZ = xlapLengthsDiffZ{stI}{mouseI};
            xMeanLengthDiffsNosplitZ(hereAndSplit | ~cellHere) = NaN;

            % <0 is where laps from non-firing conition are longer than firing condition
            numXmeanLengthDiffsSplit = sum(xMeanLengthDiffsSplit<0,1);
            numXmeanLengthDiffsNosplit = sum(xMeanLengthDiffsNosplit<0,1);

            numXmeanLengthDiffsSplitZ = sum(xMeanLengthDiffsSplitZ<0,1);
            numXmeanLengthDiffsNosplitZ = sum(xMeanLengthDiffsNosplitZ<0,1);

            pctSplitWithLongerOffCondNoFiringLaps = numXmeanLengthDiffsSplit ./ numHere;
            pctSplitWithLongerOffCondNoFiringLapsZ = numXmeanLengthDiffsSplitZ ./ numHere;

            % Aggregate across mice
            pctLongerOffCondNoFiring{stI}{mouseI}(trsI,:) = pctSplitWithLongerOffCondNoFiringLaps;
            pctLongerOffCondNoFiringZ{stI}{mouseI}(trsI,:) = pctSplitWithLongerOffCondNoFiringLapsZ;
        end
    end

end
  
figure;
for stI = 1:2
    subplot(1,2,stI)
    
    for trsI = 1:length(trialReliSteps)
        hhHere = [];
        for mouseI = 1:numMice
            hhHere = [hhHere,pctLongerOffCondNoFiring{stI}{mouseI}(trsI,:)];
        end
        mMean(trsI) = mean(hhHere);
        mStd(trsI) = std(hhHere);
    end
    
    errorbar(mMean,mStd)
end        
    %{


for mouseI = 1:numMice
    maxTrialReli{mouseI} = max(trialReli{mouseI},[],3);
    firedThisCond{mouseI} = trialReli{mouseI}>0;
end

% Cells below threshold that survive vs dont (expect survivors to have low lap lengths), 
% Expect cells that survive threshold vs dont to fire in conditions with lower lap lengths than other conditions 
for stI = 1:length(splitterType)
    switch splitterType{stI}
        case 'LR'
            condsA = Conds.Left;
            condsB = Conds.Right;
        case 'ST'
            condsA = Conds.Study;
            condsB = Conds.Test;
    end
    
    for mouseI = 1:numMice
        for cellI = 1:numCells(mouseI)
            if sum(trialReli{mouseI}(cellI,dayI,:),3) > 0
                % Lap lengths for trials active
                trialReli{mouseI}(cellI,dayI,condsA)
                
            end
            
    
    
    
    
end
%}

%% Cells coming back across days
splitCBgroupOut = []; splitSSgroupOut = [];
for slI = 1:2
    pooledSplitterComesBack{slI} = cell(numTraitGroups,1);
    pooledSplitterStillSplitter{slI} = cell(numTraitGroups,1);
    pooledSplitterStillSplitterNorm{slI} = cell(numTraitGroups,1);
    
    for mouseI = 1:numMice
        [splitCBgroupOut{slI}{mouseI}] = RunGroupFunction(...
            'GetCellsOverlap',traitGroups{slI}{mouseI},dayUseFilter{slI}{mouseI},dayPairs{mouseI});
        
        [splitSSgroupOut{slI}{mouseI}] = RunGroupFunction(...
            'GetCellsOverlap',traitGroups{slI}{mouseI},traitGroups{slI}{mouseI},dayPairs{mouseI});
        
        for tgI = 1:numTraitGroups
            %cellsActiveHere = sum(dayUseFilter{slI}{mouseI},1);
            splitSSgroupOut{slI}{mouseI}(tgI).overlapWithModelActiveNormalized = ...
                (splitSSgroupOut{slI}{mouseI}(tgI).overlapWithModel ./ splitCBgroupOut{slI}{mouseI}(tgI).overlapWithModel);%...
                %.*splitCBgroupOut{slI}{mouseI}(tgI).overlapWithModel;
        end
        
        for tgI = 1:numTraitGroups
            pooledSplitterComesBack{slI}{tgI} =  [pooledSplitterComesBack{slI}{tgI}; splitCBgroupOut{slI}{mouseI}(tgI).overlapWithModel];
            pooledSplitterStillSplitter{slI}{tgI} =  [pooledSplitterStillSplitter{slI}{tgI}; splitSSgroupOut{slI}{mouseI}(tgI).overlapWithModel];
            pooledSplitterStillSplitterNorm{slI}{tgI} =  [pooledSplitterStillSplitterNorm{slI}{tgI}; splitSSgroupOut{slI}{mouseI}(tgI).overlapWithModelActiveNormalized];
        end
    end
end

disp('Done splitter reactivation/persistence')

%% Cell Turning into other types
transInds = [3 4; 4 3; 3 5; 4 5; 5 3; 5 4]; 

%transLabels = traitLabels(transInds);
cellTransTraits = [];
splitterChanges = [];
pooledSplitterChanges = [];
for slI = 1:2
    pooledSplitterChanges{slI} = cell(size(transInds,1),1);
    for mouseI = 1:numMice
        cellTransTraits{slI}{mouseI} = traitGroups{slI}{mouseI}(transInds);
        
        [splitterChanges{slI}{mouseI}] = RunGroupFunction('GetCellsOverlap',cellTransTraits{slI}{mouseI}(:,1),cellTransTraits{slI}{mouseI}(:,2),dayPairs{mouseI});
        
        
        for tiI = 1:size(transInds,1)
            pooledSplitterChanges{slI}{tiI} = [pooledSplitterChanges{slI}{tiI}; splitterChanges{slI}{mouseI}(tiI).overlapWithModel];
            
            transLabels{tiI} = [traitLabels{transInds(tiI,1)} '-to-' traitLabels{transInds(tiI,2)}];
        end
    end   
end

disp('Done splitter transitions')
%% When are splitters showing up
%How many days a splitter
for slI = 1:2
    for mouseI = 1:numMice
        numDaysSplitter{slI}{mouseI} = cellfun(@(x) sum(x,2),traitGroups{slI}{mouseI},'UniformOutput',false);
        
        pooledNumDaysSplitter{slI} = cell(numTraitGroups,1);
        for tgI = 1:numTraitGroups
            pooledNumDaysSplitter{slI}{tgI} = [pooledNumDaysSplitter{slI}{tgI}; numDaysSplitter{slI}{mouseI}{tgI}];
        end
    end
end

%Day trait center of mass
logicalCOMgroupout = []; 
pooledSplitDayCOM = [];
pooledCOMBiases = [];
for slI = 1:2
    pooledSplitDayCOM{slI} = cell(numTraitGroups,1);
    pooledCOMBiases{slI} = cell(numTraitGroups,1);
    for mouseI = 1:numMice
        [logicalCOMgroupout{slI}{mouseI}] = RunGroupFunction('LogicalTraitCenterofMass',traitGroups{slI}{mouseI},dayUseFilter{slI}{mouseI});%ones(size(dayUse{mouseI}))
        
        for tgI = 1:numTraitGroups
            pooledSplitDayCOM{slI}{tgI} = [pooledSplitDayCOM{slI}{tgI}; logicalCOMgroupout{slI}{mouseI}(tgI).dayCOM];
            
            pooledCOMBiases{slI}{tgI} = [pooledCOMBiases{slI}{tgI};...
                                         logicalCOMgroupout{slI}{mouseI}(tgI).dayBias.Pct.Early...
                                         logicalCOMgroupout{slI}{mouseI}(tgI).dayBias.Pct.NoBias+logicalCOMgroupout{slI}{mouseI}(tgI).dayBias.Pct.SplitAllDays...
                                         logicalCOMgroupout{slI}{mouseI}(tgI).dayBias.Pct.Late];
        end        
    end
end

%What are new cells? 
%but also what were previously inactive cells
pooledNewCellProps = [];
pooledNewCellPropChanges = [];
pooledNewlyActiveCellProps = [];
pooledNewlyActiveCellPropChanges = [];
firstDayGroupout = []; firstDays = [];
inactiveTraitPcts = [];
for slI = 1:2
    pooledNewCellProps{slI} = cell(numTraitGroups,1);
    pooledNewCellPropChanges{slI} = cell(numTraitGroups,1);
    pooledNewlyActiveCellProps{slI} = cell(numTraitGroups,1);
    pooledNewlyActiveCellPropChanges{slI} = cell(numTraitGroups,1);
    pooledNewlyActiveAndNewCellProps{slI} = cell(numTraitGroups,1);
    pooledNewlyActiveAndNewCellPropsChanges{slI} = cell(numTraitGroups,1);
    for mouseI = 1:numMice
        %firstDays{slI}{mouseI} = GetFirstDayTrait(dayUseFilter{slI}{mouseI}); %This is first day active
        firstDays{slI}{mouseI} = GetFirstDayTrait(cellSSI{mouseI}>0);
        %[firstDayGroupout{slI}{mouseI}] = RunGroupFunction('GetFirstDayTrait',traitGroups{slI}{mouseI},[]);
        
        firstDayLogical{slI}{mouseI} = false(size(cellSSI{mouseI}));
        for cellI = 1:size(cellSSI{mouseI},1)
            if ~isnan(firstDays{slI}{mouseI}(cellI))
            firstDayLogical{slI}{mouseI}(cellI,firstDays{slI}{mouseI}(cellI)) = true;  %NEED to eliminate day 1 after performing this
            end
        end
        %New Cells
        firstDayLogicalUse{slI}{mouseI} = firstDayLogical{slI}{mouseI};
        firstDayLogicalUse{slI}{mouseI}(:,1) = []; 
        firstDayNums{slI}{mouseI} = sum(firstDayLogicalUse{slI}{mouseI},1);
        
        %Previously inactive cells
        previouslyInactiveLogicalUse{slI}{mouseI} = presentInactive{slI}{mouseI};
        previouslyInactiveLogicalUse{slI}{mouseI}(:,end) = []; 
        previouslyInactiveNums{slI}{mouseI} = sum(previouslyInactiveLogicalUse{slI}{mouseI},1);
        
        
        firstDayNowActive{slI}{mouseI} = firstDayLogical{slI}{mouseI} .* dayUseFilter{slI}{mouseI};
        firstDayNowActiveNums{slI}{mouseI} = sum(firstDayNowActive{slI}{mouseI},1);
        firstDayNowActiveNums{slI}{mouseI}(1) = [];
        
        prevInactiveNowActive{slI}{mouseI} = presentInactive{slI}{mouseI}(:,1:end-1) .* dayUseFilter{slI}{mouseI}(:,2:end);
        prevInactiveNowActiveNums{slI}{mouseI} = sum(prevInactiveNowActive{slI}{mouseI},1);
        
        prevInactiveNowActive2{slI}{mouseI} = (dayUseFilter{slI}{mouseI}(:,1:end-1)==0) .* dayUseFilter{slI}{mouseI}(:,2:end);
        prevInactiveNowActiveNums2{slI}{mouseI} = sum(prevInactiveNowActive2{slI}{mouseI},1);
        
        for tgI = 1:numTraitGroups
            %New Cells
            traitFirst{slI}{mouseI}{tgI} = traitGroups{slI}{mouseI}{tgI}(:,2:end).*firstDayLogicalUse{slI}{mouseI};
            traitFirstNums{slI}{mouseI}{tgI} = sum(traitFirst{slI}{mouseI}{tgI},1);

            %traitFirstPcts{slI}{mouseI}{tgI} = traitFirstNums{slI}{mouseI}{tgI} ./ firstDayNums{slI}{mouseI};
            traitFirstPcts{slI}{mouseI}{tgI} = traitFirstNums{slI}{mouseI}{tgI} ./ firstDayNowActiveNums{slI}{mouseI};
            [newCellChanges{slI}{mouseI}{tgI},~] = TraitChangeDayPairs(traitFirstPcts{slI}{mouseI}{tgI},combnk(1:length(cellRealDays{mouseI})-1,2));%

            pooledNewCellProps{slI}{tgI} = [pooledNewCellProps{slI}{tgI}; traitFirstPcts{slI}{mouseI}{tgI}(:)];
            pooledNewCellPropChanges{slI}{tgI} = [pooledNewCellPropChanges{slI}{tgI}; newCellChanges{slI}{mouseI}{tgI}(:)];
            
            %Previously inactive cells
            inactiveTrait{slI}{mouseI}{tgI} = traitGroups{slI}{mouseI}{tgI}(:,2:end).*prevInactiveNowActive2{slI}{mouseI};
            inactiveTraitNums{slI}{mouseI}{tgI} = sum(inactiveTrait{slI}{mouseI}{tgI},1); %Was inactive, now coding

            %inactiveTraitPcts{slI}{mouseI}{tgI} = inactiveTraitNums{slI}{mouseI}{tgI} ./ previouslyInactiveNums{slI}{mouseI}; %out of total prev. inactive
            inactiveTraitPcts{slI}{mouseI}{tgI} = inactiveTraitNums{slI}{mouseI}{tgI} ./ prevInactiveNowActiveNums2{slI}{mouseI};
            [inactiveTraitChanges{slI}{mouseI}{tgI},~] = TraitChangeDayPairs(inactiveTraitPcts{slI}{mouseI}{tgI},combnk(1:length(cellRealDays{mouseI})-1,2));%

            pooledNewlyActiveCellProps{slI}{tgI} = [pooledNewlyActiveCellProps{slI}{tgI}; inactiveTraitPcts{slI}{mouseI}{tgI}(:)];
            pooledNewlyActiveCellPropChanges{slI}{tgI} = [pooledNewlyActiveCellPropChanges{slI}{tgI}; inactiveTraitChanges{slI}{mouseI}{tgI}(:)];
            
            %Pooled newly active and new
            inactiveAndNewNums{slI}{mouseI}{tgI} = mean([inactiveTraitNums{slI}{mouseI}{tgI}; traitFirstNums{slI}{mouseI}{tgI}],1);
            inactiveAndNewPcts{slI}{mouseI}{tgI} = inactiveAndNewNums{slI}{mouseI}{tgI} ./ mean([prevInactiveNowActiveNums{slI}{mouseI}; firstDayNowActiveNums{slI}{mouseI}],1);
            %inactiveAndNewNums{slI}{mouseI}{tgI} = inactiveTraitNums{slI}{mouseI}{tgI} + traitFirstNums{slI}{mouseI}{tgI};
            %inactiveAndNewPcts{slI}{mouseI}{tgI} = inactiveAndNewNums{slI}{mouseI}{tgI} ./ (prevInactiveNowActiveNums{slI}{mouseI} + firstDayNowActiveNums{slI}{mouseI});
            [inactiveAndNewChanges{slI}{mouseI}{tgI},~] = TraitChangeDayPairs(inactiveAndNewPcts{slI}{mouseI}{tgI},combnk(1:length(cellRealDays{mouseI})-1,2));
            
            pooledNewlyActiveAndNewCellProps{slI}{tgI} = [pooledNewlyActiveAndNewCellProps{slI}{tgI}; inactiveAndNewPcts{slI}{mouseI}{tgI}(:)];
            pooledNewlyActiveAndNewCellPropsChanges{slI}{tgI} = [pooledNewlyActiveAndNewCellPropsChanges{slI}{tgI}; inactiveAndNewChanges{slI}{mouseI}{tgI}(:)];
        end
    end
end
disp('Done what are new cells')

%% Splitter sources and sinks
cellCheck = [3 4 5];

%transCheck = [3 3; 3 4; 3 5; 4 4; 4 3; 4 5; 5 5; 5 3; 5 4];
%transCheck = [3 5; 4 5; 5 3; 5 4]; %sources: [starts as, becomes]
%transCheck = [1 3; 2 3; 3 1; 3 2]; %in cellCheck indices
%transLabels = {'LR to BOTH','ST to BOTH', 'BOTH to LR', 'BOTH to ST'};
%transCheck = [1 2; 1 3; 1 4; 2 2; 2 3; 2 4; 3 2; 3 3; 3 4];
%transLabels = {'LR to LR','LR to ST','LR to BOTH','ST to LR','ST to ST','ST to BOTH','BOTH to LR','BOTH to ST','BOTH to BOTH'};

transCheck = [1 3;          1 4;          2 2;     2 4;               3 2;        3 3];
transLabels = {'LR to ST','LR to BOTH','ST to LR','ST to BOTH','BOTH to LR','BOTH to ST'};

%What are new cells? (Move to setup)
firstDayLogical = [];
firstDayPresent = [];
for slI = 1:2
    for mouseI = 1:numMice
        firstDays{slI}{mouseI} = GetFirstDayTrait(dayUseFilter{slI}{mouseI});
        
        firstDayPresent{mouseI} = GetFirstDayTrait(cellSSI{mouseI}>0);
        
        firstDayLogical{slI}{mouseI} = false(size(cellSSI{mouseI}));
        firstDayPresentLogical{mouseI} = false(size(cellSSI{mouseI}));
        for cellI = 1:size(cellSSI{mouseI},1)
            if ~isnan(firstDays{slI}{mouseI}(cellI))
            firstDayLogical{slI}{mouseI}(cellI,firstDays{slI}{mouseI}(cellI)) = true;
            end
            firstDayPresentLogical{mouseI}(cellI,firstDayPresent{mouseI}(cellI)) = true;
        end
        
    end
end

pooledSourceChanges = []; 
pooledDailySources = [];
pooledSinkChanges = [];
pooledDailySinks = [];
sourceDayDiffsPooled = [];
sinkDayDiffsPooled = [];
newCellProps = [];
newCellPropChanges = [];
cellTransProps = [];
cellTransPropChanges = [];

%To look at all, sinks has to be traitGroups{7} (any split), sources are
%any split, non split, and new cells

sourceColors = [ colorAssc{1}; colorAssc{2}; colorAssc{5}; 0.6 0.6 0.6; 0 1 0];% ; ;0.8196    0.4118    0.1216
sourceLabels = {traitLabels{[1 2 5 8]},'Inactive','New Cells'};
for slI = 1:2
    for mouseI = 1:numMice
        firstDaySource{slI}{mouseI} = [firstDayLogical{slI}{mouseI}(:,2:end) zeros(size(cellSSI{mouseI},1),1)];
            %new cell that day, shifted to get matched as dayI-1
        
        targets{mouseI} = traitGroups{slI}{mouseI}(cellCheck);
        %sources{mouseI} = [firstDaySource{slI}{mouseI}; traitGroups{slI}{mouseI}([cellCheck 8])]; %dayUseFilter{slI}{mouseI}==0; 
        pI = presentInactive{slI}{mouseI}; 
        pIorNew = pI + [firstDayPresentLogical{mouseI}(:,2:end) zeros(size(cellSSI{mouseI},1),1)] > 0;
        switch slI; case 1; inactiveAtAll = dayUse{mouseI}==0; case 2; inactiveAtAll = dayUseArm{mouseI}==0; end
        %pIorNew = pI + firstDayPresentLogical{mouseI} > 0;
        %sources{mouseI} = [traitGroups{slI}{mouseI}([cellCheck 8]); pI];
        sources{mouseI} = [traitGroups{slI}{mouseI}([cellCheck 8]); inactiveAtAll];
        sinks{mouseI} = sources{mouseI}; 
    end
    
    [pooledSourceChanges{slI}, pooledDailySources{slI}, pooledSinkChanges{slI}, pooledDailySinks{slI}, sourceDayDiffsPooled{slI}, sinkDayDiffsPooled{slI}] =...
        CheckLogicalSinksAndSources(targets,sources,sinks,cellRealDays);
    
    [pooledDailySources2{slI}, pooledDailySinks2{slI}, sourceDayDiffsPooled2{slI}, sinkDayDiffsPooled2{slI}] =...
        CheckLogicalSinksAndSources2(targets,sources,sinks,cellPresent,[]);

    for tcI = 1:length(cellCheck) %target
        for scI = 1:length(sources{1}) %source
            dailySourcesMean{slI}(tcI,scI) = nanmean(pooledDailySources{slI}{tcI}{scI});
        end
    end
    
    
    %Reorganize new cell (previously inactive) destinations (what pct of ccI was previously inactive)
    for ccI = 1:length(cellCheck)
        newCellProps{slI}{ccI} = pooledDailySources{slI}{ccI}{1};
        newCellPropChanges{slI}{ccI} = pooledSourceChanges{slI}{ccI}{1};
    end
    
    %Reorganize cell type transitions
    for tcI = 1:size(transCheck,1)
        cellTransProps{slI}{tcI} = pooledDailySources{slI}{transCheck(tcI,1)}{transCheck(tcI,2)+1}; %+1 bc first is dayUse==0 
        cellTransPropChanges{slI}{tcI} = pooledSourceChanges{slI}{transCheck(tcI,1)}{transCheck(tcI,2)+1};
    end    
end

disp('Done cell sources and sinks')


%% To look at all, sinks has to be traitGroups{7} (any split), sources are
anyCheck = [7];
%any split, non split, and new cells
%{
anyCheck = 7;

sourceColorsA = [0 1 0; colorAssc{5}; 0.6 0.6 0.6];
sourceLabelsA = {'New cells','Splitter','Non-splitter'};
for slI = 1:2
    for mouseI = 1:numMice
        firstDaySourceA{slI}{mouseI} = [firstDayLogical{slI}{mouseI}(:,2:end) zeros(size(cellSSI{mouseI},1),1)];
            %new cell that day, shifted to get matched as dayI-1
        targetsA{mouseI} = traitGroups{slI}{mouseI}(7);
        sourcesA{mouseI} = [firstDaySourceA{slI}{mouseI}; traitGroups{slI}{mouseI}([7 8])]; %dayUseFilter{slI}{mouseI}==0; 
        sinksA{mouseI} = sourcesA{mouseI};
    end
    
    [pooledSourceChangesA{slI}, pooledDailySourcesA{slI}, pooledSinkChangesA{slI}, pooledDailySinksA{slI}, sourceDayDiffsPooledA{slI}, sinkDayDiffsPooledA{slI}] =...
        CheckLogicalSinksAndSources(targetsA,sourcesA,sinksA,cellRealDays);
    
    for tcI = 1:length(anyCheck) %target
        for scI = 1:length(sourcesA{1}) %source
            dailySourcesMeanA{slI}(tcI,scI) = nanmean(pooledDailySourcesA{slI}{tcI}{scI});
        end
    end
    
    
    %Reorganize new cell (previously inactive) destinations (what pct of
    %ccI was previously inactive)
    for ccI = 1:length(anyCheck)
        newCellPropsA{slI}{ccI} = pooledDailySourcesA{slI}{ccI}{1};
        newCellPropChangesA{slI}{ccI} = pooledSourceChangesA{slI}{ccI}{1};
    end
end

disp('done cell sources for all splitters pooled')
%}

%% Decoder analysis
numShuffles = 100;
numDownsamples = 100;

decodingType = {'allCells', 'threshCells'};
fileName = {'All','Thresh'};
traitLogUse = {cellfun(@(x) x>0,cellSSI,'UniformOutput',false), dayUse};
decodeLoc = {'STEM','ARM'};

regDecoding = []; DSdecoding = [];
%decodingResults = cell(numMice,1); shuffledResults = cell(numMice,1); sessPairs = cell(numMice,1);
for slI = 1:length(decodeLoc)
    for dtI = 1:length(decodingType)
        for mouseI = 1:numMice

            dcFileName = fullfile(mainFolder,mice{mouseI},'decoding',['decoding' fileName{dtI} '_' decodeLoc{slI} '.mat']);
            if exist(dcFileName,'file')==0
                disp(['Running decoding ' decodingType{dtI} ' for mouse ' num2str(mouseI)])
            tic
            [decodingResults, shuffledResults, testConds, titles, sessPairs] =...
                DecoderWrapper3(cellTBT{mouseI},traitLogUse{dtI}{mouseI},numShuffles,'transientDur','pooled','bayes'); %#ok<ASGLU>
            toc
            save(dcFileName,'decodingResults', 'shuffledResults', 'testConds', 'titles', 'sessPairs')
            clear('decodingResults', 'shuffledResults', 'testConds', 'titles', 'sessPairs')
            end
    
            regDecoding{slI}{dtI}{mouseI} = load(dcFileName);
  %}
            dsdcFileName = fullfile(mainFolder,mice{mouseI},'decoding',['DSdecoding' fileName{dtI} '_' decodeLoc{slI} '.mat']);
            if exist(dsdcFileName,'file')==0
                disp(['Running downsampled decoding ' decodingType{dtI} ' for mouse ' num2str(mouseI)])
            tic
            [DSdecodingResults, DSdownsampledResults, DStestConds, DStitles, DSsessPairs, cellDownsamples] =...
                DecoderWrapper3downsampling(cellTBT{mouseI},traitLogUse{dtI}{mouseI},numDownsamples,'transientDur','pooled',cellRealDays{mouseI},'bayes');
            toc
            save(dsdcFileName,'DSdecodingResults', 'DSdownsampledResults', 'DStestConds', 'DStitles', 'DSsessPairs', 'cellDownsamples')
            clear('DSdecodingResults', 'DSdownsampledResults', 'DStestConds', 'DStitles', 'DSsessPairs', 'cellDownsamples')
            end

            DSdecoding{slI}{dtI}{mouseI} = load(dsdcFileName);

            disp(['Done getting/loading ' decodingType{dtI} ' decoding for mouse ' num2str(mouseI) ' on ' decodeLoc{slI}])
        end
    end
end

%cellDownsamples{dtI}{mouseI} = GetDownsampleCellCombs(traitLogUse{dtI}{mouseI},regDecoding{dtI}{mouseI}.sessPairs,numDownsamples);

%Layout:
%decodingResults{mazeLocation}{decodingType}{mouse}.decodingResults.correctPct{1,dimDecoded}(sessPairI,condDecoding)

decodingResults = []; shuffledResults = []; decodedWell = [];
downsampledResults = []; DSshuffledResults = []; decodeOutofDS = [];

for slI = 1:length(decodeLoc)
for dtI = 1:length(decodingType)
    dimsDecoded = regDecoding{slI}{dtI}{1}.titles;
    for ddI = 1:length(dimsDecoded)
        for mouseI = 1:numMice
            %Pool wihtin sesspairs
            decodingResults{slI}{dtI}{ddI}{mouseI} = PoolCorrectIndivDecoding(regDecoding{slI}{dtI}{mouseI}.decodingResults.correctIndiv{ddI});
            shuffledResults{slI}{dtI}{ddI}{mouseI} = PoolCorrectIndivDecodingShuffles(regDecoding{slI}{dtI}{mouseI}.shuffledResults.correctIndiv(:,ddI));
            %DSdecodingResults
            downsampledResults{slI}{dtI}{ddI}{mouseI} = PoolCorrectIndivDecodingShuffles(DSdecoding{slI}{dtI}{mouseI}.DSdownsampledResults.correctIndiv(:,ddI));
            
            %Process results relative to chance
            decodedWell{slI}{dtI}{ddI}{mouseI} = EvaluateDecodingPerformance(decodingResults{slI}{dtI}{ddI}{mouseI},shuffledResults{slI}{dtI}{ddI}{mouseI},pThresh);
            sessPairs{slI}{dtI}{ddI}{mouseI} = cellRealDays{mouseI}(regDecoding{slI}{dtI}{mouseI}.sessPairs);
            
            %Downsampled evaluation
            decodeOutofDS{slI}{dtI}{ddI}{mouseI} = EvaluateDecodingPerformance(decodingResults{slI}{dtI}{ddI}{mouseI},downsampledResults{slI}{dtI}{ddI}{mouseI},pThresh);
            [decodingAboveDSrate{slI}{dtI}{ddI}{mouseI}, DSbetterThanShuff{slI}{dtI}{ddI}{mouseI}, DSaboveShuffP{slI}{dtI}{ddI}{mouseI}, meanDSperformance{slI}{dtI}{ddI}{mouseI}] =...
                EvaluateDownsampledDecodingPerformance(decodingResults{slI}{dtI}{ddI}{mouseI},downsampledResults{slI}{dtI}{ddI}{mouseI},...
                shuffledResults{slI}{dtI}{ddI}{mouseI},DSdecoding{slI}{dtI}{mouseI}.cellDownsamples,pThresh);
        end

        %Pool across mice
        decodingResultsPooled{slI}{dtI}{ddI} = PoolCellArrAcrossMice(decodingResults{slI}{dtI}{ddI});
        shuffledResultsPooled{slI}{dtI}{ddI} = PoolCellArrAcrossMice(shuffledResults{slI}{dtI}{ddI});
        downsampledResultsPooled{slI}{dtI}{ddI} = PoolCellArrAcrossMice(downsampledResults{slI}{dtI}{ddI});
        decodedWellPooled{slI}{dtI}{ddI} = PoolCellArrAcrossMice(decodedWell{slI}{dtI}{ddI});
        decodeOutofDSpooled{slI}{dtI}{ddI} = PoolCellArrAcrossMice(decodeOutofDS{slI}{dtI}{ddI});
        decodeAboveDSratePooled{slI}{dtI}{ddI} = PoolCellArrAcrossMice(decodingAboveDSrate{slI}{dtI}{ddI});
        DSmeanDayPairPerfPooled{slI}{dtI}{ddI} = PoolCellArrAcrossMice(meanDSperformance{slI}{dtI}{ddI});      
        DSbetterThanShuffPooled{slI}{dtI}{ddI} = PoolCellArrAcrossMice(DSbetterThanShuff{slI}{dtI}{ddI});
        DSaboveShuffPpooled{slI}{dtI}{ddI} = PoolCellArrAcrossMice(DSaboveShuffP{slI}{dtI}{ddI});
        
        sessPairsPooled{slI}{dtI}{ddI} = PoolCellArrAcrossMice(sessPairs{slI}{dtI}{ddI});
        sessDayDiffs{slI}{dtI}{ddI} = diff(sessPairsPooled{slI}{dtI}{ddI},1,2);
        
        %These work a little bit differently, need to work on them
        %DSdecodeAboveShuff{dtI}{ddI} = PoolCellArrAcrossMice(DSbetterThanShuff{dtI}{ddI});
        %DSaboveShuffP{dtI}{dtI} = PoolCellArrAcrossMice(DSaboveShuffP{dtI}{ddI});
    end
end
end

withinDayDecodingResults = [];
for slI = 1:length(decodeLoc)
for dtI = 1:length(decodingType)
    dimsDecoded = regDecoding{slI}{dtI}{1}.titles;
    for ddI = 1:length(dimsDecoded)
        pooledWithinDayDecResChange{slI}{dtI}{ddI} = [];
        for mouseI = 1:numMice
            withinDayDecodingResults{slI}{dtI}{ddI}{mouseI} = decodingResults{slI}{dtI}{ddI}{mouseI}(allRealDayDiffs{mouseI}==0);
            [withinDayDecResChange{slI}{dtI}{ddI}{mouseI}, ~] = TraitChangeDayPairs(withinDayDecodingResults{slI}{dtI}{ddI}{mouseI},combnk(1:numDays(mouseI),2));
           
            pooledWithinDayDecResChange{slI}{dtI}{ddI} = [pooledWithinDayDecResChange{slI}{dtI}{ddI}; withinDayDecResChange{slI}{dtI}{ddI}{mouseI}];
        end
    end
end
end

disp('Done decoding analysis')

%% Pop vector corr differences by cells included (Do Work here)

pooledCondPairs = condPairs;
poolLabels = {'Left','Right','Study','Test'};
condSet = {[1:4]; [5 6]; [7 8]};
condSetComps = [1 2; 1 3; 2 3];
condSetLabels = {'VS Self', 'Left vs. Right', 'Study vs. Test'}; csLabelsShort = {'VSelf','LvR','SvT'};
condSetColors = {'g' 'r' 'b'};
for cscI = 1:size(condSetComps,1)
    cscLabels{cscI} = [csLabelsShort{condSetComps(cscI,1)} ' - ' csLabelsShort{condSetComps(cscI,2)}];
end
condSetInds = [1*ones(length(condSet{1}),1); 2*ones(length(condSet{2}),1); 3*ones(length(condSet{3}),1)];
pooledCompPairs = {[1 1]; [2 2]; [3 3]; [4 4]; [1 2]; [2 1]; [3 4]; [4 3]}; %PFs from half tmap1/2 to use

%Set up different trait logicals
traitLogicalsUse{1}{1} = threshAndConsec;
traitLogicalsUse{2}{1} = threshAndConsecArm;
traitLogicalsUse{1}{2} = trialReli;
traitLogicalsUse{2}{2} = trialReliArm;
pooledTraitLogicalA = []; pooledTraitLogicalB = []; pooledTraitLogicalC = [];
for slI = 1:2
    pooledTraitLogicalA{slI} = [];
    pooledTraitLogicalB{slI} = [];
    for mouseI = 1:numMice 
        for cc = 1:size(pooledCondPairs,1)
            tluI = 1;
            % traitLogicalA: threshAndConsec
            pooledTraitLogicalA{slI}{mouseI}(:,:,cc) =...
                sum(traitLogicalsUse{slI}{tluI}{mouseI}(:,:,pooledCondPairs(cc,:)),3) > 0;
            tluI = 2;
            % traitLogicalB: trialReli > 0
            pooledTraitLogicalB{slI}{mouseI}(:,:,cc) =...
                sum(traitLogicalsUse{slI}{tluI}{mouseI}(:,:,pooledCondPairs(cc,:)),3) > 0;
        end
    end
    pooledTraitLogicalC{slI} = cellfun(@(x) repmat(x>0,1,1,4),cellSSI,'UniformOutput',false);
end

pvNames = {'aboveThreshEither',       'includeSilent',       'activeBoth',     'firesEither',       'cellPresentBoth', 'cellPresentEither'};
for slI = 1:2
    traitLogUse{slI} = {pooledTraitLogicalA{slI}, pooledTraitLogicalA{slI}, pooledTraitLogicalB{slI}, pooledTraitLogicalB{slI}, pooledTraitLogicalC{slI}, pooledTraitLogicalC{slI}};
end
cellsUseAll = {'activeEither',        'includeSilent',    'activeBoth',       'activeEither',        'activeBoth',       'activeEither'};

fNamePref = {'','ARM'}; cTBT = {cellTBT; cellTBTarm}; binEdgesBoth = {stemBinEdges; armBinEdges};

%Make (or check for) PV corrs
for slI = 1:2
for pvtI = 1:length(pvNames)
    for mouseI = 1:numMice
        pvBasicFile = fullfile(mainFolder,mice{mouseI},'corrs',[fNamePref{slI} 'basic_corrs_' pvNames{pvtI} '.mat']);
        %Make the pv corrs
        if exist(pvBasicFile,'file') == 0
            disp(['Did not find basic corrs ' pvNames{pvtI} ' for mouse ' num2str(mouseI) ' on ' mazeLocations{slI} ', making it now'])
            [tpvCorrs, tmeanCorr, ~, ~, ~, ~, tPVdayPairs]=...
                MakePVcorrsWrapper2(cTBT{slI}{mouseI}, [], [], 0, pooledCompPairs,...
                pooledCondPairs, poolLabels, traitLogUse{slI}{pvtI}{mouseI}, binEdgesBoth{slI}, minspeed,cellsUseAll{pvtI});
            save(pvBasicFile,'tpvCorrs','tmeanCorr','tPVdayPairs','pooledCompPairs')
        end
    end
end
end

pvCorrs = []; meanCorr = []; PVdayPairs = []; PVdaysApart = [];
withinMouseCSpooledPVcorrs = [];
for slI = 1:2
for pvtI = 1:length(pvNames)
    for mouseI = 1:numMice
        pvBasicFile = fullfile(mainFolder,mice{mouseI},'corrs',[fNamePref{slI} 'basic_corrs_' pvNames{pvtI} '.mat']);

        load(pvBasicFile)

        pvCorrs{slI}{pvtI}{mouseI} = tpvCorrs;
        meanCorr{slI}{pvtI}{mouseI} = cell2mat(tmeanCorr);
        PVdayPairs{slI}{pvtI}{mouseI} = tPVdayPairs;
        PVdayPairs{slI}{pvtI}{mouseI} = cellRealDays{mouseI}(PVdayPairs{slI}{pvtI}{mouseI});
        PVdaysApart{slI}{pvtI}{mouseI} = diff(PVdayPairs{slI}{pvtI}{mouseI},[],2);

        meanCorrHalfFirst{slI}{pvtI}{mouseI} = cell2mat(cellfun(@(x) mean(x(:,1:2),2),tpvCorrs,'UniformOutput',false));
        meanCorrHalfSecond{slI}{pvtI}{mouseI} = cell2mat(cellfun(@(x) mean(x(:,numBins-1:numBins),2),tpvCorrs,'UniformOutput',false));

        %withinMouseCSpooledPVcorrs{slI}{pvtI}{mouseI} = PoolCellArr(pvCorrs{slI}{pvtI}{mouseI},condSet);
        disp(['Done basic corrs ' pvNames{pvtI} ' for mouse ' num2str(mouseI) ' on ' mazeLocations{slI}])
    end
    
    %Pool Corrs across mice
    pooledPVcorrs{slI}{pvtI} = PoolCorrsAcrossMice(pvCorrs{slI}{pvtI});
    pooledMeanPVcorrs{slI}{pvtI} = PoolCorrsAcrossMice(meanCorr{slI}{pvtI});
    pooledMeanPVcorrsHalfFirst{slI}{pvtI} = PoolCorrsAcrossMice(meanCorrHalfFirst{slI}{pvtI});
    pooledMeanPVcorrsHalfSecond{slI}{pvtI} = PoolCorrsAcrossMice(meanCorrHalfSecond{slI}{pvtI});

    pooledPVdayPairsTemp{slI}{pvtI} = PoolCorrsAcrossMice(PVdayPairs{slI}{pvtI});
    pooledPVdayPairs{slI}{pvtI} = [pooledPVdayPairsTemp{slI}{pvtI}{1} pooledPVdayPairsTemp{slI}{pvtI}{2}];
    pooledPVDaysApart{slI}{pvtI} = abs(diff(pooledPVdayPairs{slI}{pvtI},[],2));
    
    %Pool by condset
    CSpooledPVcorrs{slI}{pvtI} = PoolCellArr(pooledPVcorrs{slI}{pvtI},condSet);
    CSpooledMeanPVcorrs{slI}{pvtI} = PoolCellArr(pooledMeanPVcorrs{slI}{pvtI},condSet);
    CSpooledMeanPVcorrsHalfFirst{slI}{pvtI} = PoolCellArr(pooledMeanPVcorrsHalfFirst{slI}{pvtI},condSet);
    CSpooledMeanPVcorrsHalfSecond{slI}{pvtI} = PoolCellArr(pooledMeanPVcorrsHalfSecond{slI}{pvtI},condSet);

    CSpooledPVdaysApart{slI}{pvtI} = cellfun(@(x) repmat(pooledPVDaysApart{slI}{pvtI},length(x),1),condSet,'UniformOutput',false);
end
end

%Change of each corr over time
sameDayDayDiffsPooled = [];
for slI = 1:2
    sameDayDayDiffsPooled{slI} = cell(length(pvNames),1);
    for pvtI = 1:length(pvNames)
        for mouseI = 1:numMice
            sameDayDayDiffsPooled{slI}{pvtI} = [sameDayDayDiffsPooled{slI}{pvtI}; realDayDiffs{mouseI}];
        end

        [withinCSdayChangeMean{slI}{pvtI},cscDiffsChangeMeanPooled{slI}{pvtI},sameDayCompsPooled{slI}{pvtI}] =...
            CorrChangeOverDays(meanCorr{slI}{pvtI},PVdayPairs{slI}{pvtI},dayPairs,condSet,condSetComps);
        [withinCSdayChangeMeanHalfFirst{slI}{pvtI},cscDiffsChangeMeanHalfFirstPooled{slI}{pvtI},~] =...
            CorrChangeOverDays(meanCorrHalfFirst{slI}{pvtI},PVdayPairs{slI}{pvtI},dayPairs,condSet,condSetComps);
        [withinCSdayChangeMeanHalfSecond{slI}{pvtI},cscDiffsChangeMeanHalfSecondPooled{slI}{pvtI},~] =...
            CorrChangeOverDays(meanCorrHalfSecond{slI}{pvtI},PVdayPairs{slI}{pvtI},dayPairs,condSet,condSetComps);
    end
end

%Mean pv corrs for each unique day pair
pvCorrsDPpooled = []; uniqueDayPairs = []; cellArrMeanByCS = []; CSpooledPVcorrs2 = []; 
CSpooledPVdaysApart2 = []; CSpooledMeanPVcorrsHalfFirst2 = []; CSpooledMeanPVcorrsHalfSecond2 = [];
for slI = 1:2
    for pvtI = 1:length(pvNames)
        for mouseI = 1:numMice
            pvCorrsDPpooled{slI}{pvtI}{mouseI} = [];
            for corrI = 1:size(pvCorrs{slI}{pvtI}{mouseI},2)
                pvsHere = pvCorrs{slI}{pvtI}{mouseI}(:,corrI);
                [pvsOut,daysOut] = PoolPVcorrByDayPair(pvsHere,PVdayPairs{slI}{pvtI}{mouseI});
                pvCorrsDPpooled{slI}{pvtI}{mouseI} = [pvCorrsDPpooled{slI}{pvtI}{mouseI},pvsOut];
                uniqueDayPairs{slI}{pvtI}{mouseI} = daysOut;
                uniqueDayDiffs{slI}{pvtI}{mouseI} = diff(daysOut,1,2);
            end
            cellArrMeanByCS{slI}{pvtI}{mouseI} = MeanCellArr(pvCorrsDPpooled{slI}{pvtI}{mouseI},condSet);
        end
        CSpooledPVcorrs2{slI}{pvtI} = PoolCorrsAcrossMice(cellArrMeanByCS{slI}{pvtI});
        CSpooledPVdaysApartTemp{slI}{pvtI} = PoolCorrsAcrossMice(uniqueDayDiffs{slI}{pvtI});
        
        for csI = 1:length(condSet)
            CSpooledMeanPVcorrs2{slI}{pvtI}{csI,1} = mean(CSpooledPVcorrs2{slI}{pvtI}{csI,1},2);
            CSpooledMeanPVcorrsHalfFirst2{slI}{pvtI}{csI,1} = mean(CSpooledPVcorrs2{slI}{pvtI}{csI,1}(:,1:2),2);
            CSpooledMeanPVcorrsHalfSecond2{slI}{pvtI}{csI,1} = mean(CSpooledPVcorrs2{slI}{pvtI}{csI,1}(:,end-1:end),2);
            CSpooledPVdaysApart2{slI}{pvtI}{csI,1} = CSpooledPVdaysApartTemp{slI}{pvtI}{1};
        end
    end
end
       
%Pooled within mice
CSpooledPVcorrWithinMouse = [];
withinDayCSpooledPVcorrWithinMouse = [];
withinDayCSpooledPVcorrWithinMouseMat = [];
for slI = 1:2
    for pvtI = 1:length(pvNames)
        for mouseI = 1:numMice
            for csI = 1:length(condSet)
                CSpooledPVcorrWithinMouse{slI}{pvtI}{mouseI}{csI} = pvCorrs{slI}{pvtI}{mouseI}(:,condSet{csI});
                withinDayCSpooledPVcorrWithinMouse{slI}{pvtI}{mouseI}{csI} = CSpooledPVcorrWithinMouse{slI}{pvtI}{mouseI}{csI}(PVdaysApart{slI}{pvtI}{mouseI}==0,:);
                for ccI = 1:size(withinDayCSpooledPVcorrWithinMouse{slI}{pvtI}{mouseI}{csI},2)
                    withinDayCSpooledPVcorrWithinMouseMat{slI}{pvtI}{mouseI}{csI}{1,ccI} = cell2mat(withinDayCSpooledPVcorrWithinMouse{slI}{pvtI}{mouseI}{csI}(:,ccI));
                end
            end
        end
    end
end
                
disp('Done PV corrs') 

%{
%% Discrimination index of PV results

tic
for slI = 1:2
    CSpooledPVcorrsDPrime{slI} = [];
    CSpooledPVcorrsDPrimePval{slI} = [];
    CSpooledPVcorrsDiff{slI} = [];
    for pvtI = 1:length(pvNames)
        for pvpoolI = 2:3
            dayDiffsHere = unique([CSpooledPVdaysApart{slI}{pvtI}{1}; CSpooledPVdaysApart{slI}{pvtI}{pvpoolI}]);
            for ddI = 1:length(dayDiffsHere)
                daysUseSig = CSpooledPVdaysApart{slI}{pvtI}{pvpoolI}==dayDiffsHere(ddI);
                daysUseNoise = CSpooledPVdaysApart{slI}{pvtI}{1}==dayDiffsHere(ddI);

                [CSpooledPVcorrsDPrime{slI}{pvtI}{pvpoolI-1}(ddI),CSpooledPVcorrsDPrimePval{slI}{pvtI}{pvpoolI-1}(ddI)] =...
                    SensitivityIndexSL(CSpooledPVcorrs{slI}{pvtI}{pvpoolI}(daysUseSig),CSpooledPVcorrs{slI}{pvtI}{1}(daysUseNoise),1000);
                [CSpooledPVcorrsDPrimeHalfFirst{slI}{pvtI}{pvpoolI-1}(ddI),CSpooledPVcorrsDPrimePvalHalfFirst{slI}{pvtI}{pvpoolI-1}(ddI)] =...
                    SensitivityIndexSL(CSpooledMeanPVcorrsHalfFirst{slI}{pvtI}{pvpoolI}(daysUseSig),CSpooledMeanPVcorrsHalfFirst{slI}{pvtI}{1}(daysUseNoise),1000);
                [CSpooledPVcorrsDPrimeHalfSecond{slI}{pvtI}{pvpoolI-1}(ddI),CSpooledPVcorrsDPrimePvalHalfSecond{slI}{pvtI}{pvpoolI-1}(ddI)] =...
                    SensitivityIndexSL(CSpooledMeanPVcorrsHalfSecond{slI}{pvtI}{pvpoolI}(daysUseSig),CSpooledMeanPVcorrsHalfSecond{slI}{pvtI}{1}(daysUseNoise),1000);

                CSpooledPVcorrsDiff{slI}{pvtI}{pvpoolI-1}(ddI) = mean(CSpooledPVcorrs{slI}{pvtI}{1}(daysUseNoise)) - mean(CSpooledPVcorrs{slI}{pvtI}{pvpoolI}(daysUseSig)); 
                CSpooledPVcorrsDiffHalfFirst{slI}{pvtI}{pvpoolI-1}(ddI) =...
                    mean(CSpooledMeanPVcorrsHalfFirst{slI}{pvtI}{1}(daysUseNoise)) - mean(CSpooledMeanPVcorrsHalfFirst{slI}{pvtI}{pvpoolI}(daysUseSig)); 
                CSpooledPVcorrsDiffHalfSecond{slI}{pvtI}{pvpoolI-1}(ddI) =...
                    mean(CSpooledMeanPVcorrsHalfSecond{slI}{pvtI}{1}(daysUseNoise)) - mean(CSpooledMeanPVcorrsHalfSecond{slI}{pvtI}{pvpoolI}(daysUseSig)); 
            end
        end
    end
end
toc

disp('Done PV corr sensitivity index')
%}
%% Center of mass, change over time

disp('Generating maps for center of mass')
for mouseI = 1:numMice
    [allCondsTMap{mouseI}, ~, ~, ~, ~, ~, ~] =...
        PFsLinTBTdnmp(cellTBT{mouseI}, stemBinEdges, minspeed, [], false,[1 2 3 4]);

    [allCondsTMapARM{mouseI}, ~, ~, ~, ~, ~, ~] =...
        PFsLinTBTdnmp(cellTBTarm{mouseI}, armBinEdges, minspeed, [], false,[1 2 3 4]);

    allFiringCOM{mouseI} = TMapFiringCOM(allCondsTMap{mouseI});
    allFiringCOMarm{mouseI} = TMapFiringCOM(allCondsTMapARM{mouseI});
end
disp('done')

pooledCOMlr = [];
pooledCOMst = [];
pooledCOMlrEx = [];
pooledCOMstEx = [];
pooledCOMboth = [];
pooledCOMlrARM = [];
pooledCOMstARM = [];
pooledCOMlrARMex = [];
pooledCOMstARMex = [];
pooledCOMbothARM = [];
for mouseI = 1:numMice
    for dayI = 1:numDays(mouseI)
        pooledCOMlr = [pooledCOMlr; allFiringCOM{mouseI}(traitGroups{1}{mouseI}{1}(:,dayI),dayI)];
        pooledCOMst = [pooledCOMst; allFiringCOM{mouseI}(traitGroups{1}{mouseI}{2}(:,dayI),dayI)];
        pooledCOMlrEx = [pooledCOMlrEx; allFiringCOM{mouseI}(traitGroups{1}{mouseI}{3}(:,dayI),dayI)];
        pooledCOMstEx = [pooledCOMstEx; allFiringCOM{mouseI}(traitGroups{1}{mouseI}{4}(:,dayI),dayI)];
        pooledCOMboth = [pooledCOMboth; allFiringCOM{mouseI}(traitGroups{1}{mouseI}{5}(:,dayI),dayI)];
        
        pooledCOMlrARM = [pooledCOMlrARM; allFiringCOMarm{mouseI}(traitGroups{2}{mouseI}{1}(:,dayI),dayI)];
        pooledCOMstARM = [pooledCOMstARM; allFiringCOMarm{mouseI}(traitGroups{2}{mouseI}{2}(:,dayI),dayI)];
        pooledCOMlrARMex = [pooledCOMlrARMex; allFiringCOMarm{mouseI}(traitGroups{2}{mouseI}{3}(:,dayI),dayI)];
        pooledCOMstARMex = [pooledCOMstARMex; allFiringCOMarm{mouseI}(traitGroups{2}{mouseI}{4}(:,dayI),dayI)];
        pooledCOMbothARM = [pooledCOMbothARM; allFiringCOMarm{mouseI}(traitGroups{2}{mouseI}{5}(:,dayI),dayI)];
    end
end

disp('Done getting COM')

%% PV corrs all to all bins

fNamePref = {'','ARM'}; cTBT = {cellTBT; cellTBTarm}; binEdgesBoth = {stemBinEdges; armBinEdges};

for slI = 1:2
pvtI = 5;
    for mouseI = 1:numMice
        pvBasicFile = fullfile(mainFolder,mice{mouseI},'corrs',[fNamePref{slI} 'basic_corrs_all_' pvNames{pvtI} '.mat']);
        %Make the pv corrs
        if exist(pvBasicFile,'file') == 0
            disp(['Did not find basic corrs ' pvNames{pvtI} ' for mouse ' num2str(mouseI) ' on ' mazeLocations{slI} ', making it now'])
            [tpvCorrsAll, tmeanCorrAll, ~, ~, ~, ~, tPVdayPairsAll]=...
                MakePVcorrsWrapper2allToAll(cTBT{slI}{mouseI}, [], [], 0, pooledCompPairs,...
                pooledCondPairs, poolLabels, traitLogUse{slI}{pvtI}{mouseI}, binEdgesBoth{slI}, minspeed,cellsUseAll{pvtI});
            save(pvBasicFile,'tpvCorrsAll','tmeanCorrAll','tPVdayPairsAll','pooledCompPairs')
        end
        
        load(pvBasicFile)
        pvCorrsATA{slI}{pvtI}{mouseI} = tpvCorrsAll;
        PVdayPairsATA{slI}{pvtI}{mouseI} = tPVdayPairsAll;
    end
end

pvCorrsDPpooled = []; uniqueDayPairs = []; cellArrMeanByCS = []; CSpooledPVcorrs2 = []; 
CSpooledPVdaysApart2 = []; CSpooledMeanPVcorrsHalfFirst2 = []; CSpooledMeanPVcorrsHalfSecond2 = [];

for slI = 1:2
    pvtI = 5;
        for mouseI = 1:numMice
            pvCorrsDPpooledATA{slI}{pvtI}{mouseI} = [];
            for corrI = 1:size(pvCorrsATA{slI}{pvtI}{mouseI},2)
                pvsHere = pvCorrsATA{slI}{pvtI}{mouseI}(:,corrI);
                [pvsOutATA,daysOutATA] = PoolPVcorrByDayPair(pvsHere,PVdayPairsATA{slI}{pvtI}{mouseI});
                pvCorrsDPpooledATA{slI}{pvtI}{mouseI} = [pvCorrsDPpooledATA{slI}{pvtI}{mouseI},pvsOutATA];
                uniqueDayPairsATA{slI}{pvtI}{mouseI} = daysOutATA;
                uniqueDayDiffsATA{slI}{pvtI}{mouseI} = diff(daysOutATA,1,2);
            end
            cellArrMeanByCSata{slI}{pvtI}{mouseI} = MeanCellArr(pvCorrsDPpooledATA{slI}{pvtI}{mouseI},condSet);
            cellArrMeanEachCondATA{slI}{pvtI}{mouseI} = MeanCellArr(pvCorrsDPpooledATA{slI}{pvtI}{mouseI},{1;2;3;4});
        end
        CSpooledPVcorrs2ATA{slI}{pvtI} = PoolCorrsAcrossMice(cellArrMeanByCSata{slI}{pvtI});
        CSpooledPVcorrsEachATA{slI}{pvtI} = PoolCorrsAcrossMice(cellArrMeanEachCondATA{slI}{pvtI});
        CSpooledPVdaysApartTempATA{slI}{pvtI} = PoolCorrsAcrossMice(uniqueDayDiffs{slI}{pvtI});
        
        %Work from here
        for csI = 1:length(condSet)
            CSpooledMeanPVcorrs2ATA{slI}{pvtI}{csI,1} = mean(CSpooledPVcorrs2ATA{slI}{pvtI}{csI,1},3);
            %CSpooledMeanPVcorrsHalfFirst2{slI}{pvtI}{csI,1} = mean(CSpooledPVcorrs2{slI}{pvtI}{csI,1}(:,1:2),2);
            %CSpooledMeanPVcorrsHalfSecond2{slI}{pvtI}{csI,1} = mean(CSpooledPVcorrs2{slI}{pvtI}{csI,1}(:,end-1:end),2);
            CSpooledPVdaysApart2{slI}{pvtI}{csI,1} = CSpooledPVdaysApartTempATA{slI}{pvtI}{1};
        end
end

%% New cells/lost cells
numNewCellsPooled = [];
pctNewCellsChangePooled = [];
numLostCellsPooled = [];
pctLostCellsChangePooled = [];
dayPairsHerePooled = [];
for mouseI = 1:numMice
    cellPresent = cellSSI{mouseI} > 0;
    for dayI = 2:length(cellRealDays{mouseI})
        newCells = cellPresent(:,dayI) == (cellPresent(:,dayI-1)==0);
        numNewCells{mouseI}(dayI-1) = sum(newCells);
        newOutofTotal{mouseI}(dayI-1) = numNewCells{mouseI}(dayI-1) / sum(cellPresent(:,dayI));
        
        lostCells = (cellPresent(:,dayI)==0) == cellPresent(:,dayI-1);
        numLostCells{mouseI}(dayI-1) = sum(lostCells);
        lostOutofTotal{mouseI}(dayI-1) = numLostCells{mouseI}(dayI-1) / sum(cellPresent(:,dayI-1));
    end
    
    dayPairsHere = combnk(1:length(cellRealDays{mouseI})-1,2);
    realDaysHere = cellRealDays{mouseI}(2:end);
    realDayPairsHere = realDaysHere(dayPairsHere);
    realDayDiffsHere = diff(realDayPairsHere,1,2);
    dayPairsHerePooled = [dayPairsHerePooled; realDayDiffsHere];
    
    [~, numNewCellsPctChange{mouseI}] = TraitChangeDayPairs(numNewCells{mouseI},dayPairsHere);
    [pctNewCellsChange{mouseI}, ~] = TraitChangeDayPairs(newOutofTotal{mouseI},dayPairsHere);
    
    numNewCellsPooled = [numNewCellsPooled; numNewCellsPctChange{mouseI}];
    pctNewCellsChangePooled = [pctNewCellsChangePooled; pctNewCellsChange{mouseI}];
    
    [~, numLostCellsPctChange{mouseI}] = TraitChangeDayPairs(numLostCells{mouseI},dayPairsHere);
    [pctLostCellsChange{mouseI}, ~] = TraitChangeDayPairs(lostOutofTotal{mouseI},dayPairsHere);
    
    numLostCellsPooled = [numLostCellsPooled; numLostCellsPctChange{mouseI}];
    pctLostCellsChangePooled = [pctLostCellsChangePooled; pctLostCellsChange{mouseI}];
end

figure; plot(dayPairsHerePooled,pctNewCellsChangePooled,'.')
hold on
[fitVal,daysPlot] = FitLineForPlotting(pctNewCellsChangePooled,dayPairsHerePooled);
plot(daysPlot,fitVal,'k'); plot([0 16],[0 0],'k')
title('Pct change in new cells as pct of present that day')

figure; plot(dayPairsHerePooled,pctLostCellsChangePooled,'.')
hold on
[fitVal,daysPlot] = FitLineForPlotting(pctLostCellsChangePooled,dayPairsHerePooled);
plot(daysPlot,fitVal,'k'); plot([0 16],[0 0],'k')
title('Pct change in lost cells as pct of present previous day')
