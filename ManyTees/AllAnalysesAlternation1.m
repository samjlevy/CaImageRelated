%% AllAnalysesAlternation1

disp('loading stuff')

mainFolder = 'C:\Users\Sam\Desktop\TwoMazeAlternationData';
mice = {'Marble19','Marble91'};

numMice = length(mice);

for mouseI = 1:numMice
    load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'))
    
    cellTBT{mouseI} = trialbytrial;
    cellSSI{mouseI} = sortedSessionInds;
    cellPresent{mouseI} = cellSSI{mouseI} > 0;
    cellAllFiles{mouseI} = allfiles;
    cellRealDays{mouseI} = realdays;
    
    clear trialbytrial sortedSessionInds allFiles realdays
end

for mouseI = 1:numMice
    saveName = fullfile(mainFolder,mice{mouseI},'trialReliability.mat');
    if exist(saveName,'file')==0
        [dayUse,threshAndConsec] = GetUseCells(cellTBT{mouseI}, 0.25, 3);
        [trialReli,aboveThresh,~,~] = TrialReliability(cellTBT{mouseI}, 0.25);
        
        save(saveName,'dayUse','threshAndConsec','trialReli')
        clear('dayUse','threshAndConsec','dayUseArm','threshAndConsecArm','trialReli','trialReliArm')
    end
end
for mouseI = 1:numMice
    saveName = fullfile(mainFolder,mice{mouseI},'trialReliability.mat');
    dd = load(saveName);
    dayUse{mouseI} = dd.dayUse;
    threshAndConsec{mouseI} = dd.threshAndConsec;
    trialReli{mouseI} = dd.trialReli;
end

stemPFs = 'PFsLinStem.mat';
load(fullfile(mainFolder,'stemLims.mat'))
stemLims = round(stemLims);
numBins = 10;
stemBinEdges = linspace(stemLims(1),stemLims(2),numBins+1);
minspeed = [];
for mouseI = 1:numMice
    saveName = fullfile(mainFolder,mice{mouseI},stemPFs);
    switch exist(saveName,'file')
        case 0
            disp(['no pooled placefields found for ' mice{mouseI} ', making now'])
            [~, ~, ~, ~, ~, ~, ~] =...
           PFsLinTBTalternation(cellTBT{mouseI}, stemBinEdges, minspeed, saveName, false,[1;2;3;4],'y');
       case 2
            disp(['found pooled placefields for ' mice{mouseI} ', all good'])
    end
    
    load(fullfile(mainFolder,mice{mouseI},stemPFs),'TMap_unsmoothed','TMap_zRates','TCounts','RunOccMap')
    cellTMap_unsmoothed{1}{mouseI} = TMap_unsmoothed;
    %cellPooledTMap_firesAtAll{1}{mouseI} = TMap_firesAtAll;
    cellTMap_zRates{1}{mouseI} = TMap_unsmoothed; 
    cellTCounts{1}{mouseI} = TCounts;
    cellRunOccMap{1}{mouseI} = RunOccMap;
end

disp('Done loading stuff')

%% Splitters
pThresh = 0.05;
numShuffles = 1000;
binsAboveShuffle = [];
shuffThresh = 1 - pThresh;
thisCellSplits = [];
for mouseI = 1:numMice
    splitterFile = fullfile(mainFolder,mice{mouseI},'splitLR.mat');
    
    if exist(splitterFile,'file')==0
        disp(['making splitters for ' mice{mouseI}])
        [binsAboveShuffle, numBinsAboveShuffle, thisCellSplits] = SplitterWrapper5(cellTBT{mouseI}, cellTMap_unsmoothed{1}{mouseI},...
            'LR','unpooled', numShuffles, stemBinEdges, [], shuffThresh, 1,'Y');
        
        [rateDiff, rateSplit, meanRateDiff, DIeach, DImean, DIall] = LookAtSplitters4(cellTMap_unsmoothed{1}{mouseI},[1 2;3 4],[]);
        
        save(splitterFile,'binsAboveShuffle','thisCellSplits','numBinsAboveShuffle','rateDiff','rateSplit','meanRateDiff','DIeach','DImean','DIall')
    else
        disp(['found splitters for ' mice{mouseI}])
    end
    
    ss = load(splitterFile);
    binsAboveShuffle{mouseI} = ss.binsAboveShuffle;
    numBinsAboveShuffle{mouseI} = ss.numBinsAboveShuffle;
    thisCellSplits{mouseI} = ss.thisCellSplits;
    rateDiff{mouseI} = ss.rateDiff;
    rateSplit{mouseI} = ss.rateSplit; 
    meanRateDiff{mouseI} = ss.meanRateDiff;
    DIeach{mouseI} = ss.DIeach;
    DImean{mouseI} = ss.DImean;
    DIall{mouseI} = ss.DIall; 
end

disp('Done loading splitters')

%% Decoding analysis: one maze turn dir from the other?




