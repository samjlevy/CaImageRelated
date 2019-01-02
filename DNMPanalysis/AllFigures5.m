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

%% Prop of splitters that still split
gh = [];
statsOut = [];
for slI = 1:2
    gh{slI} = figure('Position',[435 278 988 390]);
    [gh{slI},statsOut{slI}] = PlotTraitChangeOverDays(pooledSplitterStillSplitter{slI},pooledRealDayDiffs,...
        pairsCompareInd(cpsPlot,:),colorAssc,traitLabels,gh{slI},[0 1],'pct. Cells Same Type'); %Num in this case is diff in Pcts.
    suptitleSL(['Change in Proportion of Splitters that Are the Same Splitting Type on ' splitterLoc{slI}])
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
hj = figure;%('Position',[593 58 651 803]);
axHand = []; statsOut = []; statsExtra = [];
axHand{1} = subplot(1,3,1); 
[axHand{1},statsOut{1}] = PlotTraitProps(pooledPctSamePref,[1 2],[1 2],[],splitterType,axHand{1});
title('Cells Active Both Same Pref'); xlabel('Which splitting')
axHand{2} = subplot(1,3,2); 
[axHand{2},statsOut{2}] = PlotTraitProps(pooledPctSamePrefSTEM,[1 2],[1 2],[],splitterType,axHand{2});
title('Cells Active STEM Same Pref'); xlabel('Which splitting')
axHand{3} = subplot(1,3,3); 
[axHand{3},statsOut{3}] = PlotTraitProps(pooledPctSamePrefARM,[1 2],[1 2],[],splitterType,axHand{3});
title('Cells Active ARMs Same Pref'); xlabel('Which splitting')
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


%% Mean pop vector corr all animals all days, each condSet

%mean =/- sem corr each bin, corr to decorr, decorr to corr, flat

hh = PlotAllPVcorrsCurves(CSpooledPVcorrs,CSpooledPVdaysApart,pvNames,condSetColors);
suptitleSL({'Mean PV curves, all mice All Days'; 'B - VS Self,   G - Study vs. Test,   R - Left vs. Right'})

ii = PlotAllPVcorrsCurves(CSpooledPVcorrsARM,CSpooledPVdaysApart,pvNames,condSetColors);
suptitleSL({'ARM Mean PV curves, all mice All Days'; 'B - VS Self,   G - Study vs. Test,   R - Left vs. Right'})
%

%% First two bins vs. last two bins
csColorNums = {[0 0 1]; [0 1 0]; [1 0 0]};
[figHand,statsOut] = FirstHalfVsSecondHaldf(CSpooledPVcorrs,CSpooledPVdaysApart,pvNames,csColorNums,4);
suptitleSL('1st Half vs 2nd half Stem Correlations')
    
csColorNums = {[0 0 1]; [0 1 0]; [1 0 0]};
[figHand,statsOut] = FirstHalfVsSecondHaldf(CSpooledPVcorrs,CSpooledPVdaysApart,pvNames,csColorNums,2);
suptitleSL('1st 2 bins vs Last 2 bins Stem Correlations')
    
csColorNums = {[0 0 1]; [0 1 0]; [1 0 0]};
[figHand,statsOut] = FirstHalfVsSecondHaldf(CSpooledPVcorrsARM,CSpooledPVdaysApart,pvNames,csColorNums,4);
suptitleSL('1st Half vs 2nd half ARM Correlations')
    
csColorNums = {[0 0 1]; [0 1 0]; [1 0 0]};
[figHand,statsOut] = FirstHalfVsSecondHaldf(CSpooledPVcorrsARM,CSpooledPVdaysApart,pvNames,csColorNums,2);
suptitleSL('1st 2 bins vs Last 2 bins ARM Correlations')

%% Pop Vector corrs by days apart
gg = figure('Position',[288 37 1521 849]); 
hht = [];
for pvtI = 1:length(pvNames)
    hht{pvtI} = subplot(2,3,pvtI);
[hht{pvtI}, statsOut] = PlotMeanPVcorrsDaysApart(CSpooledMeanPVcorrs{pvtI}, CSpooledPVdaysApart{pvtI}, 'mean', condSetColors, condSetLabels, hht{pvtI});
hht{pvtI}.Title.String = [pvNames{pvtI}; hht{pvtI}.Title.String];
end
suptitleSL('PV by days apart')

% Pop Vector corrs by days apart FIRST HALF
gg = figure('Position',[288 37 1521 849]); 
hht = [];
for pvtI = 1:length(pvNames)
    hht{pvtI} = subplot(2,3,pvtI);
[hht{pvtI}, statsOut] = PlotMeanPVcorrsDaysApart(CSpooledMeanPVcorrsHalfFirst{pvtI}, CSpooledPVdaysApart{pvtI}, 'mean', condSetColors, condSetLabels, hht{pvtI});
hht{pvtI}.Title.String = [pvNames{pvtI}; hht{pvtI}.Title.String];
end
suptitleSL('PV by days apart, FRIST HALF')

% Pop Vector corrs by days apart SECOND HALF
gg = figure('Position',[288 37 1521 849]); 
hht = [];
for pvtI = 1:length(pvNames)
    hht{pvtI} = subplot(2,3,pvtI);
    [hht{pvtI}, statsOut] = PlotMeanPVcorrsDaysApart(CSpooledMeanPVcorrsHalfSecond{pvtI}, CSpooledPVdaysApart{pvtI}, 'mean', condSetColors, condSetLabels, hht{pvtI});
    hht{pvtI}.Title.String = [pvNames{pvtI}; hht{pvtI}.Title.String];
end
suptitleSL('PV by days apart, SECOND HALF')
%% PV corr self change by days apart
figure('Position',[288 37 1521 849]);
for pvtI = 1:length(pvNames)
    ggt{pvtI} = subplot(2,3,pvtI);
    [ggt{pvtI},statsOut] = PlotChangeByDaysApartFWDonly(withinCSdayChangeMean{pvtI},sameDayDayDiffsPooled{pvtI},condSetColors,condSetLabels,ggt{pvtI});
    ggt{pvtI}.Title.String = [pvNames{pvtI}; ggt{pvtI}.Title.String];
end
suptitleSL('Chance in Each Correlation over Experience')

% PV corr self change by days apart FIRST HALF
figure('Position',[288 37 1521 849]);
for pvtI = 1:length(pvNames)
    ggt{pvtI} = subplot(2,3,pvtI);
    [ggt{pvtI},statsOut] = PlotChangeByDaysApartFWDonly(withinCSdayChangeMeanHalfFirst{pvtI},sameDayDayDiffsPooled{pvtI},condSetColors,condSetLabels,ggt{pvtI});
    ggt{pvtI}.Title.String = [pvNames{pvtI}; ggt{pvtI}.Title.String];
end
suptitleSL('Chance in Each Correlation over Experience First Half')

% PV corr self change by days apart SECOND HALF
figure('Position',[288 37 1521 849]);
for pvtI = 1:length(pvNames)
    ggt{pvtI} = subplot(2,3,pvtI);
    [ggt{pvtI},statsOut] = PlotChangeByDaysApartFWDonly(withinCSdayChangeMeanHalfSecond{pvtI},sameDayDayDiffsPooled{pvtI},condSetColors,condSetLabels,ggt{pvtI});
    ggt{pvtI}.Title.String = [pvNames{pvtI}; ggt{pvtI}.Title.String];
end
suptitleSL('Chance in Each Correlation over Experience Second Half')

%% PV corr separation by days apart

cscColors = {'m'; 'c'; 'k'};%[0.8 0.2 0]
figure('Position',[288 37 1521 849]);
for pvtI = 1:length(pvNames)
    ggt{pvtI} = subplot(2,3,pvtI);
    [ggt{pvtI},statsOut] = PlotChangeByDaysApartFWDonly(cscDiffsChangeMeanPooled{pvtI},sameDayDayDiffsPooled{pvtI},cscColors,cscLabels,ggt{pvtI});
    ggt{pvtI}.Title.String = [pvNames{pvtI}; ggt{pvtI}.Title.String];
end
suptitleSL('Change in Separation between Correlations')

% PV corr separation by days apart FIRST HALF
figure('Position',[288 37 1521 849]);
for pvtI = 1:length(pvNames)
    ggt{pvtI} = subplot(2,3,pvtI);
    [ggt{pvtI},statsOut] = PlotChangeByDaysApartFWDonly(cscDiffsChangeMeanHalfFirstPooled{pvtI},sameDayDayDiffsPooled{pvtI},cscColors,cscLabels,ggt{pvtI});
    ggt{pvtI}.Title.String = [pvNames{pvtI}; ggt{pvtI}.Title.String];
end
suptitleSL('Change in Separation between Correlations FIRST HALF')

% PV corr separation by days apart SECOND HALF
figure('Position',[288 37 1521 849]);
for pvtI = 1:length(pvNames)
    ggt{pvtI} = subplot(2,3,pvtI);
    [ggt{pvtI},statsOut] = PlotChangeByDaysApartFWDonly(cscDiffsChangeMeanHalfSecondPooled{pvtI},sameDayDayDiffsPooled{pvtI},cscColors,cscLabels,ggt{pvtI});
    ggt{pvtI}.Title.String = [pvNames{pvtI}; ggt{pvtI}.Title.String];
end
suptitleSL('Change in Separation between Correlations SECOND HALF')
%% Pop Vector corrs by days apart ARMs
gg = figure('Position',[288 37 1521 849]); 
hht = [];
for pvtI = 1:length(pvNames)
    hht{pvtI} = subplot(2,3,pvtI);
[hht{pvtI}, statsOut] = PlotMeanPVcorrsDaysApart(CSpooledMeanPVcorrsARM{pvtI}, CSpooledPVdaysApart{pvtI}, 'mean', condSetColors, condSetLabels, hht{pvtI});
hht{pvtI}.Title.String = [pvNames{pvtI}; hht{pvtI}.Title.String];
end
suptitleSL('PV by days apart ARMS')

gg = figure('Position',[288 37 1521 849]); 
hht = [];
for pvtI = 1:length(pvNames)
    hht{pvtI} = subplot(2,3,pvtI);
[hht{pvtI}, statsOut] = PlotMeanPVcorrsDaysApart(CSpooledMeanPVcorrsHalfFirstARM{pvtI}, CSpooledPVdaysApart{pvtI}, 'mean', condSetColors, condSetLabels, hht{pvtI});
hht{pvtI}.Title.String = [pvNames{pvtI}; hht{pvtI}.Title.String];
end
suptitleSL('PV by days apart ARMS FIRST HALF')


gg = figure('Position',[288 37 1521 849]); 
hht = [];
for pvtI = 1:length(pvNames)
    hht{pvtI} = subplot(2,3,pvtI);
[hht{pvtI}, statsOut] = PlotMeanPVcorrsDaysApart(CSpooledMeanPVcorrsHalfSecondARM{pvtI}, CSpooledPVdaysApart{pvtI}, 'mean', condSetColors, condSetLabels, hht{pvtI});
hht{pvtI}.Title.String = [pvNames{pvtI}; hht{pvtI}.Title.String];
end
suptitleSL('PV by days apart ARMS SECOND HALF')



%% PV corr self change by days apart ARMS
figure('Position',[288 37 1521 849]);
for pvtI = 1:length(pvNames)
    ggt{pvtI} = subplot(2,3,pvtI);
    [ggt{pvtI},statsOut] = PlotChangeByDaysApartFWDonly(withinCSdayChangeMeanARM{pvtI},sameDayDayDiffsPooled{pvtI},condSetColors,condSetLabels,ggt{pvtI});
    ggt{pvtI}.Title.String = [pvNames{pvtI}; ggt{pvtI}.Title.String];
end
suptitleSL('Chance in Each Correlation over Experience ARMS')

figure('Position',[288 37 1521 849]);
for pvtI = 1:length(pvNames)
    ggt{pvtI} = subplot(2,3,pvtI);
    [ggt{pvtI},statsOut] = PlotChangeByDaysApartFWDonly(withinCSdayChangeMeanHalfFirstARM{pvtI},sameDayDayDiffsPooled{pvtI},condSetColors,condSetLabels,ggt{pvtI});
    ggt{pvtI}.Title.String = [pvNames{pvtI}; ggt{pvtI}.Title.String];
end
suptitleSL('Chance in Each Correlation over Experience ARMS first half')

figure('Position',[288 37 1521 849]);
for pvtI = 1:length(pvNames)
    ggt{pvtI} = subplot(2,3,pvtI);
    [ggt{pvtI},statsOut] = PlotChangeByDaysApartFWDonly(withinCSdayChangeMeanHalfSecondARM{pvtI},sameDayDayDiffsPooled{pvtI},condSetColors,condSetLabels,ggt{pvtI});
    ggt{pvtI}.Title.String = [pvNames{pvtI}; ggt{pvtI}.Title.String];
end
suptitleSL('Chance in Each Correlation over Experience ARMS second half')
%% PV corr separation by days apart ARMS

cscColors = {'m'; 'c'; 'k'};%[0.8 0.2 0]
figure('Position',[288 37 1521 849]);
for pvtI = 1:length(pvNames)
    ggt{pvtI} = subplot(2,3,pvtI);
    [ggt{pvtI},statsOut] = PlotChangeByDaysApartFWDonly(cscDiffsChangeMeanPooledARM{pvtI},sameDayDayDiffsPooled{pvtI},cscColors,cscLabels,ggt{pvtI});
    ggt{pvtI}.Title.String = [pvNames{pvtI}; ggt{pvtI}.Title.String];
end
suptitleSL('Change in Separation between Correlations ARMS')

cscColors = {'m'; 'c'; 'k'};%[0.8 0.2 0]
figure('Position',[288 37 1521 849]);
for pvtI = 1:length(pvNames)
    ggt{pvtI} = subplot(2,3,pvtI);
    [ggt{pvtI},statsOut] = PlotChangeByDaysApartFWDonly(cscDiffsChangeMeanHalfFirstPooledARM{pvtI},sameDayDayDiffsPooled{pvtI},cscColors,cscLabels,ggt{pvtI});
    ggt{pvtI}.Title.String = [pvNames{pvtI}; ggt{pvtI}.Title.String];
end
suptitleSL('Change in Separation between Correlations ARMS First Half')

cscColors = {'m'; 'c'; 'k'};%[0.8 0.2 0]
figure('Position',[288 37 1521 849]);
for pvtI = 1:length(pvNames)
    ggt{pvtI} = subplot(2,3,pvtI);
    [ggt{pvtI},statsOut] = PlotChangeByDaysApartFWDonly(cscDiffsChangeMeanHalfSecondPooledARM{pvtI},sameDayDayDiffsPooled{pvtI},cscColors,cscLabels,ggt{pvtI});
    ggt{pvtI}.Title.String = [pvNames{pvtI}; ggt{pvtI}.Title.String];
end
suptitleSL('Change in Separation between Correlations ARMS Second Half')

%% Stem vs Arms

statsOut = [];
for condI = 1:length(condSet)
[figHand, statsOut{condI}] = PVcorrCompStemVsArmDaysApart(CSpooledMeanPVcorrs,CSpooledMeanPVcorrsARM,CSpooledPVdaysApart,pvNames,condI);
suptitleSL(['Difference between Stem (l) and ARM (r) corrs in ' condSetLabels{condI}])
end


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
            


    