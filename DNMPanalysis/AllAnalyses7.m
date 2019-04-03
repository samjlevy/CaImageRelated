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
mazeLocations = {'Stem','Arms'};
performanceThreshold = 0.7;
global dayLagLimit
dayLagLimit = 16;

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
    
    load(fullfile(mainFolder,mice{mouseI},'allAccuracy.mat'))
    allDaysAccuracy{mouseI} = allAccuracy;
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
    %cellPooledTMap_firesAtAll{1}{mouseI} = TMap_firesAtAll;
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
    %cellPooledTMap_firesAtAllArm{1}{mouseI} = TMap_firesAtAll;
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

purp = [0.4902    0.1804    0.5608]; orng = [0.8510    0.3294    0.1020];
colorAssc = { [1 0 0]     [0 0 1]    [1 0 1]       [0 1 1]         purp     orng        [0 1 0]       [0 0 0]};
traitLabels = {'splitLR' 'splitST'  'splitLRonly' 'splitSTonly' 'splitBOTH' 'splitONE' 'splitEITHER' 'dontSplit'};

disp('Done all setup stuff')

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
                    cellTMap = cellPooledTMap_unsmoothed{1}{mouseI};
                    %cellTMap = cellPooledTMap_firesAtAll{1}{mouseI};
                    tbtHere = cellTBT{mouseI};
                case 'arm'
                    splitterFile = fullfile(shuffleDir,['ARMsplitters' splitterType{stI} '.mat']);
                    binEdgesHere = armBinEdges;
                    cellTMap = cellPooledTMap_unsmoothedArm{1}{mouseI};
                    %cellTMap = cellPooledTMap_firesAtAllArm{1}{mouseI};
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
disp('Done loading all splitting')

%% Splitter cells: logical each type
dayUseFilter = {dayUse; dayUseArm}; 
%dayUseFilter = {dayUsePooled; dayUseArmPooled};
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

disp('Done how many splitters')

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
        %[dayCOMsignpVal(mouseI,tgI),dayCOMsignpVal(mouseI,tgI)] = signtest(logicalCOMgroupout{slI}{mouseI}(tgI).dayBias.Early
        
        for tgI = 1:numTraitGroups
            pooledSplitDayCOM{slI}{tgI} = [pooledSplitDayCOM{slI}{tgI}; logicalCOMgroupout{slI}{mouseI}(tgI).dayCOM];
            
            pooledCOMBiases{slI}{tgI} = [pooledCOMBiases{slI}{tgI}; logicalCOMgroupout{slI}{mouseI}(tgI).dayBias.Pct.Early...
                                                                    logicalCOMgroupout{slI}{mouseI}(tgI).dayBias.Pct.NoBias+logicalCOMgroupout{slI}{mouseI}(tgI).dayBias.Pct.SplitAllDays...
                                                                    logicalCOMgroupout{slI}{mouseI}(tgI).dayBias.Pct.Late];
        end        
    end
end


%What are new cells?
pooledNewCellProps = [];
pooledNewCellPropChanges = [];
firstDayGroupout = []; firstDays = [];
for slI = 1:2
    pooledNewCellProps{slI} = cell(numTraitGroups,1);
    pooledNewCellPropChanges{slI} = cell(numTraitGroups,1);
    for mouseI = 1:numMice
        firstDays{slI}{mouseI} = GetFirstDayTrait(dayUseFilter{slI}{mouseI});
        %[firstDayGroupout{slI}{mouseI}] = RunGroupFunction('GetFirstDayTrait',traitGroups{slI}{mouseI},[]);
        
        firstDayLogical{slI}{mouseI} = false(size(cellSSI{mouseI}));
        for cellI = 1:size(cellSSI{mouseI},1)
            if ~isnan(firstDays{slI}{mouseI}(cellI))
            firstDayLogical{slI}{mouseI}(cellI,firstDays{slI}{mouseI}(cellI)) = true;  %NEED to eliminate day 1 after performing this
            end
        end
        firstDayLogicalUse{slI}{mouseI} = firstDayLogical{slI}{mouseI};
        firstDayLogicalUse{slI}{mouseI}(:,1) = [];
        firstDayNums{slI}{mouseI} = sum(firstDayLogicalUse{slI}{mouseI},1);
        
        for tgI = 1:numTraitGroups
            traitFirst{slI}{mouseI}{tgI} = traitGroups{slI}{mouseI}{tgI}(:,2:end).*firstDayLogicalUse{slI}{mouseI};
            traitFirstNums{slI}{mouseI}{tgI} = sum(traitFirst{slI}{mouseI}{tgI},1);

            traitFirstPcts{slI}{mouseI}{tgI} = traitFirstNums{slI}{mouseI}{tgI}./ firstDayNums{slI}{mouseI};
            [newCellChanges{slI}{mouseI}{tgI},~] = TraitChangeDayPairs(traitFirstPcts{slI}{mouseI}{tgI},combnk(1:length(cellRealDays{mouseI})-1,2));%

            pooledNewCellProps{slI}{tgI} = [pooledNewCellProps{slI}{tgI}; traitFirstPcts{slI}{mouseI}{tgI}(:)];
            pooledNewCellPropChanges{slI}{tgI} = [pooledNewCellPropChanges{slI}{tgI}; newCellChanges{slI}{mouseI}{tgI}(:)];
        end
        
        %{
        for pcI = 1:size(pairsCompareInd,1)
            traitFirstDiffs{mouseI}{pcI} = traitFirstPcts{slI}{mouseI}{pairsCompareInd(pcI,2)} - traitFirstPcts{slI}{mouseI}{pairsCompareInd(pcI,1)};
            [traitFirstDiffsChanges{mouseI}{pcI},~] = TraitChangeDayPairs(traitFirstDiffs{mouseI}{pcI},compDayPairsFWD{mouseI});

            traitFirstDiffsPooled{slI}{pcI} = [traitFirstDiffsPooled{slI}{pcI}; traitFirstDiffs{mouseI}{pcI}(:)];
            traitFirstDiffsPooledChanges{{slI}pcI} = [traitFirstDiffsPooledChanges{slI}{pcI}; traitFirstDiffsChanges{mouseI}{pcI}(:)];
        end
        %}
    end
end
disp('Done when do splitters show up')

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

sourceColors = [0 1 0; colorAssc{1}; colorAssc{2}; colorAssc{5}; 0.6 0.6 0.6]; 
sourceLabels = {'New Cells',traitLabels{[1 2 5 8]}};
for slI = 1:2
    for mouseI = 1:numMice
        firstDaySource{slI}{mouseI} = [firstDayLogical{slI}{mouseI}(:,2:end) zeros(size(cellSSI{mouseI},1),1)];
            %new cell that day, shifted to get matched as dayI-1
        targets{mouseI} = traitGroups{slI}{mouseI}(cellCheck);
        sources{mouseI} = [firstDaySource{slI}{mouseI}; traitGroups{slI}{mouseI}([cellCheck 8])]; %dayUseFilter{slI}{mouseI}==0; 
        
        sinks{mouseI} = sources{mouseI};
    end
    
    [pooledSourceChanges{slI}, pooledDailySources{slI}, pooledSinkChanges{slI}, pooledDailySinks{slI}, sourceDayDiffsPooled{slI}, sinkDayDiffsPooled{slI}] =...
        CheckLogicalSinksAndSources(targets,sources,sinks,cellRealDays);
    
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



%old, probably doesn't work
%{
for slI = 1:2
    %figure;
    for tgI = 1:3
        %Source of cells
        for scI = 1:length(sources)
            sourceChangePooled{slI}{tgI}{scI} = [];
            for mouseI = 1:numMice
                sourceChangePooled{slI}{tgI}{scI} = [sourceChangePooled{slI}{tgI}{scI}; sourceChange{slI}{scI}{tgI}{mouseI}(:)];
            end
        end
        
        %Where cells going
        for scK = 1:length(sinks)
            sinkChangePooled{slI}{tgI}{scK} = [];
            for mouseI = 1:numMice
                sinkChangePooled{slI}{tgI}{scK} = [sinkChangePooled{slI}{tgI}{scK}; sinkChange{slI}{scK}{tgI}{mouseI}(:)];
            end
        end
        
    end
    
    %Where are cells coming from
    dfg = figure('Position',[468 122 1132 609]);
       
    sourceColors = {[0.9294    0.6902    0.1294];colorAssc{1}; colorAssc{2}; colorAssc{5}; colorAssc{8}};
    sourceColorsAll = {sourceColors{:} sourceColors{:} sourceColors{:}};
    scPooledAll = {sourceChangePooled{slI}{1}{:} sourceChangePooled{slI}{2}{:} sourceChangePooled{slI}{3}{:}};
    compsAll = [1 2 3 4 5; 6 7 8 9 10; 11 12 13 14 15];
    sourceLabelsAll = {sourceLabels{:} sourceLabels{:} sourceLabels{:}};
        
    [figHand,statsOut] = PlotTraitChangeOverDays(scPooledAll,abbrevDayDiffsPooled,compsAll,...
        sourceColorsAll,sourceLabelsAll,dfg,true,'regress',[-1 1],'change pct This Source');
    for tgI = 1:3
        dfg.Children((3+1)*2-tgI*2).Title.String = ['sources for: ' traitLabels{cellCheck(tgI)}];%
    end
    suptitleSL(['Where are these cells coming from? ' upper(mazeLocations{slI})])
    
    %Where are cells going
    dfh = figure('Position',[468 122 1132 609]);
       
    sourceColors = {[0.9294    0.6902    0.1294];colorAssc{1}; colorAssc{2}; colorAssc{5}; colorAssc{8}};
    sourceColorsAll = {sourceColors{:} sourceColors{:} sourceColors{:}};
    scPooledAllK = {sinkChangePooled{slI}{1}{:} sinkChangePooled{slI}{2}{:} sinkChangePooled{slI}{3}{:}};
    compsAll = [1 2 3 4 5; 6 7 8 9 10; 11 12 13 14 15];
    sinkLabelsAll = {sinkLabels{:} sinkLabels{:} sinkLabels{:}};
        
    [figHand,statsOut] = PlotTraitChangeOverDays(scPooledAllK,abbrevDayDiffsPooledJ,compsAll,...
        sourceColorsAll,sinkLabelsAll,dfh,true,'regress',[-1 1],'change pct This Source');
    for tgI = 1:3
        dfh.Children((3+1)*2-tgI*2).Title.String = ['sinks for: ' traitLabels{cellCheck(tgI)}];
    end        
    suptitleSL(['Where are these cells going? ' upper(mazeLocations{slI})])
    
end


sourceLabels = {'newCells','LRonly','STonly','both'};
figure;
for scI = 1:4
    for tgI = 1:3
        %subplot(4,3,tgI+3*(scI-1))
        for mouseI = 1:4
            %plot(thisSourceSumNorm{1}{mouseI}{tgI}(scI,:))
            hold on
        end
        %plot(mean(thisSourceSumNormSC{1}{scI}{tgI}(:,1:8),1),'k','LineWidth',2)
        
        dataKeep{1}{tgI}(scI,:) = mean(thisSourceSumNormSC{1}{scI}{tgI}(:,1:8),1);
        ylim([0 1])
        
        %title([traitLabels{sourceCheck(tgI)} ' from ' sourceLabels{scI}])
    end
end

figure;
scColors = {[0.9294    0.6902    0.1294];colorAssc{1}; colorAssc{2}; colorAssc{5}};
for tgI = 1:3
    barDataAll = [];
    pp = [];
    subplot(1,3,tgI)
    for dayI = 1:8
        dataHere = dataKeep{1}{tgI}(:,dayI);
        barData = dataHere/sum(dataHere);
        barDataAll = [barDataAll; barData(:)'];
    end
    
    for scI = 1:4
        pp(scI) = plot(barDataAll(:,scI),'LineWidth',2,'Color',scColors{scI},'DisplayName',sourceLabels{scI});
        hold on
    end
    ylim([0 1])
    title([traitLabels{cellCheck(tgI)} ' sources'])   
    legend(pp,'location','nw')
    xlabel('DayN+1/DayN')
end
%}
%% Overlap in both
pctTraitBothPooled = cell(numTraitGroups,1);
for mouseI = 1:numMice
    activeTodayStem{mouseI} = sum(dayUse{mouseI},1)/numCells(mouseI);
    activeTodayArm{mouseI} = sum(dayUseArm{mouseI},1)/numCells(mouseI);
    activeARMandSTEM{mouseI} = dayUse{mouseI} + dayUseArm{mouseI}==2;
    activeEither{mouseI} = dayUse{mouseI} + dayUseArm{mouseI} >0;
    %pctActiveBoth{mouseI} = sum(activeARMandSTEM{mouseI},1) / size(dayUse{mouseI},1);
    %pctActiveBoth{mouseI} = sum(activeARMandSTEM{mouseI},1) ./ sum(cellSSI{mouseI}>0,1);
    pctActiveBoth{mouseI} = sum(activeARMandSTEM{mouseI},1) ./ sum(activeEither{mouseI},1);
    
    for tgI = 1:numTraitGroups
        traitARMandSTEM{mouseI}{tgI} = traitGroups{1}{mouseI}{tgI} + traitGroups{2}{mouseI}{tgI}==2;
        %pctTraitBoth{mouseI}{tgI} = sum(traitARMandSTEM{mouseI}{tgI},1) / numCells(mouseI);
        pctTraitBoth{mouseI}{tgI} = sum(traitARMandSTEM{mouseI}{tgI},1) ./ sum(activeARMandSTEM{mouseI},1);
        pctTraitBothPooled{tgI} = [pctTraitBothPooled{tgI}; pctTraitBoth{mouseI}{tgI}(:)];
    end
end


%Splits the same
pooledPctSamePref = cell(2,1);
pooledPctSamePrefSTEM = cell(2,1);
pooledPctSamePrefARM = cell(2,1);
for stI = 1:length(splitterType)
    for mouseI = 1:numMice
        splitNeg = (meanRateDiff{1}{stI}{mouseI} < 0) + (meanRateDiff{2}{stI}{mouseI} < 0) == 2;
        splitPos = (meanRateDiff{1}{stI}{mouseI} > 0) + (meanRateDiff{2}{stI}{mouseI} > 0) == 2;
        
        splitSame = splitNeg + splitPos;
        
        samePrefSTEMandARM{stI}{mouseI} = splitSame;  
        
        pctSamePref{stI}{mouseI} = sum(samePrefSTEMandARM{stI}{mouseI}.*activeARMandSTEM{mouseI},1) ./ sum(activeARMandSTEM{mouseI},1);
        pooledPctSamePref{stI} = [pooledPctSamePref{stI}; pctSamePref{stI}{mouseI}(:)];
        
        pctSamePrefSTEM{stI}{mouseI} = sum(samePrefSTEMandARM{stI}{mouseI}.*activeARMandSTEM{mouseI},1) ./ sum(dayUse{mouseI},1);
        pooledPctSamePrefSTEM{stI} = [pooledPctSamePref{stI}; pctSamePrefSTEM{stI}{mouseI}(:)];
        pctSamePrefARM{stI}{mouseI} = sum(samePrefSTEMandARM{stI}{mouseI}.*activeARMandSTEM{mouseI},1) ./ sum(dayUseArm{mouseI},1);
        pooledPctSamePrefARM{stI} = [pooledPctSamePrefARM{stI}; pctSamePrefARM{stI}{mouseI}(:)];
    end
end
        
%Filter by each splitting type
pooledPctSamePrefByTG = []; samePrefByTG = []; numSamePrefByTG = []; pctSamePreByTG = [];
for stI = 1:length(splitterType)
    for slI = 1:2
        pooledPctSamePrefByTG{stI}{slI} = cell(numTraitGroups,1);
        for tgI = 1:numTraitGroups
            for mouseI = 1:numMice
                samePrefByTG{slI}{stI}{tgI}{mouseI} = samePrefSTEMandARM{stI}{mouseI}.*traitGroups{slI}{mouseI}{tgI};
                
                numSamePrefByTG{slI}{stI}{tgI}{mouseI} = sum(samePrefByTG{slI}{stI}{tgI}{mouseI},1);
                
                pctSamePreByTG{slI}{stI}{tgI}{mouseI} = numSamePrefByTG{slI}{stI}{tgI}{mouseI} ./ sum(traitGroups{slI}{mouseI}{tgI},1);
                pooledPctSamePrefByTG{stI}{slI}{tgI} = [pooledPctSamePrefByTG{stI}{slI}{tgI}; pctSamePreByTG{slI}{stI}{tgI}{mouseI}(:)];
            end
        end
    end
end
disp('Done arm/stem splitter overlap')

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



%% Pop vector corr differences by cells included (Do Work here)

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

pvNames = {'includeSilent', 'aboveThreshBoth', 'aboveThreshEither', 'cellPresentBoth'}
traitLogUse{1} = {cellfun(@(x) ones(size(x)),cellSSI,'UniformOutput',false) }

%To do: function that predetermines cellsUse for each day pair/cond pair,
%(needed to aboveThreshOne but present both)
%Also need a toggle in pvcorrswrapper to check to use this

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


%% Pop vector corr differences by cells included STEM

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

    %Diff from VS self
    
    
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

%Discrimination index of PV results
tic
CSpooledPVcorrsDPrime = [];
CSpooledPVcorrsDPrimePval = [];
CSpooledPVcorrsDiff = [];
for pvtI = 1:length(pvNames)
    for pvpoolI = 2:3
        dayDiffsHere = unique([CSpooledPVdaysApart{pvtI}{1}; CSpooledPVdaysApart{pvtI}{pvpoolI}]);
        for ddI = 1:length(dayDiffsHere)
            daysUseSig = CSpooledPVdaysApart{pvtI}{pvpoolI}==dayDiffsHere(ddI);
            daysUseNoise = CSpooledPVdaysApart{pvtI}{1}==dayDiffsHere(ddI);
            
            [CSpooledPVcorrsDPrime{pvtI}{pvpoolI-1}(ddI),CSpooledPVcorrsDPrimePval{pvtI}{pvpoolI-1}(ddI)] =...
                SensitivityIndexSL(CSpooledPVcorrs{pvtI}{pvpoolI}(daysUseSig),CSpooledPVcorrs{pvtI}{1}(daysUseNoise),1000);
            [CSpooledPVcorrsDPrimeHalfFirst{pvtI}{pvpoolI-1}(ddI),CSpooledPVcorrsDPrimePvalHalfFirst{pvtI}{pvpoolI-1}(ddI)] =...
                SensitivityIndexSL(CSpooledPVcorrsHalfFirst{pvtI}{pvpoolI}(daysUseSig),CSpooledPVcorrsHalfFirst{pvtI}{1}(daysUseNoise),1000);
            [CSpooledPVcorrsDPrimeHalfSecond{pvtI}{pvpoolI-1}(ddI),CSpooledPVcorrsDPrimePvalHalfSecond{pvtI}{pvpoolI-1}(ddI)] =...
                SensitivityIndexSL(CSpooledPVcorrsHalfSecond{pvtI}{pvpoolI}(daysUseSig),CSpooledPVcorrsHalfSecond{pvtI}{1}(daysUseNoise),1000);
            
            CSpooledPVcorrsDiff{pvtI}{pvpoolI-1}(ddI) = mean(CSpooledPVcorrs{pvtI}{1}(daysUseNoise)) - mean(CSpooledPVcorrs{pvtI}{pvpoolI}(daysUseSig)); 
            CSpooledPVcorrsDiffHalfFirst{pvtI}{pvpoolI-1}(ddI) = mean(CSpooledPVcorrsHalfFirst{pvtI}{1}(daysUseNoise)) - mean(CSpooledPVcorrsHalfFirst{pvtI}{pvpoolI}(daysUseSig)); 
            CSpooledPVcorrsDiffHalfSecond{pvtI}{pvpoolI-1}(ddI) = mean(CSpooledPVcorrsHalfSecond{pvtI}{1}(daysUseNoise)) - mean(CSpooledPVcorrsHalfSecond{pvtI}{pvpoolI}(daysUseSig)); 
        end
    end
end
toc

disp('Done PV corrs STEM')

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

disp('Done PV corrs ARMS')

%% Center of mass, change over time

for mouseI = 1:numMice
    [allCondsTMap{mouseI}, ~, ~, ~, ~, ~, ~] =...
        PFsLinTBTdnmp(cellTBT{mouseI}, stemBinEdges, minspeed, [], false,[1 2 3 4]);

    [allCondsTMapARM{mouseI}, ~, ~, ~, ~, ~, ~] =...
        PFsLinTBTdnmp(cellTBTarm{mouseI}, armBinEdges, minspeed, [], false,[1 2 3 4]);

    allFiringCOM{mouseI} = TMapFiringCOM(allCondsTMap{mouseI});
    allFiringCOMarm{mouseI} = TMapFiringCOM(allCondsTMapARM{mouseI});
end

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
                DecoderWrapper3downsampling(cellTBT{mouseI},traitLogUse{dtI}{mouseI},numDownsamples,'transientDur','pooled','bayes');
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




