%% All Figs


%% Accuracy per day (Fig 1b)
figure;
for mouseI = 1:numMice
    subplot(numMice,1,mouseI)
    plot(accuracy{mouseI},'-o','LineWidth',1.5)
    ylabel('Performance')
    ylim([0.5 1])
    title(mice{mouseI})
end
xlabel('Day Number') 

figure;
for mouseI = 1:numMice
    plot(cellRealDays{mouseI}-(cellRealDays{mouseI}(1)-1),accuracy{mouseI},'-o','LineWidth',1.5)
    hold on
end
ylabel('Performance')
xlabel('Day Number')
ylim([0.5 1])

figure;
for mouseI = 1:numMice
    plot(accuracy{mouseI},'-o','LineWidth',1.5)
    hold on
end
ylabel('Performance')
xlabel('Session Number')
ylim([0.5 1])

%% Splitting Dot plot fig (Fig 1ci)

%Ideally would load pos align
mouseI = 1; dayI = 1;
load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'))
load(fullfile(mainFolder,mice{mouseI},'demoPos','Pos_align.mat'))
%[frames, txt] = xlsread(ls(fullfile(mainFolder,mice{mouseI},'demoPos','*Finalized.xlsx')));
%[start_stop_struct, include_struct, exclude_struct, pooled, correct, lapNumber]...
xfile = ls(fullfile(mainFolder,mice{mouseI},'demoPos','*Finalized.xlsx'));
xfile = fullfile(mainFolder,mice{mouseI},'demoPos',xfile);
[~, include_struct, ~, ~, correct, ~]...
    = GetBlockDNMPbehavior(xfile, 'stem_extended', size(PSAbool,2));
xlims = [8 38]; numBins = 8; cmperbin = (max(xlims)-min(xlims))/numBins;
dotPlotXlim = [-10 10];
dotPlotYlim = [0 50];
dotPlotDemoX = [-4 4];

cellsUse = [14 37];
for cellI = 1:length(cellsUse)
    
    cellRow = sortedSessionInds(cellsUse(cellI),dayI);
    
    ptsHere{1} = correct.include.study_l | correct.include.test_l;
    ptsHere{2} = correct.include.study_r | correct.include.test_r;
    ptsHere{3} = correct.include.study_l | correct.include.study_r;
    ptsHere{4} = correct.include.test_l | correct.include.test_r;
    titlesD = {'Left Turn Activity', 'Right Turn Activity', 'Study Trial Activity', 'Test Trial Activity'};
   
    figure;
    for pp = 1:4
        hh(pp) = subplot(2,2,pp);
        plot(y_adj_cm(ptsHere{pp})*(-1),x_adj_cm(ptsHere{pp}),'.k'); hold on
        plot(y_adj_cm(logical(PSAbool(cellRow,:).*ptsHere{pp}))*(-1),x_adj_cm(logical(PSAbool(cellRow,:).*ptsHere{pp})),'.r')
        title(titlesD{pp})
        
        for binI = 1:numBins+1
            plot(dotPlotDemoX,[xlims(1)+cmperbin*binI-1 xlims(1)+cmperbin*binI-1],'k')
        end
        
        xlim(dotPlotXlim)
        ylim(dotPlotYlim)
    end
    
    suptitleSL(['Cell ' num2str(cellsUse(cellI)) ' Activity by Position, Day ' num2str(dayI)])
end
    

%% Splitter example fig (Fig 1cii)
mouseI = 1;
%cellsUse = [14 36 37 44 18 55];
cellsUse = [14 37];
posUse =  [584   324   305   427];
saveHere = 'C:\Users\Sam\Desktop\Figures\Figs180703';
for cellI = 1:length(cellsUse)
    daysPlot = find(dayUse{mouseI}(cellsUse(cellI),:));
    for daysPlotI = 1:length(daysPlot)
        PlotSplitterFig({cellPooledTMap_unsmoothed{mouseI}{cellsUse(cellI),daysPlot(daysPlotI),:}},...
            [1 2; 3 4], 1, 2, [], [])
            %[1 2 3 4; 1 3 2 4], 1, 2, [], [])
        suptitleSL(['Cell ' num2str(cellsUse(cellI)) ' splitting, day ' num2str(daysPlot(daysPlotI))])
        hh = gcf;
        hh.Position = posUse;
        saveas(hh,fullfile(saveHere,['Cell' num2str(cellsUse(cellI)) 'day' num2str(daysPlot(daysPlotI)) '.png']));
    end
end


%% One condition heatmap over days (Ziv-style) (Figure 1d?)
refDay = 1;
plotDays = 5;
condPlot = 1;
topBuffer = 0.05;
boxSpaceV = 0.0025;
boxSpaceH = 0.025;
bottomBuffer = 0.05;
for mouseI = 1:numMice
    hh = figure('Position',[100 100 1600 900]);
    cellsUse = find(aboveThresh{mouseI}{condPlot}(:,refDay));
    cellsUse = find(sum(aboveThresh{mouseI}{condPlot}(:,refDay:plotDays),2));
    %cellsUse = find(dayUse{mouseI}(:,dayI));
    
    %Also want one sorted by COM
    
    nCells = length(cellsUse);
    boxHeight = (1-topBuffer - bottomBuffer - boxSpaceV*(nCells+1)) / nCells;
    boxWidth = (1-boxSpaceH*(plotDays+1)) / plotDays;
    
    for dayI = 1:plotDays
        for cellI = 1:nCells
            thisPos = [boxSpaceH*dayI+boxWidth*(dayI-1),... %left
                       1-topBuffer-boxSpaceV*(cellI-1)-boxHeight*cellI,...%bottom
                       boxWidth,... %width
                       boxHeight]; %Height
            axes('Position',thisPos)
            imagesc(cellTMap_unsmoothed{mouseI}{cellsUse(cellI),dayI,condPlot})
            caxis([0 1])
            %axis off
            
            set(gca,'YTick',[],'XTick',[])
            if cellI == 1
                title(['Day ' num2str(dayI)])
            end
            if dayI == 1
                set(gca,'YTick',1,'YTickLabel',num2str(cellsUse(cellI)));
            end
        end
        
        xlabel('Position (Bin)')
        nBins = length(cellTMap_unsmoothed{mouseI}{1,1,1});
        set(gca,'XTick',1:nBins,'XTickLabel',{num2str([1:nBins]')});
    end   
end
    
%% Splitters: what proportion per day?

%traitLabels = {'splitLR' 'splitST' 'splitEITHER' 'splitLRonly' 'splitSTonly' 'splitBOTH' 'splitONE' 'dontSplit'};
figure;
for mouseI = 1:numMice
    subplot(numMice,1,mouseI)
    hold on
    title(['Mouse ' num2str(mouseI) ])
    for tgI = 1:length(traitGroups{mouseI})
        plot(splitPropEachDay{mouseI}{tgI},'Color',colorAssc{tgI},'LineWidth',1.5)
    end
    xlabel('Day Number')
    ylabel('% Splitters/Active')
    ylim([0 1])
end
    
%Splitter props. by average num conds active

%% Splitters change by days apart, all mice

sRows = 3;
sCols = ceil(length(pooledSplitPctChangeFWD)/sRows);
figure;
allPlotDays = [pooledDaysApartFWD; pooledDaysApartREV];
for tgI = 1:length(pooledSplitPctChangeFWD)
    subplot(sRows,sCols,tgI)
    allPlotData = [pooledSplitPctChangeFWD{tgI}; pooledSplitPctChangeREV{tgI}];
    plot(allPlotDays,allPlotData,'.','Color',colorAssc{tgI},'MarkerSize',8)
    hold on
    plot([min(allPlotDays) max(allPlotDays)],[0 0],'k')
    ylabel('Change in pct')
    xlabel('Days apart')
    title(traitLabels{tgI})
    ylim([-0.5 0.5])
end

%Comparison
for cpI = 1:size(pairsCompareInd,1)
    figure;
    plot(pooledDaysApartFWD-0.1,pooledSplitPctChangeFWD{pairsCompareInd(pcI,1)},'.','Color',colorAssc{pairsCompareInd(pcI,1)},'MarkerSize',8)
    hold on
    plot(pooledDaysApartFWD+0.1,pooledSplitPctChangeFWD{pairsCompareInd(pcI,2)},'.','Color',colorAssc{pairsCompareInd(pcI,1)},'MarkerSize',8)
    fitX = unique(splitterFitLine{pairsCompareInd(pcI,1)}(:,1));
    
    plot the lin reg. fit line
    
    ylim([-0.5 0.5])
    indicate the r2 of each line
    switch slopeDiffRank(pcI)>=(1*numPerms-numPerms*pThresh); case 1; diffTxt='ARE'; case 0; diffTxt ='ARE NOT'; end
    title([pairsCompare{pcI,1} ' vs ' pairsCompare{pcI,2} ', slopes ' diffTxt ' diff at p = ' num2str(1-slopeDiffRank(pcI)/1000)])
end

shuffSlope
%% Cells by accuracy 
for mouseI = 1:numMice
    figure;
    plot(accuracy{mouseI}, numCellsToday{mouseI}, 'or')
    title(['Mouse ' num2str(mouseI) ', numCells found by Performance'])
    %least squares regression
    xlabel('Performance'); ylabel('Number of cells')
end

%Pooled
figure;
for mouseI = 1:numMice
    hold on
    plot(accuracy{mouseI},numCellsToday{mouseI}, '.','MarkerSize',15)
end
xlabel('Performance'); ylabel('Number of cells')
title('Performance by Number of Cells')


%% Cells by day
for mouseI = 1:numMice
    figure;
    plot(numCellsToday{mouseI}, '-ob')
    title(['Mouse ' num2str(mouseI) ', numCells ' num2str(cellsTodayRange(mouseI, 1)) ', +/- ' num2str(cellsTodayRange(mouseI, 2))])
    xlabel('Day Number'); ylabel('Number of cells')
end

%% Cell persistance histogram
figure;
for mouseI = 1:numMice
    subplot(numMice,1,mouseI) 
    hh = histogram(cellPersistHist{mouseI},[0.5:1:max(cellPersistHist{mouseI})+0.5]);
    hold on
    plot([cellPersistRange(mouseI,1) cellPersistRange(mouseI,1)],[0 hh.Values(1)],'r')
    title(['Mouse ' num2str(mouseI) ', Number of days a cell lasts, mean '...
        num2str(cellPersistRange(mouseI, 1)) ', +/- ' num2str(cellPersistRange(mouseI, 2))])
    xlabel('Number of days found'); ylabel('Number of cells')
end

%% Cells active today
for mouseI = 1:numMice
    figure;
    plot(accuracy{mouseI}, cellsActiveToday{mouseI}, 'or')
    title(['Mouse ' num2str(mouseI) ', numCells active on stem by accuracy'])
    %least squares regression
    xlabel('Accuracy'); ylabel('Number cells active ')
end

for mouseI = 1:numMice
    figure;
    plot(accuracy{mouseI}, cellsActivePct{mouseI}, 'or')
    title(['Mouse ' num2str(mouseI) ', pct of cells active on stem by accuracy'])
    %least squares regression
    xlabel('Accuracy'); ylabel('Pct cells active ')
end


%% Percent cells from any other day
figure;
for mouseI = 1:numMice
    subplot(numMice,1,mouseI)
    bar(dayCellsThatReturnPct{mouseI},0.98,'FaceColor',[0,0.5,0.8])
    ylim([0.5 1]); xlim([0.5 length(dayCellsThatReturnPct{mouseI})+0.5])
    title(['Mouse ' num2str(mouseI) ', pct cells the show up another day'])
    xlabel('Day Number'); ylabel('Pct cells returning')
end

%% Percent cells above activity thresholds by day
figure;
for mouseI = 1:numMice
    subplot(numMice,1,mouseI)
    plot(cellsActivePct{mouseI},'LineWidth',1.5)
    ylim([0 0.2])
    title(['Mouse ' num2str(mouseI) ', pct cells above activity thresholds'])
    xlabel('Day Number')
end

figure;
for mouseI = 1:numMice
    hold on
    plot(accuracy{mouseI},cellsActivePct{mouseI},'.','MarkerSize',15)
    xlim([0.65 1]); ylim([0 0.25])
    title(['Proportion cells above activity thresholds by performance'])
    xlabel('Performance'); ylabel('Proportion Active')
end

%% Conds active per day (above threshold)
for mouseI = 1:numMice
    figure;
    errorbar(dailyNCAmean(mouseI,:),dailyNCAsem(mouseI,:))
    title(['Mean conditions above thresh for active cells, Mouse ' num2str(mouseI)])
    xlabel('Day Number'); ylabel('Mean/SEM conds active'); ylim([0 4])
end

%% Cell activity histograms

% One for trial reliability
%   - maybe just error bars on a histogram across all days? or day one then
%   all w/ errors?
% Another for consecutive laps.


%% Splitters: what proportion per day 2, with slopes
figure;
daysPlotHere = cellRealDays;
%daysPlotHere = cellfun(@(x) 1:length(x),cellRealDays,'UniformOutput',false);
for mouseI = 1:numMice
    subplot(2,2,mouseI)
    hold on
    plot(daysPlotHere{mouseI}, propLRsplitters{mouseI},'r','LineWidth',1.5)
    plot(daysPlotHere{mouseI}, propSTsplitters{mouseI},'b','LineWidth',1.5)
    plot(daysPlotHere{mouseI}, propOneDimSplitters{mouseI},'g','LineWidth',1.5)
    plot(daysPlotHere{mouseI}, propNonSplitters{mouseI},'k','LineWidth',1.5)
    xlabel('Calendar Day')
    %xlabel('Session Number')
    ylabel('Prop of active cells')
    xlim([1 max(daysPlotHere{mouseI})])
    ylim([0 1])
    %slopeStr = {['slope = ' num2str(round(slopeLRsplitters(mouseI),3)), ', rank = ' num2str(slopeRankLRsplitters(mouseI)) ];...
    %            ['slope = ' num2str(round(slopeSTsplitters(mouseI),3)), ', rank = ' num2str(slopeRankSTsplitters(mouseI)) ];...
    %            ['slope = ' num2str(round(slopeOneDimSplitters(mouseI),3)), ', rank = ' num2str(slopeRankOneDimSplitters(mouseI)) ];...
    %            ['slope = ' num2str(round(slopeNonSplitters(mouseI),3)), ', rank = ' num2str(slopeRankNonSplitters(mouseI)) ]};
   %text(1,0.5,slopeStr)
end
suptitleSL('Splitter Type: R = LR, B = ST, G = One Dim. (ex), K = NonSplitter')
%% Splitter dim overlap

figure;
for mouseI = 1:numMice
    subplot(numMice,1,mouseI) 
    hold on
    plot(splitLRalsoSplitSTprop{mouseI},'m','LineWidth',2)
    plot(splitSTalsoSplitLRprop{mouseI},'c','LineWidth',2)
    ylim([0.5 1])
    xlabel('Session Number')
    ylabel('Prop. of splitters')
end
subplot(numMice,1,1)
title('Prop splitters that also split other dimension. m = LR that split ST, c = ST that also split LR')

figure;
for mouseI = 1:numMice
    subplot(numMice,1,mouseI) 
    hold on
    plot(cellRealDays{mouseI},splitLRalsoSplitSTprop{mouseI},'m','LineWidth',2)
    plot(cellRealDays{mouseI},splitSTalsoSplitLRprop{mouseI},'c','LineWidth',2)
    ylim([0 1])
    xlabel('Calendar day')
    ylabel('Prop. of splitters')
    title(['Slope is ' num2str(slopeLRalsoST(mouseI)) ', p = ' num2str(1 - (numPerms-slopeRankLRalsoST(mouseI))/numPerms)])
end
suptitleSL('Prop splitters that also split other dimension. m = LR that split ST, c = ST that also split LR')

%% Days each splitter type
for mouseI = 1:numMice
    figure
    subplot(2,2,1)
    histogram(pctDaysLRsplitter{mouseI},0:0.1:1)%(~isnan(pctDaysLRsplitter{mouseI}))
    title('Range days LRsplitter')
    subplot(2,2,2)
    histogram(pctDaysSTsplitter{mouseI},0:0.1:1)
    title('Range days STsplitter')
    subplot(2,2,3)
    histogram(pctDaysOneDimSplitter{mouseI},0:0.1:1)
    title('Range days OneDimSplitter')
    subplot(2,2,4)
    histogram(pctDaysNonSplitter{mouseI},0:0.1:1)
    title('Range days NonSplitter')
end


%% Proportion of DI score at extremes

%DI distributions: currently thows out 0s in bins
allbarColorLR = [0.7020    0.1804    0.4000];
allbarColorST = [0    0.4510    0.7412];
figure;
for mouseI = 1:numMice
    subplot(numMice,2,mouseI*2-1)
    b = bar(pctsDistMeanLR(mouseI,:),0.98,'FaceColor',allbarColorLR);
    b.Parent.XTick = [1 (length(binEdges)/2) length(binEdges)-1];
    b.Parent.XTickLabel = {'-1' '0' '1'};
    hold on
    for binI = 1:length(pctsDistMeanLR(mouseI,:))
        yval = pctsDistMeanLR(mouseI,binI);
        plot([binI binI],[yval+ pctsDistSEMsLR(mouseI,binI) yval- pctsDistSEMsLR(mouseI,binI)],'k','LineWidth',2)
    end
    ylim([0 0.4])
    xlabel('Selectivity Score')
    title(['Mouse ' num2str(mouseI) ', distribution of Left/Right DI scores all days'])
    
    subplot(numMice,2,mouseI*2)
    b = bar(pctsDistMeanST(mouseI,:),0.98,'FaceColor',allbarColorST);
    b.Parent.XTick = [1 (length(binEdges)/2) length(binEdges)-1];
    b.Parent.XTickLabel = {'-1' '0' '1'};
    hold on
    for binI = 1:length(pctsDistMeanST(mouseI,:))
        yval = pctsDistMeanST(mouseI,binI);
        plot([binI binI],[yval+pctsDistSEMsST(mouseI,binI) yval-pctsDistSEMsST(mouseI,binI)],'k','LineWidth',2)
    end
    ylim([0 0.4])
    xlabel('Selectivity Score')
    title(['Mouse ' num2str(mouseI) ', distribution of Study/Test DI scores all days'])
end

%All mice pooled
allbarColorLR = [0.7020    0.1804    0.4000];
allbarColorST = [0    0.4510    0.7412];
figure;
subplot(1,2,1)
b = bar(amPctsDistMeanLR(1,:),0.98,'FaceColor',allbarColorLR);
b.Parent.XTick = [1 (length(binEdges)/2) length(binEdges)-1];
b.Parent.XTickLabel = {'-1' '0' '1'};
hold on
for binI = 1:length(amPctsDistMeanLR(1,:))
        yval = amPctsDistMeanLR(1,binI);
        plot([binI binI],[yval+ amPctsDistSEMsLR(1,binI) yval- amPctsDistSEMsLR(1,binI)],'k','LineWidth',2)
end
    ylim([0 0.4])
    xlabel('Selectivity Score')
    title('All mice all days, distribution of Left/Right DI scores all days')

subplot(1,2,2)
b = bar(amPctsDistMeanST(1,:),0.98,'FaceColor',allbarColorST);
b.Parent.XTick = [1 (length(binEdges)/2) length(binEdges)-1];
b.Parent.XTickLabel = {'-1' '0' '1'};
hold on
for binI = 1:length(amPctsDistMeanST(1,:))
    yval = amPctsDistMeanST(1,binI);
    plot([binI binI],[yval+ amPctsDistSEMsST(1,binI) yval- amPctsDistSEMsST(1,binI)],'k','LineWidth',2)
end
ylim([0 0.4])
xlabel('Selectivity Score')
title('All mice all days, distribution of Study/Test DI scores all days')

for mouseI = 1:numMice
    figure; 
    subplot(1,3,1)
    plot(pctEdgeLR{mouseI},'b'); hold on;
    plot(pctEdgeLRsplitters{mouseI},'r');
    plot(pctEdgeNOTLRsplitters{mouseI},'m');
    plot(pctEdgeLRboth{mouseI},'g'); ylim([0 1])
    xlabel('Session Number')
    title(['LR Prop. cells w/ edge DI Mouse ' num2str(mouseI)])
    subplot(1,3,2)
    plot(pctEdgeST{mouseI},'b'); hold on;
    plot(pctEdgeSTsplitters{mouseI},'r');
    plot(pctEdgeNOTSTsplitters{mouseI},'m');
    plot(pctEdgeSTboth{mouseI},'g'); ylim([0 1])
    xlabel('Session Number')
    title(['ST Prop. cells w/ edge DI Mouse ' num2str(mouseI)])
    legend('Any','Splitters','non-splitters','both','Location','southwest')
    subplot(1,3,3)
    plot(pctEdgeLR{mouseI},'b'); hold on
    plot(pctEdgeST{mouseI},'r');
    plot(pctEdgeLRsplitters{mouseI},'c');
    plot(pctEdgeSTsplitters{mouseI},'m');
    legend('All LR','All ST','LRsplitters','ST splitters')
end

%Group pooling, looking at splitter scores
hh = figure; axes;
labels = {'All LR', 'All ST', 'LR split LR', 'ST split ST', 'Not LR splitters LR', 'Not St splittersST', 'LR of STsplitters', 'ST of LRsplitters'};
dataHere = {allMiceEdgeLR, allMiceEdgeST, allMiceEdgeLRsplitters, allMiceEdgeSTsplitters,...
    allMiceEdgeNOTLRsplitters, allMiceEdgeNOTSTsplitters, allMiceEdgeLRforSTsplitters, allMiceEdgeSTforLRsplitters};
scatterBoxWrapper(hh.Children, 1, labels, numDays, dataHere)
title('All mice, all days, Prop cells with edge DI score')
ylim([0 1]); ylabel('prop with Edge DI score'); hold on
for tpI = 1:size(testPairs,1)
    plotH = (max([max(dataHere{testPairs(tpI,1)}) max(dataHere{testPairs(tpI,2)})]) + 0.025)*ones(1,2);
    plotX = hh.Children.XTick(testPairs(tpI,:));
    plot(plotX, plotH, 'k', 'LineWidth', 1.5)
    switch edgeh(tpI)
        case 1
            txtPlot = ['p = ' num2str(edgep(tpI))];
        case 0 
            txtPlot = 'n.s.';
    end
    text(mean(plotX), plotH(1)+ 0.025, txtPlot, 'HorizontalAlignment', 'center')
end

%Group N/N+1 change
dataHere = {allMicePctEdgeLRchange, allMicePctEdgeSTchange, allMicePctEdgeLRsplittersChange,...
        allMicePctEdgeSTsplittersChange, allMicePctEdgeLRforSTsplittersChange, allMicePctEdgeSTforLRsplittersChange};
scatterBoxWrapper([], 1, {'LR','ST','LRsplitters','STsplitters' 'LR for STsplitters', 'ST for LRsplitters'},numDays,dataHere)
title('All mice pct change day N to N+1 prop. with Edge DI score by type')
ylabel('Change in prop w/ Edge DI score'); ylim([-0.5 0.5])


%DI scores for place cells
hh = figure; axes;
dataHere = {allMiceEdgeLRplace, allMiceEdgeSTplace, allMiceEdgeLRnonPlace, allMiceEdgeSTnonPlace};
labels = {'place LR', 'place ST', 'non-place LR', 'non-place ST'};
scatterBoxWrapper(hh.Children, 1, labels, numDays, dataHere)
title('All mice, pct cells with edge DI score by type')
ylabel('prop with Edge DI score'); ylim([0 1])
for tpI = 1:size(testPairs,1)
    plotH = (max([max(dataHere{testPairs(tpI,1)}) max(dataHere{testPairs(tpI,2)})]) + 0.025)*ones(1,2);
    plotX = hh.Children.XTick(testPairs(tpI,:));
    plot(plotX, plotH, 'k', 'LineWidth', 1.5)
    switch edgeplaceH(tpI)
        case 1
            txtPlot = ['p = ' num2str(edgeplaceP(tpI))];
        case 0 
            txtPlot = 'n.s.';
    end
    text(mean(plotX), plotH(1)+ 0.025, txtPlot, 'HorizontalAlignment', 'center')
end

%Group N/N+1 change
dataHere = {allMicePctEdgeLRplaceChange, allMicePctEdgeSTplaceChange, allMicePctEdgeLRnonPlaceChange, allMicePctEdgeSTnonPlaceChange};
labels = {'place LR', 'place ST', 'non-place LR', 'non-place ST'};
scatterBoxWrapper([], 1, labels, numDays, dataHere)
title('All mice pct change day N to N+1 proportion of place cells with edge DI score')
ylabel('prop. with edge DI score'); ylim([-0.55 0.55])

%% Splitter breakdown

%Reactivation
for mouseI = 1:numMice
    subplot(numMice,1,mouseI)
    hold on
    plot(reactivatesSplitterLR(mouseI).prop,'r')
    plot(reactivatesSplitterST(mouseI).prop,'b')
    plot(reactivatesSplitterLRonly(mouseI).prop,'m')
    plot(reactivatesSplitterSTonly(mouseI).prop,'c')
    title(['Mouse ' num2str(mouseI)])
    ylim([0 1]); ylabel('Prop. reac')
end
xlabel('Day number')
suptitleSL('Splitter Proportion Reactivated, R=LR, B=ST, M=LRonly, C=STonly')

%N/N+1 change
hh = figure; axes;
mouseIDvec = []; for mouseI = 1:numMice; mouseIDvec = [mouseIDvec; ones(numDays(mouseI)-1,1)*mouseI]; end
numDataPts = length(pooledPctChangeSplitterLR);
grps = repmat(1:6,numDataPts,1); grps = grps(:);
dataHere = [pooledPctChangeSplitterLR(:); pooledPctChangeSplitterST(:);...
            pooledPctChangeSplitterLRonly(:);  pooledPctChangeSplitterSTonly(:);...
            pooledSplittersANYchange(:); pooledSplittersEXanyChange(:);];
mousecolors2 = [1 0 0; 0 1 0; 0 0 1];
colorsHere = mousecolors2(mouseIDvec,:);
colorsHere = repmat(colorsHere,6,1);
xLabels = {'LR splitters', 'ST splitters', 'LR-only splitters', 'ST-only splitters', 'All Splitters', 'All Splitters-only'};
scatterBoxSL(dataHere, grps, 'xLabel', xLabels, 'plotBox', true, 'circleColors', colorsHere, 'transparency', 0.5, 'plotHandle',hh.Children)
title('All mice, all days, Pct. Proportion Change by Trait Type')
ylim([-0.5 0.5]); ylabel('Change From day before')
hold on; plot(hh.Children.XLim,[0 0],'-r')


%% Proportion place cells
for mouseI = 1:numMice
    figure; hold on
    for condI = 1:4
        plot(placeProps{mouseI}(condI,:))
    end
    plot(totalPropPlace{mouseI},'k','LineWidth',2)
    legend('Study L', 'Study R', 'Test L', 'Test R','Location','northwest')
    title(['Mouse ' num2str(mouseI) ', Proportion place cells by condition'])
    xlabel('Day Number'); ylim([0 1])
end


%% Proportion conds active also place
for mouseI = 1:numMice
    figure; hold on
    errorbar(dailyPropCondsWherePlace{mouseI}(1,:),dailyPropCondsWherePlace{mouseI}(2,:))
    title(['Mouse ' num2str(mouseI) ', Proportion conds active also place'])
    xlabel('Day Number'); %ylim([0 1])
end

%% Place or splitter prop by day

for mouseI = 1:numMice
    figure; hold on
    subplot(2,1,1)
    hold on
    plot(pctDailySplittersANY{mouseI},'r','LineWidth',1.5)
    plot(pctDailySplittersEXany{mouseI},'m','LineWidth',1.5)
    plot(totalPropPlace{mouseI},'b','LineWidth',1.5)
    ylim([0 1])
    title(['Mouse ' num2str(mouseI) ', Proportion of splitter and place cells'])
    legend('Splitter', 'SplittersEX', 'Place')
    subplot(2,1,2)
    hold on
    plot(pctDailyPlaceAndSplitter{mouseI},'g','LineWidth',1.5)
    plot(pctDailyPlaceNotSplitter{mouseI},'c','LineWidth',1.5)
    plot(pctDailySplitterNotPlace{mouseI},'m','LineWidth',1.5)
    plot(pctDailynotSplitterNotPlace{mouseI},'k','LineWidth',1.5)
    ylim([0 1])
    title('Place and splitter relationship')
    legend('Place and Splitter','Place but not Splitter','Splitter but not Place','Not place not splitter')
    %{
    subplot(3,1,1)
    hold on
    plot(pctDailySplittersLR{mouseI},'r','LineWidth',1.5)
    plot(pctDailySplittersST{mouseI},'b','LineWidth',1.5)
    plot(pctDailySplittersLRonly{mouseI},'c','LineWidth',1.5)
    plot(pctDailySplittersSTonly{mouseI},'m','LineWidth',1.5)
    ylim([0 1])
    title([Splitter
    %}
end


%last day - first day
hh = figure; hold on
mousecolors = {'r','b','g'};
traitsPlot = {placeFLpctCh, splitANYFLpctCh, splitEXanyFLpctCh,splitBOTHFLpctCh, placeAndSplitFLpctCh,...
              placeNotSplitFLpctCh, splitNotPlaceFLpctCh, notSplitNotPlaceFLpctCh};
xlabels = {'Place', 'Splitters', 'SplitersBOTH', 'place and split', 'place NOT split', 'split NOT place', 'NOT split NOT place'};
for labI = 1:length(xlabels)
    for mouseI = 1:numMice
        plot(labI,traitsPlot{labI}(mouseI),'o','MarkerSize',8,'MarkerFaceColor',mousecolors{mouseI})
    end
end
title('All mice, change last day from first pct each trait type')
hold on
xticks = hh.Children.XTick;
xlim([0 hh.Children.XLim(2)+1])
plot(hh.Children.XLim,[0 0],'r')
hh.Children.XTick = xticks;
hh.Children.XTickLabel = xlabels;
hh.Children.XTickLabelRotation = 45;


% last 2 days  - first 2 days
hh = figure; hold on
mousecolors = {'r','b','g'};
traitsPlot = {placeFLpctCh2, splitANYFLpctCh2, splitEXanyFLpctCh2, splitBOTHFLpctCh2, placeAndSplitFLpctCh2,...
              placeNotSplitFLpctCh2, splitNotPlaceFLpctCh2, notSplitNotPlaceFLpctCh2};
xlabels = {'Place', 'Splitters', 'SplitersBOTH', 'place and split', 'place NOT split', 'split NOT place', 'NOT split NOT place'};
for labI = 1:length(xlabels)
    for mouseI = 1:numMice
        plot(labI,traitsPlot{labI}(mouseI),'o','MarkerSize',8,'MarkerFaceColor',mousecolors{mouseI})
    end
end
title('All mice, change last 2 days from first 2 days pct each trait type')
hold on
xticks = hh.Children.XTick;
xlim([0 hh.Children.XLim(2)+1])
plot(hh.Children.XLim,[0 0],'r')
hh.Children.XTick = xticks;
hh.Children.XTickLabel = xlabels;
hh.Children.XTickLabelRotation = 45;

%% Splitters / Place by accuracy
figure;
mousecolors = {'r','b','g'}; %Could add diff shades by splitters/place etc.
for mouseI = 1:numMice
    subplot(1,3,1)
    hold on
    plot(accuracy{mouseI},totalPropPlace{mouseI},'o','MarkerSize',8,'MarkerFaceColor',mousecolors{mouseI})
    ylim([0 1]); xlim([0.5 1]); ylabel('Proportion place cells'); xlabel('Accuracy')
    title('All mice, place by accuracy')
    subplot(1,3,2)
    hold on
    plot(accuracy{mouseI},pctDailySplittersANY{mouseI},'o','MarkerSize',8,'MarkerFaceColor',mousecolors{mouseI})
    ylim([0 1]); xlim([0.5 1]); ylabel('Proportion Splitters'); xlabel('Accuracy')
    title('All mice, splitters by accuracy')
    subplot(1,3,3)
    hold on
    plot(accuracy{mouseI},pctDailySplittersEXany{mouseI},'o','MarkerSize',8,'MarkerFaceColor',mousecolors{mouseI})
    ylim([0 1]); xlim([0.5 1]); ylabel('Proportion Exclusive Splitters'); xlabel('Accuracy')
    title('All mice, exclusive splitters by accuracy')
end

figure;
mousecolors = {'r','b','g'}; %Could add diff shades by splitters/place etc.
for mouseI = 1:numMice
    subplot(2,2,1)
    hold on
    plot(accuracy{mouseI},pctDailyPlaceAndSplitter{mouseI},'o','MarkerSize',8,'MarkerFaceColor',mousecolors{mouseI})
    ylim([0 1]); xlim([0.5 1]); ylabel('Prop. Place and Splitter'); xlabel('Accuracy')
    subplot(2,2,2)
    hold on
    plot(accuracy{mouseI},pctDailyPlaceNotSplitter{mouseI},'o','MarkerSize',8,'MarkerFaceColor',mousecolors{mouseI})
    ylim([0 1]); xlim([0.5 1]); ylabel('Prop. Place, NOT Splitter'); xlabel('Accuracy')
    subplot(2,2,3)
    hold on
    plot(accuracy{mouseI},pctDailySplitterNotPlace{mouseI},'o','MarkerSize',8,'MarkerFaceColor',mousecolors{mouseI})
    ylim([0 1]); xlim([0.5 1]); ylabel('Prop. Splitter, NOT Place'); xlabel('Accuracy')
    subplot(2,2,4)
    hold on
    plot(accuracy{mouseI},pctDailynotSplitterNotPlace{mouseI},'o','MarkerSize',8,'MarkerFaceColor',mousecolors{mouseI})
    ylim([0 1]); xlim([0.5 1]); ylabel('Prop. NOT Place, NOT Splitter'); xlabel('Accuracy')
end

%% Splitters: num days active by type

%{
numPts = cell2mat(cellfun(@length, activeDaysSplitNone, 'UniformOutput', false))


numSplitLR
     numSplitST
     numSpliyBOTH
  numSplitLRonly
     numSplitSTonly
             numSplitANY
             numSplitEXany
numSplitNone
%}
    
%hh = figure; axes;
%mouseIDvec = []; for mouseI = 1:numMice; mouseIDvec = [mouseIDvec; ones(numDays(mouseI)-1,1)*mouseI]; end
%numDataPts = length(pooledReacBaseline);

grps = [1*ones(1,length(pooledActiveDaysSplitLR)) 2*ones(1,length(pooledActiveDaysSplitST)) 3*ones(1,length(pooledActiveDaysSplitBOTH))... 
        4*ones(1,length(pooledActiveDaysSplitLRonly)) 5*ones(1,length(pooledActiveDaysSplitSTonly)) 6*ones(1,length(pooledActiveDaysSplitANY))...
        7*ones(1,length(pooledActiveDaysSplitEXany)) 8*ones(1,length(pooledActiveDaysSplitNone))];
dataHere = [pooledActiveDaysSplitLR pooledActiveDaysSplitST pooledActiveDaysSplitBOTH... 
            pooledActiveDaysSplitLRonly pooledActiveDaysSplitSTonly pooledActiveDaysSplitANY...
            pooledActiveDaysSplitEXany pooledActiveDaysSplitNone];
%mousecolors2 = [1 0 0; 0 1 0; 0 0 1];
%colorsHere = mousecolors2(mouseIDvec,:);
%colorsHere = repmat(colorsHere,9,1);
xLabels = {'SplitLR', 'SplitST', 'SplitBOTH', 'SplitLRex', 'SplitSTex', 'SplitANY', 'SplitEXany', 'SplitNone'};
scatterBoxSL(dataHere, grps, 'xLabel', xLabels, 'plotBox', true) %'circleColors', colorsHere, 'plotHandle',hh.Children
title('All mice, Number Days Active by Splitter Type')
ylabel('Mean days active')


figure;
bar([mean(pooledActiveDaysSplitLR) mean(pooledActiveDaysSplitST) mean(pooledActiveDaysSplitBOTH)... 
     mean(pooledActiveDaysSplitLRonly) mean(pooledActiveDaysSplitSTonly) mean(pooledActiveDaysSplitANY)...
     mean(pooledActiveDaysSplitEXany) mean(pooledActiveDaysSplitNone)])
 title('Mean days active by type')
 
 figure; 
bar([standarderrorSL(pooledActiveDaysSplitLR) standarderrorSL(pooledActiveDaysSplitST) standarderrorSL(pooledActiveDaysSplitBOTH)... 
     standarderrorSL(pooledActiveDaysSplitLRonly) standarderrorSL(pooledActiveDaysSplitSTonly) standarderrorSL(pooledActiveDaysSplitANY)...
     standarderrorSL(pooledActiveDaysSplitEXany) standarderrorSL(pooledActiveDaysSplitNone)])
 title('Standard error')
 
  grps = [length(pooledActiveDaysSplitLR) length(pooledActiveDaysSplitST) length(pooledActiveDaysSplitBOTH)... 
     length(pooledActiveDaysSplitLRonly) length(pooledActiveDaysSplitSTonly) length(pooledActiveDaysSplitANY)...
     length(pooledActiveDaysSplitEXany) length(pooledActiveDaysSplitNone)];
 
%% Place: num days active by cond




%% Portion change splitter/place by days apart

for mouseI = 1:numMice
    figure;
    subplot(3,1,1); hold on
    for ddI = 1:length(PSpctChangeReorg{mouseI})
        plot(ddI*ones(length(PSpctChangeReorg{mouseI}{ddI})),PSpctChangeReorg{mouseI}{ddI},'.','MarkerSize',8)
    end
    plot(meanPSpctChange{mouseI})
    title('Pct Change Place and Splitter')
    subplot(3,1,2); hold on
    for ddI = 1:length(PSxpctChangeReorg{mouseI})
        plot(ddI*ones(length(PSxpctChangeReorg{mouseI}{ddI})),PSxpctChangeReorg{mouseI}{ddI},'.','MarkerSize',8)
    end
    plot(meanPSxpctChange{mouseI})
    title('Pct Change Place, Not-Splitter')
    subplot(3,1,3); hold on
    for ddI = 1:length(PxSpctChangeReorg{mouseI})
        plot(ddI*ones(length(PxSpctChangeReorg{mouseI}{ddI})),PxSpctChangeReorg{mouseI}{ddI},'.','MarkerSize',8)
    end
    plot(meanPxSpctChange{mouseI})
    title('Pct Change Not-Place, Splitter')
    xlabel('Days Apart')
    suptitleSL(['Mouse ' num2str(mouseI) ', Change in pct cell trait'])
end

%by 1-day pair
for mouseI = 1:numMice
    figure;
    hold on
    hi = plot(PSpctChangeReorg{mouseI}{1});
    h(1) = hi(1);
    hi = plot(PSxpctChangeReorg{mouseI}{1});
    h(2) = hi(1);
    hi = plot(PxSpctChangeReorg{mouseI}{1});
    h(3) = hi(1);
    xlabel('1 Day pair change')
    title(['Mouse ', num2str(mouseI) ', day to day change in cell trait'])
    legend(h,'Place and Splitter','Place, Not-Splitter','Not-place, splitter')
end

%% All animals cell round-up
mouseIDvec = [];
for mouseI = 1:numMice
    mouseIDvec = [mouseIDvec; ones(numDays(mouseI),1)*mouseI];
end

numDataPts = length(pooledPctDailySplittersAny);
grps = repmat(1:8,numDataPts,1); grps = grps(:);
dataHere = [pooledPctDailySplittersAny(:); pooledPctDailySplittersEXany(:);...
            pooledPctDailySplittersBOTH(:); pooledTotalPropPlace(:);...
            pooledPlaceAndSplitter(:); pooledPlaceNotSplitter(:);...
            pooledSplitterNotPlace(:); pooledNotSplitterNotPlace(:);];
mousecolors = {'r','b','g'};
mousecolors2 = [1 0 0; 0 1 0; 0 0 1];
colorsHere = mousecolors2(mouseIDvec,:);
colorsHere = repmat(colorsHere,8,1);
%colorNums = repmat(mouseIDvec,7,1);
%scatColors = mousecolors(colorNums); scatColors =[scatColors{:}];
xLabels = {'Splitters', 'EX-Split', 'Split-BOTH', 'Place', 'Place and Split', 'Place NOT Split', 'Split NOT Place', 'NOT Split NOT place'};
scatterBoxSL(dataHere, grps, 'xLabel', xLabels, 'plotBox', true, 'circleColors', colorsHere, 'transparency', 0.5)
title('All mice, all days, Proportion of each Trait Type of Active Cells')
ylim([0 1]); ylabel('Proportion each type')

%% Reactivation probability
%Pooled
hh = figure; axes;
mouseIDvec = []; for mouseI = 1:numMice; mouseIDvec = [mouseIDvec; ones(numDays(mouseI)-1,1)*mouseI]; end
numDataPts = length(pooledReacBaseline);
grps = repmat(1:9,numDataPts,1); grps = grps(:);
dataHere = [pooledReacBaseline(:); pooledReacPlace(:); pooledReacSplitter(:);...
            pooledReacSplitterEx(:);  pooledReacSplitterBOTH(:); pooledReacPlaceAndSplit(:);...
            pooledReacPlaceNotSplit(:); pooledReacSplitNotPlace(:); pooledReacNotPlaceNotSplit(:);];
mousecolors2 = [1 0 0; 0 1 0; 0 0 1];
colorsHere = mousecolors2(mouseIDvec,:);
colorsHere = repmat(colorsHere,9,1);
xLabels = {'Baseline', 'Place', 'Splitter', 'EX-Split', 'Split-BOTH', 'Place and Split', 'Place NOT Split', 'Split NOT Place', 'NOT Split NOT place'};
scatterBoxSL(dataHere, grps, 'xLabel', xLabels, 'plotBox', true, 'circleColors', colorsHere, 'transparency', 0.5, 'plotHandle',hh.Children)
title('All mice, all days, Reactivation Probability by Trait Type')
ylim([0 1]); ylabel('Proportion Reactivated')
hold on
plot(hh.Children.XLim,[0 0],'-r')


%% Pct. Day N-to-N+1 count trait change
%Pooled
mouseIDvec = []; for mouseI = 1:numMice; mouseIDvec = [mouseIDvec; ones(numDays(mouseI)-1,1)*mouseI]; end
numDataPts = length(pooledPlaceChange);
grps = repmat(1:8,numDataPts,1); grps = grps(:);
dataHere = [pooledPlaceChange(:); pooledSplittersANYchange(:); pooledSplittersEXanyChange(:);...
            pooledSplittersBOTHChange(:); pooledPlaceAndSplitterChange(:); pooledPlaceNotSplitterChange(:);...
            pooledSplitterNotPlaceChange(:); pooledNotSplitterNotPlaceChange(:);];
mousecolors2 = [1 0 0; 0 1 0; 0 0 1];
colorsHere = mousecolors2(mouseIDvec,:);
colorsHere = repmat(colorsHere,8,1);        
xLabels = {'Place', 'Splitter', 'EX-Split', 'Split-BOTH', 'Place and Split', 'Place NOT Split', 'Split NOT Place', 'NOT Split NOT place'};
scatterBoxSL(dataHere, grps, 'xLabel', xLabels, 'plotBox', true, 'circleColors', colorsHere, 'transparency', 0.5)
title('All mice, all  Day N-to-N+1 pairs, Diff in pct. cells each trait type')
ylim([-0.5 0.5]); ylabel('Proportion Reactivated')

%% Firing COM

%Individual mice
for mouseI = 1:numMice
    figure;
    subplot(3,2,1)
    histogram(COMsplittersLR{mouseI},0.5:1:numBins+0.5)
    title('LR splitters')
    subplot(3,2,2)
    histogram(COMsplittersST{mouseI},0.5:1:numBins+0.5)
    title('ST splitters')
    subplot(3,2,3)
    histogram(COMsplittersLRonly{mouseI},0.5:1:numBins+0.5)
    title('LR splitters only')
    subplot(3,2,4)
    histogram(COMsplittersSTonly{mouseI},0.5:1:numBins+0.5)
    title('ST splitters only')
    subplot(3,2,5)
    histogram(COMsplittersEXonly{mouseI},0.5:1:numBins+0.5)
    title('EX splitters only'); xlabel('Bin #')
    subplot(3,2,6)
    histogram(COMsplittersBOTH{mouseI},0.5:1:numBins+0.5)
    title('BOTH splitters only'); xlabel('Bin #')
    suptitleSL(['Mouse ' num2str(mouseI) ' Firing COM all cells all days'])
    
    figure;
    
    dataThings = {COMallCells{mouseI}(~isnan(COMallCells{mouseI})),...
                  COMplace{mouseI}(~isnan(COMplace{mouseI})),...
                  COMsplittersANY{mouseI}(~isnan(COMsplittersANY{mouseI})),...
                  COMplaceAndSplitter{mouseI}(~isnan(COMplaceAndSplitter{mouseI})),...
                  COMplaceNotSplitter{mouseI}(~isnan(COMplaceNotSplitter{mouseI})),...
                  COMsplitterNotPlace{mouseI}(~isnan(COMsplitterNotPlace{mouseI})),...
                  COMnotSplitterNotPlace{mouseI}(~isnan(COMnotSplitterNotPlace{mouseI}))};
    grps = cell2mat(cellfun(@length,dataThings,'UniformOutput',false));
end
              
              
%% Reactivation prob old, indiv. mice
for mouseI = 1:numMice
    grps = repmat(1:7,numDays(mouseI)-1,1); grps = grps(:);
    dataHere = [reactivatesLR{mouseI}(2,:), reactivatesST{mouseI}(2,:),... 
                reactivatesLRonly{mouseI}(2,:), reactivatesSTonly{mouseI}(2,:),...
                reactivatesBOTH{mouseI}(2,:), reactivatesANY{mouseI}(2,:),...
                reactivatesNotSplitter{mouseI}(2,:)];
    xLabels = {'LR splitters','ST splitters','LR split-ex','ST split-ex','BOTH split','Any split','Non-splitters'};
    scatterBoxSL(dataHere,grps,'xLabel',xLabels,'plotBox',true)
    title(['Reactivation Probability by Splitter type mouse ' num2str(mouseI) ])
    ylim([0 1])
end

for mouseI = 1:numMice
    grps = repmat(1:6,numDays(mouseI)-1,1); grps = grps(:);
    dataHere = [reactivatesPlaceSL{mouseI}(2,:), reactivatesPlaceSR{mouseI}(2,:),... 
                reactivatesPlaceTL{mouseI}(2,:), reactivatesPlaceTR{mouseI}(2,:),...
               reactivatesPlaceAny{mouseI}(2,:), reactivatesNotPlace{mouseI}(2,:)];
    xLabels = {'Place SL','Place SR','Place TL','Place TR','Place at all','Not place'};
    scatterBoxSL(dataHere,grps,'xLabel',xLabels,'plotBox',true)
    title(['Reactivation Probability by Splitter type mouse ' num2str(mouseI) ])
    ylim([0 1])
end

for mouseI = 1:numMice
    grps = repmat(1:8,numDays(mouseI)-1,1); grps = grps(:);
    dataHere = [reactivatespxsLR{mouseI}(2,:), reactivatespxsST{mouseI}(2,:),...
                reactivatespxsLRonly{mouseI}(2,:), reactivatespxsSTonly{mouseI}(2,:),...
                reactivatespxsBoth{mouseI}(2,:), reactivatespxsNone{mouseI}(2,:),...
                reactivatesSplitterNotPlace{mouseI}(2,:), reactivatesPlaceNotSplitter{mouseI}(2,:)];
    xLabels = {'Place-LR','Place-ST','Place-LRex','Place-STex','Place-BOTH','Place-NonSplitter',...
               'Splitter-NotPlace','Place-NotSplitter'};
    scatterBoxSL(dataHere,grps,'xLabel',xLabels,'plotBox',true)
    title(['Reactivation Probability by Splitter type mouse ' num2str(mouseI) ])
    ylim([0 1])
end


%% Decoder stuff

%Within day results

typePredict = {'leftright', 'studytest'};
grps = [];
correctPts = [];
incorrectPts = [];
correctGrps = [];
incorrectGrps = [];
shuffGrps = [];
pooledShuffPerfR = [];
for mouseI = 1:numMice
    sameDays = cellDaysApart{1}{mouseI}==0;
    dcI = 1;
    for tpI = 1:length(typePredict)
        plotInds = cellSigDecoding{dcI}{mouseI}{tpI};
        
        correctHere = cellDecodePerformance{dcI}{mouseI}{1,tpI}(plotInds' & sameDays);
        incorrectHere = cellDecodePerformance{dcI}{mouseI}{1,tpI}(~plotInds' & sameDays);
        
        correctPts = [correctPts; correctHere];
        incorrectPts = [incorrectPts; incorrectHere];
        
        correctGrps = [correctGrps; tpI*ones(length(correctHere),1)];
        incorrectGrps = [incorrectGrps; tpI*ones(length(incorrectHere),1)];
        
        shuffPerf = cellDecodePerformance{dcI}{mouseI}(2:end,tpI);
        shuffPerf = cellfun(@(x) x(sameDays), shuffPerf, 'UniformOutput',false);
        shuffPerf = cellfun(@(x) x',shuffPerf,'UniformOutput',false); %Make it straight
        shuffPerfR = cell2mat(shuffPerf); shuffPerfR = shuffPerfR(:);
        
        pooledShuffPerfR = [pooledShuffPerfR; shuffPerfR];
        shuffGrps = [shuffGrps; tpI*ones(length(shuffPerfR),1)];
    end
end
            
figure; axes;
hh = gca;
scatterBoxSL(pooledShuffPerfR,shuffGrps,'plotBox',false,'plotHandle',hh)
hold on
inColors = repmat([1 0 0],length(incorrectPts),1);
scatterBoxSL(incorrectPts,incorrectGrps,'plotBox',false,'circleColors',inColors,'transparency',1,'plotHandle',hh)
coColors = repmat([0 0 1],length(correctPts),1);
scatterBoxSL(correctPts,correctGrps,'plotBox',false,'circleColors',coColors,'transparency',1,'plotHandle',hh)
hh.XTick = [1 2];
hh.XTickLabel = {'Left/Right', 'Study/Test'};
ylabel('Decoding Performance');
title('Within Day Decoding Performance')
ylim([0.2 1.1])
plot([1.25 1.75],[1 1],'k','LineWidth',2)
[p,h]=ranksum(correctPts(correctGrps==1),correctPts(correctGrps==2));
text(1.5, 1+0.025, 'n.s.', 'HorizontalAlignment', 'center')

%Newer, using all mice all types
makePlot = 1;
typePredict = {'leftright', 'studytest'};
pooledShuffPerfR = cell(length(cellSigDecoding),2);
pooledGrps = cell(length(cellSigDecoding),2);
pooledGoodPerf = cell(length(cellSigDecoding),2);
pooledBadPerf = cell(length(cellSigDecoding),2);
pooledGoodDDs = cell(length(cellSigDecoding),2);
pooledBadDDs = cell(length(cellSigDecoding),2);
for dcI = 1:length(cellSigDecoding)
    for mouseI = 1:numMice
        if makePlot==1
        figure;
        end
        dayDiffsUse{mouseI} = cellDaysApart{dcI}{mouseI};
        for condsPlot = 1:2
            shuffPerf = cellDecodePerformance{dcI}{mouseI}(2:end,condsPlot);
            shuffPerf = cellfun(@(x) x',shuffPerf,'UniformOutput',false); %Make it straight
            shuffPerfR = cell2mat(shuffPerf); shuffPerfR = shuffPerfR(:);
            grps = repmat(dayDiffsUse{mouseI}',size(shuffPerf,1),1); grps = grps(:);
            xlabels = cellfun(@num2str,num2cell(unique(dayDiffsUse{mouseI})),'UniformOutput',false);
            plotInds = cellSigDecoding{dcI}{mouseI}{condsPlot};
            correctPts = cellDecodePerformance{dcI}{mouseI}{1,condsPlot}(plotInds); correctDDs = dayDiffsUse{mouseI}(plotInds);
            incorrectPts = cellDecodePerformance{dcI}{mouseI}{1,condsPlot}(~plotInds); incorrectDDs = dayDiffsUse{mouseI}(~plotInds);
            if makePlot==1
            hh = subplot(2,1,condsPlot);
            scatterBoxSL(shuffPerfR,grps,'xLabel',xlabels,'plotBox',false,'plotHandle',hh)%
            hh = gcf;
            hold on
            plot(correctDDs,correctPts,'ob','MarkerFaceColor','b')
            plot(incorrectDDs,incorrectPts,'or','MarkerFaceColor','r')
            xlabel('Days between model and test data'); ylabel('Prop. decoded correctly')
            ylim([0 1])
            title(typePredict{condsPlot})
            end
            
            pooledShuffPerfR{dcI,condsPlot} = [pooledShuffPerfR{dcI,condsPlot}; shuffPerfR];
            pooledGrps{dcI,condsPlot} = [pooledGrps{dcI,condsPlot}; grps];
            pooledGoodPerf{dcI,condsPlot} = [pooledGoodPerf{dcI,condsPlot}; correctPts];
            pooledBadPerf{dcI,condsPlot} = [pooledBadPerf{dcI,condsPlot}; incorrectPts];
            pooledGoodDDs{dcI,condsPlot} = [pooledGoodDDs{dcI,condsPlot}; correctDDs];
            pooledBadDDs{dcI,condsPlot} = [pooledBadDDs{dcI,condsPlot}; incorrectDDs];
        end
        if makePlot==1
        suptitleSL(['Mouse ' num2str(mouseI) ' ' decodeFileName{dcI}])
        end
    end 
end

%Pooled figure
for dcI = 1:length(cellSigDecoding)
    figure;
    for condsPlot = 1:2
        hh = subplot(2,1,condsPlot);
        scatterBoxSL(pooledShuffPerfR{dcI,condsPlot},pooledGrps{dcI,condsPlot},'plotBox',false,'plotHandle',hh)
        hold on
        plot(pooledBadDDs{dcI,condsPlot},pooledBadPerf{dcI,condsPlot},'or','MarkerFaceColor','r')
        plot(pooledGoodDDs{dcI,condsPlot},pooledGoodPerf{dcI,condsPlot},'ob','MarkerFaceColor','b')
        xlabel('Days between model and test data'); ylabel('Prop. decoded correctly')
        ylim([0 1])
        title(typePredict{condsPlot})
    end
    suptitleSL(['All mice ' decodeFileName{dcI}])
end

% Plot performance against number of cells, and overlap 

for dcI = 1:length(cellSigDecoding)
    figure;
    for condsPlot = 1:2
        hh = subplot(2,1,condsPlot); hold on
        goodPlot = cellSigDecoding{dcI}{mouseI}{condsPlot}==1;
        badPlot = cellSigDecoding{dcI}{mouseI}{condsPlot}==0;
        plot(numCellsUsedDecode{dcI}{mouseI}(badPlot,1), cellDecodePerformance{dcI}{mouseI}{1,condsPlot}(badPlot),'or','MarkerFaceColor','r')
        plot(numCellsUsedDecode{dcI}{mouseI}(goodPlot,1), cellDecodePerformance{dcI}{mouseI}{1,condsPlot}(goodPlot), 'ob','MarkerFaceColor','b')
        ylim([0 1]); ylabel('Performance')
        xlabel('Num cells used in model')
        title(typePredict{condsPlot})
    end
    suptitleSL(['Mouse ' num2str(mouseI) ', ' decodeFileName{dcI} ', Decoder performance by pct cells used in model'])
end
       
        
for dcI = 1:length(cellSigDecoding)
figure;
    for condsPlot = 1:2
        hh = subplot(2,1,condsPlot); hold on
        goodPlot = cellSigDecoding{dcI}{mouseI}{condsPlot}==1;
        badPlot = cellSigDecoding{dcI}{mouseI}{condsPlot}==0;
        plot(activeCellsOverlap{dcI}{mouseI}(badPlot,1), cellDecodePerformance{dcI}{mouseI}{1,condsPlot}(badPlot),'or','MarkerFaceColor','r')
        plot(activeCellsOverlap{dcI}{mouseI}(goodPlot,1), cellDecodePerformance{dcI}{mouseI}{1,condsPlot}(goodPlot), 'ob','MarkerFaceColor','b')
        ylim([0 1]); ylabel('Performance')
        xlabel('Num cells used in model')
        title(typePredict{condsPlot})
    end
    suptitleSL(['All mice ' decodeFileName{dcI} ', Decoder performance by num cells overlap model and test'])
end
        
for dcI = 1:length(cellSigDecoding)
figure;
    for condsPlot = 1:2
        hh = subplot(2,1,condsPlot); hold on
        goodPlot = cellSigDecoding{dcI}{mouseI}{condsPlot}==1;
        badPlot = cellSigDecoding{dcI}{mouseI}{condsPlot}==0;
        plot(overlapWithModel{dcI}{mouseI}(badPlot,1), cellDecodePerformance{dcI}{mouseI}{1,condsPlot}(badPlot),'or','MarkerFaceColor','r')
        plot(overlapWithModel{dcI}{mouseI}(goodPlot,1), cellDecodePerformance{dcI}{mouseI}{1,condsPlot}(goodPlot), 'ob','MarkerFaceColor','b')
        ylim([0 1]); ylabel('Performance')
        xlabel('Num cells used in model')
        title(typePredict{condsPlot})
    end
    suptitleSL(['All mice ' decodeFileName{dcI} ', Decoder performance by num cells overlap model and test / num model'])
end

for dcI = 1:length(cellSigDecoding)
figure;
    for condsPlot = 1:2
        hh = subplot(2,1,condsPlot); hold on
        goodPlot = cellSigDecoding{dcI}{mouseI}{condsPlot}==1;
        badPlot = cellSigDecoding{dcI}{mouseI}{condsPlot}==0;
        plot(overlapWithTest{dcI}{mouseI}(badPlot,1), cellDecodePerformance{dcI}{mouseI}{1,condsPlot}(badPlot),'or','MarkerFaceColor','r')
        plot(overlapWithTest{dcI}{mouseI}(goodPlot,1), cellDecodePerformance{dcI}{mouseI}{1,condsPlot}(goodPlot), 'ob','MarkerFaceColor','b')
        ylim([0 1]); ylabel('Performance')
        xlabel('Num cells used in model')
        title(typePredict{condsPlot})
    end
    suptitleSL(['All mice ' decodeFileName{dcI} ', Decoder performance by num cells overlap model and test / num test'])
end
            
            

condTitles = {'Study LvR', 'Test LvR', 'Left SvT', 'Right SvT'};

%Made from LR splitters
for mouseI = 1:numMice
    for condsPlot = 1:2
        shuffPerf = decodeLRperf{mouseI}(2:end,condsPlot);
        shuffPerf = cellfun(@(x) x',shuffPerf,'UniformOutput',false);
        shuffPerfR = cell2mat(shuffPerf); shuffPerfR = shuffPerfR(:);
        grps = repmat(daysApart{mouseI}',size(shuffPerf,1),1); grps = grps(:);
        xlabels  = cellfun(@num2str,num2cell(unique(daysApart{mouseI})),'UniformOutput',false);
        scatterBoxSL(shuffPerfR,grps,'xLabel',xlabels,'plotBox',false)
        hold on
        plotInds = sigDecodingLR{mouseI}{condsPlot};
        plot(daysApart{mouseI}(plotInds),decodeLRperf{mouseI}{1,condsPlot}(plotInds),'ob')
        plot(daysApart{mouseI}(~plotInds),decodeLRperf{mouseI}{1,condsPlot}(~plotInds),'or')
        title(['Mouse ' num2str(mouseI) ', ' condTitles{condsPlot}...
            ' decoding performance with LR splitters; blue above shuffle, red not'])
        xlabel('Days between model and test data'); ylabel('Prop. decoded correctly')
        ylim([0 1])
    end
end
        
%Made from ST splitters
cuse = 3:4;
for mouseI = 1:numMice
    figure;
    for condsPlot = 1:length(cuse)
        hh = subplot(1,2,condsPlot);
        shuffPerf = decodeSTperf{mouseI}(2:end,cuse(condsPlot));
        shuffPerf = cellfun(@(x) x',shuffPerf,'UniformOutput',false);
        shuffPerfR = cell2mat(shuffPerf); shuffPerfR = shuffPerfR(:);
        grps = repmat(daysApart{mouseI}',size(shuffPerf,1),1); grps = grps(:);
        xlabels  = cellfun(@num2str,num2cell(unique(daysApart{mouseI})),'UniformOutput',false);
        scatterBoxSL(shuffPerfR,grps,'xLabel',xlabels,'plotBox',false,'plotHere',hh)
        hold on
        plotInds = sigDecodingST{mouseI}{cuse(condsPlot)};
        plot(daysApart{mouseI}(plotInds),decodeSTperf{mouseI}{1,cuse(condsPlot)}(plotInds),'ob','MarkerFaceColor','b')
        plot(daysApart{mouseI}(~plotInds),decodeSTperf{mouseI}{1,cuse(condsPlot)}(~plotInds),'or','MarkerFaceColor','r')
        %title(['Mouse ' num2str(mouseI) ', ' condTitles{condsPlot}...
        %   ' decoding performance with ST splitters; blue above shuffle, red not'])
        title([ condTitles{cuse(condsPlot)} ' decoding performance'])
        xlabel('Days between model and test data'); ylabel('Prop. decoded correctly')
        ylim([0 1])
    end
    suptitleSL(['Mouse ' num2str(mouseI)])
end      

%Made from All cells
dayDiffsUse = daysApart;
%dayDiffsUse = actualDaysApart;
for mouseI = 1:numMice
    figure;
    for condsPlot = 1:4
        hh = subplot(2,2,condsPlot);
        shuffPerf = decodeAllperf{mouseI}(2:end,condsPlot);
        shuffPerf = cellfun(@(x) x',shuffPerf,'UniformOutput',false);
        shuffPerfR = cell2mat(shuffPerf); shuffPerfR = shuffPerfR(:);
        grps = repmat(dayDiffsUse{mouseI}',size(shuffPerf,1),1); grps = grps(:);
        xlabels  = cellfun(@num2str,num2cell(unique(dayDiffsUse{mouseI})),'UniformOutput',false);
        scatterBoxSL(shuffPerfR,grps,'xLabel',xlabels,'plotBox',false,'plotHere',hh)%
        hh = gcf;
        hold on
        plotInds = sigDecodingAll{mouseI}{condsPlot};
        plot(dayDiffsUse{mouseI}(plotInds),decodeAllperf{mouseI}{1,condsPlot}(plotInds),'ob','MarkerFaceColor','b')
        plot(dayDiffsUse{mouseI}(~plotInds),decodeAllperf{mouseI}{1,condsPlot}(~plotInds),'or','MarkerFaceColor','r')
        %title(['Mouse ' num2str(mouseI) ', ' condTitles{condsPlot}...
        %    ' decoding performance with all splitters; blue above shuffle, red not'])
        title([ condTitles{condsPlot} ' decoding performance'])
        xlabel('Days between model and test data'); ylabel('Prop. decoded correctly')
        ylim([0 1])
    end
    suptitleSL(['Mouse ' num2str(mouseI) ', all cells'])
end    

figure;
    for condsPlot = 1:4
        hh = subplot(2,2,condsPlot);
        shuffPerf = decodeSTperf{mouseI}(2:end,condsPlot);
        shuffPerf = cellfun(@(x) x',shuffPerf,'UniformOutput',false);
        shuffPerfR = cell2mat(shuffPerf); shuffPerfR = shuffPerfR(:);
        grps = repmat(dayDiffsUse{mouseI}',size(shuffPerf,1),1); grps = grps(:);
        xlabels  = cellfun(@num2str,num2cell(unique(dayDiffsUse{mouseI})),'UniformOutput',false);
        scatterBoxSL(shuffPerfR,grps,'xLabel',xlabels,'plotBox',false,'plotHere',hh)%
        hh = gcf;
        hold on
        plotInds = sigDecodingST{mouseI}{condsPlot};
        plot(dayDiffsUse{mouseI}(plotInds),decodeSTperf{mouseI}{1,condsPlot}(plotInds),'ob','MarkerFaceColor','b')
        plot(dayDiffsUse{mouseI}(~plotInds),decodeSTperf{mouseI}{1,condsPlot}(~plotInds),'or','MarkerFaceColor','r')
        %title(['Mouse ' num2str(mouseI) ', ' condTitles{condsPlot}...
        %    ' decoding performance with all splitters; blue above shuffle, red not'])
        title([ condTitles{condsPlot} ' decoding performance'])
        xlabel('Days between model and test data'); ylabel('Prop. decoded correctly')
        ylim([0 1])
    end
    suptitleSL(['Mouse ' num2str(mouseI) ', ST splitters'])
    
    figure;
    for condsPlot = 1:4
        hh = subplot(2,2,condsPlot);
        shuffPerf = decodeLRperf{mouseI}(2:end,condsPlot);
        shuffPerf = cellfun(@(x) x',shuffPerf,'UniformOutput',false);
        shuffPerfR = cell2mat(shuffPerf); shuffPerfR = shuffPerfR(:);
        grps = repmat(dayDiffsUse{mouseI}',size(shuffPerf,1),1); grps = grps(:);
        xlabels  = cellfun(@num2str,num2cell(unique(dayDiffsUse{mouseI})),'UniformOutput',false);
        scatterBoxSL(shuffPerfR,grps,'xLabel',xlabels,'plotBox',false,'plotHere',hh)%
        hh = gcf;
        hold on
        plotInds = sigDecodingLR{mouseI}{condsPlot};
        plot(dayDiffsUse{mouseI}(plotInds),decodeLRperf{mouseI}{1,condsPlot}(plotInds),'ob','MarkerFaceColor','b')
        plot(dayDiffsUse{mouseI}(~plotInds),decodeLRperf{mouseI}{1,condsPlot}(~plotInds),'or','MarkerFaceColor','r')
        %title(['Mouse ' num2str(mouseI) ', ' condTitles{condsPlot}...
        %    ' decoding performance with all splitters; blue above shuffle, red not'])
        title([ condTitles{condsPlot} ' decoding performance'])
        xlabel('Days between model and test data'); ylabel('Prop. decoded correctly')
        ylim([0 1])
    end
    suptitleSL(['Mouse ' num2str(mouseI) ', LR splitters'])
    
    
   
%dayDiffsUse = actualDaysApart;
for mouseI = 1:numMice
    dayDiffsUse{mouseI} = daysApart{mouseI};
    figure;
    for condsPlot = 1:2
        hh = subplot(2,1,condsPlot);
        shuffPerf = decodeAllperf{mouseI}(2:end,condsPlot);
        shuffPerf = cellfun(@(x) x',shuffPerf,'UniformOutput',false);
        shuffPerfR = cell2mat(shuffPerf); shuffPerfR = shuffPerfR(:);
        grps = repmat(dayDiffsUse{mouseI}',size(shuffPerf,1),1); grps = grps(:);
        xlabels  = cellfun(@num2str,num2cell(unique(dayDiffsUse{mouseI})),'UniformOutput',false);
        scatterBoxSL(shuffPerfR,grps,'xLabel',xlabels,'plotBox',false,'plotHandle',hh)%
        hh = gcf;
        hold on
        plotInds = sigDecodingAll{mouseI}{condsPlot};
        plot(dayDiffsUse{mouseI}(plotInds),decodeAllperf{mouseI}{1,condsPlot}(plotInds),'ob','MarkerFaceColor','b')
        plot(dayDiffsUse{mouseI}(~plotInds),decodeAllperf{mouseI}{1,condsPlot}(~plotInds),'or','MarkerFaceColor','r')
        %title(['Mouse ' num2str(mouseI) ', ' condTitles{condsPlot}...
        %    ' decoding performance with all splitters; blue above shuffle, red not'])
        %title([ condTitles{condsPlot} ' decoding performance'])
        xlabel('Days between model and test data'); ylabel('Prop. decoded correctly')
        ylim([0 1])
    end
    suptitleSL(['Mouse ' num2str(mouseI) ', all cells'])
end    

%% Pop.vector corr single day averages

plotColors = {'b', 'r', 'g'};
for mouseI = 1:numMice
    figure; hold on
    for csI = 1:length(condSet)
        plot(dayCorrsMeanCS{mouseI}(:,csI),'-o','Color',plotColors{csI})
    end
    title(['mouse ' num2str(mouseI) ', all trials; B self, R LvR, G SvT'])
end


plotColors = {'b', 'r', 'g'};
for mouseI = 1:numMice
    figure; hold on
    for csI = 1:length(condSet)
        plot(splitDayCorrsMeanCS{mouseI}(:,csI),'-o','Color',plotColors{csI})
    end
    title(['mouse ' num2str(mouseI) ', split sessions; B self, R LvR, G SvT'])
end
    
%% Pop vector corrs all days, 1 day per color

ss = fieldnames(Conds);
for mouseI = 1:numMice
    figure; jetTrips = colormap(jet); close
    jetUse = round(linspace(1,64,numDays(mouseI)));
    plotColors = jetTrips(jetUse,:);
    figure;
    for condI = 1:4
        subplot(2,2,condI)
        for dayI = 1:numDays(mouseI)
            hold on
            %Row for the compairson of this type
            %rowUse = find(((singleDayCondPairs{mouseI}(:,1)==Conds.(ss{condI})(1))+...
            %         (singleDayCondPairs{mouseI}(:,2)==Conds.(ss{condI})(2)))==2);  
            
            plot(squeeze([singleDayCorrs{mouseI}(dayI,condI,:)]),'-o','Color',plotColors(dayI,:))
        end
        ylim([-1 1]); xlim([1 size(singleDayCorrs{mouseI},3)])
        xlabel('Start             Choice')
        title([ss{condI} ' PV corrs']) 
    end
    suptitleSL(['Mouse ' num2str(mouseI) ', Cells active either cond.'])
end

%% Pooled pop vector corrs by days apart

condSet{1} = 1:4;   % VS. Self
condSet{2} = [5 6]; % L v R
condSet{3} = [7 8]; % S v T
plotColors = {'b' 'r' 'g'};
dispNames = {'Within Condition' 'Left vs. Right' 'Study vs Test'};
eachDayDiffs = unique(allDayDiffs); eachDayDiffs = eachDayDiffs(eachDayDiffs > 0);
eachRealDayDiffs = unique(allRealDayDiffs); eachRealDayDiffs = eachRealDayDiffs(eachRealDayDiffs > 0);

%PV by days apart, session days
figure; hold on
clear h
for csI = 1:length(condSet)
    for cpI = 1:length(condSet{csI})
        for ddI = 1:length(eachDayDiffs)
            dataHere = allCorrsMean{condSet{csI}(cpI)}(allDayDiffs==eachDayDiffs(ddI));
            hi = plot(eachDayDiffs(ddI)*ones(length(dataHere),1),dataHere,'.','Color',plotColors{csI});
            h(csI) = hi(1);
        end
    end
end
for csI = 1:length(condSet)
    errorbar(eachDayDiffs,ddMeanLineCS(csI,:),ddSEMlineCS(csI,:),'-o','Color',plotColors{csI},'LineWidth',1.5)
end
ylim([-1 1])
xlabel('Number of Sessions Apart')
ylabel('Mean Correlation')
title('All Mice, Population Vector Corrs by Days Apart')
legend(h,dispNames) 

%PV by days apart, calendar days
figure; hold on
clear h
for csI = 1:length(condSet)
    for cpI = 1:length(condSet{csI})
        for ddI = 1:length(eachRealDayDiffs)
            dataHere = allCorrsMean{condSet{csI}(cpI)}(allRealDayDiffs==eachRealDayDiffs(ddI));
            hi = plot(eachRealDayDiffs(ddI)*ones(length(dataHere),1),dataHere,'.','Color',plotColors{csI});
            h(csI) = hi(1);
        end
    end
end
for csI = 1:length(condSet)
    errorbar(eachRealDayDiffs,ddRealMeanLineCS(csI,:),ddRealSEMlineCS(csI,:),'-o','Color',plotColors{csI},'LineWidth',1.5)
end

ylim([-1 1])
xlabel('Number of Calendar Days Apart')
ylabel('Mean Correlation')
title('All Mice, Population Vector Corrs by Days Apart')
legend(h,dispNames) 


%% Pop vector corrs, split sessions, by days apart USE THIS ONE

condSet{1} = 1:4;   % VS. Self
condSet{2} = [5 6]; % L v R
condSet{3} = [7 8]; % S v T
plotColors = {'b' 'r' 'g'};
dispNames = {'Within Condition' 'Left vs. Right' 'Study vs Test'};
sessDayDiffs = unique(allMiceSplitDayDayDiffsCS{1});
calDayDiffs = unique(allMiceSplitRealDayDayDiffsCS{1});

figure; hold on; clear h
for csI = 1:length(condSet)
    for cpI = 1:length(condSet{csI})
        hi = plot(allMiceSplitDayDayDiffs{condSet{csI}(cpI)},allMiceSplitDayCorrsMean{condSet{csI}(cpI)},'.','Color',plotColors{csI});
        h(csI) = hi(1);
    end
end
for csJ = 1:length(condSet)
    errorbar(sessDayDiffs,ddAllMiceSplitMeanCS(:,csJ),ddAllMiceSplitMeanSEM(:,csJ),'-o','Color',plotColors{csJ},'LineWidth',1.5)
end
xlabel('Number of sessions apart')
title('PV scorrs from day-split data')
legend(h,dispNames)


figure; hold on; clear h
for csI = 1:length(condSet)
    for cpI = 1:length(condSet{csI})
        hi = plot(allMiceSplitRealDayDayDiffs{condSet{csI}(cpI)},allMiceSplitDayCorrsMean{condSet{csI}(cpI)},'.','Color',plotColors{csI});
        h(csI) = hi(1);
    end
end        
for csJ = 1:length(condSet)
    errorbar(calDayDiffs,ddRealAllMiceSplitMeanCS(:,csJ),ddRealAllMiceSplitMeanSEM(:,csJ),'-o','Color',plotColors{csJ},'LineWidth',1.5)
end
%for csJ = 1:length(condSet)
%    plot(rallPooledSplitFitLine{csJ}(:,1),rallPooledSplitFitLine{csJ}(:,2),'--','Color',plotColors{csJ},'LineWidth',1)
%end
xlabel('Number of calendar days apart')
ylabel('Correlation')
title('PV scorrs from day-split data with mean line')
legend(h,dispNames)
ylim([-1 1])

hh = figure; hold on; clear h
for csI = 1:length(condSet)
    for cpI = 1:length(condSet{csI})
        hi = plot(allMiceSplitRealDayDayDiffs{condSet{csI}(cpI)},allMiceSplitDayCorrsMean{condSet{csI}(cpI)},'.','Color',plotColors{csI});
        h(csI) = hi(1);
    end
end        
for csJ = 1:length(condSet)
    plot(rallPooledSplitFitLine{csJ}(:,1),rallPooledSplitFitLine{csJ}(:,2),'-o','Color',plotColors{csJ},'LineWidth',1.5)
end
hh.Position = [680 380 1004 598];
xlabel('Number of calendar days apart')
ylabel('Correlation')
title('PV scorrs from day-split data with lin-regress line')
legend(h,dispNames)
ylim([-1 1])
annotation('textbox',[0.5 0.7 0.25 0.2],'String',annotationToPlot,'FitBoxToText','on')

%Rank sum comparison of each lne
figure; 
y1Height = 0.9;
y2Height = 0.8;
for compI = 1:size(compares,1)
    subplot(3,1,compI)
    hold on
    plot(pooledAllMiceSplitRealDayDayDiffs{compares(compI,1)}+0.05,pooledAllMiceSplitDayCorrsMean{compares(compI,1)},...
        '.','Color',plotColors{compares(compI,1)})
    plot(pooledAllMiceSplitRealDayDayDiffs{compares(compI,2)}-0.05,pooledAllMiceSplitDayCorrsMean{compares(compI,2)},...
        '.','Color',plotColors{compares(compI,2)})
    ylim([-1 1])
    xlim([-0.5 max(calDayDiffs)+0.5])
    xlabel('Number of calendar days apart')
    txtStr = [pPooledSplitDayCal(compI,:)]; 
    txtStr = cellfun(@num2str,num2cell(txtStr),'UniformOutput',false);
    txtStr(hPooledSplitDayCal(compI,:)==0) = deal({'n.s.'});
    txtStr(hPooledSplitDayCal(compI,:)==1) = deal({'*'}); %Unfortunately, no room to plot
    text(calDayDiffs,y2Height*ones(length(calDayDiffs),1),txtStr)
end
subplot(3,1,1)
title('Ranksum difference between lines at each day diff (b = vsSelf, r = LvR, g = SvT)')
        
        
    


%% Pop vector corrs by days apart
%condSet{1} = find(diff(condPairs{mouseI},1,2)==0); %vs. self
%condSet{1} = find(abs(diff(condPairs{mouseI},1,2))==1);
condSet{1} = 1:4;          % vs Self
condSet{2} = [5 10 11 16]; % L v R
condSet{3} = [6 9 12 15];  % S v T
plotColors = {'b', 'r', 'g'};
%dayDiffsUse = daysApart;
dayDiffsUse = actualDaysApart;
for mouseI = 1:numMice
    clear h
    dayDiffs = unique(dayDiffsUse{mouseI});
    figure;
    hold on
    meanLine = []; SEMline = [];
    for csI = 1:length(condSet)
        for ddI = 1:length(dayDiffs)
            dataHere = []; meanCorrs = [];
            dayPairsUse = find(dayDiffsUse{mouseI}==dayDiffs(ddI));
            condPairsUse = condSet{csI};
            dataHere = Corrs{mouseI}(dayPairsUse,condPairsUse,:);
            meanCorrs = mean(dataHere,3); meanCorrs = meanCorrs(:); meanCorrs(isnan(meanCorrs))=[];
            meanLine(csI,ddI) = mean(meanCorrs); SEMline(csI,ddI) = standarderrorSL(meanCorrs);
            hi = plot(ones(length(meanCorrs(:)),1)*dayDiffs(ddI),meanCorrs(:),'.','MarkerSize',10,'Color',plotColors{csI});
            h(csI) = hi(1);
        end
    end
    for csJ = 1:length(condSet)
        errorbar(dayDiffs,meanLine(csJ,:),SEMline(csJ,:),'-o','Color',plotColors{csJ},'LineWidth',1.5)
    end
    ylim([-1 1])
    title(['Mouse ' num2str(mouseI) ', Mean Correlation by Days Apart'])
    legend(h,'Within Condition','Left vs. Right','Study vs. Test','Location','northeast')
    xlabel('Days Apart')
    ylabel('Mean Corr')
end
            


%% Older pooled pv corrs 
condSet{1} = 1:4;   % VS. Self
condSet{2} = [5 6]; % L v R
condSet{3} = [7 8]; % S v T
plotColors = {'b', 'r', 'g'};
allPooledMeans = [];
allPooledDayDiffs = [];
for mouseI = 1:numMice
    dayDiffsUse{mouseI} = pooledDayDiffs{mouseI};
    %dayDiffsUse{mouseI} = pooledRealDayDiffs{mouseI};
    dayDiffsHere = unique(dayDiffsUse{mouseI});
    dayDiffsHere = dayDiffsHere(dayDiffsHere > 0); %Eliminate compare to self
    
    clear h; figure; hold on
    meanLine = [];
    SEMline = [];
    for csI = 1:length(condSet)
        for ddI = 1:length(dayDiffsHere)
            dataHere = []; meanCorrs = [];
            dayPairsUse = find(dayDiffsUse{mouseI}==dayDiffsHere(ddI));
            condPairsUse = condSet{csI};
            dataHere = pooledCorrs{mouseI}(dayPairsUse,condPairsUse,:);
            meanCorrs = mean(dataHere,3); meanCorrs = meanCorrs(:); meanCorrs(isnan(meanCorrs))=[];
            meanLine(csI,ddI) = mean(meanCorrs); SEMline(csI,ddI) = standarderrorSL(meanCorrs);
            ddExpanded = ones(length(meanCorrs(:)),1)*dayDiffsHere(ddI);
            hi = plot(ddExpanded,meanCorrs(:),'.','MarkerSize',10,'Color',plotColors{csI});
            h(csI) = hi(1);
            
            allPooledMeans = [allPooledMeans; meanCorrs];
            allPooledDayDiffs = [allPooledDayDiffs; ddExpanded];
        end
    end
    for csJ = 1:length(condSet)
        errorbar(dayDiffsHere,meanLine(csJ,:),SEMline(csJ,:),'-o','Color',plotColors{csJ},'LineWidth',1.5)
    end
    ylim([-1 1])
    title(['Mouse ' num2str(mouseI) ', Mean Correlation by Days Apart (Pooled)'])
    legend(h,'Within Condition','Left vs. Right','Study vs. Test','Location','northeast')
    xlabel('Days Apart')
    ylabel('Mean Corr')    
end
%% L after R corrs

xaxCorrs{mouseI}
xaxConds = GetTBTconds(xaxTBT{mouseI});
 figure; jetTrips = colormap(jet); close
    jetUse = round(linspace(1,64,numDays(mouseI)));
    plotColors = jetTrips(jetUse,:);
    figure;
    for condI = 1:4
        subplot(2,2,condI)
        for dayI = 1:numDays(mouseI)
            hold on
            rowUse = find(((xaxcondPairs{mouseI}(:,1)==xaxConds.(ss{condI})(1))+...
                     (xaxcondPairs{mouseI}(:,2)==xaxConds.(ss{condI})(2)))==2);  
            plot(squeeze(xaxCorrs{mouseI}(dayI,rowUse,:)),'-o','Color',plotColors(dayI,:))
        end
        ylim([-1 1]); xlim([1 size(xaxCorrs{mouseI},3)])
        xlabel('Start             Choice')
        title([ss{condI} ' PV corrs']) 
    end
    suptitleSL(['Mouse ' num2str(mouseI) ', Cells active either cond.'])

%% Place-by-Splitter
for mouseI = 1:numMice
    figure; hold on
    plot(numPctPXSLR{mouseI}(2,:))
    plot(numPctPXSST{mouseI}(2,:))
    plot(numPctPXSBOTH{mouseI}(2,:))
    plot(numPctPXSLRonly{mouseI}(2,:))
    plot(numPctPXSSTonly{mouseI}(2,:))
    plot(numPctPXSNone{mouseI}(2,:))
    title(['Mouse ' num2str(mouseI) ', Proportion of active cells Place-X-Splitter'])
    xlabel('Day Number'); ylim([0 1])
    legend('LR','ST','BOTH','LRonly','STonly','None','Location','northwest')
end

    
%% Example splitter cells

% ---> Check sfnFigs1 for examples on how to plot this








