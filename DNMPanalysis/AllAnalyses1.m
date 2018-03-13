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
    condPairsLR = [1 2; 3 4];
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
end

% Study/Test
for mouseI = 1:numMice
    condPairsST = [1 3; 2 4];
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
end

%Get logical splitting type
for mouseI = 1:numMice
    splittersLR{mouseI} = (LRthisCellSplits{mouseI} + dayUse{mouseI}) ==2;
    splittersST{mouseI} = (STthisCellSplits{mouseI} + dayUse{mouseI}) ==2;
    splittersANY{mouseI} = (splittersLR{mouseI} + splittersST{mouseI}) > 0;
    [splittersLRonly{mouseI}, splittersSTonly{mouseI}, splittersBOTH{mouseI},...
        splittersOne{mouseI}, splittersNone{mouseI}] = ...
        GetSplittingTypes(splittersLR{mouseI}, splittersST{mouseI}, dayUse{mouseI});
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
        
        %Last one: could look across dimension: LR DIs of ST splitters
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
binEdges = [-1.1 -0.9:0.1:0.9 1.1];
for mouseI = 1:numMice
    DImeansLR = DImeanLR{mouseI}; DImeansLR(dayUse{mouseI}==0) = NaN;
    DImeansST = DImeanST{mouseI}; DImeansST(dayUse{mouseI}==0) = NaN;
    DImeansLRsplitters = DImeansLR; DImeansLRsplitters(LRsplitters{mouseI}==0) = NaN; %LR only?
    DImeansSTsplitters = DImeansST; DImeansSTsplitters(STsplitters{mouseI}==0) = NaN; %ST only?
    
    dayDistLR{mouseI} = histcounts(DImeansLR(:,dayI),binEdges);
    
    pctDayDistLRsplitters{mouseI}(dayI,:) = histcounts(DImeansSTsplitters(:,dayI),binEdges, 'Normalization','probability');
    
    
    
end
    
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
    placeByCond{mouseI} = binsAbove95;
    %numAbove95
    belowHalf{mouseI} = lessThanHalf;
    anyPlace{mouseI} = placeAtAll;
    placeThisDay{mouseI} = placeToday;
end


%Splitter-type evaluation of how many are place cells, do the become/lose placeness
%How many conds to they tend to be place-y out of conds active?

%% Place/Splitter cell over lap




%% Population Vector Correlations



%% Decoder analysis