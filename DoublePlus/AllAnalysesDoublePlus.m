%AllAnalysesDoublePlus

mainFolder = 'G:\DoublePlus';
mice = {'Kerberos','Marble07','Marble11','Pandora','Styx','Titan'};
numMice = length(mice);

load(fullfile(mainFolder,'groupAssign.mat'))

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
    [dayUse{mouseI},threshAndConsec{mouseI}] = GetUseCells(cellTBT{mouseI}, lapPctThresh, consecLapThresh);
    [trialReli{mouseI},aboveThresh{mouseI},~,~] = TrialReliability(cellTBT{mouseI}, lapPctThresh);
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
            PFsLinTBTdoublePlus(cellTBT{mouseI}, binEdges, minspeed, saveName, 'smth',false,'trialReli',trialReli{mouseI}); %'trialReli',trialReli{mouseI},
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

%% Pop vector corr analysis (most basic)
cellsUseOption = 'activeEither';
corrType = 'Spearman';

condPairs = [1 1; 2 2; 3 3; 4 4]; numCondPairs = size(condPairs,1);
dayPairs = [1 2; 1 3; 2 3]; numDayPairs = size(dayPairs,1);

traitLogical = threshAndConsec;
pvCorrs = cell(numMice,1); 
meanCorr = cell(numMice,1); 
numCellsUsed = cell(numMice,1); 
numNan = cell(numMice,1); 

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

groupNames = unique(groupAssign(:,2));
diffMice = find(strcmpi('diff',groupAssign(:,2)));
sameMice = find(strcmpi('same',groupAssign(:,2)));

for cpI = 1:numCondPairs
    for dpI = 1:numDayPairs
        sameMicePVcorrs{dpI,cpI} = pooledPVcorrs{dpI,cpI}(sameMice,:);
        sameMicePVcorrsMeans{dpI,cpI} = mean(sameMicePVcorrs{dpI,cpI},1);
        
        diffMicePVcorrs{dpI,cpI} = pooledPVcorrs{dpI,cpI}(diffMice,:);
        diffMicePVcorrsMeans{dpI,cpI} = mean(diffMicePVcorrs{dpI,cpI},1);
        
        sameMinusDiff{dpI,cpI} = sameMicePVcorrsMeans{dpI,cpI} - diffMicePVcorrsMeans{dpI,cpI};
        
        for binI = 1:numBins
            %[pPVs{dpI,cpI}(binI),hPVs{dpI,cpI}(binI)] = ranksum(sameMicePVcorrs{dpI,cpI}(:,binI),diffMicePVcorrs{dpI,cpI}(:,binI));
        end
        
        diffRank{dpI,cpI} = PermutationTestSL(sameMicePVcorrs{dpI,cpI},diffMicePVcorrs{dpI,cpI},numPerms);
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

for mouseI = 1:numMice
    for dcI = 1:numDayChunks
        trimmedTBT = SlimDownTBT(cellTBT{mouseI},dayChunks(dcI,:));

        [TMapTrimmed, ~, ~, ~, ~, ~, ~] =...
            PFsLinTBTdoublePlus(trimmedTBT, binEdges, minspeed, [], 'smth',false,'trialReli',trialReli{mouseI}); %'trialReli',trialReli{mouseI},

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

sameMiceTrimPVcorrs = cell(numDayChunks,numDayPairs,numCondPairs);
sameMiceTrimPVcorrsMeans = cell(numDayChunks,numDayPairs,numCondPairs);
diffMiceTrimPVcorrs = cell(numDayChunks,numDayPairs,numCondPairs);
diffMiceTrimPVcorrsMeans = cell(numDayChunks,numDayPairs,numCondPairs);
diffMinusSameTrim = cell(numDayChunks,numDayPairs,numCondPairs);
        
for dcI = 1:numDayChunks
for cpI = 1:numCondPairs
    for dpI = 1:numDayPairs
        sameMiceTrimPVcorrs{dcI,dpI,cpI} = trimPooledPVcorrs{dcI,dpI,cpI}(sameMice,:);
        sameMiceTrimPVcorrsMeans{dcI,dpI,cpI} = mean(sameMiceTrimPVcorrs{dcI,dpI,cpI},1);
        
        diffMiceTrimPVcorrs{dcI,dpI,cpI} = trimPooledPVcorrs{dcI,dpI,cpI}(diffMice,:);
        diffMiceTrimPVcorrsMeans{dcI,dpI,cpI} = mean(diffMiceTrimPVcorrs{dcI,dpI,cpI},1);
        
        diffMinusSameTrim{dcI,dpI,cpI} = sameMiceTrimPVcorrsMeans{dcI,dpI,cpI} - diffMiceTrimPVcorrsMeans{dcI,dpI,cpI};
        
        diffRank{dcI,dpI,cpI} = PermutationTestSL(sameMicePVcorrs{dcI,dpI,cpI},diffMicePVcorrs{dcI,dpI,cpI},numPerms);
        isSig{dcI,dpI,cpI} = diffRank{dcI,dpI,cpI} > (1-pThresh);
    end
end
end



%% Splitter cells? 
numShuffles = 1000;
%numShuffles = 100;
shuffThresh = 1 - pThresh;
binsMin = 1;

%Shuffle between start arm and finish arm
dimShuffle = {'south','east';'north','west'};
for mouseI = 1:numMice    
    tic
    shuffDirFull = fullfile(mainFolder,mice{mouseI},'shuffleSame');
    condPairs = [];
    for shuffPairI = 1:size(dimShuffle,1)
        for shuffThisI = 1:size(dimShuffle,2)
            condPairs(shuffPairI,shuffThisI) = find(strcmpi({cellTBT{mouseI}(:).name},dimShuffle{shuffPairI,shuffThisI}));
        end
    end

    [rateDiffSame{mouseI}, rateSplitSame{mouseI}, meanRateDiffSame{mouseI}, DIeachSame{mouseI}, DImeanSame{mouseI}, DIallSame{mouseI}] =...
        LookAtSplitters4(cellTMap_unsmoothed{mouseI}, condPairs, []);
    
    if exist(shuffDirFull,'dir')~=7
        mkdir(shuffDirFull)
        disp('making shuffle directory')
    end
    
    splitterFileSame = fullfile(shuffDirFull,'splittersSame.mat');
    if exist(splitterFileSame,'file')==2
        load(splitterFileSame)
    else
        disp(['did not find Same splitting for mouse ' num2str(mouseI) ', making now'])
        [~, binsAboveShuffleSame, thisCellSplitsSame] = SplitterWrapperDoublePlus(cellTBT{mouseI}, dimShuffle,...
                numShuffles, shuffDirFull, binEdges, minspeed, trialReli{mouseI}, shuffThresh, binsMin);
        save(splitterFileSame,'binsAboveShuffleSame','thisCellSplitsSame')
    end
    toc
end
%Shuffle across starts, across finishes
dimShuffle = {'south','north';'east','west'};
        






