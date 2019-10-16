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

allRealDays = vertcat(cellRealDays{:});
allAccuracyUsed = vertcat(accuracy{:});
[accRho, accpVal] = corr(allRealDays,allAccuracyUsed,'type','Spearman');

allAccuracyAllRealDays = vertcat(allDaysAccuracy{:});
[accRho, accpVal] = corr(allAccuracyAllRealDays(:,1),allAccuracyAllRealDays(:,2),'type','Spearman');
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

for mouseI = 1:numMice
    leftSplitter{mouseI} = meanRateDiff{1}{1}{mouseI}<0 & traitGroups{1}{mouseI}{3};
    studySplitter{mouseI} = meanRateDiff{1}{2}{mouseI}<0 & traitGroups{1}{mouseI}{4};
end

splittersPlot = randomFiringCell;
for mouseI = 1:numMice
    if any(splittersPlot{mouseI})
        load(fullfile(mouseDefaultFolder{mouseI},'daybyday.mat'))
        for cellI = 1:length(splittersPlot{mouseI})
            figg = [];
            cp = splittersPlot{mouseI}(cellI);
            cp = 356;
            pd = find(cellSSI{mouseI}(cp,:)>0);
            [figg] = PlotSplittingDotPlot(daybyday,cellTBTarm{mouseI},cp,pd,'arm','line','wholeLap');
            %cellOutLinePlot...
             
            figHd = [];
            figHd = PlotCellOutline(cellAllFiles{mouseI}(pd),cellSSI{mouseI}(cp,pd),45);
            title(['m' num2str(mouseI) 'c ' num2str(cp) ' D ' num2str(cellRealDays{mouseI}(pd))])
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

%% Splitter DI distributions unpooled
condNames = {cellTBT{1}.name};
splitDIcolor = {[0.4000    0.6510    0.8314];[0.9294    0.3490    0.1294]};
splitDIcolor = {'r','b'};
gg = [];
for slI = 1:2 %Maze Location
    figure;
    for stI = 1:2 %Splitter type
        for ttI = 1:2 %Sub chunk
            subplot(2,2,ttI+2*(stI-1))
            allDIhere = [];
            for mouseI = 1:numMice
                DIhere = DImeanUnpooled{slI}{stI}{mouseI}(:,:,ttI);
                allDIhere = [allDIhere; DIhere(:)];
            end
            gg{ttI+2*(stI-1)} = histogram(allDIhere,[-1.1 -0.9:0.1:0.9 1.1],'FaceColor',splitDIcolor{stI});
            ylab = cellfun(@str2num,gg.Parent.YTickLabel,'UniformOutput',false);
            newLab = cellfun(@(x) num2str(x/sum(gg.Values)),ylab,'UniformOutput',false);
            gg.Parent.YTickLabel = newLab;
            
            title(['Splitting between ' condNames{unpooledCPs{stI}(ttI,1)} ' and ' condNames{unpooledCPs{stI}(ttI,2)}])
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
    text(1,1.5,'sign rank test p'); text(3,1.5,num2str([statsOut{slI}.signrank.pVal]))
    text(1,2,'sign rank test z'); text(3,2,num2str([statsOut{slI}.signrank.zVal]))
    text(1,2.5,'KS ANOVA p tukey'); text(4,2.5,num2str(statsOut{slI}.ksANOVA.multComps(:,6)'))
    text(1,3,['KS ANOVA: Chi-sq    ' num2str(statsOut{slI}.ksANOVA.tbl{2,5})]) 
    text(1,3.5,['KS ANOVA: df groups, error, total    ' num2str([statsOut{slI}.ksANOVA.tbl{2:end,3}])])
       
    xlim([0 12]); ylim([0 5])
    title(['Stats for splitter proportions on ' splitterLoc{slI}])
end

%Stem vs. arms
tgHere = [3 4 5 8];
disp('Stemp vs. arm comparisons splitter props')
pVal = [];
for tgH = 1:length(tgHere)
    [pVal(tgH),~,stats(tgH)] = signrank(pooledSplitProp{1}{tgHere(tgH)},pooledSplitProp{2}{tgHere(tgH)});
    disp(['Sign-rank test ' traitLabels{tgHere(tgH)} ' p= ' num2str(pVal(tgH)) ', zval= ' num2str(stats(tgH).zval)])
end
    

%% Change in Proportion of Each splitter type by days apart
changesPlot =[3 4 5 8];
gh = [];
statsOut = [];
for slI = 1:2
    gh{slI} = figure('Position',[593 316 660 458]);%[435 278 988 390][593 273 559 501]
    [gh{slI},statsOut{slI}] = PlotTraitChangeOverDays(pooledSplitNumChange{slI},pooledRealDayDiffs,...
        {changesPlot},colorAsscAlt,traitLabels,gh{slI},true,'regress',[-0.6 0.4],'pct Change',[]); %Num in this case is diff in Pcts.
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

%% Prop. of cells above activity threshold

propActiveCellsOfTotal = cellfun(@(x) sum(x,1)/size(x,1),dayUse,'UniformOutput',false);
propActiveCellsOfFound = cellfun(@(x,y) sum(x,1)./sum(y>0,1),dayUse,cellSSI,'UniformOutput',false);

figure;
subplot(1,2,1)
daysHere = [];
pooledHere = [];
for mouseI = 1:numMice
    dayss = cellRealDays{mouseI} - (cellRealDays{mouseI}(1)-1);
    splitPropHere = propActiveCellsOfTotal{mouseI};
    plot(dayss,splitPropHere); hold on
    pooledHere = [pooledHere; splitPropHere(:)];
    daysHere = [daysHere; dayss];
end
[fitVal,daysPlot] = FitLineForPlotting(pooledHere,daysHere);
    plot(daysPlot,fitVal,'k','LineWidth',2)
 [propsRhoH,propsPvalH] = corr(daysHere,pooledHere,'type','Spearman');
 title(['rho= ' num2str(propsRhoH) ', p= ' num2str(propsPvalH)])
 ylabel('Prop. Active/Total # Cells')
  xlabel('Recording Day')
 ylim([0 0.4])
 
subplot(1,2,2)
daysHere = [];
pooledHere = [];
for mouseI = 1:numMice
    dayss = cellRealDays{mouseI} - (cellRealDays{mouseI}(1)-1);
    splitPropHere = propActiveCellsOfFound{mouseI};
    plot(dayss,splitPropHere); hold on
    pooledHere = [pooledHere; splitPropHere(:)];
    daysHere = [daysHere; dayss];
end
[fitVal,daysPlot] = FitLineForPlotting(pooledHere,daysHere);
    plot(daysPlot,fitVal,'k','LineWidth',2)
 [propsRhoH,propsPvalH] = corr(daysHere,pooledHere,'type','Spearman');
 title(['rho= ' num2str(propsRhoH) ', p= ' num2str(propsPvalH)])
 ylabel('Prop. Active/# Cells Day N')
 xlabel('Recording Day')
ylim([0 0.4])
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
            
            %outputForMarc(ii).indivMice(mouseI).props = splitPropHere;
            %outputForMarc(ii).indivMice(mouseI).days = dayss;
            
            %outputForMarc(ii).earlyDat(mouseI) = mean(splitPropHere(1:2));
            %outputForMarc(ii).lateDat(mouseI) = mean(splitPropHere(end-1:end));
        end
        
    %outputForMarc(ii).earlyMean = mean(outputForMarc(ii).earlyDat);
    %outputForMarc(ii).lateMean = mean(outputForMarc(ii).lateDat);
    %outputForMarc(ii).props = pooledHere;
    %outputForMarc(ii).days = daysHere;

    ylabel('Proportion of cells')
    xlabel('Recording day')
    
    [fitVal,daysPlot] = FitLineForPlotting(pooledHere,daysHere);
    plot(daysPlot,fitVal,'k','LineWidth',2)
    [~, ~, ~, RR(ii), Pval(ii), ~] =...
                fitLinRegSL(pooledHere,daysHere);
            [Fval(ii),dfNum(ii),dfDen(ii),pVal(ii)] =...
            slopeDiffFromZeroFtest(pooledHere,daysHere);
    [propsRho(ii),propsCorrPval(ii)] = corr(daysHere,pooledHere,'type','Spearman');
    
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
    text(1,ii,[traitLabels{thingsNow(ii)} ' LinReg R=' num2str(sqrt(abs(RR(ii).Ordinary))) ', p=' num2str(Pval(ii))...
        ', F diff zero F dfNum dfDen p: ' num2str([Fval(ii) dfNum(ii) dfDen(ii) pVal(ii)])...
        ', spearman corr rho pval: ' num2str([propsRho(ii) propsCorrPval(ii)])]) 
    end
    title(['stats for raw data splitter prop changes on ' mazeLocations{slI}])
    xlim([0 18])
    ylim([0 6])
end

%Comparison to accuracy
for slI = 1:2
    figure('Position',[695 118 819 674]);
    for ii = 1:4
        pooledHere = [];
        daysHere = [];
        aff(ii)=subplot(2,2,ii);
        for mouseI = 1:4
            
            dayss = accuracy{mouseI};
            splitPropHere = splitPropEachDay{slI}{mouseI}{thingsNow(ii)};
            plot(dayss,splitPropHere,'o','MarkerFaceColor',mouseColors(mouseI,:),'MarkerSize',8)
            pooledHere = [pooledHere; splitPropHere(:)];
            daysHere = [daysHere; dayss];
            hold on
        end
        
    ylabel('Proportion of cells')
    xlabel('Accuracy')
    
    [fitVal,daysPlot] = FitLineForPlotting(pooledHere,daysHere);
    plot(daysPlot,fitVal,'k','LineWidth',2)
    [~, ~, ~, RR(ii), Pval(ii), ~] =...
                fitLinRegSL(pooledHere,daysHere);
            [Fval(ii),dfNum(ii),dfDen(ii),pVal(ii)] =...
            slopeDiffFromZeroFtest(pooledHere,daysHere);
    [propsRho(ii),propsCorrPval(ii)] = corr(daysHere,pooledHere,'type','Spearman');
    
    title([traitLabels{thingsNow(ii)}])
    
    %xlim([min(daysHere)-0.5 max(daysHere)+0.5])
    ylim(ylimsuse{slI,ii})
    
    aff(ii) = MakePlotPrettySL(aff(ii));
    end
    
    suptitleSL(['Raw splitting pcts across all mice, and regression on ' mazeLocations{slI}])
    
    figure('Position',[735 209 910 420]);
    for ii = 1:4
    text(1,ii,[traitLabels{thingsNow(ii)} ' LinReg R=' num2str(sqrt(abs(RR(ii).Ordinary))) ', p=' num2str(Pval(ii))...
        ', F diff zero F dfNum dfDen p: ' num2str([Fval(ii) dfNum(ii) dfDen(ii) pVal(ii)])...
        ', spearman corr rho pval: ' num2str([propsRho(ii) propsCorrPval(ii)])]) 
    end
    title(['stats for raw data splitter prop changes on ' mazeLocations{slI}])
    xlim([0 18])
    ylim([0 6])
end

%Comparison to num trials
for slI = 1:2
    figure('Position',[695 118 819 674]);
    for ii = 1:4
        pooledHere = [];
        daysHere = [];
        aff(ii)=subplot(2,2,ii);
        for mouseI = 1:4
            
            dayss = sum(numTrialsFull{mouseI},1);
            splitPropHere = splitPropEachDay{slI}{mouseI}{thingsNow(ii)};
            plot(dayss,splitPropHere,'o','MarkerFaceColor',mouseColors(mouseI,:),'MarkerSize',8)
            pooledHere = [pooledHere; splitPropHere(:)];
            daysHere = [daysHere; dayss(:)];
            hold on
        end
        
    ylabel('Proportion of cells')
    xlabel('Number of trials')
    
    [fitVal,daysPlot] = FitLineForPlotting(pooledHere,daysHere);
    plot(daysPlot,fitVal,'k','LineWidth',2)
    [~, ~, ~, RR(ii), Pval(ii), ~] =...
                fitLinRegSL(pooledHere,daysHere);
            [Fval(ii),dfNum(ii),dfDen(ii),pVal(ii)] =...
            slopeDiffFromZeroFtest(pooledHere,daysHere);
    [propsRho(ii),propsCorrPval(ii)] = corr(daysHere,pooledHere,'type','Spearman');
    
    title([traitLabels{thingsNow(ii)}])
    
    %xlim([min(daysHere)-0.5 max(daysHere)+0.5])
    ylim(ylimsuse{slI,ii})
    %xticks([1 6 12 18])
    
    aff(ii) = MakePlotPrettySL(aff(ii));
    end
    
    suptitleSL(['Raw splitting pcts across all mice, and regression on ' mazeLocations{slI}])
    
    figure('Position',[735 209 910 420]);
    for ii = 1:4
    text(1,ii,[traitLabels{thingsNow(ii)} ' LinReg R=' num2str(sqrt(abs(RR(ii).Ordinary))) ', p=' num2str(Pval(ii))...
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
            {colorAssc{1:2}},{'LR','ST'},true,'regress','Change in Decoding Performance',[-0.5 0.5],[]);
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
        text(1,3,['slope spearman corr rho: ' num2str(statsOut{slI}{ddI}.corr.rho) ', pval: ' num2str(statsOut{slI}{ddI}.corr.pVal)])
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
statsOut = []; sps = [];
for slI = 1:2
    figure('Position',[470 342 913 394]); %[729 513 497 340]
    for ccI = 1:length(cellCheck)
        sps{ccI} = subplot(1,length(cellCheck),ccI);
        [statsOut{slI}{ccI}] = PlotBarWithData([pooledDailySources{slI}{ccI}{:}],sourceColors,true,'jitter',sourceLabels);
        ylim([0 1.01])
        title(['Sources for ' traitLabels{cellCheck(ccI)}])
        ylabel('Pct. of cells')
        sps{ccI} = MakePlotPrettySL(sps{ccI});
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
        text(1,5,['Pct. days where category is majority contributor: ' num2str([statsOut{slI}{ccI}.pctMoreThanAllOthers])])
        text(1,6,['means ' num2str([statsOut{slI}{ccI}.means])])
        xlim([0 12]); ylim([0 7])
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

%% What are newly active cells?
%newProps = pooledNewCellProps; newPcts = traitFirstPcts; %new cells 
newProps = pooledNewlyActiveCellProps; newPcts = inactiveTraitPcts;
%newProps = pooledNewlyActiveAndNewCellProps; newPcts = inactiveAndNewPcts;
fg = [];
statsOut = [];
figure('Position',[477 83 324 803]);
for slI = 1:2
    fg{slI} = subplot(2,1,slI);
    % fg{slI} = axes;
    [fg{slI}, statsOut{slI}] = PlotTraitProps(newProps{slI},[3 4 5 8],{[1 2];[2 3];[1 3];[3 4];[2 4];[1 4]},colorAsscAlt,traitLabels,fg{slI}); 
    ylabel('Proportion of Newly Active Cells')
    title(['Proportion of newly Active cells that go to each type on ' mazeLocations{slI}])
end
figure('Position',[680 558 1055 420]); 
for slI = 1:2
    subplot(2,1,slI)
    text(1,1,'comparisons: '); text(3,0.5,num2str([statsOut{slI}.comparisons']))
    text(1,2,['sign rank p ' num2str([statsOut{slI}.signrank.pVal])])
    text(1,3,['sign rank z ' num2str([statsOut{slI}.signrank.zVal])])
    text(1,4,['KS ANOVA p tukey' num2str(statsOut{slI}.ksANOVA.multComps(:,6)')])
    text(1,5,['KS ANOVA: Chi-sq    ' num2str(statsOut{slI}.ksANOVA.tbl{2,5})]) 
    text(1,6,['KS ANOVA: df groups, error, total    ' num2str([statsOut{slI}.ksANOVA.tbl{2:end,3}])])
    text(1,7,'KS ANOVA groups: ') ; text(3,7.5,num2str([statsOut{1}.ksANOVA.multComps(:,1:2)]'))
       
    xlim([0 12]); ylim([0 9])
    title(['Stats for newly active cell proportions on ' splitterLoc{slI}])
end

% New cells prop changes individual
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
            splitPropHere = newPcts{slI}{mouseI}{thingsNow(ii)};
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
        slopePermP(ii) = NaN;
        [slopePermP(ii)] = slopePermutationTest(pkgForSlope,daysPkg,1000);
        [rhoPropsRaw(ii),pValPropsRaw(ii)] = corr(daysHere,pooledHere,'Type','Spearman');
        %title([traitLabels{thingsNow(ii)} ', R=' num2str(sqrt(abs(RR.Ordinary))) ', p=' num2str(Pval)])
        title([traitLabels{thingsNow(ii)}])

        xlim([min(daysHere)-0.5 max(daysHere)+0.5])
        ylim(ylimsuse{slI,ii})
        xticks([2 6 12 18])
        aaa = MakePlotPrettySL(aaa);
    end
    
    suptitleSL(['Raw splitting pcts of newly active cells across all mice, and regression on ' mazeLocations{slI}])
    
    figure('Position',[322 269 1255 420]);
    for ii = 1:4
    text(1,ii,[traitLabelsAlt{thingsNow(ii)} ' LinReg R=' num2str(sqrt(abs(RR(ii).Ordinary))) ', p=' num2str(Pval(ii))...
        ',F diff zero F dfNum dfDen p: ' num2str([Fval(ii) dfNum(ii) dfDen(ii) pVal(ii)])...
        ', slopePermP= ' num2str(slopePermP(ii)) ', spearman rho, p ' num2str([rhoPropsRaw(ii) pValPropsRaw(ii)])]) 
    end
    title(['stats for raw data new cell splitter prop changes on ' mazeLocations{slI}])
    xlim([0 15])
    ylim([0 6])
end


%Aggregated
gh = [];
statsOut = [];
for slI = 1:2
    gh{slI} = figure;%('Position',[435 278 988 390]);
    [gh{slI},statsOut{slI}] = PlotTraitChangeOverDays(pooledNewlyActiveCellPropChanges{slI},sourceDayDiffsPooled{slI},...
        [3 4 5 8],colorAsscAlt,traitLabels,gh{slI},true,'regress',[-0.75 0.4],'Change in Pct. New Cells this Type',[]); %Num in this case is diff in Pcts.
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
runPermTest = false;
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
        
        text(1,7,['reg slope Spearman corr reg rho, pVal: ' num2str([statsOut{slI}{ddI}.slopeDiffFromZeroCorr.rho(1) ...
            statsOut{slI}{ddI}.slopeDiffFromZeroCorr.pVal(1)])])
        text(1,8,['downsampled slope Spearman corr reg rho, pVal: ' num2str([statsOut{slI}{ddI}.slopeDiffFromZeroCorr.rho(2) ...
            statsOut{slI}{ddI}.slopeDiffFromZeroCorr.pVal(2)])])
        
        text(1,9,['reg diff from lag zero ranksum pVals ' num2str([statsOut{slI}{ddI}.diffFromDayZero(1).rankSums.pVal]) ...
            ', num diff: ' num2str(sum(statsOut{slI}{ddI}.diffFromDayZero(1).rankSums.pVal<0.05))])
        text(1,10,['downsampled diff from lag zero ranksum pVals ' num2str([statsOut{slI}{ddI}.diffFromDayZero(2).rankSums.pVal]) ...
            ', num diff: ' num2str(sum(statsOut{slI}{ddI}.diffFromDayZero(2).rankSums.pVal<0.05))])
        
         text(1,11,['reg diff from lag one ranksum pVals ' num2str([statsOut{slI}{ddI}.diffFromDayOne(1).rankSums.pVal]) ...
            ', num diff: ' num2str(sum(statsOut{slI}{ddI}.diffFromDayOne(1).rankSums.pVal<0.05))])
        text(1,12,['downsampled diff from lag one ranksum pVals ' num2str([statsOut{slI}{ddI}.diffFromDayOne(2).rankSums.pVal]) ...
            ', num diff: ' num2str(sum(statsOut{slI}{ddI}.diffFromDayOne(2).rankSums.pVal<0.05))])
        
        ylim([0 13])
        
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
regDStitle = {'regular','downsampled'};
for slI = 1:2
    figure('Position',[373 137 856 766]);
    for regdsI = 1:2
        subplot(2,1,regdsI)
        text(1,1,['slopeDifference LR vs ST: F,dfNum,dfDen,pVal : '...
            num2str(statsOutDim{slI}{regdsI}.slopeDiffComp.Fval) ' ' num2str(statsOutDim{slI}{regdsI}.slopeDiffComp.dfNum) ' '...
            num2str(statsOutDim{slI}{regdsI}.slopeDiffComp.dfDen) ' ' num2str(statsOutDim{slI}{regdsI}.slopeDiffComp.pVal) ])
         
        text(1,2,['slopeDiffFromZero LR: F,dfNum,dfDen,pVal : '...
            num2str(statsOutDim{slI}{regdsI}.slopeDiffZero.Fval(1)) ' ' num2str(statsOutDim{slI}{regdsI}.slopeDiffZero.dfNum(1)) ' '...
            num2str(statsOutDim{slI}{regdsI}.slopeDiffZero.dfDen(1)) ' ' num2str(statsOutDim{slI}{regdsI}.slopeDiffZero.pVal(1)) ])
        text(1,2.5,['slope spearman corr rho, pval: ' ...
            num2str(statsOutDim{slI}{regdsI}.slopeDiffFromZeroCorr.rho(1)) ' '...
            num2str(statsOutDim{slI}{regdsI}.slopeDiffFromZeroCorr.pVal(1))]);
        text(1,3,['slopeDiffFromZero ST: F,dfNum,dfDen,pVal : '...
            num2str(statsOutDim{slI}{regdsI}.slopeDiffZero.Fval(2)) ' ' num2str(statsOutDim{slI}{regdsI}.slopeDiffZero.dfNum(2)) ' '...
            num2str(statsOutDim{slI}{regdsI}.slopeDiffZero.dfDen(2)) ' ' num2str(statsOutDim{slI}{regdsI}.slopeDiffZero.pVal(2)) ])
        text(1,3.5,['slope spearman corr rho, pval: ' ...
            num2str(statsOutDim{slI}{regdsI}.slopeDiffFromZeroCorr.rho(2)) ' '...
            num2str(statsOutDim{slI}{regdsI}.slopeDiffFromZeroCorr.pVal(2))]);
        text(1,4,['ranksum test each day LR vs ST pVals : ' num2str(statsOutDim{slI}{regdsI}.ranksums.pVal)])
        text(1,5,['sign test each day LR vs ST pVals : ' num2str(statsOutDim{slI}{regdsI}.signtests.pVal)])
        text(1,6,['sign rank test each day LR vs ST pVals : ' num2str(statsOutDim{slI}{regdsI}.signRankTests.pVal)])
        
        xlim([0 15])
        ylim([0 7])
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
    figure('Position',[655 101 890 420]);
    for cdI = 1:2
        subplot(2,1,cdI)
        text(1,1,['slope R, pVal: ' num2str([statsOut{slI}.slope.RR(cdI) statsOut{slI}.slope.pVal(cdI)])])
        text(1,2,['slope diff Zero F, dfNum, dfDen, p: ' num2str([statsOut{slI}.slopeDiffZero.Fval(cdI)...
           statsOut{slI}.slopeDiffZero.dfNum(cdI) statsOut{slI}.slopeDiffZero.dfDen(cdI)...
           statsOut{slI}.slopeDiffZero.pVal(cdI)])])
       
        text(1,3,['line separation signed rank p,z : ' num2str([statsOut{slI}.signrankall{1}.pVal statsOut{slI}.signrankall{1}.zVal])])
        text(1,4, ['spearman rho, pval :' num2str([statsOut{slI}.spearmanSlope.rho(cdI) statsOut{slI}.spearmanSlope.pVal(cdI)])])
        xlim([0 8])
        ylim([0 5])
        title(['stats for within day pv state over time bins' num2str([binsUse{bI}]) ', on ' mazeLocations{slI}...
            ' ' condSetLabels{cdI+1}])
    end
end
end


%% Day diffs population state separation

binsUse = {[1:2];[7:8]};
for bI = 1:length(binsUse)
axHand = []; statsOut = [];
for slI=1:1
    [axHand{slI},statsOut{slI}] = PlotPVcurvesDiffDayDiffs(CSpooledPVcorrs2{slI}{cellCritUse},CSpooledPVdaysApart2{slI}{cellCritUse},...
        binsUse{bI},1,condSetColors,condSetLabels,{true,0.2},[]);
    ylabel('Ensemble State Separation')
    title(['Ensemble state separation, bins ' num2str([binsUse{bI}]) ', on ' mazeLocations{slI}])
    axHand{slI}.XTick = [1 4:4:16];
    legend off
    for dayI = 1:dayLagLimit
        if statsOut{slI}.signranktests{1}.pVal(dayI) < 0.05
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
for slI = 1:1
    figure('Position',[75 129 1816 420]);
    text(1,1,['sign rank tests p: ' num2str([statsOut{slI}.signranktests{1}.pVal])])
    text(1,2,['sign rank tests z: ' num2str([statsOut{slI}.signranktests{1}.zVal])])
    text(1,3,['rankrum tests p: ' num2str([statsOut{slI}.ranksumtests{1}.pVal])])
    text(1,4,['ranksum tests z: ' num2str([statsOut{slI}.ranksumtests{1}.zVal])])
    
    text(1,5,['spearman rho, pval: ' num2str([statsOut{slI}.slopeSpearman.rho(1) statsOut{slI}.slopeSpearman.pVal(1)])])
    text(1,6,['spearman rho, pval: ' num2str([statsOut{slI}.slopeSpearman.rho(2) statsOut{slI}.slopeSpearman.pVal(2)])])
    
    for csI = 1:length(condSet)-1
        text(1,7+csI,['cond ' num2str(csI) ': sign test diff 0 p :' num2str([statsOut{slI}.eachCond{csI}.diffFromZeroSign.pVal])])
        text(1,7.5+csI,['cond ' num2str(csI) ': sign test diff 0 z :' num2str([statsOut{slI}.eachCond{csI}.diffFromZeroSign.zVal])])
    end
    
    xlim([0 15])
    ylim([0 11])
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
[statsOut.ranksum.pVal,statsOut.ranksum.hVal,statss] = ranksum(pooledCOMlrARMex,pooledCOMstARMex);
statsOut.ranksum.zVal = statss.zval;
[statsOut.ksTest.hVal,statsOut.ksTest.pVal] = kstest2(pooledCOMlrARMex,pooledCOMstARMex);

figure;
text(1,1,['ranksum p,h,z = ' num2str([statsOut.ranksum.pVal,statsOut.ranksum.hVal,statsOut.ranksum.zVal])])
text(1,2,['ksTest p,h = ' num2str([statsOut.ksTest.pVal,statsOut.ksTest.hVal])])
ylim([0 3]); xlim([0 8]); title('stats text for COMs on ARMS')
%Stats text


%% PV corrs confusion mats

%Within day self-corr
withinDays = CSpooledPVdaysApartTempATA{slI}{pvtI}{1} == 0;
figure;
for condI = 1:4
    thisConfusionMat = mean(CSpooledPVcorrsEachATA{slI}{pvtI}{condI}(:,:,withinDays),3);
    subplot(2,2,condI)
    imagesc(thisConfusionMat)
    colorbar
    title(cellTBT{1}(condI).name)
    xlabel('Bin i')
    ylabel('Bin j')
    axis equal
    xlim([0.5 numBins+0.5])
    ylim([0.5 numBins+0.5])
end
suptitleSL('Within condition bin vs. bin PV corrs')

figure;
for cscI = 1:length(condSet)
    thisConfusionMat = mean(CSpooledPVcorrs2ATA{slI}{pvtI}{cscI}(:,:,withinDays),3);
    subplot(1,3,cscI)
    imagesc(thisConfusionMat)
    colorbar
    title(condSetLabels{cscI})
    xlabel('Bin i')
    ylabel('Bin j')
    axis equal
    xlim([0.5 numBins+0.5])
    ylim([0.5 numBins+0.5])
end
suptitleSL('Across dimension bin vs. bin PV corrs')
    


%%  PV within a day
cellCritUse = 5;
%StemcondSetColors
jj = []; statsOut = [];
for slI = 1:2
[jj{slI},statsOut{slI}] = PlotPVcurves(CSpooledPVcorrs{slI}{cellCritUse},CSpooledPVdaysApart{slI}{cellCritUse},{[0.5 0.5 0.5];'r';'b'},condSetLabels,true,'STD',[]);
title(['Mean Within-Day Population Vector Correlation on ' splitterLoc{slI} ])
ylim([0 1])
jj{slI}.Children = MakePlotPrettySL(jj{slI}.Children);
end
figure('Position',[489 123 1047 576]);
for slI = 1:2
    subplot(2,1,slI)
    for ccI = 1:size(statsOut{1}.comparisons,1)
        rowHere = 1+3*(ccI-1);
        text(1,rowHere,['comparison ' num2str([statsOut{slI}.comparisons(ccI,:)])])
        text(1,rowHere+1,['ranksum zVal: ' num2str([statsOut{slI}.ranksumtests{ccI}.zVal])])
        text(1,rowHere+2,['ranksum pVal: ' num2str([statsOut{slI}.ranksumtests{ccI}.pVal])])
    end
    xlim([0 45])
    ylim([0 10])
    title(splitterLoc{slI})
end
suptitleSL('PV comparison stats')
figure('Position',[370 403 523 420]);
for slI = 1:2
    subplot(2,1,slI)
    for csI = 1:length(condSet)
        text(1,csI,['spearman rank slope for ' condSetLabels{csI} ' rho, pval: '...
            num2str([statsOut{slI}.eachCond{csI}.rankCorrs.rho statsOut{slI}.eachCond{csI}.rankCorrs.pVal])])
    end
    ylim([0 4])
    xlim([0 20])
end
suptitleSL('PV individual stats')


%% PV Change over days
%binsUse = {[1:2];[7:8]};
binsUse = {[1:2];[3:4];[5:6];[7:8]};
statsOut = [];
for slI = 1:2
    for bI = 1:length(binsUse)
    corrsUse = withinDayCSpooledPVcorrWithinMouseMat{slI}{cellCritUse};
    [figHand,statsOut{slI}{bI}] = PlotPVcurvesRawDays(corrsUse,cellRealDays,binsUse{bI},{'g','r','b'});
    title(['CondSet correlations on ' splitterLoc{slI} ' for bins ' num2str(bI)])
    figHand.Children.XTick=[1 6 12 18];
    ylim([0 0.8])
    figHand.Children = MakePlotPrettySL(figHand.Children);
    end
end

for slI = 1:2
    figure('Position',[579 174 636 562]);
    subplot(2,1,1)
    for bI = 1:length(binsUse)
        text(1,bI,['bins ' num2str(bI) ' spearman corr rho: ' num2str([statsOut{slI}{bI}.spearmanCorr.rho])])
        text(1,bI+0.5,['bins ' num2str(bI) ' spearman corr pval: ' num2str([statsOut{slI}{bI}.spearmanCorr.pVal])])
    end
    xlim([0 20])
    ylim([0 5])
    title('Individual')
    
    subplot(2,1,2)
    numComps = size(statsOut{1}{1}.comps,1);
    for bI = 1:length(binsUse)
        for compI = 1:numComps
            text(1,bI+compI-1+numComps*(compI-1),['bin ' num2str(bI) ' comp ' num2str([statsOut{slI}{bI}.comps(compI,:)])...
                ' ranksum z p ' num2str([statsOut{slI}{bI}.ranksumall{compI}.zVal statsOut{slI}{bI}.ranksumall{compI}.pVal])])
        end
    end
    xlim([0 20])
    ylim([0 15])
    title('Comparisons')
    suptitleSL(['Correlations over time on ' splitterLoc{slI}])
end

%% PV across days
axHand = []; statsOut = [];
for slI = 1:2
    for bI = 1:length(binsUse)
        [axHand{slI}{bI},statsOut{slI}{bI}] = PlotPVcurvesDayDiffs(CSpooledPVcorrs{slI}{cellCritUse},CSpooledPVdaysApart{slI}{cellCritUse},...
            binsUse{bI},1,{[0.5 0.5 0.5],'r','b'},condSetLabels,true,[]);
        title(['PV corr overdays on ' splitterLoc{slI} ' for bins ' num2str([ binsUse{bI}])])

        figure('Position',[62 108 1753 725]);
        subplot(2,1,1)
        text(1,1,['spearman rank slopes rho, pval: ' num2str([statsOut{slI}{bI}.slopeSpearman.rho statsOut{slI}{bI}.slopeSpearman.pVal])])
        for csI = 1:3
        text(1,1+csI,['cond ' num2str(csI) ' sign test v zero p: ' num2str([statsOut{slI}{bI}.eachCond{csI}.diffFromZeroSign.pVal])])
        text(1,1+csI+0.5,['cond ' num2str(csI) ' sign test v zero z: ' num2str([statsOut{slI}{bI}.eachCond{csI}.diffFromZeroSign.zVal])])
        end
        title('sign tests vs. zero')
        xlim([0 30])
        ylim([0 6])

        subplot(2,1,2)
        for csI = 1:3
        text(1,csI,['comp ' num2str(csI) ' ranksum zvals ' num2str([statsOut{slI}{bI}.ranksumtests{csI}.zVal])])
        text(1,csI+0.5,['comp ' num2str(csI) ' ranksum pvals ' num2str([statsOut{slI}{bI}.ranksumtests{csI}.pVal])])
        end
        title('condition comparisons')
        xlim([0 30])
        ylim([0 4])
        suptitleSL(['pv over days stats on ' splitterLoc{slI} ' bins ' num2str(bI)])
   end
end
    