%% Plot rasters for all good cells
%Works, but probably don't accidentally run this
%{
for mouseI = 1:numMice
    saveDir = fullfile(mainFolder,mice{mouseI});
    cellsUse = find(sum(dayUse{mouseI},2)>0);
    PlotRastersPDF(cellTBT{mouseI}, cellSSI{mouseI}, cellAllFiles{mouseI}, cellsUse, saveDir, mice{mouseI});
end
%}

%% Accuracy

figure('Position',[662 264 650 417]); 
for mouseI = 1:numMice; plot(cellRealDays{mouseI},accuracy{mouseI},'LineWidth',2); hold on; end
xlabel('Recording Day #')
ylabel('Performance')
ylim([0.5 1])
plot([2 22],[0.7 0.7],'--','Color',[0.6 0.6 0.6],'LineWidth',2)
title('Performance of Individual Mice')


mouseColors = [0    0.4510    0.7412; 0.8510    0.3294    0.1020; 0.4706    0.6706    0.1882; 0.9294    0.6902    0.1294];
figure('Position',[662 264 650 417]); 
plot([0 22],[0.7 0.7],'--','Color',[0.6 0.6 0.6],'LineWidth',2)
hold on; 
for mouseI = 1:numMice; minss(mouseI) = min(allDaysAccuracy{mouseI}(:,1)); end
minShift = min(minss)-1;
for mouseI = 1:numMice 
    hereAcc = allDaysAccuracy{mouseI}; hereAcc(:,1) = hereAcc(:,1)-minShift;
    plot(hereAcc(:,1),hereAcc(:,2),'Color',mouseColors(mouseI,:),'LineWidth',1.5);     
    belowThresh = hereAcc(:,2) < performanceThreshold;
    plot(hereAcc(belowThresh==0,1),hereAcc(belowThresh==0,2),'o','Color',mouseColors(mouseI,:));
    plot(hereAcc(belowThresh,1),hereAcc(belowThresh,2),'*r')
end
xlabel('Recording Day #')
ylabel('Performance')
ylim([0.4 1.025])
xlim([0.75 20.25])
title('Performance of Individual Mice')

%% Example cell plots

%Stable: 
stableSplitter = {[43 44];[4];[293];20};
splitterBecomingBoth = {[ ];[ ];[ ];[65 97]};
randomFiringCell = {[];[4 176 184];267;[]};
cellComing = {[];[];267;[]};
cellLeaving = {[242];[];359;[]};
toBoth = {[14 180];[];[230];[]};

splittersPlot = randomFiringCell;
for mouseI = 1:numMice
    if any(splittersPlot{mouseI})
        load(fullfile(mouseDefaultFolder{mouseI},'daybyday.mat'))
        for cellI = 1:length(splittersPlot{mouseI})
            cellPlot = splittersPlot{mouseI}(cellI);
            presentDays = find(cellSSI{mouseI}(cellPlot,:)>0);
            [figg] = PlotSplittingDotPlot(daybyday,cellTBT{mouseI},cellPlot,presentDays,'stem','line');
            %cellOutLinePlot...
        end
    end
end

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

%% New cells/lost cells






%%
compsMake = {[1 2];[3 5];[4 5]};
tgsPlot = unique([compsMake{:}]);
tgsPlot = [3 4 5];

colorAsscAlt = colorAssc;
colorAsscAlt{3} = colorAssc{1};
colorAsscAlt{4} = colorAssc{2};
colorAsscAlt{8} = [0.6 0.6 0.6];
traitLabelsAlt = traitLabels; traitLabelsAlt{3} = traitLabels{1}; traitLabelsAlt{4} = traitLabels{2}; 
%% Proportion of each splitter type
hh = figure('Position',[477 83 324 803]);%[593 58 651 803]
axHand = []; statsOut = [];
compsMakeHere = {[1 2];[2 3];[1 3];[3 4];[2 4];[1 4]};
for slI = 1:2
    axHand{slI} = subplot(2,1,slI);
    [axHand{slI},statsOut{slI}] = PlotTraitProps(pooledSplitProp{slI},[3 4 5 8],compsMakeHere,colorAsscAlt,traitLabels,axHand{slI});
    title(['Splitter Proportions on ' upper(splitterLoc{slI})])
end
suptitleSL('Proportions of Splitter Cells on Central Stem and Return Arms')

%Stats text figure
figure('Position',[680 558 1055 420]); 
for slI = 1:2
    subplot(2,1,slI)
    text(1,1,'comparisons:'); text(3,0.5,num2str(statsOut{slI}.comparisons'))
    text(1,1.5,'sign test p'); text(3,1.5,num2str(statsOut{slI}.pPropDiffs))
    text(1,2,'KS ANOVA p tukey'); text(4,2,num2str(statsOut{slI}.ksANOVA.multComps(:,6)'))
    text(1,2.5,['KS ANOVA: Chi-sq    ' num2str(statsOut{slI}.ksANOVA.tbl{2,5})]) 
    text(1,3,['KS ANOVA: df groups, error, total    ' num2str([statsOut{slI}.ksANOVA.tbl{2:end,3}])])
       
    xlim([0 12]); ylim([0 5])
    title(['Stats for splitter proportions on ' splitterLoc{slI}])
end


%sign test stem vs. arms
for tgI = 1:numTraitGroups
    splitPropDiffs{tgI} = pooledSplitProp{1}{tgI} - pooledSplitProp{2}{tgI};
    [pSplitPropDiffs(tgI),hSplitPropDiffs(tgI)] = signtest(splitPropDiffs{tgI}); %h = 1 reject (different)
end

%% Change in Proportion of Each splitter type by days apart
changesPlot =[3 4 5 8];
gh = [];
statsOut = [];
for slI = 1:2
    gh{slI} = figure('Position',[593 316 660 458]);%[435 278 988 390][593 273 559 501]
    [gh{slI},statsOut{slI}] = PlotTraitChangeOverDays(pooledSplitNumChange{slI},pooledRealDayDiffs,...
        {changesPlot},colorAsscAlt,traitLabels,gh{slI},true,'regress',[-0.6 0.4],'pct Change'); %Num in this case is diff in Pcts.
    suptitleSL(['Change in Proportion of Splitters on ' splitterLoc{slI}])
end
for slI = 1:2
    figure('Position',[680 558 730 420]);
    for lineI = 1:length(changesPlot)
        tl = changesPlot(lineI);
        
        text(1,lineI,['F test eqal var ' num2str(changesPlot(lineI))...
            ': F= ' num2str(statsOut{slI}.slopeDiffZero(tl).Fval) ' df num/den = '...
            num2str(statsOut{slI}.slopeDiffZero(tl).dfNum) ' / ' num2str(statsOut{slI}.slopeDiffZero(tl).dfDen)...
            ', p= ' num2str(statsOut{slI}.slopeDiffZero(tl).pVal)...
            ', rr= ' num2str(statsOut{slI}.slopeRR(tl).Ordinary)])
    end
    xlim([0 15]); ylim([0 5])
    title(['stats for splitter prop changes on ' splitterLoc{slI}])
end

%% Prop of splitters that come back
tgsPlot = [1 2 5];
gh = [];
statsOut = [];
for slI = 1:2
    gh{slI} = figure('Position',[360 169 435 444]);
    [gh{slI},statsOut{slI}] = PlotTraitChangeOverDays(pooledSplitterComesBack{slI},pooledRealDayDiffs,...
        tgsPlot,colorAssc,traitLabels,gh{slI},true,'mean',[0 0.8],'pct. Cells Return'); %Num in this case is diff in Pcts.
    suptitleSL(['Change in Proportion of Splitters that Come Back on ' splitterLoc{slI}])
end
for slI = 1:2
    figure('Position',[680 558 730 420]);
    for lineI = 1:length(tgsPlot)
        text(1,lineI,['comparison lines ' num2str(statsOut{slI}.comps{1}(lineI,:))...
            ', num day lags diff sign test: ' num2str(sum([statsOut{slI}.signtests{1}(lineI).pVal]<0.05))])
    end
    xlim([0 15]); ylim([0 5])
    title(['stats for splitter reactivation by day lag on ' splitterLoc{slI}])
end

% Old
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

tgsPlot = [1 2 5];
eachDayDiffs = unique(pooledRealDayDiffs);
jk = [];
for slI = 1:2
    jk{slI} = figure;
    hold on
    for tgI = 1:length(tgsPlot)
        for ddI = 1:length(eachDayDiffs)
            splitterCBmean{tgI}(ddI) = mean(pooledSplitterComesBack{slI}{tgsPlot(tgI)}(pooledRealDayDiffs==eachDayDiffs(ddI)));
            splitterSSmean{tgI}(ddI) = mean(pooledSplitterStillSplitter{slI}{tgsPlot(tgI)}(pooledRealDayDiffs==eachDayDiffs(ddI)));
        end
        
        plot(eachDayDiffs,splitterCBmean{tgI},'Color',colorAsscAlt{tgsPlot(tgI)},'LineWidth',2,'DisplayName',[traitLabelsAlt{tgsPlot(tgI)} ' return'])
        plot(eachDayDiffs,splitterSSmean{tgI},'--','Color',colorAsscAlt{tgsPlot(tgI)},'LineWidth',2,'DisplayName',[traitLabelsAlt{tgsPlot(tgI)} ' still split'])
        
    end
    legend('location','northeast')
    title(['Likelihood of reactivation and continued splitting on ' mazeLocations{slI}])
    xlabel('Day lag')
    ylabel('Pct. returning')
    ylim([0 0.6])
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

plotHere = [1 2 5];
hj = [];
for slI = 1:2
    hj{slI} = figure;
    subplot(1,2,1)
    for tgI = 1:length(plotHere)
        [fitVal,daysPlot] = FitLineForPlotting(pooledSplitterComesBack{slI}{plotHere(tgI)},pooledRealDayDiffs);
        plot(daysPlot,fitVal,'Color',colorAssc{plotHere(tgI)},'LineWidth',2);
        hold on
    end
    ylim([0.15 0.55])
    xlim([0.5 max(pooledRealDayDiffs)+0.5])
    xlabel('Day Lag')
    ylabel('Percent returning')
    subplot(1,2,2)
    for tgI = 1:length(plotHere)
        [fitVal,daysPlot] = FitLineForPlotting(pooledSplitterStillSplitterNorm{slI}{plotHere(tgI)},pooledRealDayDiffs);
        plot(daysPlot,fitVal,'Color',colorAssc{plotHere(tgI)},'LineWidth',2);%'--',
        hold on
    end
    ylim([0.5 1])
    xlim([0.5 max(pooledRealDayDiffs)+0.5])
    xlabel('Day Lag')
    ylabel('Percent still split')
    title(['Pct of splitters reactivating (solid) and of those still splitting (dashed) on ' splitterLoc{slI}])
end




%Stem vs. arm
jk = figure;
statsOut = [];
[jk,statsOut] = PlotTraitChangeOverDaysSTEMvsARM(pooledSplitterStillSplitter{1},pooledRealDayDiffs,pooledSplitterStillSplitter{2},...
    pooledRealDayDiffs,colorAssc,traitLabels,jk,[0 1],'% Cells That Still Split');

%% Splitters changing type

fh = []; statsOut = [];
for slI = 1:2
    figure; fh{slI} = axes;
    [fh{slI},statsOut{slI}] = PlotTraitProps(cellTransProps{slI},[],[],colorAssc,transLabels,fh{slI}); 
    title(['Daily likelihood of changing splitter type on ' mazeLocations{slI}])
    ylabel('Likelihood')
end

gj = [];
statsOut = [];
transChangesPlot = 1:length(cellTransPropChanges{slI});
transColors = colorAssc(transChangesPlot);
for slI = 1:2
    gj{slI} = figure;%('Position',[258 350 1542 459]);
    [gj{slI},statsOut{slI}]=PlotTraitChangeOverDays(cellTransPropChanges{slI},sourceDayDiffsPooled{slI},...
        transChangesPlot,transColors,transLabels,gj{slI},true,'regress',[-0.6 0.6],'pct. Change Transition Probability');
    suptitleSL(['Transition likelihoods on ' splitterLoc{slI}])
end

for slI = 1:2
    figure('Position',[680 558 730 420]);
    for lineI = 1:length(transChangesPlot)
        tl = transChangesPlot(lineI);
        text(1,lineI,['F test eqal var ' num2str(transChangesPlot(lineI))...
            ': F= ' num2str(statsOut{slI}.slopeDiffZero(tl).Fval) ' df num/den = '...
            num2str(statsOut{slI}.slopeDiffZero(tl).dfNum) ' / ' num2str(statsOut{slI}.slopeDiffZero(tl).dfDen)...
            ', p= ' num2str(statsOut{slI}.slopeDiffZero(tl).pVal)...
            ', rr= ' num2str(statsOut{slI}.slopeRR(tl).Ordinary)])
    end
    
    xlim([0 15]); ylim([0 8])
    title(['stats for splitter prop changes on ' splitterLoc{slI}])
end
%{
gj = [];
statsOut = [];
transColors = colorAssc([1 2 5 1 2 5 1 2 5]);
for slI = 1:2
    gj{slI} = figure;%('Position',[258 350 1542 459]);
    [gj{slI},statsOut{slI}]=PlotTraitChangeOverDays(cellTransPropChanges{slI},sourceDayDiffsPooled{slI},...
        {1:3;4:6;7:9},transColors,transLabels,gj{slI},true,'regress',[-0.75 0.75],'pct. Change Transition Probability');
    suptitleSL(['Transition likelihoods on ' splitterLoc{slI}])
end
%}
%% What are new cells?
fg = [];
statsOut = [];
figure('Position',[477 83 324 803]);
for slI = 1:2
    fg{slI} = subplot(2,1,slI);
    % fg{slI} = axes;
    [fg{slI}, statsOut{slI}] = PlotTraitProps(pooledNewCellProps{slI},[3 4 5 8],{[2 3];[1 3];[3 4];[2 4];[1 4]},colorAsscAlt,traitLabels,fg{slI}); 
    ylabel('Proportion of New Cells')
    title(['Proportion of new cells that go to each type on ' mazeLocations{slI}])
end

%Stats text figure
figure('Position',[680 558 1055 420]); 
for slI = 1:2
    subplot(2,1,slI)
    text(1,1,'comparisons:'); text(3,0.5,num2str(statsOut{slI}.comparisons'))
    text(1,1.5,'sign test p'); text(3,1.5,num2str(statsOut{slI}.pPropDiffs))
    text(1,2,'KS ANOVA p tukey'); text(4,2,num2str(statsOut{slI}.ksANOVA.multComps(:,6)'))
    text(1,2.5,['KS ANOVA: Chi-sq    ' num2str(statsOut{slI}.ksANOVA.tbl{2,5})]) 
    text(1,3,['KS ANOVA: df groups, error, total    ' num2str([statsOut{slI}.ksANOVA.tbl{2:end,3}])])
       
    xlim([0 12]); ylim([0 5])
    title(['Stats for new cell proportions on ' splitterLoc{slI}])
end



gh = [];
statsOut = [];
for slI = 1:2
    gh{slI} = figure;%('Position',[435 278 988 390]);
    [gh{slI},statsOut{slI}] = PlotTraitChangeOverDays(pooledNewCellPropChanges{slI},sourceDayDiffsPooled{slI},...
        [3 4 5 8],colorAsscAlt,traitLabels,gh{slI},true,'regress',[-0.75 0.4],'Change in Pct. New Cells this Type'); %Num in this case is diff in Pcts.
    %(pooledTraitChanges,pooledDaysApart,comparisons,colorsUse,labels,figHand,plotDots,lineType,ylims,yLabel)

    suptitleSL(['Change in Proportion of New Cells that are a splitting type ' splitterLoc{slI}])
end
for slI = 1:2
    figure('Position',[593 316 660 458]);%[680 558 730 420]
    for lineI = 1:length(changesPlot)
        tl = changesPlot(lineI);
        
        text(1,lineI,['F test eqal var ' num2str(changesPlot(lineI))...
            ': F= ' num2str(statsOut{slI}.slopeDiffZero(tl).Fval) ' df num/den = '...
            num2str(statsOut{slI}.slopeDiffZero(tl).dfNum) ' / ' num2str(statsOut{slI}.slopeDiffZero(tl).dfDen)...
            ', p= ' num2str(statsOut{slI}.slopeDiffZero(tl).pVal)...
            ', rr= ' num2str(statsOut{slI}.slopeRR(tl).Ordinary)])
    end
    xlim([0 15]); ylim([0 5])
    title(['stats for splitter prop changes on ' splitterLoc{slI}])
end

%{
%% What are new cells?
fg = [];
statsOut = [];
for slI = 1:2
    figure; fg{slI} = axes;
    [fg{slI}, statsOut{slI}] = PlotTraitProps(newCellProps{slI},[],[],colorAssc,{'LR','ST','BOTH'},fg{slI});
    title(['Daily distribution of new cells among splitter types on ' mazeLocations{slI}])
    ylabel('Pct. of new cells')
end

statsOut = [];
for slI = 1:2
    sd{slI} = figure;
    [sd{slI},statsOut{slI}]=PlotTraitChangeOverDays(newCellPropChanges{slI},sourceDayDiffsPooled{slI},...
        1:length(newCellPropChanges{slI}),...
        colorAssc,{'LR','ST','BOTH'},sd{slI},true,'regress',[-1 1],'Change in pct. new cells');
end
%}

%% Cell type sources bargraph

c = categorical({'Turn','Phase','Conjunctive'});
statsOut = [];
for slI = 1:2
    figure; 
    for tcI = 1:length(cellCheck)
        subplot(1,length(cellCheck),tcI)
        [statsOut{slI}{tcI}] = PlotBarWithData([pooledDailySources{slI}{tcI}{:}],sourceColors,true,false,sourceLabels);
        title(['Sources for ' traitLabels{cellCheck(tcI)}])
        ylabel('Pct. of cells')
    end
    suptitleSL(['Sources for each type on ' mazeLocations{slI}])
end

for slI = 1:2
    figure('Position',[257 92 1551 750]); 
    for ccI = 1:length(cellCheck)
        subplot(length(cellCheck),1,ccI)
        text(1,1,'comparisons:'); text(3,0.5,num2str(statsOut{slI}{ccI}.signtest.comparisons'))
        text(1,1.5,'sign test p'); text(3,1.5,num2str(statsOut{slI}{ccI}.signtest.pVal))
        text(1,2,'KS ANOVA p tukey'); text(4,2,num2str(statsOut{slI}{ccI}.ksANOVA.multComps(:,6)'))
        text(1,2.5,['KS ANOVA: Chi-sq    ' num2str(statsOut{slI}{ccI}.ksANOVA.tbl{2,5})]) 
        text(1,3,['KS ANOVA: df groups, error, total    ' num2str([statsOut{slI}{ccI}.ksANOVA.tbl{2:end,3}])])
        text(1,4,'KS ANOVA: groups :'); text(3,4,num2str(statsOut{slI}{ccI}.ksANOVA.multComps(:,1:2)'),'VerticalAlignment','middle')

        xlim([0 12]); ylim([0 5])
        title(['Stats for splitter sources for ' traitLabels{cellCheck(ccI)} ' on ' splitterLoc{slI}])
    end
end

%Changes 
ff = []; statsOut = [];
compsHere = {[1:5];[6:10];[11:15]};
allColors = [sourceColors;sourceColors;sourceColors];
allColors = mat2cell(allColors,ones(15,1),3);
allLabels = {sourceLabels{:}, sourceLabels{:}, sourceLabels{:}};
for slI = 1:2
    allSourceChanges = [pooledSourceChanges{slI}{:}]; allSourceChanges = allSourceChanges(:);
    ff{slI} = figure;
    [ff{slI},statsOut{slI}] = PlotTraitChangeOverDays(allSourceChanges,sourceDayDiffsPooled{slI},compsHere,...
        allColors,allLabels,ff{slI},true,'regress',[-1 1],'Change in sources');
    suptitleSL(['Change in sources for each type on ' mazeLocations{slI}])
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


%D-prime sensitivity index
%Stem
[jj,statsOut] = PlotPVcurvesDiff(CSpooledPVcorrs{cellCritUse},CSpooledPVdaysApart{cellCritUse},condSetColors,condSetLabels,[]);
title(['Within-Day Sensitivity Index STEM (' pvNames{cellCritUse} ')'])
ylim([0 4.5])
%Arms
[jj,statsOut] = PlotPVcurvesDiff(CSpooledPVcorrsARM{cellCritUse},CSpooledPVdaysApart{cellCritUse},condSetColors,condSetLabels,[]);
title(['Within-Day Sensitivity Index ARM (' pvNames{cellCritUse} ')'])
ylim([0 7])

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

%% Center-of-mass

figure; histogram(pooledCOMlrEx,1:0.5:8,'FaceColor',[0.8510    0.3294    0.1020])
hold on
histogram(pooledCOMstEx,1:0.5:8,'FaceColor',[0    0.4510    0.7412])
plot([1 1]*mean(pooledCOMlrEx),[0 200],'--r','LineWidth',2)
plot([1 1]*mean(pooledCOMstEx),[0 200],'--b','LineWidth',2)
title('STEM COM distributions (exclusive, no both), r = lr b = st')
xlim([1 8])
ylabel('Number of cells')
yyaxis right
[f,x] = ecdf(pooledCOMlrRx);
plot(x,f,'-','Color','r','LineWidth',2)
[f,x] = ecdf(pooledCOMstEx);
plot(x,f,'-','Color','b','LineWidth',2)
ylabel('Cumulative portion')
xlabel('All trials Firing COM')
[statsOut.ranksum.pVal,statsOut.ranksum.hVal] = ranksum(pooledCOMlrEx,pooledCOMstEx);
[statsOut.ksTest.hVal,statsOut.ksTest.pVal] = kstest2(pooledCOMlrEx,pooledCOMstEx);


figure; histogram(pooledCOMlrARMex,1:0.5:8,'FaceColor',[0.8510    0.3294    0.1020])
hold on
histogram(pooledCOMstARMex,1:0.5:8,'FaceColor',[0    0.4510    0.7412])
plot([1 1]*mean(pooledCOMlrARMex),[0 450],'--r','LineWidth',2)
plot([1 1]*mean(pooledCOMstARMex),[0 450],'--b','LineWidth',2)
title('ARM COM distributions (exclusive, no both), r = lr b = st')
xlim([1 8])
ylabel('Number of cells')
yyaxis right
[f,x] = ecdf(pooledCOMlrARMex);
plot(x,f,'-','Color','r','LineWidth',2)
[f,x] = ecdf(pooledCOMstARMex);
plot(x,f,'-','Color','b','LineWidth',2)
ylabel('Cumulative portion')
xlabel('All trials Firing COM')

[statsOut.ranksum.pVal,statsOut.ranksum.hVal] = ranksum(pooledCOMlrARMex,pooledCOMstARMex);
[statsOut.ksTest.hVal,statsOut.ksTest.pVal] = kstest2(pooledCOMlrARMex,pooledCOMstARMex);
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

colors = {colorAssc{1} colorAssc{2}};
axH = []; statsOut = [];
for slI = 1:2
    figure('Position',[725 217 340 406]); axH = axes;
    [axH,statsOut] = PlotTraitProps({decodingResultsPooled{slI}{2}{1}(sessDayDiffs{slI}{2}{1}==0) decodingResultsPooled{slI}{2}{2}(sessDayDiffs{slI}{2}{2}==0)},...
        [1 2],[1 2],colors,{'Traj. Dest.','Task Phase'},axH);
    hold on
    plot([0 3],[0.5 0.5],'--','Color',[0.6 0.6 0.6],'LineWidth',2)
    title(['Within Day Decoding on ' decodeLoc{slI} ', thresh cells'])
    ylabel('% Trials Decoded Correct')
end

%{
for slI = 1:2
    colors{1} = {colorAssc{1} colorAssc{2}}; colors{2} = {colorAssc{1} colorAssc{2}};
    [axH,statsOut]=PlotWithinDayDecoding(decodingResultsPooled{slI},shuffledResultsPooled{slI},sessDayDiffs{slI},...
        {'all','thresh'},{'LR','ST'},colors);
    title(['Within-Day Decoding on ' decodeLoc{slI}])
end
%}
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

%Reg vs. Downsampled
dimCols = {[0.6392 0.0784 0.1804;1 0 0];[ 0 1 1;0 0 1]};
decDim = {'Traj. Dest.','Task Phase'};
lineType = {{'-','--'},{'-','--'}};
transHere = {[0.6 1];[0.6 1]};
dtI = 2
statsOut = [];
asd = figure('Position',[373 137 482 766]);%[723 305 574 461]
axH = [];
for slI = 1:length(decodeLoc)
    axInd = slI;
    axH(axInd) = subplot(length(decodeLoc),1,axInd);
for ddI = 1:2%decoding Dimension
    [axH(axInd), statsOut{slI}{ddI}] = PlotDecodingOneVSother3(...
                                {decodingResultsPooled{slI}{dtI}{ddI} downsampledResultsPooled{slI}{dtI}{ddI}},...
                                {shuffledResultsPooled{slI}{dtI}{ddI} shuffledResultsPooled{slI}{dtI}{ddI}},...
                                {decodedWellPooled{slI}{dtI}{ddI} DSaboveShuffPpooled{slI}{dtI}{ddI}},...
                                sessDayDiffs{slI}{dtI}{ddI},sessDayDiffs{slI}{dtI}{ddI},[],lineType{ddI},transHere{ddI},dimCols{ddI},axH(axInd));
    title(['Decoding comparison, reg. vs. DS, decoding Cells on ' decodeLoc{slI} ])
end
end
asd.Renderer = 'painters';
suptitleSL(['Decoding with ' decodingType{dtI} ', solid = REG, dotted = DS, r = lr b = st'])


%LvR vs. SvT comparison
statsOut = [];
asd = figure('Position',[373 137 482 766]);%[723 305 574 461]
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
    title(['Decoding Comparison ' decodeLoc{slI} ',r=lr b=st'])
end
end
asd.Renderer = 'painters';
suptitleSL('Transparent = all cells, dotted = above thresh')

%Downsampled
%LR vs. ST
statsOut = [];
asd = figure('Position',[373 137 482 766]);%[723 305 574 461]
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
                                DSaboveShuffPpooled{slI}{dtI},sessDayDiffs{slI}{dtI}{1},sessDayDiffs{slI}{dtI}{1},...
                                 [],lineType{dtI},transHere{dtI},[1 0 0; 0 0 1],axH(axInd));
    title(['Decoding Comparison, Downsampled cells on ' decodeLoc{slI} ',r=lr b=st'])
end
end
asd.Renderer = 'painters';
suptitleSL('Solid = all cells, dotted = thresh')


%Stem vs. Arm
decDim = {'Traj. Dest.','Task Phase'};
statsOut = [];
asd = figure('Position',[373 137 482 766]);%[723 305 574 461]
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
asd.Renderer = 'painters';
suptitleSL('Transparent = LR, dotted = ST')


%Within dimension, which cell inclusion is better?
dimCols = {[0.6392 0.0784 0.1804;1 0 0];[ 0 1 1;0 0 1]};
decDim = {'Traj. Dest.','Task Phase'};
statsOut = [];
asd = figure('Position',[373 137 482 766]);%[723 305 574 461]
axH = [];
lineType = {{'-','--'},{'-','--'}};
transHere = {[0.6 1];[0.6 1]};
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
      title(['Decoding Cell Inclusion Comparison, on ' decodeLoc{slI} ', solid=all dotted=thresh'])
end
end
asd.Renderer = 'painters';
suptitleSL('Red = LR, Blue = ST')



%Redo here - something needs to be organized differently, may require
%reorganizing all
%RegVsDownsampled
dimCols = {[0.6392 0.0784 0.1804;1 0 0];[ 0 1 1;0 0 1]};
decDim = {'Traj. Dest.','Task Phase'};
lineType = {{'-','--'},{'-','--'}};
transHere = {[0.6 1];[0.6 1]};
for dtI = 1:length(decodingType)
statsOut = [];
asd = figure('Position',[373 137 482 766]);%[723 305 574 461]
axH = [];
for slI = 1:length(decodeLoc)
for ddI = 1:2%decoding Dimension
    %axInd = ddI+length(decodeLoc)*(slI-1);
    %axH(axInd) = subplot(length(decodeLoc),2,axInd);
    axInd = slI;
    axH(axInd) = subplot(length(decodeLoc),1,axInd);
    
    [axH(axInd), statsOut{slI}{ddI}] = PlotDecodingOneVSother3(...
                                {decodingResultsPooled{slI}{dtI}{ddI} downsampledResultsPooled{slI}{dtI}{ddI}},...
                                {shuffledResultsPooled{slI}{dtI}{ddI} shuffledResultsPooled{slI}{dtI}{ddI}},...
                                {decodedWellPooled{slI}{dtI}{ddI} DSaboveShuffPpooled{slI}{dtI}{ddI}},...
                                sessDayDiffs{slI}{dtI}{ddI},sessDayDiffs{slI}{dtI}{ddI},[],lineType{ddI},transHere{ddI},dimCols{ddI},axH(axInd));
    title(['Decoding comparison, reg. vs. DS, decoding Cells on ' decodeLoc{slI} ])
end
end
asd.Renderer = 'painters';
suptitleSL(['Decoding with ' decodingType{dtI} ', solid = REG, dotted = DS, r = lr b = st'])
end
            

%% Within day d-prime sensitivity index
cellCritUse = 5;
limsHere = [0 4.5; 0 7];
jj = []; statsOut = [];
for slI = 1:2
    [jj{slI},statsOut{slI}] = PlotPVcurvesDiff(CSpooledPVcorrs{slI}{cellCritUse},CSpooledPVdaysApart{slI}{cellCritUse},...
        condSetColors,condSetLabels,false,[]);
    title(['Within-Day Sensitivity Index (dPrime) ' upper(mazeLocations{slI}) ' (' pvNames{cellCritUse} ')'])
    ylim(limsHere(slI,:))
end

cellCritUse = 5;
limsHere = [0 4.5; 0 7];
jj = []; statsOut = [];
for slI = 1:2
    [jj{slI},statsOut{slI}] = PlotPVcurvesDPrime(CSpooledPVcorrs{slI}{cellCritUse},CSpooledPVdaysApart{slI}{cellCritUse},...
        condSetColors,condSetLabels,[]);
    title(['Within-Day Sensitivity Index (dPrime) ' upper(mazeLocations{slI}) ' (' pvNames{cellCritUse} ')'])
    ylim(limsHere(slI,:))
end
for slI = 1:2
    figure;
    text(1,1,['sensitivity index perm test, ' condSetLabels{2} ', p: ' num2str([statsOut{slI}.permTest.pVal(1,:)])])
    text(1,2,['sensitivity index perm test, ' condSetLabels{3} ', p: ' num2str([statsOut{slI}.permTest.pVal(2,:)])])
    xlim([0 12]); ylim([0 4])
    title(['Stats for d-prime pv corrs within day on ' mazeLocations{slI}])
end

    %% Population D-prime sensitivity index by days apart
cellCritUse = 5;
statsOut = [];
dr = [];
for slI = 1:2
    figure('Position',[317 403 1448 417]);
    
    dr{slI}{1} = subplot(1,3,1);
    [dr{slI}{1}, statsOut{slI}{1}] = PlotMeanPVcorrsDiffDaysApart(CSpooledMeanPVcorrs{slI}{cellCritUse}, CSpooledPVdaysApart{slI}{cellCritUse},...
        condSetColors, condSetLabels, dr{slI}{1});
    title('Sensitivity Index by Days Apart, mean all bins')
    
    dr{slI}{2} = subplot(1,3,2);
    [dr{slI}{2}, statsOut{slI}{2}] = PlotMeanPVcorrsDiffDaysApart(CSpooledMeanPVcorrsHalfFirst{slI}{cellCritUse}, CSpooledPVdaysApart{slI}{cellCritUse},...
        condSetColors, condSetLabels, dr{slI}{2});
    title('Sensitivity Index by Days Apart, mean 1st 2 bins')
    
    dr{slI}{3} = subplot(1,3,3);
    [dr{slI}{3}, statsOut{slI}{3}] = PlotMeanPVcorrsDiffDaysApart(CSpooledMeanPVcorrsHalfSecond{slI}{cellCritUse}, CSpooledPVdaysApart{slI}{cellCritUse},...
        condSetColors, condSetLabels, dr{slI}{3});
    title('Sensitivity Index by Days Apart, mean Last 2 bins')
    
    suptitleSL(upper(mazeLocations{slI}))
end
%Stats text
for slI = 1:2
    figure('Position',[411 89 661 844]);
    subplot(3,1,1);
    text(1,1,[condSetLabels{2} ' vs VSelf pVal: ' num2str(statsOut{slI}{1}.reg.pVal{1})])
    text(1,2,[condSetLabels{3} ' vs VSelf pVal: ' num2str(statsOut{slI}{1}.reg.pVal{2})])
    text(1,3,[condSetLabels{statsOut{1}{1}.comp.comparisons(1)} ' vs ' condSetLabels{statsOut{1}{1}.comp.comparisons(2)}...
        ' pVal: ' num2str(statsOut{slI}{1}.comp.pVal{1})])
    xlim([0 12]); ylim([0 4]); title('Sensitivity index stats on all bins')
    
    subplot(3,1,2);
    text(1,1,[condSetLabels{2} ' vs VSelf pVal: ' num2str(statsOut{slI}{2}.reg.pVal{1})])
    text(1,2,[condSetLabels{3} ' vs VSelf pVal: ' num2str(statsOut{slI}{2}.reg.pVal{2})])
    text(1,3,[condSetLabels{statsOut{1}{2}.comp.comparisons(1)} ' vs ' condSetLabels{statsOut{1}{2}.comp.comparisons(2)}...
        ' pVal: ' num2str(statsOut{slI}{2}.comp.pVal{1})])
    xlim([0 12]); ylim([0 4]); title('Sensitivity index stats on 1st 2 bins')
    
    subplot(3,1,3);
    text(1,1,[condSetLabels{2} ' vs VSelf pVal: ' num2str(statsOut{slI}{3}.reg.pVal{1})])
    text(1,2,[condSetLabels{3} ' vs VSelf pVal: ' num2str(statsOut{slI}{3}.reg.pVal{2})])
    text(1,3,[condSetLabels{statsOut{1}{3}.comp.comparisons(1)} ' vs ' condSetLabels{statsOut{1}{3}.comp.comparisons(2)}...
        ' pVal: ' num2str(statsOut{slI}{3}.comp.pVal{1})])
    xlim([0 12]); ylim([0 4]); title('Sensitivity index stats on Last 2 bins')
    
    suptitleSL(upper(mazeLocations{slI}))
end



%% PV corr by days apart
%{
cellCritUse = 5;
statsOut = []; gg = []; 
for slI = 1:2
    figure('Position',[317 403 1448 417]);
    
    gg{slI}{1} = subplot(1,3,1);
    [gg{slI}{1}, statsOut{slI}{1}] = PlotMeanPVcorrsDaysApart(CSpooledMeanPVcorrs{slI}{cellCritUse}, CSpooledPVdaysApart{slI}{cellCritUse},...
        'none', condSetColors, condSetLabels, false, gg{slI}{1});
    gg{slI}{1}.Title.String = ['Mean All Bins (' pvNames{cellCritUse} ')'];
    ylim([-0.1 1])
    
    gg{slI}{2} = subplot(1,3,2);
    [gg{slI}{2}, statsOut{slI}{2}] = PlotMeanPVcorrsDaysApart(CSpooledMeanPVcorrsHalfFirst{slI}{cellCritUse}, CSpooledPVdaysApart{slI}{cellCritUse},...
        'none', condSetColors, condSetLabels, false, gg{slI}{2});
    gg{slI}{2}.Title.String = ['Mean 1st 2 bins (' pvNames{cellCritUse} ')'];
    ylim([-0.1 1])

    gg{slI}{3} = subplot(1,3,3);
    [gg{slI}{3}, statsOut{slI}{3}] = PlotMeanPVcorrsDaysApart(CSpooledMeanPVcorrsHalfSecond{slI}{cellCritUse}, CSpooledPVdaysApart{slI}{cellCritUse},...
    'none', condSetColors, condSetLabels, false, gg{slI}{3});
    ylim([-0.1 1])
    gg{3}.Title.String = ['Mean Last 2 bins (' pvNames{cellCritUse} ')'];
    suptitleSL(['Mean correlation by days apart ' mazeLocations{slI}])
end
%}