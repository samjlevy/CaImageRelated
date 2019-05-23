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
%global realDatMarkerSize
%realDatMarkerSize = 16;

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


%What are new cells?
firstDayLogical = [];
for slI = 1:2
    for mouseI = 1:numMice
        firstDays{slI}{mouseI} = GetFirstDayTrait(dayUseFilter{slI}{mouseI});
        
        firstDayLogical{slI}{mouseI} = false(size(cellSSI{mouseI}));
        for cellI = 1:size(cellSSI{mouseI},1)
            if ~isnan(firstDays{slI}{mouseI}(cellI))
            firstDayLogical{slI}{mouseI}(cellI,firstDays{slI}{mouseI}(cellI)) = true;
            end
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
            pooledTraitLogicalA{slI}{mouseI}(:,:,cc) =...
                sum(traitLogicalsUse{slI}{tluI}{mouseI}(:,:,pooledCondPairs(cc,:)),3) > 0;
            tluI = 2;
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
