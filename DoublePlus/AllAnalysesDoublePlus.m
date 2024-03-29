%AllAnalysesDoublePlus

%mainFolder = 'G:\DoublePlus';
mainFolder = 'C:\Users\Sam\Desktop\DoublePlusFinalData';
mice = {'Kerberos','Marble07','Marble11','Pandora','Styx','Titan'};
numMice = length(mice);

load(fullfile(mainFolder,'groupAssign.mat'))
groupNum = ones(6,1); groupNum(strcmpi(groupAssign(:,2),'diff'))=2;

locInds = {1 'center'; 2 'north'; 3 'south'; 4 'east'; 5 'west'};
[armBounds, ~, ~] = MakeDoublePlusBehaviorBounds;
armLims = armBounds.north(3,:);
numBins = 10;
cmperbin = (max(armLims) - min(armLims))/numBins;
binEdges = linspace(min(armLims),max(armLims),numBins+1);
minspeed = 0;

pThresh = 0.05;
lapPctThresh = 0.25;
consecLapThresh = 3;

disp('loading root data')
for mouseI = 1:numMice
    load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'))
    cellTBT{mouseI} = trialbytrial;
    cellSSI{mouseI} = sortedSessionInds;
    cellAllFiles{mouseI} = allfiles;
    cellRealDays{mouseI} = realdays;
    
    numDays(mouseI) = size(cellSSI{mouseI},2);
    numCells(mouseI) = size(cellSSI{mouseI},1);
    
    clear trialbytrial sortedSessionInds allFiles

    load(fullfile(mainFolder,mice{mouseI},'DoublePlusDataTable.mat'))
    accuracy{mouseI} = DoublePlusDataTable.Accuracy;
    realDays{mouseI} = DoublePlusDataTable.RealDay;
    
    clear DoublePlusDataTable 
    
    disp(['Mouse ' num2str(mouseI) ' completed'])
end

armAlignment = GetDoublePlusArmAlignment;
condNames = {cellTBT{1}.name};

disp('Getting reliability')
dayUse = cell(1,numMice); threshAndConsec = cell(1,numMice);
for mouseI = 1:numMice
    [dayUse{mouseI},threshAndConsec{mouseI}] = GetUseCells(cellTBT{mouseI}, lapPctThresh, consecLapThresh,[],[],[]);
                            %(trialbytrial, lapPctThresh, consecLapThresh, poolConds,xBinLims,yBinLims)
    [trialReli{mouseI},aboveThresh{mouseI},~,~] = TrialReliability(cellTBT{mouseI}, lapPctThresh,[],[],[]);
    cellsActiveToday{mouseI} = sum(dayUse{mouseI},1);
    daysEachCellActive{mouseI} = sum(dayUse{mouseI},2);
    %disp(['Mouse ' num2str(mouseI) ' completed'])
end
disp('done reliability')


disp('checking place fields')
for mouseI = 1:numMice
    saveName = fullfile(mainFolder,mice{mouseI},'PFsLin.mat');
    switch exist(fullfile(mainFolder,mice{mouseI},'PFsLin.mat'),'file')
        case 0
            disp(['no placefields found for ' mice{mouseI} ', making now'])
            %[TMap_unsmoothed, TMap_gauss, TMap_zRates, OccMap, RunOccMap, xBin, TCounts] =...
            [~, ~, ~, ~, ~, ~, ~] =...
            PFsLinTBTdoublePlus(cellTBT{mouseI}, binEdges, minspeed, saveName, false); %'trialReli',trialReli{mouseI},
        case 2
            disp(['found placefields for ' mice{mouseI} ', all good'])
    end
end

for mouseI = 1:numMice
    load(fullfile(mainFolder,mice{mouseI},'PFsLin.mat'),'TMap_unsmoothed','TMap_zRates')
    for condI = 1:length(condNames)
        if sum(strcmpi(condNames{condI},{'north','west'}))==1 %Bin is direction of travel
            TMap_unsmoothed(:,:,condI) = cellfun(@fliplr,TMap_unsmoothed(:,:,condI),'UniformOutput',false);
            TMap_zRates(:,:,condI) = cellfun(@fliplr,TMap_zRates(:,:,condI),'UniformOutput',false);
        end
    end
    cellTMap_unsmoothed{mouseI} = TMap_unsmoothed;
    cellTMap_zScored{mouseI} = TMap_zRates;
end   

groupNames = unique(groupAssign(:,2));
twoEnvMice = find(strcmpi('diff',groupAssign(:,2)));
oneEnvMice = find(strcmpi('same',groupAssign(:,2)));

disp('Done setup stuff')
%% Pop vector corr analysis (most basic)
cellsUseOption = 'activeEither';
corrType = 'Spearman';
numPerms = 1000;

condPairs = [1 1; 2 2; 3 3; 4 4]; numCondPairs = size(condPairs,1);
dayPairs = [1 2; 1 3; 2 3]; numDayPairs = size(dayPairs,1);

traitLogical = threshAndConsec;
pvCorrs = cell(numMice,1); 
meanCorr = cell(numMice,1); 
numCellsUsed = cell(numMice,1); 
numNan = cell(numMice,1); 

disp('Making corrs')
pooledPVcorrs = cell(numDayPairs,numCondPairs);
pooledMeanCorr = cell(numDayPairs,numCondPairs);
pooledNumCellsUsed = cell(numDayPairs,numCondPairs);
for mouseI = 1:numMice
    
    [pvCorrs, meanCorr, numCellsUsed, numNans] =...
        PVcorrsWrapperBasic(cellTMap_unsmoothed{mouseI},condPairs,dayPairs,traitLogical{mouseI},cellsUseOption,corrType);
    
    for cpI = 1:numCondPairs
        for dpI = 1:numDayPairs
            pooledPVcorrs{dpI,cpI} = [pooledPVcorrs{dpI,cpI}; pvCorrs{dpI,cpI}];
            pooledMeanCorr{dpI,cpI} = [pooledMeanCorr{dpI,cpI}; meanCorr{dpI,cpI}];
            pooledNumCellsUsed{dpI,cpI} = [pooledNumCellsUsed{dpI,cpI}; numCellsUsed{dpI,cpI}];
        end
    end
end

disp('testing diffs')
for cpI = 1:numCondPairs
    for dpI = 1:numDayPairs
        oneEnvMicePVcorrs{dpI,cpI} = pooledPVcorrs{dpI,cpI}(oneEnvMice,:);
        oneEnvMicePVcorrsMeans{dpI,cpI} = mean(oneEnvMicePVcorrs{dpI,cpI},1);
        
        twoEnvMicePVcorrs{dpI,cpI} = pooledPVcorrs{dpI,cpI}(twoEnvMice,:);
        twoEnvMicePVcorrsMeans{dpI,cpI} = mean(twoEnvMicePVcorrs{dpI,cpI},1);
        
        sameMinusDiff{dpI,cpI} = oneEnvMicePVcorrsMeans{dpI,cpI} - twoEnvMicePVcorrsMeans{dpI,cpI};
        
        %sepMinusInt{dI,cpI} = twoEnvMicePVcorrsMeans{dpI,cpI} - oneEnvMicePVcorrsMeans{dpI,cpI};
        
        for binI = 1:numBins
            %[pPVs{dpI,cpI}(binI),hPVs{dpI,cpI}(binI)] = ranksum(oneEnvMicePVcorrs{dpI,cpI}(:,binI),...
            %twoEnvMicePVcorrs{dpI,cpI}(:,binI));
        end
        
        diffRank{dpI,cpI} = PermutationTestSL(oneEnvMicePVcorrs{dpI,cpI},twoEnvMicePVcorrs{dpI,cpI},numPerms);
        isSig{dpI,cpI} = diffRank{dpI,cpI} > (1-pThresh);
    end
end

disp('done pv corrs basic')

%% PV corrs: portion of session
cellsUseOption = 'activeEither';
corrType = 'Spearman';

condPairs = [1 1; 2 2; 3 3; 4 4]; numCondPairs = size(condPairs,1);
dayPairs = [1 2; 1 3; 2 3]; numDayPairs = size(dayPairs,1);
dayChunks = [0 0.34; 0.33 0.67; 0.66 1];
numDayChunks = size(dayChunks,1);

trimPooledPVcorrs = cell(numDayChunks,numDayPairs,numCondPairs);
trimPooledMeanCorr = cell(numDayChunks,numDayPairs,numCondPairs);
trimPooledNumCellsUsed = cell(numDayChunks,numDayPairs,numCondPairs);

disp('Making corrs')
for mouseI = 1:numMice
    for dcI = 1:numDayChunks
        trimmedTBT = SlimDownTBT(cellTBT{mouseI},dayChunks(dcI,:));

        [TMapTrimmed, ~, ~, ~, ~, ~, ~] =...
            PFsLinTBTdoublePlus(trimmedTBT, binEdges, minspeed, [], false);

        [pvCorrsTrim, meanCorrTrim, ~, ~] =...
            PVcorrsWrapperBasic(TMapTrimmed,condPairs,dayPairs,traitLogical{mouseI},cellsUseOption,corrType);

        for cpI = 1:numCondPairs
            for dpI = 1:numDayPairs
                trimPooledPVcorrs{dcI,dpI,cpI} = [trimPooledPVcorrs{dcI,dpI,cpI}; pvCorrsTrim{dpI,cpI}];
                trimPooledMeanCorr{dcI,dpI,cpI} = [trimPooledMeanCorr{dcI,dpI,cpI}; meanCorrTrim{dpI,cpI}];
                trimPooledNumCellsUsed{dcI,dpI,cpI} = [trimPooledNumCellsUsed{dcI,dpI,cpI}; numCellsUsed{dpI,cpI}];
            end
        end
    end
end
disp('Done making corrs')

oneEnvMiceTrimPVcorrs = cell(numDayChunks,numDayPairs,numCondPairs);
oneEnvMiceTrimPVcorrsMeans = cell(numDayChunks,numDayPairs,numCondPairs);
twoEnvMiceTrimPVcorrs = cell(numDayChunks,numDayPairs,numCondPairs);
twoEnvMiceTrimPVcorrsMeans = cell(numDayChunks,numDayPairs,numCondPairs);
sameMinusDiffTrim = cell(numDayChunks,numDayPairs,numCondPairs);

disp('testing diffs')
for dcI = 1:numDayChunks
for cpI = 1:numCondPairs
    for dpI = 1:numDayPairs
        oneEnvMiceTrimPVcorrs{dcI,dpI,cpI} = trimPooledPVcorrs{dcI,dpI,cpI}(oneEnvMice,:);
        oneEnvMiceTrimPVcorrsMeans{dcI,dpI,cpI} = mean(oneEnvMiceTrimPVcorrs{dcI,dpI,cpI},1);
        
        twoEnvMiceTrimPVcorrs{dcI,dpI,cpI} = trimPooledPVcorrs{dcI,dpI,cpI}(twoEnvMice,:);
        twoEnvMiceTrimPVcorrsMeans{dcI,dpI,cpI} = mean(twoEnvMiceTrimPVcorrs{dcI,dpI,cpI},1);
        
        sameMinusDiffTrim{dcI,dpI,cpI} = oneEnvMiceTrimPVcorrsMeans{dcI,dpI,cpI} - twoEnvMiceTrimPVcorrsMeans{dcI,dpI,cpI};
        
        diffRankTrim{dcI,dpI,cpI} = PermutationTestSL(oneEnvMiceTrimPVcorrs{dcI,dpI,cpI},...
            twoEnvMiceTrimPVcorrs{dcI,dpI,cpI},numPerms);
        isSigTrim{dcI,dpI,cpI} = diffRankTrim{dcI,dpI,cpI} > (1-pThresh);
    end
end
end

disp('Done with portion of day')


%% Splitter cells? 
numShuffles = 1000;
%numShuffles = 100;
shuffThresh = 1 - pThresh;
binsMin = 1;

%Shuffle between start arm and finish arm ('phase')
dimShuffle = {'south','east';'north','west'};
for mouseI = 1:numMice    
    tic
    shuffDirFull = fullfile(mainFolder,mice{mouseI},'shufflePhase');
    condPairs = [];
    for shuffPairI = 1:size(dimShuffle,1)
        for shuffThisI = 1:size(dimShuffle,2)
            condPairs(shuffPairI,shuffThisI) = find(strcmpi({cellTBT{mouseI}(:).name},dimShuffle{shuffPairI,shuffThisI}));
        end
    end

    [rateDiffPhase{mouseI}, rateSplitPhase{mouseI}, meanRateDiffPhase{mouseI},...
        DIeachPhase{mouseI}, DImeanPhase{mouseI}, DIallPhase{mouseI}] =...
        LookAtSplitters4(cellTMap_unsmoothed{mouseI}, condPairs, []);
    
    if exist(shuffDirFull,'dir')~=7
        mkdir(shuffDirFull)
        disp('making shuffle directory')
    end
    
    splitterFilePhase = fullfile(shuffDirFull,'splittersPhase.mat');
    if exist(splitterFilePhase,'file')==2
        disp(['found phase splitters for mouse ' num2str(mouseI)])
        load(splitterFilePhase)
    else
        disp(['did not find Phase splitting for mouse ' num2str(mouseI) ', making now'])
        [~, binsAboveShufflePhase, thisCellSplitsPhase] = SplitterWrapperDoublePlus(cellTBT{mouseI}, dimShuffle,...
                numShuffles, shuffDirFull, binEdges, minspeed, shuffThresh, binsMin);
        save(splitterFilePhase,'binsAboveShufflePhase','thisCellSplitsPhase')
    end
    
    splittersPhase{mouseI} = thisCellSplitsPhase.*dayUse{mouseI};
    binsAboveShuffPhase{mouseI} = binsAboveShufflePhase;
end

%Shuffle across starts, across finishes ('same')
dimShuffle = {'south','north';'east','west'};
for mouseI = 1:numMice    
    tic
    shuffDirFull = fullfile(mainFolder,mice{mouseI},'shuffleSame');
    condPairs = [];
    for shuffPairI = 1:size(dimShuffle,1)
        for shuffThisI = 1:size(dimShuffle,2)
            condPairs(shuffPairI,shuffThisI) = find(strcmpi({cellTBT{mouseI}(:).name},dimShuffle{shuffPairI,shuffThisI}));
        end
    end

    [rateDiffSame{mouseI}, rateSplitSame{mouseI}, meanRateDiffSame{mouseI},...
        DIeachSame{mouseI}, DImeanSame{mouseI}, DIallSame{mouseI}] =...
        LookAtSplitters4(cellTMap_unsmoothed{mouseI}, condPairs, []);
    
    if exist(shuffDirFull,'dir')~=7
        mkdir(shuffDirFull)
        disp('making shuffle directory')
    end
    
    splitterFileSame = fullfile(shuffDirFull,'splittersSame.mat');
    if exist(splitterFileSame,'file')==2
        disp(['found same splitters for mouse ' num2str(mouseI)])
        load(splitterFileSame)
    else
        disp(['did not find Same splitting for mouse ' num2str(mouseI) ', making now'])
        [~, binsAboveShuffleSame, thisCellSplitsSame] = SplitterWrapperDoublePlus(cellTBT{mouseI}, dimShuffle,...
                numShuffles, shuffDirFull, binEdges, minspeed, shuffThresh, binsMin);
        save(splitterFileSame,'binsAboveShuffleSame','thisCellSplitsSame')
    end
    toc
    
    splittersSame{mouseI} = thisCellSplitsSame.*dayUse{mouseI};
    binsAboveShuffSame{mouseI} = binsAboveShuffleSame;
end


%% Splitter breakdowns

for mouseI = 1:numMice
    nonPhaseSplitter{mouseI} = splittersPhase{mouseI}==0 & dayUse{mouseI};
    nonSameSplitter{mouseI} = splittersSame{mouseI}==0 & dayUse{mouseI};
    nonSplitter{mouseI} = nonPhaseSplitter{mouseI} & nonSameSplitter{mouseI};
    splitterBoth{mouseI} = splittersPhase{mouseI} & splittersSame{mouseI};
    
    %codes for start/end but doesnt care which
    splittersPhaseOnly{mouseI} = splittersPhase{mouseI} & splittersSame{mouseI}==0;

    %codes for only one trajectory, doesn't care start or end
    splittersSameOnly{mouseI} = splittersSame{mouseI} & splittersPhase{mouseI}==0;
end

groupNames = {'Phase','Same','PhaseOnly','SameOnly','non-Split','Split-Both'};
for mouseI = 1:numMice     
    traitGroups{mouseI} = {splittersPhase{mouseI}; splittersSame{mouseI}; splittersPhaseOnly{mouseI};...
                           splittersSameOnly{mouseI}; nonSplitter{mouseI}; splitterBoth{mouseI}};
end


%Pct each day? 
pooledSplitterProps = cell(length(traitGroups),1);
for mouseI = 1:numMice
	splitterGroupPct{mouseI} = RunGroupFunction('TraitDailyPct',traitGroups{mouseI},dayUse{mouseI});
    
    for tgI = 1:length(traitGroups)
        pooledSplitterProps{tgI} = [pooledSplitterProps{tgI}; splitterGroupPct{mouseI}{tgI}];
    end
end


%splitters coming and going?
pooledSplitPctChangeFWD = cell(1,length(traitGroups{1})); pooledDaysApartFWD = [];
for mouseI = 1:numMice
    [splitterPctDayChangesFWD{mouseI}] = RunGroupFunction('NNplusKChange',traitGroups{mouseI},dayUse{mouseI});

    daysApartFWD{mouseI} = diff(splitterPctDayChangesFWD{mouseI}(1).dayPairs,1,2);
    
    %realDaysApart cellRealDays
    
    pooledDaysApartFWD = [pooledDaysApartFWD; daysApartFWD{mouseI}];
    for tgI = 1:length(traitGroups{mouseI})
        pooledSplitPctChangeFWD{tgI} = [pooledSplitPctChangeFWD{tgI}; splitterPctDayChangesFWD{mouseI}(tgI).pctChange];
    end
end

dayPairsForward = [1 2; 1 3; 2 3];
dSame = find([ones(2,length(oneEnvMice));zeros(1,length(oneEnvMice))]);
dDiff = find([ones(2,length(twoEnvMice));zeros(1,length(twoEnvMice))]);
%Cells becoming phase splitters?
cellHere = cellfun(@(x) x>0,cellSSI,'UniformOutput',false);
cellsRegistered = RunGroupFunction('GetCellsOverlap',cellHere,cellHere,dayPairsForward);
registrationRateDiffPct = [cellsRegistered(twoEnvMice).overlapWithModel]; %(dayPair,mouseI)
registrationRateSamePct = [cellsRegistered(oneEnvMice).overlapWithModel]; %(dayPair,mouseI)
regRateSig = PermutationTestSL(registrationRateDiffPct(dDiff),registrationRateSamePct(dSame),1000) > (1 - pThresh);

becomesPhase = RunGroupFunction('GetCellsOverlap',nonPhaseSplitter,splittersPhase,dayPairsForward);
becomesPhaseDiffPct = [becomesPhase(twoEnvMice).overlapWithModel]; %(dayPair,mouseI)
becomesPhaseSamePct = [becomesPhase(oneEnvMice).overlapWithModel]; %(dayPair,mouseI)
becomesPhaseSig = PermutationTestSL(becomesPhaseDiffPct(dDiff),becomesPhaseSamePct(dSame),1000) > (1 - pThresh);

becomesSame = RunGroupFunction('GetCellsOverlap',nonSameSplitter,splittersSame,dayPairsForward);
becomesSameDiffPct = [becomesSame(twoEnvMice).overlapWithModel]; %(dayPair,mouseI)
becomesSameSamePct = [becomesSame(oneEnvMice).overlapWithModel]; %(dayPair,mouseI)
becomesSameSig = PermutationTestSL(becomesSameDiffPct(dDiff),becomesSameSamePct(dSame),1000) > (1 - pThresh);

losesPhase = RunGroupFunction('GetCellsOverlap',splittersPhase,nonPhaseSplitter,dayPairsForward);
losesPhaseDiffPct = [losesPhase(twoEnvMice).overlapWithModel]; %(dayPair,mouseI)
losesPhaseSamePct = [losesPhase(oneEnvMice).overlapWithModel]; %(dayPair,mouseI)
losesPhaseSig = PermutationTestSL(losesPhaseDiffPct(dDiff),losesPhaseSamePct(dSame),1000) > (1 - pThresh);

losesSame = RunGroupFunction('GetCellsOverlap',splittersSame,nonSameSplitter,dayPairsForward);
losesSameDiffPct = [losesSame(twoEnvMice).overlapWithModel]; %(dayPair,mouseI)
losesSameSamePct = [losesSame(oneEnvMice).overlapWithModel]; %(dayPair,mouseI)
losesSameSig = PermutationTestSL(losesSameDiffPct(dDiff),losesSameSamePct(dSame),1000) > (1 - pThresh);


%% Single cell remapping
numConds = length(cellTBT{1});

dayPairsForward = [1 2; 1 3; 2 3]; numDayPairs = size(dayPairsForward,1);
%Center of mass shift
allFiringCOM = cell(numMice,1);
oneEnvCOMchanges = cell(numDayPairs,1);
twoEnvCOMchanges = cell(numDayPairs,1);

for mouseI = 1:numMice
    allFiringCOM{mouseI} = TMapFiringCOM(cellTMap_unsmoothed{mouseI});
    
    for dpI = 1:numDayPairs
        comsA = squeeze(allFiringCOM{mouseI}(:,dayPairsForward(dpI,1),:));
        comsB = squeeze(allFiringCOM{mouseI}(:,dayPairsForward(dpI,2),:));
        COMchanges{mouseI}{dpI} = abs(comsB - comsA); %(cell, cond)
    
        %Ultimately want to compare this to a shuffle, is diff greater than suffle
        
        switch mouseI
            case num2cell(oneEnvMice)'
                oneEnvCOMchanges{dpI} = [oneEnvCOMchanges{dpI}; COMchanges{mouseI}{dpI}];%(cell, cond)
            case num2cell(twoEnvMice)'
                twoEnvCOMchanges{dpI} = [twoEnvCOMchanges{dpI}; COMchanges{mouseI}{dpI}];
        end
    end
end
histBins = 0:1:10;
oneEnvCOMchangeProps = []; twoEnvCOMchangeProps = [];
oneEnvCOMchangeCDF = []; twoEnvCOMchangeCDF = [];
for dpI = 1:numDayPairs
    for condI = 1:numConds
        oneEnvCOMchangeProps{dpI}{condI} = histcounts(oneEnvCOMchanges{dpI}(:,condI),histBins)...
            / sum(~isnan(oneEnvCOMchanges{dpI}(:,condI)));
        twoEnvCOMchangeProps{dpI}{condI} = histcounts(twoEnvCOMchanges{dpI}(:,condI),histBins)...
            / sum(~isnan(twoEnvCOMchanges{dpI}(:,condI)));
        
        oneEnvCOMchangeCDF{dpI}{condI} = CDFfromHistcounts(oneEnvCOMchangeProps{dpI}{condI});
        twoEnvCOMchangeCDF{dpI}{condI} = CDFfromHistcounts(twoEnvCOMchangeProps{dpI}{condI});
    end
end

%Rate Remapping:
maxRates = []; meanRates = []; maxRateDiffs = []; meanRateDiffs = []; pctChangeMax = []; pctChangeMean = [];
oneEnvMaxRateDiffs = cell(numDayPairs,1); oneEnvMaxRatePctChange = cell(numDayPairs,1);
twoEnvMaxRateDiffs = cell(numDayPairs,1); twoEnvMaxRatePctChange = cell(numDayPairs,1);
oneEnvMeanRateDiffs = cell(numDayPairs,1); oneEnvMeanRatePctChange = cell(numDayPairs,1);
oneEnvFiredEither = cell(numDayPairs,1); twoEnvFiredEither = cell(numDayPairs,1);
twoEnvMeanRateDiffs = cell(numDayPairs,1); twoEnvMeanRatePctChange = cell(numDayPairs,1);
for mouseI = 1:numMice
    maxRates{mouseI} = cell2mat(cellfun(@max,cellTMap_unsmoothed{mouseI},'UniformOutput',false));
    for dpI = 1:numDayPairs
        ratesA = squeeze(maxRates{mouseI}(:,dayPairsForward(dpI,1),:));
        ratesB = squeeze(maxRates{mouseI}(:,dayPairsForward(dpI,2),:));
        ratesAll = [];
        ratesAll(:,:,1) = ratesA; 
        ratesAll(:,:,2) = ratesB; 
        firedEither = sum(ratesAll,3)>0;
        maxRateDiffs{mouseI}{dpI} = max(ratesAll,[],3) - min(ratesAll,[],3);
        pctChangeMax{mouseI}{dpI} = maxRateDiffs{mouseI}{dpI} ./ max(ratesAll,[],3);
        
        switch mouseI
            case num2cell(oneEnvMice)'
                oneEnvMaxRateDiffs{dpI} = [oneEnvMaxRateDiffs{dpI}; maxRateDiffs{mouseI}{dpI}];%(cell, cond)
                oneEnvMaxRatePctChange{dpI} = [oneEnvMaxRatePctChange{dpI}; pctChangeMax{mouseI}{dpI}];
            case num2cell(twoEnvMice)'
                twoEnvMaxRateDiffs{dpI} = [twoEnvMaxRateDiffs{dpI}; maxRateDiffs{mouseI}{dpI}];
                twoEnvMaxRatePctChange{dpI} = [twoEnvMaxRatePctChange{dpI}; pctChangeMax{mouseI}{dpI}];
        end
    end
    
    meanRates{mouseI} = cell2mat(cellfun(@mean,cellTMap_unsmoothed{mouseI},'UniformOutput',false));
    for dpI = 1:numDayPairs
        mratesA = squeeze(meanRates{mouseI}(:,dayPairsForward(dpI,1),:));
        mratesB = squeeze(meanRates{mouseI}(:,dayPairsForward(dpI,2),:));
        mratesAll = [];
        mratesAll(:,:,1) = mratesA; 
        mratesAll(:,:,2) = mratesB;
        mfiredEither = sum(mratesAll,3)>0;
        meanRateDiffs{mouseI}{dpI} = max(mratesAll,[],3) - min(mratesAll,[],3);
        pctChangeMean{mouseI}{dpI} = meanRateDiffs{mouseI}{dpI} ./ max(mratesAll,[],3);
        
        switch mouseI
            case num2cell(oneEnvMice)'
                oneEnvMeanRateDiffs{dpI} = [oneEnvMeanRateDiffs{dpI}; meanRateDiffs{mouseI}{dpI}];%(cell, cond)
                oneEnvMeanRatePctChange{dpI} = [oneEnvMeanRatePctChange{dpI}; pctChangeMean{mouseI}{dpI}];
                oneEnvFiredEither{dpI} = [oneEnvFiredEither{dpI}; mfiredEither];
            case num2cell(twoEnvMice)'
                twoEnvMeanRateDiffs{dpI} = [twoEnvMeanRateDiffs{dpI}; meanRateDiffs{mouseI}{dpI}];
                twoEnvMeanRatePctChange{dpI} = [twoEnvMeanRatePctChange{dpI}; pctChangeMean{mouseI}{dpI}];
                twoEnvFiredEither{dpI} = [twoEnvFiredEither{dpI}; mfiredEither];
        end
    end
end

%Arm preference
oneEnvSameArms = cell(numDayPairs,1);
twoEnvSameArms = cell(numDayPairs,1);
for mouseI = 1:numMice
    [armPref{mouseI}] = CondFiringPreference(cellTMap_unsmoothed{mouseI});
    firedAtAll = sum(trialReli{mouseI},3)>0;
    
    for dpI = 1:numDayPairs
        firedBothDays = sum(firedAtAll(:,dayPairsForward(dpI,:)),2)==2;
        armsA = armPref{mouseI}(firedBothDays,dayPairsForward(dpI,1));
        armsB = armPref{mouseI}(firedBothDays,dayPairsForward(dpI,2));
        
        sameArm = armsA==armsB;
        sameArmPct(mouseI,dpI) = sum(sameArm)/length(sameArm);
        switch mouseI
            case num2cell(oneEnvMice)'
                oneEnvSameArms{dpI} = [oneEnvSameArms{dpI}; sameArm];
            case num2cell(twoEnvMice)'
                twoEnvSameArms{dpI} = [twoEnvSameArms{dpI}; sameArm];
        end
        
        sameArmEach{mouseI}{dpI} = sameArm;
        fbd{mouseI}{dpI} = firedBothDays;
    end
end
   
oneEnvSameArmsPct = cell2mat(cellfun(@(x) sum(x)/length(x),oneEnvSameArms,'UniformOutput',false));
twoEnvSameArmsPct = cell2mat(cellfun(@(x) sum(x)/length(x),twoEnvSameArms,'UniformOutput',false));

% Cells that totally stop/start firing
regConfirmed = 0;
oneEnvStoppedFiring = cell(numDayPairs,1);
oneEnvStartedFiring = cell(numDayPairs,1);
twoEnvStoppedFiring = cell(numDayPairs,1);
twoEnvStartedFiring = cell(numDayPairs,1);
for mouseI = 1:numMice
    firedThisCond = trialReli{mouseI}>0;
    
    for dpI = 1:numDayPairs
        firedA = squeeze(firedThisCond(:,dayPairsForward(dpI,1),:));
        firedB = squeeze(firedThisCond(:,dayPairsForward(dpI,2),:));
        
        firedAll = []; firedAll(:,:,1) = firedA; firedAll(:,:,2) = firedB;
        firedOne = sum(firedAll,3)==1;
        
        stoppedFiring = firedA & firedOne;
        startedFiring = firedB & firedOne;
        
        %Make sure both cells were there
        defHaveTheCells = cellSSI{mouseI}>0;
        haveCellsBothDays = sum(defHaveTheCells(:,dayPairsForward(dpI,:)),2)==2;
        dayPairMaxCells{mouseI}{dpI} = max(sum(defHaveTheCells(:,dayPairsForward(dpI,:)),1));
        goodReg(mouseI,dpI) = sum(haveCellsBothDays,1)/size(cellSSI{mouseI},1);
        if regConfirmed==1
            stoppedFiring(haveCellsBothDays==0) = 0;
            startedFiring(haveCellsBothDays==0) = 0;
            
            stoppedFiringAll(mouseI,dpI) = sum(sum(stoppedFiring))/(sum(haveCellsBothDays,1)*numConds);
            startedFiringAll(mouseI,dpI) = sum(sum(startedFiring))/(sum(haveCellsBothDays,1)*numConds);
        end
            %could also do this for started or stopped in each mouse independently, add them up in the section vvvvv
        
        stoppedFiringAll(mouseI,dpI) = sum(sum(stoppedFiring))/(size(stoppedFiring,1)*numConds);
        startedFiringAll(mouseI,dpI) = sum(sum(startedFiring))/(size(startedFiring,1)*numConds);
         %could be normalized by dayPairMaxCells or defHaveboth
        switch mouseI
            case num2cell(oneEnvMice)'
                oneEnvStoppedFiring{dpI} = [oneEnvStoppedFiring{dpI}; stoppedFiring];
                oneEnvStartedFiring{dpI} = [oneEnvStartedFiring{dpI}; startedFiring];
            case num2cell(twoEnvMice)'
                twoEnvStoppedFiring{dpI} = [twoEnvStoppedFiring{dpI}; stoppedFiring];
                twoEnvStartedFiring{dpI} = [twoEnvStartedFiring{dpI}; startedFiring];
        end
        
        
    end
end
 

oneEnvStoppedFiringPct = cell2mat(cellfun(@(x) sum(sum(x))/(size(x,1)*numConds),oneEnvStoppedFiring,'UniformOutput',false));
oneEnvStartedFiringPct = cell2mat(cellfun(@(x) sum(sum(x))/(size(x,1)*numConds),oneEnvStartedFiring,'UniformOutput',false));
twoEnvStoppedFiringPct = cell2mat(cellfun(@(x) sum(sum(x))/(size(x,1)*numConds),twoEnvStoppedFiring,'UniformOutput',false));
twoEnvStartedFiringPct = cell2mat(cellfun(@(x) sum(sum(x))/(size(x,1)*numConds),twoEnvStartedFiring,'UniformOutput',false));

disp('Done single cell remapping')

% Rate map correlations

% Compare 4 vs 7 to 4 vs 8 within groups

%% Remapping from assembly
load(fullfile(mainFolder,'tnc.mat'));
dayThree = [11 12 13 12 9 12];

dayPairsForwardCheck = [1 2];
% First break it down, then re-register it
ensAggYes = [];
ensAggNo = [];
for mouseI = 1:numMice
    nCells = max(cellSSI{mouseI}(:,1));
    theseCells = cellSSI{mouseI}(:,1) >0;
    try
    theseCells(nCells+1:end) = [];
    end
    
    for ii = 1:2
        mapsHere{mouseI}{ii} = tnc{mouseI}{ii}{dayThree(mouseI)}(1:nCells,1:nCells);
        ensembleT{mouseI}{ii} = mapsHere{mouseI}{ii}(cellSSI{mouseI}(theseCells,1),:);
        ensemble{mouseI}{ii} = mapsHere{mouseI}{ii}(:,cellSSI{mouseI}(theseCells,1));
    
    end
    
    for dpJ = 1:length(dayPairsForwardCheck)
        %sameArmEach{mouseI}{dpI} = sameArm;
        %fbd{mouseI}{dpI} = firedBothDays;
        dpI = dayPairsForwardCheck(dpJ);
        fbdH = fbd{mouseI}{dpI}(theseCells);
        ensH = [ensemble{mouseI}{1}(fbdH,:) ensemble{mouseI}{2}(fbdH,:)];
        
        yesArm = sameArmEach{mouseI}{dpI} == 1;
        noArm = sameArmEach{mouseI}{dpI} == 0;
        
        ensPos = sum(ensH >0,2);
        ensNan = ensH;
        ensNan(ensNan==0) = NaN;
        
        ensAggYes = [ensAggYes; ensPos(yesArm)];
        ensAggNo = [ensAggNo; ensPos(noArm)];
        %{
        figure; histogram(ensPos(yesArm))
        figure; histogram(ensPos(noArm))
        
        figure;
        cdfplot(ensPos(yesArm))
        hold on
        cdfplot(ensPos(noArm))
        [hh,pp] = kstest2(ensPos(yesArm),ensPos(noArm))
        
        
        figure; histogram(max(ensNan(yesArm),[],2))
        figure; histogram(max(ensNan(noArm),[],2))
        
        figure;
        cdfplot(max(ensNan(yesArm),[],2))
        hold on
        cdfplot(max(ensNan(noArm),[],2))
        [hh,pp] = kstest2(max(ensNan(yesArm),[],2),max(ensNan(noArm),[],2))
    
        figure; histogram(nanmean(ensNan(yesArm),2))
        figure; histogram(nanmean(ensNan(noArm),2))
        
        figure;
        cdfplot(nanmean(ensNan(yesArm),2))
        hold on
        cdfplot(nanmean(ensNan(noArm),2))
        [hh,pp] = kstest2(nanmean(ensNan(yesArm),2),nanmean(ensNan(noArm),2))
    %}
    end
end

    
%% Correlation by coactivity

armBounds2{1}.X = armBounds.north(:,1);
armBounds2{1}.Y = armBounds.north(:,2);
armBounds2{2}.X = armBounds.south(:,1);
armBounds2{2}.Y = armBounds.south(:,2);
armBounds2{3}.X = armBounds.east(:,1);
armBounds2{3}.Y = armBounds.east(:,2);
armBounds2{4}.X = armBounds.west(:,1);
armBounds2{4}.Y = armBounds.west(:,2);



coactivity = cell(1,numMice);    totalCoactivity = cell(1,numMice);
pctTrialsActive = cell(1,numMice);    trialCoactiveAboveBaseline = cell(1,numMice);
totalCoactiveAboveBaseline = cell(1,numMice);    chanceCoactive = cell(1,numMice);
singleCellCorrsRho = cell(1,numMice);    singleCellCorrsP = cell(1,numMice);

condCorrAgg = cell(1,2); [condCorrAgg{:}] = deal(cell(numConds,numDayPairs));
allCorrAgg = cell(1,2); [allCorrAgg{:}] = deal(cell(1,numDayPairs));
condCoacAgg = cell(1,2); [condCoacAgg{:}] = deal(cell(numConds,numDayPairs));
allCoacAgg = cell(1,2); [allCoacAgg{:}] = deal(cell(1,numDayPairs));
for mouseI = 1:numMice
   % [singleCellCorrsRho{mouseI}, singleCellCorrsP{mouseI}] = singleNeuronCorrelations(cellTMap_unsmoothed{mouseI},dayPairs,[]);%turnBinsUse
    %{mouseI}{condI}{dayPairI}(cellI)
   % [coactivity{mouseI},totalCoactivity{mouseI},pctTrialsActive{mouseI},trialCoactiveAboveBaseline{mouseI},totalCoactiveAboveBaseline{mouseI},chanceCoactive{mouseI}] =...
   %     findingEnsemblesNotes3(cellTBT{mouseI},armBounds2,[1;2;3;4]);
    %{dpI,condI}
    
    threshHere = 0;
    %{
    cellsActiveToday = (trialReli{mouseI} > threshHere) & (trialReli{mouseI} < 1);
    %cellsActiveToday = dayUse{mouseI};
    
    numCellsActiveToday = sum(cellsActiveToday,1);
    
    numCoactivePartners{mouseI} = cellfun(@(x) sum(x,2),totalCoactiveAboveBaseline{mouseI},'UniformOutput',false);
        % {dpI,condI}
        cellsToday = num2cell(repmat(numCellsActiveToday',1,numConds));
    pctCoactivePartners{mouseI} = cellfun(@(x,y) x/y,numCoactivePartners{mouseI},cellsToday,'UniformOutput',false);
        % {dpI,condI}
        %}
    for condI = 1:numConds
        for dpI = 1:numDayPairs
            %cellsUse = trialReli{mouseI}(:,dayPairs(dpI,1),condI)>0 & trialReli{mouseI}(:,dayPairs(dpI,2),condI)>0;
            cellsUse = cellSSI{mouseI}(:,dayPairs(dpI,1))>0 & cellSSI{mouseI}(:,dayPairs(dpI,2))>0;
            
            %{
            % Pct coactive partners/active this cond
            cellsActive = (trialReli{mouseI}(:,dayPairs(dpI,1),condI)>threshHere) & (trialReli{mouseI}(:,dayPairs(dpI,1),condI)<1);
            coactiveUse = totalCoactiveAboveBaseline{mouseI}{dayPairs(dpI,1),condI};
            %}
            xlabb = 'Pct coactive/active';
            
            % Pct coactive partners/present today
            coactiveUse = totalCoactiveAboveBaseline{mouseI}{dayPairs(dpI,1),condI};
            cellsActive = cellsUse;
            %}
            
            %{
            % Mean coactivity score/any coactive partners
            coactiveUse = coactivity{mouseI}{dayPairs(dpI,1),condI};
            cellsActive = (trialReli{mouseI}(:,dayPairs(dpI,1),condI)>threshHere) & (trialReli{mouseI}(:,dayPairs(dpI,1),condI)<1);
            xlabb = 'Mean coactivity score';
            %}
            
            cellsUse = cellsUse & cellsActive;
            numCellsHere = sum(cellsUse);
            
            coactiveHere = coactiveUse(cellsUse,:);
            coactiveHere = coactiveHere(:,cellsUse);
            
            coactiveScoreTotal = sum(coactiveHere,2);
            coactivityHere = coactiveScoreTotal/numCellsHere;
            %coactivityHere = mean(coactiveHere,2);
            
            %coactivityHere = pctCoactivePartners{mouseI}{dpI,condI}(cellsUse);
            condCoacAgg{groupNum(mouseI)}{condI,dpI} = [condCoacAgg{groupNum(mouseI)}{condI,dpI}; coactivityHere];
            allCoacAgg{groupNum(mouseI)}{dpI} = [allCoacAgg{groupNum(mouseI)}{dpI}; coactivityHere];
            
            corrsHere = singleCellCorrsRho{mouseI}{condI}{dpI}(cellsUse);
            condCorrAgg{groupNum(mouseI)}{condI,dpI} = [condCorrAgg{groupNum(mouseI)}{condI,dpI}; corrsHere];
            allCorrAgg{groupNum(mouseI)}{dpI} = [allCorrAgg{groupNum(mouseI)}{dpI}; corrsHere];
        end
    end
end

for condI = 1:numConds
    figure;
    for dpI = 1:numDayPairs
        subplot(1,numDayPairs,dpI)
        plot(condCoacAgg{condI,dpI},condCorrAgg{condI,dpI},'.')
        
        xlabel(xlabb)
        ylabel('Corr (rho)')
        title(num2str(dayPairs(dpI,:)))
    end
    suptitleSL(['Cond ' num2str(condI)])
end

figure;
for dpI = 1:numDayPairs
    subplot(1,numDayPairs,dpI)
    xplot = allCoacAgg{1}{dpI};
    yplot = allCorrAgg{1}{dpI};
    plot(xplot,yplot,'.')
    
    xlabel(xlabb)
    ylabel('Corr (rho)')
    [rr,pp] = corr(xplot,yplot,'type','Spearman');
    title(num2str([rr pp])) %num2str(dayPairs(dpI,:))
end
suptitleSL('1')

figure;
for dpI = 1:numDayPairs
    subplot(1,numDayPairs,dpI)
    xplot = allCoacAgg{2}{dpI};
    yplot = allCorrAgg{2}{dpI};
    plot(xplot,yplot,'.')
    
    xlabel(xlabb)
    ylabel('Corr (rho)')
    [pp] = corr(xplot,yplot,'type','Spearman');
    [rr,pp] = corr(xplot,yplot,'type','Spearman');
    title(num2str([rr pp])) %num2str(dayPairs(dpI,:))
end
suptitleSL('2')


