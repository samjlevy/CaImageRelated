%% Process all data

mainFolder = 'C:\Users\Sam\Desktop\DNMPfinalData';
mice = {'Bellatrix', 'Polaris', 'Calisto'}; %'Europa'
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
    saveName = fullfile(mainFolder,mice{mouseI},'PFsLin.mat');
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
        
        dailyCondsActiveHist{mouseI,dayI} = histcounts(dailyNumCondsActiveCells{mouseI,dayI},0.5:1:4.5);
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
    disp(['done single cells mouse ' num2str(mouseI)])
end

for mouseI = 1:numMice
    [trialReli{mouseI},~,~,~] = TrialReliability(cellTBT{mouseI}, lapPctThresh);
    [maxConsec{mouseI}, ~] = ConsecutiveLaps(cellTBT{mouseI}, consecLapThresh);
    
    %Histograms to look at trial reliability and number of maxConsecutive
    %laps
end

%% Splitter cells: Shuffle versions

numShuffles = 1000;
shuffThresh = 1 - pThresh;
binsMin = 1;
shuffleDirLR = 'shuffleLR';
shuffleDirST = 'shuffleST';

for mouseI = 1:numMice
    load(fullfile(mainFolder,mice{mouseI},'PFsLin.mat'),'TMap_unsmoothed')
    cellTMap_unsmoothed{mouseI} = TMap_unsmoothed;
end

% Left/Right
for mouseI = 1:numMice
    %condPairsLR = [1 2; 3 4];
    condPairsLR = [Conds.Study; Conds.Test];
    shuffDirFullLR = fullfile(mainFolder,mice{mouseI},shuffleDirLR);
    [rateDiffLR{mouseI}, rateSplitLR{mouseI}, meanRateDiffLR{mouseI}, DIeachLR{mouseI}, DImeanLR{mouseI}, DIallLR{mouseI}] =...
        LookAtSplitters4(cellTMap_unsmoothed{mouseI}, condPairsLR, trialReli{mouseI});
    splitterFileLR = fullfile(shuffDirFullLR,'splittersLR.mat');
    if exist(splitterFileLR,'file')==2
        load(splitterFileLR)
    else
        disp(['did not find LR splitting for ' num2str(mouseI) ', making now'])
        [binsAboveShuffleLR, thisCellSplitsLR] = SplitterWrapper2(cellTBT{mouseI}, cellTMap_unsmoothed{mouseI},...
            'leftright', numShuffles, shuffDirFullLR, xlims, cmperbin, minspeed, trialReli{mouseI}, shuffThresh, binsMin);
        save(splitterFileLR,'binsAboveShuffleLR','thisCellSplitsLR')
    end
    LRbinsAboveShuffle{mouseI} = binsAboveShuffleLR; 
    LRthisCellSplits{mouseI} = thisCellSplitsLR;
    disp(['done Left/Right splitters mouse ' num2str(mouseI)])
end

% Study/Test
for mouseI = 1:numMice
    %condPairsST = [1 3; 2 4];
    condPairsST = [Conds.Left; Conds.Right];
    shuffDirFullST = fullfile(mainFolder,mice{mouseI},shuffleDirST);
    [rateDiffST{mouseI}, rateSplitST{mouseI}, meanRateDiffST{mouseI}, DIeachST{mouseI}, DImeanST{mouseI}, DIallST{mouseI}] =...
        LookAtSplitters4(cellTMap_unsmoothed{mouseI}, condPairsST, trialReli{mouseI});
    splitterFileST = fullfile(shuffDirFullST,'splittersST.mat');
    if exist(splitterFileST,'file')==2
        load(splitterFileST)
    else
        disp(['did not find ST splitting for ' num2str(mouseI) ', making now'])
        [binsAboveShuffleST, thisCellSplitsST] = SplitterWrapper2(cellTBT{mouseI}, cellTMap_unsmoothed{mouseI},...
            'studytest', numShuffles, shuffDirFullST, xlims, cmperbin, minspeed, trialReli{mouseI}, shuffThresh, binsMin);
        save(splitterFileST,'binsAboveShuffleST','thisCellSplitsST')
    end
    STbinsAboveShuffle{mouseI} = binsAboveShuffleST; 
    STthisCellSplits{mouseI} = thisCellSplitsST;
    disp(['done Study/Test splitters mouse ' num2str(mouseI)])
end

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
    %Should work out that LRonly + STonly + Both + none = total active
        %And LR only + STonly = one
    cellsActiveToday{mouseI} = sum(dayUse{mouseI},1);
    splitterProps{mouseI} = [sum(splittersNone{mouseI},1)./cellsActiveToday{mouseI};... %None
                             sum(splittersLRonly{mouseI},1)./cellsActiveToday{mouseI};... %LR only
                             sum(splittersSTonly{mouseI},1)./cellsActiveToday{mouseI};... %ST only
                             sum(splittersBOTH{mouseI},1)./cellsActiveToday{mouseI}]; %Both only
end

%Evaluate splitting: days bias numbers and center of mass per cell
for mouseI = 1:numMice
    %BIAS: early bias, no bias didn't split all days, late bias, split all days
    [splitterCOMLR{mouseI}, splitterDayBiasLR{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, splittersLR{mouseI});
    [splitterCOMST{mouseI}, splitterDayBiasST{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, splittersST{mouseI});
    [splitterCOMBOTH{mouseI}, splitterDayBiasBOTH{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, splittersBOTH{mouseI});
    [splitterCOMLRonly{mouseI}, splitterDayBiasLRonly{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, splittersLRonly{mouseI});
    [splitterCOMSTonly{mouseI}, splitterDayBiasSTonly{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, splittersSTonly{mouseI});
    [splitterCOMANY{mouseI}, splitterDayBiasANY{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, splittersANY{mouseI});
end

%Daily splitter ranges
for mouseI = 1:numMice
    everSplitANY{mouseI} = sum(sum(splittersANY{mouseI},2) > 0);
    
    %Should generalize this (splittersLogical, splitterDayBias, dayUse, cellsActiveToday (sum(dayUse,1))
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
end

% DI distributions
binEdges = [-1.1 -0.9:0.1:0.9 1.1];
for mouseI = 1:numMice
    DImeansLR = DImeanLR{mouseI}; DImeansLR(dayUse{mouseI}==0) = NaN;
    DImeansST = DImeanST{mouseI}; DImeansST(dayUse{mouseI}==0) = NaN;
    DImeansLRsplitters = DImeansLR; DImeansLRsplitters(LRthisCellSplits{mouseI}==0) = NaN; %LR only?
    DImeansSTsplitters = DImeansST; DImeansSTsplitters(STthisCellSplits{mouseI}==0) = NaN; %ST only?
    DImeansLRboth = DImeanLR{mouseI}; DImeansLRboth(splittersBOTH{mouseI}==0) = NaN; %DIs of both Splitters
    DImeansSTboth = DImeanST{mouseI}; DImeansSTboth(splittersBOTH{mouseI}==0) = NaN;
    %DImeansNOTLRsplitters = DImeansLR; DImeansNOTLRsplitters(LRthisCellSplits{mouseI}==1) = NaN; %LR only?
    %DImeansNOTSTsplitters = DImeansST; DImeansNOTSTsplitters(STthisCellSplits{mouseI}==1) = NaN; %ST only?
    DImeansNOTLRsplitters = DImeansLR; DImeansNOTLRsplitters(nonLRsplitters{mouseI}==0) = NaN; %LR only? Should be same as above?
    DImeansNOTSTsplitters = DImeansST; DImeansNOTSTsplitters(nonSTsplitters{mouseI}==0) = NaN; %ST only? Should be same as above?
    
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
    end
end



%Possible better rebuild, probably not necessary
%{
binEdges = [-1.1 -0.9:0.1:0.9 1.1];
for mouseI = 1:numMice
    DImeansLR = DImeanLR{mouseI}; DImeansLR(dayUse{mouseI}==0) = NaN;
    DImeansST = DImeanST{mouseI}; DImeansST(dayUse{mouseI}==0) = NaN;
    DImeansLRsplitters = DImeansLR; DImeansLRsplitters(LRsplitters{mouseI}==0) = NaN; %LR only?
    DImeansSTsplitters = DImeansST; DImeansSTsplitters(STsplitters{mouseI}==0) = NaN; %ST only?
    
    dayDistLR{mouseI} = histcounts(DImeansLR(:,dayI),binEdges);
    
    pctDayDistLRsplitters{mouseI}(dayI,:) = histcounts(DImeansSTsplitters(:,dayI),binEdges, 'Normalization','probability');
    
    
    
end
    %}
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
    placeThisDay{mouseI} = placeToday;
    notPlace{mouseI} = (placeThisDay{mouseI}==0).*dayUse{mouseI};
end

%How many place cells each conditions? How many with more than one condition?
for mouseI = 1:numMice
    cellsActiveToday{mouseI} = sum(dayUse{mouseI},1);
    placeByCondThreshed{mouseI}(:,:,1) = squeeze(placeByCond{mouseI}(:,1,:)).*squeeze(threshAndConsec{mouseI}(:,:,1));
    placeByCondThreshed{mouseI}(:,:,2) = squeeze(placeByCond{mouseI}(:,2,:)).*squeeze(threshAndConsec{mouseI}(:,:,2));
    placeByCondThreshed{mouseI}(:,:,3) = squeeze(placeByCond{mouseI}(:,3,:)).*squeeze(threshAndConsec{mouseI}(:,:,3));
    placeByCondThreshed{mouseI}(:,:,4) = squeeze(placeByCond{mouseI}(:,4,:)).*squeeze(threshAndConsec{mouseI}(:,:,4));
    %placeNums{mouseI} = [sum(squeeze(placeByCond{mouseI}(:,1,:)).*dayUse{mouseI});... %Study L
    %                     sum(squeeze(placeByCond{mouseI}(:,2,:)).*dayUse{mouseI});... %Study R
    %                     sum(squeeze(placeByCond{mouseI}(:,3,:)).*dayUse{mouseI});... %Test L
    %                     sum(squeeze(placeByCond{mouseI}(:,4,:)).*dayUse{mouseI})];   %Test R
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
    pctRangeCondsWherePlace(mouseI,1:2) = [mean(dailyPropCondsWherePlace{mouseI}(1,:)) standarderrorSL(dailyPropCondsWherePlace{mouseI}(1,:))];
end


%Placecells coming or going?
for mouseI = 1:numMice
    [placeCOM{mouseI}, placeDayBias{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, placeThisDay{mouseI}); 
    [placeCOMSL{mouseI}, placeDayBiasSL{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, squeeze(placeByCond{mouseI}(:,1,:)));
    [placeCOMSR{mouseI}, placeDayBiasSR{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, squeeze(placeByCond{mouseI}(:,2,:)));
    [placeCOMTL{mouseI}, placeDayBiasTL{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, squeeze(placeByCond{mouseI}(:,3,:)));
    [placeCOMTR{mouseI}, placeDayBiasTR{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, squeeze(placeByCond{mouseI}(:,4,:)));
end

    
%% Place/Splitter cell over lap

% Get logical is it placeXsplitter
for mouseI = 1:numMice
    placeSplitLR{mouseI} = logical(splittersLR{mouseI}.*(placeThisDay{mouseI}.*dayUse{mouseI}));
    placeSplitST{mouseI} = logical(splittersST{mouseI}.*(placeThisDay{mouseI}.*dayUse{mouseI}));
    placeSplitBOTH{mouseI} = logical(splittersBOTH{mouseI}.*(placeThisDay{mouseI}.*dayUse{mouseI}));
    placeSplitLRonly{mouseI} = logical(splittersLRonly{mouseI}.*(placeThisDay{mouseI}.*dayUse{mouseI}));
    placeSplitSTonly{mouseI} = logical(splittersSTonly{mouseI}.*(placeThisDay{mouseI}.*dayUse{mouseI}));
    placeSplitNone{mouseI} = logical(splittersNone{mouseI}.*(placeThisDay{mouseI}.*dayUse{mouseI})); %placeByCondThreshed{mouseI}(:,:,1) | placeByCondThreshed{mouseI}(:,:,3)));%???
end

% How many, Range etc.
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
end
% Coming or going?
for mouseI = 1:numMice
    [pxsLRCOM{mouseI}, pxsDayBiasLR{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, placeSplitLR{mouseI});
    [pxsSTCOM{mouseI}, pxsDayBiasST{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, placeSplitST{mouseI});
    [pxsBOTHCOM{mouseI}, pxsDayBiasBOTH{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, placeSplitBOTH{mouseI});
    [pxsLRonlyCOM{mouseI}, pxsDayBiasLRonly{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, placeSplitLRonly{mouseI});
    [pxsSTonlyCOM{mouseI}, pxsDayBiasSTonly{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, placeSplitSTonly{mouseI});
    [pxsNoneCOM{mouseI}, pxsDayBiasNone{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, placeSplitNone{mouseI});
    disp(['done place by splitter mouse ' num2str(mouseI)])
end
    
%% Cell identity round-up

%Splitter, not place

%Place, not splitter

%Splitter and place

%Not splitter, not place

%Reactivation probability by type: if split/place/not on day n, how likely
%shows up again on day n+1
%Splitters
for mouseI = 1:numMice
    reactivatesLR{mouseI} = TraitReactivation(dayUse{mouseI},splittersLR{mouseI});
    reactivatesST{mouseI} = TraitReactivation(dayUse{mouseI},splittersST{mouseI});
    reactivatesLRonly{mouseI} = TraitReactivation(dayUse{mouseI},splittersLRonly{mouseI});
    reactivatesSTonly{mouseI} = TraitReactivation(dayUse{mouseI},splittersSTonly{mouseI});
    reactivatesBOTH{mouseI} = TraitReactivation(dayUse{mouseI},splittersBOTH{mouseI});
    reactivatesANY{mouseI} = TraitReactivation(dayUse{mouseI},splittersANY{mouseI});
    reactivatesNotSplitter{mouseI} = TraitReactivation(dayUse{mouseI},splittersNone{mouseI});
end
%Place
for mouseI = 1:numMice
    reactivatesPlaceAny{mouseI} = TraitReactivation(dayUse{mouseI},placeThisDay{mouseI});
    reactivatesPlaceSL{mouseI} = TraitReactivation(dayUse{mouseI},squeeze(placeByCond{mouseI}(:,1,:)));
    reactivatesPlaceSR{mouseI} = TraitReactivation(dayUse{mouseI},squeeze(placeByCond{mouseI}(:,2,:)));
    reactivatesPlaceTL{mouseI} = TraitReactivation(dayUse{mouseI},squeeze(placeByCond{mouseI}(:,3,:)));
    reactivatesPlaceTR{mouseI} = TraitReactivation(dayUse{mouseI},squeeze(placeByCond{mouseI}(:,4,:)));
    reactivatesNotPlace{mouseI} = TraitReactivation(dayUse{mouseI},notPlace{mouseI});
end
%Place x split
for mouseI = 1:numMice
    reactivatespxsLR{mouseI} = TraitReactivation(dayUse{mouseI},placeSplitLR{mouseI});
    reactivatespxsST{mouseI} = TraitReactivation(dayUse{mouseI},placeSplitST{mouseI});
    reactivatespxsLRonly{mouseI} = TraitReactivation(dayUse{mouseI},placeSplitLRonly{mouseI});
    reactivatespxsSTonly{mouseI} = TraitReactivation(dayUse{mouseI},placeSplitSTonly{mouseI});
    reactivatespxsBoth{mouseI} = TraitReactivation(dayUse{mouseI},placeSplitBOTH{mouseI});
    reactivatespxsNone{mouseI} = TraitReactivation(dayUse{mouseI},placeSplitNone{mouseI});
    reactivatesSplitterNotPlace{mouseI} = TraitReactivation(dayUse{mouseI},logical(splittersANY{mouseI}.*notPlace{mouseI}));
    reactivatesPlaceNotSplitter{mouseI} = TraitReactivation(dayUse{mouseI},logical(splittersNone{mouseI}.*placeThisDay{mouseI}));
    disp(['done reactivation by type mouse ' num2str(mouseI)])
end
%% Lap following L/R


%% Population Vector Correlations



%% Decoder analysis
%numShuffles = 100;
numShuffles = 20;
activityType = [];

%Splitters

%All Cells
for mouseI = 1:numMice
    decodeAll = fullfile(mainFolder,mice{mouseI},'\decoding','decoderAllsplit.mat');
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
end


%Left/Right splitters (decoding only in cell cols 1 & 2)
for mouseI = 1:numMice
    decodeLR = fullfile(mainFolder,mice{mouseI},'\decoding','decoderLRsplit.mat');
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
    decodeST = fullfile(mainFolder,mice{mouseI},'\decoding','decoderSTsplit.mat');
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

nonLRsplitters{mouseI}
splittersNone
%Place vs. non-place
placeThisDay{mouseI}
notPlace{mouseI}
%Randomly chosen from active (match number to place/splitters)

%% RSA maybe