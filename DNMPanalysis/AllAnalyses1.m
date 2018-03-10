%% Process all data

mainFolder = 'C:\Users\Sam\Desktop\DNMPfinalData';
mice = {'Bellatrix', 'Polaris', 'Calisto'}; %'Europa'
numMice = length(mice);

%Thresholds
pThresh = 0.05;
lapPctThresh = 0.25;
consecLapThresh = 3;
xlims = [25.5 56];
minspeed = 0; 
zeronans = 1; 
posThresh = 3;
numBins = 8;
cmperbin = (max(xlims)-min(xlims))/numBins;

disp('Loading stuff')
for mouseI = 1:numMice
    
    load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'))
    cellTBT{mouseI} = trialbytrial;
    cellSSI{mouseI} = sortedSessionInds;
    cellAllFiles{mouseI} = allfiles;
    
    numDays(mouseI) = size(cellSSI{mouseI},2);
    numCells(mouseI) = size(cellSSI{mouseI},1);
    clear trialbytrial sortedSessionInds allFiles
    disp(['Mouse ' num2str(mouseI) ' completed'])
end

maxDays = max(numDays);

disp('Getting Accuracy')
for mouseI = 1:numMice
    accuracy{mouseI} = sessionAccuracy(cellAllFiles{mouseI});
    accuracyRange(mouseI, 1:2) = [mean(accuracy{mouseI}),...
        std(accuracy{mouseI})/sqrt(length(accuracy{mouseI}))];
end

for mouseI = 1:numMice
    [xMax(mouseI,:), xMin(mouseI,:)] = GetTBTlims(cellTBT{mouseI});
end

disp('Getting reliability')
dayUse = cell(1,numMice); threshAndConsec = cell(1,numMice);
for mouseI = 1:numMice
    [dayUse{mouseI},threshAndConsec{mouseI}] = GetUseCells(cellTBT{mouseI}, lapPctThresh, consecLapThresh);
    [trialReli{mouseI},aboveThresh{mouseI},~,~] = TrialReliability(cellTBT{mouseI}, lapPctThresh);
    cellsActiveToday{mouseI} = sum(dayUse{mouseI},1);
    %disp(['Mouse ' num2str(mouseI) ' completed'])
end

%Place fields
for mouseI = 1:numMice
    saveName = fullfile(mainFolder,mice{mouseI},'PFsLin2.mat');
    switch exist(fullfile(mainFolder,mice{mouseI},'PFsLin.mat'),'file')
        case 0
            disp(['no placefields found for ' mice{mouseI} ', making now'])
            %[~, ~, ~, ~, ~] =... 
            %    PFsLinTrialbyTrial(cellTBT{mouseI},xlims, cmperbin, minspeed, 1, saveName, trialReli{mouseI});
            [~, ~, ~, ~, ~, ~] =...
            PFsLinTrialbyTrial2(cellTBT{mouseI}, xlims, cmperbin, minspeed,...
                saveName,'trialReli',trialReli{mouseI},'smooth',false);        
        case 2
            disp(['found placefields for ' mice{mouseI} ', all good'])
    end
end

Conds = GetTBTconds(cellTBT{1});
disp('Done set-up stuff')
%% Plot rasters for all good cells

for mouseI = 1:numMice
    saveDir = fullfile(mainFolder,mice{mouseI});
    cellsUse = find(sum(dayUse{mouseI},2)>0);
    PlotRastersPDF(cellTBT{mouseI}, cellSSI{mouseI}, cellAllFiles{mouseI}, cellsUse, saveDir, mice{mouseI});
end


%% Single Cells Stats

% How many cells per day? 
% How many days to cells persist for?
% How many cells above activity threshold per day?
%       - How many laps are the active for, how many consecutive?
%       - How many conditions do they tend to pass criteria for?
numCellsToday = cell(1,numMice); cellsTodayRange = zeros(numMice,2);
cellPersistHist = cell(1,numMice); cellPersistRange = zeros(numMice,2);
dailyNCAmean = nan(numMice,maxDays); dailyNCAsem = nan(numMice,maxDays);

for mouseI = 1:numMice
    %Number of cells
    numCellsToday{mouseI} = sum(cellSSI{mouseI} > 0,1);
    cellsTodayRange(mouseI,1:2) = [mean(numCellsToday{mouseI}),...
        std(numCellsToday{mouseI})/sqrt(length(numCellsToday{mouseI}))];
    
    %Cell persistance
    cellPersistHist{mouseI} = sum(cellSSI{mouseI} > 0,2);
    cellPersistRange(mouseI, 1:2) = [mean(cellPersistHist{mouseI}), standarderrorSL(cellPersistHist{mouseI})];
    cellsThatReturn(mouseI, 1) = sum(cellPersistHist{mouseI} > 1);
    cellsThatReturn(mouseI, 2) = cellsThatReturn(mouseI, 1)/sum(cellPersistHist{mouseI} > 0);
    % pct cells each day that can be found another day, related to accuracy
    
    %Cells active each day
    %[dayUse{mouseI},threshAndConsec{mouseI}] = GetUseCells(cellTBT{mouseI}, lapPctThresh, consecLapThresh);
    daysEachCellActive{mouseI} = sum(dayUse{mouseI},2);
    daysECArange(mouseI,1:2) = [mean(daysEachCellActive{mouseI}),standarderrorSL(daysEachCellActive{mouseI})];
    cellsActiveToday{mouseI} = sum(dayUse{mouseI},1);
    cellsActivePct{mouseI} = cellsActiveToday{mouseI}./numCellsToday{mouseI};
    cellsActivePctRange(mouseI,1:2) = [mean(cellsActivePct{mouseI}), standarderrorSL(cellsActivePct{mouseI})];
    
    %When are the cells active
    numCondsActive{mouseI} = sum(threshAndConsec{mouseI},3);
    cellsThatReturnIDs{mouseI} = cellPersistHist{mouseI} > 1;
    for dayI = 1:numDays(mouseI)
        dailyNumCondsActiveCells{mouseI,dayI} = numCondsActive{mouseI}(logical(dayUse{mouseI}(:,dayI)), dayI); 
        dailyNCAmean(mouseI,dayI) = mean(dailyNumCondsActiveCells{mouseI,dayI});
        dailyNCAsem(mouseI,dayI) = standarderrorSL(dailyNumCondsActiveCells{mouseI,dayI});
         
        dailyOnlyActiveOneRaw(mouseI, dayI) = sum(dailyNumCondsActiveCells{mouseI, dayI}==1); %Raw number
        dailyOnlyActiveOnePct(mouseI, dayI) = dailyOnlyActiveOneRaw(mouseI, dayI)/length(dailyNumCondsActiveCells{mouseI, dayI}); %Percent
         
        dayCellsThatReturn{mouseI}(dayI) = sum((cellSSI{mouseI}(:,dayI) > 0).*cellsThatReturnIDs{mouseI});
        
    end
    dayCellsThatReturnPct{mouseI} = dayCellsThatReturn{mouseI}./numCellsToday{mouseI};
    dayCellsThatReturnRange(mouseI,1:2) = [mean(dayCellsThatReturn{mouseI}) standarderrorSL(dayCellsThatReturn{mouseI})];
    dayCellsThatReturnPctRange(mouseI,1:2) = [mean(dayCellsThatReturnPct{mouseI}) standarderrorSL(dayCellsThatReturnPct{mouseI})];
    
    numCondsActiveRange(mouseI, 1:2) = [nanmean(dailyNCAmean(mouseI,:)), standarderrorSL(dailyNCAmean(mouseI,~isnan(dailyNCAmean(mouseI,:))))];
    activeMoreThanOneRange(mouseI, 1:2) = ...
        [mean(dailyOnlyActiveOnePct(mouseI,dailyOnlyActiveOnePct(mouseI,:) > 0))...
         standarderrorSL(dailyOnlyActiveOnePct(mouseI,dailyOnlyActiveOnePct(mouseI,:) > 0))];
    
    %likelihood of a cell being active in the same number of conditions
    %each day found
    for cellI = 1:size(dayUse{mouseI},1)
        notZeroHere = dayUse{mouseI}(cellI,:);
        cellCondsActiveRange{mouseI}(cellI,1:2) =...
            [mean(numCondsActive{mouseI}(cellI,notZeroHere)), standarderrorSL(numCondsActive{mouseI}(cellI,notZeroHere))];
    end
    cellsUse = daysEachCellActive{mouseI}>1;
    allCellCondsActiveRange(mouseI, 1:2) =...
        [nanmean(cellCondsActiveRange{mouseI}(cellsUse,1)) nanstandarderrorSL(cellCondsActiveRange{mouseI}(cellsUse,1))];
    %This number may not be meaningful given that majority of numberCondsActive is 1; 
end

for mouseI = 1:numMice
    [trialReli{mouseI},~,~,~] = TrialReliability(cellTBT{mouseI}, lapPctThresh);
    [maxConsec{mouseI}, ~] = ConsecutiveLaps(cellTBT{mouseI}, consecLapThresh);
    
    %Histograms to look at trial reliability and number of maxConsecutive
    %laps
end

%% Splitter Cells: ANOVA version
for mouseI = 1:numMice
    TMap_unsmoothed = [];
    load(fullfile(mainFolder,mice{mouseI},'PFsLin.mat'),'TMap_unsmoothed')
    cellTMap{mouseI} = TMap_unsmoothed;
end

condPairs = [1 2; 3 4; 1 3; 2 4]; %Study LvR, Test LvR, Left SvT, Right SvT

%Find out if a cell splits
for mouseI = 1:numMice
    [discriminationIndex{mouseI}, anov{mouseI}] = LookAtSplitters3(cellTMap{mouseI}, condPairs);
    
    cellSplitsAtAll{mouseI} = zeros(size(anov{mouseI}.p(:,:,1)));
    for cpI = 1:size(condPairs,1)
        thisCellSplits{mouseI}{cpI} = anov{mouseI}.p(:,:,cpI) < pThresh;
        cellSplitsAtAll{mouseI} = cellSplitsAtAll{mouseI} + thisCellSplits{mouseI}{cpI};
        
        cellsUse = logical(sum(threshAndConsec{mouseI}(:,:,condPairs(cpI,:)),3) > 0); %Activity thresholded
        numSplitters{mouseI}(cpI,1:numDays(mouseI)) = sum(thisCellSplits{mouseI}{cpI}.*cellsUse,1);
        pctSplitters{mouseI}(cpI,1:numDays(mouseI)) = numSplitters{mouseI}(cpI,:)./sum(cellsUse,1);
        
        thisCellSplits{mouseI}{cpI} = logical(thisCellSplits{mouseI}{cpI}.*dayUse{mouseI}); %Activity threshold. Probably fine here?
    end
    
end
 
%Get logical splitting kind
for mouseI = 1:numMice
    splittersLR{mouseI} = thisCellSplits{mouseI}{1} + thisCellSplits{mouseI}{2} > 0;
    splittersST{mouseI} = thisCellSplits{mouseI}{3} + thisCellSplits{mouseI}{4} > 0;

    [splittersLRonly{mouseI}, splittersSTonly{mouseI}, splittersBOTH{mouseI},...
        splittersOne{mouseI}, splittersNone{mouseI}] = ...
        GetSplittingTypes(splittersLR{mouseI}, splittersST{mouseI});
    
    cellsActiveToday{mouseI} = sum(dayUse{mouseI},1);
    splitterProps{mouseI} = [sum(splittersNone{mouseI},1)./cellsActiveToday{mouseI};... %None
                             sum(splittersLRonly{mouseI},1)./cellsActiveToday{mouseI};... %LR only
                             sum(splittersSTonly{mouseI},1)./cellsActiveToday{mouseI};... %ST only
                             sum(splittersBOTH{mouseI},1)./cellsActiveToday{mouseI}]; %Both only
end


%Daily splitter ranges
for mouseI = 1:numMice
    numDailySplittersLR{mouseI} = sum(splittersLR{mouseI},1);
    rangeDaliSplittersLR(mouseI,:) = [mean(numDailySplittersLR{mouseI}) standarderrorSL(numDailySplittersLR{mouseI})];
    pctDailySplittersLR{mouseI} = stuff;
end

%Evaluate splitting: days bias numbers and center of mass per cell
for mouseI = 1:numMice
    [splitterLR{mouseI}, splitterST{mouseI}, splitterBOTH{mouseI}] =...
        SplitterCenterOfMass(dayUse, splittersLR, splittersST, splittersBOTH);  
end

%% Splitter cells: Shuffle versions

numShuffles = 1000;
shuffThresh = 1 - pThresh;
binsMin = 1;
shuffleDirLR = 'shuffleLR';
shuffleDirST = 'shuffleST';

%Left/Right
for mouseI = 1:numMice
    shuffDirFullLR = fullfile(mainFolder,mice{mouseI},shuffleDirLR);
    load(fullfile(mainFolder,mice{mouseI},'PFsLin.mat'),'TMap_unsmoothed')
    [rateDiffLR{mouseI}, rateSplitLR{mouseI}, meanRateDiffLR{mouseI}, DIeachLR{mouseI}, DImeanLR{mouseI}] =...
        LookAtSplitters4(TMap_unsmoothed,[1 2; 3 4],trialReli{mouseI});
    [binsAboveShuffleLR, thisCellSplitsLR] = SplitterWrapper2(cellTBT{mouseI}, TMap_unsmoothed,...
    'leftright', numShuffles, shuffDirFullLR, xlims, cmperbin, minspeed, trialReli{mouseI}, shuffThresh, binsMin);
    save(fullfile(shuffDirFullLR,'splittersLR.mat'),'binsAboveShuffleLR','thisCellSplitsLR')
end

% Study/Test
for mouseI = 1:numMice
    shuffDirFullST = fullfile(mainFolder,mice{mouseI},shuffleDirST);
    load(fullfile(mainFolder,mice{mouseI},'PFsLin.mat'),'TMap_unsmoothed')
    [rateDiffST{mouseI}, rateSplitST{mouseI}, meanRateDiffST{mouseI}, DIeachST{mouseI}, DImeanST{mouseI}] =...
        LookAtSplitters4(TMap_unsmoothed,[1 3; 2 4],trialReli{mouseI});
    [binsAboveShuffleST, thisCellSplitsST] = SplitterWrapper2(cellTBT{mouseI}, TMap_unsmoothed,...
    'studytest', numShuffles, shuffDirFullST, xlims, cmperbin, minspeed, trialReli{mouseI}, shuffThresh, binsMin);
    save(fullfile(shuffDirFullST,'splittersST.mat'),'binsAboveShuffleST','thisCellSplitsST')
end

%Get logical splitting kind
for mouseI = 1:numMice
    
    splittersLR{mouseI} = (thisCellSplitsLR{mouseI} + dayUse{mouseI}) ==2;
    splittersST{mouseI} = (thisCellSplitsST{mouseI} + dayUse{mouseI}) ==2;
    splittersANY{mouseI} = (splittersLR{mouseI} + splittersST{mouseI}) > 0;
    [splittersLRonly{mouseI}, splittersSTonly{mouseI}, splittersBOTH{mouseI},...
        splittersOne{mouseI}, splittersNone{mouseI}] = ...
        GetSplittingTypes(splittersLR{mouseI}, splittersST{mouseI}, dayUse{mouseI});
    
    cellsActiveToday{mouseI} = sum(dayUse{mouseI},1);
    splitterProps{mouseI} = [sum(splittersNone{mouseI},1)./cellsActiveToday{mouseI};... %None
                             sum(splittersLRonly{mouseI},1)./cellsActiveToday{mouseI};... %LR only
                             sum(splittersSTonly{mouseI},1)./cellsActiveToday{mouseI};... %ST only
                             sum(splittersBOTH{mouseI},1)./cellsActiveToday{mouseI}]; %Both only
end

%Evaluate splitting: days bias numbers and center of mass per cell
for mouseI = 1:numMice
    [splitterLR{mouseI}, splitterST{mouseI}, splitterBOTH{mouseI}] =...
        SplitterCenterOfMass(dayUse{mouseI}, splittersLR{mouseI}, splittersST{mouseI}, splittersBOTH{mouseI});
    [splitterLRonly{mouseI}, splitterSTonly{mouseI}, ~] =...
        SplitterCenterOfMass(dayUse{mouseI}, splittersLRonly{mouseI}, splittersSTonly{mouseI}, splittersBOTH{mouseI});  

end

%Daily splitter ranges
for mouseI = 1:numMice
    everSplitANY{mouseI} = sum(sum(splittersANY{mouseI},2) > 0);
    
    %Should generalize this
    numDailySplittersLR{mouseI} = sum(splittersLR{mouseI},1);
    daysSplitLR{mouseI} = sum(splittersLR{mouseI},2);
    rangeDailySplittersLR(mouseI,:) = [mean(numDailySplittersLR{mouseI}) standarderrorSL(numDailySplittersLR{mouseI})];
    pctDailySplittersLR{mouseI} = numDailySplittersLR{mouseI}./cellsActiveToday{mouseI};
    rangePctDailySplittersLR(mouseI,:) = [mean(pctDailySplittersLR{mouseI}) standarderrorSL(pctDailySplittersLR{mouseI})];
    splitAllDaysLR{mouseI} = splitterLR{mouseI}.dayBias/sum(sum(dayUse{mouseI},2) > 1); %ever splitLR/cells active at least 2 days
    
    numDailySplittersST{mouseI} = sum(splittersST{mouseI},1);
    daysSplitST{mouseI} = sum(splittersST{mouseI},2);
    rangeDailySplittersST(mouseI,:) = [mean(numDailySplittersST{mouseI}) standarderrorSL(numDailySplittersST{mouseI})];
    pctDailySplittersST{mouseI} = numDailySplittersST{mouseI}./cellsActiveToday{mouseI};
    rangePctDailySplittersST(mouseI,:) = [mean(pctDailySplittersST{mouseI}) standarderrorSL(pctDailySplittersST{mouseI})];
    splitAllDaysST{mouseI} = splitterST{mouseI}.dayBias/sum(sum(dayUse{mouseI},2) > 1); %ever splitST/cells active at least 2 days
    
    numDailySplittersBOTH{mouseI} = sum(splittersBOTH{mouseI},1);
    daysSplitBOTH{mouseI} = sum(splittersBOTH{mouseI},2);
    rangeDailySplittersBOTH(mouseI,:) = [mean(numDailySplittersBOTH{mouseI}) standarderrorSL(numDailySplittersBOTH{mouseI})];
    pctDailySplittersBOTH{mouseI} = numDailySplittersBOTH{mouseI}./cellsActiveToday{mouseI};
    rangePctDailySplittersBOTH(mouseI,:) = [mean(pctDailySplittersBOTH{mouseI}) standarderrorSL(pctDailySplittersBOTH{mouseI})];
    splitAllDaysBOTH{mouseI} = splitterBOTH{mouseI}.dayBias/sum(sum(dayUse{mouseI},2) > 1); %ever splitBOTH/cells active at least 2 days
    
    numDailySplittersLRonly{mouseI} = sum(splittersLRonly{mouseI},1);
    daysSplitLRonly{mouseI} = sum(splittersLRonly{mouseI},2);
    rangeDailySplittersLRonly(mouseI,:) = [mean(numDailySplittersLRonly{mouseI}) standarderrorSL(numDailySplittersLRonly{mouseI})];
    pctDailySplittersLRonly{mouseI} = numDailySplittersLRonly{mouseI}./cellsActiveToday{mouseI};
    rangePctDailySplittersLRonly(mouseI,:) = [mean(pctDailySplittersLRonly{mouseI}) standarderrorSL(pctDailySplittersLRonly{mouseI})];
    splitAllDaysLRonly{mouseI} = splitterLRonly{mouseI}.dayBias/sum(sum(dayUse{mouseI},2) > 1); %ever splitBOTH/cells active at least 2 days

    numDailySplittersSTonly{mouseI} = sum(splittersSTonly{mouseI},1);
    daysSplitSTonly{mouseI} = sum(splittersSTonly{mouseI},2);
    rangeDailySplittersSTonly(mouseI,:) = [mean(numDailySplittersSTonly{mouseI}) standarderrorSL(numDailySplittersSTonly{mouseI})];
    pctDailySplittersSTonly{mouseI} = numDailySplittersSTonly{mouseI}./cellsActiveToday{mouseI};
    rangePctDailySplittersSTonly(mouseI,:) = [mean(pctDailySplittersSTonly{mouseI}) standarderrorSL(pctDailySplittersSTonly{mouseI})];
    splitAllDaysSTonly{mouseI} = splitterSTonly{mouseI}.dayBias/sum(sum(dayUse{mouseI},2) > 1); %ever splitBOTH/cells active at least 2 days
end



%% Place Cells
numShuffles = 1000; %takes about an hour
% Shuffle within a condition for peak place firing
shuffleDir = 'ShufflePos';


%Make position shuffles
for mouseI = 1:numMice
    
    allTMap_shuffled = cell(numShuffles,1);
    shuffDirFull = fullfile(mainFolder,mice{mouseI},shuffleDir);
    if ~exist(shuffDirFull,'dir')
        mkdir(shuffDirFull)
    end
    
    for shuffleI = 1:numShuffles
        shuffledTBT = shuffleTBTposition(cellTBT{mouseI});
        saveName = fullfile(shuffDirFull,['shuffPos' num2str(shuffleI) '.mat']);
        %[~, ~, ~, allTMap_shuffled{shuffleI}, ~] =... 
        %            PFsLinTrialbyTrial(shuffledTBT,xlims, cmperbin, minspeed, 1, saveName, trialReli{mouseI});
        [~, ~, ~, ~, ~, ~] =...
            PFsLinTrialbyTrial2(shuffledTBT, xlims, cmperbin, minspeed,...
                saveName,'trialReli',trialReli{mouseI},'smooth',false); 
        disp(['done shuffle ' num2str(shuffleI) ])
   
    end
    save(fullfile(shuffDirFull,'allTMap_shuffled.mat'),'allTMap_shuffled')
end


%Load shuffles, organize, check placefields
for mouseI = 1:numMice
    %Load reorganized shuffles
    shuffDirFull = fullfile(mainFolder,mice{mouseI},shuffleDir);
    if exist(fullfile(shuffDirFull,'allShuffledRates.mat'),'file')==2
        load(fullfile(shuffDirFull,'allShuffledRates.mat'))
    else
        disp('Could not find all tmap shuffled, loading shuffled PFs')
        shuffFiles = dir([shuffDirFull '\shuffPos*.mat']);
        shuffFiles([shuffFiles.isdir]) = [];
        
        tic
        allTMap_shuffled = cell(length(shuffFiles),1);
        for fileI = 1:length(shuffFiles) %Takes a few minues with 1000 shuffles
            TMap_unsmoothed = [];
            load(fullfile(shuffDirFull,shuffFiles(fileI).name),'TMap_unsmoothed')
            allTMap_shuffled{fileI} = TMap_unsmoothed;
        end
        toc
        %save((fullfile(shuffDirFull,'allTMap_shuffled.mat')),'allTMap_shuffled','-v7.3')
        %disp('Saved allTMap_shuffled')
    
        %Reorganize to make sorting, etc. easier
        numBins = length(allTMap_shuffled{1}{1,1,1});
        nShuffles = length(allTMap_shuffled);
        allShuffledRates = cell(numCells(mouseI),4,numDays(mouseI));
        tic
        for cellI = 1:numCells(mouseI) %Takes a few minues with 1000 shuffles
            for condI = 1:4
                for dayI = 1:numDays(mouseI)
                    allShuffledRates{cellI,condI,dayI} = nan(nShuffles, numBins);
                    for shuffI = 1:nShuffles
                        allShuffledRates{cellI,condI,dayI}(shuffI,:) = allTMap_shuffled{shuffI}{cellI,condI,dayI};
                    end
                end
            end
        end
        toc         
        
        save(fullfile(shuffDirFull,'allShuffledRates.mat'),'allShuffledRates','-v7.3')
        disp('Saved allShuffledRates')
        allTMap_shuffled = [];
    end
    
    %Sort, etc. 
    tic
    shuffledRatesSorted = cell(size(allShuffledRates));
    shuffledRatesMean = cell(size(allShuffledRates));
    shuffledRates95 = cell(size(allShuffledRates));
    pInd = round((1-pThresh)*nShuffles);
    
    for cellI = 1:numCells(mouseI) %Takes a few minues with 1000 shuffles
        for condI = 1:4
            for dayI = 1:numDays(mouseI)
                shuffledRatesSorted{cellI,condI,dayI} = sort(allShuffledRates{cellI,condI,dayI},1);
                shuffledRatesMean{cellI,condI,dayI} = nanmean(shuffledRatesSorted{cellI,condI,dayI},1); %Uses nanmean
                shuffledRates95{cellI,condI,dayI} = shuffledRatesSorted{cellI,condI,dayI}(pInd,:);
            end
        end
    end
    save(fullfile(shuffDirFull,'shuffledRatesSorted.mat'),'shuffledRatesSorted','-v7.3')
    disp('Saved shuffledRatesSorted')
    toc
    
    load(fullfile(mainFolder,mice{mouseI},'PFsLin.mat'),'TMap_unsmoothed')
    binsAbove95 = cell(size(allShuffledRates));
    for cellI = 1:numCells(mouseI) %Takes a few minues with 1000 shuffles
        for condI = 1:4
            for dayI = 1:numDays(mouseI)
                binsAbove95{cellI,condI,dayI} = ...
                    TMap_unsmoothed{cellI,condI,dayI} > shuffledRates95{cellI,condI,dayI};
            end
        end
    end
    
    numAbove95 = cell2mat(cellfun(@sum,binsAbove95,'UniformOutput',false));
    placeAtAll = numAbove95 > 0;
    lessThanHalf = numAbove95 < round(numBins/2); %Fires on less than half the stem
                    %Bins are next to each other
    placeToday = squeeze(sum(placeAtAll,2) > 0);
    placeTodayPct = sum(placeToday.*dayUse{mouseI},1)./sum(dayUse{mouseI},1); %numCellsToday{mouseI}
    
end
%ANOVA by bin

%% Population Vector Correlations



%% Decoder analysis