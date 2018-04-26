%% All Figs

%% Cells by day
for mouseI = 1:numMice
    figure;
    plot(numCellsToday{mouseI}, '-ob')
    title(['Mouse ' num2str(mouseI) ', numCells ' num2str(cellsTodayRange(mouseI, 1)) ', +/- ' num2str(cellsTodayRange(mouseI, 2))])
    xlabel('Day Number'); ylabel('Number of cells')
end

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

%% Accuracy per day
figure;
for mouseI = 1:numMice
    subplot(3,1,mouseI)
    plot(accuracy{mouseI},'-o','LineWidth',1.5)
    ylabel('Performance')
    ylim([0.5 1])
    title(mice{mouseI})
end
xlabel('Day Number')
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
    ylim([0 1])
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
% Another for consecutive laps

%% Splitters: what proportion per day?
for mouseI = 1:numMice
    figure; hold on
    title(['Mouse ' num2str(mouseI) ', Pct Active cells that split, R = LR, B = ST, G = Both'])
    plot(pctDailySplittersLR{mouseI},'r','LineWidth',1.5)
    plot(pctDailySplittersST{mouseI},'b','LineWidth',1.5)
    plot(pctDailySplittersBOTH{mouseI},'g','LineWidth',1.5)
    plot(pctDailySplittersLRonly{mouseI},'Color',[0.9294    0.6902    0.1294],'LineWidth',1.5)
    plot(pctDailySplittersSTonly{mouseI},'c','LineWidth',1.5)
    xlabel('Day Number')
    ylabel('% Splitters/Active')
    ylim([0 1])
end

%Splitters by accuracy

%Splitter props. by average num conds active

%% Proportion of DI score at extremes
for mouseI = 1:numMice
    figure; 
    subplot(1,2,1)
    plot(pctEdgeLR{mouseI},'b'); hold on;
    plot(pctEdgeLRsplitters{mouseI},'r');
    plot(pctEdgeNOTLRsplitters{mouseI},'m');
    plot(pctEdgeLRboth{mouseI},'g'); ylim([0 1])
    title(['LR Prop. cells w/ edge DI Mouse ' num2str(mouseI)])
    subplot(1,2,2)
    plot(pctEdgeST{mouseI},'b'); hold on;
    plot(pctEdgeSTsplitters{mouseI},'r');
    plot(pctEdgeNOTSTsplitters{mouseI},'m');
    plot(pctEdgeSTboth{mouseI},'g'); ylim([0 1])
    title(['ST Prop. cells w/ edge DI Mouse ' num2str(mouseI)])
    legend('Any','Splitters','non-splitters','both','Location','southwest')
end

%DI distributions
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
    xlabel('Selectivity Score')
    title(['Mouse ' num2str(mouseI) ', distribution of Study/Test DI scores all days'])
end

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
    
%% Reactivation probability
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
%% Pop vector corrs

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
            rowUse = find(((condPairs{mouseI}(:,1)==Conds.(ss{condI})(1))+...
                     (condPairs{mouseI}(:,2)==Conds.(ss{condI})(2)))==2);  
            plot(squeeze(Corrs{mouseI}(dayI,rowUse,:)),'-o','Color',plotColors(dayI,:))
        end
        ylim([-1 1]); xlim([1 size(Corrs{mouseI},3)])
        xlabel('Start             Choice')
        title([ss{condI} ' PV corrs']) 
    end
    suptitleSL(['Mouse ' num2str(mouseI) ', Cells active either cond.'])
end

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
%% Example splitter cells

% ---> Check sfnFigs1 for examples on how to plot this








