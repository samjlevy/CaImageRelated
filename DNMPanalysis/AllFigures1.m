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

%% Cell activity histograms

% One for trial reliability
%   - maybe just error bars on a histogram across all days? or day one then
%   all w/ errors?
% Another for consecutive laps

%% Splitters
for mouseI = 1:numMice
    figure; hold on; splitterData = [zeros(size(splitterProps{mouseI},2),1), splitterProps{mouseI}'];
    bar(splitterData(:,2:5),'stacked')
    title(['Mouse ' num2str(mouseI) ', Proportion Active cells that split'])
    legend('Study LvR','Test LvR','Left SvT','Right SvT','Location','northeast')
    xlabel('Day Number')
end

colorsU = {'b','c','r','m'};
for mouseI = 1:numMice
    figure; hold on
    for cpI = 1:size(pctSplitters{mouseI},1)
        plot(pctSplitters{mouseI}(cpI,:),colorsU{cpI})
    end
    title(['Mouse ' num2str(mouseI) ', pct of active that split by day'])
    legend('Study LvR','Test LvR','Left SvT','Right SvT')
    xlabel('Day Number'); ylabel('Pct Splitters')
    ylim([0 1])
end

for mouseI = 1:numMice
    figure; hold on
    %numDays = size(pctSplitters{mouseI},2);
    for cpI = 1:size(pctSplitters{mouseI},1)
        plot(accuracy{mouseI},pctSplitters{mouseI}(cpI,:),['o' colorsU{cpI}],'MarkerFaceColor',colorsU{cpI})
    end
    title(['Mouse ' num2str(mouseI) ', pct splitters of active by accuracy'])
    legend('Study LvR','Test LvR','Left SvT','Right SvT','Location','southwest')
    xlabel('Accuracy'); ylabel('Pct Splitters')
    ylim([0 1])
end

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
            errorB(binI) = standarderrorSL(counts(:,binI));
            plot([histMids(binI) histMids(binI)], [bars(binI)-errorB(binI) bars(binI)+errorB(binI)],...
                'k', 'LineWidth', 2)
        end
        title([ labels{cpI} ' Mean of all days'])
        %xlabel, ylabel
    end
end
    

%% Example splitter cells

% ---> Check sfnFigs1 for examples on how to plot this








