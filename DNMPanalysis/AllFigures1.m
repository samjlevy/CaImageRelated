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

%% Splitters
colorsU = {'b','c','r','m'};
for mouseI = 1:numMice
    figure; 
    hold on
    for cpI = 1:size(pctSplitters{mouseI},1)
        plot(pctSplitters{mouseI}(cpI,:),colorsU{cpI})
    end
    title(['Mouse ' num2str(mouseI) ', pct splitters of active by day'])
    legend('Study LvR','Test LvR','Left SvT','Right SvT')
    xlabel('Day Number'); ylabel('Pct Splitters')
    ylim([0 1])
end

for mouseI = 1:numMice
    figure; 
    hold on
    %numDays = size(pctSplitters{mouseI},2);
    for cpI = 1:size(pctSplitters{mouseI},1)
        plot(accuracy{mouseI},pctSplitters{mouseI}(cpI,:),['o' colorsU{cpI}],'MarkerFaceColor',colorsU{cpI})
    end
    title(['Mouse ' num2str(mouseI) ', pct splitters of active by accuracy'])
    legend('Study LvR','Test LvR','Left SvT','Right SvT','Location','southwest')
    xlabel('Accuracy'); ylabel('Pct Splitters')
    ylim([0 1])
end











