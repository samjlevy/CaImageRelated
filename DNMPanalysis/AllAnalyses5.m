%% Process all data

mainFolder = 'C:\Users\Sam\Desktop\DNMPfinalData';
%mainFolder = 'C:\Users\samjl\Desktop\DNMPfinalData';
%mainFolder = 'E:\DNMPfinalData';
mice = {'Bellatrix', 'Polaris', 'Calisto', 'Nix'}; %'Europa'
numMice = length(mice);

%Thresholds
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
condPairs = [1 3; 2 4; 1 2; 3 4];

disp('Loading stuff')
for mouseI = 1:numMice
    load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'))
    cellTBT{mouseI} = trialbytrial;
    cellSSI{mouseI} = sortedSessionInds;
    cellAllFiles{mouseI} = allfiles;
    cellRealDays{mouseI} = realdays;
    
    clear trialbytrial sortedSessionInds allFiles realdays
    
    load(fullfile(mainFolder,mice{mouseI},'armTrialbytrial.mat'))
    cellTBTarm{mouseI} = armtrialbytrial;
    
    clear armtrialbytrial realdays allfiles sortedSessionInds
    
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
end

disp('Getting reliability')
dayUse = cell(1,numMice); threshAndConsec = cell(1,numMice);
for mouseI = 1:numMice
    saveName = fullfile(mainFolder,mice{mouseI},'trialReliability.mat');
    if exist(saveName,'file')==0
        [dayUse,threshAndConsec] = GetUseCells(cellTBT{mouseI}, lapPctThresh, consecLapThresh);
        [trialReli,aboveThresh,~,~] = TrialReliability(cellTBT{mouseI}, lapPctThresh);

        [dayUseArm,threshAndConsecArm] = GetUseCells(cellTBTarm{mouseI}, lapPctThresh, consecLapThresh);
        [trialReliArm,aboveThreshArm,~,~] = TrialReliability(cellTBTarm{mouseI}, lapPctThresh);
    
        save(saveName,'dayUse','threshAndConsec','dayUseArm','threshAndConsecArm','trialReli','trialReliArm')
        clear('dayUse','threshAndConsec','dayUseArm','threshAndConsecArm','trialReli','trialReliArm')
    end
end

for mouseI = 1:numMice
    saveName = fullfile(mainFolder,mice{mouseI},'trialReliability.mat');
    reliability{mouseI} = load(saveName);
    
    dayUse{mouseI} = reliability{mouseI}.dayUse;
    threshAndConsec{mouseI} = reliability{mouseI}.threshAndConsec;
    cellsActiveToday{mouseI} = sum(dayUse{mouseI},1);
    daysEachCellActive{mouseI} = sum(dayUse{mouseI},2);
    trialReli{mouseI} = reliability{mouseI}.trialReli;
    
    dayUseArm{mouseI} = reliability{mouseI}.dayUseArm;
    threshAndConsecArm{mouseI} = reliability{mouseI}.threshAndConsecArm;
    cellsActiveTodayArm{mouseI} = sum(dayUseArm{mouseI},1);    
    daysEachCellActiveArm{mouseI} = sum(dayUseArm{mouseI},2);
    trialReliArm{mouseI} = reliability{mouseI}.trialReliArm;
    
    %daysCellFound{mouseI} = sum(cellSSI{mouseI}>0,2);
    clear reliability
end


%Pooled Reliability
disp('Getting pooled reliability')
for mouseI = 1:numMice
    saveName = fullfile(mainFolder,mice{mouseI},'trialReliabilityPooled.mat');
    if exist(saveName,'file')==0
    cellTBTpooled{mouseI} = PoolTBTacrossConds(cellTBT{mouseI},condPairs,{'Left','Right','Study','Test'});
    [dayUsePooled,threshAndConsecPooled] = GetUseCells(cellTBTpooled{mouseI}, lapPctThresh, consecLapThresh);
    [trialReliPooled,aboveThreshPooled,~,~] = TrialReliability(cellTBTpooled{mouseI}, lapPctThresh);
    
    cellTBTarmPooled{mouseI} = PoolTBTacrossConds(cellTBTarm{mouseI},condPairs,{'Left','Right','Study','Test'});
    [dayUseArmPooled,threshAndConsecArmPooled] = GetUseCells(cellTBTarmPooled{mouseI}, lapPctThresh, consecLapThresh);
    [trialReliArmPooled,aboveThreshArmPooled,~,~] = TrialReliability(cellTBTarmPooled{mouseI}, lapPctThresh);
    
    save(saveName,'dayUsePooled','threshAndConsecPooled','dayUseArmPooled','threshAndConsecArmPooled','trialReliPooled','trialReliArmPooled')
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

%Place fields
for mouseI = 1:numMice
    saveName = fullfile(mainFolder,mice{mouseI},'PFsLinPooled.mat');
    switch exist(fullfile(mainFolder,mice{mouseI},'PFsLinPooled.mat'),'file')
        case 0
            disp(['no pooled placefields found for ' mice{mouseI} ', making now'])
            [~, ~, ~, ~, ~, ~, ~] =...
            PFsLinTBTdnmp(cellTBT{mouseI}, stemBinEdges, minspeed, saveName, false,condPairs);
       case 2
            disp(['found pooled placefields for ' mice{mouseI} ', all good'])
    end
    
    load(fullfile(mainFolder,mice{mouseI},'PFsLinPooled.mat'),'TMap_unsmoothed','TMap_zRates')
    cellPooledTMap_unsmoothed{1}{mouseI} = TMap_unsmoothed;
    cellPooledTMap_firesAtAll{1}{mouseI} = TMap_firesAtAll;
    cellPooledTMap_zRates{1}{mouseI} = TMap_unsmoothed; 
    
    saveName = fullfile(mainFolder,mice{mouseI},'PFsLinPooledArm.mat');
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
    cellPooledTMap_firesAtAllArm{1}{mouseI} = TMap_firesAtAll;
    cellPooledTMap_zRatesArm{1}{mouseI} = TMap_unsmoothed; 
end


for mouseI = 1:numMice
     numTrialCells{mouseI} = CellsActiveEachTrial(cellTBT{mouseI});
     for condI = 1:4
     numTrialCellsPctTotal{mouseI}{condI} = numTrialCells{mouseI}{condI}/numCells(mouseI);
     numTrialCellsPctDay{mouseI}{condI} = numTrialCells{mouseI}{condI}./sum(cellSSI{mouseI}>0,1);
     numTrialCellsPctDayMean(mouseI,condI) = mean(mean(numTrialCellsPctDay{mouseI}{condI}));
     end
end

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

disp('Done all setup stuff')
%% Plot rasters for all good cells
%Works, but probably don't accidentally run this
%{
for mouseI = 1:numMice
    saveDir = fullfile(mainFolder,mice{mouseI});
    cellsUse = find(sum(dayUse{mouseI},2)>0);
    PlotRastersPDF(cellTBT{mouseI}, cellSSI{mouseI}, cellAllFiles{mouseI}, cellsUse, saveDir, mice{mouseI});
end
%}

%% Splitter cells: Shuffle versions, pooled
numShuffles = 1000;
shuffThresh = 1 - pThresh;
binsMin = 1;
splitDir = 'splitters';

splitterType = {'LR' 'ST'};
splitterCPs = {[1 2] [3 4]};
splitterLoc = {'stem' 'arm'};

%Get/make splitting
binsAboveShuffle = [];
thisCellSplits = [];
for mouseI = 1:numMice
    shuffleDir = fullfile(mainFolder,mice{mouseI},splitDir);
    for stI = 1:length(splitterType)
        for slI = 1:length(splitterLoc)
            switch splitterLoc{slI}
                case 'stem'
                    binEdgesHere = stemBinEdges;
                    splitterFile = fullfile(shuffleDir,['splitters' splitterType{stI} '.mat']);
                    %cellTMap = cellPooledTMap_unsmoothed{1}{mouseI};
                    cellTMap = cellPooledTMap_firesAtAll{1}{mouseI};
                    tbtHere = cellTBT{mouseI};
                case 'arm'
                    splitterFile = fullfile(shuffleDir,['ARMsplitters' splitterType{stI} '.mat']);
                    binEdgesHere = armBinEdges;
                    %cellTMap = cellPooledTMap_unsmoothedArm{1}{mouseI};
                    cellTMap = cellPooledTMap_firesAtAllArm{1}{mouseI};
                    tbtHere = cellTBTarm{mouseI};
            end
            
            if exist(splitterFile,'file')==0
            disp(['did not find ' splitterType{stI} ' on ' splitterLoc{slI} ' splitting for mouse ' num2str(mouseI) ', making now'])
            tic
            [binsAboveShuffle, thisCellSplits] = SplitterWrapper4(tbtHere, cellTMap,  splitterType{stI},...
                'pooled', numShuffles, binEdgesHere, minspeed, shuffThresh, binsMin);
            save(splitterFile,'binsAboveShuffle','thisCellSplits')
            toc
            end
            
            loadedSplit = load(splitterFile);
            
            binsAboveShuffle{slI}{stI}{mouseI} = loadedSplit.binsAboveShuffle;
            thisCellSplits{slI}{stI}{mouseI} = loadedSplit.thisCellSplits;
            
            [rateDiff{slI}{stI}{mouseI}, rateSplit{slI}{stI}{mouseI}, meanRateDiff{slI}{stI}{mouseI}, DIeach{slI}{stI}{mouseI},...
                DImean{slI}{stI}{mouseI}, DIall{slI}{stI}{mouseI}] =...
                LookAtSplitters4(cellTMap, splitterCPs{stI}, []);
            
            disp(['done ' splitterType{stI} ' on ' splitterLoc{slI} ' splitting for mouse ' num2str(mouseI)])
        end
    end
end
   
%% Splitter cells: logical each type
%dayUseFilter = {dayUse; dayUseArm}; 
dayUseFilter = {dayUsePooled; dayUseArmPooled};
%dayUseFilter = {cellfun(@(x) ones(size(x)),dayUse,'UniformOutput',false); cellfun(@(x) ones(size(x)),dayUseArm,'UniformOutput',false)};

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
        traitGroups{slI}{mouseI} = {splittersLR{slI}{mouseI};... 
                                    splittersST{slI}{mouseI};... 
                                    splittersLRonly{slI}{mouseI};... 
                                    splittersSTonly{slI}{mouseI}; ...
                                    splittersBoth{slI}{mouseI}; ...
                                    splittersOne{slI}{mouseI};... 
                                    splittersAny{slI}{mouseI}; ...
                                    splittersNone{slI}{mouseI}};
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

disp('done splitter logicals')

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
        [splitterNumChange{slI}{mouseI}, splitterPctChange{slI}{mouseI}] = cellfun(@(x) TraitChangeDayPairs(x,dayPairs{mouseI}),splitPropEachDay{slI}{mouseI},'UniformOutput',false);        
        for tgI = 1:numTraitGroups
            pooledSplitNumChange{slI}{tgI} = [pooledSplitNumChange{slI}{tgI}; splitterNumChange{slI}{mouseI}{tgI}];
            pooledSplitPctChange{slI}{tgI} = [pooledSplitPctChange{slI}{tgI}; splitterPctChange{slI}{mouseI}{tgI}];
        end
    end
end

disp('done how many splitters')


%% Change in accuracy, speed, time to run down arm
pooledAccuracyChange = []; accuracyChange = [];
for mouseI = 1:numMice
    for dpI = 1:size(dayPairs{mouseI},1)
        accuracyChange{mouseI}(dpI,1) = accuracy{mouseI}(dayPairs{mouseI}(dpI,2)) - accuracy{mouseI}(dayPairs{mouseI}(dpI,1));
    end
    pooledAccuracyChange = [pooledAccuracyChange; accuracyChange{mouseI}];    
end

[accuracyFval,accuracydfNum,accuracydfDen,accuracypVal] = slopeDiffFromZeroFtest(pooledAccuracyChange,pooledRealDayDiffs);
[~, ~, accuracyFitLine, ~,~,~] = fitLinRegSL(pooledAccuracyChange, pooledRealDayDiffs);

%time down arm: 
%cellfun(@(x) sum(x,2),cellTBT{mouseI}(condI).trialPSAbool,'UniformOutput',false)

%% How many active cells by days?
pooledActiveCellsChange = []; pooledRealDayDiffs = [];
for mouseI = 1:numMice
    cellsActiveEachDay{mouseI} = sum(dayUse{mouseI},1)/size(dayUse{mouseI},1);
    
    for dpI = 1:size(dayPairs{mouseI},1)
        activeCellsChange{mouseI}(dpI,1) = cellsActiveEachDay{mouseI}(dayPairs{mouseI}(dpI,2)) - cellsActiveEachDay{mouseI}(dayPairs{mouseI}(dpI,1));
    end
    
    pooledActiveCellsChange = [pooledActiveCellsChange; activeCellsChange{mouseI}]; 
end

[~, ~, cellsActiveFitLine, ~,~,~] = fitLinRegSL(pooledActiveCellsChange, pooledRealDayDiffs);
[cellsActiveFval,cellsActivedfNum,cellsActivedfDen,cellsActivepVal] = slopeDiffFromZeroFtest(pooledActiveCellsChange,pooledRealDayDiffs);
    

pooledActiveCellsChangeARM = []; pooledRealDayDiffsARM = [];
for mouseI = 1:numMice
    cellsActiveEachDayARM{mouseI} = sum(dayUseArm{mouseI},1)/size(dayUseArm{mouseI},1);
    %dayPairs{mouseI} = combnk(1:numDays(mouseI),2);
    %realDayPairs{mouseI} = cellRealDays{mouseI}(dayPairs{mouseI});
    for dpI = 1:size(dayPairs{mouseI},1)
        activeCellsChangeARM{mouseI}(dpI,1) = cellsActiveEachDayARM{mouseI}(dayPairs{mouseI}(dpI,2)) - cellsActiveEachDayARM{mouseI}(dayPairs{mouseI}(dpI,1));
    end
    
    %realDayDiffs{mouseI} = diff(realDayPairs{mouseI},1,2);
    
    pooledActiveCellsChangeARM = [pooledActiveCellsChangeARM; activeCellsChangeARM{mouseI}];
    pooledRealDayDiffsARM = [pooledRealDayDiffsARM; realDayDiffs{mouseI}];  
end

[~, ~, cellsActiveFitLineARM, ~,~,~] = fitLinRegSL(pooledActiveCellsChangeARM, pooledRealDayDiffs);
[cellsActiveFvalARM,cellsActivedfNumARM,cellsActivedfDenARM,cellsActivepValARM] = slopeDiffFromZeroFtest(pooledActiveCellsChangeARM,pooledRealDayDiffs);
    
%% Cells coming back across days
pooledActiveStillActive = []; pooledActiveComeBack = []; pooledCellComeBack = [];
for mouseI = 1:numMice
    [~, activeStillActiveFWD{mouseI}, activeStillActiveREV{mouseI}] = GetCellsOverlap(dayUse{mouseI},dayUse{mouseI},splitterPctDayChangesFWD{mouseI}(1).dayPairs);
    [~, activeComeBackFWD{mouseI}, activeComeBackREV{mouseI}] = GetCellsOverlap(dayUse{mouseI},cellSSI{mouseI}>0,splitterPctDayChangesFWD{mouseI}(1).dayPairs);
    [~, cellComeBackFWD{mouseI}, cellComeBackREV{mouseI}] = GetCellsOverlap(cellSSI{mouseI}>0,cellSSI{mouseI}>0,splitterPctDayChangesFWD{mouseI}(1).dayPairs);
    
    pooledActiveStillActive = [pooledActiveStillActive; activeStillActiveFWD{mouseI}];
    pooledActiveComeBack = [pooledActiveComeBack; activeComeBackFWD{mouseI}];
    pooledCellComeBack = [pooledCellComeBack; cellComeBackFWD{mouseI}];
end

[~,~,activeStillActiveFit,~,~,~] = fitLinRegSL(pooledActiveStillActive,pooledDaysApartFWD);
[~,~,activeComeBackFit,~,~,~] = fitLinRegSL(pooledActiveComeBack,pooledDaysApartFWD);
[~,~,cellComeBackFit,~,~,~] = fitLinRegSL(pooledCellComeBack,pooledDaysApartFWD);

dayDiffsHere = unique(pooledDaysApartFWD);
for ddI = 1:length(dayDiffsHere)
    asaMean(ddI,1) = mean(pooledActiveStillActive(pooledDaysApartFWD==dayDiffsHere(ddI)));
    acbMean(ddI,1) = mean(pooledActiveComeBack(pooledDaysApartFWD==dayDiffsHere(ddI)));
    ccbMean(ddI,1) = mean(pooledCellComeBack(pooledDaysApartFWD==dayDiffsHere(ddI)));
end

figure; 
plot(pooledDaysApartFWD-0.15,pooledActiveStillActive,'.b');
hold on
plot(pooledDaysApartFWD,pooledActiveComeBack,'.g');
plot(pooledDaysApartFWD+0.15,pooledCellComeBack,'.r');

plot(activeStillActiveFit(:,1),activeStillActiveFit(:,2),'b')
plot(activeComeBackFit(:,1), activeComeBackFit(:,2),'g')
plot(cellComeBackFit(:,1), cellComeBackFit(:,2),'r')

plot(dayDiffsHere,asaMean,'b')
plot(dayDiffsHere,acbMean,'g')
plot(dayDiffsHere,ccbMean,'r')

ylim([0 1])
title('b = activeStillActive, g = activeComeBack, r = cellComeBack')

%% Cells coming back across conditions


%% Days each cell is this splitter type (persistence/reactivation)
for mouseI = 1:numMice
    daysTrait{mouseI}=cellfun(@(x) sum(x,2),traitGroups{1}{mouseI},'UniformOutput',false);
    activeMoreThanOnce{mouseI} = daysEachCellActive{mouseI};
    activeMoreThanOnce{mouseI}(activeMoreThanOnce{mouseI}==1) = NaN;
    daysTraitOutOfActive{mouseI} = cellfun(@(x) x./activeMoreThanOnce{mouseI},daysTrait{mouseI},'UniformOutput',false);
end

% Splitters shared by days apart, normalized by reactivation
splitterComesBack = cell(numMice,1); splitterComesBackREV = cell(numMice,1); 
splitterStillSplitter = cell(numMice,1); splitterStillSplitterREV = cell(numMice,1); 
cellComesBack = cell(numMice,1); pooledCellComesBack = [];
pooledSplitterComesBackFWD = cell(numTraitGroups,1); pooledSplitterStillSplitterFWD = cell(numTraitGroups,1);
pooledSplitterComesBackREV = cell(numTraitGroups,1); pooledSplitterStillSplitterREV = cell(numTraitGroups,1);
%for clI = 1:2
%    pooledSplitterComesBackFWD{clI} = cell(numTraitGroups,1);
%end
for mouseI = 1:numMice
    %Splitter active at all
    [splitterComesBack{mouseI}] = RunGroupFunction('GetCellsOverlap',traitGroups{1}{mouseI},dayUse{mouseI},splitterPctDayChangesFWD{mouseI}(1).dayPairs);
    [splitterComesBackREV{mouseI}] = RunGroupFunction('GetCellsOverlap',traitGroupsREV{1}{mouseI},dayUseREV{mouseI},splitterPctDayChangesREV{mouseI}(1).dayPairs);
    %Splitter splitter again
    [splitterStillSplitter{mouseI}] = RunGroupFunction('GetCellsOverlap',traitGroups{1}{mouseI},traitGroups{1}{mouseI},splitterPctDayChangesFWD{mouseI}(1).dayPairs);
    [splitterStillSplitterREV{mouseI}] = RunGroupFunction('GetCellsOverlap',traitGroupsREV{1}{mouseI},traitGroupsREV{1}{mouseI},splitterPctDayChangesREV{mouseI}(1).dayPairs);
    
    for tgI = 1:numTraitGroups
         pooledSplitterComesBackFWD{tgI} = [pooledSplitterComesBackFWD{tgI}; splitterComesBack{mouseI}(tgI).overlapWithModel];
         pooledSplitterComesBackREV{tgI} = [pooledSplitterComesBackREV{tgI}; splitterComesBackREV{mouseI}(tgI).overlapWithModel];
         pooledSplitterStillSplitterFWD{tgI} = [pooledSplitterStillSplitterFWD{tgI}; splitterStillSplitter{mouseI}(tgI).overlapWithModel];
         pooledSplitterStillSplitterREV{tgI} = [pooledSplitterStillSplitterREV{tgI}; splitterStillSplitterREV{mouseI}(tgI).overlapWithModel];
    end
    
    %Baseline rate for normalizing
    [~,cellComesBack{mouseI},~] = GetCellsOverlap(dayUse{mouseI},dayUse{mouseI},splitterPctDayChangesFWD{mouseI}(1).dayPairs);
    pooledCellComesBack = [pooledCellComesBack; cellComesBack{mouseI}];
end   

%cellfun(@(x) x./pooledSplitterComesBackFWD,pooledSplitterComesBackFWD,'UniformOutput',false) ????

%Rank sum each day pair for comparison compare regression slopes
FvalSCBslopeFWD = []; pValSCBslopeFWD = []; FvalSCBslopeREV = []; pValSCBslopeREV = [];
FvalSSSslopeFWD = []; pValSSSslopeFWD = []; FvalSSSslopeREV = []; pValSSSslopeREV = [];
for pcI = 1:size(pairsCompareInd,1)  
    %Splitters come back?
    [pValSplitterComesBack{pcI},hValSplitterComesBack{pcI},whichWonSplitterComesBack{pcI},dayPairsSCB{pcI}] =...
                    RankSumAllDaypairs([pooledSplitterComesBackFWD{pairsCompareInd(pcI,1)}; pooledSplitterComesBackREV{pairsCompareInd(pcI,1)}],...
                                       [pooledSplitterComesBackFWD{pairsCompareInd(pcI,2)}; pooledSplitterComesBackREV{pairsCompareInd(pcI,2)}],...
                                       [pooledDaysApartFWD; pooledDaysApartREV]);
                                   
    [FvalSCBslopeFWD{pcI},~,~,pValSCBslopeFWD{pcI}] = TwoSlopeFTest(pooledSplitterComesBackFWD{pairsCompareInd(pcI,1)}, pooledSplitterComesBackFWD{pairsCompareInd(pcI,2)},...
                                            pooledDaysApartFWD, pooledDaysApartFWD);
    [FvalSCBslopeREV{pcI},~,~,pValSCBslopeREV{pcI}] = TwoSlopeFTest(pooledSplitterComesBackREV{pairsCompareInd(pcI,1)}, pooledSplitterComesBackREV{pairsCompareInd(pcI,2)},...
                                            pooledDaysApartREV, pooledDaysApartREV);
    
    %Splitters are still splitters?
    [pValSplitterStillSplitter{pcI},hValSplitterStillSplitter{pcI},whichWonSplitterStillSplitter{pcI},dayPairsSSS{pcI}] =...
                    RankSumAllDaypairs([pooledSplitterStillSplitterFWD{pairsCompareInd(pcI,1)}; pooledSplitterStillSplitterREV{pairsCompareInd(pcI,1)}],...
                                       [pooledSplitterStillSplitterFWD{pairsCompareInd(pcI,2)}; pooledSplitterStillSplitterREV{pairsCompareInd(pcI,2)}],...
                                       [pooledDaysApartFWD; pooledDaysApartREV]);   
                                   
    [FvalSSSslopeFWD{pcI},~,~,pValSSSslopeFWD{pcI}] = TwoSlopeFTest(pooledSplitterStillSplitterFWD{pairsCompareInd(pcI,1)}, pooledSplitterStillSplitterFWD{pairsCompareInd(pcI,2)},...
                                            pooledDaysApartFWD, pooledDaysApartFWD);
    [FvalSSSslopeREV{pcI},~,~,pValSSSslopeREV{pcI}] = TwoSlopeFTest(pooledSplitterStillSplitterREV{pairsCompareInd(pcI,1)}, pooledSplitterStillSplitterREV{pairsCompareInd(pcI,2)},...
                                            pooledDaysApartREV, pooledDaysApartREV);
end

%Regression lines for plotting
for tgI = 1:numTraitGroups
    [splitterCBSlopeFWD(tgI,1), ~, splitterCBFitLineFWD{tgI}, ~,~,~] = fitLinRegSL(pooledSplitterComesBackFWD{tgI}, pooledDaysApartFWD);
    splitterCBFitPlotDaysFWD{tgI} = unique(splitterCBFitLineFWD{1}(:,1));
    [splitterSSSlopeFWD(tgI,1), ~, splitterSSFitLineFWD{tgI}, ~,~,~] = fitLinRegSL(pooledSplitterStillSplitterFWD{tgI}, pooledDaysApartFWD);
    splitterSSFitPlotDaysFWD{tgI} = unique(splitterSSFitLineFWD{1}(:,1));
    for sfpI = 1:length(splitterCBFitPlotDaysFWD{tgI})
        splitterCBFitPlotPctFWD{tgI}(sfpI,1) = splitterCBFitLineFWD{tgI}(find(splitterCBFitLineFWD{tgI}==splitterCBFitPlotDaysFWD{tgI}(sfpI),1,'first'),2);
        splitterSSFitPlotPctFWD{tgI}(sfpI,1) = splitterSSFitLineFWD{tgI}(find(splitterSSFitLineFWD{tgI}==splitterSSFitPlotDaysFWD{tgI}(sfpI),1,'first'),2);
    end
    [splitterCBSlopeREV(tgI,1), ~, splitterCBFitLineREV{tgI}, ~,~,~] = fitLinRegSL(pooledSplitterComesBackREV{tgI}, pooledDaysApartREV);
    splitterCBFitPlotDaysREV{tgI} = unique(splitterCBFitLineREV{1}(:,1));
    [splitterSSSlopeREV(tgI,1), ~, splitterSSFitLineREV{tgI}, ~,~,~] = fitLinRegSL(pooledSplitterStillSplitterREV{tgI}, pooledDaysApartREV);
    splitterSSFitPlotDaysREV{tgI} = unique(splitterSSFitLineREV{1}(:,1)); 
    for sfpI = 1:length(splitterCBFitPlotDaysREV{tgI})
        splitterCBFitPlotPctREV{tgI}(sfpI,1) = splitterCBFitLineREV{tgI}(find(splitterCBFitLineREV{tgI}==splitterCBFitPlotDaysREV{tgI}(sfpI),1,'first'),2);
        splitterSSFitPlotPctREV{tgI}(sfpI,1) = splitterSSFitLineREV{tgI}(find(splitterSSFitLineREV{tgI}==splitterSSFitPlotDaysREV{tgI}(sfpI),1,'first'),2);
    end
end

%Rank sum as a whole
for pcI = 1:size(pairsCompareInd,1)  
    [pValSplitterComesBackAll{pcI},hValSplitterComesBackAll{pcI}] = ...
                    ranksum([pooledSplitterComesBackFWD{pairsCompareInd(pcI,1)}; pooledSplitterComesBackREV{pairsCompareInd(pcI,1)}],...
                            [pooledSplitterComesBackFWD{pairsCompareInd(pcI,2)}; pooledSplitterComesBackREV{pairsCompareInd(pcI,2)}]);
    whichWonSplitterComesBackAll{pcI} =...
                    WhichWonRanks([pooledSplitterComesBackFWD{pairsCompareInd(pcI,1)}; pooledSplitterComesBackREV{pairsCompareInd(pcI,1)}],...
                                  [pooledSplitterComesBackFWD{pairsCompareInd(pcI,2)}; pooledSplitterComesBackREV{pairsCompareInd(pcI,2)}]);
    
    [pValSplitterStillSplitterAll{pcI},hValSplitterStillSplitterAll{pcI}] = ...
                    ranksum([pooledSplitterStillSplitterFWD{pairsCompareInd(pcI,1)}; pooledSplitterStillSplitterREV{pairsCompareInd(pcI,1)}],...
                           [pooledSplitterStillSplitterFWD{pairsCompareInd(pcI,2)}; pooledSplitterStillSplitterREV{pairsCompareInd(pcI,2)}]);
    whichWonSplitterStillSplitterAll{pcI} =...
                    WhichWonRanks([pooledSplitterStillSplitterFWD{pairsCompareInd(pcI,1)}; pooledSplitterStillSplitterREV{pairsCompareInd(pcI,1)}],...
                                  [pooledSplitterStillSplitterFWD{pairsCompareInd(pcI,2)}; pooledSplitterStillSplitterREV{pairsCompareInd(pcI,2)}]);
                              
    %FWD and REV separately
    [pValSplitterComesBackAllFWD{pcI},hValSplitterComesBackAllFWD{pcI}] = ...
                    ranksum(pooledSplitterComesBackFWD{pairsCompareInd(pcI,1)}, pooledSplitterComesBackFWD{pairsCompareInd(pcI,2)});
    whichWonSplitterComesBackAllFWD{pcI} =...
                    WhichWonRanks(pooledSplitterComesBackFWD{pairsCompareInd(pcI,1)}, pooledSplitterComesBackFWD{pairsCompareInd(pcI,2)});
    [pValSplitterComesBackAllREV{pcI},hValSplitterComesBackAllREV{pcI}] = ...
                    ranksum(pooledSplitterComesBackREV{pairsCompareInd(pcI,1)}, pooledSplitterComesBackREV{pairsCompareInd(pcI,2)});
    whichWonSplitterComesBackAllREV{pcI} =...
                    WhichWonRanks(pooledSplitterComesBackREV{pairsCompareInd(pcI,1)}, pooledSplitterComesBackREV{pairsCompareInd(pcI,2)});
                              
    [pValSplitterStillSplitterAllFWD{pcI},hValSplitterStillSplitterAllFWD{pcI}] = ...
                    ranksum(pooledSplitterStillSplitterFWD{pairsCompareInd(pcI,1)}, pooledSplitterStillSplitterFWD{pairsCompareInd(pcI,2)});
    whichWonSplitterStillSplitterAllFWD{pcI} =...
                    WhichWonRanks(pooledSplitterStillSplitterFWD{pairsCompareInd(pcI,1)}, pooledSplitterStillSplitterFWD{pairsCompareInd(pcI,2)});
    [pValSplitterStillSplitterAllREV{pcI},hValSplitterStillSplitterAllREV{pcI}] = ...
                    ranksum(pooledSplitterStillSplitterREV{pairsCompareInd(pcI,1)}, pooledSplitterStillSplitterREV{pairsCompareInd(pcI,2)});
    whichWonSplitterStillSplitterAllREV{pcI} =...
                    WhichWonRanks(pooledSplitterStillSplitterREV{pairsCompareInd(pcI,1)}, pooledSplitterStillSplitterREV{pairsCompareInd(pcI,2)});
end

%Rank sum each self vs. negative day pairs, also slope test
for tgI = 1:numTraitGroups
    [pValSplitCBpvn{tgI},hValCBpvn{tgI},whichWonCBpvn{tgI},dayPairsCBpvn{tgI}] = ...
                    RankSumAllDaypairs(pooledSplitterComesBackFWD{tgI}, pooledSplitterComesBackREV{tgI},pooledDaysApartFWD);
    [pValSplitSSpvn{tgI},hValSSpvn{tgI},whichWonSSpvn{tgI},dayPairsSSpvn{tgI}] = ...
                    RankSumAllDaypairs(pooledSplitterStillSplitterFWD{tgI}, pooledSplitterStillSplitterREV{tgI},pooledDaysApartFWD);
                
    [FWDvREVcbFval{tgI},FWDvREVcbdfNum{tgI},FWDvREVcbdfDen{tgI},FWDvREVcbpVal{tgI}] = TwoSlopeFTest(...
        pooledSplitterComesBackFWD{tgI}, pooledSplitterComesBackREV{tgI}, pooledDaysApartFWD, pooledDaysApartFWD);
    [FWDvREVssFval{tgI},FWDvREVssdfNum{tgI},FWDvREVssdfDen{tgI},FWDvREVsspVal{tgI}] = TwoSlopeFTest(...
        pooledSplitterStillSplitterFWD{tgI}, pooledSplitterStillSplitterREV{tgI}, pooledDaysApartFWD, pooledDaysApartFWD);
end

%Rank sum self vs. negative group as a whole; 
for tgI = 1:numTraitGroups
    [pValSCBall{tgI}, hValSCBall{tgI}] = ranksum(pooledSplitterComesBackFWD{tgI}, pooledSplitterComesBackREV{tgI});
    whichWonSCBall{tgI} = WhichWonRanks(pooledSplitterComesBackFWD{tgI}, pooledSplitterComesBackREV{tgI});
    %[mean(pooledSplitterComesBackFWD{tgI}) mean(pooledSplitterComesBackREV{tgI})]
    [pValSSSall{tgI}, hValSSSall{tgI}] = ranksum(pooledSplitterStillSplitterFWD{tgI},pooledSplitterStillSplitterREV{tgI});
    whichWonSSSall{tgI} = WhichWonRanks(pooledSplitterStillSplitterFWD{tgI}, pooledSplitterStillSplitterREV{tgI});
    
    %Signtest on same day pair? Does that make sense?
end

disp('Done splitter reactivation')

%% Days each cell is this splitter type (persistence/reactivation) ARMS
%{
for mouseI = 1:numMice
    ARMdaysTrait{mouseI}=cellfun(@(x) sum(x,2),traitGroups{2}{mouseI},'UniformOutput',false);
    ARMactiveMoreThanOnce{mouseI} = ARMdaysEachCellActive{mouseI};
    ARMactiveMoreThanOnce{mouseI}(ARMactiveMoreThanOnce{mouseI}==1) = NaN;
    ARMdaysTraitOutOfActive{mouseI} = cellfun(@(x) x./ARMactiveMoreThanOnce{mouseI},ARMdaysTrait{mouseI},'UniformOutput',false);
end
%}
% Splitters shared by days apart, normalized by reactivation
ARMsplitterComesBack = cell(numMice,1); ARMsplitterComesBackREV = cell(numMice,1); 
ARMsplitterStillSplitter = cell(numMice,1); ARMsplitterStillSplitterREV = cell(numMice,1); 
ARMcellComesBack = cell(numMice,1); ARMpooledCellComesBack = [];
ARMpooledSplitterComesBackFWD = cell(length(ARMtraitGroups{1}),1); ARMpooledSplitterStillSplitterFWD = cell(length(ARMtraitGroups{1}),1);
ARMpooledSplitterComesBackREV = cell(length(ARMtraitGroups{1}),1); ARMpooledSplitterStillSplitterREV = cell(length(ARMtraitGroups{1}),1);
for mouseI = 1:numMice
    %Splitter active at all
    [ARMsplitterComesBack{mouseI}] = RunGroupFunction('GetCellsOverlap',traitGroups{2}{mouseI},...
        dayUseArm{mouseI},ARMsplitterPctDayChangesFWD{mouseI}(1).dayPairs);
    [ARMsplitterComesBackREV{mouseI}] = RunGroupFunction('GetCellsOverlap',traitGroupsREV{2}{mouseI},...
        dayUseREV{mouseI},ARMsplitterPctDayChangesREV{mouseI}(1).dayPairs);
    %Splitter splitter again
    [ARMsplitterStillSplitter{mouseI}] = RunGroupFunction('GetCellsOverlap',...
        traitGroups{2}{mouseI},traitGroups{2}{mouseI},ARMsplitterPctDayChangesFWD{mouseI}(1).dayPairs);
    [ARMsplitterStillSplitterREV{mouseI}] = RunGroupFunction('GetCellsOverlap',...
        traitGroupsREV{2}{mouseI},traitGroupsREV{2}{mouseI},ARMsplitterPctDayChangesREV{mouseI}(1).dayPairs);
    
    for tgI = 1:numTraitGroups
         ARMpooledSplitterComesBackFWD{tgI} = [ARMpooledSplitterComesBackFWD{tgI}; ARMsplitterComesBack{mouseI}(tgI).overlapWithModel];
         ARMpooledSplitterComesBackREV{tgI} = [ARMpooledSplitterComesBackREV{tgI}; ARMsplitterComesBackREV{mouseI}(tgI).overlapWithModel];
         ARMpooledSplitterStillSplitterFWD{tgI} = [ARMpooledSplitterStillSplitterFWD{tgI}; ARMsplitterStillSplitter{mouseI}(tgI).overlapWithModel];
         ARMpooledSplitterStillSplitterREV{tgI} = [ARMpooledSplitterStillSplitterREV{tgI}; ARMsplitterStillSplitterREV{mouseI}(tgI).overlapWithModel];
    end
    
    %Baseline rate for normalizing
    [~,ARMcellComesBack{mouseI},~] = GetCellsOverlap(dayUseArm{mouseI},dayUseArm{mouseI},ARMsplitterPctDayChangesFWD{mouseI}(1).dayPairs);
    ARMpooledCellComesBack = [ARMpooledCellComesBack; ARMcellComesBack{mouseI}];
end   

%Rank sum each day pair for comparison compare regression slopes
ARMFvalSCBslopeFWD = []; ARMpValSCBslopeFWD = []; ARMFvalSCBslopeREV = []; ARMpValSCBslopeREV = [];
ARMFvalSSSslopeFWD = []; ARMpValSSSslopeFWD = []; ARMFvalSSSslopeREV = []; ARMpValSSSslopeREV = [];
for pcI = 1:size(pairsCompareInd,1)  
    %Splitters come back?
    [ARMFvalSCBslopeFWD{pcI},~,~,ARMpValSCBslopeFWD{pcI}] = TwoSlopeFTest(ARMpooledSplitterComesBackFWD{pairsCompareInd(pcI,1)}, ARMpooledSplitterComesBackFWD{pairsCompareInd(pcI,2)},...
                                            pooledDaysApartFWD, pooledDaysApartFWD);
    [ARMFvalSCBslopeREV{pcI},~,~,ARMpValSCBslopeREV{pcI}] = TwoSlopeFTest(ARMpooledSplitterComesBackREV{pairsCompareInd(pcI,1)}, ARMpooledSplitterComesBackREV{pairsCompareInd(pcI,2)},...
                                            pooledDaysApartREV, pooledDaysApartREV);
    
    %Splitters are still splitters?
    [ARMFvalSSSslopeFWD{pcI},~,~,ARMpValSSSslopeFWD{pcI}] = TwoSlopeFTest(ARMpooledSplitterStillSplitterFWD{pairsCompareInd(pcI,1)}, ARMpooledSplitterStillSplitterFWD{pairsCompareInd(pcI,2)},...
                                            pooledDaysApartFWD, pooledDaysApartFWD);
    [ARMFvalSSSslopeREV{pcI},~,~,ARMpValSSSslopeREV{pcI}] = TwoSlopeFTest(ARMpooledSplitterStillSplitterREV{pairsCompareInd(pcI,1)}, ARMpooledSplitterStillSplitterREV{pairsCompareInd(pcI,2)},...
                                            pooledDaysApartREV, pooledDaysApartREV);
end

%Regression lines for plotting
for tgI = 1:numTraitGroups
    [ARMsplitterCBSlopeFWD(tgI,1), ~, ARMsplitterCBFitLineFWD{tgI}, ~,~,~] = fitLinRegSL(ARMpooledSplitterComesBackFWD{tgI}, pooledDaysApartFWD);
    ARMsplitterCBFitPlotDaysFWD{tgI} = unique(ARMsplitterCBFitLineFWD{1}(:,1));
    [ARMsplitterSSSlopeFWD(tgI,1), ~, ARMsplitterSSFitLineFWD{tgI}, ~,~,~] = fitLinRegSL(ARMpooledSplitterStillSplitterFWD{tgI}, pooledDaysApartFWD);
    ARMsplitterSSFitPlotDaysFWD{tgI} = unique(ARMsplitterSSFitLineFWD{1}(:,1));
    for sfpI = 1:length(ARMsplitterCBFitPlotDaysFWD{tgI})
        ARMsplitterCBFitPlotPctFWD{tgI}(sfpI,1) = ARMsplitterCBFitLineFWD{tgI}(find(ARMsplitterCBFitLineFWD{tgI}==ARMsplitterCBFitPlotDaysFWD{tgI}(sfpI),1,'first'),2);
        ARMsplitterSSFitPlotPctFWD{tgI}(sfpI,1) = ARMsplitterSSFitLineFWD{tgI}(find(ARMsplitterSSFitLineFWD{tgI}==ARMsplitterSSFitPlotDaysFWD{tgI}(sfpI),1,'first'),2);
    end
    [ARMsplitterCBSlopeREV(tgI,1), ~,ARMsplitterCBFitLineREV{tgI}, ~,~,~] = fitLinRegSL(ARMpooledSplitterComesBackREV{tgI}, pooledDaysApartREV);
    ARMsplitterCBFitPlotDaysREV{tgI} = unique(ARMsplitterCBFitLineREV{1}(:,1));
    [ARMsplitterSSSlopeREV(tgI,1), ~, ARMsplitterSSFitLineREV{tgI}, ~,~,~] = fitLinRegSL(ARMpooledSplitterStillSplitterREV{tgI}, pooledDaysApartREV);
    ARMsplitterSSFitPlotDaysREV{tgI} = unique(ARMsplitterSSFitLineREV{1}(:,1)); 
    for sfpI = 1:length(splitterCBFitPlotDaysREV{tgI})
        ARMsplitterCBFitPlotPctREV{tgI}(sfpI,1) = ARMsplitterCBFitLineREV{tgI}(find(ARMsplitterCBFitLineREV{tgI}==ARMsplitterCBFitPlotDaysREV{tgI}(sfpI),1,'first'),2);
        ARMsplitterSSFitPlotPctREV{tgI}(sfpI,1) = ARMsplitterSSFitLineREV{tgI}(find(ARMsplitterSSFitLineREV{tgI}==ARMsplitterSSFitPlotDaysREV{tgI}(sfpI),1,'first'),2);
    end
end

%Rank sum as a whole
for pcI = 1:size(pairsCompareInd,1)  
    [pValSplitterComesBackAllARM{pcI},hValSplitterComesBackAllARM{pcI}] = ...
                    ranksum([ARMpooledSplitterComesBackFWD{pairsCompareInd(pcI,1)}; ARMpooledSplitterComesBackREV{pairsCompareInd(pcI,1)}],...
                            [ARMpooledSplitterComesBackFWD{pairsCompareInd(pcI,2)}; ARMpooledSplitterComesBackREV{pairsCompareInd(pcI,2)}]);
    whichWonSplitterComesBackAllARM{pcI} =...
                    WhichWonRanks([ARMpooledSplitterComesBackFWD{pairsCompareInd(pcI,1)}; ARMpooledSplitterComesBackREV{pairsCompareInd(pcI,1)}],...
                                  [ARMpooledSplitterComesBackFWD{pairsCompareInd(pcI,2)}; ARMpooledSplitterComesBackREV{pairsCompareInd(pcI,2)}]);
    
    [pValSplitterStillSplitterAllARM{pcI},hValSplitterStillSplitterAllARM{pcI}] = ...
                    ranksum([ARMpooledSplitterStillSplitterFWD{pairsCompareInd(pcI,1)}; ARMpooledSplitterStillSplitterREV{pairsCompareInd(pcI,1)}],...
                            [ARMpooledSplitterStillSplitterFWD{pairsCompareInd(pcI,2)}; ARMpooledSplitterStillSplitterREV{pairsCompareInd(pcI,2)}]);
    whichWonSplitterStillSplitterAllARM{pcI} =...
                    WhichWonRanks([ARMpooledSplitterStillSplitterFWD{pairsCompareInd(pcI,1)}; ARMpooledSplitterStillSplitterREV{pairsCompareInd(pcI,1)}],...
                                  [ARMpooledSplitterStillSplitterFWD{pairsCompareInd(pcI,2)}; ARMpooledSplitterStillSplitterREV{pairsCompareInd(pcI,2)}]);
                              
    %FWD and REV separately
    [pValSplitterComesBackAllFWDARM{pcI},hValSplitterComesBackAllFWDARM{pcI}] = ...
                    ranksum(ARMpooledSplitterComesBackFWD{pairsCompareInd(pcI,1)}, ARMpooledSplitterComesBackFWD{pairsCompareInd(pcI,2)});
    whichWonSplitterComesBackAllFWDARM{pcI} =...
                    WhichWonRanks(ARMpooledSplitterComesBackFWD{pairsCompareInd(pcI,1)}, ARMpooledSplitterComesBackFWD{pairsCompareInd(pcI,2)});
    [pValSplitterComesBackAllREVARM{pcI},hValSplitterComesBackAllREVARM{pcI}] = ...
                    ranksum(ARMpooledSplitterComesBackREV{pairsCompareInd(pcI,1)}, ARMpooledSplitterComesBackREV{pairsCompareInd(pcI,2)});
    whichWonSplitterComesBackAllREVARM{pcI} =...
                    WhichWonRanks(ARMpooledSplitterComesBackREV{pairsCompareInd(pcI,1)}, ARMpooledSplitterComesBackREV{pairsCompareInd(pcI,2)});
                              
    [pValSplitterStillSplitterAllFWDARM{pcI},hValSplitterStillSplitterAllFWDARM{pcI}] = ...
                    ranksum(ARMpooledSplitterStillSplitterFWD{pairsCompareInd(pcI,1)}, ARMpooledSplitterStillSplitterFWD{pairsCompareInd(pcI,2)});
    whichWonSplitterStillSplitterAllFWDARM{pcI} =...
                    WhichWonRanks(ARMpooledSplitterStillSplitterFWD{pairsCompareInd(pcI,1)}, ARMpooledSplitterStillSplitterFWD{pairsCompareInd(pcI,2)});
    [pValSplitterStillSplitterAllREVARM{pcI},hValSplitterStillSplitterAllREVARM{pcI}] = ...
                    ranksum(ARMpooledSplitterStillSplitterREV{pairsCompareInd(pcI,1)}, ARMpooledSplitterStillSplitterREV{pairsCompareInd(pcI,2)});
    whichWonSplitterStillSplitterAllREVARM{pcI} =...
                    WhichWonRanks(ARMpooledSplitterStillSplitterREV{pairsCompareInd(pcI,1)},ARMpooledSplitterStillSplitterREV{pairsCompareInd(pcI,2)});
end
%cellfun(@(x) x./pooledSplitterComesBackFWD,pooledSplitterComesBackFWD,'UniformOutput',false) ????

%Rank sum each self vs. negative day pairs
for tgI = 1:numTraitGroups
    [ARMpValSplitCBpvn{tgI},ARMhValCBpvn{tgI},ARMwhichWonCBpvn{tgI},ARMdayPairsCBpvn{tgI}] = ...
                    RankSumAllDaypairs(ARMpooledSplitterComesBackFWD{tgI}, ARMpooledSplitterComesBackREV{tgI},pooledDaysApartFWD);
    [ARMpValSplitSSpvn{tgI},ARMhValSSpvn{tgI},ARMwhichWonSSpvn{tgI},ARMdayPairsSSpvn{tgI}] = ...
                    RankSumAllDaypairs(ARMpooledSplitterStillSplitterFWD{tgI}, ARMpooledSplitterStillSplitterREV{tgI},pooledDaysApartFWD);
end

%Rank sum each day pair for comparison
for pcI = 1:size(pairsCompareInd,1)  
    [ARMpValSplitterComesBack{pcI},ARMhValSplitterComesBack{pcI},ARMwhichWonSplitterComesBack{pcI},ARMdayPairsSCB{pcI}] =...
                    RankSumAllDaypairs([ARMpooledSplitterComesBackFWD{pairsCompareInd(pcI,1)}; ARMpooledSplitterComesBackREV{pairsCompareInd(pcI,1)}],...
                                       [ARMpooledSplitterComesBackFWD{pairsCompareInd(pcI,2)}; ARMpooledSplitterComesBackREV{pairsCompareInd(pcI,2)}],...
                                       [pooledDaysApartFWD; pooledDaysApartREV]);
                                   
    [ARMpValSplitterStillSplitter{pcI},ARMhValSplitterStillSplitter{pcI},ARMwhichWonSplitterStillSplitter{pcI},ARMdayPairsSSS{pcI}] =...
                    RankSumAllDaypairs([ARMpooledSplitterStillSplitterFWD{pairsCompareInd(pcI,1)}; ARMpooledSplitterStillSplitterREV{pairsCompareInd(pcI,1)}],...
                                       [ARMpooledSplitterStillSplitterFWD{pairsCompareInd(pcI,2)}; ARMpooledSplitterStillSplitterREV{pairsCompareInd(pcI,2)}],...
                                       [pooledDaysApartFWD; pooledDaysApartREV]);    
                                   
    
end

%Rank sum group as a whole
for tgI = 1:length(ARMtraitGroups{1})
    [ARMpValSCBall{tgI}, ARMhValSCBall{tgI}] = ranksum(ARMpooledSplitterComesBackFWD{tgI},ARMpooledSplitterComesBackREV{tgI});
    [~,ARMwhichWonSCBall{tgI}] = max([mean(ARMpooledSplitterComesBackFWD{tgI}) mean(ARMpooledSplitterComesBackREV{tgI})]);
    %[mean(pooledSplitterComesBackFWD{tgI}) mean(pooledSplitterComesBackREV{tgI})]
    [ARMpValSSSall{tgI}, ARMhValSSSall{tgI}] = ranksum(ARMpooledSplitterStillSplitterFWD{tgI},ARMpooledSplitterStillSplitterREV{tgI});
    [~,ARMwhichWonSSSall{tgI}] = max([mean(ARMpooledSplitterStillSplitterFWD{tgI}) mean(ARMpooledSplitterStillSplitterREV{tgI})]);
end

%F test, slopes, etc. 

%Compare LR with LR only, ST with ST only

disp('Done ARM splitter reactivation')

%% Cell Turning into other types
transInds = [ 5 6; 6 5; 1 3; 1 4; 3 1; 4 1; 2 4; 2 3; 4 2; 3 2; 8 6; 8 5]; 

for mouseI = 1:numMice
    cellTransTraits{mouseI} = {splittersBOTH{mouseI}, splittersOne{mouseI};...
                               splittersOne{mouseI}, splittersBOTH{mouseI};...
                               splittersLR{mouseI}, splittersLRonly{mouseI};...
                               splittersLR{mouseI}, splittersSTonly{mouseI};...
                               splittersLRonly{mouseI}, splittersLR{mouseI};...
                               splittersSTonly{mouseI}, splittersLR{mouseI};...
                               splittersST{mouseI}, splittersSTonly{mouseI};...
                               splittersST{mouseI}, splittersLRonly{mouseI};...
                               splittersSTonly{mouseI}, splittersST{mouseI};...
                               splittersLRonly{mouseI}, splittersST{mouseI};...
                               splittersNone{mouseI}, splittersOne{mouseI};...
                               splittersNone{mouseI}, splittersBOTH{mouseI}};
                           
    cellTransTraitsREV{mouseI} = cellfun(@fliplr,cellTransTraits{mouseI},'UniformOutput',false);
    %Need all that realignment stuff to get this in the right order
end
   
transLabels = traitLabels(transInds);
pooledSplitterChanges = cell(size(cellTransTraits{mouseI},1),1);
for mouseI = 1:numMice    
    [splitterChanges{mouseI}] = RunGroupFunction('GetCellsOverlap',cellTransTraits{mouseI}(:,1),cellTransTraits{mouseI}(:,2),dayPairs{mouseI});    
    for ctI = 1:size(cellTransTraits{mouseI},1)    
        pooledSplitterChanges{ctI} = [pooledSplitterChanges{ctI}; splitterChanges{mouseI}(ctI).overlapWithModel];
    end
    
    
end


%% New cells: what types?
%First day each splitter type
%{
pooledFirstDays = cell(numTraitGroups,1);
for mouseI = 1:numMice
    firstDays{mouseI} = RunGroupFunction('GetFirstDayTrait',traitGroups{1}{mouseI},[]);
    
    for tgI = 1:numTraitGroups
        pooledFirstDays{tgI} = [pooledFirstDays{tgI}; firstDays{mouseI}(tgI).firstDay];
    end
    
end
%}
propChecks = {[1 2 8]; [3 4]; [5 6 8]};
%Left/right %Left/right only %One/both/none
%figure;
pooledNewCellPropChanges = cell(numTraitGroups,1);
traitFirstDiffsPooledChanges = cell(size(pairsCompareInd,1),1);
traitFirstDiffsPooled = cell(size(pairsCompareInd,1),1);
for mouseI = 1:numMice
    %firstDays{mouseI} = GetFirstDayTrait(cellSSI{mouseI}>0);
    firstDays{mouseI} = GetFirstDayTrait(dayUse{mouseI});
    %firstDays{mouseI} = GetFirstDayTrait(sum(trialReli{mouseI},3)>0);
    
    firstDayLogical{mouseI} = false(size(cellSSI{mouseI}));
    for cellI = 1:size(cellSSI{mouseI},1)
        if ~isnan(firstDays{mouseI}(cellI))
        firstDayLogical{mouseI}(cellI,firstDays{mouseI}(cellI)) = true;
        firstDayNums{mouseI} = sum(firstDayLogical{mouseI},1);
        end
    end
    
    for tgI = 1:numTraitGroups
        traitFirst{mouseI}{tgI} = traitGroups{1}{mouseI}{tgI}.*firstDayLogical{mouseI};
        traitFirstNums{mouseI}{tgI} = sum(traitFirst{mouseI}{tgI},1);
        
        traitFirstPcts{mouseI}{tgI} = traitFirstNums{mouseI}{tgI}./ firstDayNums{mouseI};
        [newCellChanges{mouseI}{tgI},~] = TraitChangeDayPairs(traitFirstPcts{mouseI}{tgI},compDayPairsFWD{mouseI});
        
        pooledNewCellPropChanges{tgI} = [pooledNewCellPropChanges{tgI}; newCellChanges{mouseI}{tgI}(:)];
        fitLinRegSL(pooledNewCellPropChanges{tgI},pooledDaysApartFWD);
    end
    
    
    %{
    for tgI = 1:8
        subplot(2,4,tgI)
        plot(traitFirstPcts{mouseI}{tgI})
            hold on
        title(traitLabels{tgI})
        %ylim([0 0.2])
        ylim([0 1])
    end
    %}
    for pcI = 1:size(pairsCompareInd,1)
        traitFirstDiffs{mouseI}{pcI} = traitFirstPcts{mouseI}{pairsCompareInd(pcI,2)} - traitFirstPcts{mouseI}{pairsCompareInd(pcI,1)};
        [traitFirstDiffsChanges{mouseI}{pcI},~] = TraitChangeDayPairs(traitFirstDiffs{mouseI}{pcI},compDayPairsFWD{mouseI});
        
        traitFirstDiffsPooled{pcI} = [traitFirstDiffsPooled{pcI}; traitFirstDiffs{mouseI}{pcI}(:)];
        traitFirstDiffsPooledChanges{pcI} = [traitFirstDiffsPooledChanges{pcI}; traitFirstDiffsChanges{mouseI}{pcI}(:)];
    end
    
    
end

for pcI = 1:size(pairsCompareInd,1)
   [~,~,~,newCellsSlopeDiffpVal{pcI}] = TwoSlopeFTest(pooledNewCellPropChanges{pairsCompareInd(pcI,2)},pooledNewCellPropChanges{pairsCompareInd(pcI,1)},...
       pooledDaysApartFWD,pooledDaysApartFWD);
end
for tgI = 1:numTraitGroups
    [~,~,newCellFit{tgI},~,~,~] = fitLinRegSL(pooledNewCellPropChanges{tgI},pooledDaysApartFWD);
end


%% Comparisons of some stuff from center stem and arms



%% STEM vs. ARM props
for tgI = 1:numTraitGroups
    [pSvAsplitPropDiffs{tgI}, hSvAsplitPropDiffs{tgI}] = signtest(pooledSplitProp{tgI} - ARMpooledSplitProp{tgI});
end

%% Overlap in both
pctTraitBothPooled = cell(numTraitGroups,1);
for mouseI = 1:numMice
    activeARMandSTEM{mouseI} = dayUse{mouseI} + dayUseArm{mouseI}==2;
    pctActiveBoth{mouseI} = sum(activeARMandSTEM{mouseI},1) / size(dayUse{mouseI},1);
    
    for tgI = 1:numTraitGroups
        traitARMandSTEM{mouseI}{tgI} = traitGroups{1}{mouseI}{tgI} + traitGroups{2}{mouseI}{tgI}==2;
        pctTraitBoth{mouseI}{tgI} = sum(traitARMandSTEM{mouseI}{tgI},1) / size(dayUse{mouseI},1);
        pctTraitBothPooled{tgI} = [pctTraitBothPooled{tgI}; pctTraitBoth{mouseI}{tgI}(:)];
    end
end




%% Pop vector corr differences by cells included

pooledCondPairs = condPairs;
poolLabels = {'Left','Right','Study','Test'};
condSet = {[1:4]; [5 6]; [7 8]};
condSetComps = [1 2; 1 3; 2 3];
condSetLabels = {'VS Self', 'Left vs. Right', 'Study vs. Test'}; csLabelsShort = {'VSelf','LvR','SvT'};
condSetColors = {'b' 'r' 'g'};
for cscI = 1:size(condSetComps,1)
    cscLabels{cscI} = [csLabelsShort{condSetComps(cscI,1)} ' - ' csLabelsShort{condSetComps(cscI,2)}];
end
condSetInds = [1*ones(length(condSet{1}),1); 2*ones(length(condSet{2}),1); 3*ones(length(condSet{3}),1)];
pooledCompPairs = {[1 1]; [2 2]; [3 3]; [4 4]; [1 2]; [2 1]; [3 4]; [4 3]}; %PFs from half tmap1/2 to use

%Set up different trait logicals
traitLogical = threshAndConsec;
pooledTraitLogicalA = [];
for mouseI = 1:numMice; for cc = 1:size(pooledCondPairs,1)
        pooledTraitLogicalA{mouseI}(:,:,cc) = sum(traitLogical{mouseI}(:,:,pooledCondPairs(cc,:)),3) > 0;
end; end

traitLogical = trialReli;
pooledTraitLogicalB = [];
for mouseI = 1:numMice; for cc = 1:size(pooledCondPairs,1)
        pooledTraitLogicalB{mouseI}(:,:,cc) = sum(traitLogical{mouseI}(:,:,pooledCondPairs(cc,:)),3) > 0;
end; end
pooledTraitLogicalC = cellfun(@(x) repmat(x>0,1,1,4),cellSSI,'UniformOutput',false);

pvNames = {'aboveThreshEither',       'includeSilent',       'activeBoth',     'firesEither',       'cellPresentBoth', 'cellPresentEither'};
traitLogUse = {pooledTraitLogicalA, pooledTraitLogicalA, pooledTraitLogicalB, pooledTraitLogicalB, pooledTraitLogicalC, pooledTraitLogicalC};
cellsUseAll = {'activeEither',        'includeSilent',    'activeBoth',       'activeEither',        'activeBoth',       'activeEither'};


%Make (or check for) PV corrs
for pvtI = 1:length(pvNames)
    for mouseI = 1:numMice
        pvBasicFile = fullfile(mainFolder,mice{mouseI},'corrs',['basic_corrs_' pvNames{pvtI} '.mat']);
        %Make the pv corrs
        if exist(pvBasicFile,'file') == 0
            disp(['Did not find basic corrs ' pvNames{pvtI} ' for mouse ' num2str(mouseI) ', making it now'])
            [tpvCorrs, tmeanCorr, ~, ~, ~, ~, tPVdayPairs]=...
                MakePVcorrsWrapper2(cellTBT{mouseI}, [], [], 0, pooledCompPairs,...
                pooledCondPairs, poolLabels, traitLogUse{pvtI}{mouseI}, stemBinEdges, minspeed,cellsUseAll{pvtI});
            save(pvBasicFile,'tpvCorrs','tmeanCorr','tPVdayPairs','pooledCompPairs')
        end
    end
end

for pvtI = 1:length(pvNames)
    for mouseI = 1:numMice
        pvBasicFile = fullfile(mainFolder,mice{mouseI},'corrs',['basic_corrs_' pvNames{pvtI} '.mat']);

        load(pvBasicFile)

        pvCorrs{pvtI}{mouseI} = tpvCorrs;
        meanCorr{pvtI}{mouseI} = cell2mat(tmeanCorr);
        PVdayPairs{pvtI}{mouseI} = tPVdayPairs;
        PVdayPairs{pvtI}{mouseI} = cellRealDays{mouseI}(PVdayPairs{pvtI}{mouseI});
        PVdaysApart{pvtI}{mouseI} = diff(PVdayPairs{pvtI}{mouseI},[],2);

        %meanCorrHalfFirst{pvtI}{mouseI} = cell2mat(cellfun(@(x) mean(x(:,1:numBins/2),2),tpvCorrs,'UniformOutput',false));
        %meanCorrHalfSecond{pvtI}{mouseI} = cell2mat(cellfun(@(x) mean(x(:,numBins/2+1:numBins),2),tpvCorrs,'UniformOutput',false));
        meanCorrHalfFirst{pvtI}{mouseI} = cell2mat(cellfun(@(x) mean(x(:,1:2),2),tpvCorrs,'UniformOutput',false));
        meanCorrHalfSecond{pvtI}{mouseI} = cell2mat(cellfun(@(x) mean(x(:,numBins-1:numBins),2),tpvCorrs,'UniformOutput',false));

        disp(['Done basic corrs ' pvNames{pvtI} ' for mouse ' num2str(mouseI)])
    end
    
    %Pool Corrs across mice
    pooledPVcorrs{pvtI} = PoolCorrsAcrossMice(pvCorrs{pvtI});
    pooledMeanPVcorrs{pvtI} = PoolCorrsAcrossMice(meanCorr{pvtI});
    pooledMeanPVcorrsHalfFirst{pvtI} = PoolCorrsAcrossMice(meanCorrHalfFirst{pvtI});
    pooledMeanPVcorrsHalfSecond{pvtI} = PoolCorrsAcrossMice(meanCorrHalfSecond{pvtI});

    pooledPVdayPairsTemp{pvtI} = PoolCorrsAcrossMice(PVdayPairs{pvtI});
    pooledPVdayPairs{pvtI} = [pooledPVdayPairsTemp{pvtI}{1} pooledPVdayPairsTemp{pvtI}{2}];
    %pooledPVDaysApart{pvtI} = cellfun(@(x) abs(diff(x,[],2)),pooledPVdayPairs{pvtI},'UniformOutput',false);
    pooledPVDaysApart{pvtI} = abs(diff(pooledPVdayPairs{pvtI},[],2));
    
    %Pool by condset
    CSpooledPVcorrs{pvtI} = PoolCellArr(pooledPVcorrs{pvtI},condSet);
    CSpooledMeanPVcorrs{pvtI} = PoolCellArr(pooledMeanPVcorrs{pvtI},condSet);
    CSpooledMeanPVcorrsHalfFirst{pvtI} = PoolCellArr(pooledMeanPVcorrsHalfFirst{pvtI},condSet);
    CSpooledMeanPVcorrsHalfSecond{pvtI} = PoolCellArr(pooledMeanPVcorrsHalfSecond{pvtI},condSet);

    %CSpooledPVdaysApart{pvtI} = PoolCellArr(pooledPVDaysApart{pvtI},condSet);
    CSpooledPVdaysApart{pvtI} = cellfun(@(x) repmat(pooledPVDaysApart{pvtI},length(x),1),condSet,'UniformOutput',false);
end

%Change of each corr over time
sameDayDayDiffsPooled = cell(length(pvNames),1);
for pvtI = 1:length(pvNames)
    for mouseI = 1:numMice
        sameDayDayDiffsPooled{pvtI} = [sameDayDayDiffsPooled{pvtI}; realDayDiffs{mouseI}];
    end
    
    [withinCSdayChangeMean{pvtI},cscDiffsChangeMeanPooled{pvtI},sameDayCompsPooled{pvtI}] = CorrChangeOverDays(meanCorr{pvtI},PVdayPairs{pvtI},dayPairs,condSet,condSetComps);
    [withinCSdayChangeMeanHalfFirst{pvtI},cscDiffsChangeMeanHalfFirstPooled{pvtI},~] = CorrChangeOverDays(meanCorrHalfFirst{pvtI},PVdayPairs{pvtI},dayPairs,condSet,condSetComps);
    [withinCSdayChangeMeanHalfSecond{pvtI},cscDiffsChangeMeanHalfSecondPooled{pvtI},~] = CorrChangeOverDays(meanCorrHalfSecond{pvtI},PVdayPairs{pvtI},dayPairs,condSet,condSetComps);
end

%% Pop vector corr differences by cells included ARMS

pooledCondPairs = condPairs;
poolLabels = {'Left','Right','Study','Test'};
condSet = {[1:4]; [5 6]; [7 8]};
condSetComps = [1 2; 1 3; 2 3];
condSetLabels = {'VS Self', 'Left vs. Right', 'Study vs. Test'}; csLabelsShort = {'VSelf','LvR','SvT'};
condSetInds = [1*ones(length(condSet{1}),1); 2*ones(length(condSet{2}),1); 3*ones(length(condSet{3}),1)];
pooledCompPairs = {[1 1]; [2 2]; [3 3]; [4 4]; [1 2]; [2 1]; [3 4]; [4 3]}; %PFs from half tmap1/2 to use

%Set up different trait logicals
traitLogical = threshAndConsecArm;
pooledTraitLogicalA = [];
for mouseI = 1:numMice; for cc = 1:size(pooledCondPairs,1)
        pooledTraitLogicalA{mouseI}(:,:,cc) = sum(traitLogical{mouseI}(:,:,pooledCondPairs(cc,:)),3) > 0;
end; end

traitLogical = trialReliArm;
pooledTraitLogicalB = [];
for mouseI = 1:numMice; for cc = 1:size(pooledCondPairs,1)
        pooledTraitLogicalB{mouseI}(:,:,cc) = sum(traitLogical{mouseI}(:,:,pooledCondPairs(cc,:)),3) > 0;
end; end

pooledTraitLogicalC = cellfun(@(x) repmat(x>0,1,1,4),cellSSI,'UniformOutput',false);

pvNames = {'aboveThreshEither',       'includeSilent',       'activeBoth',     'firesEither',       'cellPresentBoth', 'cellPresentEither'};
traitLogUse = {pooledTraitLogicalA, pooledTraitLogicalA, pooledTraitLogicalB, pooledTraitLogicalB, pooledTraitLogicalC, pooledTraitLogicalC};
cellsUseAll = {'activeEither',        'includeSilent',    'activeBoth',       'activeEither',        'activeBoth',       'activeEither'};


%Make (or check for) PV corrs
for pvtI = 1:length(pvNames)
    for mouseI = 1:numMice
        pvBasicFile = fullfile(mainFolder,mice{mouseI},'corrs',['ARMbasic_corrs_' pvNames{pvtI} '.mat']);
        %Make the pv corrs
        if exist(pvBasicFile,'file') == 0
            disp(['Did not find basic corrs ' pvNames{pvtI} ' for mouse ' num2str(mouseI) ', making it now'])
            [tpvCorrs, tmeanCorr, ~, ~, ~, ~, tPVdayPairs]=...
                MakePVcorrsWrapper2(cellTBTarm{mouseI}, [], [], 0, pooledCompPairs,...
                pooledCondPairs, poolLabels, traitLogUse{pvtI}{mouseI}, armBinEdges, minspeed, cellsUseAll{pvtI});
            save(pvBasicFile,'tpvCorrs','tmeanCorr','tPVdayPairs','pooledCompPairs')
        end
    end
end

for pvtI = 1:length(pvNames)
    for mouseI = 1:numMice
        pvBasicFile = fullfile(mainFolder,mice{mouseI},'corrs',['ARMbasic_corrs_' pvNames{pvtI} '.mat']);

        load(pvBasicFile)
        
        ARMpvCorrs{pvtI}{mouseI} = cellfun(@fliplr,tpvCorrs,'UniformOutput',false);
        ARMmeanCorr{pvtI}{mouseI} = cell2mat(tmeanCorr);

        ARMmeanCorrHalfFirst{pvtI}{mouseI} = cell2mat(cellfun(@(x) mean(x(:,1:numBins/2),2),ARMpvCorrs{pvtI}{mouseI},'UniformOutput',false));
        ARMmeanCorrHalfSecond{pvtI}{mouseI} = cell2mat(cellfun(@(x) mean(x(:,numBins/2+1:numBins),2),ARMpvCorrs{pvtI}{mouseI},'UniformOutput',false));

        disp(['Done basic corrs ' pvNames{pvtI} ' for mouse ' num2str(mouseI)])
    end
    
    %Pool Corrs across mice
    ARMpooledPVcorrs{pvtI} = PoolCorrsAcrossMice(ARMpvCorrs{pvtI});
    ARMpooledMeanPVcorrs{pvtI} = PoolCorrsAcrossMice(ARMmeanCorr{pvtI});
    ARMpooledMeanPVcorrsHalfFirst{pvtI} = PoolCorrsAcrossMice(ARMmeanCorrHalfFirst{pvtI});
    ARMpooledMeanPVcorrsHalfSecond{pvtI} = PoolCorrsAcrossMice(ARMmeanCorrHalfSecond{pvtI});
    
    %Pool by condset
    CSpooledPVcorrsARM{pvtI} = PoolCellArr(ARMpooledPVcorrs{pvtI},condSet);
    CSpooledMeanPVcorrsARM{pvtI} = PoolCellArr(ARMpooledMeanPVcorrs{pvtI},condSet);
    CSpooledMeanPVcorrsHalfFirstARM{pvtI} = PoolCellArr(ARMpooledMeanPVcorrsHalfFirst{pvtI},condSet);
    CSpooledMeanPVcorrsHalfSecondARM{pvtI} = PoolCellArr(ARMpooledMeanPVcorrsHalfSecond{pvtI},condSet);
end

%Change of each corr over time
for pvtI = 1:length(pvNames)
    [withinCSdayChangeMeanARM{pvtI},cscDiffsChangeMeanPooledARM{pvtI},sameDayCompsPooledARM{pvtI}] = CorrChangeOverDays(ARMmeanCorr{pvtI},PVdayPairs{pvtI},dayPairs,condSet,condSetComps);
    [withinCSdayChangeMeanHalfFirstARM{pvtI},cscDiffsChangeMeanHalfFirstPooledARM{pvtI},~] = CorrChangeOverDays(ARMmeanCorrHalfFirst{pvtI},PVdayPairs{pvtI},dayPairs,condSet,condSetComps);
    [withinCSdayChangeMeanHalfSecondARM{pvtI},cscDiffsChangeMeanHalfSecondPooledARM{pvtI},~] = CorrChangeOverDays(ARMmeanCorrHalfSecond{pvtI},PVdayPairs{pvtI},dayPairs,condSet,condSetComps);
end


%% Decoder analysis
numShuffles = 100;
numDownsamples = 100;

decodingType = {'allCells', 'threshCells'};
fileName = {'All','Thresh'};
traitLogUse = {cellfun(@(x) x>0,cellSSI,'UniformOutput',false), dayUse};

regDecoding = []; DSdecoding = [];
%decodingResults = cell(numMice,1); shuffledResults = cell(numMice,1); sessPairs = cell(numMice,1);
for dtI = 1:length(decodingType)
for mouseI = 1:numMice
    
    dcFileName = fullfile(mainFolder,mice{mouseI},'decoding',['decoding' fileName{dtI} '.mat']);
    if exist(dcFileName,'file')==0
        disp(['Running decoding ' decodingType{dtI} ' for mouse ' num2str(mouseI)])
    tic
    [decodingResults, shuffledResults, testConds, titles, sessPairs] =...
        DecoderWrapper3(cellTBT{mouseI},traitLogUse{dtI}{mouseI},numShuffles,'transientDur','pooled','bayes'); %#ok<ASGLU>
    toc
    save(dcFileName,'decodingResults', 'shuffledResults', 'testConds', 'titles', 'sessPairs')
    clear('decodingResults', 'shuffledResults', 'testConds', 'titles', 'sessPairs')
    end
    
    regDecoding{dtI}{mouseI} = load(dcFileName);
  %}
    dsdcFileName = fullfile(mainFolder,mice{mouseI},'decoding',['DSdecoding' fileName{dtI} '.mat']);
    if exist(dsdcFileName,'file')==0
        disp(['Running downsampled decoding ' decodingType{dtI} ' for mouse ' num2str(mouseI)])
    tic
    [DSdecodingResults, DSdownsampledResults, DStestConds, DStitles, DSsessPairs, cellDownsamples] =...
        DecoderWrapper3downsampling(cellTBT{mouseI},traitLogUse{dtI}{mouseI},numDownsamples,'transientDur','pooled','bayes');
    toc
    save(dsdcFileName,'DSdecodingResults', 'DSdownsampledResults', 'DStestConds', 'DStitles', 'DSsessPairs', 'cellDownsamples')
    clear('DSdecodingResults', 'DSdownsampledResults', 'DStestConds', 'DStitles', 'DSsessPairs', 'cellDownsamples')
    end
    
    DSdecoding{dtI}{mouseI} = load(dsdcFileName);
    
    disp(['Done getting/loading ' decodingType{dtI} ' decoding for mouse ' num2str(mouseI)])
end
end

%cellDownsamples{dtI}{mouseI} = GetDownsampleCellCombs(traitLogUse{dtI}{mouseI},regDecoding{dtI}{mouseI}.sessPairs,numDownsamples);

%Layout:
%decodingResults{decodingType}{mouse}.decodingResults.correctPct{1,dimDecoded}(sessPairI,condDecoding)

decodingResults = []; shuffledResults = []; decodedWell = [];
downsampledResults = []; DSshuffledResults = []; decodeOutofDS = [];

for dtI = 1:length(decodingType)
    dimsDecoded = regDecoding{dtI}{1}.titles;
    for ddI = 1:length(dimsDecoded)
        for mouseI = 1:numMice
            %Pool wihtin sesspairs
            decodingResults{dtI}{ddI}{mouseI} = PoolCorrectIndivDecoding(regDecoding{dtI}{mouseI}.decodingResults.correctIndiv{ddI});
            shuffledResults{dtI}{ddI}{mouseI} = PoolCorrectIndivDecodingShuffles(regDecoding{dtI}{mouseI}.shuffledResults.correctIndiv(:,ddI));
            %DSdecodingResults
            downsampledResults{dtI}{ddI}{mouseI} = PoolCorrectIndivDecodingShuffles(DSdecoding{dtI}{mouseI}.DSdownsampledResults.correctIndiv(:,ddI));
            
            %Process results relative to chance
            decodedWell{dtI}{ddI}{mouseI} = EvaluateDecodingPerformance(decodingResults{dtI}{ddI}{mouseI},shuffledResults{dtI}{ddI}{mouseI},pThresh);
            sessPairs{dtI}{ddI}{mouseI} = cellRealDays{mouseI}(regDecoding{dtI}{mouseI}.sessPairs);
            
            %Downsampled evaluation
            decodeOutofDS{dtI}{ddI}{mouseI} = EvaluateDecodingPerformance(decodingResults{dtI}{ddI}{mouseI},downsampledResults{dtI}{ddI}{mouseI},pThresh);
            [decodingAboveDSrate{dtI}{ddI}{mouseI}, DSbetterThanShuff{dtI}{ddI}{mouseI}, DSaboveShuffP{dtI}{ddI}{mouseI}, meanDSperformance{dtI}{ddI}{mouseI}] =...
                EvaluateDownsampledDecodingPerformance(decodingResults{dtI}{ddI}{mouseI},downsampledResults{dtI}{ddI}{mouseI},...
                shuffledResults{dtI}{ddI}{mouseI},DSdecoding{dtI}{mouseI}.cellDownsamples,pThresh);
       

        end

        %Pool across mice
        decodingResultsPooled{dtI}{ddI} = PoolCellArrAcrossMice(decodingResults{dtI}{ddI});
        shuffledResultsPooled{dtI}{ddI} = PoolCellArrAcrossMice(shuffledResults{dtI}{ddI});
        downsampledResultsPooled{dtI}{ddI} = PoolCellArrAcrossMice(downsampledResults{dtI}{ddI});
        decodedWellPooled{dtI}{ddI} = PoolCellArrAcrossMice(decodedWell{dtI}{ddI});
        decodeOutofDSpooled{dtI}{ddI} = PoolCellArrAcrossMice(decodeOutofDS{dtI}{ddI});
        decodeAboveDSratePooled{dtI}{ddI} = PoolCellArrAcrossMice(decodingAboveDSrate{dtI}{ddI});
        DSmeanDayPairPerfPooled{dtI}{ddI} = PoolCellArrAcrossMice(meanDSperformance{dtI}{ddI});      
        DSbetterThanShuffPooled{dtI}{ddI} = PoolCellArrAcrossMice(DSbetterThanShuff{dtI}{ddI});
        DSaboveShuffPpooled{dtI}{ddI} = PoolCellArrAcrossMice(DSaboveShuffP{dtI}{ddI});
        
        sessPairsPooled{dtI}{ddI} = PoolCellArrAcrossMice(sessPairs{dtI}{ddI});
        sessDayDiffs{dtI}{ddI} = diff(sessPairsPooled{dtI}{ddI},1,2);
        
        %These work a little bit differently, need to work on them
        %DSdecodeAboveShuff{dtI}{ddI} = PoolCellArrAcrossMice(DSbetterThanShuff{dtI}{ddI});
        %DSaboveShuffP{dtI}{dtI} = PoolCellArrAcrossMice(DSaboveShuffP{dtI}{ddI});
    end
end



%% PV shuffles

%Shuffle dimensions only
tic
numPerms = 1000
pooledCompPairs = {[1 2], [2 1]; [3 4], [4 3]}; 
pooledShuffleDim = {'leftright'; 'studytest'};
%pvCorrs = cell(numMice,1); numCellsUsed = cell(numMice,1); numNans = cell(numMice,1); meanCorr = cell(numMice,1);
for mouseI = 1:numMice
    shuffleWhat = 'dimOnly';
    %shuffleWhat = 'dayOnly';
    tic
    for sdI = 1:length(pooledShuffleDim)
        %Make the pv corrs
        compPairsHere = pooledCompPairs(sdI,:);
        shuffleDimHere = pooledShuffleDim{sdI};
        [pvCorrs, meanCorr, numCellsUsed, numNans, shuffPVcorrs, shuffMeanCorr, PVdayPairs]=...
        MakePVcorrsWrapper2(cellTBT{mouseI}, shuffleWhat, shuffleDimHere, numPerms, compPairsHere,...
                           pooledCondPairs, poolLabels, pooledTraitLogical{mouseI}, stemBinEdges, minspeed);
            save(fullfile(mainFolder,mice{mouseI},'corrs',[pooledShuffleDim{sdI} '_corrs.mat']),'pvCorrs','meanCorr',...
                'numCellsUsed','numNans','shuffPVcorrs','shuffMeanCorr','PVdayPairs','compPairsHere','shuffleDimHere')
    
    %Do some processing
    %[meanCorrOutOfShuff{mouseI},pvCorrsOutOfShuff{mouseI},meanCorrsOutShuff{mouseI},numCorrsOutShuff{mouseI},corrsOutCOM{mouseI},lims95] =...
    %      ProcessPVcorrs(numPerms,pThresh,shuffMeanCorr{mouseI},meanCorr{mouseI},shuffPVcorrs{mouseI},pvCorrs{mouseI});
    disp(['Done making shuffled corrs *' shuffleWhat '*, *' shuffleDimHere '*, for mouse ' num2str(mouseI)])
    end
    toc
end
toc
save(fullfile(mainFolder,'dimCorrs.mat'),'pvCorrs','meanCorr','numCellsUsed','numNans','shuffPVcorrs','shuffMeanCorr','PVdayPairs',...
            'meanCorrOutOfShuff','pvCorrsOutOfShuff','meanCorrsOutShuff','numCorrsOutShuff','corrsOutCOM','lims95')
        
%Pool across animals
[pooledMeanCorr,pooledMeanCorrOutofShuff,pooledPVcorrs,pooledPVcorrsOutShuff,...
          pooledMeanPVcorrsOutShuff,pooledNumPVcorrsOutShuff,pooledCorrsOutCOM,pooledPVdayDiffs] =...
          PoolProcessedPVcorrs(pooledCompPairs,meanCorr,meanCorrOutOfShuff,pvCorrs,pvCorrsOutOfShuff,...
          meanCorrsOutShuff,numCorrsOutShuff,corrsOutCOM,PVdayPairs);



%Shuffle days only
tic
pooledCompPairs = [1 1; 2 2; 3 3; 4 4; 1 2; 2 1; 3 4; 4 3];
pooledShuffleDim = {'leftright', 'leftright', 'studytest','studytest'};
pvCorrs = cell(numMice,1); numCellsUsed = cell(numMice,1); numNans = cell(numMice,1); meanCorr = cell(numMice,1);
parfor mouseI = 1:numMice
    shuffleWhat = 'dayOnly';
    %Make the pv corrs
    [pvCorrs{mouseI}, meanCorr{mouseI}, numCellsUsed{mouseI}, numNans{mouseI}, shuffPVcorrs{mouseI}, shuffMeanCorr{mouseI}, PVdayPairs{mouseI}]=...
    MakePVcorrsWrapper(cellTBT{mouseI}, shuffleWhat, numPerms, pooledCompPairs, pooledShuffleDim,...
                       pooledCondPairs, poolLabels, pooledTraitLogical{mouseI}, xlims, cmperbin, minspeed);
    %Do some processing
    [meanCorrOutOfShuff{mouseI},pvCorrsOutOfShuff{mouseI},meanCorrsOutShuff{mouseI},numCorrsOutShuff{mouseI},corrsOutCOM{mouseI},lims95] =...
          ProcessPVcorrs(numPerms,pThresh,shuffMeanCorr{mouseI},meanCorr{mouseI},shuffPVcorrs{mouseI},pvCorrs{mouseI});
end
toc
save(fullfile(mainFolder,'dayCorrs.mat'),'pvCorrs','meanCorr','numCellsUsed','numNans','shuffPVcorrs','shuffMeanCorr','PVdayPairs',...
            'meanCorrOutOfShuff','pvCorrsOutOfShuff','meanCorrsOutShuff','numCorrsOutShuff','corrsOutCOM','lims95')
        
%Pool across animals
[pooledMeanCorr,pooledMeanCorrOutofShuff,pooledPVcorrs,pooledPVcorrsOutShuff,...
          pooledMeanPVcorrsOutShuff,pooledNumPVcorrsOutShuff,pooledCorrsOutCOM,pooledPVdayDiffs] =...
          PoolProcessedPVcorrs(pooledCompPairs,meanCorr,meanCorrOutOfShuff,pvCorrs,pvCorrsOutOfShuff,...
          meanCorrsOutShuff,numCorrsOutShuff,corrsOutCOM,PVdayPairs);


%Shuffle days and dimensions
tic
pooledCompPairs = [1 2; 2 1; 3 4; 4 3]; 
pooledShuffleDim = {'leftright', 'leftright', 'studytest','studytest'};
pvCorrs = cell(numMice,1); numCellsUsed = cell(numMice,1); numNans = cell(numMice,1); meanCorr = cell(numMice,1);
parfor mouseI = 1:numMice
    shuffleWhat = 'dayAndDim';
    %Make the pv corrs
    [pvCorrs{mouseI}, meanCorr{mouseI}, numCellsUsed{mouseI}, numNans{mouseI}, shuffPVcorrs{mouseI}, shuffMeanCorr{mouseI}, PVdayPairs{mouseI}]=...
    MakePVcorrsWrapper(cellTBT{mouseI}, shuffleWhat, numPerms, pooledCompPairs, pooledShuffleDim,...
                       pooledCondPairs, poolLabels, pooledTraitLogical{mouseI}, xlims, cmperbin, minspeed);
    %Do some processing
    [meanCorrOutOfShuff{mouseI},pvCorrsOutOfShuff{mouseI},meanCorrsOutShuff{mouseI},numCorrsOutShuff{mouseI},corrsOutCOM{mouseI},lims95] =...
          ProcessPVcorrs(numPerms,pThresh,shuffMeanCorr{mouseI},meanCorr{mouseI},shuffPVcorrs{mouseI},pvCorrs{mouseI});
end
toc
save(fullfile(mainFolder,'dayAndDimCorrs.mat'),'pvCorrs','meanCorr','numCellsUsed','numNans','shuffPVcorrs','shuffMeanCorr','PVdayPairs',...
            'meanCorrOutOfShuff','pvCorrsOutOfShuff','meanCorrsOutShuff','numCorrsOutShuff','corrsOutCOM','lims95')
        
%Pool across animals
[pooledMeanCorr,pooledMeanCorrOutofShuff,pooledPVcorrs,pooledPVcorrsOutShuff,...
          pooledMeanPVcorrsOutShuff,pooledNumPVcorrsOutShuff,pooledCorrsOutCOM,pooledPVdayDiffs] =...
          PoolProcessedPVcorrs(pooledCompPairs,meanCorr,meanCorrOutOfShuff,pvCorrs,pvCorrsOutOfShuff,...
          meanCorrsOutShuff,numCorrsOutShuff,corrsOutCOM,PVdayPairs);



%% Variance of diff types of cell

[b,r,stats, MSE] = GetCellVarianceSource(trialbytrial,pooledUnpooled)



%% Center of mass, change over time
for mouseI = 1:numMice
    allFiringCOM{mouseI} = TMapFiringCOM(cellPooledTMap_unsmoothed{mouseI});
end

figure; 
pooledCOM = cell(4,max(numDays));
for condI = 1:4
    subplot(2,2,condI)
    for mouseI = 1:numMice
        for dayI = 1:numDays(mouseI)
            dataHere = allFiringCOM{mouseI}(:,dayI,condI);
            plot(ones(sum(dataHere>0),1)*dayI,dataHere(dataHere>0),'*')
            hold on
            pooledCOM{condI,dayI} = [pooledCOM{condI,dayI}; dataHere(dataHere>0)];
        end
    end
    comMeans(condI,:) = cell2mat(cellfun(@mean,pooledCOM(condI,:),'UniformOutput',false));
    comSEMs(condI,:) = cell2mat(cellfun(@standarderrorSL,pooledCOM(condI,:),'UniformOutput',false));
    
    plot(comMeans(condI,:))
    
end

possDaysApart = unique(pooledDaysApartFWD);
pooledCOMchange = cell(4,length(possDaysApart));
for mouseI = 1:numMice
    COMchange{mouseI} = nan(size(cellSSI{mouseI},1),size(dayPairs{mouseI},1),4);
    for condI = 1:4
        for dpI = 1:size(dayPairs{mouseI},1)
            for cellI = 1:size(cellSSI{mouseI},1)
                fCOMB = allFiringCOM{mouseI}(cellI,dayPairs{mouseI}(dpI,2),condI);
                fCOMA = allFiringCOM{mouseI}(cellI,dayPairs{mouseI}(dpI,1),condI);
                if fCOMA > 0 && fCOMB > 0
                    COMchange{mouseI}(cellI,dpI,condI) = fCOMB - fCOMA;
                end
            end
        end
    end
    
    for condI = 1:4
    for ddI = 1:length(possDaysApart)
        changes = COMchange{mouseI}(:,daysApartFWD{mouseI}==possDaysApart(ddI),condI);
        changes = changes(:);
        pooledCOMchange{condI,ddI} = [pooledCOMchange{condI,ddI}; changes(isnan(changes)==0)];
    end
    end
end

figure; 
for condI = 1:4
    subplot(2,2,condI)
    for ddI = 1:17
    plot(ddI*ones(length(pooledCOMchange{condI,ddI}),1),pooledCOMchange{condI,ddI},'.')
    means(condI,ddI) = mean(pooledCOMchange{condI,ddI});
    hold on
    end
    plot(means(condI,:),'LineWidth',2)
end


