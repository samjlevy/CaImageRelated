%% Plot rasters for all good cells
%Works, but probably don't accidentally run this
%{
for mouseI = 1:numMice
    saveDir = fullfile(mainFolder,mice{mouseI});
    cellsUse = find(sum(dayUse{mouseI},2)>0);
    PlotRastersPDF(cellTBT{mouseI}, cellSSI{mouseI}, cellAllFiles{mouseI}, cellsUse, saveDir, mice{mouseI});
end
%}

%% How many cells active?
figure;
plot(pooledRealDayDiffs,pooledActiveCellsChange,'.k','MarkerSize',8)
hold on
plot(-1*pooledRealDayDiffs,-1*pooledActiveCellsChange,'.k','MarkerSize',8)
plot([-20 20],[0 0],'k')
plot(cellsActiveFitLine(:,1),cellsActiveFitLine(:,2),'k','LineWidth',2)
plot(-1*cellsActiveFitLine(:,1),-1*cellsActiveFitLine(:,2),'k','LineWidth',2)
title(['Change in cells above activity threshold, slope diff from 0 at p=' num2str(cellsActivepVal)])
xlabel('Days Apart')
ylabel('STEM Change in Proportion of Cells Active on Stem')

figure;
plot(pooledRealDayDiffs,pooledActiveCellsChangeARM,'.k','MarkerSize',8)
hold on
plot(-1*pooledRealDayDiffs,-1*pooledActiveCellsChangeARM,'.k','MarkerSize',8)
plot([-20 20],[0 0],'k')
plot(cellsActiveFitLineARM(:,1),cellsActiveFitLineARM(:,2),'k','LineWidth',2)
plot(-1*cellsActiveFitLineARM(:,1),-1*cellsActiveFitLineARM(:,2),'k','LineWidth',2)
title(['ARM Change in cells above activity threshold, slope diff from 0 at p=' num2str(cellsActivepValARM)])
xlabel('Days Apart')
ylabel('Change in Proportion of Cells Active')
ylim([-0.15 0.15])


%%
compsMake = {[1 2];[3 5];[4 5]};
tgsPlot = unique([compsMake{:}]);

colorAsscAlt = colorAssc;
colorAsscAlt{3} = colorAssc{1};
colorAsscAlt{4} = colorAssc{2};
colorAsscAlt{8} = [0.6 0.6 0.6];

%% Proportion of each splitter type
hh = figure('Position',[593 58 651 803]);
axHand = []; statsOut = [];
for slI = 1:2
    axHand{slI} = subplot(2,1,slI);
    [axHand{slI},statsOut{slI}] = PlotTraitProps(pooledSplitProp{slI},[3 4 5 8],{[2 3];[1 3];[3 4];[2 4];[1 4]},colorAsscAlt,traitLabels,axHand{slI});
    title(['Splitter Proportions on ' upper(splitterLoc{slI})])
end
suptitleSL('Proportions of Splitter Cells on Central Stem and Return Arms')

for tgI = 1:numTraitGroups
    %sign test stem vs. arms
    splitPropDiffs{tgI} = pooledSplitProp{1}{tgI} - pooledSplitProp{2}{tgI};
    [pSplitPropDiffs(tgI),hSplitPropDiffs(tgI)] = signtest(splitPropDiffs{tgI}); %h = 1 reject (different)
end

%% Change in Proportion of Each splitter type by days apart
gh = [];
statsOut = [];
for slI = 1:2
    gh{slI} = figure('Position',[593 273 559 501]);%[435 278 988 390]
    [gh{slI},statsOut{slI}] = PlotTraitChangeOverDays(pooledSplitNumChange{slI},pooledRealDayDiffs,...
        {[3 4 5 8]},colorAsscAlt,traitLabels,gh{slI},false,'mean',[-0.25 0.25],'pct Change'); %Num in this case is diff in Pcts.
    suptitleSL(['Change in Proportion of Splitters on ' splitterLoc{slI}])
end

%% Prop of splitters that come back
gh = [];
statsOut = [];
for slI = 1:2
    gh{slI} = figure('Position',[435 278 988 390]);
    [gh{slI},statsOut{slI}] = PlotTraitChangeOverDays(pooledSplitterComesBack{slI},pooledRealDayDiffs,...
        pairsCompareInd(cpsPlot,:),colorAssc,traitLabels,gh{slI},false,'regress',[0 1],'pct. Cells Return'); %Num in this case is diff in Pcts.
    suptitleSL(['Change in Proportion of Splitters that Come Back on ' splitterLoc{slI}])
end

gh = [];
statsOut = [];
for slI = 1:2
    gh{slI} = figure('Position',[435 278 988 390]);
    [gh{slI},statsOut{slI}] = PlotTraitChangeOverDays(pooledSplitterComesBack{slI},pooledRealDayDiffs,...
        {[1 2]; [3 4 5]},colorAssc,traitLabels,gh{slI},[0 1],'pct. Cells Return'); %Num in this case is diff in Pcts.
    suptitleSL(['Change in Proportion of Splitters that Come Back on ' splitterLoc{slI}])
end

hj = [];
for slI = 1:2
    hj{slI} = figure;
    for tgI = 1:length(tgsPlot)
        [fitVal,daysPlot] = FitLineForPlotting(pooledSplitterComesBack{slI}{tgsPlot(tgI)},pooledRealDayDiffs);
        plot(daysPlot,fitVal,'Color',colorAssc{tgsPlot(tgI)},'LineWidth',2);
        hold on
    end
    ylim([0.1 0.6])
    xlim([0.5 max(pooledRealDayDiffs)+0.5])
    xlabel('Days Apart'); ylabel('Percent returning')
    title(['Pct. of Splitters that come back on ' splitterLoc{slI}])
    
    %dimComp = [3 4 5];
    %dimComp(statsOut{slI}.comps{2})
    %statsOut{1}.slopeDiffComp{2}.pVal
end
     
%Stem vs. arm
jk = figure;
statsOut = [];
[jk,statsOut] = PlotTraitChangeOverDaysSTEMvsARM(pooledSplitterComesBack{1},pooledRealDayDiffs,pooledSplitterComesBack{2},...
    pooledRealDayDiffs,colorAssc,traitLabels,jk,[0 1],'% Cells That Come Back');

%% Prop of splitters that still split
gh = [];
statsOut = [];
for slI = 1:2
    gh{slI} = figure('Position',[435 278 988 390]);
    [gh{slI},statsOut{slI}] = PlotTraitChangeOverDays(pooledSplitterStillSplitter{slI},pooledRealDayDiffs,...
        pairsCompareInd(cpsPlot,:),colorAssc,traitLabels,gh{slI},[0 1],'pct. Cells Same Type'); %Num in this case is diff in Pcts.
    suptitleSL(['Change in Proportion of Splitters that Are the Same Splitting Type on ' splitterLoc{slI}])
end

gh = [];
statsOut = [];
for slI = 1:2
    gh{slI} = figure('Position',[435 278 988 390]);
    [gh{slI},statsOut{slI}] = PlotTraitChangeOverDays(pooledSplitterStillSplitter{slI},pooledRealDayDiffs,...
        {[1 2]; [3 4 5]},colorAssc,traitLabels,gh{slI},[0 1],'pct. Cells Same Type'); %Num in this case is diff in Pcts.
    suptitleSL(['Change in Proportion of Splitters that Are the Same Splitting Type on ' splitterLoc{slI}])
end

hj = [];
for slI = 1:2
    hj{slI} = figure;
    for tgI = 1:length(tgsPlot)
        [fitVal,daysPlot] = FitLineForPlotting(pooledSplitterStillSplitter{slI}{tgsPlot(tgI)},pooledRealDayDiffs);
        plot(daysPlot,fitVal,'Color',colorAssc{tgsPlot(tgI)},'LineWidth',2);
        hold on
    end
    ylim([0 0.5])
    xlim([0.5 max(pooledRealDayDiffs)+0.5])
    xlabel('Days Apart'); ylabel('Percent returning')
    title(['Pct. of Splitters that split same type on ' splitterLoc{slI}])
end

%Stem vs. arm
jk = figure;
statsOut = [];
[jk,statsOut] = PlotTraitChangeOverDaysSTEMvsARM(pooledSplitterStillSplitter{1},pooledRealDayDiffs,pooledSplitterStillSplitter{2},...
    pooledRealDayDiffs,colorAssc,traitLabels,jk,[0 1],'% Cells That Still Split');

%% Splitters changing type
gj = [];
statsOut = [];
for slI = 1:2
    gj{slI} = figure('Position',[258 350 1542 459]);
    [gj{slI},statsOut{slI}]=PlotTraitChangeOverDays(pooledSplitterChanges{slI},pooledRealDayDiffs,...
        [5 6 3 4],...%[1 3; 2 4; 3 4; 5 6],...
        colorAssc,transLabels,gj{slI},[0 0.6],'pct. Cells Changing Type');
    suptitleSL(['Transition likelihoods on ' splitterLoc{slI}])
end

%% What are new cells?
gh = [];
statsOut = [];
for slI = 1:2
    gh{slI} = figure('Position',[435 278 988 390]);
    [gh{slI},statsOut{slI}] = PlotTraitChangeOverDays(pooledNewCellPropChanges{slI},pooledRealDayDiffs,...
        {[1 2];[3 4 5]},colorAssc,traitLabels,gh{slI},[-0.65 0.65],'Change in Pct. New Cells this Type'); %Num in this case is diff in Pcts.
    suptitleSL(['Change in Proportion of New Cells that are a splitting type ' splitterLoc{slI}])
end

%% Num days a splitter
qw = [];
for slI = 1:2
    qw{slI} = figure('Position',[697 219 695 466]);
    for cpI = 1:length(cpsPlot)
        datA = pooledNumDaysSplitter{slI}{pairsCompareInd(cpI,1)}(pooledNumDaysSplitter{slI}{pairsCompareInd(cpI,1)}>0);
        datB = pooledNumDaysSplitter{slI}{pairsCompareInd(cpI,2)}(pooledNumDaysSplitter{slI}{pairsCompareInd(cpI,2)}>0);
        plot(cpI*2-1+[-0.25 0.25],ones(1,2)*mean(datA),'k','LineWidth',2); hold on
        plot([cpI*2-1 cpI*2-1],[mean(datA)+[-1 1]*standarderrorSL(datA)],'k','LineWidth',2)
        
        text(cpI*2-0.75,0.65,[num2str(mean(datA)) ' +/- ' num2str(standarderrorSL(datA))],'HorizontalAlignment','center')
        
        plot(cpI*2+[-0.25 0.25],ones(1,2)*mean(datB),'k','LineWidth',2)
        plot([cpI*2 cpI*2],[mean(datB)+[-1 1]*standarderrorSL(datB)],'k','LineWidth',2)
        
        text(cpI*2-0.25,0.45,[num2str(mean(datB)) ' +/- ' num2str(standarderrorSL(datB))],'HorizontalAlignment','center')
        
        [pHere,hHere] = ranksum(datA,datB);
        heightH = max([mean(datA) mean(datB)]) + 0.3;
        plot([cpI*2-1 cpI*2],[heightH heightH],'k','LineWidth',2)
        text(cpI*2-0.5,heightH+0.1,['p = ' num2str(pHere)],'HorizontalAlignment','center')
    end
    ylim([0 3])
    xlim([0.5 cpI*2+0.5])
    qw{slI}.Children.XTickLabel = traitLabels(tgsPlot);
    ylabel('Mean +/- SEM number of days this trait')
    title(['How many days each cell this trait on ' splitterLoc{slI}])
end

statsOutBonus = [];
for tgI = 1:numTraitGroups
    [statsOutBonus.ranksum(tgI).pVal, statsOutBonus.ranksum(tgI).hVal] = ranksum(...
        pooledNumDaysSplitter{1}{tgI}(pooledNumDaysSplitter{1}{tgI}>0),...
        pooledNumDaysSplitter{2}{tgI}(pooledNumDaysSplitter{2}{tgI}>0));
    statsOutBonus.ranksum(tgI).whichWon = WhichWonRanks(...
        pooledNumDaysSplitter{1}{tgI}(pooledNumDaysSplitter{1}{tgI}>0),...
        pooledNumDaysSplitter{2}{tgI}(pooledNumDaysSplitter{2}{tgI}>0));
end

%% When are splitters active (dayBias)
compsDisp = {[1 2] [3 4 5]};
for slI = 1:2
    disp(splitterLoc{slI})
for cdI = 1:2
    for cdJ = 1:length(compsDisp{cdI})
        datHere = pooledCOMBiases{slI}{compsDisp{cdI}(cdJ)};
        disp([traitLabels{compsDisp{cdI}(cdJ)} ': '...
            num2str(mean(datHere(:,1))) '+/-' num2str(standarderrorSL(datHere(:,1))) '; '... 
            num2str(mean(datHere(:,2))) '+/-' num2str(standarderrorSL(datHere(:,2))) '; '...
            num2str(mean(datHere(:,3))) '+/-' num2str(standarderrorSL(datHere(:,3))) '; '])
    end
end
end

for slI = 1:2
    figure;
    for cpI = 1:length(cpsPlot)
        subplot(length(cpsPlot),2,cpI*2-1)
        
        for mouseI = 1:numMice
            parsedBiases{slI}{cpI,1}(mouseI,:) = ...
                [logicalCOMgroupout{slI}{mouseI}(pairsCompareInd(cpI,1)).dayBias.Pct.Early,...
                          logicalCOMgroupout{slI}{mouseI}(pairsCompareInd(cpI,1)).dayBias.Pct.NoBias,...
                          logicalCOMgroupout{slI}{mouseI}(pairsCompareInd(cpI,1)).dayBias.Pct.Late];
            plot([1,2,3],parsedBiases{slI}{cpI,1}(mouseI,:)); hold on
        end
        title(traitLabels{pairsCompareInd(cpI,1)})
        
        subplot(length(cpsPlot),2,cpI*2)
        for mouseI = 1:numMice
            parsedBiases{slI}{cpI,2}(mouseI,:) = ...
                [logicalCOMgroupout{slI}{mouseI}(pairsCompareInd(cpI,2)).dayBias.Pct.Early,...
                          logicalCOMgroupout{slI}{mouseI}(pairsCompareInd(cpI,2)).dayBias.Pct.NoBias,...
                          logicalCOMgroupout{slI}{mouseI}(pairsCompareInd(cpI,2)).dayBias.Pct.Late];
            plot([1,2,3],parsedBiases{slI}{cpI,2}(mouseI,:)); hold on
        end
        title(traitLabels{pairsCompareInd(cpI,2)})
    end
end


%% Cells splitter type in STEM and ARM
%Same splitter type in cell and arm
hh = figure('Position',[589 293 637 447]); 
axHand = axes;
statsOut = [];
[axHand,statsOut] = PlotTraitProps(pctTraitBothPooled,tgsPlot,pairsCompareInd(cpsPlot,:),colorAssc,traitLabels,axHand);
title('Proportions of Splitter Cells on Central Stem and Return Arms')
ylabel('% of active on both')

%Cells have the same preference
hj = figure('Position',[519 337 1138 336]);
axHand = []; statsOut = []; statsExtra = [];
axHand{1} = subplot(1,3,1); 
[axHand{1},statsOut{1}] = PlotTraitProps(pooledPctSamePref,[1 2],[1 2],[],splitterType,axHand{1});
title('Active Both Same Pref'); xlabel('Which splitting'); ylabel('Prop. Cells with Same Split Pref.')
axHand{2} = subplot(1,3,2); 
[axHand{2},statsOut{2}] = PlotTraitProps(pooledPctSamePrefSTEM,[1 2],[1 2],[],splitterType,axHand{2});
title('Active STEM Same Pref'); xlabel('Which splitting'); ylabel('Prop. Cells with Same Split Pref.')
axHand{3} = subplot(1,3,3); 
[axHand{3},statsOut{3}] = PlotTraitProps(pooledPctSamePrefARM,[1 2],[1 2],[],splitterType,axHand{3});
title('Active ARMs Same Pref'); xlabel('Which splitting'); ylabel('Prop. Cells with Same Split Pref.')
%Stem vs. arm
for stI = 1:2
    [statsExtra.ranksum.pVal(stI), statsExtra.ranksum.hVal(stI)] = ranksum(pooledPctSamePrefSTEM{stI},pooledPctSamePrefARM{stI});
    statsExtra.ranksum.whichWon(stI) = WhichWonRanks(pooledPctSamePrefSTEM{stI},pooledPctSamePrefARM{stI});
end

%Same Preferences by splitting type
hj = []; axHand = []; statsOut = [];
for slI = 1:2
    hj{slI} = figure('Position',[593 58 651 803]);
    for stI = 1:2
        axHand{slI}{stI} = subplot(2,1,stI);
        [axHand{slI}{stI},statsOut{slI}{stI}] = PlotTraitProps(pooledPctSamePrefByTG{stI}{slI},tgsPlot,pairsCompareInd(cpsPlot,:),colorAssc,traitLabels,axHand{slI}{stI});
        title(['Same ' splitterType{stI} ' preference'])
    end
    suptitleSL(['Pct. of cell type with same preference of ' splitterLoc{slI} ' splitters'])
end
%Stem vs. arm
statsExtra = [];
for stI = 1:2
    for tgI = 1:numTraitGroups
        [statsExtra{stI}.signtest.pVal(tgI), statsExtra{stI}.signtest.hVal(tgI)] = signtest(...
            pooledPctSamePrefByTG{stI}{1}{tgI},pooledPctSamePrefByTG{stI}{2}{tgI});
        statsExtra{stI}.signtest.whichWon(tgI) = WhichWonRanks(pooledPctSamePrefByTG{stI}{1}{tgI},pooledPctSamePrefByTG{stI}{2}{tgI});
    end
end

%% PV corr figures, cellsPresentBoth only

%% Within-day curves
cellCritUse = 5;
%Stem
jj = PlotPVcurves(CSpooledPVcorrs{cellCritUse},CSpooledPVdaysApart{cellCritUse},condSetColors,condSetLabels,[]);
title(['Mean Within-Day Population Vector Correlation STEM(' pvNames{cellCritUse} ')'])
ylim([0 0.7])
%Arms
jj = PlotPVcurves(CSpooledPVcorrsARM{cellCritUse},CSpooledPVdaysApart{cellCritUse},condSetColors,condSetLabels,[]);
title(['Mean Within-Day Population Vector Correlation ARM(' pvNames{cellCritUse} ')'])
ylim([0 0.7])

%% PV corr by days apart
%Stem
figure('Position',[317 403 1448 417]);
gg = []; statsOut = [];
gg{1} = subplot(1,3,1);
[gg{1}, statsOut{1}] = PlotMeanPVcorrsDaysApart(CSpooledMeanPVcorrs{cellCritUse}, CSpooledPVdaysApart{cellCritUse},...
    'none', condSetColors, condSetLabels, false, gg{1});
gg{1}.Title.String = ['Mean All Bins (' pvNames{cellCritUse} ')'];
ylim([-0.3 0.4])
gg{2} = subplot(1,3,2);
[gg{2}, statsOut{2}] = PlotMeanPVcorrsDaysApart(CSpooledMeanPVcorrsHalfFirst{cellCritUse}, CSpooledPVdaysApart{cellCritUse},...
    'none', condSetColors, condSetLabels, false, gg{2});
gg{2}.Title.String = ['Mean 1st 2 bins (' pvNames{cellCritUse} ')'];
ylim([-0.3 0.4])
gg{3} = subplot(1,3,3);
[gg{3}, statsOut{3}] = PlotMeanPVcorrsDaysApart(CSpooledMeanPVcorrsHalfSecond{cellCritUse}, CSpooledPVdaysApart{cellCritUse},...
    'none', condSetColors, condSetLabels, false, gg{3});
ylim([-0.3 0.4])
gg{3}.Title.String = ['Mean Last 2 bins (' pvNames{cellCritUse} ')'];
suptitleSL('Mean correlation by days apart STEM')
%Arm
figure('Position',[317 403 1448 417]);
gg = []; statsOut = [];
gg{1} = subplot(1,3,1);
[gg{1}, statsOut{1}] = PlotMeanPVcorrsDaysApart(CSpooledMeanPVcorrsARM{cellCritUse}, CSpooledPVdaysApart{cellCritUse},...
    'none', condSetColors, condSetLabels, false, gg{1});
gg{1}.Title.String = ['Mean Correlation by Days Apart (' pvNames{cellCritUse} ')'];
ylim([-0.3 0.4])
gg{2} = subplot(1,3,2);
[gg{2}, statsOut{2}] = PlotMeanPVcorrsDaysApart(CSpooledMeanPVcorrsHalfFirstARM{cellCritUse}, CSpooledPVdaysApart{cellCritUse},...
    'none', condSetColors, condSetLabels, false, gg{2});
gg{2}.Title.String = ['Mean Correlation by Days Apart 1st 2 bins (' pvNames{cellCritUse} ')'];
ylim([-0.3 0.4])
gg{3} = subplot(1,3,3);
[gg{3}, statsOut{3}] = PlotMeanPVcorrsDaysApart(CSpooledMeanPVcorrsHalfSecondARM{cellCritUse}, CSpooledPVdaysApart{cellCritUse},...
    'none', condSetColors, condSetLabels, false, gg{3});
gg{3}.Title.String = ['Mean Correlation by Days Apart last 2 bins (' pvNames{cellCritUse} ')'];
ylim([-0.3 0.4])
suptitleSL('Mean correlation by days apart ARM')


%% Change and separation of PV corrs
%Stem
% PV corr self change by days apart
figure('Position',[317 403 1448 417]); 
ggt = []; statsOut = [];
ggt{1} = subplot(1,3,1);
[ggt{1},statsOut{1}] = PlotChangeByDaysApartFWDonly(withinCSdayChangeMean{cellCritUse},sameDayDayDiffsPooled{cellCritUse},condSetColors,condSetLabels,ggt{1});
ggt{1}.Title.String = ['Mean All Bins'];
xlabel('Days Apart'); ylabel('Change in mean PV corr'); ylim([-0.4 0.4])
ggt{2} = subplot(1,3,2);
[ggt{2},statsOut{2}] = PlotChangeByDaysApartFWDonly(withinCSdayChangeMeanHalfFirst{cellCritUse},sameDayDayDiffsPooled{cellCritUse},condSetColors,condSetLabels,ggt{2});
ggt{2}.Title.String = ['1st 2 bins'];
xlabel('Days Apart'); ylabel('Change in mean PV corr'); ylim([-0.4 0.4])
ggt{3} = subplot(1,3,3);
[ggt{3},statsOut{3}] = PlotChangeByDaysApartFWDonly(withinCSdayChangeMeanHalfSecond{cellCritUse},sameDayDayDiffsPooled{cellCritUse},condSetColors,condSetLabels,ggt{3});
ggt{3}.Title.String = ['Last 2 bins'];
xlabel('Days Apart'); ylabel('Change in mean PV corr'); ylim([-0.4 0.4])
suptitleSL('Change of Within-Day PV corrs STEM')

%PV corr separation by days apart
cscColors = {'m'; 'c'; 'k'};
figure('Position',[317 403 1448 417]); 
ggt = []; statsOut = [];
ggt{1} = subplot(1,3,1);
[ggt{1},statsOut{1}] = PlotChangeByDaysApartFWDonly(cscDiffsChangeMeanPooled{cellCritUse},sameDayDayDiffsPooled{cellCritUse},cscColors,cscLabels,ggt{1});
ggt{1}.Title.String = ['Mean All Bins'];
xlabel('Days Apart'); ylabel('Change in mean PV corr'); ylim([-0.4 0.4])
ggt{2} = subplot(1,3,2);
[ggt{2},statsOut{2}] = PlotChangeByDaysApartFWDonly(cscDiffsChangeMeanHalfFirstPooled{cellCritUse},sameDayDayDiffsPooled{cellCritUse},cscColors,cscLabels,ggt{2});
ggt{2}.Title.String = ['1st 2 bins'];
xlabel('Days Apart'); ylabel('Change in mean PV corr'); ylim([-0.4 0.4])
ggt{3} = subplot(1,3,3);
[ggt{3},statsOut{3}] = PlotChangeByDaysApartFWDonly(cscDiffsChangeMeanHalfSecondPooled{cellCritUse},sameDayDayDiffsPooled{cellCritUse},cscColors,cscLabels,ggt{3});
ggt{3}.Title.String = ['Last 2 bins'];
xlabel('Days Apart'); ylabel('Change in mean PV corr'); ylim([-0.4 0.4])
suptitleSL('Change of Within-Day Separation of PV corrs STEM')


%Arms
% PV corr self change by days apart
figure('Position',[317 403 1448 417]); 
ggt = []; statsOut = [];
ggt{1} = subplot(1,3,1);
[ggt{1},statsOut{1}] = PlotChangeByDaysApartFWDonly(withinCSdayChangeMeanARM{cellCritUse},...
    sameDayDayDiffsPooled{cellCritUse},condSetColors,condSetLabels,ggt{1});
ggt{1}.Title.String = ['Mean All Bins'];
xlabel('Days Apart'); ylabel('Change in mean PV corr'); ylim([-0.4 0.4])
ggt{2} = subplot(1,3,2);
[ggt{2},statsOut{2}] = PlotChangeByDaysApartFWDonly(withinCSdayChangeMeanHalfFirstARM{cellCritUse},...
    sameDayDayDiffsPooled{cellCritUse},condSetColors,condSetLabels,ggt{2});
ggt{2}.Title.String = ['1st 2 bins'];
xlabel('Days Apart'); ylabel('Change in mean PV corr'); ylim([-0.4 0.4])
ggt{3} = subplot(1,3,3);
[ggt{3},statsOut{3}] = PlotChangeByDaysApartFWDonly(withinCSdayChangeMeanHalfSecondARM{cellCritUse},...
    sameDayDayDiffsPooled{cellCritUse},condSetColors,condSetLabels,ggt{3});
ggt{3}.Title.String = ['Last 2 bins'];
xlabel('Days Apart'); ylabel('Change in mean PV corr'); ylim([-0.4 0.4])
suptitleSL('Change of Within-Day PV corrs ARM')

%PV corr separation by days apart
cscColors = {'m'; 'c'; 'k'};
figure('Position',[317 403 1448 417]); 
ggt = []; statsOut = [];
ggt{1} = subplot(1,3,1);
[ggt{1},statsOut{1}] = PlotChangeByDaysApartFWDonly(cscDiffsChangeMeanPooledARM{cellCritUse},sameDayDayDiffsPooled{cellCritUse},cscColors,cscLabels,ggt{1});
ggt{1}.Title.String = ['Mean All Bins'];
xlabel('Days Apart'); ylabel('Change in mean PV corr'); ylim([-0.4 0.4])
ggt{2} = subplot(1,3,2);
[ggt{2},statsOut{2}] = PlotChangeByDaysApartFWDonly(cscDiffsChangeMeanHalfFirstPooledARM{cellCritUse},sameDayDayDiffsPooled{cellCritUse},cscColors,cscLabels,ggt{2});
ggt{2}.Title.String = ['1st 2 bins'];
xlabel('Days Apart'); ylabel('Change in mean PV corr'); ylim([-0.4 0.4])
ggt{3} = subplot(1,3,3);
[ggt{3},statsOut{3}] = PlotChangeByDaysApartFWDonly(cscDiffsChangeMeanHalfSecondPooledARM{cellCritUse},sameDayDayDiffsPooled{cellCritUse},cscColors,cscLabels,ggt{3});
ggt{3}.Title.String = ['Last 2 bins'];
xlabel('Days Apart'); ylabel('Change in mean PV corr'); ylim([-0.4 0.4])
suptitleSL('Change of Within-Day Separation of PV corrs ARM')

%% Stem vs Arms
gg = figure; statsOut = [];
for condI = 1:length(condSetLabels)
    stemArmDiff{condI} =  CSpooledMeanPVcorrs{cellCritUse}{condI}-CSpooledMeanPVcorrsARM{cellCritUse}{condI};
end
[gg, statsOut] = PlotMeanPVcorrsDaysApart(stemArmDiff, CSpooledPVdaysApart{cellCritUse},...
    'none', condSetColors, condSetLabels, false, gg);
ylim([-0.25 0.25])
title('Diff in correlation between Stem and Arms, MEAN')
ylabel('ARM higher    Correlation Diff    STEM higher')
xlabel('Day Lag')


gg = figure; statsOut = [];
for condI = 1:length(condSetLabels)
    stemArmDiff{condI} =  CSpooledMeanPVcorrsHalfFirst{cellCritUse}{condI}-CSpooledMeanPVcorrsARM{cellCritUse}{condI};
end
[gg, statsOut] = PlotMeanPVcorrsDaysApart(stemArmDiff, CSpooledPVdaysApart{cellCritUse},...
    'none', condSetColors, condSetLabels, false, gg);
ylim([-0.25 0.35])
title('Diff in correlation between Stem-1st 2 bins and Arms, MEAN')
ylabel('ARM higher    Correlation Diff    STEM higher')
xlabel('Day Lag')


gg = figure; statsOut = [];
for condI = 1:length(condSetLabels)
    stemArmDiff{condI} =  CSpooledMeanPVcorrsHalfSecond{cellCritUse}{condI}-CSpooledMeanPVcorrsARM{cellCritUse}{condI};
end
[gg, statsOut] = PlotMeanPVcorrsDaysApart(stemArmDiff, CSpooledPVdaysApart{cellCritUse},...
    'none', condSetColors, condSetLabels, false, gg);
ylim([-0.25 0.25])
title('Diff in correlation between Stem-Last 2 bins and Arms, MEAN')
ylabel('ARM higher    Correlation Diff    STEM higher')
xlabel('Day Lag')

%{
plotColors = {[0.4706    0.6706    0.1882],[0 1 0];...
              [0.6392    0.0784    0.1804],[0.8510    0.3294    0.1020];...
              [0 0 1], [0 1 1]};
          
figure('Position',[317 403 1448 417]);
statsOut = [];
for condI = 1:length(condSetLabels)
    subplot(1,length(condSetLabels),condI)
    [statsOut{condI}] = PVcorrCompStemVSarm(CSpooledMeanPVcorrs{cellCritUse}{condI},CSpooledMeanPVcorrsARM{cellCritUse}{condI},...
        CSpooledPVdaysApart{cellCritUse}{condI},plotColors(condI,:),'mean',[0 0.9]); 
    title(condSetLabels{condI})
    xlabel('Day Lag'); ylabel('Correlation')
end
suptitleSL(['Difference between STEM (dark) and ARM (light) mean corrs (' pvNames{cellCritUse} ')'])
%}

%% Decoder results 

%decResults{1} = decodingResultsPooled{1}{dtI}
%decResults{2} = decodingResultsPooled{2}{dtI}
%Within day decoding
for slI = 1:2
    colors{1} = {colorAssc{1} colorAssc{2}}; colors{2} = {colorAssc{1} colorAssc{2}};
    [axH,statsOut]=PlotWithinDayDecoding(decodingResultsPooled{slI},shuffledResultsPooled{slI},sessDayDiffs{slI},...
        {'all','thresh'},{'LR','ST'},colors);
    title(['Within-Day Decoding on ' decodeLoc{slI}])
end
%Need downsampled control

%Does within-day decoding change
statsOut = [];
for dtI = 1:length(decodingType)
    figure;
    for slI = 1:2
        subplot(1,2,slI)
        [statsOut{dtI}{slI}] = PlotTraitChangeOverDaysOne(pooledWithinDayDecResChange{slI}{dtI},pooledRealDayDiffs,...
            {colorAssc{1:2}},{'LR','ST'},'Change in Decoding Performance',[-0.5 0.5]);
        title([decodeLoc{slI}])
    end
    suptitleSL(['Change in daily decoding performance using ' decodingType{dtI}]) 
end

%LvR vs. SvT comparison
statsOut = [];
figure('Position',[373 137 482 766]);%[723 305 574 461]
axH = [];
lineType = {{'-','-'},{'--','--'}};
transHere = {[0.6 0.6];[1 1]};
for slI = 1:length(decodeLoc)
for dtI = 1:length(decodingType)
    %axInd = dtI+length(decodeLoc)*(slI-1);
    axInd = slI;
    axH(axInd) = subplot(length(decodeLoc),1,axInd);%length(decodingType)
    
    [axH, statsOut{slI}{dtI}] = PlotDecodingOneVSother3(...
                                                decodingResultsPooled{slI}{dtI},shuffledResultsPooled{slI}{dtI},...%shuffledResultsPooled{slI}{dtI}
                                                decodedWellPooled{slI}{dtI},sessDayDiffs{slI}{dtI}{1},sessDayDiffs{slI}{dtI}{1},...
                                                [],lineType{dtI},transHere{dtI},[1 0 0; 0 0 1],axH(axInd));
    title(['Decoding Comparison, ' fileName{dtI} ' cells on ' decodeLoc{slI} ',r=lr b=st'])
end
end
suptitleSL('Transparent = all cells, dotted = above thresh')

%Stem vs. Arm
decDim = {'Traj. Dest.','Task Phase'};
statsOut = [];
figure('Position',[373 137 482 766]);%[723 305 574 461]
axH = [];
lineType = {{'-','-'},{'--','--'}};
transHere = {[0.6 0.6];[1 1]};
for dtI = 1:length(decodingType)
for ddI = 1:2 %decoding dimension
    %figH = figure('Position',[723 305 574 461]);%[723 207 690 559]
    %axInd = ddI+2*(dtI-1);
    %axH(axInd) = subplot(length(decodingType),2,axInd);
    axInd = dtI;
    axH(axInd) = subplot(length(decodingType),1,axInd);
    
    [axH(axInd), statsOut{dtI}{ddI}] = PlotDecodingOneVSother3(...
                            {decodingResultsPooled{1}{dtI}{ddI},decodingResultsPooled{2}{dtI}{ddI}},...
                            {shuffledResultsPooled{1}{dtI}{ddI},shuffledResultsPooled{1}{dtI}{ddI}},...
                            {decodedWellPooled{1}{dtI}{ddI},decodedWellPooled{1}{dtI}{ddI}},...
                            sessDayDiffs{1}{dtI}{ddI},sessDayDiffs{1}{dtI}{ddI},decodeLoc,lineType{ddI},transHere{ddI},[0.85 0.33 0.10; 1 0 1],axH(axInd));
    title(['Decoding Comparison, ' fileName{dtI} ' cells by task timension o=stem p=arm'])
end
end
suptitleSL('Transparent = LR, dotted = ST')


%Within dimension, which cell inclusion is better?
dimCols = {[0.6392 0.0784 0.1804;1 0 0];[ 0 1 1;0 0 1]};
decDim = {'Traj. Dest.','Task Phase'};
statsOut = [];
figure('Position',[373 137 482 766]);%[723 305 574 461]
axH = [];
lineType = {{'-','-'},{'--','--'}};
transHere = {[0.6 0.6];[1 1]};
for slI = 1:length(decodeLoc)
for dwI = 1:length(decDim)
      %figH = figure('Position',[723 207 690 559]);
      %axInd = dwI+length(decodeLoc)*(slI-1);
      %axH(axInd) = subplot(length(decodingType),2,axInd);
      axInd = slI;
      axH(axInd) = subplot(length(decodeLoc),1,axInd);
    
      [axH(axInd), statsOut{slI}{dwI}] = PlotDecodingOneVSother3(...
                                {decodingResultsPooled{slI}{1}{dwI} decodingResultsPooled{slI}{2}{dwI}},...
                                {shuffledResultsPooled{slI}{1}{dwI} shuffledResultsPooled{slI}{2}{dwI}},...
                                {decodedWellPooled{slI}{1}{dwI} decodedWellPooled{slI}{2}{dwI}},...
                                sessDayDiffs{slI}{1}{dwI},sessDayDiffs{slI}{1}{dwI},decodingType,lineType{dwI},transHere{dwI},dimCols{dwI},axH(axInd));
      title(['Decoding Cell Inclusion Comparison, on ' decodeLoc{slI} ', light=all dark=thresh'])
end
end
suptitleSL('Solid = LR, dotted = ST')

%Downsampled
%LR vs. ST
statsOut = [];
figure('Position',[373 137 482 766]);%[723 305 574 461]
axH = [];
lineType = {{'-','-'},{'--','--'}};
transHere = {[0.6 0.6];[1 1]};
for slI = 1:length(decodeLoc)
for dtI = 1:length(decodingType)
    %axInd = dtI+length(decodeLoc)*(slI-1);
    %axH(axInd) = subplot(length(decodeLoc),length(decodingType),axInd);
    axInd = slI;
    axH(axInd) = subplot(length(decodeLoc),1,axInd);
      
    [axH(axInd), statsOut{slI}{dtI}] = PlotDecodingOneVSother3(...
                                downsampledResultsPooled{slI}{dtI},shuffledResultsPooled{slI}{dtI},...%shuffledResultsPooled{slI}{dtI}
                                DSaboveShuffPpooled{slI}{dtI},...
                                sessDayDiffs{slI}{dtI}{1},sessDayDiffs{slI}{dtI}{1},{'Turn Direction','Task Phase'},lineType{dtI},transHere{dtI},[],axH(axInd));
    title(['Decoding Comparison, Downsampled cells on ' decodeLoc{slI} ',r=lr b=st'])
end
end
suptitleSL('Solid = all cells, dotted = thresh')


%Redo here - something needs to be organized differently, may require
%reorganizing all
%RegVsDownsampled
dimCols = {[0.6392 0.0784 0.1804;1 0 0];[ 0 1 1;0 0 1]};
decDim = {'Traj. Dest.','Task Phase'};
lineType = {{'-','--'},{'-','--'}};
transHere = {[0.6 1];[0.6 1]};
for dtI = 1:length(decodingType)
statsOut = [];
figure('Position',[373 137 482 766]);%[723 305 574 461]
axH = [];
for slI = 1:length(decodeLoc)
for ddI = 1:2%decoding Dimension
    %axInd = ddI+length(decodeLoc)*(slI-1);
    %axH(axInd) = subplot(length(decodeLoc),2,axInd);
    axInd = slI;
    axH(axInd) = subplot(length(decodeLoc),1,axInd);
    
    [axH(axInd), statsOut{slI}{dtI}] = PlotDecodingOneVSother3(...
                                {decodingResultsPooled{slI}{dtI}{ddI} downsampledResultsPooled{slI}{dtI}{ddI}},...
                                shuffledResultsPooled{slI}{dtI},...%shuffledResultsPooled{slI}{dtI}
                                {decodedWellPooled{slI}{dtI}{ddI} DSaboveShuffPpooled{slI}{dtI}{ddI}},...
                                sessDayDiffs{slI}{dtI}{ddI},sessDayDiffs{slI}{dtI}{ddI},[],lineType{ddI},transHere{ddI},dimCols{ddI},axH(axInd));
    title(['Decoding comparison, reg. vs. DS, decoding Cells on ' decodeLoc{slI} ])
end
end
suptitleSL(['Decoding with ' decodingType{dtI} ', solid = REG, dotted = DS, r = lr b = st'])
end
            


    