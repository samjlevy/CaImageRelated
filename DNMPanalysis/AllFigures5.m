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

cpsPlot = [1 2 3];
tgsPlot = pairsCompareInd(cpsPlot,:)'; tgsPlot = tgsPlot(:);

%% Proportion of each splitter type
hh = figure('Position',[593 58 651 803]);
for slI = 1:2
    axHand{slI} = subplot(2,1,slI);
    [axHand{slI},statsOut{slI}] = PlotTraitProps(pooledSplitProp{slI},tgsPlot,pairsCompareInd(cpsPlot,:),colorAssc,traitLabels,axHand{slI});
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
    gh{slI} = figure('Position',[435 278 988 390]);
    [gh{slI},statsOut{slI}] = PlotTraitChangeOverDays(pooledSplitNumChange{slI},pooledRealDayDiffs,...
        pairsCompareInd(cpsPlot,:),colorAssc,traitLabels,gh{slI},[-0.6 0.6],'pct Change'); %Num in this case is diff in Pcts.
    suptitleSL(['Change in Proportion of Splitters on ' splitterLoc{slI}])
end

%% Prop of splitters that come back
gh = [];
statsOut = [];
for slI = 1:2
    gh{slI} = figure('Position',[435 278 988 390]);
    [gh{slI},statsOut{slI}] = PlotTraitChangeOverDays(pooledSplitterComesBack{slI},pooledRealDayDiffs,...
        pairsCompareInd(cpsPlot,:),colorAssc,traitLabels,gh{slI},[0 1],'pct. Cells Return'); %Num in this case is diff in Pcts.
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
    ylim([0 1])
    xlim([0.5 max(pooledRealDayDiffs)+0.5])
    xlabel('Days Apart'); ylabel('Percent returning')
    title(['Pct. of Splitters that come back on ' splitterLoc{slI}])
end
        
%% Prop of splitters that still split
gh = [];
statsOut = [];
for slI = 1:2
    gh{slI} = figure('Position',[435 278 988 390]);
    [gh{slI},statsOut{slI}] = PlotTraitChangeOverDays(pooledSplitterStillSplitter{slI},pooledRealDayDiffs,...
        pairsCompareInd(cpsPlot,:),colorAssc,traitLabels,gh{slI},[0 1],'pct. Cells Same Type'); %Num in this case is diff in Pcts.
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
    ylim([0 1])
    xlim([0.5 max(pooledRealDayDiffs)+0.5])
    xlabel('Days Apart'); ylabel('Percent returning')
    title(['Pct. of Splitters that split same type on ' splitterLoc{slI}])
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
%% When are splitters active (dayBias)

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

%% What are new cells?

gh = [];
statsOut = [];
for slI = 1:2
    gh{slI} = figure('Position',[435 278 988 390]);
    [gh{slI},statsOut{slI}] = PlotTraitChangeOverDays(pooledNewCellPropChanges{slI},pooledRealDayDiffs,...
        pairsCompareInd(cpsPlot,:),colorAssc,traitLabels,gh{slI},[-1 1],'Change in Pct. New Cells this Type'); %Num in this case is diff in Pcts.
    suptitleSL(['Change in Proportion of New Cells taht are a splitting type ' splitterLoc{slI}])
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
%Stem
cellCritUse = 5;
jj = PlotPVcurves(CSpooledPVcorrs{cellCritUse},CSpooledPVdaysApart{cellCritUse},condSetColors,condSetLabels,[]);
title(['Mean Within-Day Population Vector Correlation (' pvNames{cellCritUse} ')'])
ylim([0 0.7])

figure('Position',[317 403 1448 417]);
gg = []; statsOut = [];
gg{1} = subplot(1,3,1);
[gg{1}, statsOut{1}] = PlotMeanPVcorrsDaysApart(CSpooledMeanPVcorrs{cellCritUse}, CSpooledPVdaysApart{cellCritUse}, 'none', condSetColors, condSetLabels, false, gg{1});
gg{1}.Title.String = ['Mean All Bins (' pvNames{cellCritUse} ')'];
gg{2} = subplot(1,3,2);
[gg{2}, statsOut{2}] = PlotMeanPVcorrsDaysApart(CSpooledMeanPVcorrsHalfFirst{cellCritUse}, CSpooledPVdaysApart{cellCritUse}, 'none', condSetColors, condSetLabels, false, gg{2});
gg{2}.Title.String = ['Mean 1st 2 bins (' pvNames{cellCritUse} ')'];
gg{3} = subplot(1,3,3);
[gg{3}, statsOut{3}] = PlotMeanPVcorrsDaysApart(CSpooledMeanPVcorrsHalfSecond{cellCritUse}, CSpooledPVdaysApart{cellCritUse}, 'none', condSetColors, condSetLabels, false, gg{3});
gg{3}.Title.String = ['Mean Last 2 bins (' pvNames{cellCritUse} ')'];
suptitleSL('Mean correlation by days apart')

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
suptitleSL('Change of Within-Day PV corrs')

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
suptitleSL('Change of Within-Day Separation of PV corrs')


%Arms
jj = PlotPVcurves(CSpooledPVcorrsARM{cellCritUse},CSpooledPVdaysApart{cellCritUse},condSetColors,condSetLabels,[]);
title(['Mean Within-Day Population Vector Correlation ARM(' pvNames{cellCritUse} ')'])
ylim([0 0.7])

figure('Position',[317 403 1448 417]);
gg = []; statsOut = [];
gg{1} = subplot(1,3,1);
[gg{1}, statsOut{1}] = PlotMeanPVcorrsDaysApart(CSpooledMeanPVcorrsARM{cellCritUse}, CSpooledPVdaysApart{cellCritUse}, 'none', condSetColors, condSetLabels, false, gg{1});
gg{1}.Title.String = ['Mean Correlation by Days Apart (' pvNames{cellCritUse} ')'];
gg{2} = subplot(1,3,2);
[gg{2}, statsOut{2}] = PlotMeanPVcorrsDaysApart(CSpooledMeanPVcorrsHalfFirstARM{cellCritUse}, CSpooledPVdaysApart{cellCritUse}, 'none', condSetColors, condSetLabels, false, gg{2});
gg{2}.Title.String = ['Mean Correlation by Days Apart 1st 2 bins (' pvNames{cellCritUse} ')'];
gg{3} = subplot(1,3,3);
[gg{3}, statsOut{3}] = PlotMeanPVcorrsDaysApart(CSpooledMeanPVcorrsHalfSecondARM{cellCritUse}, CSpooledPVdaysApart{cellCritUse}, 'none', condSetColors, condSetLabels, false, gg{3});
gg{3}.Title.String = ['Mean Correlation by Days Apart last 2 bins (' pvNames{cellCritUse} ')'];
suptitleSL('Mean correlation by days apart ARM')

% PV corr self change by days apart
figure('Position',[317 403 1448 417]); 
ggt = []; statsOut = [];
ggt{1} = subplot(1,3,1);
[ggt{1},statsOut{1}] = PlotChangeByDaysApartFWDonly(withinCSdayChangeMeanARM{cellCritUse},sameDayDayDiffsPooled{cellCritUse},condSetColors,condSetLabels,ggt{1});
ggt{1}.Title.String = ['Mean All Bins'];
xlabel('Days Apart'); ylabel('Change in mean PV corr'); ylim([-0.4 0.4])
ggt{2} = subplot(1,3,2);
[ggt{2},statsOut{2}] = PlotChangeByDaysApartFWDonly(withinCSdayChangeMeanHalfFirstARM{cellCritUse},sameDayDayDiffsPooled{cellCritUse},condSetColors,condSetLabels,ggt{2});
ggt{2}.Title.String = ['1st 2 bins'];
xlabel('Days Apart'); ylabel('Change in mean PV corr'); ylim([-0.4 0.4])
ggt{3} = subplot(1,3,3);
[ggt{3},statsOut{3}] = PlotChangeByDaysApartFWDonly(withinCSdayChangeMeanHalfSecondARM{cellCritUse},sameDayDayDiffsPooled{cellCritUse},condSetColors,condSetLabels,ggt{3});
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
plotColors = {[0 0 1], [0 1 1];...
              [0.6392    0.0784    0.1804],[0.8510    0.3294    0.1020];...
              [0.4706    0.6706    0.1882],[0 1 0]};
          
figure('Position',[317 403 1448 417]);
statsOut = [];
for condI = 1:length(condSetLabels)
    subplot(1,length(condSetLabels),condI)
    [statsOut{condI}] = PVcorrCompStemVSarm(CSpooledMeanPVcorrs{cellCritUse}{condI},CSpooledMeanPVcorrsARM{cellCritUse}{condI},...
        CSpooledPVdaysApart{cellCritUse}{condI},plotColors(condI,:)); 
    title(condSetLabels{condI})
    ylim([-0.1 1]); xlabel('Days Apart'); ylabel('Correlation')
end
suptitleSL(['Difference between STEM (L) and ARM (R) corrs (' pvNames{cellCritUse} ')'])


%% Decoder results 

%Decoder FWD vs REV self.
statsOut = [];
for dtI = 1:length(decodingType)
    dimsDecoded = regDecoding{dtI}{1}.titles;
    figure('Position',[403 461 771 496]);
    for ddI = 1:length(dimsDecoded)
        axH(ddI) = subplot(length(dimsDecoded),1,ddI);
        [axH(ddI),statsOut{dtI}{ddI}] = PlotDecodingFWDvsREVwrapper(decodingResultsPooled{dtI}{ddI},decodedWellPooled{dtI}{ddI},sessDayDiffs{dtI}{ddI},axH(ddI));
        title(['Decoding ' dimsDecoded{ddI} ' ' fileName{dtI} ' cells'])
    end
end
       
%LvR vs. SvT comparison
statsOut = [];
for dtI = 1:length(decodingType)
    [axH, statsOut{dtI}] = PlotDecodingOneVSother(decodingResultsPooled{dtI},shuffledResultsPooled{dtI},decodedWellPooled{dtI},...
                                                sessDayDiffs{dtI}{1},sessDayDiffs{dtI}{1},{'Turn Direction','Task Phase'});
    suptitleSL(['Decoding Comparison, ' fileName{dtI} ' cells'])
end

%Within dimension, which cell inclusion is better?
dimsDecoded = regDecoding{1}{1}.titles;
statsOut = [];
for dwI = 1:length(dimsDecoded)
[axH, statsOut{dwI}] = PlotDecodingOneVSother({decodingResultsPooled{1}{dwI} decodingResultsPooled{2}{dwI}},...
                                         {shuffledResultsPooled{1}{dwI} shuffledResultsPooled{2}{dwI}},...
                                         {decodedWellPooled{1}{dwI} decodedWellPooled{2}{dwI}},sessDayDiffs{1}{dwI},decodingType);
      suptitleSL(['Decoding Cell Inclusion Comparison, ' dimsDecoded{dwI}])
end

%Regular vs Downsampling
dimsDecoded = regDecoding{1}{1}.titles;
statsOut = [];
for dtI = 1:length(decodingType)
    [axH, statsOut{dtI}] = PlotDecodingOneVSother(decodingResultsPooled{dtI},...
           downsampledResultsPooled{dtI},decodeOutofDSpooled{dtI},sessDayDiffs{dtI}{1},sessDayDiffs{dtI}{1},{'Turn Direction','Task Phase'});
    suptitleSL(['Reg vs. downsampled distribution, ' fileName{dtI} ' cells'])
end

%Downsampled inclusion comparison
%Is each downsample above 95% of shuffles?
statsOut = [];
for dtI = 1:length(decodingType)
    [axH, statsOut{dtI}] = PlotDecodingOneVSother(downsampledResultsPooled{dtI},shuffledResultsPooled{dtI},DSaboveShuffPpooled{dtI},...
                    sessDayDiffs{dtI}{1},sessDayDiffs{dtI}{1},dimsDecoded);
    suptitleSL(['Downsampled Decoding vs. Original Shuffle, ' fileName{dtI} ' cells'])
end


%% PV condset each mouse

for pvtI = 1:length(pvNames)
    figure;
    for mouseI = 1:numMice
        subplot(2,2,mouseI)
        for csI = 1:length(condSet)
            plot(CSpooledSameDaymeanCorr{pvtI}{mouseI}{csI},condSetColors{csI})
            hold on
        end
    end
    suptitleSL(pvNames{pvtI})
end
            


    