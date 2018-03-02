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
    [trialReli{mouseI},~,~,~] = TrialReliability(cellTBT{mouseI}, lapPctThresh);
    cellsActiveToday{mouseI} = sum(dayUse{mouseI},1);
    disp(['Mouse ' num2str(mouseI) ' completed'])
end

%Place fields
for mouseI = 1:numMice
    saveName = fullfile(mainFolder,mice{mouseI},'PFsLin.mat');
    switch exist(fullfile(mainFolder,mice{mouseI},'PFsLin.mat'),'file')
        case 0
            disp(['no placefields found for ' mice{mouseI} ', making now'])
            [~, ~, ~, ~, ~] =... %, TMap_gauss
                PFsLinTrialbyTrial(cellTBT{mouseI},xlims, cmperbin, minspeed, 1, saveName, trialReli{mouseI});
            %PFsLinTrialbyTrial2(cellTBT{mouseI}, xlims, cmperbin, minspeed,...
            %    'saveThis',true,'saveName',saveName,'trialReli',trialReli{mouseI},'smooth',false);
        case 2
            disp(['found placefields for ' mice{mouseI} ', all good'])
    end
end

Conds = GetTBTconds(cellTBT{1});
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

%% Splitter Cells
for mouseI = 1:numMice
    TMap_unsmoothed = [];
    load(fullfile(mainFolder,mice{mouseI},'PFsLin.mat'),'TMap_unsmoothed')
    cellTMap{mouseI} = TMap_unsmoothed;
end

condPairs = [1 2; 3 4; 1 3; 2 4];

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
    
    splittersLR{mouseI} = thisCellSplits{mouseI}{1} + thisCellSplits{mouseI}{2} > 0;
    splittersST{mouseI} = thisCellSplits{mouseI}{3} + thisCellSplits{mouseI}{4} > 0;
    splittersLRonly{mouseI} = splittersLR{mouseI}; splittersLRonly{mouseI}(splittersST{mouseI}==1) = 0;
    splittersSTonly{mouseI} = splittersST{mouseI}; splittersSTonly{mouseI}(splittersLR{mouseI}==1) = 0;
    splittersBoth{mouseI} = (splittersLR{mouseI} + splittersST{mouseI}) == 2;
    splittersOne{mouseI} = (splittersLR{mouseI} + splittersST{mouseI}) == 1;
    splittersNone{mouseI} = dayUse{mouseI}; splittersNone{mouseI}(splittersLR{mouseI} | splittersST{mouseI}) = 0;
    
    cellsActiveToday{mouseI} = sum(dayUse{mouseI},1);
    splitterProps{mouseI} = [sum(splittersNone{mouseI},1)./cellsActiveToday{mouseI};... %None
                             sum(splittersLRonly{mouseI},1)./cellsActiveToday{mouseI};... %LR only
                             sum(splittersSTonly{mouseI},1)./cellsActiveToday{mouseI};... %ST only
                             sum(splittersBoth{mouseI},1)./cellsActiveToday{mouseI}]; %Both only
    
end

% In theory maybe still should do shuffling, diff results (stricter) than ANOVA

for mouseI = 1:numMice
    numDaysSplitterLR{mouseI} = nan(numCells(mouseI),1); splitterCOMLR{mouseI} = nan(numCells(mouseI),1);
    numDaysSplitterST{mouseI} = nan(numCells(mouseI),1); splitterCOMST{mouseI} = nan(numCells(mouseI),1);
    numDaysSplitterBOTH{mouseI} = nan(numCells(mouseI),1); splitterCOMBOTH{mouseI} = nan(numCells(mouseI),1);
    for cellI = 1:numCells(mouseI)
        %If the cell splits LR/ST/Both ever and is active for more than one day
        numDaysPresent = sum(dayUse{mouseI}(cellI,:),2);
        if numDaysPresent > 1
            daysPresent = dayUse{mouseI}(cellI,:);
            dayV = 1:numDaysPresent; dayAlign = zeros(1,length(daysPresent));
            dayAlign(daysPresent) = dayV;
            daysActiveCOM = sum(dayAlign)/numDaysPresent;
            splitterWeight = dayAlign;
            splitterWeight(daysPresent) = splitterWeight(daysPresent) - daysActiveCOM;
            
            LRsplitterDays = splittersLR{mouseI}(cellI,:);
            numLRsplitterDays = sum(splittersLR{mouseI}(cellI,:),2);
            if numLRsplitterDays > 0
                numDaysSplitterLR{mouseI}(cellI) = numLRsplitterDays;
                splitterCOMLR{mouseI}(cellI) = sum(splitterWeight(LRsplitterDays))/numDaysPresent; %offset from active days COM
            end
            
            STsplitterDays = splittersST{mouseI}(cellI,:);
            numSTsplitterDays = sum(STsplitterDays,2);
            if numSTsplitterDays > 0
                numDaysSplitterST{mouseI}(cellI) = numSTsplitterDays;
                splitterCOMST{mouseI}(cellI) = sum(splitterWeight(STsplitterDays))/numDaysPresent; %offset from active days COM
            end
            
            BOTHsplitterDays = splittersBoth{mouseI}(cellI,:);
            numBothsplitterDays = sum(splittersBoth{mouseI}(cellI,:),2);
            if numLRsplitterDays > 0
                numDaysSplitterBOTH{mouseI}(cellI) = numBothsplitterDays;
                splitterCOMBOTH{mouseI}(cellI) = sum(splitterWeight(BOTHsplitterDays))/numDaysPresent; %offset from active days COM
            end 
        end
    end
    
    % Only includes cells that show up more than 1 day and split at least 1 day; won't equal some number of splitters or active cells
    % early bias, no bias didn't split all days, late bias, split all days
    splitterLRdayBias(mouseI,[1 3]) = [sum(splitterCOMLR{mouseI}<0) sum(splitterCOMLR{mouseI}>0)];
        splitterLRdayBias(mouseI, 2) = sum((splitterCOMLR{mouseI}==0).*(numDaysSplitterLR{mouseI}~=daysEachCellActive{mouseI}));
        splitterLRdayBias(mouseI, 4) = sum((splitterCOMLR{mouseI}==0).*(numDaysSplitterLR{mouseI}==daysEachCellActive{mouseI}));
    splitterSTdayBias(mouseI,[1 3]) = [sum(splitterCOMST{mouseI}<0) sum(splitterCOMST{mouseI}>0)];
        splitterSTdayBias(mouseI, 2) = sum((splitterCOMST{mouseI}==0).*(numDaysSplitterST{mouseI}~=daysEachCellActive{mouseI}));
        splitterSTdayBias(mouseI, 4) = sum((splitterCOMST{mouseI}==0).*(numDaysSplitterST{mouseI}==daysEachCellActive{mouseI}));
    splitterBOTHdayBias(mouseI,[1 3]) = [sum(splitterCOMBOTH{mouseI}<0) sum(splitterCOMBOTH{mouseI}>0)];
        splitterBOTHdayBias(mouseI, 2) = sum((splitterCOMBOTH{mouseI}==0).*(numDaysSplitterBOTH{mouseI}~=daysEachCellActive{mouseI}));
        splitterBOTHdayBias(mouseI, 4) = sum((splitterCOMBOTH{mouseI}==0).*(numDaysSplitterBOTH{mouseI}==daysEachCellActive{mouseI}));
        
end

%% Place Cells
numShuffles = 1000; %takes about an hour
% Shuffle within a condition for peak place firing
shuffleDir = 'PosShuffle';


%Make position shuffles
for mouseI = 1:numMice
    
    TMap_shuffled = cell(numShuffles,1);
    shuffDirFull = fullfile(mainFolder,mice{mouseI},shuffleDir);
    if ~exist(shuffDirFull,'dir')
        mkdir(shuffDirFull)
    end
    
    for shuffleI = 1:numShuffles
        shuffledTBT = shuffleTBTposition(cellTBT{mouseI});
        saveName = fullfile(shuffDirFull,['shuffPos' num2str(shuffleI) '.mat']);
        [~, ~, ~, TMap_shuffled{shuffleI}, ~] =... 
                    PFsLinTrialbyTrial(shuffledTBT,xlims, cmperbin, minspeed, 1, saveName, trialReli{mouseI});
        disp(['done shuffle ' num2str(shuffleI) ])
   
    end
    save(fullfile(shuffDirFull,allTMap_shuffled.mat),'TMap_shuffled')
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
        %save((fullfile(shuffDirFull,'allTMap_shuffled.mat')),'allTMap_shuffled')
        %disp('Saved allTMap_shuffled')
    
        %Reorganize to make sorting, etc. easier
        numBins = length(allTMap_unsmoothed{1}{1,1,1});
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
        
        save((fullfile(shuffDirFull,'allShuffledRates.mat')),'allShuffledRates','-v7.3')
        disp('Saved allShuffledRates')
        allTMap_shuffled = [];
    end
    
    %Sort, etc. 
    
    shuffledRatesSorted2 = cell(size(allShuffledRates));
    shuffledRatesMean = cell(size(allShuffledRates));
    shuffledRates95 = cell(size(allShuffledRates));
    pInd = round((1-pThresh)*nShuffles);
    
    for cellI = 1:numCells(mouseI) %Takes a few minues with 1000 shuffles
        for condI = 1:4
            for dayI = 1:numDays(mouseI)
                shuffledRatesSorted2{cellI,condI,dayI} = sort(allShuffledRates{cellI,condI,dayI},1);
                %shuffledRatesMean{cellI,condI,dayI} = nanmean(shuffledRatesSorted{cellI,condI,dayI},1); %Uses nanmean
                %shuffledRates95{cellI,condI,dayI} = shuffledRatesSorted{cellI,condI,dayI}(pInd,:);
            end
        end
    end
    toc
    
    
    
end
%ANOVA by bin

%% Population Vector Correlations



%% Decoder analysis