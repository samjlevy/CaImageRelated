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
    title(['Mouse ' num2str(mouseI) ', numCells found by accuracy'])
    %least squares regression
    xlabel('Accuracy'); ylabel('Number of cells')
end

%% Cell persistance histogram
for mouseI = 1:numMice
    figure; 
    histogram(cellPersistHist{mouseI},[0.5:1:max(cellPersistHist{mouseI})+0.5])
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
for mouseI = 1:numMice
    figure;
    bar(dayCellsThatReturnPct{mouseI},0.95)
    ylim([0.5 1]); xlim([0.5 length(dayCellsThatReturnPct{mouseI})+0.5])
    title(['Mouse ' num2str(mouseI) ', pct cells the show up another day'])
    xlabel('Day Number'); ylabel('Pct cells returning')
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

reactivatesLR{mouseI}
    reactivatesST{mouseI} 
    reactivatesLRonly{mouseI} 
    reactivatesSTonly{mouseI}
    reactivatesBOTH{mouseI} 
    reactivatesNone{mouseI} 
    reactivatesANY{mouseI}
%% old splitters



%Maybe all the stuff here should be in analyses?
labels = {'Study LvR','Test LvR','Left SvT','Right SvT'};
for mouseI = 1:numMice
    figure;
    histEdges = [-1.05:0.1:1.05];
    histMids = histEdges(1:end-1)+0.05;
    for cpI = 1:size(discriminationIndex{mouseI},3)
        subplot(4,4,(1:2)+(cpI-1)*2)
        dataPlot = discriminationIndex{mouseI}(:,1,cpI); 
        dataPlot = dataPlot(thisCellSplits{mouseI}{cpI}(:,1));
        histogram(dataPlot, histEdges, 'FaceColor', colorsU{cpI})
        title([ labels{cpI} ' Day 1'])
        %xlabel, ylabel
    end
    %suptitle(['Mouse ' num2str(mouseI) ' DI distribution'])
    
    for cpI = 1:size(discriminationIndex{mouseI},3)
        subplot(4,4,(1:2)+(cpI-1)*2+8)
        dataPlot = discriminationIndex{mouseI}(:,:,cpI); 
        dataPlot(thisCellSplits{mouseI}{cpI}==0) = NaN;
        counts = [];
        for dayI = 1:size(dataPlot,2)
            counts(dayI,:) = histcounts(dataPlot(:,dayI), histEdges);
        end
        bars = mean(counts,1);
        histogram('BinEdges', histEdges, 'BinCounts', bars, 'FaceColor', colorsU{cpI})
        hold on
        for binI = 1:size(counts,2)
            errorB(binI) = standarderrorSL(counts(:,binI)); % This should probably leave out days with 0 in the bin
            plot([histMids(binI) histMids(binI)], [bars(binI)-errorB(binI) bars(binI)+errorB(binI)],...
                'k', 'LineWidth', 2)
        end
        title([ labels{cpI} ' Mean of all days'])
        %xlabel, ylabel
    end
end
    

%% Example splitter cells

% ---> Check sfnFigs1 for examples on how to plot this








