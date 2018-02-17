%% Process all data

mainFolder = 'C:\Users\Sam\Desktop\DNMPfinalData';
mice = {'Bellatrix', 'Polaris', 'Calisto'}; %'Europa'
numMice = length(mice);

%Thresholds
lapPctThresh = 0.25;
consecLapThresh = 3;
xlims = [25.5 56];

for mouseI = 1:numMice
    trialbytrial = []; sortedSessionInds = []; allfiles = [];
    load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'))
    cellTBT{mouseI} = trialbytrial;
    cellSSI{mouseI} = sortedSessionInds;
    cellAllFiles{mouseI} = allfiles;
    
    numDays(mouseI) = size(sortedSessionInds,2);
end

maxDays = max(numDays);

for mouseI = 1:numMice
    accuracy{mouseI} = sessionAccuracy(cellAllFiles{mouseI});
    accyracyRange(mouseI, 1:2) = [mean(accuracy{mouseI}),...
        std(accuracy{mouseI})/sqrt(length(accuracy{mouseI}))];
end

%% Single Cells Stats

% How many cells per day? 
% How many days to cells persist for?
% How many cells above activity threshold per day?
%       - How many laps are the active for, how many consecutive?
%       - How many conditions do they tend to pass criteria for?

for mouseI = 1:numMice
    %Number of cells
    numCellsToday{mouseI} = sum(cellSSI{mouseI} > 0,1);
    cellsTodayRange(mouseI,1:2) = [mean(numCellsToday{mouseI}),...
        std(numCellsToday{mouseI})/sqrt(length(numCellsToday{mouseI}))];
    
    %Cell persistance
    cellPersistHist{mouseI} = sum(cellSSI{mouseI} > 0,2);
    cellPersistRange(mouseI, 1:2) = [mean(cellPersistHist{mouseI}),...
        std(cellPersistHist{mouseI})/sqrt(length(cellPersistHist{mouseI}))];
    
    [dayUse,threshAndConsec] = GetUseCells(cellTBT{mouseI}, lapPctThresh, consecLapThresh);
    %[trialReli,aboveThresh,~,~] = TrialReliability(trialbytrial, lapPctThresh);
    %[consec, enoughConsec] = ConsecutiveLaps(trialbytrial, consecLapThresh);%maxConsec
    
end

%% Place Cells



%% Splitter Cells




% Populations

%% Population Vector Correlations



%% Decoder analysis