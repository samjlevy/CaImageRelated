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

cmp = colormap('lines');
close
mouseColors = cmp(1:numMice,:);

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

%% Ziv figure
slidingWindowSize = 5; %cm
slidingWindowNbins = 80;
%Get smoother Firing likelihood maps
disp('Making smoother maps...')
for mouseI = 1:numMice
    edgesHere = linspace(stemBinEdges(1),stemBinEdges(end),20);
    %[TMap_extra{mouseI}, ~, ~, ~, ~, ~, ~] =...
    %PFsLinTBTdnmp(cellTBT{mouseI}, edgesHere, [], [], false,condPairs);
    [TMap_extra{mouseI}, ~, ~, ~, ~] =...
            PFsLinTBTdnmpSliding(cellTBT{mouseI}, [stemBinEdges(1) stemBinEdges(end)], slidingWindowNbins, slidingWindowSize, [], false,[1;2;3;4]);% condPairs
end
disp('Done making maps')

%Pool Across mice; also COM
daysZiv = [4 5 19; 3 4 18; 4 5 19]; 
zivMice = [1 2 4];
TMap_expanded = []; expandedCOM = [];
for mouseJ = 1:length(zivMice)
    zm = zivMice(mouseJ);
    dz = find(sum(cellRealDays{zm}==daysZiv(mouseJ,:),2));
    TMap_here = TMap_extra{zm}(:,dz,:);
    TMap_expanded = [TMap_expanded; TMap_here];
    
    %Center of mass
    [allCondsTMap{mouseJ}, ~, ~, ~, ~] =...
            PFsLinTBTdnmpSliding(cellTBT{zm}, [stemBinEdges(1) stemBinEdges(end)], slidingWindowNbins, slidingWindowSize, [], false,[1 2 3 4]);
        
    %[allCondsTMap{mouseJ}, ~, ~, ~, ~, ~, ~] =...
    %    PFsLinTBTdnmp(cellTBT{zm}, stemBinEdges, minspeed, [], false,[1 2 3 4]);
    allFiringCOM{mouseJ} = TMapFiringCOM(allCondsTMap{mouseJ},'maxBin');
    COMhere = allFiringCOM{mouseJ}(:,dz);
    expandedCOM = [expandedCOM; COMhere];
end

%Decide which cells to use, adjust for later mice
cellsUse = [];
for mouseJ = 1:length(zivMice)
    dzz = find(cellRealDays{zivMice(mouseJ)}==daysZiv(mouseJ,1));
    %cells above activity threshold
    cellsUse = [cellsUse; dayUse{zivMice(mouseJ)}(:,dzz)];
    %cells that fired
    %cellsUse = [cellsUse; (sum(trialReli{zivMice(mouseJ)}(:,dzz,:),3)>0)];
    %cells here at all
    %cellsUse = [cellsUse; cellSSI{zivMice(mouseJ)}(:,dzz)>0];
end

%Plot the thing
[figHand] = PlotZivStyleFigure(TMap_expanded,cellsUse,expandedCOM,'day1EachCond');%day1AllConds
suptitleSL([num2str(slidingWindowNbins) ' bins that are ' num2str(slidingWindowSize) ' cm'])

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
            figg = [];
            cp = splittersPlot{mouseI}(cellI);
            pd = find(cellSSI{mouseI}(cp,:)>0);
            [figg] = PlotSplittingDotPlot(daybyday,cellTBTarm{mouseI},cp,pd,'stem','line','wholeLap');
            %cellOutLinePlot...
             
            figHd = [];
            figHd = PlotCellOutline(cellAllFiles{mouseI}(pd),cellSSI{mouseI}(44,pd),250);
            %title has that cell's number on that day, and the session number (not real day)
            %Also one to combine all these across days? Will have to load
            %the all file, or at least the aligned files from each day
        end
    end
end

%Get splitters that only split in one location
slInds = [1 2];
for slI = 1:2
    for mouseI = 1:4
        %splitLocRestrict = ones(size(traitGroups{slI}{mouseI}{3})); %Doesn't matter other loc
        splitLocRestrict = traitGroups{slInds(slInds~=slI)}{mouseI}{8}; %only this loc
        
        LRonlyCell = find(traitGroups{slI}{mouseI}{3} .* splitLocRestrict);
        STonlyCell = find(traitGroups{slI}{mouseI}{4} .* splitLocRestrict);
        BOTHcell = find(traitGroups{slI}{mouseI}{5} .* splitLocRestrict);
        NonSplitterCell = find(traitGroups{slI}{mouseI}{8} .* splitLocRestrict);
        
        [cellPlot,presentDays] = ind2sub(size(cellSSI{mouseI}),LRonlyCell(1));
        
        
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
    text(1,1.5,'sign rank test p'); text(3,1.5,num2str([statsOut{slI}.signrank.pVal]))
    text(1,2,'sign rank test z'); text(3,2,num2str([statsOut{slI}.signrank.zVal]))
    text(1,2.5,'KS ANOVA p tukey'); text(4,2.5,num2str(statsOut{slI}.ksANOVA.multComps(:,6)'))
    text(1,3,['KS ANOVA: Chi-sq    ' num2str(statsOut{slI}.ksANOVA.tbl{2,5})]) 
    text(1,3.5,['KS ANOVA: df groups, error, total    ' num2str([statsOut{slI}.ksANOVA.tbl{2:end,3}])])
       
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

%% Splitter proportion changes raw
thingsNow = [3     4     5     8];

ylimsuse = {[0 0.4],[0 0.4],[0.2 0.8],[0 0.4];[0.2 0.6],[0 0.2],[0.2 0.8],[0 0.2]}; 
for slI = 1:2
    figure('Position',[695 118 819 674]);
    for ii = 1:4
        pooledHere = [];
        daysHere = [];
        aff(ii)=subplot(2,2,ii);
        for mouseI = 1:4
            
            dayss = cellRealDays{mouseI} - (cellRealDays{mouseI}(1)-1);
            %dayss = cellRealDays{mouseI};
            splitPropHere = splitPropEachDay{slI}{mouseI}{thingsNow(ii)};
            %splitPropHere = splitPropHere - mean(splitPropHere);
            plot(dayss,splitPropHere)
            pooledHere = [pooledHere; splitPropHere(:)];
            daysHere = [daysHere; dayss];
            hold on
            
            outputForMarc(ii).indivMice(mouseI).props = splitPropHere;
            outputForMarc(ii).indivMice(mouseI).days = dayss;
            
            outputForMarc(ii).earlyDat(mouseI) = mean(splitPropHere(1:2));
            outputForMarc(ii).lateDat(mouseI) = mean(splitPropHere(end-1:end));
        end
        
    outputForMarc(ii).earlyMean = mean(outputForMarc(ii).earlyDat);
    outputForMarc(ii).lateMean = mean(outputForMarc(ii).lateDat);
    outputForMarc(ii).props = pooledHere;
    outputForMarc(ii).days = daysHere;

    ylabel('Proportion of cells')
    xlabel('Recording day')
    
    [fitVal,daysPlot] = FitLineForPlotting(pooledHere,daysHere);
    plot(daysPlot,fitVal,'k','LineWidth',2)
    [~, ~, ~, RR(ii), Pval(ii), ~] =...
                fitLinRegSL(pooledHere,daysHere);
            [Fval(ii),dfNum(ii),dfDen(ii),pVal(ii)] =...
            slopeDiffFromZeroFtest(pooledHere,daysHere);
    [propsRho(ii),propsCorrPval(ii)] = corr(pooledHere,daysHere,'Type','Spearman');
    
    %title([traitLabels{thingsNow(ii)} ', R=' num2str(sqrt(abs(RR.Ordinary))) ', p=' num2str(Pval)])
    title([traitLabels{thingsNow(ii)}])
    
    xlim([min(daysHere)-0.5 max(daysHere)+0.5])
    ylim(ylimsuse{slI,ii})
    xticks([1 6 12 18])
    
    aff(ii) = MakePlotPrettySL(aff(ii));
    end
    
    suptitleSL(['Raw splitting pcts across all mice, and regression on ' mazeLocations{slI}])
    
    figure('Position',[735 209 910 420]);
    for ii = 1:4
    text(1,ii,['LinReg R=' num2str(sqrt(abs(RR(ii).Ordinary))) ', p=' num2str(Pval(ii))...
        ', F diff zero F dfNum dfDen p: ' num2str([Fval(ii) dfNum(ii) dfDen(ii) pVal(ii)])...
        ', spearman corr rho pval: ' num2str([propsRho(ii) propsCorrPval(ii)])]) 
    end
    title(['stats for raw data splitter prop changes on ' mazeLocations{slI}])
    xlim([0 18])
    ylim([0 6])
end

%% Within day decoding results

colors = {colorAssc{1} colorAssc{2}};
axH = []; statsOut = [];
for slI = 1:2
    figure('Position',[725 217 250 406]); axH = axes;
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
text(1,1,['sign test pVal, zVal: ' num2str([statsOut{slI}.signrank.pVal statsOut{slI}.signrank.zVal])])
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
        text(1,1,['slopeDiffComp F,dnNum,dfDen,pVal: '...
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

statsOut = [];
for slI = 1:2
    %figure('Position',[626 213 428 596]);
    figure('Position',[626 418 442 391]);
    for ddI = 1:2
        %subplot(2,1,ddI) 
        %colorsUse = mouseColors
        colorsUse = repmat(colorAssc{ddI},numMice,1);
        statsOut{slI}{ddI} = PlotRawTraitEachMouse(withinDayDecodingResults{slI}{2}{ddI},...
            cellRealDays,'none',colorsUse,colorAssc{ddI});
        title(['Decoding performance on for ' dimsDecoded{ddI}])
        ylabel('Decoding Performance')
        xlabel('Recording Day')
        ylim([0.4 1.05])
        hold on
    end
    d1 = PoolCellArrAcrossMice(withinDayDecodingResults{slI}{2}{1});
    d2 = PoolCellArrAcrossMice(withinDayDecodingResults{slI}{2}{2});
    [statsOut{slI}{1}.signrank.pVal,statsOut{slI}{1}.signrank.hVal,ts] = signrank(d1,d2);
        statsOut{slI}{1}.signrank.zVal = ts.zval;
    suptitleSL(['Decoding performance over days on ' mazeLocations{slI}])
end
%Stats Text
for slI = 1:2
    figure;
    for ddI = 1:2
        subplot(2,1,ddI)
        text(1,1,['slopeDiffComp F,dnNum,dfDen,pVal: '...
            num2str(statsOut{slI}{ddI}.slopeDiffZero(1).Fval) ' ' num2str(statsOut{slI}{ddI}.slopeDiffZero(1).dfNum) ' '...
            num2str(statsOut{slI}{ddI}.slopeDiffZero(1).dfDen) ' ' num2str(statsOut{slI}{ddI}.slopeDiffZero(1).pVal)])
        text(1,2,['slope RR, pVa: ' num2str([statsOut{slI}{ddI}.slope.RR.Ordinary  statsOut{slI}{ddI}.slope.pVal])])
        xlim([0 15])
        ylim([0 4])
        title(['Stats for ' dimsDecoded{ddI}])
    end
    suptitleSL({['Stats for decoding performance on ' mazeLocations{slI}];...
            ['Dim comparison sign rank p,z: ' num2str([statsOut{slI}{1}.signrank.pVal statsOut{slI}{1}.signrank.zVal])]})
end


%% Prop of splitters that come back (Reactivation)
tgsPlot = [3 4 5];
gh = [];
statsOut = [];
for slI = 1:2
    gh{slI} = figure('Position',[360 169 435 444]);%[434 68 855 689]
    [gh{slI},statsOut{slI}] = PlotTraitChangeOverDays(pooledSplitterComesBack{slI},pooledRealDayDiffs,...
        tgsPlot,colorAsscAlt,traitLabels,gh{slI},false,'mean',[0 0.7],'pct. Cells Return',0.23); %Num in this case is diff in Pcts.
    suptitleSL(['Change in Proportion of Splitters that Come Back on ' splitterLoc{slI}])
end
for slI = 1:2
    figure('Position',[680 558 730 420]);
    for lineI = 1:length(tgsPlot)
        sigTests = statsOut{slI}.signranktests{1}(lineI).pVal<0.05;
        text(1,lineI,['comparison lines ' num2str(statsOut{slI}.comps{1}(lineI,:))...
            ', num day lags diff sign rank test: ' num2str(sum(sigTests)) ', from day lags ' num2str(find(sigTests))])
    end
    for lineI = 1:length(tgsPlot)
        sigTests = statsOut{slI}.signranktests{1}(lineI).pVal<(0.05/(max(cell2mat(cellfun(@length,cellRealDays,'UniformOutput',false))-1)));
        text(1,lineI+length(tgsPlot),['mult comp bonferroni comparison lines ' num2str(statsOut{slI}.comps{1}(lineI,:))...
            ', num day lags diff sign rank test: ' num2str(sum(sigTests)) ', from day lags ' num2str(find(sigTests))])
    end
    xlim([0 15]); ylim([0 7])
    title(['stats for splitter reactivation by day lag on ' splitterLoc{slI}])
end

%% Cell type sources bar graph
c = categorical({'Turn','Phase','Conjunctive'});
statsOut = [];
for slI = 1:2
    figure; 
    for tcI = 1:length(cellCheck)
        subplot(1,length(cellCheck),tcI)
        [statsOut{slI}{tcI}] = PlotBarWithData([pooledDailySources{slI}{tcI}{:}],sourceColors,false,true,sourceLabels);
        ylim([0 1.05])
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

%New cells prop Raw
%statsOut = PlotRawTraitEachMouse(traitProps,realDays,normalization,mouseColors,regColor)

thingsNow = [3     4     5     8];

ylimsuse = {[0 0.5],[0 0.5],[0.1 0.9],[0 0.5];[0.1 0.7],[-0.01 0.4],[0.1 0.7],[-0.01 0.4]};
for slI = 1:2
    figure('Position',[695 118 819 674]);
    for ii = 1:4
        pooledHere = [];
        daysHere = [];
        aaa = subplot(2,2,ii);
        for mouseI = 1:4
            
            dayss = cellRealDays{mouseI} - (cellRealDays{mouseI}(1)-1);
            dayss = dayss(2:end);
            %dayss = cellRealDays{mouseI};
            splitPropHere = traitFirstPcts{slI}{mouseI}{thingsNow(ii)};
            pkgForSlope{mouseI} = splitPropHere;
            %splitPropHere = splitPropHere - mean(splitPropHere);
            plot(dayss,splitPropHere)
            pooledHere = [pooledHere; splitPropHere(:)];
            daysHere = [daysHere; dayss];
            daysPkg{mouseI} = dayss;
            hold on
        end
        
        ylabel('Proportion of cells')
        xlabel('Recording day')

        [fitVal,daysPlot] = FitLineForPlotting(pooledHere,daysHere);
        plot(daysPlot,fitVal,'k','LineWidth',2)
        [~, ~, ~, RR(ii), Pval(ii), ~] =...
                    fitLinRegSL(pooledHere,daysHere);
                [Fval(ii),dfNum(ii),dfDen(ii),pVal(ii)] =...
                slopeDiffFromZeroFtest(pooledHere,daysHere);
        [slopePermP(ii)] = slopePermutationTest(pkgForSlope,daysPkg,1000);
        %title([traitLabels{thingsNow(ii)} ', R=' num2str(sqrt(abs(RR.Ordinary))) ', p=' num2str(Pval)])
        title([traitLabels{thingsNow(ii)}])

        xlim([min(daysHere)-0.5 max(daysHere)+0.5])
        ylim(ylimsuse{slI,ii})
        xticks([2 6 12 18])
        aaa = MakePlotPrettySL(aaa);
    end
    
    suptitleSL(['Raw splitting pcts of new cells across all mice, and regression on ' mazeLocations{slI}])
    
    figure('Position',[322 269 1255 420]);
    for ii = 1:4
    text(1,ii,[traitLabelsAlt{thingsNow(ii)} ' LinReg R=' num2str(sqrt(abs(RR(ii).Ordinary))) ', p=' num2str(Pval(ii))...
        ',F diff zero F dfNum dfDen p: ' num2str([Fval(ii) dfNum(ii) dfDen(ii) pVal(ii)])...
        ', slopePermP= ' num2str(slopePermP(ii))]) 
    end
    title(['stats for raw data new cell splitter prop changes on ' mazeLocations{slI}])
    xlim([0 15])
    ylim([0 6])
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
runPermTest = true;
for slI = 1:length(decodeLoc)
    axInd = slI;
    axH(axInd) = subplot(length(decodeLoc),1,axInd);
    for ddI = 1:2%decoding Dimension
        [axH(axInd), statsOut{slI}{ddI}] = PlotDecodingOneVSother3(...
                                    {decodingResultsPooled{slI}{dtI}{ddI} downsampledResultsPooled{slI}{dtI}{ddI}},...
                                    {shuffledResultsPooled{slI}{dtI}{ddI} shuffledResultsPooled{slI}{dtI}{ddI}},...
                                    {decodedWellPooled{slI}{dtI}{ddI} DSaboveShuffPpooled{slI}{dtI}{ddI}},...
                                    sessDayDiffs{slI}{dtI}{ddI},sessDayDiffs{slI}{dtI}{ddI},[],lineType{ddI},transHere{ddI},dimCols{ddI},runPermTest,axH(axInd));
        title(['Decoding comparison, reg. vs. DS, decoding Cells on ' decodeLoc{slI} ])
    end
    xticks([1 4 8 12 16])
end
asd.Renderer = 'painters';
suptitleSL(['Decoding with ' decodingType{dtI} ', solid = REG, dotted = DS, r = lr b = st'])
for chI = 1:length(asd.Children); if strcmpi(class(asd.Children(chI)),'matlab.graphics.axis.Axes'); 
        asd.Children(chI) = MakePlotPrettySL(asd.Children(chI)); end; end

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
        
        text(1,5,['slopeDiffZero reg permutation pVal: ' num2str(statsOut{slI}{ddI}.slopeDiffZeroPerm.pVal(1))])
        text(1,6,['slopeDiffZero downsampled permutation pVal: ' num2str(statsOut{slI}{ddI}.slopeDiffZeroPerm.pVal(2))])
        
        ylim([0 7])
        
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
                                    sessDayDiffs{slI}{dtI}{ddI},sessDayDiffs{slI}{dtI}{ddI},[],[],[],[1 0 0;0 0 1],false,axHH(axInd));
    title(['Decoding comparison, reg. across dims, decoding Cells on ' decodeLoc{slI} ])
    %Downsampled dim comparison
    axInd = 2;
    axHH(axInd) = subplot(2,1,axInd);
    [axHH(axInd), statsOutDim{slI}{2}] = PlotDecodingOneVSother3(...
                                          downsampledResultsPooled{slI}{dtI},...
                                          shuffledResultsPooled{slI}{dtI},...
                                          DSaboveShuffPpooled{slI}{dtI},...
                                          sessDayDiffs{slI}{dtI}{ddI},sessDayDiffs{slI}{dtI}{ddI},[],[],[],[1 0 0;0 0 1],false,axHH(axInd));
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


%% Within day population state separation
%Need to work in option to plot lines instead of dots

cellCritUse = 5;
%Stem
%for slI = 1:2
%jj = PlotPVcurves(CSpooledPVcorrs2{slI}{cellCritUse},CSpooledPVdaysApart2{1}{cellCritUse},condSetColors,condSetLabels,{true,0.2},[]);
%end
axHand = []; statsOut = [];
for slI = 1:2
    [axHand{slI},statsOut{slI}] = PlotPVcurvesDiff(CSpooledPVcorrs2{slI}{cellCritUse},CSpooledPVdaysApart2{slI}{cellCritUse},condSetColors,condSetLabels,{true,0.25},[]);
    ylabel('Ensemble State Separation')
    title(['Ensemble state separation on ' mazeLocations{slI}])
    legend off
    
    for binI = 1:numBins
        if statsOut{slI}.signranktests{1}(binI).pVal < 0.05
            plot([-0.5 0.5]+binI,[-0.05 -0.05],'r','LineWidth',2)
        end
        for csI = 1:length(condSet)-1
            if statsOut{slI}.eachCond{csI}.diffFromZeroSign(binI).pVal < 0.05
                plot(binI,-0.05-0.05*csI,'*','Color',condSetColors{csI+1},'MarkerSize',6)
            end
        end
    end
    ylim([-0.05-0.05*(csI+1) axHand{slI}.YLim(2)])
    axHand{slI} = MakePlotPrettySL(axHand{slI});
end
%stats
for slI = 1:2
    figure('Position',[605 184 992 420]);
    text(1,1,['sign rank tests p: ' num2str([statsOut{slI}.signranktests{1}.pVal])])
    text(1,2,['sign rank tests z: ' num2str([statsOut{slI}.signranktests{1}.zVal])])
    text(1,3,['rankrum tests p: ' num2str([statsOut{slI}.ranksumtests{1}.pVal])])
    text(1,4,['ranksum tests z: ' num2str([statsOut{slI}.ranksumtests{1}.zVal])])
    
     for csI = 1:length(condSet)-1
        text(1,5+csI,['cond ' num2str(csI) ': sign test diff 0 p :' num2str([statsOut{slI}.eachCond{csI}.diffFromZeroSign.pVal])])
        text(1,5.5+csI,['cond ' num2str(csI) ': sign test diff 0 z :' num2str([statsOut{slI}.eachCond{csI}.diffFromZeroSign.pVal])])
     end
    
    xlim([0 15])
    ylim([0 5])
    title(['stats for within day pv state separation on ' mazeLocations{slI}])
end

%% Population state separation over days
figHand = [];
statsOut = [];
binsUse = {[1:2];[7:8]};
%ylimsHere = {{0 0.5}{0 1};{0 1}{0 1]
for bI = 1:length(binsUse)
for slI = 1:2
    [figHand{slI},statsOut{slI}] = PlotPVcurvesDiffRawDays(...
        cellArrMeanByCS{slI}{cellCritUse},uniqueDayDiffs{slI}{cellCritUse},cellRealDays,binsUse{bI},condSetColors(2:end));
    figHand{slI}.Children.YLabel.String = 'Ensemble State Separation';
    figHand{slI}.Children.XLim = [1 figHand{slI}.Children.XLim(2)];
   
    figHand{slI}.Children.XTick = [6 12 18];
    figHand{slI}.Children.XTickLabel ={'6'; '12'; '18'}; 
    
    figHand{slI}.Children.YLim = [0 1];
    figHand{slI}.Children.Title.String = ['Corr Over days on ' mazeLocations{slI} ', bins ' num2str([binsUse{bI}])];
    
    %for dpI = 1:length(statsOut{slI}.signranks{1}.eachDayPair)
    %    if statsOut{slI}.signranks{1}.pVal(dpI) < 0.05
    %        plot([-0.5 0.5]+statsOut{slI}.signranks{1}.eachDayPair(dayI),[-0.05 -0.05],'m','LineWidth',2)
    %    end 
    %end
    %figHand{slI}.Children.YLim = [-0.1 1];
    figHand{slI}.Children = MakePlotPrettySL(figHand{slI}.Children);
end
%stats
for slI = 1:2
    figure('Position',[75 129 1816 420]);
    for cdI = 1:2
        subplot(2,1,cdI)
        text(1,1,['slope R, pVal: ' num2str([statsOut{slI}.slope.RR(cdI) statsOut{slI}.slope.pVal(cdI)])])
        text(1,2,['slope diff Zero F, dfNum, dfDen, p: ' num2str([statsOut{slI}.slopeDiffZero.Fval(cdI)...
           statsOut{slI}.slopeDiffZero.dfNum(cdI) statsOut{slI}.slopeDiffZero.dfDen(cdI)...
           statsOut{slI}.slopeDiffZero.pVal(cdI)])])
       
        text(1,3,['line separation signed rank p,z : ' num2str([statsOut{slI}.signrankall{1}.pVal statsOut{slI}.signrankall{1}.zVal])])

        xlim([0 8])
        ylim([0 4])
        title(['stats for within day pv state over time bins' num2str([binsUse{bI}]) ', on ' mazeLocations{slI}...
            ' ' condSetLabels{cdI+1}])
    end
end
end


%% Day diffs population state separation

binsUse = {[1:2];[7:8]};
for bI = 1:length(binsUse)
axHand = []; statsOut = [];
for slI=1:2
    [axHand{slI},statsOut{slI}] = PlotPVcurvesDiffDayDiffs(CSpooledPVcorrs2{slI}{cellCritUse},CSpooledPVdaysApart2{slI}{cellCritUse},...
        binsUse{bI},1,condSetColors,condSetLabels,{true,0.2},[]);
    ylabel('Ensemble State Separation')
    title(['Ensemble state separation, bins ' num2str([binsUse{bI}]) ', on ' mazeLocations{slI}])
    axHand{slI}.XTick = [1 4:4:16];
    legend off
    for dayI = 1:dayLagLimit
        if statsOut{slI}.signranktests{1}(dayI).pVal < 0.05
            plot([-0.5 0.5]+dayI,[-0.05 -0.05],'m','LineWidth',2)
        end
        for csI = 1:length(condSet)-1
            if statsOut{slI}.eachCond{csI}.diffFromZeroSign(dayI).pVal < 0.05
                plot(dayI,-0.05-0.05*csI*1,'*','Color',condSetColors{csI+1},'MarkerSize',6)
            end
        end
    end
    ylim([-0.05-0.05*(csI+1) axHand{slI}.YLim(2)])
    axHand{slI} = MakePlotPrettySL(axHand{slI});
end
%stats
for slI = 1:2
    figure('Position',[75 129 1816 420]);
    text(1,1,['sign rank tests p: ' num2str([statsOut{slI}.signranktests{1}.pVal])])
    text(1,2,['sign rank tests z: ' num2str([statsOut{slI}.signranktests{1}.zVal])])
    text(1,3,['rankrum tests p: ' num2str([statsOut{slI}.ranksumtests{1}.pVal])])
    text(1,4,['ranksum tests z: ' num2str([statsOut{slI}.ranksumtests{1}.zVal])])
    
    for csI = 1:length(condSet)-1
        text(1,5+csI,['cond ' num2str(csI) ': sign test diff 0 p :' num2str([statsOut{slI}.eachCond{csI}.diffFromZeroSign.pVal])])
        text(1,5.5+csI,['cond ' num2str(csI) ': sign test diff 0 z :' num2str([statsOut{slI}.eachCond{csI}.diffFromZeroSign.pVal])])
    end
    
    xlim([0 15])
    ylim([0 8])
    title(['stats for within day pv state separation bins ' num2str([binsUse{bI}]) ', on ' mazeLocations{slI}])
end
end

%% Center-of-mass

statsOut = [];
qq = figure; histogram(pooledCOMlrEx,1:0.5:8,'FaceColor',[0.8510    0.3294    0.1020])
hold on
histogram(pooledCOMstEx,1:0.5:8,'FaceColor',[0    0.4510    0.7412])
plot([1 1]*mean(pooledCOMlrEx),[0 200],'--r','LineWidth',2)
plot([1 1]*mean(pooledCOMstEx),[0 200],'--b','LineWidth',2)
title('STEM COM distributions (exclusive, no both), r = lr b = st')
xlim([1 8])
ylabel('Number of cells')
yyaxis right
[f,x] = ecdf(pooledCOMlrEx);
plot(x,f,'-','Color','r','LineWidth',2)
[f,x] = ecdf(pooledCOMstEx);
plot(x,f,'-','Color','b','LineWidth',2)
ylabel('Cumulative portion')
xlabel('All trials Firing COM')
qq.Children = MakePlotPrettySL(qq.Children);
[statsOut.ranksum.pVal,statsOut.ranksum.hVal] = ranksum(pooledCOMlrEx,pooledCOMstEx);
[statsOut.ksTest.hVal,statsOut.ksTest.pVal] = kstest2(pooledCOMlrEx,pooledCOMstEx);

figure;
text(1,1,['ranksum p,h = ' num2str([statsOut.ranksum.pVal,statsOut.ranksum.hVal])])
text(1,2,['ksTest p,h = ' num2str([statsOut.ksTest.pVal,statsOut.ksTest.hVal])])
ylim([0 3]); xlim([0 8]); title('stats text for COMs on STEM')

statsOut = [];
ww = figure; histogram(pooledCOMlrARMex,1:0.5:8,'FaceColor',[0.8510    0.3294    0.1020])
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
ww.Children = MakePlotPrettySL(ww.Children);
[statsOut.ranksum.pVal,statsOut.ranksum.hVal] = ranksum(pooledCOMlrARMex,pooledCOMstARMex);
[statsOut.ksTest.hVal,statsOut.ksTest.pVal] = kstest2(pooledCOMlrARMex,pooledCOMstARMex);

figure;
text(1,1,['ranksum p,h = ' num2str([statsOut.ranksum.pVal,statsOut.ranksum.hVal])])
text(1,2,['ksTest p,h = ' num2str([statsOut.ksTest.pVal,statsOut.ksTest.hVal])])
ylim([0 3]); xlim([0 8]); title('stats text for COMs on ARMS')
%Stats text
    