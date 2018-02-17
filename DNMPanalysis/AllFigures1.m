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
    title(['Mouse ' num2str(mouseI) ', numCells by accuracy'])
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
