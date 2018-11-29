%% Overlap in both
pctTraitBothPooled = cell(numTraitGroups,1);
for mouseI = 1:numMice
    activeARMandSTEM{mouseI} = dayUse{mouseI} + dayUseArm{mouseI}==2;
    pctActiveBoth{mouseI} = sum(activeARMandSTEM{mouseI},1) / size(dayUse{mouseI},1);
    
    for tgI = 1:length(traitGroups{1})
        traitARMandSTEM{mouseI}{tgI} = traitGroups{mouseI}{tgI} + ARMtraitGroups{mouseI}{tgI}==2;
        pctTraitBoth{mouseI}{tgI} = sum(traitARMandSTEM{mouseI}{tgI},1) / size(dayUse{mouseI},1);
        pctTraitBothPooled{tgI} = [pctTraitBothPooled{tgI}; pctTraitBoth{mouseI}{tgI}(:)];
    end
end

%% ARM Splitter cells: stats and logical breakdown
%Get logical splitting type
for mouseI = 1:numMice
    ARMsplittersLR{mouseI} = (LRthisCellSplitsARM{mouseI} + dayUseArm{mouseI}) ==2;
    ARMsplittersST{mouseI} = (STthisCellSplitsARM{mouseI} + dayUseArm{mouseI}) ==2;
    ARMsplittersANY{mouseI} = (ARMsplittersLR{mouseI} + ARMsplittersST{mouseI}) > 0;
    [ARMsplittersLRonly{mouseI}, ARMsplittersSTonly{mouseI}, ARMsplittersBOTH{mouseI},...
        ARMsplittersOne{mouseI}, ARMsplittersNone{mouseI}] = ...
        GetSplittingTypes(ARMsplittersLR{mouseI}, ARMsplittersST{mouseI}, dayUseArm{mouseI});
    %ARMsplittersOne{mouseI} = ARMsplittersOne{mouseI}.*dayUse{mouseI};
    ARMnonLRsplitters{mouseI} = ((LRthisCellSplitsARM{mouseI} == 0) + dayUseArm{mouseI}) ==2;
    ARMnonSTsplitters{mouseI} = ((STthisCellSplitsARM{mouseI} == 0) + dayUseArm{mouseI}) ==2;
    
    %Sanity check: Should work out that LRonly + STonly + Both + none = total active
        %And LR only + STonly = one
    cellsActiveTodayArm{mouseI} = sum(dayUseArm{mouseI},1);
    ARMsplitterProps{mouseI} = [sum(ARMsplittersNone{mouseI},1)./cellsActiveTodayArm{mouseI};... %None
                             sum(ARMsplittersLRonly{mouseI},1)./cellsActiveTodayArm{mouseI};... %LR only
                             sum(ARMsplittersSTonly{mouseI},1)./cellsActiveTodayArm{mouseI};... %ST only
                             sum(ARMsplittersBOTH{mouseI},1)./cellsActiveTodayArm{mouseI}]; %Both only
                         
    ARMsplittersEXany{mouseI} = (ARMsplittersLRonly{mouseI} + ARMsplittersSTonly{mouseI}) > 0;
end

purp = [0.4902    0.1804    0.5608]; % uisetcolor
orng = [0.8510    0.3294    0.1020];
colorAssc = {'r'            'b'        'm'         'c'              purp     orng    'g'      'k'  };
colorAssc = { [1 0 0]     [0 0 1]    [1 0 1]       [0 1 1]         purp     orng        [0 1 0]       [0 0 0]};
traitLabels = {'splitLR' 'splitST'  'splitLRonly' 'splitSTonly' 'splitBOTH' 'splitONE' 'splitEITHER' 'dontSplit'};
ARMtraitLabels = {'ARMsplitLR' 'ARMsplitST'  'ARMsplitLRonly' 'ARMsplitSTonly' 'ARMsplitBOTH' 'ARMsplitONE' 'ARMsplitEITHER' 'ARMdontSplit'};

for mouseI = 1:numMice
    ARMtraitGroups{mouseI} = {ARMsplittersLR{mouseI}; ARMsplittersST{mouseI};... 
                           ARMsplittersLRonly{mouseI}; ARMsplittersSTonly{mouseI}; ...
                           ARMsplittersBOTH{mouseI}; ...
                           ARMsplittersOne{mouseI};... 
                           ARMsplittersANY{mouseI}; ...
                           ARMsplittersNone{mouseI}};
                   
    ARMtraitGroupsREV{mouseI} = cellfun(@fliplr,ARMtraitGroups{mouseI},'UniformOutput',false);
    
end
dayUseArmREV = cellfun(@fliplr,dayUseArm,'UniformOutput',false);

%sessionsIndREV = cellfun(@(x) fliplr(1:length(x)),cellRealDays,'UniformOutput',false);

disp('done ARM splitter logicals')
%{
pairsCompare = {'splitLR' 'splitST';...
                'splitLRonly' 'splitSTonly';...
                'splitBOTH' 'splitONE';...
                'splitEITHER' 'dontSplit'};
pairsCompareInd = cell2mat(cellfun(@(x) find(strcmpi(traitLabels,x)),pairsCompare,'UniformOutput',false));
numPairsCompare = size(pairsCompare,1);
%}
%% How many each type per day? 
ARMpooledSplitProp = cell(1,length(ARMtraitGroups{1}));
for mouseI = 1:numMice
    ARMsplitPropEachDay{mouseI} = RunGroupFunction('TraitDailyPct',ARMtraitGroups{mouseI},dayUseArm{mouseI});
    withinMouseSplitPropEachDayMeans{mouseI} = cellfun(@mean,ARMsplitPropEachDay{mouseI},'UniformOutput',false);
    %withinMouseSplitPropEachDaySEMs{mouseI} = cellfun(@standarderrorSL,ARMsplitPropEachDay{mouseI},'UniformOutput',false);
    for tgI = 1:length(traitGroups{1})
        ARMpooledSplitProp{tgI} = [ARMpooledSplitProp{tgI}; ARMsplitPropEachDay{mouseI}{tgI}(:)];
    end
end

ARMsplitPropMeans = cell2mat(cellfun(@mean,ARMpooledSplitProp,'UniformOutput',false));
%ARMsplitPropSEMs = cell2mat(cellfun(@standarderrorSL,ARMpooledSplitProp,'UniformOutput',false));

% Is there a difference in the proportions each day?
ARMsplitPropDiffsPooled = cell(numPairsCompare,1);
for mouseI = 1:numMice
    for pcI = 1:numPairsCompare
        ARMsplitPropDiffs{mouseI}{pcI} = ARMsplitPropEachDay{mouseI}{pairsCompareInd(pcI,1)} - ARMsplitPropEachDay{mouseI}{pairsCompareInd(pcI,2)};
        ARMsplitPropDiffsPooled{pcI} = [ARMsplitPropDiffsPooled{pcI} ARMsplitPropDiffs{mouseI}{pcI}];
    end
end
    
for pcJ = 1:numPairsCompare
    [pArmSplitterPropDiffs(pcJ),hArmSplitterPropDiffs(pcJ)] = signtest(ARMsplitPropDiffsPooled{pcJ}); %h = 1 reject (different)
end
  
disp('done how many ARM splitters')

%% Get changes in number of splitters over time
%Packaging for running neatly in a big group

%ARMpooledDaysApartFWD = []; ARMpooledDaysApartREV = [];
ARMpooledSplitPctChangeFWD = cell(1,length(traitGroups{1})); ARMpooledSplitPctChangeREV = cell(1,length(traitGroups{1}));
for mouseI = 1:numMice
    [ARMsplitterPctDayChangesFWD{mouseI}] = RunGroupFunction('NNplusKChange',ARMtraitGroups{mouseI},dayUseArm{mouseI});
    [ARMsplitterPctDayChangesREV{mouseI}] = RunGroupFunction('NNplusKChange',ARMtraitGroupsREV{mouseI},dayUseArmREV{mouseI});
    
    for tgI = 1:length(traitGroups{mouseI})
        ARMsplitterPctDayChangesREV{mouseI}(tgI).dayPairs = sessionsIndREV{mouseI}(ARMsplitterPctDayChangesREV{mouseI}(tgI).dayPairs);
    end
    
    if useRealDays==1    
        if mouseI==1; disp('Using real days'); end 
        for tgI = 1:length(traitGroups{mouseI})
        ARMsplitterDayPairsFWD{mouseI}{tgI} = cellRealDays{mouseI}(ARMsplitterPctDayChangesFWD{mouseI}(tgI).dayPairs);
        ARMsplitterDayPairsREV{mouseI}{tgI} = cellRealDays{mouseI}(ARMsplitterPctDayChangesREV{mouseI}(tgI).dayPairs);
        end
    end
    
    %daysApartFWD{mouseI} = diff(splitterDayPairsFWD{mouseI}{1},1,2);
    %daysApartREV{mouseI} = diff(splitterDayPairsREV{mouseI}{1},1,2);
    
    %pooledDaysApartFWD = [pooledDaysApartFWD; daysApartFWD{mouseI}];
    %pooledDaysApartREV = [pooledDaysApartREV; daysApartREV{mouseI}];
    for tgI = 1:length(traitGroups{mouseI})
        ARMpooledSplitPctChangeFWD{tgI} = [ARMpooledSplitPctChangeFWD{tgI}; ARMsplitterPctDayChangesFWD{mouseI}(tgI).pctChange];
        ARMpooledSplitPctChangeREV{tgI} = [ARMpooledSplitPctChangeREV{tgI}; ARMsplitterPctDayChangesREV{mouseI}(tgI).pctChange];
    end
end


% Compare the slops of these lines to each other and zero
numPerms = 1000;
for tgI = 1:length(traitGroups{mouseI})
    %Here's the slope of each line
    [ARMsplitterSlope(tgI,1), ARMsplitterIntercept(tgI,1), ARMsplitterFitLine{tgI}, ARMsplitterRR{tgI}] = fitLinRegSL(ARMpooledSplitPctChangeFWD{tgI}, pooledDaysApartFWD);
    [ARMsplitterSlopeREV(tgI,1), ~, ARMsplitterFitLineREV{tgI}, ARMsplitterRR{tgI}] = fitLinRegSL(ARMpooledSplitPctChangeREV{tgI}, pooledDaysApartREV);
    ARMsplitterFitPlotDays = unique(ARMsplitterFitLine{1}(:,1));
    ARMsplitterFitPlotDaysREV = unique(ARMsplitterFitLineREV{1}(:,1));
    for sfpI = 1:length(ARMsplitterFitPlotDays)
        ARMsplitterFitPlotPct{tgI}(sfpI,1) = ARMsplitterFitLine{tgI}(find(ARMsplitterFitLine{tgI}==ARMsplitterFitPlotDays(sfpI),1,'first'),2);
        ARMsplitterFitPlotPctREV{tgI}(sfpI,1) = ARMsplitterFitLineREV{tgI}(find(ARMsplitterFitLineREV{tgI}==ARMsplitterFitPlotDaysREV(sfpI),1,'first'),2);
    end
    %sameSlope = splitterSlope == splitterSlopeREV; %Rounding error a problem here
    
    %Is that slope different from a shuffle?
    %[splitterSlopeRank(tgI,1), splitterRRrank(tgI,1)] = slopeRankWrapper2(pooledSplitPctChangeFWD{tgI}, pooledDaysApartFWD, numPerms, pThresh);
end

%Are the slopes different from each other?
for pcI = 1:size(pairsCompareInd,1)    
    disp(['pci ' num2str(pcI)])
    %[slopeDiffRank(pcI)] = multiSlopeRankWrapper(pooledSplitPctChangeFWD{pairsCompareInd(pcI,1)},...
    %                                             pooledSplitPctChangeFWD{pairsCompareInd(pcI,2)}, pooledDaysApartFWD, numPerms);
    [ARMFval(pcI),ARMdfNum(pcI),ARMdfDen(pcI),ARMpVal(pcI)] = TwoSlopeFTest(ARMpooledSplitPctChangeFWD{pairsCompareInd(pcI,1)},...
                                                ARMpooledSplitPctChangeFWD{pairsCompareInd(pcI,2)}, pooledDaysApartFWD);
    [ARMrho(pcI),ARMrsP(pcI)] = ranksum(ARMpooledSplitPctChangeFWD{pairsCompareInd(pcI,1)},ARMpooledSplitPctChangeFWD{pairsCompareInd(pcI,2)});
end

disp('Done change in number of ARM splitters')

%% Days each cell is this splitter type
%{
for mouseI = 1:numMice
    ARMdaysTrait{mouseI}=cellfun(@(x) sum(x,2),ARMtraitGroups{mouseI},'UniformOutput',false);
    ARMactiveMoreThanOnce{mouseI} = ARMdaysEachCellActive{mouseI};
    ARMactiveMoreThanOnce{mouseI}(ARMactiveMoreThanOnce{mouseI}==1) = NaN;
    ARMdaysTraitOutOfActive{mouseI} = cellfun(@(x) x./ARMactiveMoreThanOnce{mouseI},ARMdaysTrait{mouseI},'UniformOutput',false);
end
%}
% Splitters shared by days apart, normalized by reactivation
ARMsplitterComesBack = cell(numMice,1); ARMsplitterComesBackREV = cell(numMice,1); 
ARMsplitterStillSplitter = cell(numMice,1); ARMsplitterStillSplitterREV = cell(numMice,1); 
ARMcellComesBack = cell(numMice,1); ARMpooledCellComesBack = [];
ARMpooledSplitterComesBackFWD = cell(length(ARMtraitGroups{1}),1); ARMpooledSplitterStillSplitterFWD = cell(length(ARMtraitGroups{1}),1);
ARMpooledSplitterComesBackREV = cell(length(ARMtraitGroups{1}),1); ARMpooledSplitterStillSplitterREV = cell(length(ARMtraitGroups{1}),1);
for mouseI = 1:numMice
    %Splitter active at all
    [ARMsplitterComesBack{mouseI}] = RunGroupFunction('GetCellsOverlap',ARMtraitGroups{mouseI},dayUseArm{mouseI},ARMsplitterPctDayChangesFWD{mouseI}(1).dayPairs);
    [ARMsplitterComesBackREV{mouseI}] = RunGroupFunction('GetCellsOverlap',ARMtraitGroupsREV{mouseI},dayUseArmREV{mouseI},ARMsplitterPctDayChangesREV{mouseI}(1).dayPairs);
    %Splitter splitter again
    [ARMsplitterStillSplitter{mouseI}] = RunGroupFunction('GetCellsOverlap',ARMtraitGroups{mouseI},ARMtraitGroups{mouseI},ARMsplitterPctDayChangesFWD{mouseI}(1).dayPairs);
    [ARMsplitterStillSplitterREV{mouseI}] = RunGroupFunction('GetCellsOverlap',ARMtraitGroupsREV{mouseI},ARMtraitGroupsREV{mouseI},ARMsplitterPctDayChangesREV{mouseI}(1).dayPairs);
    
    for tgI = 1:length(traitGroups{1})
         ARMpooledSplitterComesBackFWD{tgI} = [ARMpooledSplitterComesBackFWD{tgI}; ARMsplitterComesBack{mouseI}(tgI).overlapWithModel];
         ARMpooledSplitterComesBackREV{tgI} = [ARMpooledSplitterComesBackREV{tgI}; ARMsplitterComesBackREV{mouseI}(tgI).overlapWithModel];
         ARMpooledSplitterStillSplitterFWD{tgI} = [ARMpooledSplitterStillSplitterFWD{tgI}; ARMsplitterStillSplitter{mouseI}(tgI).overlapWithModel];
         ARMpooledSplitterStillSplitterREV{tgI} = [ARMpooledSplitterStillSplitterREV{tgI}; ARMsplitterStillSplitterREV{mouseI}(tgI).overlapWithModel];
    end
    
    %Baseline rate for normalizing
    [~,ARMcellComesBack{mouseI},~] = GetCellsOverlap(dayUseArm{mouseI},dayUseArm{mouseI},ARMsplitterPctDayChangesFWD{mouseI}(1).dayPairs);
    ARMpooledCellComesBack = [ARMpooledCellComesBack; ARMcellComesBack{mouseI}];
end   

%cellfun(@(x) x./pooledSplitterComesBackFWD,pooledSplitterComesBackFWD,'UniformOutput',false) ????

%Rank sum each self vs. negative day pairs
for tgI = 1:length(traitGroups{1})
    [ARMpValSplitCBpvn{tgI},ARMhValCBpvn{tgI},ARMwhichWonCBpvn{tgI},ARMdayPairsCBpvn{tgI}] = ...
                    RankSumAllDaypairs(ARMpooledSplitterComesBackFWD{tgI}, ARMpooledSplitterComesBackREV{tgI},pooledDaysApartFWD);
    [ARMpValSplitSSpvn{tgI},ARMhValSSpvn{tgI},ARMwhichWonSSpvn{tgI},ARMdayPairsSSpvn{tgI}] = ...
                    RankSumAllDaypairs(ARMpooledSplitterStillSplitterFWD{tgI}, ARMpooledSplitterStillSplitterREV{tgI},pooledDaysApartFWD);
end

%Rank sum each day pair for comparison
for pcI = 1:size(pairsCompareInd,1)  
    [ARMpValSplitterComesBack{pcI},ARMhValSplitterComesBack{pcI},ARMwhichWonSplitterComesBack{pcI},ARMdayPairsSCB{pcI}] =...
                    RankSumAllDaypairs([ARMpooledSplitterComesBackFWD{pairsCompareInd(pcI,1)}; ARMpooledSplitterComesBackREV{pairsCompareInd(pcI,1)}],...
                                       [ARMpooledSplitterComesBackFWD{pairsCompareInd(pcI,2)}; ARMpooledSplitterComesBackREV{pairsCompareInd(pcI,2)}],...
                                       [pooledDaysApartFWD; pooledDaysApartREV]);
                                   
    [ARMpValSplitterStillSplitter{pcI},ARMhValSplitterStillSplitter{pcI},ARMwhichWonSplitterStillSplitter{pcI},ARMdayPairsSSS{pcI}] =...
                    RankSumAllDaypairs([ARMpooledSplitterStillSplitterFWD{pairsCompareInd(pcI,1)}; ARMpooledSplitterStillSplitterREV{pairsCompareInd(pcI,1)}],...
                                       [ARMpooledSplitterStillSplitterFWD{pairsCompareInd(pcI,2)}; ARMpooledSplitterStillSplitterREV{pairsCompareInd(pcI,2)}],...
                                       [pooledDaysApartFWD; pooledDaysApartREV]);    
                                   
    
end

%Rank sum group as a whole
for tgI = 1:length(ARMtraitGroups{1})
    [ARMpValSCBall{tgI}, ARMhValSCBall{tgI}] = ranksum(ARMpooledSplitterComesBackFWD{tgI},ARMpooledSplitterComesBackREV{tgI});
    [~,ARMwhichWonSCBall{tgI}] = max([mean(ARMpooledSplitterComesBackFWD{tgI}) mean(ARMpooledSplitterComesBackREV{tgI})]);
    %[mean(pooledSplitterComesBackFWD{tgI}) mean(pooledSplitterComesBackREV{tgI})]
    [ARMpValSSSall{tgI}, ARMhValSSSall{tgI}] = ranksum(ARMpooledSplitterStillSplitterFWD{tgI},ARMpooledSplitterStillSplitterREV{tgI});
    [~,ARMwhichWonSSSall{tgI}] = max([mean(ARMpooledSplitterStillSplitterFWD{tgI}) mean(ARMpooledSplitterStillSplitterREV{tgI})]);
end

%F test, slopes, etc. 

%Compare LR with LR only, ST with ST only

disp('Done ARM splitter reactivation')

%% STEM vs. ARM props
for tgI = 1:numTraitGroups
    [pSvAsplitPropDiffs{tgI}, hSvAsplitPropDiffs{tgI}] = signtest(pooledSplitProp{tgI} - ARMpooledSplitProp{tgI});
end