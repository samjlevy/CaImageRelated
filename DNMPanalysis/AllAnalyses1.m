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

for mouseI = 1:numMice
    trialbytrial = []; sortedSessionInds = []; allfiles = [];
    load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'))
    cellTBT{mouseI} = trialbytrial;
    cellSSI{mouseI} = sortedSessionInds;
    cellAllFiles{mouseI} = allfiles;
    
    numDays(mouseI) = size(cellSSI{mouseI},2);
end

maxDays = max(numDays);

for mouseI = 1:numMice
    accuracy{mouseI} = sessionAccuracy(cellAllFiles{mouseI});
    accuracyRange(mouseI, 1:2) = [mean(accuracy{mouseI}),...
        std(accuracy{mouseI})/sqrt(length(accuracy{mouseI}))];
end

%Big caveat: right now, sortedSessionInds etc. have rows that have nothing
%in them b/c blank entries for cells got left in when sessions were taken
%out during MakeTrialByTrial > GetMegaStuff2
dayUse = cell(1,numMice); threshAndConsec = cell(1,numMice);
for mouseI = 1:numMice
    [dayUse{mouseI},threshAndConsec{mouseI}] = GetUseCells(cellTBT{mouseI}, lapPctThresh, consecLapThresh);
end

for mouseI = 1:numMice
    saveName = fullfile(mainFolder,mice{mouseI},'PFsLin.mat');
    switch exist(fullfile(mainFolder,mice{mouseI},'PFsLin.mat'),'file')
        case 0
            disp(['no placefields found for ' mice{mouseI} ', making now'])
            [~, ~, ~, ~, ~, ~] =...
                PFsLinTrialbyTrial(cellTBT{mouseI},xlims, cmperbin, minspeed, 1, saveName, cellSSI{mouseI});
        case 1
            disp(['found placefields for ' mice{mouseI} ', you"re good'])
    end
end

Conds = GetTBTconds(cellTBT{1});
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
    
    for dayI = 1:numDays(mouseI)
        dailyNumCondsActiveCells{mouseI,dayI} = numCondsActive{mouseI}(logical(dayUse{mouseI}(:,dayI)), dayI); 
        dailyNCAmean(mouseI,dayI) = mean(dailyNumCondsActiveCells{mouseI,dayI});
        dailyNCAsem(mouseI,dayI) = standarderrorSL(dailyNumCondsActiveCells{mouseI,dayI});
         
        dailyOnlyActiveOneRaw(mouseI, dayI) = sum(dailyNumCondsActiveCells{mouseI, dayI}==1); %Raw number
        dailyOnlyActiveOnePct(mouseI, dayI) = dailyOnlyActiveOneRaw(mouseI, dayI)/length(dailyNumCondsActiveCells{mouseI, dayI}); %Percent
         
        %[mean(cellfun(@length,dailyNumCondsActiveCells(mouseI,:))
    end
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
    [trialReli{mouseI},~,~,~] = TrialReliability(trialbytrial, lapPctThresh);
    [maxConsec{mouseI}, ~] = ConsecutiveLaps(trialbytrial, consecLapThresh);
    
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
    
    %These need to be activity thresholded
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






% If active, % days a splitter
% Become splitter vs. not 
%

%% Place Cells

%ANOVA by bin

%% Population Vector Correlations



%% Decoder analysis