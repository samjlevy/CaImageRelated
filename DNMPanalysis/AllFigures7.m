%% Plot rasters for all good cells
%Works, but probably don't accidentally run this
%{
for mouseI = 1:numMice
    saveDir = fullfile(mainFolder,mice{mouseI});
    cellsUse = find(sum(dayUse{mouseI},2)>0);
    PlotRastersPDF(cellTBT{mouseI}, cellSSI{mouseI}, cellAllFiles{mouseI}, cellsUse, saveDir, mice{mouseI});
end
%}

%%
tgsPlot = [3 4 5];

colorAsscAlt = colorAssc;
colorAsscAlt{3} = colorAssc{1};
colorAsscAlt{4} = colorAssc{2};
colorAsscAlt{8} = [0.6 0.6 0.6];
traitLabelsAlt = traitLabels; traitLabelsAlt{3} = traitLabels{1}; traitLabelsAlt{4} = traitLabels{2}; 

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

%% Within day decoding results

colors = {colorAssc{1} colorAssc{2}};
axH = []; statsOut = [];
for slI = 1:2
    figure('Position',[725 217 340 406]); axH = axes;
    [axH,statsOut{slI}] = PlotTraitProps({decodingResultsPooled{slI}{2}{1}(sessDayDiffs{slI}{2}{1}==0) decodingResultsPooled{slI}{2}{2}(sessDayDiffs{slI}{2}{2}==0)},...
        [1 2],[1 2],colors,{'Traj. Dest.','Task Phase'},axH);
    hold on
    plot([0 3],[0.5 0.5],'--','Color',[0.6 0.6 0.6],'LineWidth',2)
    title(['Within Day Decoding on ' decodeLoc{slI} ', thresh cells'])
    ylabel('% Trials Decoded Correct')
end
figure; %Stats text
for slI = 1:2
subplot(2,1,slI)
text(1,1,['sign test pVal: ' num2str(statsOut{slI}.pPropDiffs)])
xlim([0 10])
ylim([0 3])
title([mazeLocations{slI}])
end
suptitleSL('stats for within-day decoding')

% Does within-day decoding change
statsOut = [];
for dtI = 1:length(decodingType)
    figure;
    for slI = 1:2
        subplot(1,2,slI)
        [statsOut{dtI}{slI}] = PlotTraitChangeOverDaysOne(pooledWithinDayDecResChange{slI}{dtI},pooledRealDayDiffs,...
            {colorAssc{1:2}},{'LR','ST'},true,'regress','Change in Decoding Performance',[-0.5 0.5]);
        title([decodeLoc{slI}])
    end
    suptitleSL(['Change in daily decoding performance using ' decodingType{dtI}]) 
end

%Stats text
for dtI = 1:length(decodingType)
    figure('Position',[724 162 648 423]);
    for slI = 1:2
        subplot(2,1,slI)
        text(1,1,['slopeDiffComp F,dnNum,dfDen,pVal : '...
            num2str(statsOut{dtI}{slI}.slopeDiffComp.Fval) ' ' num2str(statsOut{dtI}{slI}.slopeDiffComp.dfNum) ' '...
            num2str(statsOut{dtI}{slI}.slopeDiffComp.dfDen) ' ' num2str(statsOut{dtI}{slI}.slopeDiffComp.pVal)])
        text(1,2,['slopediffZero ' dimsDecoded{1} ' F,dnNum,dfDen,pVal : '...
            num2str(statsOut{dtI}{slI}.slopeDiffZero(1).Fval) ' ' num2str(statsOut{dtI}{slI}.slopeDiffZero(1).dfNum) ' '...
            num2str(statsOut{dtI}{slI}.slopeDiffZero(1).dfDen) ' ' num2str(statsOut{dtI}{slI}.slopeDiffZero(1).pVal)])
        text(1,3,['slopediffZero ' dimsDecoded{2} ' F,dnNum,dfDen,pVal : '...
            num2str(statsOut{dtI}{slI}.slopeDiffZero(2).Fval) ' ' num2str(statsOut{dtI}{slI}.slopeDiffZero(2).dfNum) ' '...
            num2str(statsOut{dtI}{slI}.slopeDiffZero(2).dfDen) ' ' num2str(statsOut{dtI}{slI}.slopeDiffZero(2).pVal)])
        xlim([0 15])
        ylim([0 5])
        title(['stats for decoding performance change ' decodingType{dtI} ' on ' mazeLocations{slI}])
    end
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

%% Cell type sources bar graph
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

%% Cells transitioning between types

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

% New cells prop changes
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

%% Decoding by days apart
%Reg vs. Downsampled
dimCols = {[0.6392 0.0784 0.1804;1 0 0];[ 0 1 1;0 0 1]};
decDim = {'Traj. Dest.','Task Phase'};
lineType = {{'-','--'},{'-','--'}};
transHere = {[0.6 1];[0.6 1]}; %Line transparency
dtI = 2;
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

%Stats text
for slI = 1:2
    figure('Position',[373 137 856 766]);
    for ddI = 1:2
        subplot(2,1,ddI)
        xlim([0 15])
        text(1,1,['slopeDifference: F,dfNum,dfDen,pVal : '...
            num2str(statsOut{slI}{ddI}.slopeDiffComp.Fval) ' ' num2str(statsOut{slI}{ddI}.slopeDiffComp.dfNum) ' '...
            num2str(statsOut{slI}{ddI}.slopeDiffComp.dfDen) ' ' num2str(statsOut{slI}{ddI}.slopeDiffComp.pVal) ])
        text(1,2,['slopeDiffFromZero reg: F,dfNum,dfDen,pVal : '...
            num2str(statsOut{slI}{ddI}.slopeDiffZero.Fval(1)) ' ' num2str(statsOut{slI}{ddI}.slopeDiffZero.dfNum(1)) ' '...
            num2str(statsOut{slI}{ddI}.slopeDiffZero.dfDen(1)) ' ' num2str(statsOut{slI}{ddI}.slopeDiffZero.pVal(1)) ])
        text(1,3,['slopeDiffFromZero downsampled: F,dfNum,dfDen,pVal : '...
            num2str(statsOut{slI}{ddI}.slopeDiffZero.Fval(2)) ' ' num2str(statsOut{slI}{ddI}.slopeDiffZero.dfNum(2)) ' '...
            num2str(statsOut{slI}{ddI}.slopeDiffZero.dfDen(2)) ' ' num2str(statsOut{slI}{ddI}.slopeDiffZero.pVal(2)) ])
        text(1,4,['ranksum test each day reg. vs. ds. pVals : ' num2str(statsOut{slI}{ddI}.ranksums.pVal)])
        
        ylim([0 5])
        
        title(['reg vs. ds decoding stats for ' dimsDecoded{ddI}])
    end
    suptitleSL(['Reg vs. downsampeld decoding stats on ' mazeLocations{slI}])
end

%Stats for across dimension comparisons
statsOutDim = [];
for slI = 1:length(decodeLoc)
    asdd = figure('Position',[373 137 482 766]);%[723 305 574 461]
    axHH = [];
    axInd = 1;
    axHH(axInd) = subplot(2,1,axInd);
    %Reg dim comparison
    [axHH(axInd), statsOutDim{slI}{1}] = PlotDecodingOneVSother3(...
                                    decodingResultsPooled{slI}{dtI},...
                                    shuffledResultsPooled{slI}{dtI},...
                                    decodedWellPooled{slI}{dtI},...
                                    sessDayDiffs{slI}{dtI}{ddI},sessDayDiffs{slI}{dtI}{ddI},[],[],[],[1 0 0;0 0 1],axHH(axInd));
    title(['Decoding comparison, reg. across dims, decoding Cells on ' decodeLoc{slI} ])
    %Downsampled dim comparison
    axInd = 2;
    axHH(axInd) = subplot(2,1,axInd);
    [axHH(axInd), statsOutDim{slI}{2}] = PlotDecodingOneVSother3(...
                                          downsampledResultsPooled{slI}{dtI},...
                                          shuffledResultsPooled{slI}{dtI},...
                                          DSaboveShuffPpooled{slI}{dtI},...
                                          sessDayDiffs{slI}{dtI}{ddI},sessDayDiffs{slI}{dtI}{ddI},[],[],[],[1 0 0;0 0 1],axHH(axInd));
    title(['Decoding comparison, downsampled across dims, decoding Cells on ' decodeLoc{slI} ])
end
%close(asdd)

%Stats text
for slI = 1:2
    figure('Position',[373 137 856 766]);
    regDStitle = {'regular','downsampled'};
    for regdsI = 1:2
        subplot(2,1,regdsI)
        text(1,1,['slopeDifference LR vs ST: F,dfNum,dfDen,pVal : '...
            num2str(statsOutDim{slI}{regdsI}.slopeDiffComp.Fval) ' ' num2str(statsOutDim{slI}{regdsI}.slopeDiffComp.dfNum) ' '...
            num2str(statsOutDim{slI}{regdsI}.slopeDiffComp.dfDen) ' ' num2str(statsOutDim{slI}{regdsI}.slopeDiffComp.pVal) ])
        text(1,2,['slopeDiffFromZero LR: F,dfNum,dfDen,pVal : '...
            num2str(statsOutDim{slI}{regdsI}.slopeDiffZero.Fval(1)) ' ' num2str(statsOutDim{slI}{regdsI}.slopeDiffZero.dfNum(1)) ' '...
            num2str(statsOutDim{slI}{regdsI}.slopeDiffZero.dfDen(1)) ' ' num2str(statsOutDim{slI}{regdsI}.slopeDiffZero.pVal(1)) ])
        text(1,3,['slopeDiffFromZero ST: F,dfNum,dfDen,pVal : '...
            num2str(statsOutDim{slI}{regdsI}.slopeDiffZero.Fval(2)) ' ' num2str(statsOutDim{slI}{regdsI}.slopeDiffZero.dfNum(2)) ' '...
            num2str(statsOutDim{slI}{regdsI}.slopeDiffZero.dfDen(2)) ' ' num2str(statsOutDim{slI}{regdsI}.slopeDiffZero.pVal(2)) ])
        text(1,4,['ranksum test each day LR vs ST pVals : ' num2str(statsOutDim{slI}{regdsI}.ranksums.pVal)])
        text(1,5,['sign test each day LR vs ST pVals : ' num2str(statsOutDim{slI}{regdsI}.signtests.pVal)])
        
        xlim([0 15])
        ylim([0 6])
        title(['dimension comparison stats ' regDStitle{regdsI}]) 
    end     
    suptitleSL(['decoding comparison between dimensions on ' mazeLocations{slI}])
end


%% Within day population D-prime sensitivity index
cellCritUse = 5;
limsHere = [0 4.5; 0 7];
jj = []; statsOut = [];
for slI = 1:2
    [jj{slI},statsOut{slI}] = PlotPVcurvesDiff(CSpooledPVcorrs{slI}{cellCritUse},CSpooledPVdaysApart{slI}{cellCritUse},...
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


%Stats text
    