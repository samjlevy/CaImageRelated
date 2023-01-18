%AllAnalysesDoublePlus

mainFolder = 'C:\Users\Sam\Desktop\DoublePlus';
load(fullfile(mainFolder,'groupAssign.mat'))
groupNum(strcmpi(groupAssign(:,2),'same')) = 1;
groupNum(strcmpi(groupAssign(:,2),'diff')) = 2;
%mice = {'Kerberos','Marble07','Marble11','Pandora','Styx','Titan'};
mice = groupAssign(:,1)';
groupNames = unique(groupAssign(:,2));
twoEnvMice = find(strcmpi('diff',groupAssign(:,2)));
oneEnvMice = find(strcmpi('same',groupAssign(:,2)));
numMice = length(mice);
groupColors = {[0.3922    0.8314    0.0745],[0.7176    0.2745    1]}; % OneMaze green, TwoMaze purple

dayThree = 3*ones(numMice,1);

sessTypes = {'Turn','Turn','Turn','Place','Place','Place','Turn','Turn','Turn'};
name = {'North-West','South-East';'North-East','South-East'};
binLabelsUse = {['n','m','w'],['s','m','e'];['n','m','e'],['s','m','e']};
armLabels = {'n','w','s','e'};% {'n','e','s','w'}; old
turnArmLabels = armLabels; turnArmLabelsInds = [1 2 3 4];
placeArmLabels = {'n','e','s','e'}; placeArmLabelsInds = [1 4 3 4];

sessDays(strcmpi(sessTypes,'Turn')) = 1; sessDays(strcmpi(sessTypes,'Place')) = 2;

nArmBins = 14;
lgAnchor = load(fullfile(mainFolder,'mainPosAnchor.mat')); 
[lgDataBins,lgPlotBins] = SmallPlusBounds(lgAnchor.posAnchorIdeal,nArmBins,nArmBins-2);  nArmBins = nArmBins - 2;
lgPlotBins.labelNumber = [1:49]';
lgDataBins.labelNumber = [1:49]';
lgBinVertices = {lgDataBins.X, lgDataBins.Y};
locInds = {1 'center'; 2 'north'; 3 'south'; 4 'east'; 5 'west'};
binMidsX = mean(lgDataBins.X,2);
binMidsY = mean(lgDataBins.Y,2);
allMazeBound.Y = [lgDataBins.bounds.north.Y; lgDataBins.bounds.east.Y; lgDataBins.bounds.south.Y; flipud(lgDataBins.bounds.west.Y)];
allMazeBound.X = [flipud(lgDataBins.bounds.north.X); lgDataBins.bounds.east.X; lgDataBins.bounds.south.X; lgDataBins.bounds.west.X];
numBins = size(lgDataBins.X,1);
[binOrderIndex] = SetBinOrder(lgDataBins,armLabels,[]);
lgPlotAll.X = [];
lgPlotAll.Y = [];
for condI = 1:4
    lgPlotHere{condI}.X = lgPlotBins.X(binOrderIndex{condI},:);
    lgPlotHere{condI}.Y = lgPlotBins.Y(binOrderIndex{condI},:);
    lgPlotHere{condI}.labelNumber = lgPlotBins.labelNumber(binOrderIndex{condI});
    lgPlotAll.X = [lgPlotAll.X; lgPlotBins.X(binOrderIndex{condI},:)];
    lgPlotAll.Y = [lgPlotAll.Y; lgPlotBins.Y(binOrderIndex{condI},:)];
end
armLims = [min(abs(lgDataBins.Y(:)))  max(abs(lgDataBins.Y(:)))];
% save(fullfile(mainFolder,'armBoundariesUsed.mat'),'armLabels','lgPlotHere','binOrderIndex','lgDataBins','lgPlotBins','locInds')

% msgbox('See here for bin plot ordering; should be ok')
% so maybe looks like plot bins getting reordered but data bins are not?
% plot pv corrs uses lgPlotHere; TMap_unsmoothedEach gets reordered that
% way; This seems ok, as long as we can be sure other things are getting
% plotted correct too. 
%{
figure;
subplot(1,3,1)
for binI = 1:49
    text(mean(lgDataBins.X(binI,:)),mean(lgDataBins.Y(binI,:)),[num2str(lgDataBins.labelNumber(binI)) ', ' num2str(binI)])
end
ylim([min(lgDataBins.Y(:)) max(lgDataBins.Y(:))]); xlim([min(lgDataBins.X(:)) max(lgDataBins.X(:))])
subplot(1,3,2)
for binI = 1:49
    text(mean(lgPlotBins.X(binI,:)),mean(lgPlotBins.Y(binI,:)),[num2str(lgPlotBins.labelNumber(binI)) ', ' num2str(binI)])
end
ylim([min(lgPlotBins.Y(:)) max(lgPlotBins.Y(:))]); xlim([min(lgPlotBins.X(:)) max(lgPlotBins.X(:))])
plotBins.X = []; plotBins.Y = []; plotBins.labelNumber = [];
for condI = 1:numel(condsUse)
    plotBins.X = [plotBins.X; lgPlotHere{condsUse(condI)}.X];
    plotBins.Y = [plotBins.Y; lgPlotHere{condsUse(condI)}.Y];
    plotBins.labelNumber = [plotBins.labelNumber; lgPlotHere{condsUse(condI)}.labelNumber];
end
subplot(1,3,3)
for binI = 1:size(plotBins.X,1)
    text(mean(plotBins.X(binI,:)),mean(plotBins.Y(binI,:)),[num2str(plotBins.labelNumber(binI)) ', ' num2str(binI)])
end
ylim([min(plotBins.Y(:)) max(plotBins.Y(:))]); xlim([min(plotBins.X(:)) max(plotBins.X(:))])
%}
% For some reason I reordered plot bins, and this is what's getting used
% to plot the pv corrs; looks like this new one is used consistently
%{
figure; plot(allMazeBound.X,allMazeBound.Y); hold on
plot(allMazeBound.X(1),allMazeBound.Y(1),'*r'); plot(allMazeBound.X(end),allMazeBound.Y(end),'og')
%}
% Each Arm Bins
%[binOrderArms] = SetBinOrder(lgDataBins,armLabels,[]);
%binsOrderedArms.X = cellfun(@(x) lgDataBins.X(x,:),binOrderArms,'UniformOutput',false);
%binsOrderedArms.Y = cellfun(@(x) lgDataBins.Y(x,:),binOrderArms,'UniformOutput',false);
eachArmBoundsT{1}.Y = lgDataBins.bounds.north.Y; eachArmBoundsT{2}.Y = lgDataBins.bounds.west.Y;
eachArmBoundsT{3}.Y = lgDataBins.bounds.south.Y; eachArmBoundsT{4}.Y = lgDataBins.bounds.east.Y;
eachArmBoundsT{1}.X = lgDataBins.bounds.north.X; eachArmBoundsT{2}.X = lgDataBins.bounds.west.X;
eachArmBoundsT{3}.X = lgDataBins.bounds.south.X; eachArmBoundsT{4}.X = lgDataBins.bounds.east.X;
eachArmBoundsP = eachArmBoundsT; 
eachArmBoundsP{2}.Y = lgDataBins.bounds.east.Y; eachArmBoundsP{2}.X = lgDataBins.bounds.east.X;
mazeWidth = 5.7150; % cm
binSize = lgBinVertices{1}(5,1) - lgBinVertices{1}(4,1);

minspeed = 1;

pThresh = 0.05;
lapsActiveThresh = 3;
lapPctThresh = 0.25;
consecLapThresh = 3;

disp('loading root data')
for mouseI = 1:numMice
    load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'),'tbtAllEachCorrectThreshMaze')
    load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'),'sortedSessionInds','allfiles','realDays')
    
    cellTBT{mouseI} = tbtAllEachCorrectThreshMaze;
    cellSSI{mouseI} = sortedSessionInds;
    cellAllFiles{mouseI} = allfiles;
    cellRealDays{mouseI} = realDays;
    
    numDays(mouseI) = size(cellSSI{mouseI},2);
    numCells(mouseI) = size(cellSSI{mouseI},1);
    
    clear tbtAllEachCorrectThreshMaze sortedSessionInds allFiles
    
    disp(['Mouse ' num2str(mouseI) ' completed'])
end
cellSSI{1}(:,[5 6]) = 0; % zeroed out cellSSI for mouse 1 days 5-6

numConds = length(cellTBT{1}); % should be 4

%Threshold data by deleting pts below threshold
speedThresh = 1; % cm/s
for mouseI = 1:numMice
    for condI = 1:numConds
        for lapI = 1:numel(cellTBT{mouseI}(condI).trialsX)
            badSpd = cellTBT{mouseI}(condI).trialVelocity{lapI} < speedThresh;
            
            if any(badSpd)
                % Why bad speed? Thought we deleted these already...
                keyboard
            end
            cellTBT{mouseI}(condI).trialsX{lapI}(badSpd) = [];
            cellTBT{mouseI}(condI).trialsY{lapI}(badSpd) = [];
            cellTBT{mouseI}(condI).trialPSAbool{lapI}(:,badSpd) = [];
            cellTBT{mouseI}(condI).trialDFDTtrace{lapI}(:,badSpd) = [];
            cellTBT{mouseI}(condI).trialRawTrace{lapI}(:,badSpd) = [];
            cellTBT{mouseI}(condI).trialVelocity{lapI}(badSpd) = [];
        end
    end
end

disp('Getting reliability')
%reliFileUse = 'trialReli.mat';
reliFileUse = 'trialReliThresh.mat';
for mouseI = 1:numMice
    reliFileName = fullfile(mainFolder,mice{mouseI},reliFileUse);
    if exist(reliFileName,'file')==0
        disp(['Making reliability for mouse ' num2str(mouseI)])
        [dayUse,trialReli,threshAndConsec,numTrials] = TrialReliability2(cellTBT{mouseI},allMazeBound,lapPctThresh, consecLapThresh,[1;2;3;4]);
        [dayUseAll,trialReliAll,threshAndConsecAll,numTrialsAll] = TrialReliability2(cellTBT{mouseI},allMazeBound,lapPctThresh, consecLapThresh,[1 2 3 4]);
        
        save(reliFileName,'dayUse','trialReli','threshAndConsec','numTrials','dayUseAll','trialReliAll','threshAndConsecAll','numTrialsAll')
    end
end
clear dayUse threshAndConsec trialReli dayUseAll threshAndConsecAll trialReliAll %dayUseEach trialReliEach threshAndConsecEach numTrialsEach%dayUse = cell(1,numMice); threshAndConsec = cell(1,numMice);

for mouseI = 1:numMice
    reliFileName = fullfile(mainFolder,mice{mouseI},reliFileUse);
    reliLoad = load(reliFileName);
    
    %dayUse{mouseI} = reliLoad.dayUse;
    trialReli{mouseI} = reliLoad.trialReli; 
    threshAndConsec{mouseI} = reliLoad.threshAndConsec;
    %dayUseAll{mouseI} = reliLoad.dayUseAll;
    trialReliAll{mouseI} = reliLoad.trialReliAll;
    threshAndConsecAll{mouseI} = reliLoad.threshAndConsecAll;
    
    dayUse{mouseI} = reliLoad.numTrials >= lapsActiveThresh;
    dayUseAll{mouseI} = sum(dayUse{mouseI},3)>0;

    numTrialsFired{mouseI} = reliLoad.numTrials;
    for condI = 1:numConds
        for dayI = 1:9
            numSessTrials{mouseI}(dayI,condI) = sum(cellTBT{mouseI}(condI).sessID == dayI);
        end
    end
    
    disp(['Mouse ' num2str(mouseI) ' completed'])
end
disp('done reliability')

disp('checking place fields')
%pfNameUse = 'PFsLinEach.mat';
pfNameUse = 'PFsLinEachThresh.mat';
condPairs = [1; 2; 3; 4];
numCondPairs = size(condPairs,1);
for mouseI = 1:numMice
    pfName= fullfile(mainFolder,mice{mouseI},pfNameUse);
    if exist(pfName,'file')==0
        disp(['no placefields found for ' mice{mouseI} ', making now'])
        binLabels = lgDataBins.labels;
        binVertices = lgBinVertices;
        
        [~,~] = RateMapsDoublePlusV2(cellTBT{mouseI}, lgBinVertices, 'vertices', condPairs, 0, 'zeroOut', pfName, false);
        
        
        load(pfName)
        if mouseI == 1
            for condI = 1:numConds
                [TMap_unsmoothed{:,5,condI}] = deal(zeros(length(lgDataBins.labels),1));
                [TMap_unsmoothed{:,6,condI}] = deal(zeros(length(lgDataBins.labels),1));
            end
            save(pfName,'TMap_unsmoothed','-append')
        end
        
        
        for condI = 1:numConds
            TMap_unsmoothedEach(:,[1:3 7:9],condI) =...
                cellfun(@(x) x(binOrderIndex{turnArmLabelsInds(condI)}),TMap_unsmoothed(:,[1:3 7:9],condI),'UniformOutput',false);
            TMap_unsmoothedEach(:,[4:6],condI) =...
                cellfun(@(x) x(binOrderIndex{placeArmLabelsInds(condI)}),TMap_unsmoothed(:,[4:6],condI),'UniformOutput',false);
        end
        
        save(pfName,'TMap_unsmoothedEach','binLabels','binVertices','-append')
    end
    clear TMap_unsmoothedEach
end
for mouseI = 1:numMice
    pfName= fullfile(mainFolder,mice{mouseI},pfNameUse);
    load(pfName);
    cellTMap{mouseI} = TMap_unsmoothedEach;
    cellFiresAtAll{mouseI} = TMap_firesAtAll;
    % allTMap{mouseI} = cellfun(@(y,z) [y(:); z(:)],cellTMap{mouseI}(:,:,1),cellTMap{mouseI}(:,:,2),'UniformOutput',false);
        % need to re do this more general (not restricted size(3)
end
clear TMap_unsmoothed TMap_firesAtAll
disp('Done loading place fields')

% All single cell corrs
%corrsFile = 'singelCellCorrs.mat'
corrsFile ='singelCellCorrsThresh.mat';
if ~(exist(fullfile(mainFolder,corrsFile),'file')==2)
    for mouseI = 1:numMice
        
        allDayPairs = combnk(1:9,2);
        [singleCellCorrsRho{mouseI}, singleCellCorrsP{mouseI}] = singleNeuronCorrelations(cellTMap{mouseI},allDayPairs,[]);%turnBinsUse
        %{mouseI}{condI}{dayPairI}(cellI)
        
        % Pooled doesn't work because we don't know which conds we'll need
        % Well... probably all 4 or 1 3 4
        pooledTmap = cell(numCells(mouseI),9);
        for cellI = 1:numCells(mouseI)
            for dayI = 1:9
                pooledTmap{cellI,dayI} = vertcat(cellTMap{mouseI}{cellI,dayI,:});
            end
        end
        [singleCellAllCorrsRho{mouseI}, singleCellAllCorrsP{mouseI}] = singleNeuronCorrelations(pooledTmap,allDayPairs,[]);%turnBinsUse
        
        threeConds = [1 3 4];
        pooledTmapThree = cell(numCells(mouseI),9);
        for cellI = 1:numCells(mouseI)
            for dayI = 1:9
                pooledTmapThree{cellI,dayI} = vertcat(cellTMap{mouseI}{cellI,dayI,threeConds});
            end
        end
        [singleCellThreeCorrsRho{mouseI}, singleCellThreeCorrsP{mouseI}] = singleNeuronCorrelations(pooledTmapThree,allDayPairs,[]);%turnBinsUse
    end
    save(fullfile(mainFolder,corrsFile),'singleCellCorrsRho','singleCellCorrsP','singleCellAllCorrsRho','singleCellAllCorrsP','singleCellThreeCorrsRho','singleCellThreeCorrsP','threeConds','allDayPairs')
    clear singleCellCorrsRho singleCellCorrsP singleCellAllCorrsRho singleCellAllCorrsP singleCellThreeCorrsRho singleCellThreeCorrsP threeConds allDayPairs 
end
corrsLoaded = load(fullfile(mainFolder,corrsFile));

disp('Done setup stuff')

%msgbox('Pandora day 6 low correlation from day 5?')

%% Turn1-Turn2 remapping, all day pairs

dayPairsForward = GetAllCombs(1:3,7:9);
dayPairs = dayPairsForward;
numDayPairs = size(dayPairsForward,1);
condsUse = 1:4;
numConds = numel(condsUse);

condsCompare = combnk(condsUse,2);

cellTMapH = cellfun(@(x) x(:,:,condsUse),cellTMap,'UniformOutput',false);

SingleCellRemapping4_2


oneEnvMIagg = []; twoEnvMIagg = [];
for dpI = 1:numDayPairs
    for mouseI = 1:numMice
        miHere = MIdiff{mouseI}{dpI};
        switch groupNum(mouseI)
            case 1
                oneEnvMIagg = [oneEnvMIagg; miHere(:)];
            case 2
                twoEnvMIagg = [twoEnvMIagg; miHere(:)];
        end
    end
end


oneEnvCOMagg = []; twoEnvCOMagg = [];
oneEnvCOMaggEach = cell(1,numConds); twoEnvCOMaggEach = cell(1,length(condsUse));
oneEnvRateAgg = []; twoEnvRateAgg = [];
oneEnvRateAggEach = cell(1,numConds); twoEnvRateAggEach = cell(1,numConds);
oneEnvCorrsAgg = []; twoEnvCorrsAgg = [];
oneEnvCorrsAggEach = cell(1,numConds); twoEnvCorrsAggEach = cell(1,numConds);
oneHaveBoth = []; oneStartFiring = []; oneStopFiring = [];
twoHaveBoth = []; twoStartFiring = []; twoStopFiring = [];
oneHaveBothEach = cell(1,numConds); oneStartFiringEach = cell(1,numConds); oneStopFiringEach = cell(1,numConds);
twoHaveBothEach = cell(1,numConds); twoStartFiringEach = cell(1,numConds); twoStopFiringEach = cell(1,numConds);
oneArmPctChange = []; twoArmPctChange = [];
for dpI = 1:numDayPairs
    % COM shift:
    oneData = oneEnvCOMchanges{dpI}(oneEnvCOMchangesCellsUse{dpI});
    oneEnvCOMagg = [oneEnvCOMagg; oneData];
    
    twoData = twoEnvCOMchanges{dpI}(twoEnvCOMchangesCellsUse{dpI});
    twoEnvCOMagg = [twoEnvCOMagg; twoData];
    
    for condI = 1:length(condsUse)
        oneDataE = oneEnvCOMchanges{dpI}(oneEnvCOMchangesCellsUse{dpI}(:,condI),condI);
        oneEnvCOMaggEach{condI} = [oneEnvCOMaggEach{condI}; oneDataE];
        twoDataE = twoEnvCOMchanges{dpI}(twoEnvCOMchangesCellsUse{dpI}(:,condI),condI);
        twoEnvCOMaggEach{condI} = [twoEnvCOMaggEach{condI}; twoDataE];
    end
    % Rate changes:
  
    oneCellsUse = oneEnvMeanRateCellsUse{dpI}; % This adds the >=3 laps one day; says max but it's the same
    changesHereOne = oneEnvMeanRatePctChange{dpI};
    changesHereOne(oneEnvFiredBoth{dpI}==0) = NaN;
    oneData = changesHereOne(oneCellsUse);
    oneEnvRateAgg = [oneEnvRateAgg; oneData];
    
    twoCellsUse = twoEnvMeanRateCellsUse{dpI};
    changesHereTwo = twoEnvMeanRatePctChange{dpI};
    changesHereTwo(twoEnvFiredBoth{dpI}==0) = NaN;
    %twoData = changesHereTwo;
    twoData = changesHereTwo(twoCellsUse);
    twoEnvRateAgg = [twoEnvRateAgg; twoData];

    for condI = 1:length(condsUse)
        oneDataE = changesHereOne(oneCellsUse(:,condI),condI);
        oneEnvRateAggEach{condI} = [oneEnvRateAggEach{condI}; oneDataE];
        twoDataE = changesHereTwo(twoCellsUse(:,condI),condI);
        twoEnvRateAggEach{condI} = [twoEnvRateAggEach{condI}; twoDataE];
    end
    
    % Single cell corrs:
    oneEnvCorrsAgg = [oneEnvCorrsAgg; oneEnvCorrsAll{dpI}];
    twoEnvCorrsAgg = [twoEnvCorrsAgg; twoEnvCorrsAll{dpI}];
    
    for condI = 1:length(condsUse)
        oneEnvCorrsAggEach{condI} = [oneEnvCorrsAggEach{condI}; oneEnvCorrsEach{dpI,condI}];
        twoEnvCorrsAggEach{condI} = [twoEnvCorrsAggEach{condI}; twoEnvCorrsEach{dpI,condI}];
    end
    
    % Absolute %missing all of this?
    %{
    oneHaveBoth = [oneHaveBoth; oneMazeHaveBothAgg{dpI}]; 
    oneStartFiring = [oneStartFiring; oneMazeStartFiringAgg{dpI}];
    oneStopFiring = [oneStopFiring; oneMazeStopFiringAgg{dpI}];
    twoHaveBoth = [twoHaveBoth; twoMazeHaveBothAgg{dpI}];
    twoStartFiring = [twoStartFiring; twoMazeStartFiringAgg{dpI}];
    twoStopFiring = [twoStopFiring; twoMazeStopFiringAgg{dpI}];
    
    for condI = 1:numConds
        oneHaveBothEach{condI} = [oneHaveBothEach{condI}; oneMazeHaveBothEachAgg{dpI,condI}];
        oneStartFiringEach{condI} = [oneStartFiringEach{condI}; oneMazeStartFiringEachAgg{dpI,condI}];
        oneStopFiringEach{condI} = [oneStopFiringEach{condI}; oneMazeStopFiringEachAgg{dpI,condI}];
        twoHaveBothEach{condI} = [twoHaveBothEach{condI}; twoMazeHaveBothEachAgg{dpI,condI}];
        twoStartFiringEach{condI} = [twoStartFiringEach{condI}; twoMazeStartFiringEachAgg{dpI,condI}];
        twoStopFiringEach{condI} = [twoStopFiringEach{condI}; twoMazeStopFiringEachAgg{dpI,condI}];
    end
    
    oneArmPctChange = [oneArmPctChange; oneArmActiveChange{dpI}];
    twoArmPctChange = [twoArmPctChange; twoArmActiveChange{dpI}];
    %}
end

% PV corrs
condPairs = [1 1; 2 2; 3 3; 4 4];
numCondPairs = size(condPairs,1);
binComb = 'self';

PopulationVectorCorrs4_2;

oneEnvMicePVcorrs = []; oneEnvMicePVcorrsMeans = [];
twoEnvMicePVcorrs = []; twoEnvMicePVcorrsMeans = [];
oneEnvPVmeansAll = []; oneEnvPVsemAll = [];
twoEnvPVmeansAll = []; twoEnvPVsemAll = [];
for dpI = 1:numDayPairs
    for cpI = 1:numCondPairs
        oneEnvMicePVcorrs{dpI,cpI} = pooledPVcorrs{dpI,cpI}(oneEnvMice,:);
        oneEnvMicePVcorrsMeans{dpI,cpI} = nanmean(oneEnvMicePVcorrs{dpI,cpI},1); % (1,nBins)
        for binI = 1:size(oneEnvMicePVcorrs{dpI,cpI},2)
            oneEnvMicePVcorrsSEM{dpI,cpI}(1,binI) = standarderrorSL(oneEnvMicePVcorrs{dpI,cpI}(:,binI));
        end
        
        twoEnvMicePVcorrs{dpI,cpI} = pooledPVcorrs{dpI,cpI}(twoEnvMice,:);
        twoEnvMicePVcorrsMeans{dpI,cpI} = nanmean(twoEnvMicePVcorrs{dpI,cpI},1);
        for binI = 1:size(twoEnvMicePVcorrs{dpI,cpI},2)
            twoEnvMicePVcorrsSEM{dpI,cpI}(1,binI) = standarderrorSL(twoEnvMicePVcorrs{dpI,cpI}(:,binI));
        end
    end
    
    %do we need a dimension direction here?
    oneEnvPVmeansAll(dpI) = nanmean(nanmean([oneEnvMicePVcorrs{dpI,:}]));
    oneEnvPVsemAll(dpI) = standarderrorSL([oneEnvMicePVcorrs{dpI,:}]);
    twoEnvPVmeansAll(dpI) = nanmean(nanmean([twoEnvMicePVcorrs{dpI,:}]));
    twoEnvPVsemAll(dpI) = standarderrorSL([twoEnvMicePVcorrs{dpI,:}]);
end

oneEnvPVcorrs = cell2mat(oneEnvMicePVcorrsMeans); % size?
twoEnvPVcorrs = cell2mat(twoEnvMicePVcorrsMeans);

for binI = 1:(nArmBins*numConds)
    [pPvs(binI),~] = ranksum(oneEnvPVcorrs(:,binI),twoEnvPVcorrs(:,binI));
end
%{
figure;
plot([-52 52],[-52 52],'k')
for ii = 1:48; text(mean(plotBins.X(ii)),mean(plotBins.Y(ii)),num2str(round(pPvs(ii),3)),'Rotation',45); hold on; end
%}
oneEnvPVcorrs = mean(cell2mat(oneEnvMicePVcorrsMeans),1);
twoEnvPVcorrs = mean(cell2mat(twoEnvMicePVcorrsMeans),1);

disp('Done Turn1-Turn2 analyses')

%% Turn 1 v Turn 2 all to all pv corrs
%dayPairsForward = GetAllCombs(1:3,7:9);
%dayPairs = dayPairsForward;
dayPairs = repmat([1:3, 7:9]',1,2);
numDayPairs = size(dayPairs,1);
condsUse = 1:4;
numConds = numel(condsUse);

binComb = 'allToAll';
% Sort out plotting labels NOW: should be able to apply these labels to a
% imagesc of the confusion matrix, show us where each arm is and end vs. mid
%lgPlotHere
plotBins.X = []; plotBins.Y = []; plotLabels = []; plotTicks = []; plotTickLabels = {}; plotOrder = []; plotReorder = [];
for condI = 1:length(condsUse)
    plotBins.X = [plotBins.X; lgPlotHere{condsUse(condI)}.X];
    plotBins.Y = [plotBins.Y; lgPlotHere{condsUse(condI)}.Y];
    plotLabels = [plotLabels; repmat([armLabels{condsUse(condI)}],nArmBins,1)];
    plotTicks = [plotTicks; [1;mean([1 nArmBins]);nArmBins]+(nArmBins*(condI-1))];
    plotTickLabels{numel(plotTickLabels)+1} = 'center';
    plotTickLabels{numel(plotTickLabels)+1} = armLabels{condsUse(condI)};
    plotTickLabels{numel(plotTickLabels)+1} = 'end';
    plotOrder = [plotOrder; [[1:nArmBins]+nArmBins*(condI-1)]'];
    orderAdd = [[1:nArmBins]+nArmBins*(condI-1)]';
    if (armLabels{condsUse(condI)} == 'n') || (armLabels{condsUse(condI)} == 's')
        orderAdd = flipud(orderAdd);
        plotTickLabels{numel(plotTickLabels)-2} = 'start';
        plotTickLabels{numel(plotTickLabels)} = 'center';
    end
    plotReorder = [plotReorder; orderAdd];
end
% So now decide how to flip them...
%{
    figure;
    for binI = 1:size(plotBins.X,1)
        text(mean(plotBins.X(binI,:)),mean(plotBins.Y(binI,:)),num2str(binI))
        hold on
    end
    xlim([min(plotBins.X(:))-5, max(plotBins.X(:))+5])
    ylim([min(plotBins.Y(:))-5, max(plotBins.Y(:))+5])
    title('PlotBins Order')

    pbX = plotBins.X(plotReorder,:); pbY = plotBins.Y(plotReorder,:);

    figure;
    for binI = 1:size(pbX,1)
        text(mean(pbX(binI,:)),mean(pbY(binI,:)),num2str(binI))
        hold on
    end
    xlim([min(pbX(:))-5, max(pbX(:))+5])
    ylim([min(pbY(:))-5, max(pbY(:))+5])
    title('PlotBins Reordered')
%}


corrType = 'Spearman';
pvCorrsATA = cell(numMice,1); 
meanCorrATA = cell(numMice,1); 
numCellsUsedATA = cell(numMice,1); 
numNanATA = cell(numMice,1); 
% With day use as TL 1, cell has to be active 1 day
% with cellSSI > 0 as TL2, cell has to be present on both days
% pooling conds so...
condPairs = [1 1];

pooledPVcorrsATA = cell(numDayPairs,1); [pooledPVcorrsATA{:}] = deal(nan(nArmBins*numConds,nArmBins*numConds,numMice));
pooledMeanCorrATA = cell(numDayPairs,1); [pooledMeanCorrATA{:}] = deal(nan(nArmBins*numConds,nArmBins*numConds,numMice));
pooledNumCellsUsedATA = cell(numDayPairs,1); [pooledNumCellsUsedATA{:}] = deal(nan(nArmBins*numConds,nArmBins*numConds,numMice));
clear traitLogical
% This code copied out of PopulationVectorCorrs4_2
for mouseI = 1:numMice
    %traitLogical{1} = dayUse{mouseI};
    traitLogical{1} = sum(dayUse{mouseI}(:,:,condsUse),3)>0;
    %traitLogical{2} = repmat(cellSSI{mouseI}>0,1,1,4);
    traitLogical{2} = cellSSI{mouseI}>0;
    if mouseI==1
        traitLogical{2}(:,[5 6]) = 0;
    end
    cellsUseOption = {'activeEither','activeBoth'};
    %traitLogical{2} = trialReli{mouseI}>0;
    disp(['Running mouse ' num2str(mouseI)])
    
    % Easiest way will be to reorganize the cell tmap here, etc.
    cellTMapAllBins = [];
    for dayI = 1:9
        for cellI = 1:numCells(mouseI)
            ttt = [cellTMap{mouseI}{cellI,dayI,condsUse(:)}];
            cellTMapAllBins{cellI,dayI} = ttt(:);
        end
        cellTMapAllBins = cellfun(@(x) x(plotReorder),cellTMapAllBins,'UniformOutput',false);
    end
        
    [pvCorrsATA{mouseI}, meanCorrATA{mouseI}, numCellsUsedATA{mouseI}, numNansATA{mouseI}] =...
        PVcorrsWrapperMedium(cellTMapAllBins,[1 1],dayPairs,traitLogical,cellsUseOption,corrType,binComb);
    tOneTwoCombs = GetAllCombs(1:3,4:6);

    for ttI = 1:size(tOneTwoCombs,1)
        pvCorrsATAdiffs{mouseI}{ttI,1} = pvCorrsATA{mouseI}{tOneTwoCombs(ttI,2)} - pvCorrsATA{mouseI}{tOneTwoCombs(ttI,1)};
    end

    % Pool these corrs: 
      %mousePVcorrs{mouseI} = pvCorrs;
    for cpI = 1:1
        for dpI = 1:numDayPairs
            if any(pvCorrsATA{mouseI}{dpI,cpI})
            %pooledPVcorrs{dpI,cpI}(mouseI,:) = [pooledPVcorrs{dpI,cpI}; pvCorrs{dpI,cpI}];
            %pooledMeanCorr{dpI,cpI}(mouseI,:) = [pooledMeanCorr{dpI,cpI}; meanCorr{dpI,cpI}];
            %pooledNumCellsUsed{dpI,cpI}(mouseI,:) = [pooledNumCellsUsed{dpI,cpI}; numCellsUsed{dpI,cpI}];
            
            pooledPVcorrsATA{dpI,cpI}(:,:,mouseI) = pvCorrsATA{mouseI}{dpI,cpI}; % corrs comes out (1,nBins)
            %pooledMeanCorrATA{dpI,cpI}(:,:,mouseI) = meanCorrATA{mouseI}{dpI,cpI};
            %pooledNumCellsUsedATA{dpI,cpI}(:,:,mouseI) = numCellsUsedATA{mouseI}{dpI,cpI};
            end
        end

        % This is inefficient, but we can re-use the code built out below
        for ttI = 1:size(tOneTwoCombs,1)
            pooledPVcorrsATAdiffs{ttI,cpI}(:,:,mouseI) = pvCorrsATAdiffs{mouseI}{ttI,1}; 
        end
    end
end 

oneEnvPVcorrsATA = cellfun(@(x) x(:,:,oneEnvMice),pooledPVcorrsATA,'UniformOutput',false);
twoEnvPVcorrsATA = cellfun(@(x) x(:,:,twoEnvMice),pooledPVcorrsATA,'UniformOutput',false);
oneEnvPVcorrsATA = cell2mat(reshape(oneEnvPVcorrsATA,1,1,6)); % but final dim3 length is 18 = 6 days * 3 mice
twoEnvPVcorrsATA = cell2mat(reshape(twoEnvPVcorrsATA,1,1,6));

meanOneEnvPVcorrsATAturn1 = mean(oneEnvPVcorrsATA(:,:,1:9),3);
meanOneEnvPVcorrsATAturn2 = mean(oneEnvPVcorrsATA(:,:,10:18),3);
meanTwoEnvPVcorrsATAturn1 = mean(twoEnvPVcorrsATA(:,:,1:9),3);
meanTwoEnvPVcorrsATAturn2 = mean(twoEnvPVcorrsATA(:,:,10:18),3);

oneEnvATAcorrsChange = meanOneEnvPVcorrsATAturn2 - meanOneEnvPVcorrsATAturn1;
twoEnvATAcorrsChange = meanTwoEnvPVcorrsATAturn2 - meanTwoEnvPVcorrsATAturn1;

ATAcorrsChangeDiff = twoEnvATAcorrsChange - oneEnvATAcorrsChange;

locations = [0 0.5 1];
colors = [1.0000    0.0    0.000;
            1 1 1;
            0    0.45   0.74];           
newGradient = GradientMaker(colors,locations);

figure;
subplot(2,2,1)
oneATAplot = meanOneEnvPVcorrsATAturn1;
oneATAplot(logical(eye(size(oneATAplot)))) = 0;
imagesc(oneATAplot)
caxis([-0.15 1])
colorbar
ata = gca;
ata.XTick = plotTicks;
ata.YTick = plotTicks;
ata.XTickLabel = plotTickLabels;
ata.XTickLabelRotation = 45;
ata.YTickLabel = plotTickLabels;
ata.YTickLabelRotation = 45;
title('OneMaze Days 1-3')
MakePlotPrettySL(gca);

subplot(2,2,3)
oneATAplot = meanOneEnvPVcorrsATAturn2;
oneATAplot(logical(eye(size(oneATAplot)))) = 0;
imagesc(oneATAplot)
caxis([-0.15 1])
colorbar
ata = gca;
ata.XTick = plotTicks;
ata.YTick = plotTicks;
ata.XTickLabel = plotTickLabels;
ata.XTickLabelRotation = 45;
ata.YTickLabel = plotTickLabels;
ata.YTickLabelRotation = 45;
title('OneMaze Days 7-9')
MakePlotPrettySL(gca);

subplot(2,2,2)
twoATAplot = meanTwoEnvPVcorrsATAturn1;
twoATAplot(logical(eye(size(twoATAplot)))) = 0;
imagesc(twoATAplot)
caxis([-0.15 1])
colorbar
ata = gca;
ata.XTick = plotTicks;
ata.YTick = plotTicks;
ata.XTickLabel = plotTickLabels;
ata.XTickLabelRotation = 45;
ata.YTickLabel = plotTickLabels;
ata.YTickLabelRotation = 45;
title('TwoMaze Days 1-3')
MakePlotPrettySL(gca);

subplot(2,2,4)
twoATAplot = meanTwoEnvPVcorrsATAturn2;
twoATAplot(logical(eye(size(twoATAplot)))) = 0;
imagesc(twoATAplot)
caxis([-0.15 1])
colorbar
ata = gca;
ata.XTick = plotTicks;
ata.YTick = plotTicks;
ata.XTickLabel = plotTickLabels;
ata.XTickLabelRotation = 45;
ata.YTickLabel = plotTickLabels;
ata.YTickLabelRotation = 45;
title('TwoMaze Days 7-9')
MakePlotPrettySL(gca);

suptitleSL({'PV Corrs All-To-All ("Internal Structure")'; 'color bar that indicates negative?'})

figure;
subplot(1,3,1)
imagesc(oneEnvATAcorrsChange)
colormap(newGradient)
caxis([-0.2 0.2])
colorbar
ata = gca;
ata.XTick = plotTicks;
ata.YTick = plotTicks;
ata.XTickLabel = plotTickLabels;
ata.XTickLabelRotation = 45;
ata.YTickLabel = plotTickLabels;
ata.YTickLabelRotation = 45;
title('OneMaze Turn2 - 1')
MakePlotPrettySL(gca);

subplot(1,3,2)
imagesc(twoEnvATAcorrsChange)
colormap(newGradient)
caxis([-0.2 0.2])
colorbar
ata = gca;
ata.XTick = plotTicks;
ata.YTick = plotTicks;
ata.XTickLabel = plotTickLabels;
ata.XTickLabelRotation = 45;
ata.YTickLabel = plotTickLabels;
ata.YTickLabelRotation = 45;
title('TwoMaze Turn2 - 1')
MakePlotPrettySL(gca);

subplot(1,3,3)
imagesc(ATAcorrsChangeDiff)
colormap(newGradient)
caxis([-0.3 0.3])
colorbar
ata = gca;
ata.XTick = plotTicks;
ata.YTick = plotTicks;
ata.XTickLabel = plotTickLabels;
ata.XTickLabelRotation = 45;
ata.YTickLabel = plotTickLabels;
ata.YTickLabelRotation = 45;
title('TwoMaze-OneMaze Turn2- 1')
MakePlotPrettySL(gca);

suptitleSL('PV Corrs All-To-All Change ("Internal Structure")')

figure;
[cdfH,xVal] = ecdf(oneEnvATAcorrsChange(:));
plot(xVal,cdfH,'Color',groupColors{1},'LineWidth',1.5)
hold on
[cdfH,xVal] = ecdf(twoEnvATAcorrsChange(:));
plot(xVal,cdfH,'Color',groupColors{2},'LineWidth',1.5)

figure;
[cdfH,xVal] = ecdf(abs(oneEnvATAcorrsChange(:)));
plot(xVal,cdfH,'Color',groupColors{1},'LineWidth',1.5)
hold on
[cdfH,xVal] = ecdf(abs(twoEnvATAcorrsChange(:)));
plot(xVal,cdfH,'Color',groupColors{2},'LineWidth',1.5)

%
oneEnvATAdiffs = cellfun(@(x) x(:,:,oneEnvMice),pooledPVcorrsATAdiffs,'UniformOutput',false);
twoEnvATAdiffs = cellfun(@(x) x(:,:,twoEnvMice),pooledPVcorrsATAdiffs,'UniformOutput',false);
oneEnvATAdiffs = round(abs(cell2mat(reshape(oneEnvATAdiffs,1,1,9))),4); % final dim is 27 = 9 day combs * 3 mice
twoEnvATAdiffs = round(abs(cell2mat(reshape(twoEnvATAdiffs,1,1,9))),4);

meanOneEnvATAdiffs = mean(oneEnvATAdiffs,3);
meanTwoEnvATAdiffs = mean(twoEnvATAdiffs,3);
meanATAdiffs = meanOneEnvATAdiffs - meanTwoEnvATAdiffs;

for binI = 1:(nArmBins*numel(condsUse))
    for binJ = 1:(nArmBins*numel(condsUse))
        [ATApVals(binI,binJ),ATAhVals(binI,binJ),stat] = ranksum(squeeze(oneEnvATAdiffs(binI,binJ,:)),squeeze(twoEnvATAdiffs(binI,binJ,:)));
        %ATArsStat(binI,binJ) = stat.zval; stat.ranksum
    end
end

climsH = [min([meanOneEnvATAdiffs(:); meanTwoEnvATAdiffs(:)]),...
         ceil(max([meanOneEnvATAdiffs(:); meanTwoEnvATAdiffs(:)])*10)/10];   
figure; 
ax1 = subplot(2,2,1);
%meanOneEnvATAdiffs(logical(eye(size(meanOneEnvATAdiffs)))) = NaN;
imagesc(meanOneEnvATAdiffs)
colormap parula
colorbar
try; caxis(climsH); catch clim(climsH); end
ata = gca;
ata.XTick = plotTicks;
ata.YTick = plotTicks;
ata.XTickLabel = plotTickLabels;
ata.XTickLabelRotation = 45;
ata.YTickLabel = plotTickLabels;
ata.YTickLabelRotation = 45;
title('abs. OneMaze Turn1-2 diffs')
MakePlotPrettySL(gca);

ax2 = subplot(2,2,2)
imagesc(meanTwoEnvATAdiffs)
colormap parula
colorbar
try; caxis(climsH); catch clim(climsH); end
ata = gca;
ata.XTick = plotTicks;
ata.YTick = plotTicks;
ata.XTickLabel = plotTickLabels;
ata.XTickLabelRotation = 45;
ata.YTickLabel = plotTickLabels;
ata.YTickLabelRotation = 45;
title('abs. TwoMaze Turn1-2 diffs')
MakePlotPrettySL(gca);

ax3 = subplot(2,2,3)
%figure;
imagesc(meanATAdiffs)
colormap(newGradient)
caxis([-0.15 0.15])
colorbar
ata = gca;
ata.XTick = plotTicks;
ata.YTick = plotTicks;
ata.XTickLabel = plotTickLabels;
ata.XTickLabelRotation = 45;
ata.YTickLabel = plotTickLabels;
ata.YTickLabelRotation = 45;
title('abs. OneMaze - abs. TwoMaze')
hold on

oneEnvMore = (meanATAdiffs > 0) & (ATApVals < 0.05);
twoEnvMore = (meanATAdiffs < 0) & (ATApVals < 0.05);

for binI = 1:(nArmBins*numel(condsUse))
    for binJ = 1:(nArmBins*numel(condsUse))
        pHere = ATApVals(binI,binJ);
        if pHere < 0.05
            valH= '*';
            %{
            if pHere < 0.005
                valH = '**';
                if pHere <0.001
                    valH = '***';
                end
            end
            %}
            moreColor = [0.9294    0.6941    0.1255];
            moreColor = groupColors{2};
            if oneEnvMore(binI,binJ)
                moreColor = groupColors{1};
            end
                
            text(binJ,binI,valH,'Color',moreColor,'HorizontalAlignment','center','VerticalAlignment','middle')
        end
    end
end
MakePlotPrettySL(gca);

colormap(ax1,parula)
colormap(ax2,parula)
colormap(ax3,newGradient)

subplot(2,2,4)
%figure;
[cdfH,xVal] = ecdf(meanOneEnvATAdiffs(:));
plot(xVal,cdfH,'Color',groupColors{1},'LineWidth',1.5)
hold on
[cdfH,xVal] = ecdf(meanTwoEnvATAdiffs(:));
plot(xVal,cdfH,'Color',groupColors{2},'LineWidth',1.5)
[h,pVal,ksstat] = kstest2(meanOneEnvATAdiffs(:),meanTwoEnvATAdiffs(:));
title(['p = ' num2str(pVal) ', ks stat = ' num2str(ksstat)])
xlabel('Absolute Correlation Difference')
ylabel('Cumulative Density')
MakePlotPrettySL(gca);

msgbox({['OneMaze more change in ' num2str(sum(sum(oneEnvMore))/2) ' bin pairs;'];...
        ['TwoMaze more change in ' num2str(sum(sum(twoEnvMore))/2) ' bin pairs;'];...
        ['Total bin pairs p<0.05 ' num2str(sum(sum(oneEnvMore))/2 + sum(sum(twoEnvMore))/2)];...
        ['out of ' num2str( (((nArmBins*numel(condsUse))^2)-(nArmBins*numel(condsUse)))/2 ) ' bin pairs']})
%% Stability by number of days present
dayPairsForward = GetAllCombs(1:3,7:9);
dayPairsForward = nchoosek([1:3, 7:9],2);
%[singleCellCorrsRho, singleCellCorrsP] = GatherSingleCellCorrs;
GatherSingleCellCorrs;

meanDayPairCorr = [];
nDayPairs = [];
oneEnvMeanDPcorrs = [];
oneEnvNdayPairsPresent = [];
twoEnvMeanDPcorrs = [];
twoEnvNdayPairsPresent = [];

numDayPairs = size(dayPairsForward,1);
for mouseI = 1:numMice
    mouseSingleCellCorrs = singleCellAllCorrsRho{mouseI}{1};
    
    firedAtAll = sum(trialReli{mouseI},3)>0;
    traitLogical = [];
    for dpI = 1:numDayPairs
        firedBothDays = sum(firedAtAll(:,dayPairsForward(dpI,:)),2)==2;
        aboveThresh = sum(dayUseAll{mouseI}(:,dayPairsForward(dpI,:)),2)>0;
        cellsUseHere = firedBothDays & aboveThresh;
        traitLogical{dpI} = cellsUseHere;
    end
    
    corrsMat = cell2mat(mouseSingleCellCorrs);
    useMat = cell2mat(traitLogical);

    nCells = size(corrsMat,1);
    meanDayPairCorrH = nan(nCells,1);
    for cellI = 1:nCells
        meanDayPairCorrH(cellI,1) = mean(corrsMat(cellI,useMat(cellI,:)));
        
    end
    %meanDayPairCorrAllH = mean(corrsMat,2); % Doesn't work, NaNs here
    nDayPairsPersist = sum(useMat,2);
    
    kickOut = isnan(meanDayPairCorrH);
    
    meanDayPairCorr{mouseI} = meanDayPairCorrH(~kickOut);
    nDayPairs{mouseI} = nDayPairsPersist(~kickOut);

    switch groupNum(mouseI)
        case 1
            oneEnvMeanDPcorrs = [oneEnvMeanDPcorrs; meanDayPairCorr{mouseI}];
            oneEnvNdayPairsPresent = [oneEnvNdayPairsPresent; nDayPairs{mouseI}];
        case 2
            twoEnvMeanDPcorrs = [twoEnvMeanDPcorrs; meanDayPairCorr{mouseI}];
            twoEnvNdayPairsPresent = [twoEnvNdayPairsPresent; nDayPairs{mouseI}];
    end
end

% Still coming up with nans...

figure;

subplot(2,1,1)
boxplot(oneEnvMeanDPcorrs,oneEnvNdayPairsPresent)
lm = fitlm(table(oneEnvNdayPairsPresent,oneEnvMeanDPcorrs),'linear');
slope = lm.Coefficients.Estimate(2);
pSlope = lm.Coefficients.pValue(2);
rr = lm.Rsquared.Ordinary;
[rr,pp]=corr(oneEnvNdayPairsPresent,oneEnvMeanDPcorrs,'type','Spearman');
title({['TwoMaze, rr = ' num2str(rr) ', slope = ' num2str(slope) ', slope pval (vs. constant) = ' num2str(pSlope)];['spearman corr rho = ' num2str(rr) ', p = ', num2str(pp)]})
xlabel('Day Pairs Present/Active')
ylabel('Mean Correlation Across Active Day Pairs')

subplot(2,1,2)
boxplot(twoEnvMeanDPcorrs,twoEnvNdayPairsPresent)
lm = fitlm(table(twoEnvNdayPairsPresent,twoEnvMeanDPcorrs),'linear');
slope = lm.Coefficients.Estimate(2);
pSlope = lm.Coefficients.pValue(2);
rr = lm.Rsquared.Ordinary;
[rr,pp]=corr(twoEnvNdayPairsPresent,twoEnvMeanDPcorrs,'type','Spearman');
title({['TwoMaze, rr = ' num2str(rr) ', slope = ' num2str(slope) ', slope pval (vs. constant) = ' num2str(pSlope)];['spearman corr rho = ' num2str(rr) ', p = ', num2str(pp)]})
xlabel('Day Pairs Present/Active')
ylabel('Mean Correlation Across Active Day Pairs')

    


%% Coactivity again...

dayPairsHere = GetAllCombs(1:3,7:9);
daysHere = [1 2 3 7 8 9];
condsHere = [1 2 3 4];

edgeThreshes = 0:0.025:0.4;
nEdgeThreshes = numel(edgeThreshes);

if ~exist(fullfile(mainFolder,'temporalCorrs.mat'),'file')
    for mouseI = 1:numMice
        disp(['Making temporal corrs for mouse ' num2str(mouseI)])
        traitLogical = dayUse{mouseI};
        [HtemporalCorrsR, HtemporalCorrsP, cellPairsUsedH] = MakeTemporalCorrs1(cellTBT{mouseI},condsHere,traitLogical);

        temporalCorrsR{mouseI} = HtemporalCorrsR;
        temporalCorrsP{mouseI} = HtemporalCorrsP;
        cellPairsUsed{mouseI} = cellPairsUsedH;
    end
    save(fullfile(mainFolder,'temporalCorrs.mat'),'temporalCorrsR','temporalCorrsP','cellPairsUsed')
    disp('Done making temporal corrs')
else
    load(fullfile(mainFolder,'temporalCorrs.mat'))
end

%edgeThreshes = 0:0.025:0.4;

%corrsTest = temporalCorrsR;
%coactivityAnalyses2;


% Repeat for spatial corrs
if ~exist(fullfile(mainFolder,'spatialCorrs.mat'),'file')
    for mouseI = 1:numMice
        tmapHere = cell(numCells(mouseI),9);
        disp(['Making spatial corrs for mouse ' num2str(mouseI)])
        for condI = 1:numel(condsHere)
            tmapHere = cellfun(@(x,y) [x;y],tmapHere,cellTMap{mouseI}(:,:,condsHere(condI)),'UniformOutput',false);
        end

        traitLogical = dayUseAll{mouseI};
        [spatialCorrsR{mouseI}, spatialCorrsP{mouseI},~] = MakeSpatialCorrs1(tmapHere,cellPairsUsed{mouseI},traitLogical);
    %[tmapRhos,tmapPs]
    end
    save(fullfile(mainFolder,'spatialCorrs.mat'),'spatialCorrsR','spatialCorrsP','cellPairsUsed')
    disp('Done making spatial corrs')
else
    load(fullfile(mainFolder,'spatialCorrs.mat'))
end


%corrsTest = spatialCorrsR;      
%coactvityAnalyses2;

% Aggregate all these, 
% Plot a scatter of spatial corr x temporal corr
% Make a histogram along the unity line (or along the best fit line...) to
% show these don't strictly go together
oneEnvSpatialRhosTurn1 = [];
oneEnvSpatialRhosTurn2 = [];
oneEnvTemporalRhosTurn1 = [];
oneEnvTemporalRhosTurn2 = [];
twoEnvSpatialRhosTurn1 = [];
twoEnvSpatialRhosTurn2 = [];
twoEnvTemporalRhosTurn1 = [];
twoEnvTemporalRhosTurn2 = [];
for mouseI = 1:numMice
    for sessI = 1:numel(daysHere)
        
        dayH = daysHere(sessI);
        switch dayH < 6
            case 1 % days 1,2,3
                switch groupNum(mouseI)
                    case 1
                        oneEnvSpatialRhosTurn1 = [oneEnvSpatialRhosTurn1; spatialCorrsR{mouseI}{dayH}];
                        oneEnvTemporalRhosTurn1 = [oneEnvTemporalRhosTurn1; temporalCorrsR{mouseI}{dayH}];
                    case 2
                        twoEnvSpatialRhosTurn1 = [twoEnvSpatialRhosTurn1; spatialCorrsR{mouseI}{dayH}];
                        twoEnvTemporalRhosTurn1 = [twoEnvTemporalRhosTurn1; temporalCorrsR{mouseI}{dayH}];
                end
            case 0 % days 7,8,9
                switch groupNum(mouseI)
                    case 1
                        oneEnvSpatialRhosTurn2 = [oneEnvSpatialRhosTurn2; spatialCorrsR{mouseI}{dayH}];
                        oneEnvTemporalRhosTurn2 = [oneEnvTemporalRhosTurn2; temporalCorrsR{mouseI}{dayH}];
                    case 2
                        twoEnvSpatialRhosTurn2 = [twoEnvSpatialRhosTurn2; spatialCorrsR{mouseI}{dayH}];
                        twoEnvTemporalRhosTurn2 = [twoEnvTemporalRhosTurn2; temporalCorrsR{mouseI}{dayH}];
                end
        end
        
    end
end

% Are these distributions different?
%{
[h,pA,ks2statA] = kstest2(oneEnvTemporalRhosTurn1,oneEnvTemporalRhosTurn2);
[h,pB,ks2statB] = kstest2(twoEnvTemporalRhosTurn1,twoEnvTemporalRhosTurn2);
[h,pC,ks2statC] = kstest2(oneEnvTemporalRhosTurn1,twoEnvTemporalRhosTurn1);
[h,pD,ks2statD] = kstest2(oneEnvTemporalRhosTurn2,twoEnvTemporalRhosTurn2);
stText = {['OneMaze: Turn1 v Turn 2: p = ' num2str(pA) ', ksStat= ' num2str(ks2statA)];...
          ['TwoMaze: Turn1 v Turn 2: p = ' num2str(pB) ', ksStat= ' num2str(ks2statB)];...
          ['Turn1: OneMaze v TwoMaze: p = ' num2str(pC) ', ksStat= ' num2str(ks2statC)];...
          ['Turn2: OneMaze v TwoMaze: p = ' num2str(pD) ', ksStat= ' num2str(ks2statD)]};
msgbox(stText)
%}

figure;
subplot(2,2,1)
plot(oneEnvSpatialRhosTurn1,oneEnvTemporalRhosTurn1,'.','MarkerEdgeColor',groupColors{1})
aa = oneEnvSpatialRhosTurn1(~isnan(oneEnvSpatialRhosTurn1) & ~isnan(oneEnvTemporalRhosTurn1));
bb = oneEnvTemporalRhosTurn1(~isnan(oneEnvSpatialRhosTurn1) & ~isnan(oneEnvTemporalRhosTurn1));
lm = fitlm(table(aa(:),bb(:)),'linear');
[rho,pp] = corr(aa,bb,'type','Spearman');
hold on
plotLocalErrorBars(oneEnvSpatialRhosTurn1,oneEnvTemporalRhosTurn1,[-1:0.2:1],'std','k')
ylabel('Temporal Correlation (rho)')
xlabel('Spatial bin correlation (rho)')
title(['OneMaze, Turn 1, rr = ' num2str(lm.Rsquared.Ordinary) ', rho,p = ' num2str(rho) ', ' num2str(pp)])
MakePlotPrettySL(gca);

subplot(2,2,2)
plot(oneEnvSpatialRhosTurn2,oneEnvTemporalRhosTurn2,'.','MarkerEdgeColor',groupColors{1})
aa = oneEnvSpatialRhosTurn2(~isnan(oneEnvSpatialRhosTurn2) & ~isnan(oneEnvTemporalRhosTurn2));
bb = oneEnvTemporalRhosTurn2(~isnan(oneEnvSpatialRhosTurn2) & ~isnan(oneEnvTemporalRhosTurn2));
lm = fitlm(table(aa(:),bb(:)),'linear');
[rho,pp] = corr(aa,bb,'type','Spearman');
hold on
plotLocalErrorBars(oneEnvSpatialRhosTurn2,oneEnvTemporalRhosTurn2,[-1:0.2:1],'std','k')
ylabel('Temporal Correlation (rho)')
xlabel('Spatial bin correlation (rho)')
title(['OneMaze, Turn 2, rr = ' num2str(lm.Rsquared.Ordinary) ', rho,p = ' num2str(rho) ', ' num2str(pp)])
MakePlotPrettySL(gca);

subplot(2,2,3)
plot(twoEnvSpatialRhosTurn1,twoEnvTemporalRhosTurn1,'.','MarkerEdgeColor',groupColors{2})
aa = twoEnvSpatialRhosTurn1(~isnan(twoEnvSpatialRhosTurn1) & ~isnan(twoEnvTemporalRhosTurn1));
bb = twoEnvTemporalRhosTurn1(~isnan(twoEnvSpatialRhosTurn1) & ~isnan(twoEnvTemporalRhosTurn1));
lm = fitlm(table(aa(:),bb(:)),'linear');
[rho,pp] = corr(aa,bb,'type','Spearman');
hold on
plotLocalErrorBars(twoEnvSpatialRhosTurn1,twoEnvTemporalRhosTurn1,[-1:0.2:1],'std','k')
ylabel('Temporal Correlation (rho)')
xlabel('Spatial bin correlation (rho)')
title(['TwoMaze, Turn 1, rr = ' num2str(lm.Rsquared.Ordinary)  ', rho,p = ' num2str(rho) ', ' num2str(pp)])
MakePlotPrettySL(gca);

subplot(2,2,4)
plot(twoEnvSpatialRhosTurn2,twoEnvTemporalRhosTurn2,'.','MarkerEdgeColor',groupColors{2})
aa = twoEnvSpatialRhosTurn2(~isnan(twoEnvSpatialRhosTurn2) & ~isnan(twoEnvTemporalRhosTurn2));
bb = twoEnvTemporalRhosTurn2(~isnan(twoEnvSpatialRhosTurn2) & ~isnan(twoEnvTemporalRhosTurn2));
%lm = fitlm(table(twoEnvSpatialRhosTurn2(:),twoEnvTemporalRhosTurn2(:)),'linear');
lm = fitlm(table(aa(:),bb(:)),'linear');
%[rho,pp] = corr(twoEnvSpatialRhosTurn2,twoEnvTemporalRhosTurn2,'type','Spearman');
[rho,pp] = corr(aa,bb,'type','Spearman');
hold on
plotLocalErrorBars(twoEnvSpatialRhosTurn2,twoEnvTemporalRhosTurn2,[-1:0.2:1],'std','k')
ylabel('Temporal Correlation (rho)')
xlabel('Spatial bin correlation (rho)')
title(['TwoMaze, Turn 2, rr = ' num2str(lm.Rsquared.Ordinary) ', rho,p = ' num2str(rho) ', ' num2str(pp)])
MakePlotPrettySL(gca);

suptitleSL('Spatial Correlation Vs. Temporal Correlation, Turn 1 vs. 2 (mean+/-STD')
aa = gcf;
aa.Renderer = 'painters';

hh = histcounts2(aa,bb,[-1:0.1:1],[-0.5:0.1:0.5]);
figure; imagesc(hh)
vv = parula;

%For handling illustrator
%{
figure;
subplot(2,2,1)
%plot(oneEnvSpatialRhosTurn1,oneEnvTemporalRhosTurn1,'.','MarkerEdgeColor',groupColors{1})
aa = oneEnvSpatialRhosTurn1(~isnan(oneEnvSpatialRhosTurn1) & ~isnan(oneEnvTemporalRhosTurn1));
bb = oneEnvTemporalRhosTurn1(~isnan(oneEnvSpatialRhosTurn1) & ~isnan(oneEnvTemporalRhosTurn1));
lm = fitlm(table(aa(:),bb(:)),'linear');
[rho,pp] = corr(aa,bb,'type','Spearman');
hold on
%plotLocalErrorBars(oneEnvSpatialRhosTurn1,oneEnvTemporalRhosTurn1,[-1:0.2:1],'std','k')
ylabel('Temporal Correlation (rho)')
xlabel('Spatial bin correlation (rho)')
title(['OneMaze, Turn 1, rr = ' num2str(lm.Rsquared.Ordinary) ', rho,p = ' num2str(rho) ', ' num2str(pp)])
MakePlotPrettySL(gca);
%axis off
set(gca,'XTick',[])
set(gca,'YTick',[])

subplot(2,2,2)
%plot(oneEnvSpatialRhosTurn2,oneEnvTemporalRhosTurn2,'.','MarkerEdgeColor',groupColors{1})
aa = oneEnvSpatialRhosTurn2(~isnan(oneEnvSpatialRhosTurn2) & ~isnan(oneEnvTemporalRhosTurn2));
bb = oneEnvTemporalRhosTurn2(~isnan(oneEnvSpatialRhosTurn2) & ~isnan(oneEnvTemporalRhosTurn2));
lm = fitlm(table(aa(:),bb(:)),'linear');
[rho,pp] = corr(aa,bb,'type','Spearman');
hold on
%plotLocalErrorBars(oneEnvSpatialRhosTurn2,oneEnvTemporalRhosTurn2,[-1:0.2:1],'std','k')
ylabel('Temporal Correlation (rho)')
xlabel('Spatial bin correlation (rho)')
title(['OneMaze, Turn 2, rr = ' num2str(lm.Rsquared.Ordinary) ', rho,p = ' num2str(rho) ', ' num2str(pp)])
MakePlotPrettySL(gca);
%axis off
set(gca,'XTick',[])
set(gca,'YTick',[])

subplot(2,2,3)
%plot(twoEnvSpatialRhosTurn1,twoEnvTemporalRhosTurn1,'.','MarkerEdgeColor',groupColors{2})
aa = twoEnvSpatialRhosTurn1(~isnan(twoEnvSpatialRhosTurn1) & ~isnan(twoEnvTemporalRhosTurn1));
bb = twoEnvTemporalRhosTurn1(~isnan(twoEnvSpatialRhosTurn1) & ~isnan(twoEnvTemporalRhosTurn1));
lm = fitlm(table(aa(:),bb(:)),'linear');
[rho,pp] = corr(aa,bb,'type','Spearman');
hold on
%plotLocalErrorBars(twoEnvSpatialRhosTurn1,twoEnvTemporalRhosTurn1,[-1:0.2:1],'std','k')
ylabel('Temporal Correlation (rho)')
xlabel('Spatial bin correlation (rho)')
title(['TwoMaze, Turn 1, rr = ' num2str(lm.Rsquared.Ordinary)  ', rho,p = ' num2str(rho) ', ' num2str(pp)])
MakePlotPrettySL(gca);
%axis off
set(gca,'XTick',[])
set(gca,'YTick',[])

subplot(2,2,4)
%plot(twoEnvSpatialRhosTurn2,twoEnvTemporalRhosTurn2,'.','MarkerEdgeColor',groupColors{2})
aa = twoEnvSpatialRhosTurn2(~isnan(twoEnvSpatialRhosTurn2) & ~isnan(twoEnvTemporalRhosTurn2));
bb = twoEnvTemporalRhosTurn2(~isnan(twoEnvSpatialRhosTurn2) & ~isnan(twoEnvTemporalRhosTurn2));
%lm = fitlm(table(twoEnvSpatialRhosTurn2(:),twoEnvTemporalRhosTurn2(:)),'linear');
lm = fitlm(table(aa(:),bb(:)),'linear');
%[rho,pp] = corr(twoEnvSpatialRhosTurn2,twoEnvTemporalRhosTurn2,'type','Spearman');
[rho,pp] = corr(aa,bb,'type','Spearman');
hold on
%plotLocalErrorBars(twoEnvSpatialRhosTurn2,twoEnvTemporalRhosTurn2,[-1:0.2:1],'std','k')
ylabel('Temporal Correlation (rho)')
xlabel('Spatial bin correlation (rho)')
title(['TwoMaze, Turn 2, rr = ' num2str(lm.Rsquared.Ordinary) ', rho,p = ' num2str(rho) ', ' num2str(pp)])
MakePlotPrettySL(gca);
%axis off
set(gca,'XTick',[])
set(gca,'YTick',[])

suptitleSL('Spatial Correlation Vs. Temporal Correlation, Turn 1 vs. 2 (mean+/-STD')
aa = gcf;
aa.Renderer = 'painters';

figure;
plot(oneEnvSpatialRhosTurn1,oneEnvTemporalRhosTurn1,'.','MarkerEdgeColor',groupColors{1})
aa = oneEnvSpatialRhosTurn1(~isnan(oneEnvSpatialRhosTurn1) & ~isnan(oneEnvTemporalRhosTurn1));
bb = oneEnvTemporalRhosTurn1(~isnan(oneEnvSpatialRhosTurn1) & ~isnan(oneEnvTemporalRhosTurn1));
hh = histcounts2(aa,bb);
lm = fitlm(table(aa(:),bb(:)),'linear');
title(['OneMaze, Turn 1, rr = ' num2str(lm.Rsquared.Ordinary) ', rho,p = ' num2str(rho) ', ' num2str(pp)])
MakePlotPrettySL(gca);
xlim([-1 1])
ylim([-0.5 1])
axis off
set(gcf,'Renderer','painters');

figure;
plot(oneEnvSpatialRhosTurn2,oneEnvTemporalRhosTurn2,'.','MarkerEdgeColor',groupColors{1})
aa = oneEnvSpatialRhosTurn2(~isnan(oneEnvSpatialRhosTurn2) & ~isnan(oneEnvTemporalRhosTurn2));
bb = oneEnvTemporalRhosTurn2(~isnan(oneEnvSpatialRhosTurn2) & ~isnan(oneEnvTemporalRhosTurn2));
lm = fitlm(table(aa(:),bb(:)),'linear');
[rho,pp] = corr(aa,bb,'type','Spearman');
title(['OneMaze, Turn 2, rr = ' num2str(lm.Rsquared.Ordinary) ', rho,p = ' num2str(rho) ', ' num2str(pp)])
MakePlotPrettySL(gca);
xlim([-1 1])
ylim([-0.5 1])
axis off
set(gcf,'Renderer','opengl');

figure;
plot(twoEnvSpatialRhosTurn1,twoEnvTemporalRhosTurn1,'.','MarkerEdgeColor',groupColors{2})
aa = twoEnvSpatialRhosTurn1(~isnan(twoEnvSpatialRhosTurn1) & ~isnan(twoEnvTemporalRhosTurn1));
bb = twoEnvTemporalRhosTurn1(~isnan(twoEnvSpatialRhosTurn1) & ~isnan(twoEnvTemporalRhosTurn1));
lm = fitlm(table(aa(:),bb(:)),'linear');
[rho,pp] = corr(aa,bb,'type','Spearman');
title(['TwoMaze, Turn 1, rr = ' num2str(lm.Rsquared.Ordinary)  ', rho,p = ' num2str(rho) ', ' num2str(pp)])
MakePlotPrettySL(gca);
xlim([-1 1])
ylim([-0.5 1])
axis off
set(gcf,'Renderer','opengl');

figure;
plot(twoEnvSpatialRhosTurn2,twoEnvTemporalRhosTurn2,'.','MarkerEdgeColor',groupColors{2})
aa = twoEnvSpatialRhosTurn2(~isnan(twoEnvSpatialRhosTurn2) & ~isnan(twoEnvTemporalRhosTurn2));
bb = twoEnvTemporalRhosTurn2(~isnan(twoEnvSpatialRhosTurn2) & ~isnan(twoEnvTemporalRhosTurn2));
lm = fitlm(table(aa(:),bb(:)),'linear');
[rho,pp] = corr(aa,bb,'type','Spearman');
title(['TwoMaze, Turn 2, rr = ' num2str(lm.Rsquared.Ordinary) ', rho,p = ' num2str(rho) ', ' num2str(pp)])
MakePlotPrettySL(gca);
xlim([-1 1])
ylim([-0.5 1])
axis off
set(gcf,'Renderer','opengl');

figure;
subplot(2,2,1)
plot([-1 1],[0 0],'k'); hold on
plot([0 0],[-0.5 1],'k')
plotLocalErrorBars(oneEnvSpatialRhosTurn1,oneEnvTemporalRhosTurn1,[-1:0.2:1],'std','k')
MakePlotPrettySL(gca);
xlim([-1 1]); ylim([-0.5 1])

subplot(2,2,2)
plot([-1 1],[0 0],'k'); hold on
plotLocalErrorBars(oneEnvSpatialRhosTurn2,oneEnvTemporalRhosTurn2,[-1:0.2:1],'std','k')
MakePlotPrettySL(gca);
xlim([-1 1]); ylim([-0.5 1])

subplot(2,2,3)
plot([-1 1],[0 0],'k'); hold on
plotLocalErrorBars(twoEnvSpatialRhosTurn1,twoEnvTemporalRhosTurn1,[-1:0.2:1],'std','k')
MakePlotPrettySL(gca);
xlim([-1 1]); ylim([-0.5 1])

subplot(2,2,4)
plot([-1 1],[0 0],'k'); hold on
plotLocalErrorBars(twoEnvSpatialRhosTurn2,twoEnvTemporalRhosTurn2,[-1:0.2:1],'std','k')
MakePlotPrettySL(gca);
xlim([-1 1]); ylim([-0.5 1])

suptitleSL('Spatial Correlation Vs. Temporal Correlation, Turn 1 vs. 2 (mean+/-STD')
%}
figure;
%subplot()
%[cdfH,cdfX] = ecdf(oneEnvTemporalRhosTurn1);
[cdfH,cdfX] = ecdf(oneEnvTemporalRhosTurn1(oneEnvTemporalRhosTurn1>0));
plot(cdfX,cdfH,'Color',groupColors{1})
hold on
%[cdfH,cdfX] = ecdf(twoEnvTemporalRhosTurn1);
[cdfH,cdfX] = ecdf(twoEnvTemporalRhosTurn1(twoEnvTemporalRhosTurn1>0));
plot(cdfX,cdfH,'Color',groupColors{2})
[h,p] = kstest2(oneEnvTemporalRhosTurn1,twoEnvTemporalRhosTurn1);

% Is the change in spatial correlation related to change in temporal correlation?
oneEnvSpatialChanges = [];
oneEnvTemporalChanges = [];
oneEnvSpatialDayA = [];    
oneEnvTemporalDayA = [];
twoEnvSpatialChanges = [];
twoEnvTemporalChanges = [];
twoEnvSpatialDayA = [];    
twoEnvTemporalDayA = [];
oneEnvPairsOverDays = [];
twoEnvPairsOverDays = [];
for mouseI = 1:numMice
    traitLogical = dayUseAll{mouseI};
    [corrDiffs{mouseI}, corrsAllAB{mouseI}, cellPairsOverDays{mouseI}] =...
        evaluateCorrChanges1(cellPairsUsed{mouseI},traitLogical, dayPairsHere,spatialCorrsR{mouseI}, temporalCorrsR{mouseI});
    
    for dpH = 1:size(dayPairsHere,1)
        
        cellPairsHH = [];
        [cellPairsHH(:,1),cellPairsHH(:,2)] = ind2sub([numCells(mouseI) numCells(mouseI)],cellPairsOverDays{mouseI}{dpH});
        
        switch groupNum(mouseI)
            case 1
                oneEnvSpatialChanges = [oneEnvSpatialChanges; corrDiffs{mouseI}{1}{dpH}];
                oneEnvTemporalChanges = [oneEnvTemporalChanges; corrDiffs{mouseI}{2}{dpH}];
                oneEnvSpatialDayA = [oneEnvSpatialDayA; corrsAllAB{mouseI}{1}{dpH}(:,1)];
                oneEnvTemporalDayA = [oneEnvTemporalDayA; corrsAllAB{mouseI}{2}{dpH}(:,1)];
                oneEnvPairsOverDays = [oneEnvPairsOverDays; cellPairsHH];
            case 2
                twoEnvSpatialChanges = [twoEnvSpatialChanges; corrDiffs{mouseI}{1}{dpH}];
                twoEnvTemporalChanges = [twoEnvTemporalChanges; corrDiffs{mouseI}{2}{dpH}];
                twoEnvSpatialDayA = [twoEnvSpatialDayA; corrsAllAB{mouseI}{1}{dpH}(:,1)];
                twoEnvTemporalDayA = [twoEnvTemporalDayA; corrsAllAB{mouseI}{2}{dpH}(:,1)];
                twoEnvPairsOverDays = [twoEnvPairsOverDays; cellPairsHH];
        end
    end
end


figure;
subplot(2,2,1)
plot(oneEnvSpatialChanges,oneEnvTemporalChanges,'.','MarkerEdgeColor',groupColors{1})
aa = oneEnvSpatialChanges(~isnan(oneEnvSpatialChanges) & ~isnan(oneEnvTemporalChanges));
bb = oneEnvTemporalChanges(~isnan(oneEnvSpatialChanges) & ~isnan(oneEnvTemporalChanges));
lm = fitlm(table(aa,bb),'linear');
hold on
plotLocalErrorBars(oneEnvSpatialChanges,oneEnvTemporalChanges,[-2:0.25:2],'std','k')
xlabel('Change in Spatial Corr'); ylabel('Change in Temporal Corr')
[rho,pp] = corr(aa,bb,'type','Spearman');
title(['OneMaze, rr = ' num2str(lm.Rsquared.Ordinary) ', rho,p = ' num2str(rho) ', ' num2str(pp)])
MakePlotPrettySL(gca);

subplot(2,2,3)
plot(twoEnvSpatialChanges,twoEnvTemporalChanges,'.','MarkerEdgeColor',groupColors{2})
aa = twoEnvSpatialChanges(~isnan(twoEnvSpatialChanges) & ~isnan(twoEnvTemporalChanges));
bb = twoEnvTemporalChanges(~isnan(twoEnvSpatialChanges) & ~isnan(twoEnvTemporalChanges));
lm = fitlm(table(aa,bb),'linear');
hold on
plotLocalErrorBars(twoEnvSpatialChanges,twoEnvTemporalChanges,[-2:0.25:2],'std','k')
xlabel('Change in Spatial Corr'); ylabel('Change in temporal Corr')
[rho,pp] = corr(aa,bb,'type','Spearman');
title(['TwoMaze, rr = ' num2str(lm.Rsquared.Ordinary) ', rho,p = ' num2str(rho) ', ' num2str(pp)])
MakePlotPrettySL(gca);

suptitleSL('Change in Spatial Corr of pair by Change in Temporal Corr of pair')
  
% For handling illustrator
%{
figure;
subplot(2,2,1)
%plot(oneEnvSpatialChanges,oneEnvTemporalChanges,'.','MarkerEdgeColor',groupColors{1})
aa = oneEnvSpatialChanges(~isnan(oneEnvSpatialChanges) & ~isnan(oneEnvTemporalChanges));
bb = oneEnvTemporalChanges(~isnan(oneEnvSpatialChanges) & ~isnan(oneEnvTemporalChanges));
lm = fitlm(table(aa,bb),'linear');
hold on
%plotLocalErrorBars(oneEnvSpatialChanges,oneEnvTemporalChanges,[-2:0.25:2],'std','k')
xlabel('Change in Spatial Corr'); ylabel('Change in Temporal Corr')
[rho,pp] = corr(aa,bb,'type','Spearman');
title(['OneMaze, rr = ' num2str(lm.Rsquared.Ordinary) ', rho,p = ' num2str(rho) ', ' num2str(pp)])
MakePlotPrettySL(gca);
%axis off
set(gca,'XTick',[])
set(gca,'YTick',[])

subplot(2,2,3)
%plot(twoEnvSpatialChanges,twoEnvTemporalChanges,'.','MarkerEdgeColor',groupColors{2})
aa = twoEnvSpatialChanges(~isnan(twoEnvSpatialChanges) & ~isnan(twoEnvTemporalChanges));
bb = twoEnvTemporalChanges(~isnan(twoEnvSpatialChanges) & ~isnan(twoEnvTemporalChanges));
lm = fitlm(table(aa,bb),'linear');
hold on
%plotLocalErrorBars(twoEnvSpatialChanges,twoEnvTemporalChanges,[-2:0.25:2],'std','k')
xlabel('Change in Spatial Corr'); ylabel('Change in temporal Corr')
[rho,pp] = corr(aa,bb,'type','Spearman');
title(['TwoMaze, rr = ' num2str(lm.Rsquared.Ordinary) ', rho,p = ' num2str(rho) ', ' num2str(pp)])
MakePlotPrettySL(gca);
%axis off
set(gca,'XTick',[])
set(gca,'YTick',[])

suptitleSL('Change in Spatial Corr of pair by Change in Temporal Corr of pair')


figure;
subplot(2,2,1)
plot([-2 2],[0 0],'k'); hold on
plotLocalErrorBars(twoEnvSpatialChanges,twoEnvTemporalChanges,[-2:0.25:2],'std','k')
MakePlotPrettySL(gca);
xlim([-2 2]); ylim([-1 1])

subplot(2,2,3)
plot([-2 2],[0 0],'k'); hold on
plotLocalErrorBars(twoEnvSpatialChanges,twoEnvTemporalChanges,[-2:0.25:2],'std','k')
MakePlotPrettySL(gca);
xlim([-2 2]); ylim([-1 1])

suptitleSL('Change in Spatial Corr of pair by Change in Temporal Corr of pair')
%}

% Change in temporal correlation by baseline spatial correlation
% Change in temporal correlation by baseline temporal correlation
% Stronger with rule/environment than across...
figure; 
disp('work here')
%[xx,ff] = ecdf(oneEnvTem


% Among cells that stay in a temporally correlated pair, what are their
% spatial correlations?
for edgeI = 1:numel(edgeThreshes)
    oneEnvSpatialCorrsE = [];
    twoEnvSpatialCorrsE = [];
    oneEnvNotTempSpatialCorrsE = [];
    twoEnvNotTempSpatialCorrsE = [];
    oneEnvMeanRanks = [];
    oneEnvRanksAll = [];
    twoEnvMeanRanks = [];
    twoEnvRanksAll = [];
    for mouseI = 1:numMice
        for dpH = 1:size(dayPairsHere,1)
            cellPairsHH = [];
            [cellPairsHH(:,1),cellPairsHH(:,2)] = ind2sub([numCells(mouseI) numCells(mouseI)],cellPairsOverDays{mouseI}{dpH});
            pairsHere = cellPairsHH;

            singleCellPairCorrs = singleCellAllCorrsRho{mouseI}{1}{dpH}(pairsHere);

            temporalCorrChanges = corrDiffs{mouseI}{2}{dpH};
            temporalDayB = corrsAllAB{mouseI}{2}{dpH}(:,2);
            temporalDayA = corrsAllAB{mouseI}{2}{dpH}(:,1);

            stayedTempCorr = (temporalDayB > edgeThreshes(edgeI)) &...
                             (temporalDayA > edgeThreshes(edgeI));

            uniqueCellsHere = unique(pairsHere(stayedTempCorr,:)); 

            
            cellsHereBlank = false(numCells(mouseI),1);

            uch = uniqueCellsHere;
            uniqueCellsHere = cellsHereBlank; uniqueCellsHere(uch) = true; 

            allCellsActive = unique(pairsHere); % This is all the cells that are active both days in the pair
            aca = allCellsActive;
            allCellsActive = cellsHereBlank; allCellsActive(aca) = true;

            uniqueNotTempCorr = allCellsActive & (~uniqueCellsHere);
            
            if sum(allCellsActive) ~= sum(uniqueNotTempCorr) + sum(uniqueCellsHere)
                disp('logical summation error n cells here')
                keyboard
            end
            % potentialCellPairs = pairsHere(stayedTempCorr,:); index into vvv to look for low spatial correlation
            % pcpTempCorrs = [temporalDayA(stayedTempCorr), temporalDayB(stayedTempCorr)];
            % pcpSpatialCorrs = [singleCellAllCorrsRho{mouseI}{1}{dpH}(potentialCellPairs)];

            uniqueCellCorrs = singleCellAllCorrsRho{mouseI}{1}{dpH}(uniqueCellsHere);
            uniqueNotTempCorrs = singleCellAllCorrsRho{mouseI}{1}{dpH}(uniqueNotTempCorr);
            % Percentile rank of these correlations: 
            percentileRanksH = percentileOfEach(singleCellAllCorrsRho{mouseI}{1}{dpH});
            percentileRanksThese = percentileRanksH(uniqueCellsHere);
            
            switch groupNum(mouseI)
                case 1
                    oneEnvSpatialCorrsE = [oneEnvSpatialCorrsE; uniqueCellCorrs];
                    oneEnvNotTempSpatialCorrsE = [oneEnvNotTempSpatialCorrsE; uniqueNotTempCorrs];
                    oneEnvMeanRanks = [oneEnvMeanRanks; mean(percentileRanksThese)];
                    oneEnvRanksAll = [oneEnvRanksAll; percentileRanksThese];
                case 2
                    twoEnvSpatialCorrsE = [twoEnvSpatialCorrsE; uniqueCellCorrs];
                    twoEnvNotTempSpatialCorrsE = [twoEnvNotTempSpatialCorrsE; uniqueNotTempCorrs];
                    twoEnvMeanRanks = [twoEnvMeanRanks; mean(percentileRanksThese)];
                    twoEnvRanksAll = [twoEnvRanksAll; percentileRanksThese];
            end
        end
    end
    
    oneEnvMeanCorrE(edgeI) = mean(oneEnvSpatialCorrsE);
    oneEnvSemCorrE(edgeI) = standarderrorSL(oneEnvSpatialCorrsE);
    twoEnvMeanCorrE(edgeI) = mean(twoEnvSpatialCorrsE);
    twoEnvSemCorrE(edgeI) = standarderrorSL(twoEnvSpatialCorrsE);

    oneEnvMeanNotTempCorrE(edgeI) = mean(oneEnvNotTempSpatialCorrsE);
    oneEnvSemNotTempCorrE(edgeI) = standarderrorSL(oneEnvNotTempSpatialCorrsE);
    twoEnvMeanNotTempCorrE(edgeI) = mean(twoEnvNotTempSpatialCorrsE);
    twoEnvSemNotTempCorrE(edgeI) = standarderrorSL(twoEnvNotTempSpatialCorrsE);

    [oneEnvTempNonTempP(edgeI),~] = ranksum(oneEnvSpatialCorrsE,oneEnvNotTempSpatialCorrsE);
    [twoEnvTempNonTempP(edgeI),~] = ranksum(twoEnvSpatialCorrsE,twoEnvNotTempSpatialCorrsE);
    
    oneEnvMeanRankE(edgeI) = mean(oneEnvRanksAll);
    oneEnvSemRankE(edgeI) = standarderrorSL(oneEnvRanksAll);
    twoEnvMeanRankE(edgeI) = mean(twoEnvRanksAll);
    twoEnvSemRankE(edgeI) = standarderrorSL(twoEnvRanksAll);
    
    [ranksumP(edgeI),~] = ranksum(oneEnvSpatialCorrsE,twoEnvSpatialCorrsE);
    [~,ksP(edgeI)] = kstest2(oneEnvSpatialCorrsE,twoEnvSpatialCorrsE);
end
msgbox('At all these edges, active cells in an ensemble have a higher spatial correlation across the day pair than active cells out of an ensemble, OneMaze and TwoMaze')

figure;
errorbar(edgeThreshes,oneEnvMeanCorrE,oneEnvSemCorrE,'Color',groupColors{1})
hold on                
errorbar(edgeThreshes,twoEnvMeanCorrE,twoEnvSemCorrE,'Color',groupColors{2})
%errorbar(edgeThreshes,oneEnvMeanNotTempCorrE,oneEnvSemNotTempCorrE,'LineStyle',':','Color',groupColors{1})
%errorbar(edgeThreshes,twoEnvMeanNotTempCorrE,twoEnvSemNotTempCorrE,'LineStyle',':','Color',groupColors{2})
for edgeI = 1:numel(edgeThreshes)
    text(edgeThreshes(edgeI),0.3,num2str(ranksumP(edgeI)),'Rotation',45)
    text(edgeThreshes(edgeI),0.1,num2str(ksP(edgeI)),'Rotation',45)
end
plot(edgeThreshes([1 end]),[0 0],'k')
title('Coordinated remapping')
xlabel('Correlation Edge Threshold')
ylabel('Mean Single-Cell Spatial Ratemap Correlation')
ylim([0.3 0.8])
MakePlotPrettySL(gca);

figure;
errorbar(edgeThreshes,oneEnvMeanRankE,oneEnvSemRankE,'Color',groupColors{1})
hold on                
errorbar(edgeThreshes,twoEnvMeanRankE,twoEnvSemRankE,'Color',groupColors{2})
for edgeI = 1:numel(edgeThreshes)
    %text(edgeThreshes(edgeI),0.3,num2str(ranksumP(edgeI)),'Rotation',45)
    %text(edgeThreshes(edgeI),0.1,num2str(ksP(edgeI)),'Rotation',45)
end
title('Coordinated remapping')
xlabel('Correlation Edge Threshold')
ylabel('Mean Single-Cell Spatial Ratemap Correlation Percentile Rank')
ylim([0 0.8])
MakePlotPrettySL(gca);

% For each pair of days a neuron is present, separately keep track of its
% spatial correlation across that day pair depending on whether it's in a temporally correlated pair or not
% could then plot these averages, or could get the difference between means
% of each of these for each cell, average that
oneEnvMeanCorrsIn = cell(nEdgeThreshes,1);
oneEnvMeanCorrsOut = cell(nEdgeThreshes,1);
oneEnvMeanCorrsInOutDiff = cell(nEdgeThreshes,1);
oneEnvCorrsDiffInfo = cell(nEdgeThreshes,1);
twoEnvMeanCorrsIn = cell(nEdgeThreshes,1);
twoEnvMeanCorrsOut = cell(nEdgeThreshes,1);
twoEnvMeanCorrsInOutDiff = cell(nEdgeThreshes,1);
twoEnvCorrsDiffInfo = cell(nEdgeThreshes,1);

for mouseI = 1:numMice
    for cellI = 1:numCells(mouseI)
        % will there even be enough dayUse above thresh to check
        if sum(dayUse{mouseI}(cellI,unique(dayPairsHere))) > 2
        
        cellSpatialCorrsH = [];
        cellTempCorrsH = [];
        
        maxTempCorrThisDayPairA = [];
        maxTempCorrThisDayPairB = [];
        for dpH = 1:numDayPairs
            % Is the cell active this day pair
            cellStaysActive = dayUseAll{mouseI}(cellI,dayPairsHere(dpH,1)) & dayUseAll{mouseI}(cellI,dayPairsHere(dpH,2));
            if cellStaysActive
                % Pairs including this cell, to index into tempCorrs
                pairsThisCellA = sum(cellPairsUsed{mouseI}{dayPairsHere(dpH,1)} == cellI,2) > 0;
                pairsThisCellB = sum(cellPairsUsed{mouseI}{dayPairsHere(dpH,2)} == cellI,2) > 0;
                temporalCorrsThisCellDayA = temporalCorrsR{mouseI}{dayPairsHere(dpH,1)}(pairsThisCellA);
                temporalCorrsThisCellDayB = temporalCorrsR{mouseI}{dayPairsHere(dpH,2)}(pairsThisCellB);
                spatialCorrThisDayPair = singleCellAllCorrsRho{mouseI}{1}{dpH}(cellI);
                
                maxTempCorrThisDayPairA = [maxTempCorrThisDayPairA; max(temporalCorrsThisCellDayA)];
                maxTempCorrThisDayPairB = [maxTempCorrThisDayPairB; max(temporalCorrsThisCellDayB)];
                cellSpatialCorrsH = [cellSpatialCorrsH; spatialCorrThisDayPair];
            end
        end

        if any(isnan(cellSpatialCorrsH))
            disp('nan corrs')
            keyboard
        end

        for edgeI = 1:nEdgeThreshes
            corrAcrossDays = (maxTempCorrThisDayPairA > edgeThreshes(edgeI)) & (maxTempCorrThisDayPairB > edgeThreshes(edgeI));

            % Need day pairs where above and below temp corr thresh to make this comparison
            if any(corrAcrossDays == 1) && any(corrAcrossDays == 0)
            
                corrsInEnsemble = cellSpatialCorrsH(corrAcrossDays);
                corrsOutEnsemble = cellSpatialCorrsH(~corrAcrossDays);
                
                meanCorrsIn = mean(corrsInEnsemble);
                meanCorrsOut = mean(corrsOutEnsemble);
                meanInOutDiff = meanCorrsIn - meanCorrsOut;

                switch groupNum(mouseI)
                    case 1
                        oneEnvMeanCorrsIn{edgeI} = [oneEnvMeanCorrsIn{edgeI}; meanCorrsIn];
                        oneEnvMeanCorrsOut{edgeI} = [oneEnvMeanCorrsOut{edgeI}; meanCorrsOut];
                        oneEnvMeanCorrsInOutDiff{edgeI} = [oneEnvMeanCorrsInOutDiff{edgeI}; meanInOutDiff];
                        oneEnvCorrsDiffInfo{edgeI} = [oneEnvCorrsDiffInfo{edgeI}; [mouseI, cellI, numel(corrAcrossDays)]];
                    case 2
                        twoEnvMeanCorrsIn{edgeI} = [twoEnvMeanCorrsIn{edgeI}; meanCorrsIn];
                        twoEnvMeanCorrsOut{edgeI} = [twoEnvMeanCorrsOut{edgeI}; meanCorrsOut];
                        twoEnvMeanCorrsInOutDiff{edgeI} = [twoEnvMeanCorrsInOutDiff{edgeI}; meanInOutDiff];
                        twoEnvCorrsDiffInfo{edgeI} = [twoEnvCorrsDiffInfo{edgeI}; [mouseI, cellI, numel(corrAcrossDays)]];
                end
            end 
        end % edgeI
        end % enough dayUse

    end % cellI
end % mouseI

oneEnvInOutDiffMean = cellfun(@mean, oneEnvMeanCorrsInOutDiff);
oneEnvInOutDiffSEM = cellfun(@standarderrorSL, oneEnvMeanCorrsInOutDiff);
twoEnvInOutDiffMean = cellfun(@mean, twoEnvMeanCorrsInOutDiff);
twoEnvInOutDiffSEM = cellfun(@standarderrorSL, twoEnvMeanCorrsInOutDiff);
[inOutDiffP,inOutDiffH] = cellfun(@(x,y) ranksum(x,y),oneEnvMeanCorrsInOutDiff(7:end),twoEnvMeanCorrsInOutDiff(7:end));
[oneEnvInOutP,~] = cellfun(@(x,y) ranksum(x,y),oneEnvMeanCorrsIn(7:end),oneEnvMeanCorrsOut(7:end));
[twoEnvInOutP,~] = cellfun(@(x,y) ranksum(x,y),twoEnvMeanCorrsIn(7:end),twoEnvMeanCorrsOut(7:end));
[oneEnvInOutP<0.05, twoEnvInOutP < 0.05]
%should then check what % of cells/tempcorrelation pairs included here...

figure;
errorbar(edgeThreshes,oneEnvInOutDiffMean,oneEnvInOutDiffSEM,'Color',groupColors{1})
hold on                
errorbar(edgeThreshes,twoEnvInOutDiffMean,twoEnvInOutDiffSEM,'Color',groupColors{2})
plot([min(edgeThreshes) max(edgeThreshes)],[0 0],'k')
for edgeI = 1:numel(edgeThreshes)
    %text(edgeThreshes(edgeI),0.3,num2str(ranksumP(edgeI)),'Rotation',45)
    %text(edgeThreshes(edgeI),0.1,num2str(ksP(edgeI)),'Rotation',45)
end
title('Within-cell mean diff of in/out ensemble')
xlabel('Correlation Edge Threshold')
ylabel('In- Out-Ensemble Correlation Difference')
ylim([-0.3 0.3])
MakePlotPrettySL(gca);


oneEnvMeanInMean = cellfun(@mean,oneEnvMeanCorrsIn);
oneEnvMeanInSEM = cellfun(@standarderrorSL,oneEnvMeanCorrsIn);
oneEnvMeanOutMean = cellfun(@mean,oneEnvMeanCorrsOut);
oneEnvMeanOutSEM = cellfun(@standarderrorSL,oneEnvMeanCorrsOut);
twoEnvMeanInMean = cellfun(@mean,twoEnvMeanCorrsIn);
twoEnvMeanInSEM = cellfun(@standarderrorSL,twoEnvMeanCorrsIn);
twoEnvMeanOutMean = cellfun(@mean,twoEnvMeanCorrsOut);
twoEnvMeanOutSEM = cellfun(@standarderrorSL,twoEnvMeanCorrsOut);
figure;
errorbar(edgeThreshes,oneEnvMeanInMean,oneEnvMeanInSEM,'Color',groupColors{1})
hold on                
errorbar(edgeThreshes,twoEnvMeanInMean,twoEnvMeanInSEM,'Color',groupColors{2})
errorbar(edgeThreshes,oneEnvMeanOutMean,oneEnvMeanOutSEM,'LineStyle',':','Color',groupColors{1})
errorbar(edgeThreshes,twoEnvMeanOutMean,twoEnvMeanOutSEM,'LineStyle',':','Color',groupColors{2})
plot([min(edgeThreshes) max(edgeThreshes)],[0 0],'k')
for edgeI = 1:numel(edgeThreshes)
    %text(edgeThreshes(edgeI),0.3,num2str(ranksumP(edgeI)),'Rotation',45)
    %text(edgeThreshes(edgeI),0.1,num2str(ksP(edgeI)),'Rotation',45)
end
title('Within Neuron Mean In/Out-Ensemble Correlation')
xlabel('Correlation Edge Threshold')
ylabel('Mean within cell In/Out Corr')
ylim([-0.3 0.6])
MakePlotPrettySL(gca);

%{
oneEnvPairedCorrsMeans = [];
oneEnvPairedCorrsDiffs = [];
oneEnvPairedCorrsTempChange = [];
oneEnvPairedCorrsTempCorrDayB = [];
oneEnvPairedCorrsTempCorrDayA = [];
twoEnvPairedCorrsMeans = [];
twoEnvPairedCorrsDiffs = [];
twoEnvPairedCorrsTempChange = [];[
twoEnvPairedCorrsTempCorrDayB = [];
twoEnvPairedCorrsTempCorrDayA = [];
oneEnvPairedCorrsCells = [];
twoEnvPairedCorrsCells = [];
oneEnvMouseID = [];
twoEnvMouseID = [];
oneEnvDayPairID = [];
twoEnvDayPairID = [];

for edgeI = 1:numel(edgeThreshes)
oneEnvSpatialCorrsE = [];
twoEnvSpatialCorrsE = [];
for mouseI = 1:numMice
    for dpH = 1:size(dayPairsHere,1)
        cellPairsHH = [];
        [cellPairsHH(:,1),cellPairsHH(:,2)] = ind2sub([numCells(mouseI) numCells(mouseI)],cellPairsOverDays{mouseI}{dpH});
        pairsHere = cellPairsHH;
        
        singleCellPairCorrs = singleCellAllCorrsRho{mouseI}{1}{dpH}(pairsHere);
        
        temporalCorrChanges = corrDiffs{mouseI}{2}{dpH};
        temporalDayB = corrsAllAB{mouseI}{2}{dpH}(:,2);
        temporalDayA = corrsAllAB{mouseI}{2}{dpH}(:,1);
        
        stayedTempCorr = (temporalDayB > edgeThreshes(edgeI)) &...
                         (temporalDayA > edgeThreshes(edgeI));
        
        uniqueCellsHere = unique(pairsHere(stayedTempCorr,:));
        
        uniqueCellCorrs = singleCellAllCorrsRho{mouseI}{1}{dpH}(uniqueCellsHere);
        
        switch groupNum(mouseI)
            case 1
                oneEnvSpatialCorrsE; uniqueCellCorrs];
            case 2
                twoEnvSpatialCorrsE = [twoEnvSpatialCorrsE; uniqueCellCorrs];
        end
        %{
        switch groupNum(mouseI)
            case 1
                %oneEnvSpatialCorrs = [oneEnvSpatialCorrs; singleCellPairCorrs];
                oneEnvPairedCorrsMeans = [oneEnvPairedCorrsMeans; mean(singleCellPairCorrs,2)];
                oneEnvPairedCorrsDiffs = [oneEnvPairedCorrsDiffs; singleCellPairCorrs(:,2) - singleCellPairCorrs(:,2)];
                oneEnvPairedCorrsTempChange = [oneEnvPairedCorrsTempChange; temporalCorrChanges];
                oneEnvPairedCorrsTempCorrDayB = [oneEnvPairedCorrsTempCorrDayB; temporalDayB];
                oneEnvPairedCorrsTempCorrDayA = [oneEnvPairedCorrsTempCorrDayA; temporalDayA];
                oneEnvPairedCorrsCells = [oneEnvPairedCorrsCells; pairsHere];
                oneEnvMouseID = [oneEnvMouseID; mouseI*ones(size(temporalDayB))];
                oneEnvDayPairID = [oneEnvDayPairID; dpH*ones(size(temporalDayB))];
            case 2
                twoEnvPairedCorrsMeans = [twoEnvPairedCorrsMeans; mean(singleCellPairCorrs,2)];
                twoEnvPairedCorrsDiffs = [twoEnvPairedCorrsDiffs; singleCellPairCorrs(:,2) - singleCellPairCorrs(:,2)];
                twoEnvPairedCorrsTempChange = [twoEnvPairedCorrsTempChange; temporalCorrChanges];
                twoEnvPairedCorrsTempCorrDayB = [twoEnvPairedCorrsTempCorrDayB; temporalDayB];
                twoEnvPairedCorrsTempCorrDayA = [twoEnvPairedCorrsTempCorrDayA; temporalDayA];
                twoEnvPairedCorrsCells = [twoEnvPairedCorrsCells; pairsHere];
                twoEnvMouseID = [twoEnvMouseID; mouseI*ones(size(temporalDayB))];
                twoEnvDayPairID = [twoEnvDayPairID; dpH*ones(size(temporalDayB))];
        end
        %}
    end
end
  %}
  
                
%{
for edgeI = 1:nEdgeThreshes
    % Pairs of cells that stay temporally correlated
    stillTempCorr = oneEnvPairedCorrsTempCorrDayB > edgeThreshes(edgeI);
    wereTempCorr = oneEnvPairedCorrsTempCorrDayA > edgeThreshes(edgeI);
    
    uniqueCellsHere = oneEnvPairedCorrsCells(stillTempCorr & wereTempCorr, :);
    for mouseI = 1:3
    mouseCellsHere = oneEnvMouseID
    % Spatial correlation for both of these cells
    
    end
    
    for mouseI = 4:6
    
    end
end
%}
%{
figure; 
subplot(2,2,1)
plot(oneEnvSpatialDayA,oneEnvSpatialChanges,'.','MarkerEdgeColor',groupColors{1})
lm = fitlm(table(oneEnvSpatialDayA,oneEnvSpatialChanges),'linear');
xlabel('Spatial Corr Day1-3'); ylabel('Change in Spatial Corr')
title(['OneMaze, rr = ' num2str(lm.Rsquared.Ordinary)])

subplot(2,2,2)
plot(oneEnvTemporalDayA,oneEnvSpatialChanges,'.','MarkerEdgeColor',groupColors{1})
lm = fitlm(table(oneEnvTemporalDayA,oneEnvSpatialChanges),'linear');
xlabel('Temporal Corr Day1-3'); ylabel('Change in Spatial Corr')
title(['OneMaze, rr = ' num2str(lm.Rsquared.Ordinary)])

subplot(2,2,3)
plot(oneEnvTemporalDayA,oneEnvTemporalChanges,'.','MarkerEdgeColor',groupColors{1})
lm = fitlm(table(oneEnvTemporalDayA,oneEnvTemporalChanges),'linear');
xlabel('Temporal Corr Day1-3'); ylabel('Change in Temporal Corr')
title(['OneMaze, rr = ' num2str(lm.Rsquared.Ordinary)])

subplot(2,2,4)
plot(oneEnvSpatialDayA,oneEnvTemporalChanges,'.','MarkerEdgeColor',groupColors{1})
lm = fitlm(table(oneEnvSpatialDayA,oneEnvTemporalChanges),'linear');
xlabel('Spatial Corr Day1-3'); ylabel('Change in Temporal Corr')
title(['OneMaze, rr = ' num2str(lm.Rsquared.Ordinary)])

suptitleSL('Change in Correlaion of pair by Baseline, turn 1 correlation of pair')
%}

% Example cell pairs plots
disp('Really need these example plots...')

edgeThreshes = 0:0.025:0.4;

corrsTest = temporalCorrsR;
coactivityAnalyses2;

%corrsTest = spatialCorrsR;      

%coactivityAnalyses2;



%{
oneEnvAllCoactivity = [];
twoEnvAllCoactivity = [];

tic

nCoactBins = 2;
nCoactBins = 1;

switch nCoactBins
    case 2
        coactFileN = 'coactivityScoresBins.mat';
        coactVariable = 'coactivityScoreEachBin';
        for mouseI = 1:numMice
            coactFileH = fullfile(mainFolder,mice{mouseI},coactFileN);
            if exist(coactFileH,'file')==0
            tic
            coactivityScoreEachBin = cell(4,9,2);
            for bbI = 1:nCoactBins
                for condI = 1:4
                    binsHH = lgDataBins.labels==armLabels{condI};
                    xLimsH = [min(min(lgDataBins.X(binsHH,:))) max(max(lgDataBins.X(binsHH,:)))];
                    yLimsH = [min(min(lgDataBins.Y(binsHH,:))) max(max(lgDataBins.Y(binsHH,:)))];

                    %This isn't perfect and we'll need to adjust somehow for days 4:6
                    switch armLabels{condI}
                        case 'n'
                            xBox = [xLimsH fliplr(xLimsH)];
                            yBoundsUse = linspace(max(yLimsH),min(yLimsH),nCoactBins+1);

                            xB = xBox;
                            yB = yBoundsUse([bbI bbI bbI+1 bbI+1]); 

                            %bounds = [];
                            %for bbI = 1:nCoactBins
                                %bounds{bbI}.X = xBox;
                                %bounds{bbI}.Y = yBoundsUse([bbI bbI bbI+1 bbI+1]); 
                            %end
                        case 'w'
                            yBox = [yLimsH fliplr(yLimsH)];
                            xBoundsUse = linspace(max(xLimsH),min(xLimsH),nCoactBins+1);

                            xB = xBoundsUse([bbI bbI bbI+1 bbI+1]);
                            yB = yBox;
                        case 's'
                            xBox = [xLimsH fliplr(xLimsH)];
                            yBoundsUse = linspace(min(yLimsH),max(yLimsH),nCoactBins+1);

                            xB = xBox;
                            yB = yBoundsUse([bbI bbI bbI+1 bbI+1]); 
                        case 'e'
                            yBox = [yLimsH fliplr(yLimsH)];
                            xBoundsUse = linspace(min(xLimsH),max(xLimsH),nCoactBins+1);

                            xB = xBoundsUse([bbI bbI bbI+1 bbI+1]);
                            yB = yBox;
                    end

                    bounds{condI}.X = xB;
                    bounds{condI}.Y = yB;

                end

                condPairs = [1;2;3;4];

                daysR = [1 2 3 7 8 9];
                [cse,ntae,ntce,ntte] = ...
                findingEnsemblesNotes4(cellTBT{mouseI},bounds,condPairs,false,daysR);
                % Slot into the right days (columns) and binNum (3rd dimension)
                coactivityScoreEachBin(:,daysR,bbI) = cse(:,daysR);

                daysR = [4 5 6];
                if mouseI == 1
                    daysR = 4;
                end
                binsHH = lgDataBins.labels==armLabels{4};
                xLimsH = [min(min(lgDataBins.X(binsHH,:))) max(max(lgDataBins.X(binsHH,:)))];
                yLimsH = [min(min(lgDataBins.Y(binsHH,:))) max(max(lgDataBins.Y(binsHH,:)))];
                xBoundsUse = linspace(min(xLimsH),max(xLimsH),nCoactBins+1);
                xB = xBoundsUse([bbI bbI bbI+1 bbI+1]);
                yB = yBox;
                bounds{2}.X = xB;
                bounds{2}.Y = yB;
                [cse,ntae,ntce,ntte] = ...
                findingEnsemblesNotes4(cellTBT{mouseI},bounds,condPairs,false,daysR);
                % Slot into the right days (columns) and binNum (3rd dimension)
                coactivityScoreEachBin(:,daysR,bbI) = cse(:,daysR);

                allBounds{bbI} = bounds;
            end
            save(coactFileH,...
                    'coactivityScoreEachBin','bounds','-v7.3')
            toc
            else
                disp(['Have coactivity for mouse ' num2str(mouseI)])
            end  
            
        
        end

    case 1
        coactFileN = 'coactivityScores.mat';
        for mouseI = 1:numMice
            coactFileH = fullfile(mainFolder,mice{mouseI},'coactivityScores.mat');
            coactVariable = 'coactivityScoreEach';
            if exist(coactFileH,'file')==0
            tic
            condPairs = [1 2 3 4];
            % Would be great to adjust this to only run certain sessions...
            [coactivityScoreAll,numTrialsActiveAll,numTrialsCoactiveAll,numTotalTrialsAll] = ...
                findingEnsemblesNotes4(cellTBT{mouseI},allMazeBound,condPairs,false,[]);

            condPairs = [1;2;3;4];
            [coactivityScoreEach,numTrialsActiveEach,numTrialsCoactiveEach,numTotalTrialsEach] = ...
                findingEnsemblesNotes4(cellTBT{mouseI},allMazeBound,condPairs,false,[]);

            toc

            % Smaller bins in coactivity; maybe just give it bins, iterate from
            % there? Or could use smaller bins as a replacement for allMazeBound,
            % work with one cond at a time
                % the way this is setup, we should do each cond together but go by
                % the same subset of boundary bins

            %Should shuffle laps to test for significance: just compare coactivity
            %score against each shuffle, get num greater
            % May need to profile this to make it run a bit faster...

            % Normalize some how?
            save(coactFileH,...
                'coactivityScoreAll','numTrialsActiveAll','numTrialsCoactiveAll','numTotalTrialsAll',...
                'coactivityScoreEach','numTrialsActiveEach','numTrialsCoactiveEach','numTotalTrialsEach')
            else
                disp(['Have coactivity for mouse ' num2str(mouseI)])
            
            end
            
        end

end
toc

%coactivityScore{mouseI},numTrialsActive{mouseI},numTrialsCoactive{mouseI},numTotalTrials{mouseI}

% Example dotplot, Example heatmap, rasters of cells with, make sure rois are distant
cellI = 2;
condPlot = [1 2 3 4];
dayI = 1;

mouseI = 1;
PlotDotplotDoublePlus2(cellTBT{mouseI},cellI,condPlot,dayI,'dynamic',[],3)%
there = [cellTMap{mouseI}{cellI,dayI,:}]; there = [NaN; there(:)]';
gradientLims = []; titles = [];
disp('This is wrong, use lgPlotHere for correct order (probably? compare to raster plots)')
[figHand] = PlusMazePVcorrHeatmap3(there,lgPlotBins,'jet',gradientLims,titles);
figHand.Position=[243.5000 207 447 405];
PlotDoublePlusRaster(cellTBT{mouseI},cellI,dayI,condPlot,armLabels)
% Also ROI, leave that for now

% Is coactivity correlated with spatial map? yes, should be true for both groups
tic
oneEnvTmapRhos = [];
oneEnvTmapPs = [];
oneEnvCoactRhos = [];
oneEnvCoactPs = [];
oneEnvCoact = [];
oneEnvCellPairs = [];
oneEnvMouseNum = [];
oneEnvSessNum = [];
twoEnvTmapRhos = [];
twoEnvTmapPs = [];
twoEnvCoactRhos = [];
twoEnvCoactPs = [];
twoEnvCoact = [];
twoEnvCellPairs = [];
twoEnvMouseNum = [];
twoEnvSessNum = [];
for mouseI = 1:numMice
    
    tmapHere = cell(numCells(mouseI),9);
    for condI = 1:4
        tmapHere = cellfun(@(x,y) [x;y],tmapHere,cellTMap{mouseI}(:,:,condI),'UniformOutput',false);
    end
    
    for sessI = 1:9
        cellsActive = dayUseAll{mouseI}(:,sessI); 
        % With this we could pre-allocate the gather arrays, though would then need to index them...
        
        cellPairsHere = nchoosek(find(cellsActive),2); 
        cphInds = sub2ind(size(coactivityScore{mouseI}{sessI}),cellPairsHere(:,1),cellPairsHere(:,2));
        
        % Trim out unwanted rows (not in cells use) from coactivityScore, again correlate columns
        coactHere = coactivityScore{mouseI}{sessI}(cellsActive,:);
        if any(any(coactHere))
            %{
        [coactRhos,coactPs] = corr(coactHere,'type','Spearman');
        
        tmm = cell2mat(tmapHere(:,sessI)');
        [tmapRhos,tmapPs] = corr(tmm,'type','Spearman');
        
        tmapRhosHere = tmapRhos(cphInds);
        tmapPsHere = tmapPs(cphInds);
        coactRhosHere = coactRhos(cphInds); % Correlation of coactivity scores
        coactPsHere = coactPs(cphInds);
        coactScoresHere = coactivityScore{mouseI}{sessI}(cphInds);
        
        [tmapVcoactRho(mouseI,sessI),tmapVcoactP(mouseI,sessI)] = corr(tmapRhosHere,coactScoresHere,'type','Spearman');  
        [tmapVcoactVectorRho(mouseI,sessI),tmapVcoactVectorP(mouseI,sessI)] = corr(tmapRhosHere,coactRhosHere,'type','Spearman');  
        %}

        switch groupNum(mouseI)
            case 1
                oneEnvCellPairs = [oneEnvCellPairs; cellPairsHere];
                oneEnvTmapRhos = [oneEnvTmapRhos; tmapRhosHere];
                oneEnvTmapPs = [oneEnvTmapPs; tmapPsHere];
                oneEnvCoactRhos = [oneEnvCoactRhos; coactRhosHere];
                oneEnvCoactPs = [oneEnvCoactPs; coactPsHere];
                oneEnvCoact = [oneEnvCoact; coactScoresHere];
                
                oneEnvMouseNum = [oneEnvMouseNum; mouseI*ones(size(tmapRhosHere))];
                oneEnvSessNum = [oneEnvSessNum; sessI*ones(size(tmapRhosHere))];
            case 2
                twoEnvCellPairs = [twoEnvCellPairs; cellPairsHere];
                twoEnvTmapRhos = [twoEnvTmapRhos; tmapRhosHere];
                twoEnvTmapPs = [twoEnvTmapPs; tmapPsHere];
                twoEnvCoactRhos = [twoEnvCoactRhos; coactRhosHere];
                twoEnvCoactPs = [twoEnvCoactPs; coactPsHere];
                twoEnvCoact = [twoEnvCoact; coactScoresHere];
                
                twoEnvMouseNum = [twoEnvMouseNum; mouseI*ones(size(tmapRhosHere))];
                twoEnvSessNum = [twoEnvSessNum; sessI*ones(size(tmapRhosHere))];
                
        end
            %{
            rhosH = [rhosH; rr];
            psH = [psH; pp];
            zsH = [zsH; coactivityScore{mouseI}{sessI}(cellPairsHere(cpI,1),cellPairsHere(cpI,2))];
            %}
        end
        %{
        figure; plot(zsH,rhosH,'.')
        xlabel('Coactivity Score'); ylabel('Spearman rho')
        [rho,ppp] = corr(zsH,rhosH,'type','Spearman');
        %}
        
    
    end
end
toc

% num elements in nchoosek is n!/((n–k)! k!)

mouseI = 1;
sessI = 3;
datInds = (oneEnvMouseNum==mouseI) & (oneEnvSessNum==sessI);
tmapRhosH = oneEnvTmapRhos(datInds);
coactH = oneEnvCoact(datInds);
figure; plot(coactH,tmapRhosH,'.'); ylabel('Spatial Activity Correlation (rho)'); xlabel('Coactivity Score')
[rr,pp] = corr(coactH,tmapRhosH,'type','Pearson');
title({['Mouse ' num2str(mouseI) ', session ' num2str(sessI)];['r = ' num2str(rr) ', p = ' num2str(pp)]})
MakePlotPrettySL(gca);
cellPairsH = oneEnvCellPairs(datInds,:);
% High coacativity, high corr
pairI = 305954;
% Low coactivity, low corr:
pairI = 118679;
% Low coactivity, high corr:
pairI = 141791;
pairI = 136625;
% High coactivity, low corr:
pairI = 173280;

cellPair = cellPairsH(pairI,:);
condPlot = [1 2 3 4];
cellI = cellPair(1);
activityPlotStuff;
cellI = cellPair(2);
activityPlotStuff;
disp(['Correlation rho = ' num2str(tmapRhosH(pairI)) '; coactivity score = ' num2str(coactH(pairI))]) 

% Eaxmple dotplot, Example heatmap, rasters of cells with, make sure rois are distant
    %{
    high coactivity, high correlation - active together on same arms
    top quarter vs. low quarter?
    low coactivity, low correlation - active different arms
    low coactivity, high correlation - active different laps
    high coactivity, low correlation - active same laps but different parts of arms (just indicates bad temporal resolotion of coactivity)
    
    can create filter by trialReli to search for good examples here... better yet rank possible examples by trialReli
    %}



% OneMaze vs. TwoMaze: diff in proportion that have the 4 categories above?
% OneMaze vs. TwoMaze: diff in num of cells which change among the 4
% categories above?

% Change in coactivity: if cell becomes uncorrelated with one set of cells
% and now correlated with a new set, is it also coactive with that new set?

% Cells that stay spatially correlated but find a new ensemble for temporal
% correlation? Does this actually answer a question? Kind of yes, is that
% temporal coordination independent of spatial coordination
%   Maybe we can just plot the scatter of change in spatial correlation
%   against change in temporal correlation, show it's (probably) pretty
%   wide, therefore one isn't a perfect proxy for the other (histogram
%   oriented along unity line/regression line
for mouseI = 1:numMice   
        
    for dpI = 1:numDayPairs
        haveCellBothDays = sum(cellSSI{mouseI}(:,dayPairs(dpI,:))>0,2)==2;
        cellActiveOneDay = sum(dayUseAll{mouseI}(:,dayPairs(dpI,:))>0,2)==2;
        
        


    for condI = 1:numel(condPairs)
        for sessI = 1:9
            cHere = trialCoactiveAboveBaseline{mouseI}{sessI,condI};
            switch groupNum(mouseI)
                case 1
                    oneEnvAllCoactivity = [oneEnvAllCoactivity; cHere(~isnan(cHere))];
                case 2
                    twoEnvAllCoactivity = [twoEnvAllCoactivity; cHere(~isnan(cHere))];
            end
        end
    end
    
    end
end

figure; 
subplot(1,2,1); histogram(oneEnvAllCoactivity(oneEnvAllCoactivity~=0) );
subplot(1,2,2); histogram(twoEnvAllCoactivity(twoEnvAllCoactivity~=0));
%}

%% Day to day drift

dayPairsForward = [1 2; 2 3; 3 4; 4 5; 5 6; 6 7; 7 8; 8 9];
dayPairs = dayPairsForward;
numDayPairs = size(dayPairs,1);
daysAcross = zeros(8,1);
daysAcross([3 6]) = 1;

condsUse = [1 3 4];
epochPairs = [1; 1; 0; 2; 2; 0; 3; 3];

% Single neuron corrs, population vector corrs
condPairs = [1 1; 3 3; 4 4];
numCondPairs = size(condPairs,1);

cellTMapH = cellfun(@(x) x(:,:,condsUse),cellTMap,'UniformOutput',false);
SingleCellRemapping4_2
binComb = 'self';
PopulationVectorCorrs4_2;

oneEnvMicePVcorrs = []; oneEnvMicePVcorrsMeans = [];
twoEnvMicePVcorrs = []; twoEnvMicePVcorrsMeans = [];
oneEnvPVmeansAll = []; oneEnvPVsemAll = [];
twoEnvPVmeansAll = []; twoEnvPVsemAll = [];
for dpI = 1:numDayPairs
    for cpI = 1:numCondPairs
        oneEnvMicePVcorrs{dpI,cpI} = pooledPVcorrs{dpI,cpI}(oneEnvMice,:);
        oneEnvMicePVcorrsMeans{dpI,cpI} = nanmean(oneEnvMicePVcorrs{dpI,cpI},1);
        for binI = 1:size(oneEnvMicePVcorrs{dpI,cpI},2)
            oneEnvMicePVcorrsSEM{dpI,cpI}(1,binI) = standarderrorSL(oneEnvMicePVcorrs{dpI,cpI}(:,binI));
        end
        
        twoEnvMicePVcorrs{dpI,cpI} = pooledPVcorrs{dpI,cpI}(twoEnvMice,:);
        twoEnvMicePVcorrsMeans{dpI,cpI} = nanmean(twoEnvMicePVcorrs{dpI,cpI},1);
        for binI = 1:size(twoEnvMicePVcorrs{dpI,cpI},2)
            twoEnvMicePVcorrsSEM{dpI,cpI}(1,binI) = standarderrorSL(twoEnvMicePVcorrs{dpI,cpI}(:,binI));
        end
    end
    
    oneEnvPVmeansAll(dpI) = nanmean(nanmean([oneEnvMicePVcorrs{dpI,:}]));
    oneEnvPVsemAll(dpI) = standarderrorSL([oneEnvMicePVcorrs{dpI,:}]);
    twoEnvPVmeansAll(dpI) = nanmean(nanmean([twoEnvMicePVcorrs{dpI,:}]));
    twoEnvPVsemAll(dpI) = standarderrorSL([twoEnvMicePVcorrs{dpI,:}]);
end


%% PV corrs across rule epochs (Separate states)

numPerms = 1000;

condPairs = [1 1; 3 3; 4 4]; numCondPairs = size(condPairs,1);
condsHere = [1 3 4];
    condsUse = condsHere;
tonepdays = GetAllCombs(1:3,4:6);
tonettwodays = GetAllCombs(1:3,7:9);
pttwodays = GetAllCombs(4:6,7:9);
dayPairs = [tonepdays; tonettwodays; pttwodays];
dayGroups = [1*ones(size(tonepdays,1),1); 2*ones(size(tonettwodays,1),1); 3*ones(size(pttwodays,1),1)];  
dayGroupLabels = {'Turn1 vs. Place';'Turn1 vs. Turn 2';'Place vs. Turn 2'};
numDayPairs = size(dayPairs,1);

dayIntervals{1} = [diff(tonepdays,[],2); diff(pttwodays,[],2)]
dayIntervals{2} = diff(tonettwodays,[],2);

binComb = 'self';
PopulationVectorCorrs4_2;

oneEnvMicePVcorrs = []; oneEnvMicePVcorrsMeans = [];
twoEnvMicePVcorrs = []; twoEnvMicePVcorrsMeans = [];
oneEnvPVmeansAll = []; oneEnvPVsemAll = [];
twoEnvPVmeansAll = []; twoEnvPVsemAll = [];
oneEnvDGmeanAgg = cell(3,1); twoEnvDGmeanAgg = cell(3,1);
for cpI = 1:numCondPairs
    for dpgI = 1:3
        dayPairsHere = find(dayGroups==dpgI);
        
        for dpI = 1:length(dayPairsHere)
            dpJ = dayPairsHere(dpI);
        oneEnvMicePVcorrs{dpgI}{dpI,cpI} = pooledPVcorrs{dpJ,cpI}(oneEnvMice,:);
        oneEnvMicePVcorrsMeans{dpgI}{dpI,cpI} = nanmean(oneEnvMicePVcorrs{dpgI}{dpI,cpI},1);
        
        twoEnvMicePVcorrs{dpgI}{dpI,cpI} = pooledPVcorrs{dpJ,cpI}(twoEnvMice,:);
        twoEnvMicePVcorrsMeans{dpgI}{dpI,cpI} = nanmean(twoEnvMicePVcorrs{dpgI}{dpI,cpI},1);
        
        sameMinusDiff{dpgI}{dpI,cpI} = oneEnvMicePVcorrsMeans{dpgI}{dpI,cpI} - twoEnvMicePVcorrsMeans{dpgI}{dpI,cpI};
        
        %sepMinusInt{dI,cpI} = twoEnvMicePVcorrsMeans{dpI,cpI} - oneEnvMicePVcorrsMeans{dpI,cpI};
        
        for binI = 1:numBins
            %[pPVs{dpI,cpI}(binI),hPVs{dpI,cpI}(binI)] = ranksum(oneEnvMicePVcorrs{dpI,cpI}(:,binI),...
            %twoEnvMicePVcorrs{dpI,cpI}(:,binI));
        end
        
        %diffRank{dpI,cpI} = PermutationTestSL(oneEnvMicePVcorrs{dpI,cpI},twoEnvMicePVcorrs{dpI,cpI},numPerms);
        %isSig{dpI,cpI} = diffRank{dpI,cpI} > (1-pThresh);
        end
        
        % Mean across dayPairs
        corrsHereOne = cell2mat([oneEnvMicePVcorrs{dpgI}(:,cpI)]); %{dayPairI,condI}(mouseI,binI)
        corrsHereTwo = cell2mat([twoEnvMicePVcorrs{dpgI}(:,cpI)]);
        
        oneEnvDGcorrsMean{dpgI}{cpI} = nanmean(corrsHereOne,1);
        twoEnvDGcorrsMean{dpgI}{cpI} = nanmean(corrsHereTwo,1);
        
        for binI = 1:nArmBins
            oneEnvDGcorrsSEM{dpgI}{cpI}(1,binI) = standarderrorSL(corrsHereOne(:,binI));
            twoEnvDGcorrsSEM{dpgI}{cpI}(1,binI) = standarderrorSL(corrsHereTwo(:,binI));
        end
        
        oneEnvDGmeanAgg{dpgI,cpI} = [oneEnvDGcorrsMean{dpgI}{cpI}(:)'];
        twoEnvDGmeanAgg{dpgI,cpI} = [twoEnvDGcorrsMean{dpgI}{cpI}(:)'];
    end
end

% Breakdown by day pair lag
dayGroupsX = dayGroups; dayGroupsX(dayGroupsX~=2) = 1;
oneEnvPVCorrsX{1} = [oneEnvMicePVcorrs{1}; oneEnvMicePVcorrs{3}];
oneEnvPVCorrsX{2} = oneEnvMicePVcorrs{2};
twoEnvPVCorrsX{1} = [twoEnvMicePVcorrs{1}; twoEnvMicePVcorrs{3}];
twoEnvPVCorrsX{2} = twoEnvMicePVcorrs{2};
    
%% PV corr by day interval
dayPairsForward = nchoosek(1:9,2);
dayPairs = dayPairsForward;
numDayPairs = size(dayPairsForward,1);
condsUse = [1 3 4];
condPairs = [1 1; 3 3; 4 4];
numCondPairs = size(condPairs,1);

PopulationVectorCorrs4_2;

eastDays = [4 5 6];
acrossRule = sum((dayPairs==4 | dayPairs==5 | dayPairs==6),2)>0;
dayPairDiffs = diff(dayPairs,1,2);
% Aggregate the data; mean within arms; sort by day interval


oneEnvMicePVcorrs = []; oneEnvMicePVcorrsMeans = [];
twoEnvMicePVcorrs = []; twoEnvMicePVcorrsMeans = [];
oneEnvPVmeansAll = []; oneEnvPVsemAll = [];
twoEnvPVmeansAll = []; twoEnvPVsemAll = [];
oneEnvDGmeanAgg = cell(3,1); twoEnvDGmeanAgg = cell(3,1);
[oneEnvMicePVcorrs{1:3}] = deal(cell(8,3));
[oneEnvMicePVcorrsMeans{1:3}] = deal(cell(8,3));
[oneEnvPVcorrsDiff{1:3}] = deal(cell(8,3));
[oneEnvPVcorrsMeanDiff{1:3}] = deal(cell(8,3));
[twoEnvMicePVcorrs{1:3}] = deal(cell(8,3));
[twoEnvMicePVcorrsMeans{1:3}] = deal(cell(8,3));
[twoEnvPVcorrsDiff{1:3}] = deal(cell(8,3));
[twoEnvPVcorrsMeanDiff{1:3}] = deal(cell(8,3));

for cpI = 1:numCondPairs
    for dpgI = 1:2 %1 Turn1-Turn2, 2=x-Place
        dayGroupsHere = acrossRule==(dpgI-1);
        for ddI = 1:8 % Day diff interval
            dayDiffsHere = dayPairDiffs==ddI;
            dayPairsHere = find(dayDiffsHere & dayGroupsHere);
            for dpI = 1:length(dayPairsHere)
                dpJ = dayPairsHere(dpI);

                oneCorrs = pooledPVcorrs{dpJ,cpI}(oneEnvMice,:);
                nansH = sum(isnan(oneCorrs),2)==size(oneCorrs,2);
                oneCorrs(nansH,:) = [];
                oneEnvMicePVcorrs{dpgI}{ddI,cpI} = [oneEnvMicePVcorrs{dpgI}{ddI,cpI}; oneCorrs];
                oneEnvMicePVcorrsMeans{dpgI}{ddI,cpI} = [oneEnvMicePVcorrsMeans{dpgI}{ddI,cpI}; nanmean(oneCorrs,1)];

                oneEnvPVcorrsDiff{dpgI}{ddI,cpI} = [oneEnvPVcorrsDiff{dpgI}{ddI,cpI}; ddI*ones(size(oneCorrs))];
                oneEnvPVcorrsMeanDiff{dpgI}{ddI,cpI} = [oneEnvPVcorrsMeanDiff{dpgI}{ddI,cpI}; ddI*ones(size(nanmean(oneCorrs,1)))];

                twoCorrs = pooledPVcorrs{dpJ,cpI}(twoEnvMice,:);
                nansH = sum(isnan(twoCorrs),2)==size(twoCorrs,2);
                twoCorrs(nansH,:) = [];
                twoEnvMicePVcorrs{dpgI}{ddI,cpI} = [twoEnvMicePVcorrs{dpgI}{ddI,cpI}; twoCorrs];
                twoEnvMicePVcorrsMeans{dpgI}{ddI,cpI} = [twoEnvMicePVcorrsMeans{dpgI}{ddI,cpI}; nanmean(twoCorrs,1)];

                twoEnvPVcorrsDiff{dpgI}{ddI,cpI} = [twoEnvPVcorrsDiff{dpgI}{ddI,cpI}; ddI*ones(size(twoCorrs))];
                twoEnvPVcorrsMeanDiff{dpgI}{ddI,cpI} = [twoEnvPVcorrsMeanDiff{dpgI}{ddI,cpI}; ddI*ones(size(nanmean(twoCorrs,1)))];

                %sameMinusDiff{dpgI}{dpI,cpI} = oneEnvMicePVcorrsMeans{dpgI}{dpI,cpI} - twoEnvMicePVcorrsMeans{dpgI}{dpI,cpI};

                %sepMinusInt{dI,cpI} = twoEnvMicePVcorrsMeans{dpI,cpI} - oneEnvMicePVcorrsMeans{dpI,cpI};

                for binI = 1:numBins
                    %[pPVs{dpI,cpI}(binI),hPVs{dpI,cpI}(binI)] = ranksum(oneEnvMicePVcorrs{dpI,cpI}(:,binI),...
                    %twoEnvMicePVcorrs{dpI,cpI}(:,binI));
                end
        
                %diffRank{dpI,cpI} = PermutationTestSL(oneEnvMicePVcorrs{dpI,cpI},twoEnvMicePVcorrs{dpI,cpI},numPerms);
                %isSig{dpI,cpI} = diffRank{dpI,cpI} > (1-pThresh);
            end
            
            %{
            % Mean across dayPairs
            corrsHereOne = cell2mat([oneEnvMicePVcorrs{dpgI}(:,cpI)]); %{dayPairI,condI}(mouseI,binI)
            corrsHereTwo = cell2mat([twoEnvMicePVcorrs{dpgI}(:,cpI)]);
            
            oneEnvDGcorrsMean{dpgI}{cpI} = nanmean(corrsHereOne,1);
            twoEnvDGcorrsMean{dpgI}{cpI} = nanmean(corrsHereTwo,1);
            
            for binI = 1:nArmBins
                oneEnvDGcorrsSEM{dpgI}{cpI}(1,binI) = standarderrorSL(corrsHereOne(:,binI));
                twoEnvDGcorrsSEM{dpgI}{cpI}(1,binI) = standarderrorSL(corrsHereTwo(:,binI));
            end
            
            oneEnvDGmeanAgg{dpgI,cpI} = [oneEnvDGcorrsMean{dpgI}{cpI}(:)'];
            twoEnvDGmeanAgg{dpgI,cpI} = [twoEnvDGcorrsMean{dpgI}{cpI}(:)'];
            %}
        end
    end
end

dpgI = 3; % All
for cpI = 1:numCondPairs
    for ddI = 1:8 % Day diff interval
        dayDiffsHere = dayPairDiffs==ddI;
        dayPairsHere = find(dayDiffsHere);
        for dpI = 1:length(dayPairsHere)
            dpJ = dayPairsHere(dpI);
            
                oneCorrs = pooledPVcorrs{dpJ,cpI}(oneEnvMice,:);
                nansH = sum(isnan(oneCorrs),2)==size(oneCorrs,2);
                oneCorrs(nansH,:) = [];
                oneEnvMicePVcorrs{dpgI}{ddI,cpI} = [oneEnvMicePVcorrs{dpgI}{ddI,cpI}; oneCorrs];
                oneEnvMicePVcorrsMeans{dpgI}{ddI,cpI} = [oneEnvMicePVcorrsMeans{dpgI}{ddI,cpI}; nanmean(oneCorrs,1)];

                oneEnvPVcorrsDiff{dpgI}{ddI,cpI} = [oneEnvPVcorrsDiff{dpgI}{ddI,cpI}; ddI*ones(size(oneCorrs))];
                oneEnvPVcorrsMeanDiff{dpgI}{ddI,cpI} = [oneEnvPVcorrsMeanDiff{dpgI}{ddI,cpI}; ddI*ones(size(nanmean(oneCorrs,1)))];

                twoCorrs = pooledPVcorrs{dpJ,cpI}(twoEnvMice,:);
                nansH = sum(isnan(twoCorrs),2)==size(twoCorrs,2);
                twoCorrs(nansH,:) = [];
                twoEnvMicePVcorrs{dpgI}{ddI,cpI} = [twoEnvMicePVcorrs{dpgI}{ddI,cpI}; twoCorrs];
                twoEnvMicePVcorrsMeans{dpgI}{ddI,cpI} = [twoEnvMicePVcorrsMeans{dpgI}{ddI,cpI}; nanmean(twoCorrs,1)];

                twoEnvPVcorrsDiff{dpgI}{ddI,cpI} = [twoEnvPVcorrsDiff{dpgI}{ddI,cpI}; ddI*ones(size(twoCorrs))];
                twoEnvPVcorrsMeanDiff{dpgI}{ddI,cpI} = [twoEnvPVcorrsMeanDiff{dpgI}{ddI,cpI}; ddI*ones(size(nanmean(twoCorrs,1)))];
        end
    end
end

for dpgI = 1:3 %1 Turn1-Turn2, 2=x-Place
    for ddI = 1:8 % Day diff interval
        %for cpI = 1:numCondPairs
            oneEnvCorrs = [oneEnvMicePVcorrsMeans{dpgI}{ddI,:}];
            
            oneEnvMeans{dpgI}(ddI,1) = mean(oneEnvCorrs(:));
            oneEnvSEMs{dpgI}(ddI,1) = standarderrorSL(oneEnvCorrs(:));
            
            twoEnvCorrs = [twoEnvMicePVcorrsMeans{dpgI}{ddI,:}];
            
            twoEnvMeans{dpgI}(ddI,1) = mean(twoEnvCorrs(:));
            twoEnvSEMs{dpgI}(ddI,1) = standarderrorSL(twoEnvCorrs(:));
    end
end

figure;
subplot(2,1,1)
errorbar(oneEnvMeans{3},oneEnvSEMs{3},'Color',groupColors{1},'LineWidth',2,'LineStyle','-','DisplayName','One All')
hold on
errorbar(twoEnvMeans{3},twoEnvSEMs{3},'Color',groupColors{2},'LineWidth',2,'LineStyle','-','DisplayName','Two All')
legend('location','NE')
ylabel('Mean PV corr')
xlabel('Day Interval')
title('PV corr by Day Interval')
MakePlotPrettySL(gca);
xlim([0.8 8.2])
ylim([-0.2 0.5])

subplot(2,1,2)
errorbar(oneEnvMeans{1},oneEnvSEMs{1},'Color',groupColors{1},'LineWidth',2,'LineStyle',':','DisplayName','One Within')
hold on
errorbar(oneEnvMeans{2},oneEnvSEMs{2},'Color',groupColors{1},'LineWidth',2,'LineStyle','--','DisplayName','One Across')
%legend('Location','NE')
%title('One-Maze')
%ylabel('Mean PV corr')
%subplot(2,1,2)
errorbar(twoEnvMeans{1},twoEnvSEMs{1},'Color',groupColors{2},'LineWidth',2,'LineStyle',':','DisplayName','Two Within')
hold on
errorbar(twoEnvMeans{2},twoEnvSEMs{2},'Color',groupColors{2},'LineWidth',2,'LineStyle','--','DisplayName','Two Across')
legend('Location','NE')
%title('Two-Maze')
ylabel('Mean PV corr')
xlabel('Day Interval')
title('PV corr by Day Interval')
MakePlotPrettySL(gca);
xlim([0.8 8.2])

%% 3 way remapping (reinstatement)

aa = GetAllCombs(1:3,4:6);
bb = GetAllCombs(1:9,7:9);
allTriplePairs = [aa(bb(:,1),:) bb(:,2)];
oneTwoPairs = allTriplePairs(:,[1 2]);
oneThreePairs = allTriplePairs(:,[1 3]);

numDayTrips = size(allTriplePairs,1);

condsUse = [1 3 4];
numConds = numel(condsUse);
cellTMapH = cellfun(@(x) x(:,:,condsUse),cellTMap,'UniformOutput',false);

dayPairsForward = oneTwoPairs;
numDayPairs = size(dayPairsForward,1);
SingleCellRemapping4_2;

singleCellCorrsRhoAB = singleCellCorrsRho;
singleCellCorrsPab = singleCellCorrsP;
singleCellAllCorrsRhoAB = singleCellAllCorrsRho;
singleCellAllCorrsPab = singleCellAllCorrsP;

dayPairsForward = oneThreePairs;
numDayPairs = size(dayPairsForward,1);
SingleCellRemapping4_2;

singleCellCorrsRhoCD = singleCellCorrsRho;
singleCellCorrsPcd = singleCellCorrsP;
singleCellAllCorrsRhoCD = singleCellAllCorrsRho;
singleCellAllCorrsPcd = singleCellAllCorrsP;

% Lots of pre-allocating for aggregation
%{
oneEnvCOMchangeAB = cell(numDayTrips,1); oneEnvCOMchangeCD = cell(numDayTrips,1);
oneEnvCOMchangeComp = cell(numDayTrips,1); oneEnvCOMchangeCellsUse = cell(numDayTrips,1);
twoEnvCOMchangeAB = cell(numDayTrips,1); twoEnvCOMchangeCD = cell(numDayTrips,1);
twoEnvCOMchangeComp = cell(numDayTrips,1); twoEnvCOMchangeCellsUse = cell(numDayTrips,1);

oneEnvMeanRatePctChangeAB = cell(numDayTrips,1); oneEnvMeanRatePctChangeCD = cell(numDayTrips,1);
oneEnvRateChangeComp = cell(numDayTrips,1); oneEnvRateDiffCellsUse = cell(numDayTrips,1);
twoEnvMeanRatePctChangeAB = cell(numDayTrips,1); twoEnvMeanRatePctChangeCD = cell(numDayTrips,1);
twoEnvRateChangeComp = cell(numDayTrips,1); twoEnvRateDiffCellsUse = cell(numDayTrips,1);
oneEnvAbsMagEachPos = cell(numDayTrips,1); oneEnvAbsMagEachNeg = cell(numDayTrips,1);
twoEnvAbsMagEachPos = cell(numDayTrips,1); twoEnvAbsMagEachNeg = cell(numDayTrips,1);
%}
oneEnvRhosABAgg = cell(1,numDayTrips); oneEnvRhosCDAgg = cell(1,numDayTrips);
oneEnvRhoDiffsAgg = cell(1,numDayTrips); oneEnvRhosABAggAll = cell(1,numDayTrips);
oneEnvRhosCDAggAll = cell(1,numDayTrips); oneEnvRhoDiffsAggAll = cell(1,numDayTrips);
twoEnvRhosABAgg = cell(1,numDayTrips); twoEnvRhosCDAgg = cell(1,numDayTrips);
twoEnvRhoDiffsAgg = cell(1,numDayTrips); twoEnvRhosABAggAll = cell(1,numDayTrips);
twoEnvRhosCDAggAll = cell(1,numDayTrips); twoEnvRhoDiffsAggAll = cell(1,numDayTrips);
oneEnvPvalsABAgg = cell(1,numDayTrips); oneEnvPvalsCDAgg = cell(1,numDayTrips);
twoEnvPvalsABAgg = cell(1,numDayTrips); twoEnvPvalsCDAgg = cell(1,numDayTrips);
oneEnvPvalsABAggAll = cell(1,numDayTrips); oneEnvPvalsCDAggAll = cell(1,numDayTrips);
twoEnvPvalsABAggAll = cell(1,numDayTrips); twoEnvPvalsCDAggAll = cell(1,numDayTrips);
oneEnvMouseIDtracker = cell(1,numDayTrips); oneEnvCellTracker = cell(1,numDayTrips);
twoEnvMouseIDtracker = cell(1,numDayTrips); twoEnvCellTracker = cell(1,numDayTrips);
for mouseI = 1:numMice
    % Center of mass
    %{
    allFiringCOM{mouseI} = TMapFiringCOM(cellTMapH{mouseI});
    
    for dpI = 1:numDayTrips
        daysH = allTriplePairs(dpI,:);
        comsA = squeeze(allFiringCOM{mouseI}(:,oneTwoPairs(dpI,1),:));
        comsB = squeeze(allFiringCOM{mouseI}(:,oneTwoPairs(dpI,2),:));
        COMchangesAB{mouseI}{dpI} = abs(comsB - comsA);

        comsC = squeeze(allFiringCOM{mouseI}(:,oneThreePairs(dpI,1),:));
        comsD = squeeze(allFiringCOM{mouseI}(:,oneThreePairs(dpI,2),:));
        COMchangesCD{mouseI}{dpI} = abs(comsD - comsC);

        COMchangeMagnitudeComparison{mouseI}{dpI} = COMchangesCD{mouseI}{dpI} - COMchangesAB{mouseI}{dpI};
        % Negative value means greater magnitude COM change Turn 1 place than turn 1 - turn 2
        
        cellsUseHere = sum(sum(dayUse{mouseI}(:,daysH,condsUse),3)>0,2) > 0; 
        % One cond on One day out of each trip above threshold
        haveCell = sum(cellSSI{mouseI}(:,daysH)>0,2)==3;
        % Do we need active on arm all 3 days? Probably for this metric yes
        aa = trialReli{mouseI}(:,daysH,condsUse) > 0; % Cell active this arm this cond
        bb = sum(aa,2) == 3; % active this arm all days, (numCells x 1 x numConds)
        activeCondAcrossDays = squeeze(bb); % (numCells x numConds)
        
        %cellsUseHere = cellsUseHere & haveCell;
        
        cellsUseHere = cellsUseHere & haveCell & activeCondAcrossDays;
        
        % Aggregate data
        switch groupNum(mouseI)
            case 1
                oneEnvCOMchangeAB{dpI} = [oneEnvCOMchangeAB{dpI}; COMchangesAB{mouseI}{dpI}];
                oneEnvCOMchangeCD{dpI} = [oneEnvCOMchangeCD{dpI}; COMchangesCD{mouseI}{dpI}];
                oneEnvCOMchangeComp{dpI} = [oneEnvCOMchangeComp{dpI}; COMchangeMagnitudeComparison{mouseI}{dpI}];
                %oneEnvCOMchangeCellsUse{dpI} = logical([oneEnvCOMchangeCellsUse{dpI}; repmat(cellsUseHere,1,numConds)]);
                oneEnvCOMchangeCellsUse{dpI} = logical([oneEnvCOMchangeCellsUse{dpI}; cellsUseHere]);
            case 2
                twoEnvCOMchangeAB{dpI} = [twoEnvCOMchangeAB{dpI}; COMchangesAB{mouseI}{dpI}];
                twoEnvCOMchangeCD{dpI} = [twoEnvCOMchangeCD{dpI}; COMchangesCD{mouseI}{dpI}];
                twoEnvCOMchangeComp{dpI} = [twoEnvCOMchangeComp{dpI}; COMchangeMagnitudeComparison{mouseI}{dpI}];
                %twoEnvCOMchangeCellsUse{dpI} = logical([twoEnvCOMchangeCellsUse{dpI}; repmat(cellsUseHere,1,numConds)]);
                twoEnvCOMchangeCellsUse{dpI} = logical([twoEnvCOMchangeCellsUse{dpI}; cellsUseHere]);
        end
        
    end
    %}
    % Rate remapping
    %{
    meanRates{mouseI} = cell2mat(cellfun(@mean,cellTMapH{mouseI},'UniformOutput',false));
    for dpI = 1:numDayTrips
        mratesA = squeeze(meanRates{mouseI}(:,oneTwoPairs(dpI,1),:));
        mratesB = squeeze(meanRates{mouseI}(:,oneTwoPairs(dpI,2),:));
        mratesAll = [];
        mratesAll(:,:,1) = mratesA; 
        mratesAll(:,:,2) = mratesB;
        mfiredEither = sum(mratesAll,3)>0;
        mfiredBoth = sum(mratesAll>0,3)==2;
        meanRateDiffsAB{mouseI}{dpI} = max(mratesAll,[],3) - min(mratesAll,[],3);
        pctChangeMeanAB{mouseI}{dpI} = meanRateDiffsAB{mouseI}{dpI} ./ max(mratesAll,[],3);
        
        mratesC = squeeze(meanRates{mouseI}(:,oneThreePairs(dpI,1),:));
        mratesD = squeeze(meanRates{mouseI}(:,oneThreePairs(dpI,2),:));
        mratesAll = [];
        mratesAll(:,:,1) = mratesC; 
        mratesAll(:,:,2) = mratesD;
        mfiredEither = sum(mratesAll,3)>0;
        mfiredBoth = sum(mratesAll>0,3)==2;
        meanRateDiffsCD{mouseI}{dpI} = max(mratesAll,[],3) - min(mratesAll,[],3);
        pctChangeMeanCD{mouseI}{dpI} = meanRateDiffsCD{mouseI}{dpI} ./ max(mratesAll,[],3);
        
        rateDiffsMagnitudeComparison{mouseI}{dpI} = abs(pctChangeMeanCD{mouseI}{dpI}) - abs(pctChangeMeanAB{mouseI}{dpI});
        % Negative value means greater magnitude COM change Turn 1 place than turn 1 - turn 2
        
        % This might just be identical to above...
        cellsUseHere = sum(sum(dayUse{mouseI}(:,allTriplePairs(dpI,:),condsUse)>0,3),2) > 0;
        haveCell = sum(cellSSI{mouseI}(:,allTriplePairs(dpI,:))>0,2)==3;
        
        aa = trialReli{mouseI}(:,allTriplePairs(dpI,:),condsUse) > 0; % Cell active this arm this cond
        bb = sum(aa,2) == 3; % active this arm all days, (numCells x 1 x numConds)
        activeCondAcrossDays = squeeze(bb); % (numCells x numConds)
        
        cellsUseHere = cellsUseHere & haveCell & activeCondAcrossDays;
        
        % pct of cells across all three, is the difference in magnitude positive or negative
        absoluteMag{mouseI}{dpI} = rateDiffsMagnitudeComparison{mouseI}{dpI} ./ abs(rateDiffsMagnitudeComparison{mouseI}{dpI});
        absMag = absoluteMag{mouseI}{dpI}(cellsUseHere);
        pctPos = sum(absMag>0) / sum(sum(cellsUseHere));
        pctNeg = sum(absMag<0) / sum(sum(cellsUseHere));
        
        switch groupNum(mouseI)
            case 1
                %oneEnvMeanRateDiffsAB{dpI} = [oneEnvMeanRateDiffsAB{dpI}; meanRateDiffsAB{mouseI}{dpI}];%(cell, cond)
                oneEnvMeanRatePctChangeAB{dpI} = [oneEnvMeanRatePctChangeAB{dpI}; pctChangeMeanAB{mouseI}{dpI}];
                oneEnvMeanRatePctChangeCD{dpI} = [oneEnvMeanRatePctChangeCD{dpI}; pctChangeMeanCD{mouseI}{dpI}];
                oneEnvRateChangeComp{dpI} = [oneEnvRateChangeComp{dpI}; rateDiffsMagnitudeComparison{mouseI}{dpI}];
                oneEnvRateDiffCellsUse{dpI} = logical([oneEnvRateDiffCellsUse{dpI}; cellsUseHere]);
                
                %oneEnvAbsoluteMagnitude{dpI} = [oneEnvAbsoluteMagnitude{dpI}; absMag];
                oneEnvAbsMagEachPos{dpI} = [oneEnvAbsMagEachPos{dpI}; pctPos];
                oneEnvAbsMagEachNeg{dpI} = [oneEnvAbsMagEachNeg{dpI}; pctNeg];
            case 2
                %twoEnvMeanRateDiffsCD{dpI} = [twoEnvMeanRateDiffsCD{dpI}; meanRateDiffsCD{mouseI}{dpI}];
                twoEnvMeanRatePctChangeAB{dpI} = [twoEnvMeanRatePctChangeAB{dpI}; pctChangeMeanAB{mouseI}{dpI}];
                twoEnvMeanRatePctChangeCD{dpI} = [twoEnvMeanRatePctChangeCD{dpI}; pctChangeMeanCD{mouseI}{dpI}];
                twoEnvRateChangeComp{dpI} = [twoEnvRateChangeComp{dpI}; rateDiffsMagnitudeComparison{mouseI}{dpI}];
                twoEnvRateDiffCellsUse{dpI} = logical([twoEnvRateDiffCellsUse{dpI}; cellsUseHere]);
                
                twoEnvAbsMagEachPos{dpI} = [twoEnvAbsMagEachPos{dpI}; pctPos];
                twoEnvAbsMagEachNeg{dpI} = [twoEnvAbsMagEachNeg{dpI}; pctNeg];
        end
    end
    %}
    
    % Single neuron corrs:
    %{
    [singleCellCorrsRhoAB{mouseI}, singleCellCorrsPab{mouseI}] = singleNeuronCorrelations(cellTMapH{mouseI},oneTwoPairs,[]);
    [singleCellCorrsRhoCD{mouseI}, singleCellCorrsPcd{mouseI}] = singleNeuronCorrelations(cellTMapH{mouseI},oneThreePairs,[]);%turnBinsUse
    %{mouseI}{condI}{dayPairI}(cellI)
    pooledTmap = cell(numCells(mouseI),9);
    for cellI = 1:numCells(mouseI)
        for dayI = 1:9
            pooledTmap{cellI,dayI} = vertcat(cellTMapH{mouseI}{cellI,dayI,:});
        end
    end
    [singleCellAllCorrsRhoAB{mouseI}, singleCellAllCorrsPab{mouseI}] = singleNeuronCorrelations(pooledTmap,oneTwoPairs,[]);%turnBinsUse
    [singleCellAllCorrsRhoCD{mouseI}, singleCellAllCorrsPcd{mouseI}] = singleNeuronCorrelations(pooledTmap,oneThreePairs,[]);
    
    %}
    
    %}
    for dpI = 1:numDayTrips
        daysH = allTriplePairs(dpI,:);
        
        nCellsHere = sum(cellSSI{mouseI}(:,daysH)>0,1);
        if sum(nCellsHere>0)==3
        
        cellsUseHere = sum(sum(dayUse{mouseI}(:,daysH,condsUse)>0,3),2) > 0;
        haveCell = sum(cellSSI{mouseI}(:,daysH)>0,2)==3;
        
        
        
        aa = trialReli{mouseI}(:,daysH,condsUse) > 0; % Cell active this arm this cond
        bb = sum(aa,2) == 3; % active this arm all days, (numCells x 1 x numConds)
        activeCondAcrossDays = squeeze(bb); % (numCells x numConds)
        
        cellsUseHere = cellsUseHere & haveCell & activeCondAcrossDays; %(cellI, condI)
        
        singlePVcellsUse{mouseI}{dpI} = cellsUseHere;
        for condI = 1:numConds
            rhosAB = singleCellCorrsRhoAB{mouseI}{condI}{dpI}(cellsUseHere(:,condI));
            rhosCD = singleCellCorrsRhoCD{mouseI}{condI}{dpI}(cellsUseHere(:,condI));
            pValsAB = singleCellCorrsPab{mouseI}{condI}{dpI}(cellsUseHere(:,condI));
            pValsCD = singleCellCorrsPcd{mouseI}{condI}{dpI}(cellsUseHere(:,condI));
            rhoDiffs = rhosCD - rhosAB; % negative when higher rho in Turn1-Place than Turn1-Turn2
            
            switch groupNum(mouseI)
                case 1
                    oneEnvRhosABAgg{dpI} = [oneEnvRhosABAgg{dpI}; rhosAB];
                    oneEnvRhosCDAgg{dpI} = [oneEnvRhosCDAgg{dpI}; rhosCD];
                    oneEnvRhoDiffsAgg{dpI} = [oneEnvRhoDiffsAgg{dpI}; rhoDiffs];
                    
                    oneEnvPvalsABAgg{dpI} = [oneEnvPvalsABAgg{dpI}; pValsAB];
                    oneEnvPvalsCDAgg{dpI} = [oneEnvPvalsCDAgg{dpI}; pValsCD];
                    
                    oneEnvMouseIDtracker{dpI} = [oneEnvMouseIDtracker{dpI}; mouseI*ones(size(rhosAB))];
                    oneEnvCellTracker{dpI} = [oneEnvCellTracker{dpI}; find(cellsUseHere)];
                case 2
                    twoEnvRhosABAgg{dpI} = [twoEnvRhosABAgg{dpI}; rhosAB];
                    twoEnvRhosCDAgg{dpI} = [twoEnvRhosCDAgg{dpI}; rhosCD];
                    twoEnvRhoDiffsAgg{dpI} = [twoEnvRhoDiffsAgg{dpI}; rhoDiffs];
                    
                    twoEnvPvalsABAgg{dpI} = [twoEnvPvalsABAgg{dpI}; pValsAB];
                    twoEnvPvalsCDAgg{dpI} = [twoEnvPvalsCDAgg{dpI}; pValsCD];
                    
                    twoEnvMouseIDtracker{dpI} = [twoEnvMouseIDtracker{dpI}; mouseI*ones(size(rhosAB))];
                    twoEnvCellTracker{dpI} = [twoEnvCellTracker{dpI}; find(cellsUseHere)];
            end
        end
        
        % Whole maze
        rhosABall = singleCellAllCorrsRhoAB{mouseI}{1}{dpI}(sum(cellsUseHere,2)>0);
        rhosCDall = singleCellAllCorrsRhoCD{mouseI}{1}{dpI}(sum(cellsUseHere,2)>0);
        
        pValsABall = singleCellAllCorrsPab{mouseI}{1}{dpI}(sum(cellsUseHere,2)>0);
        pValsCDall = singleCellAllCorrsPcd{mouseI}{1}{dpI}(sum(cellsUseHere,2)>0);
        
        rhoDiffsAll = rhosCDall - rhosABall;
        switch groupNum(mouseI)
            case 1
                oneEnvRhosABAggAll{dpI} = [oneEnvRhosABAggAll{dpI}; rhosABall];
                oneEnvRhosCDAggAll{dpI} = [oneEnvRhosCDAggAll{dpI}; rhosCDall];
                oneEnvRhoDiffsAggAll{dpI} = [oneEnvRhoDiffsAggAll{dpI}; rhoDiffsAll];
                
                oneEnvPvalsABAggAll{dpI} = [oneEnvPvalsABAggAll{dpI}; pValsABall];
                oneEnvPvalsCDAggAll{dpI} = [oneEnvPvalsCDAggAll{dpI}; pValsCDall];
            case 2
                twoEnvRhosABAggAll{dpI} = [twoEnvRhosABAggAll{dpI}; rhosABall];
                twoEnvRhosCDAggAll{dpI} = [twoEnvRhosCDAggAll{dpI}; rhosCDall];
                twoEnvRhoDiffsAggAll{dpI} = [twoEnvRhoDiffsAggAll{dpI}; rhoDiffsAll];
                
                twoEnvPvalsABAggAll{dpI} = [twoEnvPvalsABAggAll{dpI}; pValsABall];
                twoEnvPvalsCDAggAll{dpI} = [twoEnvPvalsCDAggAll{dpI}; pValsCDall];
        end
        
        end
    end
    
    % Of cells there for T1-P, how many also T2?
    % Of cells there for T1-T2, how many also P?
    
    % Within arm reli change, each of these
    %{
    for dpI = 1:numDayTrips
        haveCell = sum(cellSSI{mouseI}(:,allTriplePairs(dpI,:))>0,2)==3;
        
        % above thresh at all
        aboveThreshAtAll = dayUse{mouseI}(haveCell,allTriplePairs(dpI,:));
        
        atAllThree = sum(aboveThreshAtAll,2)==3;
        
        TaTb = sum(aboveThreshAtAll(:,[1 3]),2)==2;
        TaP = sum(aboveThreshAtAll(:,[1 2]),2)==2;
        
        turnTurnDenom = sum(sum(TaTb));
        turnPlaceDenom = sum(sum(TaP));
        
        
        switch groupNum(mouseI)
            case 1
                oneEnvTurnTurnThresh{dpI} = [oneEnvTurnTurnThresh{dpI}; 
            case 2
        
    end
    %}
end

oneReallyAggAB = [];
oneReallyAggCD = [];
oneReallyAggDiffs = [];
twoReallyAggAB = [];
twoReallyAggCD = [];
twoReallyAggDiffs = [];
for dpI = 1:numDayTrips
    oneReallyAggAB = [oneReallyAggAB; oneEnvRhosABAggAll{dpI}];
oneReallyAggCD = [oneReallyAggCD; oneEnvRhosCDAggAll{dpI}];
oneReallyAggDiffs = [oneReallyAggDiffs; oneEnvRhoDiffsAggAll{dpI}];
twoReallyAggAB = [twoReallyAggAB; twoEnvRhosABAggAll{dpI}];
twoReallyAggCD = [twoReallyAggCD; twoEnvRhosCDAggAll{dpI}];
twoReallyAggDiffs = [twoReallyAggDiffs; twoEnvRhoDiffsAggAll{dpI}];

end
% Plotting: could either KS each day pair changeAB vs. change CD, or show
% changeComp is negative (greater change turn 1 to place than turn 1 to turn 2)

figure;
subplot(1,2,1);
yy = cdfplot(oneReallyAggAB);
yy.Color = groupColors{1};
yy.LineStyle = ':';
hold on
zz = cdfplot(oneReallyAggCD);
zz.Color = groupColors{1};
zz.LineStyle = '--';

[h,p] = kstest2(oneReallyAggAB,oneReallyAggCD)
[p] = ranksum(oneReallyAggAB,oneReallyAggCD)

disp('Done running reinstatement')
%% Turn1-Turn2 remapping
dayPairsForward = [3 7; 3 8; 7 8]; 
condsUse = 1:4;


% Single cells

cellTMapH = cellfun(@(x) x(:,:,condsUse),cellTMap,'UniformOutput',false);
numConds = numel(condsUse);
numDayPairs = size(dayPairsForward,1);

SingleCellRemapping4_2     
%save(fullfile(mainFolder,'singelCellCorrs.mat'),'singleCellCorrsRho','singleCellCorrsP','singleCellAllCorrsRho','singleCellAllCorrsP','dayPairsForward')

disp('Done single cell remapping')
% Population vector correlations
cellsUseOption = 'activeEither';
corrType = 'Spearman';
numPerms = 1000;

condPairs = [1 1; 2 2; 3 3; 4 4]; numCondPairs = size(condPairs,1);
condsUse = [1 2 3 4];
dayPairs = [3 7; 3 8; 7 8]; numDayPairs = size(dayPairs,1);
for condI = 1:4
    lgPlotHere{condI}.X = lgPlotBins.X(binOrderArms{condI},:);
    lgPlotHere{condI}.Y = lgPlotBins.Y(binOrderArms{condI},:);
end

traitLogical = dayUse;
pvCorrs = cell(numMice,1); 
meanCorr = cell(numMice,1); 
numCellsUsed = cell(numMice,1); 
numNan = cell(numMice,1); 

disp('Making corrs')
pooledPVcorrs = cell(numDayPairs,numCondPairs);
pooledMeanCorr = cell(numDayPairs,numCondPairs);
pooledNumCellsUsed = cell(numDayPairs,numCondPairs);
for mouseI = 1:numMice
    
    [pvCorrs, meanCorr, numCellsUsed, numNans] =...
        PVcorrsWrapperBasic(cellTMap{mouseI},condPairs,dayPairs,traitLogical{mouseI},cellsUseOption,corrType);
    
    %mousePVcorrs{mouseI} = pvCorrs;
    for cpI = 1:numCondPairs
        for dpI = 1:numDayPairs
            pooledPVcorrs{dpI,cpI} = [pooledPVcorrs{dpI,cpI}; pvCorrs{dpI,cpI}];
            pooledMeanCorr{dpI,cpI} = [pooledMeanCorr{dpI,cpI}; meanCorr{dpI,cpI}];
            pooledNumCellsUsed{dpI,cpI} = [pooledNumCellsUsed{dpI,cpI}; numCellsUsed{dpI,cpI}];
        end
    end
end

disp('testing diffs')
for cpI = 1:numCondPairs
    for dpI = 1:numDayPairs
        oneEnvMicePVcorrs{dpI,cpI} = pooledPVcorrs{dpI,cpI}(oneEnvMice,:);
        oneEnvMicePVcorrsMeans{dpI,cpI} = mean(oneEnvMicePVcorrs{dpI,cpI},1);
        
        twoEnvMicePVcorrs{dpI,cpI} = pooledPVcorrs{dpI,cpI}(twoEnvMice,:);
        twoEnvMicePVcorrsMeans{dpI,cpI} = mean(twoEnvMicePVcorrs{dpI,cpI},1);
        
        sameMinusDiff{dpI,cpI} = oneEnvMicePVcorrsMeans{dpI,cpI} - twoEnvMicePVcorrsMeans{dpI,cpI};
        
        %sepMinusInt{dI,cpI} = twoEnvMicePVcorrsMeans{dpI,cpI} - oneEnvMicePVcorrsMeans{dpI,cpI};
        
        for binI = 1:numBins
            %[pPVs{dpI,cpI}(binI),hPVs{dpI,cpI}(binI)] = ranksum(oneEnvMicePVcorrs{dpI,cpI}(:,binI),...
            %twoEnvMicePVcorrs{dpI,cpI}(:,binI));
        end
        
        diffRank{dpI,cpI} = PermutationTestSL(oneEnvMicePVcorrs{dpI,cpI},twoEnvMicePVcorrs{dpI,cpI},numPerms);
        isSig{dpI,cpI} = diffRank{dpI,cpI} > (1-pThresh);
    end
end

disp('done pv corrs basic')
disp('done 3-7, 3-8, 7-8 remapping')

%nArms with day use per cell
%change in within arm reli



%% Other 3-7, 3-8, 7-8 changes: Absolute change, etc.


% Cells that totally stop/start firing
for mouseI = 1:numMice
    for dpI = 1:numDayPairs
        firedOnMaze = trialReliAll{mouseI}(:,dayPairsForward(dpI,:)) > 0; % all conditions pooled
        firedOnMazeBothDays = sum(firedOnMaze,2)==2;

        firedOnMazeCondA = squeeze(trialReli{mouseI}(:,dayPairsForward(dpI,1),:)) > 0; % each condition
        firedOnMazeCondB = squeeze(trialReli{mouseI}(:,dayPairsForward(dpI,2),:)) > 0;
        
        firedOnMazeBothDaysCond = firedOnMazeCondA & firedOnMazeCondB; % did fire each condition both days
        numDaysFired = firedOnMazeCondA + firedOnMazeCondB;

        aboveThresh = dayUseAll{mouseI}(:,dayPairsForward(dpI,:)); % Across conds
        aboveThreshCondA = dayUse{mouseI}(:,dayPairsForward(dpI,1));
        aboveThreshCondB = dayUse{mouseI}(:,dayPairsForward(dpI,2));
        numDaysAboveThresh = aboveThreshCondA + aboveThreshCondB;
        
        haveCellBothDays = sum(cellSSI{mouseI}(:,dayPairsForward(dpI,:))>0,2) == 2;
        
        % Many different things we could measure:
        % Simple start/stopped activity at all (each cond)
        stoppedFiringAtAll = firedOnMazeCondA & (numDaysFired==1);
        startedFiringAtAll = firedOnMazeCondB & (numDaysFired==1);
        
        % Changed Thresholding (each cond)
        droppedBelowThresh = aboveThreshCondA & (numDaysAboveThresh==1);
        cameAboveThresh = aboveThreshCondB & (numDaysAboveThresh==1);
        
        % Possible denominators:
            % Have cell both days
            % (+) Fired on maze both days
            % (+) Fired on specific arm both days
        
        switch groupNum(mouseI)
            case 1
                
            case 2
                
        end
            
            
    end
end


% Absolute change above below thresh
oneEnvStoppedFiringAll = cell(numDayPairs,1); oneEnvStoppedFiringEach = cell(numDayPairs,numConds); 
oneEnvStartedFiringAll = cell(numDayPairs,1); oneEnvStartedFiringEach = cell(numDayPairs,numConds); 
twoEnvStoppedFiringAll = cell(numDayPairs,1); twoEnvStoppedFiringEach = cell(numDayPairs,numConds); 
twoEnvStartedFiringAll = cell(numDayPairs,1); twoEnvStartedFiringEach = cell(numDayPairs,numConds); 
oneEnvDiffArmsActive = cell(numDayPairs,1); oneEnvDiffArmsAboveThresh = cell(numDayPairs,1);
twoEnvDiffArmsActive = cell(numDayPairs,1); twoEnvDiffArmsAboveThresh = cell(numDayPairs,1);
% Change in Reliability     
oneEnvReliChangeAll = cell(numDayPairs,1); oneEnvReliChangeEach = cell(numDayPairs,numConds);
twoEnvReliChangeAll = cell(numDayPairs,1); twoEnvReliChangeEach = cell(numDayPairs,numConds);
for mouseI = 1:numMice
    for dpI = 1:numDayPairs
        haveCellsBothDays = sum(cellSSI{mouseI}(:,dayPairsForward(dpI,:))>0,2) == 2;
        
        trialReliA = squeeze(trialReli{mouseI}(:,dayPairsForward(dpI,1),:));
        trialReliB = squeeze(trialReli{mouseI}(:,dayPairsForward(dpI,2),:));
        
        trialReliDiff = trialReliB - trialReliA;
        
        firedOneDay = (trialReliA > 0) | (trialReliB > 0);
        
        for condI = 1:numConds
            %cellsH = haveCellsBothDays;
            cellsH = haveCellsBothDays & firedOneDay(:,condI);
            reliDiffH = trialReliDiff(haveCellsBothDays,condI);
            
            switch groupNum(mouseI)
                case 1
                    oneEnvReliChangeAll{dpI} = [oneEnvReliChangeAll{dpI}; reliDiffH];
                    oneEnvReliChangeEach{dpI,condI} = [oneEnvReliChangeEach{dpI,condI}; reliDiffH];
                case 2
                    twoEnvReliChangeAll{dpI} = [twoEnvReliChangeAll{dpI}; reliDiffH];
                    twoEnvReliChangeEach{dpI,condI} = [twoEnvReliChangeEach{dpI,condI}; reliDiffH];
            end
        end
        
        aboveThreshCondA = squeeze(dayUse{mouseI}(:,dayPairsForward(dpI,1),:));
        aboveThreshCondB = squeeze(dayUse{mouseI}(:,dayPairsForward(dpI,2),:));
        numDaysAboveThresh = aboveThreshCondA + aboveThreshCondB;
        
        droppedBelowThresh = aboveThreshCondA & (numDaysAboveThresh==1);
        cameAboveThresh = aboveThreshCondB & (numDaysAboveThresh==1);

        droppedAgg = [];
        cameupAgg = [];
        for condI = 1:numConds
            %cellsHA = haveCellsBothDays;
            %cellsHB = haveCellsBothDays;
            cellsHA = haveCellsBothDays & aboveThreshCondA(:,condI);
            cellsHB = haveCellsBothDays & aboveThreshCondB(:,condI);
            
            droppedHere = droppedBelowThresh(cellsHA,condI);
            cameupHere = cameAboveThresh(cellsHB,condI);
            
            droppedAgg = [droppedAgg; droppedHere];
            cameupAgg = [cameupAgg; cameupHere];
            switch groupNum(mouseI)
                case 1
                    oneEnvStoppedFiringEach{dpI,condI} = [oneEnvStoppedFiringEach{dpI,condI}; sum(droppedHere)/length(droppedHere)];
                    oneEnvStartedFiringEach{dpI,condI} = [oneEnvStartedFiringEach{dpI,condI}; sum(cameupHere)/length(cameupHere)];
                case 2
                    twoEnvStoppedFiringEach{dpI,condI} = [twoEnvStoppedFiringEach{dpI,condI}; sum(droppedHere)/length(droppedHere)];
                    twoEnvStartedFiringEach{dpI,condI} = [twoEnvStartedFiringEach{dpI,condI}; sum(cameupHere)/length(cameupHere)];
            end
            
        end
        
        switch groupNum(mouseI)
            case 1
                oneEnvStoppedFiringAll{dpI} = [oneEnvStoppedFiringAll{dpI}; sum(droppedAgg)/length(droppedAgg)];
                oneEnvStartedFiringAll{dpI} = [oneEnvStartedFiringAll{dpI}; sum(cameupAgg)/length(cameupAgg)];
            case 2
                twoEnvStoppedFiringAll{dpI} = [twoEnvStoppedFiringAll{dpI}; sum(droppedAgg)/length(droppedAgg)];
                twoEnvStartedFiringAll{dpI} = [twoEnvStartedFiringAll{dpI}; sum(cameupAgg)/length(cameupAgg)];    
        end
        
        % Number arms with any activity, above thresh activity
        %{
        aboveThreshCondA = squeeze(dayUse{mouseI}(:,dayPairsForward(dpI,1),:));
        aboveThreshCondB = squeeze(dayUse{mouseI}(:,dayPairsForward(dpI,2),:));
        trialReliA = squeeze(trialReli{mouseI}(:,dayPairsForward(dpI,1),:));
        trialReliB = squeeze(trialReli{mouseI}(:,dayPairsForward(dpI,2),:));
        %}
        
        cellActiveBothDays = (sum(trialReliAll{mouseI}(:,dayPairsForward(dpI,:))>0,2)==2);
        
        numAboveThreshCondA = sum(aboveThreshCondA,2);
        numAboveThreshCondB = sum(aboveThreshCondB,2);
        
        diffAboveThresh = numAboveThreshCondB - numAboveThreshCondA;
        
        numActiveCondA = sum(trialReliA>0,2);
        numActiveCondB = sum(trialReliB>0,2);
        
        diffNumActive = numActiveCondB - numActiveCondA;
        
        switch groupNum(mouseI)
            case 1
                oneEnvDiffArmsActive{dpI} = [oneEnvDiffArmsActive{dpI}; diffNumActive(cellActiveBothDays)]; 
                oneEnvDiffArmsAboveThresh{dpI} = [oneEnvDiffArmsAboveThresh{dpI}; diffAboveThresh(cellActiveBothDays)]; 
            case 2
                twoEnvDiffArmsActive{dpI} = [twoEnvDiffArmsActive{dpI}; diffNumActive(cellActiveBothDays)];
                twoEnvDiffArmsAboveThresh{dpI} = [twoEnvDiffArmsAboveThresh{dpI}; diffAboveThresh(cellActiveBothDays)]; 
        end
        
    end
end
        
            
        
regConfirmed = 1;
oneEnvStoppedFiring = cell(numDayPairs,1);
oneEnvStartedFiring = cell(numDayPairs,1);
twoEnvStoppedFiring = cell(numDayPairs,1);
twoEnvStartedFiring = cell(numDayPairs,1);
oneEnvStoppedFiringEach = cell(numDayPairs,1);
oneEnvStartedFiringEach = cell(numDayPairs,1);
twoEnvStoppedFiringEach = cell(numDayPairs,1);
twoEnvStartedFiringEach = cell(numDayPairs,1);
for mouseI = 1:numMice
    firedThisCond = trialReli{mouseI}>0;
    %firedThisCond = dayUse{mouseI}>0;
    
    for dpI = 1:numDayPairs
        firedA = squeeze(firedThisCond(:,dayPairsForward(dpI,1),:));
        firedB = squeeze(firedThisCond(:,dayPairsForward(dpI,2),:));
        
        firedAll = []; firedAll(:,:,1) = firedA; firedAll(:,:,2) = firedB;
        firedOne = sum(firedAll,3)==1;
        
        stoppedFiring = firedA & firedOne;
        startedFiring = firedB & firedOne;
        nCellsA = sum(firedA);
        nCellsB = sum(firedB);
        
        %Make sure both cells were there
        defHaveTheCells = cellSSI{mouseI}>0;
        haveCellsBothDays = sum(defHaveTheCells(:,dayPairsForward(dpI,:)),2)==2;
        dayPairMaxCells{mouseI}{dpI} = max(sum(defHaveTheCells(:,dayPairsForward(dpI,:)),1));
        goodReg(mouseI,dpI) = sum(haveCellsBothDays,1)/size(cellSSI{mouseI},1);
        if regConfirmed==1
            stoppedFiring(haveCellsBothDays==0) = 0;
            startedFiring(haveCellsBothDays==0) = 0;
            
            %stoppedFiringAll(mouseI,dpI) = sum(sum(stoppedFiring)) / (sum(haveCellsBothDays,1)*numConds);
            %startedFiringAll(mouseI,dpI) = sum(sum(startedFiring)) / (sum(haveCellsBothDays,1)*numConds);
            
            stoppedFiringAll(mouseI,dpI) = sum( sum(stoppedFiring)) ./ sum(sum(firedA) );
            startedFiringAll(mouseI,dpI) = sum( sum(startedFiring)) ./ sum(sum(firedB) );
            
            for condI = 1:numConds
                stoppedFiringAllEach{condI}(mouseI,dpI) = sum(stoppedFiring(:,condI)) / sum(haveCellsBothDays,1);
                startedFiringAllEach{condI}(mouseI,dpI) = sum(startedFiring(:,condI)) / sum(haveCellsBothDays,1);
            end
        end
            %could also do this for started or stopped in each mouse independently, add them up in the section vvvvv
        
        % This calculation might not be totally right, should be out of cells present...?
        %stoppedFiringAll(mouseI,dpI) = sum(sum(stoppedFiring))/(size(stoppedFiring,1)*numConds);
        %startedFiringAll(mouseI,dpI) = sum(sum(startedFiring))/(size(startedFiring,1)*numConds);
         
        %{
        stoppedFiringAll(mouseI,dpI) = sum(sum(stoppedFiring)) / (sum(haveCellsBothDays)*numConds); %sum(sum(firedA)
        startedFiringAll(mouseI,dpI) = sum(sum(startedFiring)) / (sum(haveCellsBothDays)*numConds); %sum(sum(firedB)
        
        %could be normalized by dayPairMaxCells or defHaveboth
        switch groupNum(mouseI)
            case 1
                oneEnvStoppedFiring{dpI} = [oneEnvStoppedFiring{dpI}; stoppedFiring];
                oneEnvStartedFiring{dpI} = [oneEnvStartedFiring{dpI}; startedFiring];
                
                oneEnvStoppedFiringEach{dpI} = [oneEnvStoppedFiringEach{dpI}; sum(stoppedFiring,1)./nCellsA];%size(stoppedFiring,1)
                oneEnvStartedFiringEach{dpI} = [oneEnvStartedFiringEach{dpI}; sum(startedFiring,1)./nCellsB];
            case 2
                twoEnvStoppedFiring{dpI} = [twoEnvStoppedFiring{dpI}; stoppedFiring];
                twoEnvStartedFiring{dpI} = [twoEnvStartedFiring{dpI}; startedFiring];
                
                twoEnvStoppedFiringEach{dpI} = [twoEnvStoppedFiringEach{dpI}; sum(stoppedFiring,1)./nCellsA]; %size(stoppedFiring,1)
                twoEnvStartedFiringEach{dpI} = [twoEnvStartedFiringEach{dpI}; sum(startedFiring,1)./nCellsB]; %size(startedFiring,1)
        end
        %}
    end
end
 
oneEnvStoppedFiringPct = cell2mat(cellfun(@(x) sum(sum(x))/(size(x,1)*numConds),oneEnvStoppedFiring,'UniformOutput',false));
oneEnvStartedFiringPct = cell2mat(cellfun(@(x) sum(sum(x))/(size(x,1)*numConds),oneEnvStartedFiring,'UniformOutput',false));
twoEnvStoppedFiringPct = cell2mat(cellfun(@(x) sum(sum(x))/(size(x,1)*numConds),twoEnvStoppedFiring,'UniformOutput',false));
twoEnvStartedFiringPct = cell2mat(cellfun(@(x) sum(sum(x))/(size(x,1)*numConds),twoEnvStartedFiring,'UniformOutput',false));


%%

dayPairsForward = [[1 2; 1 3; 2 3]; GetAllCombs(1:3,7:9);  [7 8; 7 9; 8 9]];
epochConds = [ones(3,1); zeros(9,1); ones(3,1)];
dayPairsForward = [[2 3]; GetAllCombs(2:3,8:9); [8 9]];
epochConds = [ones(1,1); zeros(4,1); 2*ones(1,1)];

dayPairsForward = [GetAllCombs(1:3,7:9);  [7 8; 7 9; 8 9]];
epochConds = [zeros(9,1); ones(3,1)];

condsUse = 1:4;

%%  Early/late similarity
% comparing this across days requires only using north or south to account
% for incorrect trials...
northBins = lgDataBins.labels=='n';
southBins = lgDataBins.labels=='s';
[singleTmap,RunOccMapS] = RateMapsDoublePlusV2_singleTrial(trialbytrialAll, lgBinVertices, 'vertices', 0, 'zeroOut', [], false);
singleTmap(:,:,1) = cellfun(@(x) x(northBins),singleTmap(:,:,1),'UniformOutput',false);       
singleTmap(:,:,2) = cellfun(@(x) x(southBins),singleTmap(:,:,2),'UniformOutput',false);       

condI = 1;
sessI = 4;
lapsH = find(trialbytrialAll(condI).sessID == sessI);
lapG = lapsH(1)-1;
%templateA = [singleTmap{:,lapG,condI}];
templateA = [TMap_unsmoothed{:,sessI-1,condI}];
templateA = templateA(northBins,:);
mTemplateA = mean(templateA,1);
lapI = lapsH(end)+1;
%templateB = [singleTmap{:,lapI,condI}];
templateB = [TMap_unsmoothed{:,sessI+1,condI}];
templateB = templateB(northBins,:);
mTemplateB = mean(templateB,1);

for lapJ = 1:length(lapsH)
    lapI = lapsH(lapJ);
    pvH = [singleTmap{:,lapI,condI}];
    cellsSharedA = sortedSessionInds(:,sessI)>0 & sortedSessionInds(:,sessI-1)>0;
    cellsSharedA = numTrials(:,sessI,condI)>1 & numTrials(:,sessI-1,condI)>1;
    
    pvA = templateA(cellsSharedA);
    pvHHa = mean(pvH(:,cellsSharedA),1);
    gg = [pvA(:) pvHHa(:)];
    
    eDistA(lapJ) = euclideanDistanceSL1(pvA,pvHHa,[]);
    
    cellsSharedB = numTrials(:,sessI,condI)>1 & numTrials(:,sessI+1,condI)>1;
    pvB = templateB(cellsSharedB);
    pvHHb = mean(pvH(:,cellsSharedB),1);
    hh = [pvB(:) pvHHb(:)];
    
    eDistB(lapJ) = euclideanDistanceSL1(pvB,pvHHb,[]);
    
end

    for binI = 1:sum(northBins)
        pvA = templateA(binI,cellsSharedA);
        
        pvHH = pvH(binI,cellsSharedA);
        % gg = [pvA(:) pvHH(:)];
        diffs = abs(pvA(:)-pvHH(:));
        diffsP = diffs.^(size(diffs,1));
        euclideanDistance = sum(diffsP)^(1/(size(diffs,1)));
    end  
%% Performance fit
cHere = double(trialbytrialAll(condI).isCorrect(lapsH));
cHere = [zeros(10,1); cHere];
cHereD = ones(size(cHere));
trialNum = [1:length(cHere)]';
[logitCoef,dev] = glmfit(trialNum,[cHere cHereD],'binomial','logit');
logitFit = glmval(logitCoef,trialNum,'logit');
figure; plot(trialNum,cHere,'bs', trialNum,logitFit,'r-');

%% Measuring Dimensionality
for mouseI = 1:numMice
[explained{mouseI},e{mouseI}] = PCAdimsTBT1(cellTBT{mouseI},cellSSI{mouseI});

sumExplained{mouseI} = cellfun(@cumsum,explained{mouseI},'UniformOutput',false);
top3{mouseI} = cell2mat(cellfun(@(x) x(3),sumExplained{mouseI},'UniformOutput',false));
top10{mouseI} = cell2mat(cellfun(@(x) x(10),sumExplained{mouseI},'UniformOutput',false));
mostExp{mouseI} = cellfun(@(x) find(x>95,1,'first'),sumExplained{mouseI},'UniformOutput',false);

lambdaNorms{mouseI} = cellfun(@sum,e{mouseI},'UniformOutput',false);
lambdaTildas{mouseI} = cellfun(@rdivide,e{mouseI},lambdaNorms{mouseI},'UniformOutput',false);
dimensionality{mouseI} = cellfun(@(x) 1/sum(x.^2),lambdaTildas{mouseI},'UniformOutput',false);
end
%{
missingData = [13 14];
e{1}(missingData) = [];
for ii = 1:length(explained{1}); if isempty(explained{1}{ii}); explained{1}{ii} = zeros(100,1); end; end
%}

disp('Need to align days to first turn on big maze')
figure;
for mouseI = 1:numMice
sns = unique(cellTBT{mouseI}(2).sessNumber);
tds = strcmpi(cellSessionSubtypes{mouseI},'Turn');
pds = strcmpi(cellSessionSubtypes{mouseI},'Place');
dd = cell2mat(dimensionality{mouseI});
plot(sns(pds),dd(pds),'b'); 
hold on
plot(sns(tds),dd(tds),'r');
end

%% Single neuron correlation by Cell-coactivity

%tmapPooled
turnDays = [1:3 7:9];
placeDays = [4:6];
condPairs = [1; 2]; numCondPairs = size(condPairs,1);

%dayPairs = [1 3; 2 3; 3 7; 3 8; 3 9];
dayPairs = [3 7; 3 8; 7 8];

threshHere = 0.1;
for mouseI = 1:numMice
    %[coactivity{mouseI},numTrialsActive{mouseI},pctTrialsActive{mouseI}] = findingEnsemblesNotes2(cellTBT{mouseI},condPairs);
    [coactivity{mouseI},totalCoactivity{mouseI},pctTrialsActive{mouseI},trialCoactiveAboveBaseline{mouseI},totalCoactiveAboveBaseline{mouseI},chanceCoactive{mouseI}] =...
        findingEnsemblesNotes3(cellTBT{mouseI},allMazeBound,condPairs);

[buTBT] = BreakUpTrialbyTrial(cellTBT{1},condBreak,binsBreak);
[coactivity2,totalCoactivity2,pctTrialsActive2,trialCoactiveAboveBaseline2,totalCoactiveAboveBaseline2,chanceCoactive2] =...
        findingEnsemblesNotes3(buTBT,allMazeBound,[1;2;3;4]);
    
    %[ensemBins{mouseI},ensemBinSizes{mouseI}] = cellfun(@(x) conncomp(graph(x)),totalCoactiveAboveBaseline{mouseI},'UniformOutput',false);
    %[~,V_temp,D_temp] = spectralcluster(X,5)
    
    %coactivity{mouseI}{dayI,condI}(cellI,cellJ)
    %{
    nCellsToday = sum(cellSSI{mouseI}>0,1);
    numCellsToday = mat2cell(repmat(nCellsToday(:),1,numCondPairs),ones(9,1),ones(1,numCondPairs));
    isCoactive = cellfun(@(x) x>0,coactivity{mouseI},'UniformOutput',false);
    
    numCoactivePartners{mouseI} = cellfun(@(x) sum(x,2),isCoactive,'UniformOutput',false);
    pctCoactivePartners{mouseI} = cellfun(@(x,y) x/(y*ones(numCells(mouseI),1)),numCoactivePartners{mouseI},numCellsToday,'UniformOutput',false);
    totalCoactive{mouseI} = cellfun(@(x) sum(x,2),coactivity{mouseI},'UniformOutput',false);
    meanCoactivity{mouseI} = cellfun(@(x,y) x./y,totalCoactive{mouseI},numCoactivePartners{mouseI},'UniformOutput',false);
    %}
    
    nCellsActiveToday{mouseI} = sum(trialReliAll{mouseI}>0,1);
    nCellsActiveTodayCond{mouseI} = squeeze(sum(trialReli{mouseI}>0,1))'; %(condI,dayI)
    
    numCoactivePartners{mouseI} = cellfun(@(x) sum(x,2),totalCoactiveAboveBaseline{mouseI},'UniformOutput',false);
    pctCoactivePartners{mouseI} = cellfun(@(x,y) x/y,numCoactivePartners{mouseI},num2cell(nCellsActiveTodayCond{mouseI}'),'UniformOutput',false);
    
    %{
     cellsHere = trialReli{mouseI}>threshHere;
    for dayI = 1:9
        if any(any(totalCoactiveAboveBaseline{mouseI}{dayI,1}))
        for condI = 1:2
            cellsHere = trialReli{mouseI}(:,dayI) > threshHere;
            
            tcb{dayI,condI} = totalCoactiveAboveBaseline{mouseI}{dayI,condI}(cellsHere,:);
            tcb{dayI,condI} = tcb{dayI,condI}(:,cellsHere);
            
            nCellsActiveTodayCond{dayI,condI} = sum(cellsHere);
            numCoactivePartners{dayI,condI} = sum(tcb{dayI,condI},2);
        end
        end
    end
    pctCoactivePartners{mouseI} = cellfun(@(x,y) x/y,numCoactivePartners,nCellsActiveTodayCond,'UniformOutput',false);
    %}

end
disp('Done getting coactivity')

% Change in coactivity

for mouseI = 1:numMice 
    for condI = 1:numConds
        for dpI = 1:size(dayPairs,1)
            cellsHere = cellSSI{mouseI}(:,dayPairs(dpI,1)) & cellSSI{mouseI}(:,dayPairs(dpI,2));
            reliUse = trialReli{mouseI}(:,dayPairs(dpI,1),condI)>threshHere & trialReli{mouseI}(:,dayPairs(dpI,2),condI)>threshHere;
            cellsHere = cellsHere & reliUse;

            cellsHere = find(cellsHere);
            
            coactA = totalCoactivity{mouseI}{dayPairs(dpI,1),condI};
            coactB = totalCoactivity{mouseI}{dayPairs(dpI,2),condI};
            
            coactA = coactA(cellsHere,:); coactA = coactA(:,cellsHere);
            coactB = coactB(cellsHere,:); coactB = coactB(:,cellsHere);
            
            coactChange = coactB - coactA;
            
            triInd = ones(size(coactChange));
            triInd = triu(triInd,1);
            cChange{mouseI}{condI}{dpI} = coactChange(logical(triInd));
        end
    end
end

for groupI = 1:2
    miceH = find(groupNum==groupI);
    cChangePooled{groupI} = cell(size(dayPairs,1),numConds);
    for dpI = 1:size(dayPairs,1)
        for mouseI = 1:length(miceH)
            for condI = 1:numConds
                cChangePooled{groupI}{dpI,condI} = [cChangePooled{groupI}{dpI,condI}; cChange{miceH(mouseI)}{condI}{dpI}];
            end
        end
    end
end

figure;
numDayPairs = size(dayPairs,1);
for dpI = 1:numDayPairs
    for condI = 1:numConds
        subplot(numConds,numDayPairs,dpI+numDayPairs*(condI-1))
        %[f,x] = ecdf(abs(cChangePooled{1}{dpI,condI}));
        [f,x] = ecdf(cChangePooled{1}{dpI,condI});
        plot(x,f,groupColors{1},'LineWidth',2); hold on
        %[f,x] = ecdf(abs(cChangePooled{2}{dpI,condI}));
        [f,x] = ecdf(cChangePooled{2}{dpI,condI});
        plot(x,f,groupColors{2},'LineWidth',2)
        
        %[h,p] = kstest2((abs(cChangePooled{1}{dpI,condI})),abs(cChangePooled{2}{dpI,condI}));
        [h,p] = kstest2(cChangePooled{1}{dpI,condI},cChangePooled{2}{dpI,condI});
        
        title(['Days ' num2str(dayPairs(dpI,:)) ', cond ' num2str(condI) ', p = ' num2str(p)]) 
        xlabel('Coactivity change')
    end
end
suptitleSL('Absolute coactivity change')
       

            
%adjustTmaps
for mouseI = 1:numMice
    tmapHere{mouseI}(:,[1:3 7:9],1) = cellfun(@(x) x(binOrderIndex{1}),cellTMap{mouseI}(:,[1:3 7:9],1),'UniformOutput',false);
    tmapHere{mouseI}(:,[1:3 7:9],2) = cellfun(@(x) x(binOrderIndex{3}),cellTMap{mouseI}(:,[1:3 7:9],2),'UniformOutput',false);
    tmapHere{mouseI}(:,[4:6],1) = cellfun(@(x) x(binOrderIndex{2}),cellTMap{mouseI}(:,[4:6],1),'UniformOutput',false);
    tmapHere{mouseI}(:,[4:6],2) = cellfun(@(x) x(binOrderIndex{4}),cellTMap{mouseI}(:,[4:6],2),'UniformOutput',false);
end

% Ratemap corrs
singleCellCorrsRho = []; singleCellCorrsP = [];
for mouseI = 1:numMice
    [singleCellCorrsRho{mouseI}, singleCellCorrsP{mouseI}] = singleNeuronCorrelations(tmapHere{mouseI},dayPairs,[]);%turnBinsUse
    %{mouseI}{condI}{dayPairI}(cellI)
    %[allSingleCellCorrsRho{mouseI}, allSingleCellCorrsP{mouseI}] = singleNeuronCorrelations(allTMap{mouseI},dayPairs,[]);
end
disp('Done single-cell corrs across days')

% Cells with higher corr 3-8 vs. 3-7
rPooled = cell(numConds,2);
for mouseI = 1:numMice
    for condI = 1:numConds
        allDays = sum(cellSSI{mouseI}(:,[3 7 8]) > 0,2)==3;
        reliUse = sum(trialReli{mouseI}(:,[3 7 8],condI) > threshHere,2)==3;
        
        cellsHere = allDays;

        reinstate = singleCellCorrsRho{mouseI}{condI}{1}(cellsHere) < singleCellCorrsRho{mouseI}{condI}{2}(cellsHere);
        rPooled{condI,groupNum(mouseI)} = [rPooled{condI,groupNum(mouseI)}; sum(reinstate)/sum(cellsHere)];
    end
end

% Mean Correlation from day [1 2, 2 3] (1 3) related for [3 7, 3 8] (7 8)?
daySetsTest{1} = {[1 2 3],[7 8]};

numDaySetsTest = length(daySetsTest);
stabilityAgg = cell(numDaySetsTest,numConds); [stabilityAgg{:}] = deal(cell(1,2));
for dstI = 1:numDaySetsTest
daysTestH = daySetsTest{dstI};
for mouseI = 1:numMice
    for condI = 1:numConds
        cellsHere = [];
        
        stabilityA = []; %zeros(numCellsHere,1);
        for ii = 1:numel(daysTestH{1})    
            stabilityA = [stabilityA, singleCellCorrsRho{mouseI}{condI}{daysTestH(1)}(ii)];
        end
        % stabilityA(:,1) = [];
        meanStabilityA = mean(stabilityA(cellsHere,:),2);

        stabilityB = []; %zeros(numCellsHere,1);
        for ii = 1:numel(daysTestH{2})    
            stabilityB = [stabilityB, singleCellCorrsRho{mouseI}{condI}{daysTestH(2)}(ii)];
        end
        % stabilityA(:,1) = [];
        meanStabilityB = mean(stabilityB(cellsHere,:),2);


        stabilityAgg{dstI,condI}{groupNum(mouseI)} = [stabilityAgg{dstI,condI}{groupNum(mouseI)}; meanStabilityA meanSabilityB];
    end
end
end

% Pool corrs by group
threshHere = 0.1;
corrsPooled = cell(2,1); meanCorrPooled = []; semCorrPooled = [];
meanCorrs = []; semCorrs = [];
for groupI = 1:2
    for dpI = 1:size(dayPairs,1)
        corrsPooled{groupI}{dpI} = [];
        for condI = 1:numCondPairs
            miceH = find(groupNum==groupI);
            for mouseI = 1:length(miceH)
                cellsHere = cellSSI{miceH(mouseI)}(:,dayPairs(dpI,1)) & cellSSI{miceH(mouseI)}(:,dayPairs(dpI,2));
                reliUse = trialReli{miceH(mouseI)}(:,dayPairs(dpI,1),condI)>threshHere & trialReli{miceH(mouseI)}(:,dayPairs(dpI,2),condI)>threshHere;
                cellsHere = cellsHere & reliUse;
                corrsHere = singleCellCorrsRho{miceH(mouseI)}{condI}{dpI}(cellsHere);
                %corrsHere = allSingleCellCorrsRho{miceH(mouseI)}{condI}{dpI}(cellsHere);
                meanCorrs{groupI,mouseI}(condI,dpI) = nanmean(corrsHere); % Some nans in corrs due to lots of zeros?
                semCorrs{groupI,mouseI}(condI,dpI) = standarderrorSL(corrsHere);
                corrsPooled{groupI}{dpI} = [corrsPooled{groupI}{dpI}; corrsHere];
            end
        end
        meanCorrPooled(groupI,dpI) = mean(corrsPooled{groupI}{dpI});
        semCorrPooled(groupI,dpI) = standarderrorSL(corrsPooled{groupI}{dpI});
    end
end

for dpI = 1:size(dayPairs,1)
    [p(dpI),h(dpI)] = ranksum(corrsPooled{1}{dpI},corrsPooled{2}{dpI});
end
meanCorrPooled = [meanCorrPooled(:,1:2), [1;1], meanCorrPooled(:,3:end)];
semCorrPooled = [semCorrPooled(:,1:2), [0;0], semCorrPooled(:,3:end)];

figure;
for condI = 1:numCondPairs
    if numCondPairs > 1
        subplot(numCondPairs,1,condI)
    end
    for groupI = 1:2
        for mouseI = 1:3
            %errorbar(meanCorrs{groupI,mouseI}(condI,:),semCorrs{groupI,mouseI}(condI,:),'Color',groupColors{groupI})
            plot(meanCorrs{groupI,mouseI}(condI,:),'Color',groupColors{groupI})
            hold on
        end
    end
end

figure; 
errorbar(meanCorrPooled(1,:),semCorrPooled(1,:),'Color',groupColors{1}); hold on
errorbar(meanCorrPooled(2,:),semCorrPooled(2,:),'Color',groupColors{2});


% Scatter of ratemap correlations against coactivity, num coactive partners, etc. on 1st day in pair
%threshHere = 0.25;
nReliBins = 3;
%reliBins = linspace(threshHere,1.0001,nReliBins+1);
xAgg = cell(size(dayPairs,1),1);
yAgg = cell(size(dayPairs,1),1);
xAggBlock = cell(size(dayPairs,1),1); [xAggBlock{:}] = deal(cell(nReliBins,1));
yAggBlock = cell(size(dayPairs,1),1); [yAggBlock{:}] = deal(cell(nReliBins,1));
condColors = ['r';'g'];
for dpI = 1:size(dayPairs,1)
    figure('Position',[328.5000 130 1028 627.5000]);
    for mouseI = 1:numMice
        subplot(2,3,mouseI)
        %title([mice{mouseI} ' ' groups{mouseI}])
        
        for condI = 1:numCondPairs
            cellsHere = cellSSI{mouseI}(:,dayPairs(dpI,1)) & cellSSI{mouseI}(:,dayPairs(dpI,2));
            reliUse = trialReli{mouseI}(:,dayPairs(dpI,1),condI)>threshHere & trialReli{mouseI}(:,dayPairs(dpI,2),condI)>threshHere;
            %reliUse = trialReliAll{mouseI}(:,dayPairs(dpI,1),condI)>threshHere & trialReliAll{mouseI}(:,dayPairs(dpI,2),condI)>threshHere;
            %coactHere = pctCoactivePartners{mouseI}{min(dayPairs(dpI,:)),condI} < 0.95;
            cellsHere = cellsHere & reliUse; % & coactHere;
            xPlot = pctCoactivePartners{mouseI}{min(dayPairs(dpI,:)),condI}(cellsHere); %needs to be restricted by cells carried over?
            yPlot = singleCellCorrsRho{mouseI}{condI}{dpI}(cellsHere);
            %yPlot = allSingleCellCorrsRho{mouseI}{condI}{dpI}(cellsHere);
            
            tcb = totalCoactiveAboveBaseline{mouseI}{dayPairs(dpI,1),condI}(cellsHere,:); % number of cells coactive with
            %tcb = coactivity{mouseI}{dayPairs(dpI,1),condI}(cellsHere,:); % coactivity scores
            tcb = tcb(:,cellsHere);
            nCoactivePartners = sum(tcb,2);
            pctCoactPartners = nCoactivePartners/sum(cellsHere);
            xPlot = pctCoactPartners;
            
            
            plot(xPlot,yPlot,'.','MarkerFaceColor',condColors(condI))
            hold on
            
            xAgg{dpI} = [xAgg{dpI}; xPlot];
            yAgg{dpI} = [yAgg{dpI}; yPlot];
            
            reliHere = trialReli{mouseI}(cellsHere,dayPairs(dpI,1),condI); % Should this pool across mice?
            [reliSorted,ia] = sort(reliHere,'ascend');
            reliBins = round(linspace(1,length(reliHere),nReliBins+1));
            cellsHereInds = find(cellsHere);
            for rgI = 1:length(reliBins)-1
                theseRH = reliBins(rgI):reliBins(rgI+1)-1;
                reliHinds = ia(theseRH);
                xPlotBlock = xPlot(reliHinds);
                yPlotBlock = yPlot(reliHinds);
                
                xAggBlock{dpI}{rgI} = [xAggBlock{dpI}{rgI}; xPlotBlock(:)];
                yAggBlock{dpI}{rgI} = [yAggBlock{dpI}{rgI}; yPlotBlock(:)];
            end
        end
        ylabel('PF corr')
        xlabel('Pct coactive / active')
    end
    suptitleSL(['Rate maps by coactivity day pair ' num2str(dayPairs(dpI,:))])
end

figure('Position', [137.5000 154 1.3285e+03 627.5000]);
for dpI = 1:size(dayPairs,1)
    subplot(1,size(dayPairs,1),dpI)
    plot(xAgg{dpI},yAgg{dpI},'.')
    [rho,p] = corr(xAgg{dpI},yAgg{dpI},'type','Spearman');
    title({['day pair ' num2str(dayPairs(dpI,:))];['rho ' num2str(rho) ' p: ' num2str(p)]})
    [fitVal,daysPlot] = FitLineForPlotting(yAgg{dpI},xAgg{dpI});
    hold on
    plot(daysPlot,fitVal,'r')
    ylabel('PF corr')
    xlabel('Pct coactive / active')
    
end
suptitleSL(['Single-Neuron Rate map correlation overdays by pct coactive partners'])

% Same but reliability groups
for rgI = 1:nReliBins
figure('Position', [137.5000 154 1.3285e+03 627.5000]);
for dpI = 1:size(dayPairs,1)
    subplot(1,size(dayPairs,1),dpI)
    plot(xAggBlock{dpI}{rgI},yAggBlock{dpI}{rgI},'.')
    [rho,p] = corr(xAggBlock{dpI}{rgI},yAggBlock{dpI}{rgI},'type','Spearman');
    title({['day pair ' num2str(dayPairs(dpI,:))];['rho ' num2str(rho) ' p: ' num2str(p)]})
    [fitVal,daysPlot] = FitLineForPlotting(yAggBlock{dpI}{rgI},xAggBlock{dpI}{rgI});
    hold on
    plot(daysPlot,fitVal,'r')
    ylabel('PF corr')
    xlabel('Pct coactive / active')
    
end
suptitleSL(['Single-Neuron Rate map correlation overdays by pct coactive partners, trialReli ' num2str(rgI) ' / ' num2str(nReliBins)])
end
% Remapping on x-axis, change in coactivity with partner cells on y
%           (% coactive partners, mean coactivity rate)





% PLots if same, but aggregated by group assign...            
            
            
            
        


tbtfields =  {'trialsX',...
    'trialsY',...
    'trialPSAbool',...
    'trialRawTrace',...
    'trialDFDTtrace',...
    'sessID',...
    'sessNumber',...
    'lapNumber',...
    'isCorrect',...
    'allowedFix',...
    'startArm',...
    'endArm',...
    'lapSequence',...
    'rule'};

condBreak = [1;1;2;2];
binsB = {'n' 'w' 's' 'e'};
binsB = {'north' 'west' 'south' 'east'};
for binsI = 1:4
    %binsBH = lgDataBins.labels == binsB{binsI};
    %binsBreak.X{binsI} = lgDataBins.X(binsBH,:);
    %binsBreak.Y{binsI} = lgDataBins.X(binsBH,:);
    binsBreak.X{binsI} =lgDataBins.bounds.(binsB{binsI}).X;
    binsBreak.Y{binsI} =lgDataBins.bounds.(binsB{binsI}).Y;
end
[buTBT] = BreakUpTrialbyTrial(cellTBT{1},condBreak,binsBreak); % Would need to do again and smush together for place days...

%% Single-neuron place field changes
pctRemap = cell(numDayPairs,numConds); [pctRemap{:}] = deal(cell(1,2));
for mouseI = 1:numMice
    tmapHere{mouseI}(:,[1:3 7:9],1) = cellfun(@(x) x(binOrderIndex{1}),cellTMap{mouseI}(:,[1:3 7:9],1),'UniformOutput',false);
    tmapHere{mouseI}(:,[1:3 7:9],2) = cellfun(@(x) x(binOrderIndex{3}),cellTMap{mouseI}(:,[1:3 7:9],2),'UniformOutput',false);
    tmapHere{mouseI}(:,[4:6],1) = cellfun(@(x) x(binOrderIndex{2}),cellTMap{mouseI}(:,[4:6],1),'UniformOutput',false);
    tmapHere{mouseI}(:,[4:6],2) = cellfun(@(x) x(binOrderIndex{4}),cellTMap{mouseI}(:,[4:6],2),'UniformOutput',false);
    
    allTMap{mouseI} = cellfun(@(y,z) [y(:); z(:)],tmapHere{mouseI}(:,:,1),tmapHere{mouseI}(:,:,2),'UniformOutput',false);

    TMapMeans{mouseI} = cellfun(@mean, allTMap{mouseI});
    TMapStds{mouseI} = cellfun(@std, allTMap{mouseI});
    sdM = 1.645; % 1 tailed t test
    TMapThresh{mouseI} = arrayfun(@(x,y) x+y*sdM,TMapMeans{mouseI},TMapStds{mouseI});
    %TMapThresh{mouseI} = arrayfun(@(x,y,z) x+y*sdM,TMapMeans{mouseI},TMapStds{mouseI},num2cell(trialReli{mouseI},);
        
    %[TmapAboveThresh{mouseI}(:,:,1)] = cellfun(@(x,y) x>y,tmapHere{mouseI}(:,:,1),num2cell(TMapThresh{mouseI}),'UniformOutput',false);
    %[TmapAboveThresh{mouseI}(:,:,2)] = cellfun(@(x,y) x>y,tmapHere{mouseI}(:,:,2),num2cell(TMapThresh{mouseI}),'UniformOutput',false);
    [TmapAboveThresh{mouseI}(:,:,1)] = cellfun(@(x,y,z) logical((x>y).*z),tmapHere{mouseI}(:,:,1),num2cell(TMapThresh{mouseI}),num2cell(trialReli{mouseI}(:,:,1)>0),'UniformOutput',false);
    [TmapAboveThresh{mouseI}(:,:,2)] = cellfun(@(x,y,z) logical((x>y).*z),tmapHere{mouseI}(:,:,2),num2cell(TMapThresh{mouseI}),num2cell(trialReli{mouseI}(:,:,2)>0),'UniformOutput',false);
    
% Has to be >, >= lets 0 be above mean

    [outputs] = PlaceFieldRemapping(tmapHere{mouseI},TmapAboveThresh{mouseI},dayPairs);
    
    % Get mutually exclusive split, shift merge categories
    overallShift = cellfun(@(x) sum(x)>0,outputs(1).fieldShifts);
    overallSplit = cellfun(@(x) sum(x)>0,outputs(1).fieldSplits);
    overallMerge = cellfun(@(x) sum(x)>0,outputs(1).fieldMerges);
    onlyShifts{mouseI} = overallShift & ((overallSplit | overallMerge)==0);
    onlySplits{mouseI} = overallSplit & ((overallShift | overallMerge)==0);
    onlyMerges{mouseI} = overallMerge & ((overallSplit | overallShift)==0);
    
    allCellsAboveThresh = cellfun(@any, TmapAboveThresh{mouseI});
    for dpI = 1:numDayPairs
        for condI = 1:numConds
            cellsSig = sum(allCellsAboveThresh(:,dayPairs(dpI,:),condI),2)==2;
            
            labeledRemappers = [onlyShifts{mouseI}(:,dpI,condI), onlySplits{mouseI}(:,dpI,condI), onlyMerges{mouseI}(:,dpI,condI)]; 
            
            numRemappers = sum(labeledRemappers(cellsSig,:),1);
            totalCellsSig = sum(cellsSig);
            numRemappers = [numRemappers totalCellsSig-sum(numRemappers)];
            pctRemapping = numRemappers / totalCellsSig;

            groupI = groupNum(mouseI);
            pctRemap{dpI,condI}{groupI} = [pctRemap{dpI,condI}{groupI}; pctRemapping];
        end
    end
    %pct distribution in each category
end

% Plot some examples
%Shifter:
mouseI = 1; cellI = 2; dpI = 1;
PlotDotplotDoublePlus2(cellTBT{mouseI},cellI,[1;2],dayPairs(dpI,1),'dynamic',[],2.5)
title(['Shift only: mouse ' num2str(mouseI) ', cell ' num2str(cellI) ', day ' num2str(dayPairs(dpI,1))])
PlotDotplotDoublePlus2(cellTBT{mouseI},cellI,[1;2],dayPairs(dpI,2),'dynamic',[],2.5)
title(['Shift only: mouse ' num2str(mouseI) ', cell ' num2str(cellI) ', day ' num2str(dayPairs(dpI,2))])


binsH = TmapAboveThresh{mouseI}{cellI,dayPairs(dpI,1),1};
binsAT.X{1} = binsOrdered.X{1}(binsH,:); binsAT.Y{1} = binsOrdered.Y{1}(binsH,:);
binsH = TmapAboveThresh{mouseI}{cellI,dayPairs(dpI,1),2};
binsAT.X{2} = binsOrdered.X{3}(binsH,:); binsAT.Y{2} = binsOrdered.Y{3}(binsH,:);
PlotDotplotDoublePlus2(cellTBT{mouseI},cellI,[1;2],dayPairs(dpI,1),'aboveThresh',binsAT,[])
title(['Shift only: mouse ' num2str(mouseI) ', cell ' num2str(cellI) ', day ' num2str(dayPairs(dpI,1))])
binsH = TmapAboveThresh{mouseI}{cellI,dayPairs(dpI,2),1};
binsAT.X{1} = binsOrdered.X{1}(binsH,:); binsAT.Y{1} = binsOrdered.Y{1}(binsH,:);
binsH = TmapAboveThresh{mouseI}{cellI,dayPairs(dpI,2),2};
binsAT.X{2} = binsOrdered.X{3}(binsH,:); binsAT.Y{2} = binsOrdered.Y{3}(binsH,:);
PlotDotplotDoublePlus2(cellTBT{mouseI},cellI,[1;2],dayPairs(dpI,2),'aboveThresh',binsAT,[])
title(['Shift only: mouse ' num2str(mouseI) ', cell ' num2str(cellI) ', day ' num2str(dayPairs(dpI,2))])

% Field-Split
mouseI = 1; cellI = 144; dpI = 1;
PlotDotplotDoublePlus2(cellTBT{mouseI},cellI,[1;2],dayPairs(dpI,1),'dynamic',[],3.5)
title(['Split only: mouse ' num2str(mouseI) ', cell ' num2str(cellI) ', day ' num2str(dayPairs(dpI,1))])
PlotDotplotDoublePlus2(cellTBT{mouseI},cellI,[1;2],dayPairs(dpI,2),'dynamic',[],3.5)
title(['Split only: mouse ' num2str(mouseI) ', cell ' num2str(cellI) ', day ' num2str(dayPairs(dpI,2))])

binsH = TmapAboveThresh{mouseI}{cellI,dayPairs(dpI,1),1};
binsAT.X{1} = binsOrdered.X{1}(binsH,:); binsAT.Y{1} = binsOrdered.Y{1}(binsH,:);
binsH = TmapAboveThresh{mouseI}{cellI,dayPairs(dpI,1),2};
binsAT.X{2} = binsOrdered.X{3}(binsH,:); binsAT.Y{2} = binsOrdered.Y{3}(binsH,:);
PlotDotplotDoublePlus2(cellTBT{mouseI},cellI,[1;2],dayPairs(dpI,1),'aboveThresh',binsAT,[])
title(['Split only: mouse ' num2str(mouseI) ', cell ' num2str(cellI) ', day ' num2str(dayPairs(dpI,1))])
binsH = TmapAboveThresh{mouseI}{cellI,dayPairs(dpI,2),1};
binsAT.X{1} = binsOrdered.X{1}(binsH,:); binsAT.Y{1} = binsOrdered.Y{1}(binsH,:);
binsH = TmapAboveThresh{mouseI}{cellI,dayPairs(dpI,2),2};
binsAT.X{2} = binsOrdered.X{3}(binsH,:); binsAT.Y{2} = binsOrdered.Y{3}(binsH,:);
PlotDotplotDoublePlus2(cellTBT{mouseI},cellI,[1;2],dayPairs(dpI,2),'aboveThresh',binsAT,[])
title(['Split only: mouse ' num2str(mouseI) ', cell ' num2str(cellI) ', day ' num2str(dayPairs(dpI,2))])

% Field merge
mouseI = 1; cellI = 107; dpI = 1;
PlotDotplotDoublePlus2(cellTBT{mouseI},cellI,[1;2],dayPairs(dpI,1),'dynamic',[],2.5)
title(['Merge only: mouse ' num2str(mouseI) ', cell ' num2str(cellI) ', day ' num2str(dayPairs(dpI,1))])
PlotDotplotDoublePlus2(cellTBT{mouseI},cellI,[1;2],dayPairs(dpI,2),'dynamic',[],2.5)
title(['Merge only: mouse ' num2str(mouseI) ', cell ' num2str(cellI) ', day ' num2str(dayPairs(dpI,2))])

binsH = TmapAboveThresh{mouseI}{cellI,dayPairs(dpI,1),1};
binsAT.X{1} = binsOrdered.X{1}(binsH,:); binsAT.Y{1} = binsOrdered.Y{1}(binsH,:);
binsH = TmapAboveThresh{mouseI}{cellI,dayPairs(dpI,1),2};
binsAT.X{2} = binsOrdered.X{3}(binsH,:); binsAT.Y{2} = binsOrdered.Y{3}(binsH,:);
PlotDotplotDoublePlus2(cellTBT{mouseI},cellI,[1;2],dayPairs(dpI,1),'aboveThresh',binsAT,[])
title(['Merge only: mouse ' num2str(mouseI) ', cell ' num2str(cellI) ', day ' num2str(dayPairs(dpI,1))])
binsH = TmapAboveThresh{mouseI}{cellI,dayPairs(dpI,2),1};
binsAT.X{1} = binsOrdered.X{1}(binsH,:); binsAT.Y{1} = binsOrdered.Y{1}(binsH,:);
binsH = TmapAboveThresh{mouseI}{cellI,dayPairs(dpI,2),2};
binsAT.X{2} = binsOrdered.X{3}(binsH,:); binsAT.Y{2} = binsOrdered.Y{3}(binsH,:);
PlotDotplotDoublePlus2(cellTBT{mouseI},cellI,[1;2],dayPairs(dpI,2),'aboveThresh',binsAT,[])
title(['Merge only: mouse ' num2str(mouseI) ', cell ' num2str(cellI) ', day ' num2str(dayPairs(dpI,2))])

% Rates of these features diff between groups?


% When cells (that are active both) remap between days, what is the most common form?

%% Single-neuron rate map corrs (new whole lap tbt, new bins

condPairs = [1 2];
numCondPairs = size(condPairs,1);
for mouseI = 1:numMice
    saveName = fullfile(mainFolder,mice{mouseI},'PFsCheck.mat');
    %if exist(saveName,'file')==0
        %[TMap_unsmoothed,RunOccMap] = RateMapsDoublePlusV2(trialbytrial, bins, binType, condPairs, minSpeed, occNanSol, saveName, circShift)
        tic
        [~,~] = RateMapsDoublePlusV2(cellTBT{mouseI}, lgBinVertices, 'vertices', condPairs, 0, 'zeroOut', saveName, false);
        toc
    %end
    load(saveName);
    cellTMap{mouseI} = TMap_unsmoothed;
    cellFiresAtAll{mouseI} = TMap_firesAtAll;
end

sessPairs = [1 2; 1 3; 2 3];
numSessPairs = size(sessPairs,1);
pooledSingleCorrsOneEnv = cell(numCondPairs,numSessPairs);
pooledSingleCorrsTwoEnv = cell(numCondPairs,numSessPairs);
pooledSingleCorrDiffsOneEnv = cell(numCondPairs,1);
pooledSingleCorrDiffsTwoEnv = cell(numCondPairs,1);
for mouseI = 1:numMice
    for cpI = 1:numCondPairs
        for spI = 1:numSessPairs
            firesBothDays = cellFiresAtAll{mouseI}(:,sessPairs(spI,1),cpI) & cellFiresAtAll{mouseI}(:,sessPairs(spI,2),cpI);

            singleCellCorrs{mouseI}{spI}{cpI} = cellfun(@(x,y) corr(x(:),y(:),'type','Spearman'),...
                cellTMap{mouseI}(:,sessPairs(spI,1),cpI),cellTMap{mouseI}(:,sessPairs(spI,2),cpI));
            
            % Some kind of indexing here to only take cells from both days
            switch groupNum(mouseI) 
                case 1
                    pooledSingleCorrsOneEnv{cpI,spI} = [pooledSingleCorrsOneEnv{cpI,spI}; singleCellCorrs{mouseI}{spI}{cpI}(firesBothDays)];
                case 2
                    pooledSingleCorrsTwoEnv{cpI,spI} = [pooledSingleCorrsTwoEnv{cpI,spI}; singleCellCorrs{mouseI}{spI}{cpI}(firesBothDays)];
            end
            
        end
        
        % Positive if higher correlation 4-7 than 4-8
        singleCellCorrDiffs{mouseI}{cpI} = singleCellCorrs{mouseI}{1}{cpI} - singleCellCorrs{mouseI}{2}{cpI};
        switch groupNum(mouseI) 
            case 1
            pooledSingleCorrDiffsOneEnv{cpI} = [pooledSingleCorrDiffsOneEnv{cpI}; singleCellCorrDiffs(firesBothDays)];
            case 2
            pooledSingleCorrDiffsTwoEnv{cpI} = [pooledSingleCorrDiffsTwoEnv{cpI}; singleCellCorrDiffs(firesBothDays)];    
        end
        %}
    end
end

% ECDF for single Cell corrs each day pair
for cpI = 1:numCondPairs
    %gg = figure('Position',[428 376 590 515]);%[428 613 897 278]
    figure;
    for dpI = 1:numSessPairs
        xx = subplot(2,ceil(numSessPairs/2),dpI); hold on
        yy = cdfplot(pooledSingleCorrsOneEnv{cpI,dpI}); yy.Color = 'b'; yy.LineWidth = 2;
        hold on
        zz = cdfplot(pooledSingleCorrsTwoEnv{cpI,dpI}); zz.Color = 'r'; zz.LineWidth = 2; 
        
        xlabel('Corr'); ylabel('Cumulative Proportion')
        title(['sessPair ' num2str([sessPairs(dpI,:)])])
        %xlim([0 1])
        %xx.XTick = [0 0.5 1]; xx.XTickLabel = {'0' num2str(numBins/2) num2str(numBins)};
        
        [h,p] = kstest2(pooledSingleCorrsOneEnv{cpI,dpI},pooledSingleCorrsTwoEnv{cpI,dpI});
        text(0.4,0.5,['p=' num2str(round(p,2))])
    end
    %suptitleSL(['Distribution of single cell rate map correlations, day pair ' num2str(realDays{mouseI}(dayPairsForward(dpI,:))')])
    
    %print(fullfile(saveFolder,['COMchangeKS' num2str(dpI)]),'-dpdf') 
    %close(gg)
end



%% Pop vector corr analysis (most basic)

% TMaps are whole trial, split to each arm
for mouseI = 1:numMice
    % Turn days
    tmapHere{mouseI}(:,[1:3 7:9],1) = cellfun(@(x) x(binOrderArms{1}),cellTMap{mouseI}(:,[1:3 7:9],1),'UniformOutput',false);
    tmapHere{mouseI}(:,[1:3 7:9],2) = cellfun(@(x) x(binOrderArms{2}),cellTMap{mouseI}(:,[1:3 7:9],1),'UniformOutput',false);
    tmapHere{mouseI}(:,[1:3 7:9],3) = cellfun(@(x) x(binOrderArms{3}),cellTMap{mouseI}(:,[1:3 7:9],2),'UniformOutput',false);
    tmapHere{mouseI}(:,[1:3 7:9],4) = cellfun(@(x) x(binOrderArms{4}),cellTMap{mouseI}(:,[1:3 7:9],2),'UniformOutput',false);

    % Place days
    tmapHere{mouseI}(:,[4:6],1) = cellfun(@(x) x(binOrderArms{1}),cellTMap{mouseI}(:,[4:6],1),'UniformOutput',false);
    tmapHere{mouseI}(:,[4:6],2) = cellfun(@(x) x(binOrderArms{4}),cellTMap{mouseI}(:,[4:6],1),'UniformOutput',false);
    tmapHere{mouseI}(:,[4:6],3) = cellfun(@(x) x(binOrderArms{3}),cellTMap{mouseI}(:,[4:6],2),'UniformOutput',false);
    tmapHere{mouseI}(:,[4:6],4) = cellfun(@(x) x(binOrderArms{4}),cellTMap{mouseI}(:,[4:6],2),'UniformOutput',false);
end

for condI = 1:4
    lgPlotHere{condI}.X = lgPlotBins.X(binOrderArms{condI},:);
    lgPlotHere{condI}.Y = lgPlotBins.Y(binOrderArms{condI},:);
end

cellsUseOption = 'activeEither';
corrType = 'Spearman';
numPerms = 1000;

condPairs = [1 1; 2 2; 3 3; 4 4]; numCondPairs = size(condPairs,1);
%dayPairs = [1 2; 1 3; 2 3]; numDayPairs = size(dayPairs,1); % old
dayPairs = [3 7; 3 8; 7 8; 8 9]; numDayPairs = size(dayPairs,1);

traitLogical = threshAndConsecEach;
traitLogical = cellfun(@(x) x>lapPctThresh,trialReliEach,'UniformOutput',false);
pvCorrs = cell(numMice,1); 
meanCorr = cell(numMice,1); 
numCellsUsed = cell(numMice,1); 
numNan = cell(numMice,1); 

disp('Making corrs')
pooledPVcorrs = cell(numDayPairs,numCondPairs);
pooledMeanCorr = cell(numDayPairs,numCondPairs);
pooledNumCellsUsed = cell(numDayPairs,numCondPairs);
for mouseI = 1:numMice
    
    [pvCorrs, meanCorr, numCellsUsed, numNans] =...
        PVcorrsWrapperBasic(tmapHere{mouseI},condPairs,dayPairs,traitLogical{mouseI},cellsUseOption,corrType);
    
    for cpI = 1:numCondPairs
        for dpI = 1:numDayPairs
            pooledPVcorrs{dpI,cpI} = [pooledPVcorrs{dpI,cpI}; pvCorrs{dpI,cpI}];
            pooledMeanCorr{dpI,cpI} = [pooledMeanCorr{dpI,cpI}; meanCorr{dpI,cpI}];
            pooledNumCellsUsed{dpI,cpI} = [pooledNumCellsUsed{dpI,cpI}; numCellsUsed{dpI,cpI}];
        end
    end
end

disp('testing diffs')
for cpI = 1:numCondPairs
    for dpI = 1:numDayPairs
        oneEnvMicePVcorrs{dpI,cpI} = pooledPVcorrs{dpI,cpI}(oneEnvMice,:);
        oneEnvMicePVcorrsMeans{dpI,cpI} = mean(oneEnvMicePVcorrs{dpI,cpI},1);
        
        twoEnvMicePVcorrs{dpI,cpI} = pooledPVcorrs{dpI,cpI}(twoEnvMice,:);
        twoEnvMicePVcorrsMeans{dpI,cpI} = mean(twoEnvMicePVcorrs{dpI,cpI},1);
        
        sameMinusDiff{dpI,cpI} = oneEnvMicePVcorrsMeans{dpI,cpI} - twoEnvMicePVcorrsMeans{dpI,cpI};
        
        %sepMinusInt{dI,cpI} = twoEnvMicePVcorrsMeans{dpI,cpI} - oneEnvMicePVcorrsMeans{dpI,cpI};
        
        for binI = 1:numBins
            %[pPVs{dpI,cpI}(binI),hPVs{dpI,cpI}(binI)] = ranksum(oneEnvMicePVcorrs{dpI,cpI}(:,binI),...
            %twoEnvMicePVcorrs{dpI,cpI}(:,binI));
        end
        
        diffRank{dpI,cpI} = PermutationTestSL(oneEnvMicePVcorrs{dpI,cpI},twoEnvMicePVcorrs{dpI,cpI},numPerms);
        isSig{dpI,cpI} = diffRank{dpI,cpI} > (1-pThresh);
    end
end

disp('done pv corrs basic')

%% Single cell remapping

for mouseI = 1:numMice
    % Turn days
    tmapHere{mouseI}(:,[1:3 7:9],1) = cellfun(@(x) x(binOrderArms{1}),cellTMap{mouseI}(:,[1:3 7:9],1),'UniformOutput',false);
    tmapHere{mouseI}(:,[1:3 7:9],2) = cellfun(@(x) x(binOrderArms{2}),cellTMap{mouseI}(:,[1:3 7:9],1),'UniformOutput',false);
    tmapHere{mouseI}(:,[1:3 7:9],3) = cellfun(@(x) x(binOrderArms{3}),cellTMap{mouseI}(:,[1:3 7:9],2),'UniformOutput',false);
    tmapHere{mouseI}(:,[1:3 7:9],4) = cellfun(@(x) x(binOrderArms{4}),cellTMap{mouseI}(:,[1:3 7:9],2),'UniformOutput',false);

    % Place days
    tmapHere{mouseI}(:,[4:6],1) = cellfun(@(x) x(binOrderArms{1}),cellTMap{mouseI}(:,[4:6],1),'UniformOutput',false);
    tmapHere{mouseI}(:,[4:6],2) = cellfun(@(x) x(binOrderArms{4}),cellTMap{mouseI}(:,[4:6],1),'UniformOutput',false);
    tmapHere{mouseI}(:,[4:6],3) = cellfun(@(x) x(binOrderArms{3}),cellTMap{mouseI}(:,[4:6],2),'UniformOutput',false);
    tmapHere{mouseI}(:,[4:6],4) = cellfun(@(x) x(binOrderArms{4}),cellTMap{mouseI}(:,[4:6],2),'UniformOutput',false);
end


numConds = length(cellTBT{1});
numConds = 4;

dayPairsForward = [3 7; 3 8; 7 8; 8 9]; numDayPairs = size(dayPairsForward,1);
%Center of mass shift
allFiringCOM = cell(numMice,1);
oneEnvCOMchanges = cell(numDayPairs,1);
twoEnvCOMchanges = cell(numDayPairs,1);

for mouseI = 1:numMice
    allFiringCOM{mouseI} = TMapFiringCOM(tmapHere{mouseI});
    
    for dpI = 1:numDayPairs
        comsA = squeeze(allFiringCOM{mouseI}(:,dayPairsForward(dpI,1),:));
        comsB = squeeze(allFiringCOM{mouseI}(:,dayPairsForward(dpI,2),:));
        COMchanges{mouseI}{dpI} = abs(comsB - comsA); %(cell, cond)
    
        %Ultimately want to compare this to a shuffle, is diff greater than suffle
        
        switch mouseI
            case num2cell(oneEnvMice)'
                oneEnvCOMchanges{dpI} = [oneEnvCOMchanges{dpI}; COMchanges{mouseI}{dpI}];%(cell, cond)
            case num2cell(twoEnvMice)'
                twoEnvCOMchanges{dpI} = [twoEnvCOMchanges{dpI}; COMchanges{mouseI}{dpI}];
        end
    end
end

%Rate Remapping:
maxRates = []; meanRates = []; maxRateDiffs = []; meanRateDiffs = []; pctChangeMax = []; pctChangeMean = [];
oneEnvMaxRateDiffs = cell(numDayPairs,1); oneEnvMaxRatePctChange = cell(numDayPairs,1);
twoEnvMaxRateDiffs = cell(numDayPairs,1); twoEnvMaxRatePctChange = cell(numDayPairs,1);
oneEnvMeanRateDiffs = cell(numDayPairs,1); oneEnvMeanRatePctChange = cell(numDayPairs,1);
oneEnvFiredEither = cell(numDayPairs,1); twoEnvFiredEither = cell(numDayPairs,1);
twoEnvMeanRateDiffs = cell(numDayPairs,1); twoEnvMeanRatePctChange = cell(numDayPairs,1);
for mouseI = 1:numMice
    maxRates{mouseI} = cell2mat(cellfun(@max,tmapHere{mouseI},'UniformOutput',false));
    for dpI = 1:numDayPairs
        ratesA = squeeze(maxRates{mouseI}(:,dayPairsForward(dpI,1),:));
        ratesB = squeeze(maxRates{mouseI}(:,dayPairsForward(dpI,2),:));
        ratesAll = [];
        ratesAll(:,:,1) = ratesA; 
        ratesAll(:,:,2) = ratesB; 
        firedEither = sum(ratesAll,3)>0;
        maxRateDiffs{mouseI}{dpI} = max(ratesAll,[],3) - min(ratesAll,[],3);
        pctChangeMax{mouseI}{dpI} = maxRateDiffs{mouseI}{dpI} ./ max(ratesAll,[],3);
        
        switch mouseI
            case num2cell(oneEnvMice)'
                oneEnvMaxRateDiffs{dpI} = [oneEnvMaxRateDiffs{dpI}; maxRateDiffs{mouseI}{dpI}];%(cell, cond)
                oneEnvMaxRatePctChange{dpI} = [oneEnvMaxRatePctChange{dpI}; pctChangeMax{mouseI}{dpI}];
            case num2cell(twoEnvMice)'
                twoEnvMaxRateDiffs{dpI} = [twoEnvMaxRateDiffs{dpI}; maxRateDiffs{mouseI}{dpI}];
                twoEnvMaxRatePctChange{dpI} = [twoEnvMaxRatePctChange{dpI}; pctChangeMax{mouseI}{dpI}];
        end
    end
    
    meanRates{mouseI} = cell2mat(cellfun(@mean,tmapHere{mouseI},'UniformOutput',false));
    for dpI = 1:numDayPairs
        mratesA = squeeze(meanRates{mouseI}(:,dayPairsForward(dpI,1),:));
        mratesB = squeeze(meanRates{mouseI}(:,dayPairsForward(dpI,2),:));
        mratesAll = [];
        mratesAll(:,:,1) = mratesA; 
        mratesAll(:,:,2) = mratesB;
        mfiredEither = sum(mratesAll,3)>0;
        meanRateDiffs{mouseI}{dpI} = max(mratesAll,[],3) - min(mratesAll,[],3);
        pctChangeMean{mouseI}{dpI} = meanRateDiffs{mouseI}{dpI} ./ max(mratesAll,[],3);
        
        switch mouseI
            case num2cell(oneEnvMice)'
                oneEnvMeanRateDiffs{dpI} = [oneEnvMeanRateDiffs{dpI}; meanRateDiffs{mouseI}{dpI}];%(cell, cond)
                oneEnvMeanRatePctChange{dpI} = [oneEnvMeanRatePctChange{dpI}; pctChangeMean{mouseI}{dpI}];
                oneEnvFiredEither{dpI} = [oneEnvFiredEither{dpI}; mfiredEither];
            case num2cell(twoEnvMice)'
                twoEnvMeanRateDiffs{dpI} = [twoEnvMeanRateDiffs{dpI}; meanRateDiffs{mouseI}{dpI}];
                twoEnvMeanRatePctChange{dpI} = [twoEnvMeanRatePctChange{dpI}; pctChangeMean{mouseI}{dpI}];
                twoEnvFiredEither{dpI} = [twoEnvFiredEither{dpI}; mfiredEither];
        end
    end
end

%Arm preference
oneEnvSameArms = cell(numDayPairs,1);
twoEnvSameArms = cell(numDayPairs,1);
for mouseI = 1:numMice
    [armPref{mouseI}] = CondFiringPreference(tmapHere{mouseI});
    firedAtAll = sum(trialReli{mouseI},3)>0;
    
    for dpI = 1:numDayPairs
        firedBothDays = sum(firedAtAll(:,dayPairsForward(dpI,:)),2)==2;
        armsA = armPref{mouseI}(firedBothDays,dayPairsForward(dpI,1));
        armsB = armPref{mouseI}(firedBothDays,dayPairsForward(dpI,2));
        
        sameArm = armsA==armsB;
        sameArmPct(mouseI,dpI) = sum(sameArm)/length(sameArm);
        switch mouseI
            case num2cell(oneEnvMice)'
                oneEnvSameArms{dpI} = [oneEnvSameArms{dpI}; sameArm];
            case num2cell(twoEnvMice)'
                twoEnvSameArms{dpI} = [twoEnvSameArms{dpI}; sameArm];
        end
    end
end
   
oneEnvSameArmsPct = cell2mat(cellfun(@(x) sum(x)/length(x),oneEnvSameArms,'UniformOutput',false));
twoEnvSameArmsPct = cell2mat(cellfun(@(x) sum(x)/length(x),twoEnvSameArms,'UniformOutput',false));

% Cells that totally stop/start firing
regConfirmed = 0;
oneEnvStoppedFiring = cell(numDayPairs,1);
oneEnvStartedFiring = cell(numDayPairs,1);
twoEnvStoppedFiring = cell(numDayPairs,1);
twoEnvStartedFiring = cell(numDayPairs,1);
for mouseI = 1:numMice
    firedThisCond = trialReliEach{mouseI}>0;
    
    for dpI = 1:numDayPairs
        firedA = squeeze(firedThisCond(:,dayPairsForward(dpI,1),:));
        firedB = squeeze(firedThisCond(:,dayPairsForward(dpI,2),:));
        
        firedAll = []; firedAll(:,:,1) = firedA; firedAll(:,:,2) = firedB;
        firedOne = sum(firedAll,3)==1;
        
        stoppedFiring = firedA & firedOne;
        startedFiring = firedB & firedOne;
        
        %Make sure both cells were there
        defHaveTheCells = cellSSI{mouseI}>0;
        haveCellsBothDays = sum(defHaveTheCells(:,dayPairsForward(dpI,:)),2)==2;
        dayPairMaxCells{mouseI}{dpI} = max(sum(defHaveTheCells(:,dayPairsForward(dpI,:)),1));
        goodReg(mouseI,dpI) = sum(haveCellsBothDays,1)/size(cellSSI{mouseI},1);
        if regConfirmed==1
            stoppedFiring(haveCellsBothDays==0) = 0;
            startedFiring(haveCellsBothDays==0) = 0;
            
            stoppedFiringAll(mouseI,dpI) = sum(sum(stoppedFiring))/(sum(haveCellsBothDays,1)*numConds);
            startedFiringAll(mouseI,dpI) = sum(sum(startedFiring))/(sum(haveCellsBothDays,1)*numConds);
        end
            %could also do this for started or stopped in each mouse independently, add them up in the section vvvvv
        
        stoppedFiringAll(mouseI,dpI) = sum(sum(stoppedFiring))/(size(stoppedFiring,1)*numConds);
        startedFiringAll(mouseI,dpI) = sum(sum(startedFiring))/(size(startedFiring,1)*numConds);
         %could be normalized by dayPairMaxCells or defHaveboth
        switch mouseI
            case num2cell(oneEnvMice)'
                oneEnvStoppedFiring{dpI} = [oneEnvStoppedFiring{dpI}; stoppedFiring];
                oneEnvStartedFiring{dpI} = [oneEnvStartedFiring{dpI}; startedFiring];
            case num2cell(twoEnvMice)'
                twoEnvStoppedFiring{dpI} = [twoEnvStoppedFiring{dpI}; stoppedFiring];
                twoEnvStartedFiring{dpI} = [twoEnvStartedFiring{dpI}; startedFiring];
        end
        
        
    end
end
 

oneEnvStoppedFiringPct = cell2mat(cellfun(@(x) sum(sum(x))/(size(x,1)*numConds),oneEnvStoppedFiring,'UniformOutput',false));
oneEnvStartedFiringPct = cell2mat(cellfun(@(x) sum(sum(x))/(size(x,1)*numConds),oneEnvStartedFiring,'UniformOutput',false));
twoEnvStoppedFiringPct = cell2mat(cellfun(@(x) sum(sum(x))/(size(x,1)*numConds),twoEnvStoppedFiring,'UniformOutput',false));
twoEnvStartedFiringPct = cell2mat(cellfun(@(x) sum(sum(x))/(size(x,1)*numConds),twoEnvStartedFiring,'UniformOutput',false));

disp('Done single cell remapping')

% Rate map correlations

% Compare 4 vs 7 to 4 vs 8 within groups



%% PV corrs: portion of session
cellsUseOption = 'activeEither';
corrType = 'Spearman';

condPairs = [1 1; 2 2; 3 3; 4 4]; numCondPairs = size(condPairs,1);
dayPairs = [1 2; 1 3; 2 3]; numDayPairs = size(dayPairs,1);
dayChunks = [0 0.34; 0.33 0.67; 0.66 1];
numDayChunks = size(dayChunks,1);

trimPooledPVcorrs = cell(numDayChunks,numDayPairs,numCondPairs);
trimPooledMeanCorr = cell(numDayChunks,numDayPairs,numCondPairs);
trimPooledNumCellsUsed = cell(numDayChunks,numDayPairs,numCondPairs);

disp('Making corrs')
for mouseI = 1:numMice
    for dcI = 1:numDayChunks
        trimmedTBT = SlimDownTBT(cellTBT{mouseI},dayChunks(dcI,:));

        [TMapTrimmed, ~, ~, ~, ~, ~, ~] =...
            PFsLinTBTdoublePlus(trimmedTBT, binEdges, minspeed, [], false);

        [pvCorrsTrim, meanCorrTrim, ~, ~] =...
            PVcorrsWrapperBasic(TMapTrimmed,condPairs,dayPairs,traitLogical{mouseI},cellsUseOption,corrType);

        for cpI = 1:numCondPairs
            for dpI = 1:numDayPairs
                trimPooledPVcorrs{dcI,dpI,cpI} = [trimPooledPVcorrs{dcI,dpI,cpI}; pvCorrsTrim{dpI,cpI}];
                trimPooledMeanCorr{dcI,dpI,cpI} = [trimPooledMeanCorr{dcI,dpI,cpI}; meanCorrTrim{dpI,cpI}];
                trimPooledNumCellsUsed{dcI,dpI,cpI} = [trimPooledNumCellsUsed{dcI,dpI,cpI}; numCellsUsed{dpI,cpI}];
            end
        end
    end
end
disp('Done making corrs')

oneEnvMiceTrimPVcorrs = cell(numDayChunks,numDayPairs,numCondPairs);
oneEnvMiceTrimPVcorrsMeans = cell(numDayChunks,numDayPairs,numCondPairs);
twoEnvMiceTrimPVcorrs = cell(numDayChunks,numDayPairs,numCondPairs);
twoEnvMiceTrimPVcorrsMeans = cell(numDayChunks,numDayPairs,numCondPairs);
sameMinusDiffTrim = cell(numDayChunks,numDayPairs,numCondPairs);

disp('testing diffs')
for dcI = 1:numDayChunks
for cpI = 1:numCondPairs
    for dpI = 1:numDayPairs
        oneEnvMiceTrimPVcorrs{dcI,dpI,cpI} = trimPooledPVcorrs{dcI,dpI,cpI}(oneEnvMice,:);
        oneEnvMiceTrimPVcorrsMeans{dcI,dpI,cpI} = mean(oneEnvMiceTrimPVcorrs{dcI,dpI,cpI},1);
        
        twoEnvMiceTrimPVcorrs{dcI,dpI,cpI} = trimPooledPVcorrs{dcI,dpI,cpI}(twoEnvMice,:);
        twoEnvMiceTrimPVcorrsMeans{dcI,dpI,cpI} = mean(twoEnvMiceTrimPVcorrs{dcI,dpI,cpI},1);
        
        sameMinusDiffTrim{dcI,dpI,cpI} = oneEnvMiceTrimPVcorrsMeans{dcI,dpI,cpI} - twoEnvMiceTrimPVcorrsMeans{dcI,dpI,cpI};
        
        diffRankTrim{dcI,dpI,cpI} = PermutationTestSL(oneEnvMiceTrimPVcorrs{dcI,dpI,cpI},...
            twoEnvMiceTrimPVcorrs{dcI,dpI,cpI},numPerms);
        isSigTrim{dcI,dpI,cpI} = diffRankTrim{dcI,dpI,cpI} > (1-pThresh);
    end
end
end

disp('Done with portion of day')


%% Splitter cells? 
numShuffles = 1000;
%numShuffles = 100;
shuffThresh = 1 - pThresh;
binsMin = 1;

%Shuffle between start arm and finish arm ('phase')
dimShuffle = {'south','east';'north','west'};
for mouseI = 1:numMice    
    tic
    shuffDirFull = fullfile(mainFolder,mice{mouseI},'shufflePhase');
    condPairs = [];
    for shuffPairI = 1:size(dimShuffle,1)
        for shuffThisI = 1:size(dimShuffle,2)
            condPairs(shuffPairI,shuffThisI) = find(strcmpi({cellTBT{mouseI}(:).name},dimShuffle{shuffPairI,shuffThisI}));
        end
    end

    [rateDiffPhase{mouseI}, rateSplitPhase{mouseI}, meanRateDiffPhase{mouseI},...
        DIeachPhase{mouseI}, DImeanPhase{mouseI}, DIallPhase{mouseI}] =...
        LookAtSplitters4(cellTMap_unsmoothed{mouseI}, condPairs, []);
    
    if exist(shuffDirFull,'dir')~=7
        mkdir(shuffDirFull)
        disp('making shuffle directory')
    end
    
    splitterFilePhase = fullfile(shuffDirFull,'splittersPhase.mat');
    if exist(splitterFilePhase,'file')==2
        disp(['found phase splitters for mouse ' num2str(mouseI)])
        load(splitterFilePhase)
    else
        disp(['did not find Phase splitting for mouse ' num2str(mouseI) ', making now'])
        [~, binsAboveShufflePhase, thisCellSplitsPhase] = SplitterWrapperDoublePlus(cellTBT{mouseI}, dimShuffle,...
                numShuffles, shuffDirFull, binEdges, minspeed, shuffThresh, binsMin);
        save(splitterFilePhase,'binsAboveShufflePhase','thisCellSplitsPhase')
    end
    
    splittersPhase{mouseI} = thisCellSplitsPhase.*dayUse{mouseI};
    binsAboveShuffPhase{mouseI} = binsAboveShufflePhase;
end

%Shuffle across starts, across finishes ('same')
dimShuffle = {'south','north';'east','west'};
for mouseI = 1:numMice    
    tic
    shuffDirFull = fullfile(mainFolder,mice{mouseI},'shuffleSame');
    condPairs = [];
    for shuffPairI = 1:size(dimShuffle,1)
        for shuffThisI = 1:size(dimShuffle,2)
            condPairs(shuffPairI,shuffThisI) = find(strcmpi({cellTBT{mouseI}(:).name},dimShuffle{shuffPairI,shuffThisI}));
        end
    end

    [rateDiffSame{mouseI}, rateSplitSame{mouseI}, meanRateDiffSame{mouseI},...
        DIeachSame{mouseI}, DImeanSame{mouseI}, DIallSame{mouseI}] =...
        LookAtSplitters4(cellTMap_unsmoothed{mouseI}, condPairs, []);
    
    if exist(shuffDirFull,'dir')~=7
        mkdir(shuffDirFull)
        disp('making shuffle directory')
    end
    
    splitterFileSame = fullfile(shuffDirFull,'splittersSame.mat');
    if exist(splitterFileSame,'file')==2
        disp(['found same splitters for mouse ' num2str(mouseI)])
        load(splitterFileSame)
    else
        disp(['did not find Same splitting for mouse ' num2str(mouseI) ', making now'])
        [~, binsAboveShuffleSame, thisCellSplitsSame] = SplitterWrapperDoublePlus(cellTBT{mouseI}, dimShuffle,...
                numShuffles, shuffDirFull, binEdges, minspeed, shuffThresh, binsMin);
        save(splitterFileSame,'binsAboveShuffleSame','thisCellSplitsSame')
    end
    toc
    
    splittersSame{mouseI} = thisCellSplitsSame.*dayUse{mouseI};
    binsAboveShuffSame{mouseI} = binsAboveShuffleSame;
end


%% Splitter breakdowns

for mouseI = 1:numMice
    nonPhaseSplitter{mouseI} = splittersPhase{mouseI}==0 & dayUse{mouseI};
    nonSameSplitter{mouseI} = splittersSame{mouseI}==0 & dayUse{mouseI};
    nonSplitter{mouseI} = nonPhaseSplitter{mouseI} & nonSameSplitter{mouseI};
    splitterBoth{mouseI} = splittersPhase{mouseI} & splittersSame{mouseI};
    
    %codes for start/end but doesnt care which
    splittersPhaseOnly{mouseI} = splittersPhase{mouseI} & splittersSame{mouseI}==0;

    %codes for only one trajectory, doesn't care start or end
    splittersSameOnly{mouseI} = splittersSame{mouseI} & splittersPhase{mouseI}==0;
end

groupNames = {'Phase','Same','PhaseOnly','SameOnly','non-Split','Split-Both'};
for mouseI = 1:numMice     
    traitGroups{mouseI} = {splittersPhase{mouseI}; splittersSame{mouseI}; splittersPhaseOnly{mouseI};...
                           splittersSameOnly{mouseI}; nonSplitter{mouseI}; splitterBoth{mouseI}};
end


%Pct each day? 
pooledSplitterProps = cell(length(traitGroups),1);
for mouseI = 1:numMice
	splitterGroupPct{mouseI} = RunGroupFunction('TraitDailyPct',traitGroups{mouseI},dayUse{mouseI});
    
    for tgI = 1:length(traitGroups)
        pooledSplitterProps{tgI} = [pooledSplitterProps{tgI}; splitterGroupPct{mouseI}{tgI}];
    end
end


%splitters coming and going?
pooledSplitPctChangeFWD = cell(1,length(traitGroups{1})); pooledDaysApartFWD = [];
for mouseI = 1:numMice
    [splitterPctDayChangesFWD{mouseI}] = RunGroupFunction('NNplusKChange',traitGroups{mouseI},dayUse{mouseI});

    daysApartFWD{mouseI} = diff(splitterPctDayChangesFWD{mouseI}(1).dayPairs,1,2);
    
    %realDaysApart cellRealDays
    
    pooledDaysApartFWD = [pooledDaysApartFWD; daysApartFWD{mouseI}];
    for tgI = 1:length(traitGroups{mouseI})
        pooledSplitPctChangeFWD{tgI} = [pooledSplitPctChangeFWD{tgI}; splitterPctDayChangesFWD{mouseI}(tgI).pctChange];
    end
end

dayPairsForward = [1 2; 1 3; 2 3];
dSame = find([ones(2,length(oneEnvMice));zeros(1,length(oneEnvMice))]);
dDiff = find([ones(2,length(twoEnvMice));zeros(1,length(twoEnvMice))]);
%Cells becoming phase splitters?
cellHere = cellfun(@(x) x>0,cellSSI,'UniformOutput',false);
cellsRegistered = RunGroupFunction('GetCellsOverlap',cellHere,cellHere,dayPairsForward);
registrationRateDiffPct = [cellsRegistered(twoEnvMice).overlapWithModel]; %(dayPair,mouseI)
registrationRateSamePct = [cellsRegistered(oneEnvMice).overlapWithModel]; %(dayPair,mouseI)
regRateSig = PermutationTestSL(registrationRateDiffPct(dDiff),registrationRateSamePct(dSame),1000) > (1 - pThresh);

becomesPhase = RunGroupFunction('GetCellsOverlap',nonPhaseSplitter,splittersPhase,dayPairsForward);
becomesPhaseDiffPct = [becomesPhase(twoEnvMice).overlapWithModel]; %(dayPair,mouseI)
becomesPhaseSamePct = [becomesPhase(oneEnvMice).overlapWithModel]; %(dayPair,mouseI)
becomesPhaseSig = PermutationTestSL(becomesPhaseDiffPct(dDiff),becomesPhaseSamePct(dSame),1000) > (1 - pThresh);

becomesSame = RunGroupFunction('GetCellsOverlap',nonSameSplitter,splittersSame,dayPairsForward);
becomesSameDiffPct = [becomesSame(twoEnvMice).overlapWithModel]; %(dayPair,mouseI)
becomesSameSamePct = [becomesSame(oneEnvMice).overlapWithModel]; %(dayPair,mouseI)
becomesSameSig = PermutationTestSL(becomesSameDiffPct(dDiff),becomesSameSamePct(dSame),1000) > (1 - pThresh);

losesPhase = RunGroupFunction('GetCellsOverlap',splittersPhase,nonPhaseSplitter,dayPairsForward);
losesPhaseDiffPct = [losesPhase(twoEnvMice).overlapWithModel]; %(dayPair,mouseI)
losesPhaseSamePct = [losesPhase(oneEnvMice).overlapWithModel]; %(dayPair,mouseI)
losesPhaseSig = PermutationTestSL(losesPhaseDiffPct(dDiff),losesPhaseSamePct(dSame),1000) > (1 - pThresh);

losesSame = RunGroupFunction('GetCellsOverlap',splittersSame,nonSameSplitter,dayPairsForward);
losesSameDiffPct = [losesSame(twoEnvMice).overlapWithModel]; %(dayPair,mouseI)
losesSameSamePct = [losesSame(oneEnvMice).overlapWithModel]; %(dayPair,mouseI)
losesSameSig = PermutationTestSL(losesSameDiffPct(dDiff),losesSameSamePct(dSame),1000) > (1 - pThresh);


