%% Process all data

mainFolder = 'C:\Users\Sam\Desktop\DNMPfinalData';
%mainFolder = 'E:\DNMPfinalData';
mice = {'Bellatrix', 'Polaris', 'Calisto', 'Nix'}; %'Europa'
numMice = length(mice);

%Thresholds
pThresh = 0.05;
lapPctThresh = 0.25;
consecLapThresh = 3;
%xlims = [25.5 56]; %old
xlims = [8 38];
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
    cellRealDays{mouseI} = realdays;
    
    clear trialbytrial sortedSessionInds allFiles
    
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
    saveName = fullfile(mainFolder,mice{mouseI},'PFsLin.mat');
    switch exist(fullfile(mainFolder,mice{mouseI},'PFsLin.mat'),'file')
        case 0
            disp(['no placefields found for ' mice{mouseI} ', making now'])
            [~, ~, ~, ~, ~, ~] =...
            PFsLinTrialbyTrial2(cellTBT{mouseI}, xlims, cmperbin, minspeed,...
                saveName,'trialReli',trialReli{mouseI},'smooth',false);        
        case 2
            disp(['found placefields for ' mice{mouseI} ', all good'])
    end
    
    saveName = fullfile(mainFolder,mice{mouseI},'PFsLinPooled.mat');
    switch exist(fullfile(mainFolder,mice{mouseI},'PFsLinPooled.mat'),'file')
        case 0
             disp(['no pooled placefields found for ' mice{mouseI} ', making now'])
            [~, ~, ~, ~, ~, ~] =...
            PFsLinTrialbyTrial2(cellTBT{mouseI}, xlims, cmperbin, minspeed,...
                saveName,'trialReli',trialReli{mouseI},'smooth',false,'condPairs',[1 3; 2 4; 1 2; 3 4]);  
        case 2
            disp(['found pooled placefields for ' mice{mouseI} ', all good'])
    end
end

for mouseI = 1:numMice
    load(fullfile(mainFolder,mice{mouseI},'PFsLin.mat'),'TMap_unsmoothed','TMap_zRates')
    cellTMap_unsmoothed{mouseI} = TMap_unsmoothed;
    cellTMap_zScored{mouseI} = TMap_zRates;
    load(fullfile(mainFolder,mice{mouseI},'PFsLinPooled.mat'),'TMap_unsmoothed','TMap_zRates')
    cellPooledTMap_unsmoothed{mouseI} = TMap_unsmoothed;
    cellPooledTMap_zRates{mouseI} = TMap_unsmoothed; 
end

Conds = GetTBTconds(cellTBT{1});
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
%numShuffles = 100;
shuffThresh = 1 - pThresh;
binsMin = 1;
shuffleDirLR = 'shuffleLR2';
shuffleDirST = 'shuffleST2';

%Get left/right splitting
for mouseI = 1:numMice
    condPairsLR = [1 2];
    shuffDirFullLR = fullfile(mainFolder,mice{mouseI},shuffleDirLR);
    [rateDiffLR{mouseI}, rateSplitLR{mouseI}, meanRateDiffLR{mouseI}, DIeachLR{mouseI}, DImeanLR{mouseI}, DIallLR{mouseI}] =...
        LookAtSplitters4(cellPooledTMap_unsmoothed{mouseI}, condPairsLR, []);
    splitterFileLR = fullfile(shuffDirFullLR,'splittersLR.mat');
    if exist(splitterFileLR,'file')==2
        load(splitterFileLR)
    else
        disp(['did not find LR splitting for mouse ' num2str(mouseI) ', making now'])
        [~, binsAboveShuffleLR, thisCellSplitsLR] = SplitterWrapper3(cellTBT{mouseI},'leftright',...
             'pooled', numShuffles, shuffDirFullLR, xlims, cmperbin, minspeed, [], shuffThresh, binsMin);
        save(splitterFileLR,'binsAboveShuffleLR','thisCellSplitsLR')
    end
    LRbinsAboveShuffle{mouseI} = binsAboveShuffleLR; 
    LRthisCellSplits{mouseI} = thisCellSplitsLR;
    disp(['done Left/Right splitters mouse ' num2str(mouseI)])
end

%Get study/test splitting
for mouseI = 1:numMice
    condPairsST = [3 4];
    shuffDirFullST = fullfile(mainFolder,mice{mouseI},shuffleDirST);
    [rateDiffST{mouseI}, rateSplitST{mouseI}, meanRateDiffST{mouseI}, DIeachST{mouseI}, DImeanST{mouseI}, DIallST{mouseI}] =...
        LookAtSplitters4(cellPooledTMap_unsmoothed{mouseI}, condPairsST, []);
    splitterFileST = fullfile(shuffDirFullST,'splittersST.mat');
    if exist(splitterFileST,'file')==2
        load(splitterFileST)
    else
        disp(['did not find ST splitting for ' num2str(mouseI) ', making now'])
        [~, binsAboveShuffleST, thisCellSplitsST] = SplitterWrapper3(cellTBT{mouseI},'studytest',...
             'pooled', numShuffles, shuffDirFullST, xlims, cmperbin, minspeed, [], shuffThresh, binsMin);
        save(splitterFileST,'binsAboveShuffleST','thisCellSplitsST')
    end
    STbinsAboveShuffle{mouseI} = binsAboveShuffleST; 
    STthisCellSplits{mouseI} = thisCellSplitsST;
    disp(['done Study/Test splitters mouse ' num2str(mouseI)])
end


%% Splitter cells: stats and logical breakdown
%Get logical splitting type
for mouseI = 1:numMice
    splittersLR{mouseI} = (LRthisCellSplits{mouseI} + dayUse{mouseI}) ==2;
    splittersST{mouseI} = (STthisCellSplits{mouseI} + dayUse{mouseI}) ==2;
    splittersANY{mouseI} = (splittersLR{mouseI} + splittersST{mouseI}) > 0;
    [splittersLRonly{mouseI}, splittersSTonly{mouseI}, splittersBOTH{mouseI},...
        splittersOne{mouseI}, splittersNone{mouseI}] = ...
        GetSplittingTypes(splittersLR{mouseI}, splittersST{mouseI}, dayUse{mouseI});
    nonLRsplitters{mouseI} = ((LRthisCellSplits{mouseI} == 0) + dayUse{mouseI}) ==2;
    nonSTsplitters{mouseI} = ((STthisCellSplits{mouseI} == 0) + dayUse{mouseI}) ==2;
    
    %Sanity check: Should work out that LRonly + STonly + Both + none = total active
        %And LR only + STonly = one
    cellsActiveToday{mouseI} = sum(dayUse{mouseI},1);
    splitterProps{mouseI} = [sum(splittersNone{mouseI},1)./cellsActiveToday{mouseI};... %None
                             sum(splittersLRonly{mouseI},1)./cellsActiveToday{mouseI};... %LR only
                             sum(splittersSTonly{mouseI},1)./cellsActiveToday{mouseI};... %ST only
                             sum(splittersBOTH{mouseI},1)./cellsActiveToday{mouseI}]; %Both only
                         
    splittersEXany{mouseI} = (splittersLRonly{mouseI} + splittersSTonly{mouseI}) > 0;
end

orng = [0.9294    0.6902    0.1294]; % uisetcolor
colorAssc = {'r'            'b'     'g'             'm'         'c'              orng     [1 0.8 0]         'k'  };
traitLabels = {'splitLR' 'splitST' 'splitEITHER' 'splitLRonly' 'splitSTonly' 'splitBOTH' 'splitONE' 'dontSplit'};

for mouseI = 1:numMice
    traitGroups{mouseI} = {splittersLR{mouseI}; splittersST{mouseI};... 
                           splittersANY{mouseI}; ...
                           splittersLRonly{mouseI}; splittersSTonly{mouseI}; ...
                           splittersBOTH{mouseI}; ...
                           splittersOne{mouseI};... 
                           splittersNone{mouseI}};
                   
    traitGroupsREV{mouseI} = cellfun(@fliplr,traitGroups{mouseI},'UniformOutput',false);
    
end
dayUseREV = cellfun(@fliplr,dayUse,'UniformOutput',false);

disp('done splitter logicals')

pairsCompare = {'splitLR' 'splitST';...
                'splitLRonly' 'splitSTonly';...
                'splitBOTH' 'splitONE';...
                'splitEITHER' 'dontSplit'};
pairsCompareInd = cell2mat(cellfun(@(x) find(strcmpi(traitLabels,x)),pairsCompare,'UniformOutput',false));

%% How many each type per day? 
for mouseI = 1:numMice
    splitPropEachDay{mouseI} = RunGroupFunction('TraitDailyPct',traitGroups{mouseI},dayUse{mouseI});
end

%% Get changes in number of splitters over time
%Packaging for running neatly in a big group

pooledDaysApartFWD = []; pooledDaysApartREV = [];
pooledSplitPctChangeFWD = cell(1,length(traitGroups{1})); pooledSplitPctChangeREV = cell(1,length(traitGroups{1}));
for mouseI = 1:numMice
    [splitterPctDayChangesFWD{mouseI}] = RunGroupFunction('NNplusKChange',traitGroups{mouseI},dayUse{mouseI});
    [splitterPctDayChangesREV{mouseI}] = RunGroupFunction('NNplusKChange',traitGroupsREV{mouseI},dayUseREV{mouseI});

    daysApartFWD{mouseI} = diff(splitterPctDayChangesFWD{mouseI}(1).dayPairs,1,2);
    daysApartREV{mouseI} = -1*daysApartFWD{mouseI};
    
    %realDaysApart cellRealDays
    
    pooledDaysApartFWD = [pooledDaysApartFWD; daysApartFWD{mouseI}];
    pooledDaysApartREV = [pooledDaysApartREV; daysApartREV{mouseI}];
    for tgI = 1:length(traitGroups{mouseI})
        pooledSplitPctChangeFWD{tgI} = [pooledSplitPctChangeFWD{tgI}; splitterPctDayChangesFWD{mouseI}(tgI).pctChange];
        pooledSplitPctChangeREV{tgI} = [pooledSplitPctChangeREV{tgI}; splitterPctDayChangesREV{mouseI}(tgI).pctChange];
    end
end

%Compare statistically
%For self comparison (to zero), shuffle the data points against days apart, and measure the slope

%An F-test will do it, for now just doing a permutation test on difference in regression lines
numPerms = 1000;
for tgI = 1:length(traitGroups{mouseI})
    %Here's the slope of each line
    [splitterSlope(tgI,1), splitterIntercept(tgI,1), splitterFitLine{tgI}, splitterRR{tgI}] = fitLinRegSL(pooledSplitPctChangeFWD{tgI}, pooledDaysApartFWD);
    [splitterSlopeREV(tgI,1), ~, ~, splitterRR{tgI}] = fitLinRegSL(pooledSplitPctChangeREV{tgI}, pooledDaysApartREV);
    
    %sameSlope = splitterSlope == splitterSlopeREV; %Rounding error a problem here
    
    %Is that slope different from a shuffle?
    [splitterSlopeRank(tgI,1), splitterRRrank(tgI,1)] = slopeRankWrapper(pooledSplitPctChangeFWD{tgI}, pooledDaysApartFWD, numPerms);
end

%Are the slopes different from each other?
for pcI = 1:size(pairsCompareInd,1)    
    [slopeDiffRank(pcI)] = multiSlopeRankWrapper(pooledSplitPctChangeFWD{pairsCompareInd(pcI,1)},...
                                                 pooledSplitPctChangeFWD{pairsCompareInd(pcI,2)}, pooledDaysApartFWD, numPerms);
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
        
        dailyCondsActiveHist{mouseI,dayI} = histcounts(dailyNumCondsActiveCells{mouseI,dayI},0.5:1:4.5);
    end
    dayCellsThatReturnPct{mouseI} = dayCellsThatReturn{mouseI}./numCellsToday{mouseI};
    dayCellsThatReturnRange(mouseI,1:2) = [mean(dayCellsThatReturn{mouseI}) standarderrorSL(dayCellsThatReturn{mouseI})];
    dayCellsThatReturnPctRange(mouseI,1:2) = [mean(dayCellsThatReturnPct{mouseI}) standarderrorSL(dayCellsThatReturnPct{mouseI})];
    
    numCondsActiveRange(mouseI, 1:2) = [nanmean(dailyNCAmean(mouseI,:)),...
        standarderrorSL(dailyNCAmean(mouseI,~isnan(dailyNCAmean(mouseI,:))))];
    activeMoreThanOneRange(mouseI, 1:2) = ...
        [mean(dailyOnlyActiveOnePct(mouseI,dailyOnlyActiveOnePct(mouseI,:) > 0))...
         standarderrorSL(dailyOnlyActiveOnePct(mouseI,dailyOnlyActiveOnePct(mouseI,:) > 0))];
    
    %likelihood of a cell being active in the same number of conditions each day found
    for cellI = 1:size(dayUse{mouseI},1)
        notZeroHere = dayUse{mouseI}(cellI,:);
        cellCondsActiveRange{mouseI}(cellI,1:2) =...
            [mean(numCondsActive{mouseI}(cellI,notZeroHere)), standarderrorSL(numCondsActive{mouseI}(cellI,notZeroHere))];
    end
    cellsUse = daysEachCellActive{mouseI}>1;
    allCellCondsActiveRange(mouseI, 1:2) =...
        [nanmean(cellCondsActiveRange{mouseI}(cellsUse,1)) nanstandarderrorSL(cellCondsActiveRange{mouseI}(cellsUse,1))];
    disp(['done single cells mouse ' num2str(mouseI)])
end

%for mouseI = 1:numMice
%    [trialReli{mouseI},~,~,~] = TrialReliability(cellTBT{mouseI}, lapPctThresh);
%    [maxConsec{mouseI}, ~] = ConsecutiveLaps(cellTBT{mouseI}, consecLapThresh);
%end

disp('Done with all single cells analysis')
%% Get some daily percentages of splitters
%Evaluate splitting: days bias numbers and center of mass per cell
for mouseI = 1:numMice
    %BIAS: early bias, no bias didn't split all days, late bias, split all days
    [splitterCOMLR{mouseI}, splitterDayBiasLR{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, splittersLR{mouseI});
    [splitterCOMST{mouseI}, splitterDayBiasST{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, splittersST{mouseI});
    [splitterCOMBOTH{mouseI}, splitterDayBiasBOTH{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, splittersBOTH{mouseI});
    [splitterCOMLRonly{mouseI}, splitterDayBiasLRonly{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, splittersLRonly{mouseI});
    [splitterCOMSTonly{mouseI}, splitterDayBiasSTonly{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, splittersSTonly{mouseI});
    [splitterCOMANY{mouseI}, splitterDayBiasANY{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, splittersANY{mouseI});
    [splitterCOMEXany{mouseI}, splitterDayBiasEXany{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, splittersEXany{mouseI});
    [splitterCOMNone{mouseI}, splitterDayBiasNone{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, splittersNone{mouseI});
end

    
%Daily splitter ranges
for mouseI = 1:numMice
    everSplit{mouseI} = sum(sum(splittersANY{mouseI},2) > 0);
    
    [numDailySplittersANY{mouseI}, daysSplitANY{mouseI}, rangeDailySplittersANY(mouseI,:),...
    pctDailySplittersANY{mouseI}, rangePctDailySplittersANY(mouseI,:), splitAllDaysANY{mouseI}]... 
     = DailyTraitRanges(splittersANY{mouseI}, splitterDayBiasANY{mouseI}, dayUse{mouseI});
    
    [numDailySplittersLR{mouseI}, daysSplitLR{mouseI}, rangeDailySplittersLR(mouseI,:),...
    pctDailySplittersLR{mouseI}, rangePctDailySplittersLR(mouseI,:), splitAllDaysLR{mouseI}]...
     = DailyTraitRanges(splittersLR{mouseI}, splitterDayBiasLR{mouseI}, dayUse{mouseI});
 
    [numDailySplittersST{mouseI}, daysSplitST{mouseI}, rangeDailySplittersST(mouseI,:),...
    pctDailySplittersST{mouseI}, rangePctDailySplittersST(mouseI,:), splitAllDaysST{mouseI}]...
     = DailyTraitRanges(splittersST{mouseI}, splitterDayBiasST{mouseI}, dayUse{mouseI});
     
    [numDailySplittersBOTH{mouseI}, daysSplitBOTH{mouseI}, rangeDailySplittersBOTH(mouseI,:),...
    pctDailySplittersBOTH{mouseI}, rangePctDailySplittersBOTH(mouseI,:), splitAllDaysBOTH{mouseI}]...
     = DailyTraitRanges(splittersBOTH{mouseI}, splitterDayBiasBOTH{mouseI}, dayUse{mouseI});
     
    [numDailySplittersLRonly{mouseI}, daysSplitLRonly{mouseI}, rangeDailySplittersLRonly(mouseI,:),...
    pctDailySplittersLRonly{mouseI}, rangePctDailySplittersLRonly(mouseI,:), splitAllDaysLRonly{mouseI}]...
     = DailyTraitRanges(splittersLRonly{mouseI}, splitterDayBiasLRonly{mouseI}, dayUse{mouseI}); 
 
    [numDailySplittersSTonly{mouseI}, daysSplitSTonly{mouseI}, rangeDailySplittersSTonly(mouseI,:),...
    pctDailySplittersSTonly{mouseI}, rangePctDailySplittersSTonly(mouseI,:), splitAllDaysSTonly{mouseI}]...
     = DailyTraitRanges(splittersSTonly{mouseI}, splitterDayBiasSTonly{mouseI}, dayUse{mouseI});
 
    [numDailySplittersEXany{mouseI}, daysSplitEXany{mouseI}, rangeDailySplittersEXany(mouseI,:),...
    pctDailySplittersEXany{mouseI}, rangePctDailySplittersEXany(mouseI,:), splitAllDaysEXany{mouseI}]...
     = DailyTraitRanges(splittersEXany{mouseI}, splitterDayBiasEXany{mouseI}, dayUse{mouseI});
 
    [numDailySplittersNone{mouseI}, daysSplitNone{mouseI}, rangeDailySplittersNone(mouseI,:),...
    pctDailySplittersNone{mouseI}, rangePctDailySplittersNone(mouseI,:), splitAllDaysNone{mouseI}]...
     = DailyTraitRanges(splittersNone{mouseI}, splitterDayBiasNone{mouseI}, dayUse{mouseI});
 
 [numDailySplittersOneDim{mouseI}, daysSplitOneDim{mouseI}, rangeDailySplittersOneDim(mouseI,:),...
    pctDailySplittersOneDim{mouseI}, rangePctDailySplittersOneDim(mouseI,:), splitAllDaysOneDim{mouseI}]...
     = DailyTraitRanges(oneDimSplitters{mouseI}, splitterDayBiasNone{mouseI}, dayUse{mouseI});
end

%% Percent change by days apart for splitters

%Splitters doing the other thing; slope also
numPerms = 1000;
for mouseI = 1:numMice
    %splittersLRalsoSplitST{mouseI} = (splittersLR{mouseI} + splittersBOTH{mouseI})==2;
    splitLRalsoSplitSTprop{mouseI} = sum(splittersBOTH{mouseI},1)./sum(splittersLR{mouseI},1);
    splitSTalsoSplitLRprop{mouseI} = sum(splittersBOTH{mouseI},1)./sum(splittersST{mouseI},1);
    
    [slopeRankLRalsoST(mouseI), RsquaredRankLRalsoST(mouseI)] = slopeRankWrapper(splitLRalsoSplitSTprop{mouseI}, cellRealDays{mouseI}, numPerms);
    [slopeLRalsoST(mouseI), intercept, fitLine, rrLRalsoST(mouseI)] = fitLinRegSL(splitLRalsoSplitSTprop{mouseI}, cellRealDays{mouseI});
    [slopeRankSTalsoLR(mouseI), RsquaredRankSTalsoLR(mouseI)] = slopeRankWrapper(splitSTalsoSplitLRprop{mouseI}, cellRealDays{mouseI}, numPerms);
    [slopeSTalsoLR(mouseI), intercept, fitLine, rrSTalsoLR(mouseI)] = fitLinRegSL(splitSTalsoSplitLRprop{mouseI}, cellRealDays{mouseI});
end

numPerms = 1000;
for mouseI = 2:numMice
    %splittersLRalsoSplitST{mouseI} = (splittersLR{mouseI} + splittersBOTH{mouseI})==2;
    propLRsplitters{mouseI} = sum(splittersLR{mouseI},1)./sum(dayUse{mouseI},1);
    propSTsplitters{mouseI} = sum(splittersST{mouseI},1)./sum(dayUse{mouseI},1);
    
    oneDimSplitters{mouseI} = splittersLRonly{mouseI} + splittersSTonly{mouseI};
    propOneDimSplitters{mouseI} = sum(oneDimSplitters{mouseI},1)./sum(dayUse{mouseI},1);
    propNonSplitters{mouseI} = sum(splittersNone{mouseI},1)./sum(dayUse{mouseI},1); 
    
    [slopeRankLRsplitters(mouseI), RsquaredRankLRsplitters(mouseI)] = slopeRankWrapper(propLRsplitters{mouseI}, cellRealDays{mouseI}, numPerms);
    [slopeLRsplitters(mouseI), intercept, fitLine, rrLRsplitters(mouseI)] = fitLinRegSL(propLRsplitters{mouseI}, cellRealDays{mouseI});
    [slopeRankSTsplitters(mouseI), RsquaredRankSTsplitters(mouseI)] = slopeRankWrapper(propSTsplitters{mouseI}, cellRealDays{mouseI}, numPerms);
    [slopeSTsplitters(mouseI), intercept, fitLine, rrSTsplitters(mouseI)] = fitLinRegSL(propSTsplitters{mouseI}, cellRealDays{mouseI});
    [slopeRankOneDimSplitters(mouseI), RsquaredRankOneDimSplitters(mouseI)] = slopeRankWrapper(propOneDimSplitters{mouseI}, cellRealDays{mouseI}, numPerms);
    [slopeOneDimSplitters(mouseI), intercept, fitLine, rrOneDimSplitters(mouseI)] = fitLinRegSL(propOneDimSplitters{mouseI}, cellRealDays{mouseI});
    [slopeRankNonSplitters(mouseI), RsquaredRankNonSplitters(mouseI)] = slopeRankWrapper(propNonSplitters{mouseI}, cellRealDays{mouseI}, numPerms);
    [slopeNonSplitters(mouseI), intercept, fitLine, rrNonSplitters(mouseI)] = fitLinRegSL(propNonSplitters{mouseI}, cellRealDays{mouseI});
    disp(['Done splitter slopes mouse ' num2str(mouseI)])
end
%{
    splittersLR{mouseI});
    splittersST{mouseI});
    splittersBOTH{mouseI});
    splittersLRonly{mouseI});
    splittersSTonly{mouseI});
    splittersANY{mouseI});
    splittersEXany{mouseI});
    splittersNone{mouseI});
%}


%Lr, st, how often is LR also ST, how often is ST also LR?
%How many full convert to other type?



%How many days active by splitter type
for mouseI = 1:numMice
    everSplitLR{mouseI} = sum(splittersLR{mouseI},2)>0;             numSplitLR(mouseI) = sum(everSplitLR{mouseI});
    everSplitST{mouseI} = sum(splittersST{mouseI},2)>0;             numSplitST(mouseI) = sum(everSplitST{mouseI});
    everSplitBOTH{mouseI} = sum(splittersBOTH{mouseI},2)>0;         numSplitBOTH(mouseI) = sum(everSplitBOTH{mouseI});
    everSplitLRonly{mouseI} = sum(splittersLRonly{mouseI},2)>0;     numSplitLRonly(mouseI) = sum(everSplitLRonly{mouseI});
    everSplitSTonly{mouseI} = sum(splittersSTonly{mouseI},2)>0;     numSplitSTonly(mouseI) = sum(everSplitSTonly{mouseI});
    everSplitANY{mouseI} = sum(splittersANY{mouseI},2)>0;           numSplitANY(mouseI) = sum(everSplitANY{mouseI});
    everSplitEXany{mouseI} = sum(splittersEXany{mouseI},2)>0;       numSplitEXany(mouseI) = sum(everSplitEXany{mouseI});
    everSplitNone{mouseI} = sum(splittersNone{mouseI},2)>0;         numSplitNone(mouseI) = sum(everSplitNone{mouseI});
    
    %Days active by everSplit ind
    activeDaysSplitLR{mouseI} = daysEachCellActive{mouseI}(everSplitLR{mouseI})';
    activeDaysSplitST{mouseI} = daysEachCellActive{mouseI}(everSplitST{mouseI})';
    activeDaysSplitBOTH{mouseI} = daysEachCellActive{mouseI}(everSplitBOTH{mouseI})';
    activeDaysSplitLRonly{mouseI} = daysEachCellActive{mouseI}(everSplitLRonly{mouseI})'; 
    activeDaysSplitSTonly{mouseI} = daysEachCellActive{mouseI}(everSplitSTonly{mouseI})';
    activeDaysSplitANY{mouseI} = daysEachCellActive{mouseI}(everSplitANY{mouseI})';
    activeDaysSplitEXany{mouseI} = daysEachCellActive{mouseI}(everSplitEXany{mouseI})';
    activeDaysSplitNone{mouseI} = daysEachCellActive{mouseI}(everSplitNone{mouseI})';
    
    %Pct active days a splitter
   
    pctDaysLRsplitter{mouseI} = daysSplitLR{mouseI}./daysEachCellActive{mouseI};
    pctDaysSTsplitter{mouseI} = daysSplitST{mouseI}./daysEachCellActive{mouseI};
    pctDaysOneDimSplitter{mouseI} = sum(oneDimSplitters{mouseI},2)./daysEachCellActive{mouseI};
    pctDaysNonSplitter{mouseI} = daysSplitNone{mouseI}./daysEachCellActive{mouseI};
end
    
pooledActiveDaysSplitLR = [activeDaysSplitLR{:}];
pooledActiveDaysSplitST = [activeDaysSplitST{:}];
pooledActiveDaysSplitBOTH = [activeDaysSplitBOTH{:}];
pooledActiveDaysSplitLRonly = [activeDaysSplitLRonly{:}];
pooledActiveDaysSplitSTonly = [activeDaysSplitSTonly{:}];
pooledActiveDaysSplitANY = [activeDaysSplitANY{:}];
pooledActiveDaysSplitEXany = [activeDaysSplitEXany{:}];
pooledActiveDaysSplitNone = [activeDaysSplitNone{:}];


for mouseI = 1:numMice
    reactivatesSplitterLR(mouseI) = TraitReactivation(dayUse{mouseI}, splittersLR{mouseI});
    reactivatesSplitterST(mouseI) = TraitReactivation(dayUse{mouseI}, splittersST{mouseI});
    reactivatesSplitterLRonly(mouseI) = TraitReactivation(dayUse{mouseI}, splittersLRonly{mouseI});
    reactivatesSplitterSTonly(mouseI) = TraitReactivation(dayUse{mouseI}, splittersSTonly{mouseI});
    
    [splittersLRnumChangeSplitterLR{mouseI}, pctChangeSplitterLR{mouseI}] = NNplusOneChange(splittersLR{mouseI}, dayUse{mouseI});
    [splittersLRnumChangeSplitterST{mouseI}, pctChangeSplitterST{mouseI}] = NNplusOneChange(splittersST{mouseI}, dayUse{mouseI});
    [splittersLRnumChangeSplitterLRonly{mouseI}, pctChangeSplitterLRonly{mouseI}] = NNplusOneChange(splittersLRonly{mouseI}, dayUse{mouseI});
    [splittersLRnumChangeSplitterSTonly{mouseI}, pctChangeSplitterSTonly{mouseI}] = NNplusOneChange(splittersSTonly{mouseI}, dayUse{mouseI});
end

pooledReacSplitterLR = [reactivatesSplitterLR(:).prop];
pooledReacSplitterST = [reactivatesSplitterST(:).prop];
pooledReacSplitterLRonly = [reactivatesSplitterLRonly(:).prop];
pooledReacSplitterSTonly = [reactivatesSplitterSTonly(:).prop];

pooledPctChangeSplitterLR = [pctChangeSplitterLR{:}];
pooledPctChangeSplitterST = [pctChangeSplitterST{:}];
pooledPctChangeSplitterLRonly = [pctChangeSplitterLRonly{:}];
pooledPctChangeSplitterSTonly = [pctChangeSplitterSTonly{:}];


disp('Done with all splitter cells analysis')

%% Place Cells
numShuffles = 1000; %takes about an hour
% Shuffle within a condition for peak place firing
shuffleDir = 'shufflePos';

%Make all Place stuff
for mouseI = 1:numMice
    shuffDirFull = fullfile(mainFolder,mice{mouseI},shuffleDir);
    mouseDir = fullfile(mainFolder,mice{mouseI});
    PlaceSigWrapper1(cellTBT{mouseI}, xlims, cmperbin, minspeed, trialReli{mouseI}, numShuffles, mouseDir, shuffDirFull, pThresh )
    disp(['done mouse ' num2str(mouseI)])
end

%Load sig results, start-a-parsing
for mouseI = 1:numMice
    load(fullfile(mainFolder,mice{mouseI},shuffleDir,'PFresults.mat'))
    placeByBin{mouseI} = binsAbove95;
    numPlaceBins{mouseI} = numAbove95;
    belowHalf{mouseI} = lessThanHalf;
    placeByCond{mouseI} = placeAtAll;
    placeThisDay{mouseI} = placeToday.*dayUse{mouseI};
    notPlace{mouseI} = (placeThisDay{mouseI}==0).*dayUse{mouseI};
end

%How many place cells each conditions? How many with more than one condition?
for mouseI = 1:numMice
    cellsActiveToday{mouseI} = sum(dayUse{mouseI},1);
    placeByCondThreshed{mouseI}(:,:,1) = squeeze(placeByCond{mouseI}(:,:,1)).*squeeze(threshAndConsec{mouseI}(:,:,1));
    placeByCondThreshed{mouseI}(:,:,2) = squeeze(placeByCond{mouseI}(:,:,2)).*squeeze(threshAndConsec{mouseI}(:,:,2));
    placeByCondThreshed{mouseI}(:,:,3) = squeeze(placeByCond{mouseI}(:,:,3)).*squeeze(threshAndConsec{mouseI}(:,:,3));
    placeByCondThreshed{mouseI}(:,:,4) = squeeze(placeByCond{mouseI}(:,:,4)).*squeeze(threshAndConsec{mouseI}(:,:,4));
    %placeNums{mouseI} = [sum(squeeze(placeByCond{mouseI}(:,:,1)).*dayUse{mouseI});... %Study L
    %                     sum(squeeze(placeByCond{mouseI}(:,:,2)).*dayUse{mouseI});... %Study R
    %                     sum(squeeze(placeByCond{mouseI}(:,:,3)).*dayUse{mouseI});... %Test L
    %                     sum(squeeze(placeByCond{mouseI}(:,:,4)).*dayUse{mouseI})];   %Test R
    placeNums{mouseI} = [sum(placeByCondThreshed{mouseI}(:,:,1),1);... %Study L
                         sum(placeByCondThreshed{mouseI}(:,:,2),1);... %Study R
                         sum(placeByCondThreshed{mouseI}(:,:,3),1);... %Test L
                         sum(placeByCondThreshed{mouseI}(:,:,4),1)];   %Test R
                         
    placeProps{mouseI} = [placeNums{mouseI}(1,:)./cellsActiveToday{mouseI};... %Study L
                          placeNums{mouseI}(2,:)./cellsActiveToday{mouseI};... %Study R
                          placeNums{mouseI}(3,:)./cellsActiveToday{mouseI};... %Test L
                          placeNums{mouseI}(4,:)./cellsActiveToday{mouseI}]; %Test R  
    totalPropPlace{mouseI} = (sum(placeThisDay{mouseI}.*dayUse{mouseI})./cellsActiveToday{mouseI});
    
    for condI = 1:size(placeProps{mouseI},1)
        pctRangePlace{mouseI}(condI,1:2) = [mean(placeProps{mouseI}(condI,:)) standarderrorSL(placeProps{mouseI}(condI,:))];
    end
    pctRangePlace{mouseI}(size(pctRangePlace{mouseI},1)+1,1:2) = [mean(totalPropPlace{mouseI}) standarderrorSL(totalPropPlace{mouseI})];
    
    %numCondsAPlaceCell{mouseI} = sum(placeByCond{mouseI},2)
    condsWherePlace{mouseI} = squeeze(sum(placeByCondThreshed{mouseI},3))./squeeze(sum(threshAndConsec{mouseI},3));
    for dayI = 1:size(dayUse{mouseI},2)
        dailyPropCondsWherePlace{mouseI}([1:2],dayI) = [mean(condsWherePlace{mouseI}(dayUse{mouseI}(:,dayI),dayI));...
                          standarderrorSL(condsWherePlace{mouseI}(dayUse{mouseI}(:,dayI),dayI))]; %Indexing only gets it for active cells
    end
    pctRangeCondsWherePlace(mouseI,1:2) = [mean(dailyPropCondsWherePlace{mouseI}(1,:)),...
        standarderrorSL(dailyPropCondsWherePlace{mouseI}(1,:))];
end

%Placecells coming or going?
for mouseI = 1:numMice
    [placeCOM{mouseI}, placeDayBias{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, placeThisDay{mouseI}); 
    [placeCOMSL{mouseI}, placeDayBiasSL{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, squeeze(placeByCond{mouseI}(:,:,1)));
    [placeCOMSR{mouseI}, placeDayBiasSR{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, squeeze(placeByCond{mouseI}(:,:,2)));
    [placeCOMTL{mouseI}, placeDayBiasTL{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, squeeze(placeByCond{mouseI}(:,:,3)));
    [placeCOMTR{mouseI}, placeDayBiasTR{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, squeeze(placeByCond{mouseI}(:,:,4)));
end

%Place detail
for mouseI = 1:numMice
    reactivatesPlaceAny{mouseI} = TraitReactivation(dayUse{mouseI},placeThisDay{mouseI});
    reactivatesPlaceSL{mouseI} = TraitReactivation(dayUse{mouseI},squeeze(placeByCond{mouseI}(:,:,1)));
    reactivatesPlaceSR{mouseI} = TraitReactivation(dayUse{mouseI},squeeze(placeByCond{mouseI}(:,:,2)));
    reactivatesPlaceTL{mouseI} = TraitReactivation(dayUse{mouseI},squeeze(placeByCond{mouseI}(:,:,3)));
    reactivatesPlaceTR{mouseI} = TraitReactivation(dayUse{mouseI},squeeze(placeByCond{mouseI}(:,:,4)));
    reactivatesNotPlace{mouseI} = TraitReactivation(dayUse{mouseI},notPlace{mouseI});
end

disp('Done getting all place cell stuff')

%% Place/Splitter cell overlap

% Get logical is it placeXsplitter
for mouseI = 1:numMice
    placeSplitLR{mouseI} = logical(splittersLR{mouseI}.*(placeThisDay{mouseI}.*dayUse{mouseI}));           %Place split LR
    placeSplitST{mouseI} = logical(splittersST{mouseI}.*(placeThisDay{mouseI}.*dayUse{mouseI}));           %Place split ST
    placeSplitBOTH{mouseI} = logical(splittersBOTH{mouseI}.*(placeThisDay{mouseI}.*dayUse{mouseI}));       %Place split both
    placeSplitLRonly{mouseI} = logical(splittersLRonly{mouseI}.*(placeThisDay{mouseI}.*dayUse{mouseI}));   %Place split LRex
    placeSplitSTonly{mouseI} = logical(splittersSTonly{mouseI}.*(placeThisDay{mouseI}.*dayUse{mouseI}));   %Place split STex
    placeSplitNone{mouseI} = logical(splittersNone{mouseI}.*(placeThisDay{mouseI}.*dayUse{mouseI}));       %Place not splitter
        %placeByCondThreshed{mouseI}(:,:,1) | placeByCondThreshed{mouseI}(:,:,3)));%???
        
    placeAndSplitter{mouseI} = logical(splittersANY{mouseI}.*(placeThisDay{mouseI}.*dayUse{mouseI}));
    placeNotSplitter{mouseI} = logical(splittersNone{mouseI}.*(placeThisDay{mouseI}.*dayUse{mouseI}));
    splitterNotPlace{mouseI} = logical(splittersANY{mouseI}.*(notPlace{mouseI}.*dayUse{mouseI}));
    notSplitterNotPlace{mouseI} = logical(splittersNone{mouseI}.*(notPlace{mouseI}.*dayUse{mouseI}));
end

    
% How many, Range etc.
for mouseI = 1:numMice
    pctDailyPlaceAndSplitter{mouseI} = sum(placeAndSplitter{mouseI},1)./cellsActiveToday{mouseI};
    pctDailyPlaceNotSplitter{mouseI} = sum(placeNotSplitter{mouseI},1)./cellsActiveToday{mouseI};
    pctDailySplitterNotPlace{mouseI} = sum(splitterNotPlace{mouseI},1)./cellsActiveToday{mouseI};
    pctDailynotSplitterNotPlace{mouseI} = sum(notSplitterNotPlace{mouseI},1)./cellsActiveToday{mouseI};
    
     sanityCheck = [pctDailyPlaceAndSplitter{mouseI}; pctDailyPlaceNotSplitter{mouseI};...
                pctDailySplitterNotPlace{mouseI}; pctDailynotSplitterNotPlace{mouseI}];
end

disp('done logical overlap place and splitter')
 
%% DI distributions
binEdges = [-1.1 -0.9:0.1:0.9 1.1];
for mouseI = 1:numMice
    DImeansLR = DImeanLR{mouseI}; DImeansLR(dayUse{mouseI}==0) = NaN;
    DImeansST = DImeanST{mouseI}; DImeansST(dayUse{mouseI}==0) = NaN;
    
    %All cells
    [dayDistLR{mouseI}, pctDayDistLR{mouseI}, pctEdgeLR{mouseI}, dayDistMeansLR(mouseI,:), dayDistSEMsLR(mouseI,:)] =...
        DIdistBreakdown(DImeansLR, dayUse{mouseI}, binEdges);
    [dayDistST{mouseI}, pctDayDistST{mouseI}, pctEdgeST{mouseI}, dayDistMeansST(mouseI,:), dayDistSEMsST(mouseI,:)] =...
        DIdistBreakdown(DImeansST, dayUse{mouseI}, binEdges);
    %Splitters
    [dayDistLRsplitters{mouseI}, pctDayDistLRsplitters{mouseI}, pctEdgeLRsplitters{mouseI},...
        dayDistMeansLRsplitters(mouseI,:), dayDistSEMsLRsplitters(mouseI,:)] =...
        DIdistBreakdown(DImeansLR, splittersLR{mouseI}, binEdges);
    [dayDistSTsplitters{mouseI}, pctDayDistSTsplitters{mouseI}, pctEdgeSTsplitters{mouseI},...
        dayDistMeansSTsplitters(mouseI,:), dayDistSEMsSTsplitters(mouseI,:)] =...
        DIdistBreakdown(DImeansST, splittersST{mouseI}, binEdges);
    %Splitters, other dim
    [dayDistLRforSTsplitters{mouseI}, pctDayDistLRforSTsplitters{mouseI}, pctEdgeLRforSTsplitters{mouseI},...
        dayDistMeansLRforSTsplitters(mouseI,:), dayDistSEMsLRforSTsplitters(mouseI,:)] =...
        DIdistBreakdown(DImeansLR, splittersST{mouseI}, binEdges);
    [dayDistSTforLRsplitters{mouseI}, pctDayDistSTforLRsplitters{mouseI}, pctEdgeSTforLRsplitters{mouseI},...
        dayDistMeansSTforLRsplitters(mouseI,:), dayDistSEMsSTforLRsplitters(mouseI,:)] =...
        DIdistBreakdown(DImeansST, splittersLR{mouseI}, binEdges);
    %Split both
    [dayDistLRboth{mouseI}, pctDayDistLRboth{mouseI}, pctEdgeLRboth{mouseI}, dayDistMeansLRboth(mouseI,:), dayDistSEMsLRboth(mouseI,:)] =...
        DIdistBreakdown(DImeansLR, splittersBOTH{mouseI}, binEdges);
    [dayDistSTboth{mouseI}, pctDayDistSTboth{mouseI}, pctEdgeSTboth{mouseI}, dayDistMeansSTboth(mouseI,:), dayDistSEMsSTboth(mouseI,:)] =...
        DIdistBreakdown(DImeansST, splittersBOTH{mouseI}, binEdges);
    %Non splitters
    [dayDistNOTLRsplitters{mouseI}, pctDayDistNOTLRsplitters{mouseI}, pctEdgeNOTLRsplitters{mouseI},...
        dayDistMeansNOTLRsplitters(mouseI,:), dayDistSEMsNOTLRsplitters(mouseI,:)] =...
        DIdistBreakdown(DImeansLR, splittersLR{mouseI}==0, binEdges);
    [dayDistNOTSTsplitters{mouseI}, pctDayDistNOTSTsplitters{mouseI}, pctEdgeNOTSTsplitters{mouseI},...
        dayDistMeansNOTSTsplitters(mouseI,:), dayDistSEMsNOTSTsplitters(mouseI,:)] =...
        DIdistBreakdown(DImeansST, splittersST{mouseI}==0, binEdges);
    
    %Place
    [dayDistLRplace{mouseI}, pctDayDistLRplace{mouseI}, pctEdgeLRplace{mouseI}, dayDistMeansLRplace(mouseI,:),...
        dayDistSEMsLRplace(mouseI,:)] = DIdistBreakdown(DImeansLR, placeThisDay{mouseI}, binEdges);
    [dayDistSTplace{mouseI}, pctDayDistSTplace{mouseI}, pctEdgeSTplace{mouseI}, dayDistMeansSTplace(mouseI,:),...
        dayDistSEMsSTplace(mouseI,:)] = DIdistBreakdown(DImeansST, placeThisDay{mouseI}, binEdges);
    %Non-place
    [dayDistLRnonPlace{mouseI}, pctDayDistLRnonPlace{mouseI}, pctEdgeLRnonPlace{mouseI}, dayDistMeansLRnonPlace(mouseI,:),...
        dayDistSEMsLRnonPlace(mouseI,:)] = DIdistBreakdown(DImeansLR, placeThisDay{mouseI}==0, binEdges);
    [dayDistSTnonPlace{mouseI}, pctDayDistSTnonPlace{mouseI}, pctEdgeSTnonPlace{mouseI}, dayDistMeansSTnonPlace(mouseI,:),...
        dayDistSEMsSTnonPlace(mouseI,:)] = DIdistBreakdown(DImeansST, placeThisDay{mouseI}==0, binEdges);
end     


%Dist pooled lr/st
allMiceDayDistLR = vertcat(dayDistLR{:});
allMiceDayDistST = vertcat(dayDistST{:});
allMicePctDistLR = vertcat(pctDayDistLR{:});
allMicePctDistST = vertcat(pctDayDistST{:});

allMiceEdgeLR = [pctEdgeLR{:}];
allMiceEdgeST = [pctEdgeST{:}];
allMiceEdgeLRsplitters = [pctEdgeLRsplitters{:}];
allMiceEdgeSTsplitters = [pctEdgeSTsplitters{:}];
allMiceEdgeLRforSTsplitters = [pctEdgeLRforSTsplitters{:}];
allMiceEdgeSTforLRsplitters = [pctEdgeSTforLRsplitters{:}];
allMiceEdgeNOTLRsplitters = [pctEdgeNOTLRsplitters{:}];
allMiceEdgeNOTSTsplitters = [pctEdgeNOTSTsplitters{:}];

[edgep(1), edgeh(1)] = ranksum(allMiceEdgeLR, allMiceEdgeST);
[edgep(2), edgeh(2)] = ranksum(allMiceEdgeLRsplitters, allMiceEdgeSTsplitters);
[edgep(3), edgeh(3)] = ranksum(allMiceEdgeNOTLRsplitters, allMiceEdgeNOTSTsplitters);
[edgep(4), edgeh(4)] = ranksum(allMiceEdgeLRforSTsplitters, allMiceEdgeSTforLRsplitters);
testPairs = [1 2; 3 4; 5 6; 7 8];


for binI = 1:length(binEdges)-1
    amppLR = allMicePctDistLR(:,binI);
    amPctsDistMeanLR(1,binI) = mean(amppLR(amppLR~=0));
    amPctsDistSEMsLR(1,binI) = standarderrorSL(amppLR(amppLR~=0));
    amppST = allMicePctDistST(:,binI);
    amPctsDistMeanST(1,binI) = mean(amppST(amppST~=0));
    amPctsDistSEMsST(1,binI) = standarderrorSL(amppST(amppST~=0));
end 

%More breakdowns lr/st
for mouseI = 1:numMice
     pctEdgeLRchange{mouseI} = NNplusOnePropChange(pctEdgeLR{mouseI});
     pctEdgeSTchange{mouseI} = NNplusOnePropChange(pctEdgeST{mouseI});
     pctEdgeLRsplittersChange{mouseI} = NNplusOnePropChange(pctEdgeLRsplitters{mouseI});
     pctEdgeSTsplittersChange{mouseI} = NNplusOnePropChange(pctEdgeSTsplitters{mouseI});
     pctEdgeLRforSTsplittersChange{mouseI} = NNplusOnePropChange(pctEdgeLRforSTsplitters{mouseI});
     pctEdgeSTforLRsplittersChange{mouseI} = NNplusOnePropChange(pctEdgeSTforLRsplitters{mouseI});
     
     [edgeMidEdgeLRcounts{mouseI}, edgeMidLRcounts{mouseI}] = DIedgeCount(dayDistLR{mouseI});
     [edgeMidEdgeSTcounts{mouseI}, edgeMidSTcounts{mouseI}] = DIedgeCount(dayDistST{mouseI});
     [edgeMidEdgeLRsplitterCounts{mouseI}, edgeMidLRsplitterCounts{mouseI}] = DIedgeCount(dayDistLRsplitters{mouseI});
     [edgeMidEdgeSTsplitterCounts{mouseI}, edgeMidSTsplitterCounts{mouseI}] = DIedgeCount(dayDistSTsplitters{mouseI});
end

allMicePctEdgeLRchange = [pctEdgeLRchange{:}];
allMicePctEdgeSTchange = [pctEdgeSTchange{:}];
allMicePctEdgeLRsplittersChange = [pctEdgeLRsplittersChange{:}];
allMicePctEdgeSTsplittersChange = [pctEdgeSTsplittersChange{:}];
allMicePctEdgeLRforSTsplittersChange = [pctEdgeLRforSTsplittersChange{:}];
allMicePctEdgeSTforLRsplittersChange = [pctEdgeSTforLRsplittersChange{:}];


%Dist pooled place/non place
allMiceDayDistLRplace = vertcat(dayDistLRplace{:});
allMiceDayDistSTplace = vertcat(dayDistSTplace{:});
allMiceDayDistLRnonPlace = vertcat(dayDistLRnonPlace{:});
allMiceDayDistSTnonPlace = vertcat(dayDistSTnonPlace{:});

allMiceEdgeLRplace = [pctEdgeLRplace{:}];
allMiceEdgeSTplace = [pctEdgeSTplace{:}];
allMiceEdgeLRnonPlace = [pctEdgeLRnonPlace{:}];
allMiceEdgeSTnonPlace = [pctEdgeSTnonPlace{:}];

[edgeplaceP(1), edgeplaceH(1)] = ranksum(allMiceEdgeLRplace, allMiceEdgeSTplace);
[edgeplaceP(2), edgeplaceH(2)] = ranksum(allMiceEdgeLRnonPlace, allMiceEdgeSTnonPlace);
testPairs = [1 2; 3 4];

%More breakdowns place
for mouseI = 1:numMice
     pctEdgeLRplaceChange{mouseI} = NNplusOnePropChange(pctEdgeLRplace{mouseI});
     pctEdgeSTplaceChange{mouseI} = NNplusOnePropChange(pctEdgeSTplace{mouseI});
     pctEdgeLRnonPlaceChange{mouseI} = NNplusOnePropChange(pctEdgeLRnonPlace{mouseI});
     pctEdgeSTnonPlaceChange{mouseI} = NNplusOnePropChange(pctEdgeSTnonPlace{mouseI});
     
     [edgeMidEdgeLRplaceCounts{mouseI}, edgeMidLRcounts{mouseI}] = DIedgeCount(dayDistLRplace{mouseI});
     [edgeMidEdgeSTplaceCounts{mouseI}, edgeMidSTcounts{mouseI}] = DIedgeCount(dayDistSTplace{mouseI});
     [edgeMidEdgeLRnonPlaceCounts{mouseI}, edgeMidLRsplitterCounts{mouseI}] = DIedgeCount(dayDistLRnonPlace{mouseI});
     [edgeMidEdgeSTnonPlaceCounts{mouseI}, edgeMidSTsplitterCounts{mouseI}] = DIedgeCount(dayDistSTnonPlace{mouseI});
end

allMicePctEdgeLRplaceChange = [pctEdgeLRplaceChange{:}];
allMicePctEdgeSTplaceChange = [pctEdgeSTplaceChange{:}];
allMicePctEdgeLRnonPlaceChange = [pctEdgeLRnonPlaceChange{:}];
allMicePctEdgeSTnonPlaceChange = [pctEdgeSTnonPlaceChange{:}];

for binI = 1:length(binEdges)-1
    amppLRplace = allMicePctDistLRplace(:,binI);
    amPctsDistMeanLRplace(1,binI) = mean(amppLRplace(amppLRplace~=0));
    amPctsDistSEMsLRplace(1,binI) = standarderrorSL(amppLRplace(amppLRplace~=0));
    
end

%L edge, mid, right egde
anovaGroup = [ones(size(amPctsDistMeanLR,1),1) 2*ones(size(amPctsDistMeanLR,1),size(amPctsDistMeanLR,2)-2) 3*ones(size(amPctsDistMeanLR,1),1)];
%Edge or not
anovaGroup = [ones(size(amPctsDistMeanLR,1),1) 2*ones(size(amPctsDistMeanLR,1),size(amPctsDistMeanLR,2)-2) ones(size(amPctsDistMeanLR,1),1)];
LRmids = allMicePctDistLR(:,2:end-1);
STmids = allMicePctDistST(:,2:end-1);
anovagroup = [ones(size(LRmids,1),size(LRmids,2)) 2*ones(size(STmids,1),size(STmids,2))];
anovadata = [LRmids STmids];
[p,tbl]=anovan(anovadata(:),anovagroup(:)) %Better done as a chi square for counts? (Edge, middle, other edge?)
figure; scatterBoxSL(anovadata(:), anovagroup(:),'plotBox',true) 
[p,tbl]=anovan(anovadata(anovadata~=0),anovagroup(anovadata~=0)) %Probably not really fair to throw out 0s
figure; scatterBoxSL(anovadata(anovadata~=0), anovagroup(anovadata~=0),'plotBox',true)

disp('Done looking at Discrimination Index scores')

   
%% Cell identity round-up

%Place splitter comparisons
pooledPctDailySplittersAny = [pctDailySplittersANY{:}];
pooledPctDailySplittersEXany = [pctDailySplittersEXany{:}];
pooledPctDailySplittersBOTH = [pctDailySplittersBOTH{:}];
pooledTotalPropPlace = [totalPropPlace{:}];
    
pooledPlaceAndSplitter = [pctDailyPlaceAndSplitter{:}];
pooledPlaceNotSplitter = [pctDailyPlaceNotSplitter{:}];
pooledSplitterNotPlace = [pctDailySplitterNotPlace{:}];
pooledNotSplitterNotPlace = [pctDailynotSplitterNotPlace{:}];


%Trait overall
for mouseI = 1:numMice
    reactivatesPlace(mouseI) = TraitReactivation(dayUse{mouseI}, placeThisDay{mouseI});
    reactivatesSplitter(mouseI) = TraitReactivation(dayUse{mouseI}, splittersANY{mouseI});
    reactivatesSplitterEX(mouseI) = TraitReactivation(dayUse{mouseI}, splittersEXany{mouseI});
    reactivatesSplitterBOTH(mouseI) = TraitReactivation(dayUse{mouseI}, splittersBOTH{mouseI});
    reactivatesPlaceAndSplitter(mouseI) = TraitReactivation(dayUse{mouseI}, placeAndSplitter{mouseI});
    reactivatesPlaceNotSplitter(mouseI) = TraitReactivation(dayUse{mouseI}, placeNotSplitter{mouseI}); 
    reactivatesSplitterNotPlace(mouseI) = TraitReactivation(dayUse{mouseI}, splitterNotPlace{mouseI});
    reactivatesNotSplitterNotPlace(mouseI) = TraitReactivation(dayUse{mouseI}, notSplitterNotPlace{mouseI}); 
end
%Pool
pooledReacBaseline = [reactivatesBaseline(:).prop];
pooledReacPlace = [reactivatesPlace(:).prop];
pooledReacSplitter = [reactivatesSplitter(:).prop];
pooledReacSplitterEx = [reactivatesSplitterEX(:).prop];
pooledReacSplitterBOTH = [reactivatesSplitterBOTH(:).prop];
pooledReacPlaceAndSplit = [reactivatesPlaceAndSplitter(:).prop];
pooledReacPlaceNotSplit = [reactivatesPlaceNotSplitter(:).prop];
pooledReacSplitNotPlace = [reactivatesSplitterNotPlace(:).prop];
pooledReacNotPlaceNotSplit = [reactivatesNotSplitterNotPlace(:).prop];

%N-N+1 change
for mouseI = 1:numMice
    [placeNumChange{mouseI}, placePctChange{mouseI}] = NNplusOneChange(placeThisDay{mouseI}, dayUse{mouseI});
    [splittersANYNumChange{mouseI}, splittersANYPctChange{mouseI}] = NNplusOneChange(splittersANY{mouseI}, dayUse{mouseI});
    [splittersEXanyNumChange{mouseI}, splittersEXanyPctChange{mouseI}] = NNplusOneChange(splittersEXany{mouseI}, dayUse{mouseI});
    [splittersBOTHNumChange{mouseI}, splittersBOTHPctChange{mouseI}] = NNplusOneChange(splittersBOTH{mouseI}, dayUse{mouseI});
    [placeAndSplitterNumChange{mouseI}, placeAndSplitterPctChange{mouseI}] = NNplusOneChange(placeAndSplitter{mouseI}, dayUse{mouseI});
    [placeNotSplitterNumChange{mouseI}, placeNotSplitterPctChange{mouseI}] = NNplusOneChange(placeNotSplitter{mouseI}, dayUse{mouseI});
    [splitterNotPlaceNumChange{mouseI}, splitterNotPlacePctChange{mouseI}] = NNplusOneChange(splitterNotPlace{mouseI}, dayUse{mouseI});
    [notSplitterNotPlaceNumChange{mouseI}, notSplitterNotPlacePctChange{mouseI}] = NNplusOneChange(notSplitterNotPlace{mouseI}, dayUse{mouseI});
end
pooledPlaceChange = [placePctChange{:}];
pooledSplittersANYchange = [splittersANYPctChange{:}];
pooledSplittersEXanyChange = [splittersEXanyPctChange{:}];
pooledSplittersBOTHChange = [splittersBOTHPctChange{:}];
pooledPlaceAndSplitterChange = [placeAndSplitterPctChange{:}];
pooledPlaceNotSplitterChange = [placeNotSplitterPctChange{:}];
pooledSplitterNotPlaceChange = [splitterNotPlacePctChange{:}];
pooledNotSplitterNotPlaceChange = [notSplitterNotPlacePctChange{:}];

%First v. last day change
for mouseI = 1:numMice
    dayPairsUse = [1; numDays(mouseI)];
    [placeFLnumCh(mouseI), placeFLpctCh(mouseI), ~] = FirstToLastChange(placeThisDay{mouseI}, dayUse{mouseI}, dayPairsUse);
    [splitANYFLnumCh(mouseI), splitANYFLpctCh(mouseI), ~] = FirstToLastChange(splittersANY{mouseI}, dayUse{mouseI}, dayPairsUse);
    [splitEXanyFLnumCh(mouseI), splitEXanyFLpctCh(mouseI), ~] = FirstToLastChange(splittersEXany{mouseI}, dayUse{mouseI}, dayPairsUse);
    [splitBOTHFLnumCh(mouseI), splitBOTHFLpctCh(mouseI), ~] = FirstToLastChange(splittersBOTH{mouseI}, dayUse{mouseI}, dayPairsUse);
    [placeAndSplitFLnumCh(mouseI), placeAndSplitFLpctCh(mouseI), ~] = FirstToLastChange(placeAndSplitter{mouseI}, dayUse{mouseI}, dayPairsUse);
    [placeNotSplitFLnumCh(mouseI), placeNotSplitFLpctCh(mouseI), ~] = FirstToLastChange(placeNotSplitter{mouseI}, dayUse{mouseI}, dayPairsUse);
    [splitNotPlaceFLnumCh(mouseI), splitNotPlaceFLpctCh(mouseI), ~] = FirstToLastChange(splitterNotPlace{mouseI}, dayUse{mouseI}, dayPairsUse);
    [notSplitNotPlaceFLnumCh(mouseI), notSplitNotPlaceFLpctCh(mouseI), ~] = FirstToLastChange(notSplitterNotPlace{mouseI}, dayUse{mouseI}, dayPairsUse);
end

%First 2 v. last 2 days change
for mouseI = 1:numMice3
    dayPairsUse = [1 2; numDays(mouseI)-1 numDays(mouseI)];
    [placeFLnumCh2(mouseI), placeFLpctCh2(mouseI), ~] = FirstToLastChange(placeThisDay{mouseI}, dayUse{mouseI}, dayPairsUse);
    [splitANYFLnumCh2(mouseI), splitANYFLpctCh2(mouseI), ~] = FirstToLastChange(splittersANY{mouseI}, dayUse{mouseI}, dayPairsUse);
    [splitEXanyFLnumCh2(mouseI), splitEXanyFLpctCh2(mouseI), ~] = FirstToLastChange(splittersEXany{mouseI}, dayUse{mouseI}, dayPairsUse);
    [splitBOTHFLnumCh2(mouseI), splitBOTHFLpctCh2(mouseI), ~] = FirstToLastChange(splittersBOTH{mouseI}, dayUse{mouseI}, dayPairsUse);
    [placeAndSplitFLnumCh2(mouseI), placeAndSplitFLpctCh2(mouseI), ~] = FirstToLastChange(placeAndSplitter{mouseI}, dayUse{mouseI}, dayPairsUse);
    [placeNotSplitFLnumCh2(mouseI), placeNotSplitFLpctCh2(mouseI), ~] = FirstToLastChange(placeNotSplitter{mouseI}, dayUse{mouseI}, dayPairsUse);
    [splitNotPlaceFLnumCh2(mouseI), splitNotPlaceFLpctCh2(mouseI), ~] = FirstToLastChange(splitterNotPlace{mouseI}, dayUse{mouseI}, dayPairsUse);
    [notSplitNotPlaceFLnumCh2(mouseI), notSplitNotPlaceFLpctCh2(mouseI), ~] = FirstToLastChange(notSplitterNotPlace{mouseI}, dayUse{mouseI}, dayPairsUse);
end

%shuffle 
for mouseI = 1:numMice3
    
    %dayPairsUse = shuffle some how;
    for shuffI = 1:stuff
    [placeFLnumCh2(shuffI, mouseI), placeFLpctCh2(mouseI), ~] = FirstToLastChange(placeThisDay{mouseI}, dayUse{mouseI}, dayPairsUse);
    [splitANYFLnumCh2(mouseI), splitANYFLpctCh2(mouseI), ~] = FirstToLastChange(splittersANY{mouseI}, dayUse{mouseI}, dayPairsUse);
    [splitEXanyFLnumCh2(mouseI), splitEXanyFLpctCh2(mouseI), ~] = FirstToLastChange(splittersEXany{mouseI}, dayUse{mouseI}, dayPairsUse);
    [splitBOTHFLnumCh2(mouseI), splitBOTHFLpctCh2(mouseI), ~] = FirstToLastChange(splittersBOTH{mouseI}, dayUse{mouseI}, dayPairsUse);
    [placeAndSplitFLnumCh2(mouseI), placeAndSplitFLpctCh2(mouseI), ~] = FirstToLastChange(placeAndSplitter{mouseI}, dayUse{mouseI}, dayPairsUse);
    [placeNotSplitFLnumCh2(mouseI), placeNotSplitFLpctCh2(mouseI), ~] = FirstToLastChange(placeNotSplitter{mouseI}, dayUse{mouseI}, dayPairsUse);
    [splitNotPlaceFLnumCh2(mouseI), splitNotPlaceFLpctCh2(mouseI), ~] = FirstToLastChange(splitterNotPlace{mouseI}, dayUse{mouseI}, dayPairsUse);
    [notSplitNotPlaceFLnumCh2(mouseI), notSplitNotPlaceFLpctCh2(mouseI), ~] = FirstToLastChange(notSplitterNotPlace{mouseI}, dayUse{mouseI}, dayPairsUse);
    end
end


%Coming or going

[traitEntrance, changeNums, changePct] = LogicalTraitDayChange(traitLogical, dayUse)

%Reactivation probability by type: if split/place/not on day n, how likely
%shows up again on day n+1
    %NEED TO normalize by number of cells active each day
%Baseline reactivation
for mouseI = 1:numMice
    reactivatesBaseline(mouseI) = TraitReactivation(dayUse{mouseI},dayUse{mouseI});
end


%Splitters detail
for mouseI = 1:numMice
    reactivatesLR{mouseI} = TraitReactivation(dayUse{mouseI},splittersLR{mouseI});
    reactivatesST{mouseI} = TraitReactivation(dayUse{mouseI},splittersST{mouseI});
    reactivatesLRonly{mouseI} = TraitReactivation(dayUse{mouseI},splittersLRonly{mouseI});
    reactivatesSTonly{mouseI} = TraitReactivation(dayUse{mouseI},splittersSTonly{mouseI});
    reactivatesBOTH{mouseI} = TraitReactivation(dayUse{mouseI},splittersBOTH{mouseI});
    reactivatesANY{mouseI} = TraitReactivation(dayUse{mouseI},splittersANY{mouseI});
    reactivatesNotSplitter{mouseI} = TraitReactivation(dayUse{mouseI},splittersNone{mouseI});
end



%Place x split
for mouseI = 1:numMice
    reactivatespxsLR{mouseI} = TraitReactivation(dayUse{mouseI}, placeSplitLR{mouseI});
    reactivatespxsST{mouseI} = TraitReactivation(dayUse{mouseI}, placeSplitST{mouseI});
    reactivatespxsLRonly{mouseI} = TraitReactivation(dayUse{mouseI}, placeSplitLRonly{mouseI});
    reactivatespxsSTonly{mouseI} = TraitReactivation(dayUse{mouseI}, placeSplitSTonly{mouseI});
    reactivatespxsBoth{mouseI} = TraitReactivation(dayUse{mouseI}, placeSplitBOTH{mouseI});
    reactivatespxsNone{mouseI} = TraitReactivation(dayUse{mouseI}, placeSplitNone{mouseI});
    reactivatesSplitterNotPlace{mouseI} = TraitReactivation(dayUse{mouseI}, logical(splittersANY{mouseI}.*notPlace{mouseI}));
    reactivatesPlaceNotSplitter{mouseI} = TraitReactivation(dayUse{mouseI}, logical(splittersNone{mouseI}.*placeThisDay{mouseI}));
    disp(['done reactivation by type mouse ' num2str(mouseI)])
end

%% Firing field center of mass

for mouseI = 1:numMice
    FiringCOMallCells{mouseI} = TMapFiringCOM(cellTMap_unsmoothed{mouseI});
    
    COMactiveCells{mouseI} = FiringCOMallCells{mouseI}(dayUse{mouseI});
    
    COMsplittersANY{mouseI} = FiringCOMallCells{mouseI}(splittersANY{mouseI});
    COMsplittersLR{mouseI} = FiringCOMallCells{mouseI}(splittersLR{mouseI});
    COMsplittersST{mouseI} = FiringCOMallCells{mouseI}(splittersST{mouseI});
    COMsplittersLRonly{mouseI} = FiringCOMallCells{mouseI}(splittersLRonly{mouseI});
    COMsplittersSTonly{mouseI} = FiringCOMallCells{mouseI}(splittersSTonly{mouseI});
    COMsplittersEXany{mouseI} = FiringCOMallCells{mouseI}(splittersEXany{mouseI});
    COMsplittersBOTH{mouseI} = FiringCOMallCells{mouseI}(splittersBOTH{mouseI});
    
    COMplace{mouseI} = FiringCOMallCells{mouseI}(placeThisDay{mouseI});
    COMplaceAndSplitter{mouseI} = FiringCOMallCells{mouseI}(placeAndSplitter{mouseI});
    COMplaceNotSplitter{mouseI} = FiringCOMallCells{mouseI}(placeNotSplitter{mouseI});
    COMsplitterNotPlace{mouseI} = FiringCOMallCells{mouseI}(splitterNotPlace{mouseI});
    COMnotSplitterNotPlace{mouseI} = FiringCOMallCells{mouseI}(notSplitterNotPlace{mouseI});
end


pool all this, then ranksum?


%% Lap following L/R
for mouseI = 1:numMice
    [xaxTBT{mouseI}, lapsIncLog{mouseI}] = XafterXtbt(cellTBT{mouseI});
    [xaxdayUse{mouseI},xaxthreshAndConsec{mouseI}] = GetUseCells(xaxTBT{mouseI}, lapPctThresh, consecLapThresh);
    [xaxtrialReli{mouseI},xaxaboveThresh{mouseI},~,~] = TrialReliability(xaxTBT{mouseI}, lapPctThresh);
    [xaxTMap_unsmoothed{mouseI}, xaxTMap_zRates{mouseI}, ~,~, ~, ~]=...
    PFsLinTrialbyTrial2(xaxTBT{mouseI}, xlims, cmperbin, minspeed,...
                [],'trialReli',xaxtrialReli{mouseI},'smooth',false);
    cellsUse = 'activeEither'; %'activeBoth' 'includeSilent'
    traitLogical = xaxthreshAndConsec{mouseI}>0;
    [xaxCorrs{mouseI}, xaxnumCellsUsed{mouseI}, xaxdayPairs{mouseI}, xaxcondPairs{mouseI}] =...
        PopVectorCorrs1(xaxTMap_unsmoothed{mouseI},traitLogical, 'activeEither', 'Spearman', [], []);
end
are there splitters based on this?


%% Variance of diff types of cell? Like splitting, but more wishy washy

[b,r,stats, MSE] = GetCellVarianceSource(trialbytrial,pooledUnpooled)



%% Population Vector Correlations


% Split days pv corrs: still pooled
TMapA = cell(1,numMice); TMapB = cell(1,numMice);
for mouseI = 1:numMice
    %Split the tbt
    [tbtA, tbtB] = SplitTrialByTrial(cellTBT{mouseI}, 'alternate');
    
    %make placefields from splits
    [TMapA{mouseI}, ~, ~, ~, ~, ~] =...
        PFsLinTrialbyTrial2(tbtA, xlims, cmperbin, minspeed,...
        [],'trialReli',trialReli{mouseI},'smooth',false,'condPairs',[1 3; 2 4; 1 2; 3 4]);
    [TMapB{mouseI}, ~, ~, ~, ~, ~] =...
        PFsLinTrialbyTrial2(tbtB, xlims, cmperbin, minspeed,...
        [],'trialReli',trialReli{mouseI},'smooth',false,'condPairs',[1 3; 2 4; 1 2; 3 4]);
end

%Progression over experiment with split data;
numPerms = 1000;
condSet{1} = 1:4;   % VS. Self
condSet{2} = [5 6]; % L v R
condSet{3} = [7 8]; % S v T
traitLogical = threshAndConsec;
 pooledCondPairs = [1 1; 2 2; 3 3; 4 4; 1 2; 2 1; 3 4; 4 3];
for mouseI = 1:numMice
    pooledTraitLogical = [];
    pooledTraitLogical(:,:,1) = sum(traitLogical{mouseI}(:,:,[1 3]),3) > 0;
    pooledTraitLogical(:,:,2) = sum(traitLogical{mouseI}(:,:,[2 4]),3) > 0;
    pooledTraitLogical(:,:,3) = sum(traitLogical{mouseI}(:,:,[1 2]),3) > 0;
    pooledTraitLogical(:,:,4) = sum(traitLogical{mouseI}(:,:,[3 4]),3) > 0;
  
    %pop vector corrs with 2 tmaps, 1 day only
   
    dayPairs = repmat(1:numDays(mouseI),2,1)';
    [pooledSplitCorrs{mouseI}, pooledSplitCumCells{mouseI}, ~, ~] = PopVectorCorrs2TMaps(TMapA{mouseI}, TMapB{mouseI}, pooledTraitLogical,...
        'activeEither', 'Spearman', pooledCondPairs, dayPairs);
    
    %Reorganize
    for cpJ = 1:size(pooledCondPairs,1)
        splitDayCorrsMean{mouseI}(:,cpJ) = mean(squeeze(pooledSplitCorrs{mouseI}(:,cpJ,:)),2);
    end
    for csI = 1:length(condSet)
        splitDayCorrsMeanCS{mouseI}(:,csI) = mean(splitDayCorrsMean{mouseI}(:,condSet{csI}),2);
    end 
    
    %Compare slope differences of LvR and SvT, R2 of fit compared to shuffles
    [slope{mouseI}, intercept{mouseI}, fitLine{mouseI}, Rsquared{mouseI}] = fitLinRegSL(splitDayCorrsMeanCS{mouseI}, realDays{mouseI});
    [slopeDiff{mouseI}, slopeDiffRank{mouseI}, RsquaredRank{mouseI}, comps{mouseI}] =...
        slopeDiffWrapper(splitDayCorrsMeanCS{mouseI}, realDays{mouseI}, numPerms);
    
    disp(['done  corrs mouse ' num2str(mouseI)])
end
%How to pool across mice with diff days?


%By Days apart with split data
numPerms = 1000;   
condSet{1} = 1:4;   % VS. Self
condSet{2} = [5 6]; % L v R
condSet{3} = [7 8]; % S v T
compLabels = {'vSelf','LvR','SvT'};
traitLogical = threshAndConsec;
pooledCondPairs = [1 1; 2 2; 3 3; 4 4; 1 2; 2 1; 3 4; 4 3];
allMiceSplitDayCorrsMean = cell(1,size(pooledCondPairs,1));
allMiceSplitDayDayDiffs = cell(1,size(pooledCondPairs,1));
allMiceSplitRealDayDayDiffs = cell(1,size(pooledCondPairs,1));
for mouseI = 1:numMice
    pooledTraitLogical = [];
    pooledTraitLogical(:,:,1) = sum(traitLogical{mouseI}(:,:,[1 3]),3) > 0;
    pooledTraitLogical(:,:,2) = sum(traitLogical{mouseI}(:,:,[2 4]),3) > 0;
    pooledTraitLogical(:,:,3) = sum(traitLogical{mouseI}(:,:,[1 2]),3) > 0;
    pooledTraitLogical(:,:,4) = sum(traitLogical{mouseI}(:,:,[3 4]),3) > 0;
      
    %pop vector corrs with split tmaps, all day pairs
    dayPairs = repmat(1:numDays(mouseI),2,1)';
    [allPooledSplitCorrs{mouseI}, allPooledSplitCumCells{mouseI}, allPooledDayPairs{mouseI}, ~] = PopVectorCorrs2TMaps(TMapA{mouseI}, TMapB{mouseI}, pooledTraitLogical,...
        'activeEither', 'Spearman', pooledCondPairs, []);
    allPooledDayDiffs{mouseI} = abs(diff(allPooledDayPairs{mouseI},1,2));
    allPooledRealDayPairs{mouseI} = cellRealDays{mouseI}(allPooledDayPairs{mouseI});
    allPooledRealDayDiffs{mouseI} = abs(diff(allPooledRealDayPairs{mouseI},1,2));
    
    %Reorganize, mean within day across bins, and pool across mice
    allSameDays = find(pooledCondPairs(:,1) == pooledCondPairs(:,2));
    numExtra = size(combnk(1:numDays(mouseI),2),1);
    for cpJ = 1:size(pooledCondPairs,1)
        allSplitDayCorrsMean{mouseI}{cpJ} = mean(squeeze(allPooledSplitCorrs{mouseI}(:,cpJ,:)),2); %mean across bins
        allPooledDayDiffsCP{mouseI}{cpJ} = allPooledDayDiffs{mouseI};
        allPooledRealDayDiffsCP{mouseI}{cpJ} = allPooledRealDayDiffs{mouseI};
        if sum(allSameDays == cpJ) == 1 %Chop off where comparison is identical
            allSplitDayCorrsMean{mouseI}{cpJ}(end-numExtra+1:end) = [];
            allPooledDayDiffsCP{mouseI}{cpJ}(end-numExtra+1:end,:) = [];
            allPooledRealDayDiffsCP{mouseI}{cpJ}(end-numExtra+1:end,:) = [];
        end
        
        allMiceSplitDayCorrsMean{cpJ} = [allMiceSplitDayCorrsMean{cpJ}; allSplitDayCorrsMean{mouseI}{cpJ}];
        allMiceSplitDayDayDiffs{cpJ} = [allMiceSplitDayDayDiffs{cpJ}; allPooledDayDiffsCP{mouseI}{cpJ}];
        allMiceSplitRealDayDayDiffs{cpJ} = [allMiceSplitRealDayDayDiffs{cpJ}; allPooledRealDayDiffsCP{mouseI}{cpJ}];
    end
    
    %Compare slope differences of LvR and SvT, R2 of fit compared to shuffles
    [slope{mouseI}, intercept{mouseI}, fitLine{mouseI}, Rsquared{mouseI}] = fitLinRegSL(splitDayCorrsMeanCS{mouseI}, realDays{mouseI});
    [slopeDiff{mouseI}, slopeDiffRank{mouseI}, RsquaredRank{mouseI}, comps{mouseI}] =...
        slopeDiffWrapper(splitDayCorrsMeanCS{mouseI}, realDays{mouseI}, numPerms);
    
    disp(['done all day pair pv corrs mouse ' num2str(mouseI)])
end

%Pool across condSet
for csK = 1:length(condSet)
    dTemp = [allMiceSplitDayCorrsMean{condSet{csK}}];
    ddTemp = [allMiceSplitDayDayDiffs{condSet{csK}}];
    dddTemp = [allMiceSplitRealDayDayDiffs{condSet{csK}}];
    
    pooledAllMiceSplitDayCorrsMean{csK} = dTemp(:);
    pooledAllMiceSplitDayDayDiffs{csK} = ddTemp(:);
    pooledAllMiceSplitRealDayDayDiffs{csK} = dddTemp(:);
    
    [pamsdcSlope(csK), pamsdcIntercept(csK), ~, ~] =...
        fitLinRegSL(pooledAllMiceSplitDayCorrsMean{csK},pooledAllMiceSplitDayDayDiffs{csK});
    allPooledSplitFitLine{csK} = [unique(pooledAllMiceSplitDayDayDiffs{csK}),...
        unique(pooledAllMiceSplitDayDayDiffs{csK})*pamsdcSlope(csK)+pamsdcIntercept(csK)];
    [rpamsdcSlope(csK), rpamsdcIntercept(csK), ~, ~] =...
        fitLinRegSL(pooledAllMiceSplitDayCorrsMean{csK},pooledAllMiceSplitRealDayDayDiffs{csK});
    rallPooledSplitFitLine{csK} = [unique(pooledAllMiceSplitRealDayDayDiffs{csK}), ...
        unique(pooledAllMiceSplitRealDayDayDiffs{csK})*rpamsdcSlope(csK)+rpamsdcIntercept(csK)];     
end
[pooledSplitSlopeDiff, pooledSplitSlopeDiffRank, pooledSplitRsquaredRank, pooledSplitComps] =...
    slopeDiffWrapperCell(pooledAllMiceSplitDayCorrsMean, pooledAllMiceSplitDayDayDiffs, numPerms);
[rpooledSplitSlopeDiff, rpooledSplitSlopeDiffRank, rpooledSplitRsquaredRank, rpooledSplitComps] =...
    slopeDiffWrapperCell(pooledAllMiceSplitDayCorrsMean, pooledAllMiceSplitRealDayDayDiffs, numPerms);

annotationToPlot{1,1} = 'Slope difference comparisons';
for csQ = 1:length(condSet)
    pHere = 1-(rpooledSplitSlopeDiffRank(csQ)/numPerms);
annotationToPlot{csQ+1,1} = [compLabels{rpooledSplitComps(csQ,1)} ' vs ' compLabels{rpooledSplitComps(csQ,2)} ' >> p = ' num2str(pHere)];
end

%Mean across condSet
allMiceSplitDayCorrsMeanCS = cell(1,length(condSet));
allMiceSplitDayDayDiffsCS = cell(1,length(condSet));
allMiceSplitRealDayDayDiffsCS = cell(1,length(condSet));
for csI = 1:length(condSet)
    allMiceSplitDayCorrsMeanCS{csI} = mean([allMiceSplitDayCorrsMean{condSet{csI}}],2);
    allMiceSplitDayDayDiffsCS{csI} = allMiceSplitDayDayDiffs{condSet{csI}(1)};
    allMiceSplitRealDayDayDiffsCS{csI} = allMiceSplitRealDayDayDiffs{condSet{csI}(1)};
end
%bin by day diff
sessDayDiffs = unique(allMiceSplitDayDayDiffsCS{end}); 
calDayDiffs = unique(allMiceSplitRealDayDayDiffsCS{end});
for csJ = 1:length(condSet)
    for ddI = 1:length(sessDayDiffs)
        ddAllMiceSplitMeanCS(ddI,csJ) = mean(allMiceSplitDayCorrsMeanCS{csJ}(allMiceSplitDayDayDiffsCS{csJ}==sessDayDiffs(ddI)));
        ddAllMiceSplitMeanSEM(ddI,csJ) = standarderrorSL(allMiceSplitDayCorrsMeanCS{csJ}(allMiceSplitDayDayDiffsCS{csJ}==sessDayDiffs(ddI)));
    end
    for ddJ = 1:length(sessDayDiffs)
        ddRealAllMiceSplitMeanCS(ddJ,csJ) = mean(allMiceSplitDayCorrsMeanCS{csJ}(allMiceSplitRealDayDayDiffsCS{csJ}==calDayDiffs(ddJ)));
        ddRealAllMiceSplitMeanSEM(ddJ,csJ) = standarderrorSL(allMiceSplitDayCorrsMeanCS{csJ}(allMiceSplitRealDayDayDiffsCS{csJ}==calDayDiffs(ddJ)));
    end
end
    
%Ranksum test each pair of day diffs for each color line pair
sessDayDiffs = unique(pooledAllMiceSplitDayDayDiffs{1});
calDayDiffs = unique(pooledAllMiceSplitRealDayDayDiffs{1});
compares = combnk(1:length(condSet),2);
for compI = 1:size(compares,1)
    for ddI = 1:length(sessDayDiffs)
        dataHereA = pooledAllMiceSplitDayCorrsMean{compares(compI,1)}...
            (pooledAllMiceSplitDayDayDiffs{compares(compI,1)}==sessDayDiffs(ddI));
        dataHereB = pooledAllMiceSplitDayCorrsMean{compares(compI,2)}...
            (pooledAllMiceSplitDayDayDiffs{compares(compI,2)}==sessDayDiffs(ddI));
        
        [pPooledSplitDaySess(compI,ddI),hPooledSplitDaySess(compI,ddI)] = ranksum(dataHereA,dataHereB);
    end
    for ddJ = 1:length(calDayDiffs)
        dataHereA = pooledAllMiceSplitDayCorrsMean{compares(compI,1)}...
            (pooledAllMiceSplitRealDayDayDiffs{compares(compI,1)}==calDayDiffs(ddJ));
        dataHereB = pooledAllMiceSplitDayCorrsMean{compares(compI,2)}...
            (pooledAllMiceSplitRealDayDayDiffs{compares(compI,2)}==calDayDiffs(ddJ));
        
        [pPooledSplitDayCal(compI,ddJ),hPooledSplitDayCal(compI,ddJ)] = ranksum(dataHereA,dataHereB);
    end
end



%Pooled pop vector corrs
pooledCondPairs = [1 1; 2 2; 3 3; 4 4; 1 2; 2 1; 3 4; 4 3];
dayPairs = [];
traitLogical = threshAndConsec;
for mouseI = 1:numMice
    pooledTraitLogical = [];
    pooledTraitLogical(:,:,1) = sum(traitLogical{mouseI}(:,:,[1 3]),3) > 0;
    pooledTraitLogical(:,:,2) = sum(traitLogical{mouseI}(:,:,[2 4]),3) > 0;
    pooledTraitLogical(:,:,3) = sum(traitLogical{mouseI}(:,:,[1 2]),3) > 0;
    pooledTraitLogical(:,:,4) = sum(traitLogical{mouseI}(:,:,[3 4]),3) > 0;
    [pooledCorrs{mouseI}, pooldNumCellsUsed{mouseI}, pooledDayPairs{mouseI}, pooledCondPairsOut{mouseI}] = ...
        PopVectorCorrs1(cellPooledTMap_unsmoothed{mouseI},pooledTraitLogical, 'activeEither', 'Spearman', pooledCondPairs, []);
    pooledDayDiffs{mouseI} = abs(diff(pooledDayPairs{mouseI},1,2));
    pooledRealDayPairs{mouseI} = cellRealDays{mouseI}(pooledDayPairs{mouseI});
    pooledRealDayDiffs{mouseI} = abs(diff(pooledRealDayPairs{mouseI},1,2));
end

condSet{1} = 1:4;   % VS. Self
condSet{2} = [5 6]; % L v R
condSet{3} = [7 8]; % S v T
%Reorganize across mice, mean across spatial bins
allDayDiffs = [];
allRealDayDiffs = [];
allPooledMouseID = [];
allCorrsMean = cell(size(pooledCondPairs,1),1);
for mouseI = 1:numMice
    allDayDiffs = [allDayDiffs; pooledDayDiffs{mouseI}];
    allRealDayDiffs = [allRealDayDiffs; pooledRealDayDiffs{mouseI}];
    allPooledMouseID = [allPooledMouseID; mouseI*ones(length(pooledDayDiffs{mouseI}),1)];
    for cpI = 1:size(pooledCondPairs,1)    
        allCorrsMean{cpI} = [allCorrsMean{cpI}; mean(squeeze(pooledCorrs{mouseI}(:,cpI,:)),2)]; %Mean across spatial bins    
    end
end

%Pooled by condSet
for csI = 1:length(condSet)
    tempHold = [allCorrsMean{condSet{csI}}];
    tempDays = repmat(allDayDiffs,1,length(condSet{csI}));
    tempRealDays = repmat(allRealDayDiffs,1,length(condSet{csI}));
    
    allCorrsMeanCS{csI} = tempHold(:);
    allDayDiffsCS{csI} = tempDays(:);
    allRealDayDiffsCS{csI} = tempRealDays(:);
end
        

% Mean by day diff 
eachDayDiffs = unique(allDayDiffs); eachDayDiffs = eachDayDiffs(eachDayDiffs > 0);
eachRealDayDiffs = unique(allRealDayDiffs); eachRealDayDiffs = eachRealDayDiffs(eachRealDayDiffs > 0);
for cpJ = 1:size(pooledCondPairs,1)
    for ddJ = 1:length(eachDayDiffs)
        ddMeanLine(cpJ,ddJ) = mean(allCorrsMean{cpJ}(allDayDiffs==eachDayDiffs(ddJ)));
        ddSEMline(cpJ,ddJ) = standarderrorSL(allCorrsMean{cpJ}(allDayDiffs==eachDayDiffs(ddJ)));
    end
    for ddK = 1:length(eachRealDayDiffs)
        ddRealMeanLine(cpJ,ddK) = mean(allCorrsMean{cpJ}(allRealDayDiffs==eachRealDayDiffs(ddK)));
        ddRealSEMline(cpJ,ddK) = standarderrorSL(allCorrsMean{cpJ}(allRealDayDiffs==eachRealDayDiffs(ddK)));
    end
end

% Mean across condSets
for csI = 1:length(condSet)
    ddMeanLineCS(csI,:) = mean(ddMeanLine(condSet{csI},:),1);
    ddSEMlineCS(csI,:) = mean(ddSEMline(condSet{csI},:),1);
    
    ddRealMeanLineCS(csI,:) = mean(ddRealMeanLine(condSet{csI},:),1);
    ddRealSEMlineCS(csI,:) = mean(ddRealSEMline(condSet{csI},:),1);
end

%Progression over experiment 
dayCorrsMean{cpJ} = cell(size(condPairs,1),1);
for mouseI = 1:numMice
    sameDay = find(pooledDayPairs{mouseI}(:,1) == pooledDayPairs{mouseI}(:,2));
    [~,rightOrder] = sort(pooledDayPairs{mouseI}(sameDay,1),'ascend');
    sameDaySorted = sameDay(rightOrder);
    for cpJ = 1:size(pooledCondPairs,1)
        dayCorrsMean{mouseI}(:,cpJ) = mean(squeeze(pooledCorrs{mouseI}(sameDaySorted,cpJ,:)),2);
    end
    for csI = 1:length(condSet)
        dayCorrsMeanCS{mouseI}(:,csI) = mean(dayCorrsMean{mouseI}(:,condSet{csI}),2);
    end    
end


%% Other PV stuff
%Average PV day by day
condPairsAll = [1 2; 3 4; 1 3; 2 4];
dayPairs = []; condPairs = []; singleDayPairs = [];
for mouseI = 1:numMice
    dayPairs = repmat(1:numDays(mouseI),2,1)';
    cellsUse = 'activeEither';
    traitLogical = threshAndConsec{mouseI}>0;
    [singleDayCorrs{mouseI}, numCellsUsed{mouseI}, singleDayPairs{mouseI}, singleDayCondPairs{mouseI}] =...
        PopVectorCorrs1(cellTMap_unsmoothed{mouseI},traitLogical, 'activeEither', 'Spearman', condPairsAll, dayPairs);
end

dayPairs = []; condPairs = [];
for mouseI = 1:numMice
    cellsUse = 'activeEither'; %'activeBoth' 'includeSilent'
    traitLogical = threshAndConsec{mouseI}>0;
    [Corrs{mouseI}, numCellsUsed{mouseI}, dayPairs{mouseI}, condPairs{mouseI}] =...
        PopVectorCorrs1(cellTMap_unsmoothed{mouseI},traitLogical, 'activeEither', 'Spearman', [], []);
end

meanLine = []; SEMline = [];
allPooledMeans = cell(length(condSet),1);
allPooledDayDiffs = cell(length(condSet),1);
allPooledMouseID = cell(length(condSet),1);

for mouseI = 1:numMice
    dayDiffsUse{mouseI} = pooledDayDiffs{mouseI};
    %dayDiffsUse{mouseI} = pooledRealDayDiffs{mouseI};
    dayDiffsHere = unique(dayDiffsUse{mouseI});
    dayDiffsHere = dayDiffsHere(dayDiffsHere > 0); %Eliminate compare to self

    
    for csI = 1:length(condSet)
        for ddI = 1:length(dayDiffsHere)
            dataHere = []; meanCorrs = [];
            dayPairsUse = find(dayDiffsUse{mouseI}==dayDiffsHere(ddI));
            condPairsUse = condSet{csI};
            dataHere = pooledCorrs{mouseI}(dayPairsUse,condPairsUse,:); %Day pair, cond pair, bin
            meanCorrs = mean(dataHere,3); meanCorrs = meanCorrs(:); meanCorrs(isnan(meanCorrs))=[]; %Meaned across spatial bins
            meanLine{mouseI}(csI,ddI) = mean(meanCorrs); SEMline{mouseI}(csI,ddI) = standarderrorSL(meanCorrs);
            
            ddExpanded = ones(length(meanCorrs(:)),1)*dayDiffsHere(ddI);
            
            allPooledMeans{csI} = [allPooledMeans{csI}; meanCorrs];
            allPooledDayDiffs{csI} = [allPooledDayDiffs{csI}; ddExpanded];
            allPooledMouseID{csI} = [allPooledMouseID{csI}; mouseI*ones(length(meanCorrs),1)];
            allPooledRealDayDiff
        end
    end
end



[Corrs, sigMat] = PopVectorCorrsWrapper1(TMap_unsmoothed, shuffleFolder,...
    traitLogical, cellsUse, corrType, condPairs, dayPairs, pThresh, sigTails)
    





%how to think about shuffles? Maybe pre-select condpairs and load appropriate shuffles?
%    should work for same cells by giving it the same traitLogical as normal

    
    
%organization for comparison to shuffled?
%organization for plotting?


%% Decoder analysis
numShuffles = 100;
%numShuffles = 20;
activityType = [];


folderName = 'decoding180611';
decodeFileName = {'decoderAllPooled', 'decoderLRsplittersPooled', 'decoderSTsplittersPooled',...
                  'decoderPlacecellsPooled', 'decoderNonPlacePooled', 'decoderLRsplitOnly', 'decoderSTsplitOnly', 'decoderNonSplitters'};  
traitLogicalUse = {dayUse,                  splittersLR,                splittersST,...
                   placeThisDay,              notPlace,                splittersLRonly,    splittersSTonly, splittersNone};
              
%here to set up cell number restrictions

allPerformanceFile = fullfile(mainFolder,mice{numMice},folderName,'decodingPerformanceAllMice.mat');
if exist(allPerformanceFile,'file') ~= 2
    for dcI = 1:length(traitLogicalUse)
        for mouseI = 1:numMice
        %tic
        decodeFile = fullfile(mainFolder,mice{mouseI},folderName,[decodeFileName{dcI} '.mat']);
        if exist(decodeFile,'file')~=2
            disp(['did not find decoder --' decodeFileName{dcI} '--  performance for mouse ' num2str(mouseI) ', running now'])
            [performance, miscoded, typePredict, sessPairs, condsInclude] =...
            DecoderWrapper2(cellTBT{mouseI},traitLogicalUse{dcI}{mouseI},cellRealDays{mouseI},numShuffles,activityType,...
                            'pooled',[],[]);
            save(decodeFile,'performance','miscoded','typePredict','sessPairs','condsInclude')
        end
        load(decodeFile)
        cellSessPairs{mouseI} = sessPairs;
        decodeAllperf{mouseI} = performance;
        cellDecodePerformance{dcI}{mouseI} = performance;
        daysApart = diff(cellRealDays{mouseI}(cellSessPairs{mouseI}), 1, 2);
        cellDaysApart{dcI}{mouseI} = daysApart;
        sigDecoding = decoderSignificance(decodeAllperf{mouseI},cellSessPairs{mouseI},pThresh);
        cellSigDecoding{dcI}{mouseI} = sigDecoding;
        save([decodeFile(1:end-4) 'Sig.mat'], 'sigDecoding','daysApart');
        %toc
        end
        disp(['Finished decoder setup ' num2str(dcI) ' / ' num2str(length(traitLogicalUse))])
    end
    save(allPerformanceFile,'cellDaysApart','cellSigDecoding','cellDecodePerformance','decodeFileName','cellSessPairs')
else
    load(allPerformanceFile)
end


[activeCellsOverlap, overlapWithModel, overlapWithTest] = GetCellsOverlap(traitLogicalOne, traitLogicalTwo, dayPairs)

%Eval number of cells used
for mouseI = 1:numMice
    for dcI = 1:length(traitLogicalUse)
        numEachDay = sum(traitLogicalUse{dcI}{mouseI},1);
        for dpI = 1:size(cellSessPairs{mouseI},1)
            numCellsUsedDecode{dcI}{mouseI}(dpI,1) = numEachDay(cellSessPairs{mouseI}(dpI,1))/sum(dayUse{mouseI}(:,cellSessPairs{mouseI}(dpI,1)),1); %training sess only
            activeCellsOverlap{dcI}{mouseI}(dpI,1) = sum(sum(traitLogicalUse{dcI}{mouseI}(:,cellSessPairs{mouseI}(dpI,:)),2)==2);
            overlapWithModel{dcI}{mouseI}(dpI,1) = activeCellsOverlap{dcI}{mouseI}(dpI,1)/sum(dayUse{mouseI}(:,cellSessPairs{mouseI}(dpI,1)));
            overlapWithTest{dcI}{mouseI}(dpI,1) = activeCellsOverlap{dcI}{mouseI}(dpI,1)/sum(dayUse{mouseI}(:,cellSessPairs{mouseI}(dpI,2)));
            if overlapWithModel{dcI}{mouseI}(dpI,1) == 0
                keyboard
            elseif overlapWithTest{dcI}{mouseI}(dpI,1) == 0
                keyboard
            end
        end
    end  
end

    


%Pool results
for mouseI = 1:numMice
    load( )
    for colNow = 1:size(performance,2)
        allPerformance{mouseI} = performance{1,colNow};
        shufflePerformance{2:end,mouseI} = performance{2:end,colNow};
        
    end
end

for mouseI = 1:numMice
    traitLogicalArr = {dayUse{mouseI}, splittersLR{mouseI}, splittersST{mouseI}, placeThisDay{mouseI}, notPlace{mouseI}};
     
end



numShuffles = 10;
    mouseI = 1
    decodeAll = fullfile(mainFolder,mice{mouseI},'\decodingXAX','decoderAllXAXsplit.mat');
    if exist(decodeAll,'file')~=2
        disp(['did not find decoder all/split performance for mouse ' num2str(mouseI) ', running now'])
        [performance, miscoded, typePredict, sessPairs, condsInclude] =...
        DecoderWrapper1(xaxTBT{mouseI},xaxdayUse{mouseI},cellRealDays{mouseI},numShuffles,activityType);
        save(decodeAll,'performance','miscoded','typePredict','sessPairs','condsInclude')
    end
    load(decodeAll)
    cellSessPairs{mouseI} = sessPairs;
    decodeAllperf{mouseI} = performance;
    daysApart{mouseI} = diff(cellRealDays{mouseI}(cellSessPairs{mouseI}), 1, 2);
    sigDecodingAll{mouseI} = decoderSignificance(decodeAllperf{mouseI},cellSessPairs{mouseI},pThresh);

%All Cells
for mouseI = 1:numMice
    tic
    decodeAll = fullfile(mainFolder,mice{mouseI},'\decoding','decoderAllsplitPooled.mat');
    if exist(decodeAll,'file')~=2
        disp(['did not find decoder all/split performance for mouse ' num2str(mouseI) ', running now'])
        [performance, miscoded, typePredict, sessPairs, condsInclude] =...
        DecoderWrapper1(cellTBT{mouseI},dayUse{mouseI},cellRealDays{mouseI},numShuffles,activityType);
        save(decodeAll,'performance','miscoded','typePredict','sessPairs','condsInclude')
    end
    load(decodeAll)
    cellSessPairs{mouseI} = sessPairs;
    decodeAllperf{mouseI} = performance;
    daysApart{mouseI} = diff(cellRealDays{mouseI}(cellSessPairs{mouseI}), 1, 2);
    sigDecodingAll{mouseI} = decoderSignificance(decodeAllperf{mouseI},cellSessPairs{mouseI},pThresh);
    toc
end


%Left/Right splitters (decoding only in cell cols 1 & 2)
for mouseI = 1:numMice
    decodeLR = fullfile(mainFolder,mice{mouseI},'\decoding','decoderLRsplit2.mat');
    if exist(decodeLR,'file')~=2
        disp(['did not find decoder lr/split performance for mouse ' num2str(mouseI) ', running now'])
        [performance, miscoded, typePredict, sessPairs, condsInclude] =...
        DecoderWrapper1(cellTBT{mouseI},LRthisCellSplits{mouseI},cellRealDays{mouseI},numShuffles,activityType);
        save(decodeLR,'performance','miscoded','typePredict','sessPairs','condsInclude')
    end
    load(decodeLR)
    cellSessPairs{mouseI} = sessPairs;
    decodeLRperf{mouseI} = performance;
    daysApart{mouseI} = diff(cellRealDays{mouseI}(cellSessPairs{mouseI}), 1, 2);
    sigDecodingLR{mouseI} = decoderSignificance(decodeLRperf{mouseI},cellSessPairs{mouseI},pThresh);
end

%Study/Test splitters(decoding only in cell cols 3 & 4)
for mouseI = 1:numMice
    decodeST = fullfile(mainFolder,mice{mouseI},'\decoding','decoderSTsplit2.mat');
    if exist(decodeST,'file')~=2
        disp(['did not find decoder st/split performance for mouse ' num2str(mouseI) ', running now'])
        [performance, miscoded, typePredict, sessPairs, condsInclude] =...
        DecoderWrapper1(cellTBT{mouseI},STthisCellSplits{mouseI},cellRealDays{mouseI},numShuffles,activityType);
        save(decodeST,'performance','miscoded','typePredict','sessPairs','condsInclude')
    end
    load(decodeST)
    cellSessPairs{mouseI} = sessPairs;
    decodeSTperf{mouseI} = performance;
    daysApart{mouseI} = diff(cellRealDays{mouseI}(cellSessPairs{mouseI}), 1, 2);
    sigDecodingST{mouseI} = decoderSignificance(decodeSTperf{mouseI},cellSessPairs{mouseI},pThresh);
end

%Place vs. non-place
%Randomly chosen from active (match number to place/splitters)

%% RSA maybe




%% Boneyard

%Old DI score stuff

    %{
    DImeansLRsplitters = DImeansLR; DImeansLRsplitters(LRthisCellSplits{mouseI}==0) = NaN; %LR only?
    DImeansSTsplitters = DImeansST; DImeansSTsplitters(STthisCellSplits{mouseI}==0) = NaN; %ST only?
    DImeansLRboth = DImeanLR{mouseI}; DImeansLRboth(splittersBOTH{mouseI}==0) = NaN; %DIs of both Splitters
    DImeansSTboth = DImeanST{mouseI}; DImeansSTboth(splittersBOTH{mouseI}==0) = NaN;
    %DImeansNOTLRsplitters = DImeansLR; DImeansNOTLRsplitters(LRthisCellSplits{mouseI}==1) = NaN; %LR only?
    %DImeansNOTSTsplitters = DImeansST; DImeansNOTSTsplitters(STthisCellSplits{mouseI}==1) = NaN; %ST only?
    DImeansNOTLRsplitters = DImeansLR; DImeansNOTLRsplitters(nonLRsplitters{mouseI}==0) = NaN; %LR only? Should be same as above?
    DImeansNOTSTsplitters = DImeansST; DImeansNOTSTsplitters(nonSTsplitters{mouseI}==0) = NaN; %ST only? Should be same as above?
    %}
    %{
    for dayI = 1:size(DImeanLR{mouseI},2)
        %dayDistLR(mouseI,dayI) = histcounts(DImeanLR{mouseI}(:,dayI),binEdges);
        %dayDistST(mouseI,dayI) = histcounts(DImeanST{mouseI}(:,dayI),binEdges);
        
        %All LR splitters
        dayDistLR{mouseI}(dayI,:) = histcounts(DImeansLR(:,dayI),binEdges); %Active only; why day use again?
        dayDistST{mouseI}(dayI,:) = histcounts(DImeansST(:,dayI),binEdges); %Active only
        pctDayDistLR{mouseI}(dayI,:) =  dayDistLR{mouseI}(dayI,:) / sum(dayDistLR{mouseI}(dayI,:)); %by percentage
        pctDayDistST{mouseI}(dayI,:) =  dayDistST{mouseI}(dayI,:) / sum(dayDistST{mouseI}(dayI,:));
        pctEdgeLR{mouseI}(dayI) = sum(pctDayDistLR{mouseI}(dayI,[1 end]));
        pctEdgeST{mouseI}(dayI) = sum(pctDayDistST{mouseI}(dayI,[1 end]));
        
        dayDistLRsplitters{mouseI}(dayI,:) = histcounts(DImeansLRsplitters(:,dayI),binEdges); %Active only
        dayDistSTsplitters{mouseI}(dayI,:) = histcounts(DImeansSTsplitters(:,dayI),binEdges); %Active only
        pctDayDistLRsplitters{mouseI}(dayI,:) =  dayDistLRsplitters{mouseI}(dayI,:) / sum(dayDistLRsplitters{mouseI}(dayI,:));
        pctDayDistSTsplitters{mouseI}(dayI,:) =  dayDistSTsplitters{mouseI}(dayI,:) / sum(dayDistSTsplitters{mouseI}(dayI,:));
        pctEdgeLRsplitters{mouseI}(dayI) = sum(pctDayDistLRsplitters{mouseI}(dayI,[1 end]));
        pctEdgeSTsplitters{mouseI}(dayI) = sum(pctDayDistSTsplitters{mouseI}(dayI,[1 end]));
        
        dayDistLRboth{mouseI}(dayI,:) = histcounts(DImeansLRboth(:,dayI),binEdges); %Active only
        dayDistSTboth{mouseI}(dayI,:) = histcounts(DImeansSTboth(:,dayI),binEdges); %Active only
        pctDayDistLRboth{mouseI}(dayI,:) =  dayDistLRboth{mouseI}(dayI,:) / sum(dayDistLRboth{mouseI}(dayI,:));
        pctDayDistSTboth{mouseI}(dayI,:) =  dayDistSTboth{mouseI}(dayI,:) / sum(dayDistSTboth{mouseI}(dayI,:));
        pctEdgeLRboth{mouseI}(dayI) = sum(pctDayDistLRboth{mouseI}(dayI,[1 end]));
        pctEdgeSTboth{mouseI}(dayI) = sum(pctDayDistSTboth{mouseI}(dayI,[1 end]));
        
        dayDistNOTLRsplitters{mouseI}(dayI,:) = histcounts(DImeansNOTLRsplitters(:,dayI),binEdges); %Active only
        dayDistNOTSTsplitters{mouseI}(dayI,:) = histcounts(DImeansNOTSTsplitters(:,dayI),binEdges); %Active only
        pctDayDistNOTLRsplitters{mouseI}(dayI,:) =  dayDistNOTLRsplitters{mouseI}(dayI,:) / sum(dayDistNOTLRsplitters{mouseI}(dayI,:));
        pctDayDistNOTSTsplitters{mouseI}(dayI,:) =  dayDistNOTSTsplitters{mouseI}(dayI,:) / sum(dayDistNOTSTsplitters{mouseI}(dayI,:));
        pctEdgeNOTLRsplitters{mouseI}(dayI) = sum(pctDayDistNOTLRsplitters{mouseI}(dayI,[1 end]));
        pctEdgeNOTSTsplitters{mouseI}(dayI) = sum(pctDayDistNOTSTsplitters{mouseI}(dayI,[1 end]));
        
        %Could look across dimension: LR DIs of ST splitters
        %{
        mouseI = 0;
        mouseI = mouseI + 1
        pctEdgeLR{mouseI}
        pctEdgeLRsplitters{mouseI}
        pctEdgeNOTLRsplitters{mouseI}

        mouseI = 0;
        mouseI = mouseI + 1
        pctEdgeST{mouseI}
        pctEdgeSTsplitters{mouseI}
        pctEdgeNOTSTsplitters{mouseI}
        %}
    end
    %}  
    %{
    for binI = 1:length(binEdges)-1
        ddLR = dayDistLR{mouseI}(:,binI);
        dayDistMeansLR(mouseI,binI) = mean(ddLR(ddLR~=0));
        dayDistSEMsLR(mouseI,binI) = standarderrorSL(ddLR(ddLR~=0));
        ddST = dayDistST{mouseI}(:,binI);
        dayDistMeansST(mouseI,binI) = mean(ddST(ddST~=0));
        dayDistSEMsST(mouseI,binI) = standarderrorSL(ddST(ddST~=0));
        
        ddLRs = dayDistLRsplitters{mouseI}(:,binI);
        dayDistMeansLRsplitters(mouseI,binI) = mean(ddLRs(ddLRs~=0));
        dayDistSEMsLRsplitters(mouseI,binI) = standarderrorSL(ddLRs(ddLRs~=0));
        ddSTs = dayDistSTsplitters{mouseI}(:,binI);
        dayDistMeansSTsplitters(mouseI,binI) = mean(ddSTs(ddSTs~=0));
        dayDistSEMsSTsplitters(mouseI,binI) = standarderrorSL(ddSTs(ddSTs~=0));
        
        ddLRboth = dayDistLRboth{mouseI}(:,binI);
        dayDistMeansLRboth(mouseI,binI) = mean(ddLRboth(ddLRboth~=0));
        dayDistSEMsLRboth(mouseI,binI) = standarderrorSL(ddLRboth(ddLRboth~=0));
        ddSTboth = dayDistSTboth{mouseI}(:,binI);
        dayDistMeansSTboth(mouseI,binI) = mean(ddSTboth(ddSTboth~=0));
        dayDistSEMsSTboth(mouseI,binI) = standarderrorSL(ddSTboth(ddSTboth~=0));
        
        ppLR = pctDayDistLR{mouseI}(:,binI);
        pctsDistMeanLR(mouseI,binI) = mean(ppLR(ppLR~=0));
        pctsDistSEMsLR(mouseI,binI) = standarderrorSL(ppLR(ppLR~=0));
        ppST = pctDayDistST{mouseI}(:,binI);
        pctsDistMeanST(mouseI,binI) = mean(ppST(ppST~=0));
        pctsDistSEMsST(mouseI,binI) = standarderrorSL(ppST(ppST~=0));
    end
    %}
%end
%{

%Trait logical prop change Place by splitter
% Coming or going?
for mouseI = 1:numMice
     numPctPXSLR{mouseI}(1,:) = sum(placeSplitLR{mouseI},1);
    numPctPXSLR{mouseI}(2,:) = numPctPXSLR{mouseI}(1,:)./cellsActiveToday{mouseI};
    rangePctPXSLR(mouseI,1:2) = [mean(numPctPXSLR{mouseI}(2,:)) standarderrorSL(numPctPXSLR{mouseI}(2,:))];
    
    numPctPXSST{mouseI}(1,:) = sum(placeSplitST{mouseI},1);
    numPctPXSST{mouseI}(2,:) = numPctPXSST{mouseI}(1,:)./cellsActiveToday{mouseI};
    rangePctPXSST(mouseI,1:2) = [mean(numPctPXSST{mouseI}(2,:)) standarderrorSL(numPctPXSST{mouseI}(2,:))];
    
    numPctPXSBOTH{mouseI}(1,:) = sum(placeSplitBOTH{mouseI},1);
    numPctPXSBOTH{mouseI}(2,:) = numPctPXSBOTH{mouseI}(1,:)./cellsActiveToday{mouseI};
    rangePctPXSBOTH(mouseI,1:2) = [mean(numPctPXSBOTH{mouseI}(2,:)) standarderrorSL(numPctPXSBOTH{mouseI}(2,:))];
    
    numPctPXSLRonly{mouseI}(1,:) = sum(placeSplitLRonly{mouseI},1);
    numPctPXSLRonly{mouseI}(2,:) = numPctPXSLRonly{mouseI}(1,:)./cellsActiveToday{mouseI};
    rangePctPXSLRonly(mouseI,1:2) = [mean(numPctPXSLRonly{mouseI}(2,:)) standarderrorSL(numPctPXSLRonly{mouseI}(2,:))];
    
    numPctPXSSTonly{mouseI}(1,:) = sum(placeSplitSTonly{mouseI},1);
    numPctPXSSTonly{mouseI}(2,:) = numPctPXSSTonly{mouseI}(1,:)./cellsActiveToday{mouseI};
    rangePctPXSSTonly(mouseI,1:2) = [mean(numPctPXSSTonly{mouseI}(2,:)) standarderrorSL(numPctPXSSTonly{mouseI}(2,:))];
    
    numPctPXSNone{mouseI}(1,:) = sum(placeSplitNone{mouseI},1);
    numPctPXSNone{mouseI}(2,:) = numPctPXSNone{mouseI}(1,:)./cellsActiveToday{mouseI};
    rangePctPXSNone(mouseI,1:2) = [mean(numPctPXSNone{mouseI}(2,:)) standarderrorSL(numPctPXSNone{mouseI}(2,:))];
    
    [pxsLRCOM{mouseI}, pxsDayBiasLR{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, placeSplitLR{mouseI});
    [pxsSTCOM{mouseI}, pxsDayBiasST{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, placeSplitST{mouseI});
    [pxsBOTHCOM{mouseI}, pxsDayBiasBOTH{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, placeSplitBOTH{mouseI});
    [pxsLRonlyCOM{mouseI}, pxsDayBiasLRonly{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, placeSplitLRonly{mouseI});
    [pxsSTonlyCOM{mouseI}, pxsDayBiasSTonly{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, placeSplitSTonly{mouseI});
    [pxsNoneCOM{mouseI}, pxsDayBiasNone{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, placeSplitNone{mouseI});
    disp(['done place by splitter mouse ' num2str(mouseI)])
end
for mouseI = 1:numMice
    [PSnumChange{mouseI}, PSpctChange{mouseI}, dayPairs{mouseI}] = NNplusKChange(placeAndSplitter{mouseI}, dayUse{mouseI});
    [PSxnumChange{mouseI}, PSxpctChange{mouseI}, dayPairs{mouseI}] = NNplusKChange(placeNotSplitter{mouseI}, dayUse{mouseI});
    [PxSnumChange{mouseI}, PxSpctChange{mouseI}, dayPairs{mouseI}] = NNplusKChange(splitterNotPlace{mouseI}, dayUse{mouseI});
    
    %Sort by days apart
    dayDiffs{mouseI} = diff(dayPairs{mouseI},1,2);
    possibleDiffs = unique(dayDiffs{mouseI});
    for pdI = 1:length(possibleDiffs)
        PSnumChangeReorg{mouseI}{pdI} = PSnumChange{mouseI}(dayDiffs{mouseI}==possibleDiffs(pdI));
        PSpctChangeReorg{mouseI}{pdI} = PSpctChange{mouseI}(dayDiffs{mouseI}==possibleDiffs(pdI));
        PSxnumChangeReorg{mouseI}{pdI} = PSxnumChange{mouseI}(dayDiffs{mouseI}==possibleDiffs(pdI));
        PSxpctChangeReorg{mouseI}{pdI} = PSxpctChange{mouseI}(dayDiffs{mouseI}==possibleDiffs(pdI)); 
        PxSnumChangeReorg{mouseI}{pdI} = PxSnumChange{mouseI}(dayDiffs{mouseI}==possibleDiffs(pdI));
        PxSpctChangeReorg{mouseI}{pdI} = PxSpctChange{mouseI}(dayDiffs{mouseI}==possibleDiffs(pdI));
    end
    meanPSpctChange{mouseI} = cell2mat(cellfun(@mean,PSpctChangeReorg{mouseI},'UniformOutput',false));
    meanPSxpctChange{mouseI} = cell2mat(cellfun(@mean,PSxpctChangeReorg{mouseI},'UniformOutput',false));
    meanPxSpctChange{mouseI} = cell2mat(cellfun(@mean,PxSpctChangeReorg{mouseI},'UniformOutput',false));
end
%}

%{
    numDailySplittersANY{mouseI} = sum(splittersANY{mouseI},1);
    daysSplitANY{mouseI} = sum(splittersANY{mouseI},2);
    rangeDailySplittersANY(mouseI,:) = [mean(numDailySplittersANY{mouseI}) standarderrorSL(numDailySplittersANY{mouseI})];
    pctDailySplittersANY{mouseI} = numDailySplittersANY{mouseI}./cellsActiveToday{mouseI};
    rangePctDailySplittersANY(mouseI,:) = [mean(pctDailySplittersANY{mouseI}) standarderrorSL(pctDailySplittersANY{mouseI})];%Pct
    splitAllDaysANY{mouseI} = splitterDayBiasANY{mouseI}/sum(sum(dayUse{mouseI},2) > 1); %ever splitLR/cells active at least 2 days
    
    numDailySplittersLR{mouseI} = sum(splittersLR{mouseI},1);
    daysSplitLR{mouseI} = sum(splittersLR{mouseI},2);
    rangeDailySplittersLR(mouseI,:) = [mean(numDailySplittersLR{mouseI}) standarderrorSL(numDailySplittersLR{mouseI})];
    pctDailySplittersLR{mouseI} = numDailySplittersLR{mouseI}./cellsActiveToday{mouseI};
    rangePctDailySplittersLR(mouseI,:) = [mean(pctDailySplittersLR{mouseI}) standarderrorSL(pctDailySplittersLR{mouseI})];%Pct
    splitAllDaysLR{mouseI} = splitterDayBiasLR{mouseI}/sum(sum(dayUse{mouseI},2) > 1); %ever splitLR/cells active at least 2 days
    
    numDailySplittersST{mouseI} = sum(splittersST{mouseI},1);
    daysSplitST{mouseI} = sum(splittersST{mouseI},2);
    rangeDailySplittersST(mouseI,:) = [mean(numDailySplittersST{mouseI}) standarderrorSL(numDailySplittersST{mouseI})];
    pctDailySplittersST{mouseI} = numDailySplittersST{mouseI}./cellsActiveToday{mouseI};
    rangePctDailySplittersST(mouseI,:) = [mean(pctDailySplittersST{mouseI}) standarderrorSL(pctDailySplittersST{mouseI})];%Pct
    splitAllDaysST{mouseI} = splitterDayBiasST{mouseI}/sum(sum(dayUse{mouseI},2) > 1); %ever splitST/cells active at least 2 days
    
    numDailySplittersBOTH{mouseI} = sum(splittersBOTH{mouseI},1);
    daysSplitBOTH{mouseI} = sum(splittersBOTH{mouseI},2);
    rangeDailySplittersBOTH(mouseI,:) = [mean(numDailySplittersBOTH{mouseI}) standarderrorSL(numDailySplittersBOTH{mouseI})];
    pctDailySplittersBOTH{mouseI} = numDailySplittersBOTH{mouseI}./cellsActiveToday{mouseI};
    rangePctDailySplittersBOTH(mouseI,:) = [mean(pctDailySplittersBOTH{mouseI}) standarderrorSL(pctDailySplittersBOTH{mouseI})];%Pct
    splitAllDaysBOTH{mouseI} = splitterDayBiasBOTH{mouseI}/sum(sum(dayUse{mouseI},2) > 1); %ever splitBOTH/cells active at least 2 days
    
    numDailySplittersLRonly{mouseI} = sum(splittersLRonly{mouseI},1);
    daysSplitLRonly{mouseI} = sum(splittersLRonly{mouseI},2);
    rangeDailySplittersLRonly(mouseI,:) = [mean(numDailySplittersLRonly{mouseI}) standarderrorSL(numDailySplittersLRonly{mouseI})];
    pctDailySplittersLRonly{mouseI} = numDailySplittersLRonly{mouseI}./cellsActiveToday{mouseI};
    rangePctDailySplittersLRonly(mouseI,:) = [mean(pctDailySplittersLRonly{mouseI}) standarderrorSL(pctDailySplittersLRonly{mouseI})];%Pct
    splitAllDaysLRonly{mouseI} = splitterDayBiasLRonly{mouseI}/sum(sum(dayUse{mouseI},2) > 1); %ever splitBOTH/cells active at least 2 days

    numDailySplittersSTonly{mouseI} = sum(splittersSTonly{mouseI},1);
    daysSplitSTonly{mouseI} = sum(splittersSTonly{mouseI},2);
    rangeDailySplittersSTonly(mouseI,:) = [mean(numDailySplittersSTonly{mouseI}) standarderrorSL(numDailySplittersSTonly{mouseI})];%Raw number
    pctDailySplittersSTonly{mouseI} = numDailySplittersSTonly{mouseI}./cellsActiveToday{mouseI};
    rangePctDailySplittersSTonly(mouseI,:) = [mean(pctDailySplittersSTonly{mouseI}) standarderrorSL(pctDailySplittersSTonly{mouseI})]; %Pct
    splitAllDaysSTonly{mouseI} = splitterDayBiasSTonly{mouseI}/sum(sum(dayUse{mouseI},2) > 1); %ever splitBOTH/cells active at least 2 days
    
    numDailySplittersEXany{mouseI} = sum(splittersEXany{mouseI},1);
    daysSplitEXany{mouseI} = sum(splittersEXany{mouseI},2);
    rangeDailySplittersEXany(mouseI,:) = [mean(numDailySplittersEXany{mouseI}) standarderrorSL(numDailySplittersEXany{mouseI})];%Raw number
    pctDailySplittersEXany{mouseI} = numDailySplittersEXany{mouseI}./cellsActiveToday{mouseI};
    rangePctDailySplittersEXany(mouseI,:) = [mean(pctDailySplittersEXany{mouseI}) standarderrorSL(pctDailySplittersEXany{mouseI})]; %Pct
    splitAllDaysEXany{mouseI} = splitterDayBiasEXany{mouseI}/sum(sum(dayUse{mouseI},2) > 1); 

    numDailySplittersNone{mouseI} = sum(splittersNone{mouseI},1);
    daysSplitNone{mouseI} = sum(splittersNone{mouseI},2);
    rangeDailySplittersNone(mouseI,:) = [mean(numDailySplittersNone{mouseI}) standarderrorSL(numDailySplittersNone{mouseI})];%Raw number
    pctDailySplittersNone{mouseI} = numDailySplittersNone{mouseI}./cellsActiveToday{mouseI};
    rangePctDailySplittersNone(mouseI,:) = [mean(pctDailySplittersNone{mouseI}) standarderrorSL(pctDailySplittersNone{mouseI})]; 
    splitAllDaysNone{mouseI} = splitterDayBiasNone{mouseI}/sum(sum(dayUse{mouseI},2) > 1); 
    %}
