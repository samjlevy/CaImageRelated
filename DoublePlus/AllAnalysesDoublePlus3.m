%AllAnalysesDoublePlus

%mainFolder = 'G:\DoublePlus';
%mainFolder = 'C:\Users\Sam\Desktop\DoublePlusFinalData';
mainFolder = 'F:\DoublePlus';
%mainFolder = 'C:\Users\samwi_000\Desktop\DoublePlus';
load(fullfile(mainFolder,'groupAssign.mat'))
groupNum(strcmpi(groupAssign(:,2),'same')) = 1;
groupNum(strcmpi(groupAssign(:,2),'diff')) = 2;
%mice = {'Kerberos','Marble07','Marble11','Pandora','Styx','Titan'};
mice = groupAssign(:,1)';
numMice = length(mice);
groupColors = {'r','b'};

%dayThree = [11 12 13 12 9 12];
dayThree = 3*ones(numMice,1);

sessTypes = {'Turn','Turn','Turn','Place','Place','Place','Turn','Turn','Turn'};
name = {'North-West','South-East';'North-East','South-East'};
binLabelsUse = {['n','m','w'],['s','m','e'];['n','m','e'],['s','m','e']};
armLabels = {'n','e','s','w'};

nArmBins = 14;
lgAnchor = load(fullfile(mainFolder,'mainPosAnchor.mat'));
[lgDataBins,lgPlotBins] = SmallPlusBounds(lgAnchor.posAnchorIdeal,nArmBins);
lgBinVertices = {lgDataBins.X, lgDataBins.Y};
binMidsX = mean(lgDataBins.X,2);
binMidsY = mean(lgDataBins.Y,2);
allMazeBound.Y = [lgDataBins.bounds.north.Y; lgDataBins.bounds.east.Y; lgDataBins.bounds.south.Y; flipud(lgDataBins.bounds.west.Y)];
allMazeBound.X = [flipud(lgDataBins.bounds.north.X); lgDataBins.bounds.east.X; lgDataBins.bounds.south.X; lgDataBins.bounds.west.X];
%{
figure; plot(allMazeBound.X,allMazeBound.Y)
hold on
plot(allMazeBound.X(1),allMazeBound.Y(1),'*r')
plot(allMazeBound.X(end),allMazeBound.Y(end),'og')
%}
[binOrderIndex] = SetBinOrder(lgDataBins,binLabelsUse);
for condI = 1:2
    %for ll = 1:length(binLabelsUse{1,condI})
    turnBinsUse{condI} = logical(sum(lgDataBins.labels == binLabelsUse{1,condI},2));
    placeBinsUse{condI} = logical(sum(lgDataBins.labels == binLabelsUse{2,condI},2));
end

mazeWidth = 5.7150; % cm
binSize = lgBinVertices{1}(5,1) - lgBinVertices{1}(4,1);



% Small maze:
%{
nArmBins = 7;
smAnchor = load(fullfile(mainFolder,'smallPosAnchor.mat'));
%[smDataBins,smPlotBins] = SmallPlusBounds(smAnchor.posAnchorIdeal,nArmBins);
[smDataBins,smPlotBins] = SmallPlusBoundsSized(smAnchor.posAnchorIdeal,nArmBins,binSize);
smBinVertices = {smDataBins.X, smDataBins.Y};
%}

locInds = {1 'center'; 2 'north'; 3 'south'; 4 'east'; 5 'west'};
%{
[armBounds, ~, ~] = MakeDoublePlusBehaviorBounds;
armLims = armBounds.north(3,:);
numBins = 10;
cmperbin = (max(armLims) - min(armLims))/numBins;
binEdges = linspace(min(armLims),max(armLims),numBins+1);
%}
% Will need to redo most code from here for new bins
minspeed = 0;


pThresh = 0.05;
lapPctThresh = 0.25;
consecLapThresh = 3;

disp('loading root data')
for mouseI = 1:numMice
    load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'))
    %load(fullfile(mainFolder,mice{mouseI},'trialbytrialLAP.mat'))
    if iscell(trialbytrial(1).trialsX{1})
        disp(['Found a misformatted trialbytrial for ' mice{mouseI} ', fixing and saving now'])
        trialbytrial = TBTcellFix(trialbytrial);
        save(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'),'trialbytrial','-append','-v7.3')
        disp('Fixed')
    end
    
    cellTBT{mouseI} = trialbytrial;
    cellSSI{mouseI} = sortedSessionInds;
    
    cellAllFiles{mouseI} = allfiles;
    try cellRealDays{mouseI} = realDays; catch cellRealDays{mouseI} = realdays; end
    
    %load(fullfile(mainFolder,mice{mouseI},'sessType.mat'))
    %cellSessType{mouseI} = sessType;
    
    daysHave = unique(cellTBT{mouseI}(1).sessID);
    %cellSessType{mouseI} = cellSessType{mouseI}(daysHave);
    %cellSessionSubtypes{mouseI} = [cellSessType{mouseI}{:}];
    
    numDays(mouseI) = size(cellSSI{mouseI},2);
    numCells(mouseI) = size(cellSSI{mouseI},1);
    
    clear trialbytrial sortedSessionInds allFiles
    
    %load(fullfile(mainFolder,mice{mouseI},'DoublePlusDataTable.mat'))
    %accuracy{mouseI} = DoublePlusDataTable.Accuracy;
    %realDays{mouseI} = DoublePlusDataTable.RealDay;
    %clear DoublePlusDataTable 
    
    disp(['Mouse ' num2str(mouseI) ' completed'])
end

armAlignment = GetDoublePlusArmAlignment;
%condNames = {cellTBT{1}.name};
numConds = length(cellTBT{1});

disp('Getting reliability')
for mouseI = 1:numMice
    reliFileName = fullfile(mainFolder,mice{mouseI},'trialReli.mat');
    if exist(reliFileName,'file')==0
        [dayUse,trialReli,threshAndConsec] = TrialReliability2(cellTBT{mouseI},allMazeBound,lapPctThresh, consecLapThresh,[1;2]);
        [dayUseAll,trialReliAll,threshAndConsecAll] = TrialReliability2(cellTBT{mouseI},allMazeBound,lapPctThresh, consecLapThresh,[1 2]);
        save(reliFileName,'dayUse','trialReli','threshAndConsec','dayUseAll','trialReliAll','threshAndConsecAll')
    end

end
clear dayUse threshAndConsec trialReli%dayUse = cell(1,numMice); threshAndConsec = cell(1,numMice);
for mouseI = 1:numMice
    reliFileName = fullfile(mainFolder,mice{mouseI},'trialReli.mat');
    reliLoad = load(reliFileName);
    
    dayUse{mouseI} = reliLoad.dayUse;
    trialReli{mouseI} = reliLoad.trialReli; 
    threshAndConsec{mouseI} = reliLoad.threshAndConsec;
    dayUseAll{mouseI} = reliLoad.dayUseAll;
    trialReliAll{mouseI} = reliLoad.trialReliAll;
    threshAndConsecAll{mouseI} = reliLoad.threshAndConsecAll;
  
    disp(['Mouse ' num2str(mouseI) ' completed'])
end
disp('done reliability')


disp('checking place fields')
condPairs = [1; 2];
numCondPairs = size(condPairs,1);
for mouseI = 1:numMice
    pfName= fullfile(mainFolder,mice{mouseI},'PFsLin.mat');
    if exist(pfName,'file')==0
        disp(['no placefields found for ' mice{mouseI} ', making now'])
        binLabels = lgDataBins.labels;
        binVertices = lgBinVertices;
        tic
        %[TMap_unsmoothed,RunOccMap] = RateMapsDoublePlusV2(trialbytrial, bins, binType, condPairs, minSpeed, occNanSol, saveName, circShift)
        [~,~] = RateMapsDoublePlusV2(cellTBT{mouseI}, lgBinVertices, 'vertices', condPairs, 0, 'zeroOut', pfName, false);
        toc
        load(pfName)
        if mouseI == 1
            [TMap_unsmoothed{:,5,1}] = deal(zeros(length(lgDataBins.labels),1));
            [TMap_unsmoothed{:,5,2}] = deal(zeros(length(lgDataBins.labels),1));
            [TMap_unsmoothed{:,6,1}] = deal(zeros(length(lgDataBins.labels),1));
            [TMap_unsmoothed{:,6,2}] = deal(zeros(length(lgDataBins.labels),1));
            %save(pfName,'TMap_unsmoothed','-append')
        end
        TMap_unsmoothed(:,[1:3 7:9],1) = cellfun(@(x) x(binOrderIndex{1}),TMap_unsmoothed(:,[1:3 7:9],1),'UniformOutput',false);
        TMap_unsmoothed(:,[1:3 7:9],2) = cellfun(@(x) x(binOrderIndex{2}),TMap_unsmoothed(:,[1:3 7:9],2),'UniformOutput',false);
        TMap_unsmoothed(:,[4:6],1) = cellfun(@(x) x(binOrderIndex{3}),TMap_unsmoothed(:,[4:6],1),'UniformOutput',false);
        TMap_unsmoothed(:,[4:6],2) = cellfun(@(x) x(binOrderIndex{4}),TMap_unsmoothed(:,[4:6],2),'UniformOutput',false);
        
        save(pfName,'TMap_unsmoothed','binLabels','binVertices','-append')
    end
end
for mouseI = 1:numMice
    pfName= fullfile(mainFolder,mice{mouseI},'PFsLin.mat');
    load(pfName);
    cellTMap{mouseI} = TMap_unsmoothed;
    cellFiresAtAll{mouseI} = TMap_firesAtAll;
    allTMap{mouseI} = cellfun(@(y,z) [y(:); z(:)],cellTMap{mouseI}(:,:,1),cellTMap{mouseI}(:,:,2),'UniformOutput',false);
end
clear TMap_unsmoothed TMap_firesAtAll
disp('Done loading place fields')

groupNames = unique(groupAssign(:,2));
twoEnvMice = find(strcmpi('diff',groupAssign(:,2)));
oneEnvMice = find(strcmpi('same',groupAssign(:,2)));
groupNum(strcmpi(groupAssign(:,2),'same')) = 1;
groupNum(strcmpi(groupAssign(:,2),'diff')) = 2;

disp('Done setup stuff')

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

%% Re-mapping by Cell-coactivity

%tmapPooled
turnDays = [1:3 7:9];
placeDays = [4:6];
condPairs = [1; 2]; numCondPairs = size(condPairs,1);

dayPairs = [1 3; 2 3; 3 7; 3 8; 3 9];

% Ratemap corrs
singleCellCorrsRho = []; singleCellCorrsP = [];
for mouseI = 1:numMice
    [singleCellCorrsRho{mouseI}, singleCellCorrsP{mouseI}] = singleNeuronCorrelations(cellTMap{mouseI},dayPairs,[]);%turnBinsUse
    %{mouseI}{condI}{dayPairI}(cellI)
    [allSingleCellCorrsRho{mouseI}, allSingleCellCorrsP{mouseI}] = singleNeuronCorrelations(allTMap{mouseI},dayPairs,[]);
end
disp('Done single-cell corrs across days')

for mouseI = 1:numMice
    %[coactivity{mouseI},numTrialsActive{mouseI},pctTrialsActive{mouseI}] = findingEnsemblesNotes2(cellTBT{mouseI},condPairs);
    [coactivity2{mouseI},pctTrialsActive2{mouseI},trialCoactiveAboveBaseline{mouseI},totalCoactiveAboveBaseline{mouseI},chanceCoactive{mouseI}] =...
        findingEnsemblesNotes3(cellTBT{mouseI},allMazeBound,condPairs);
    
    aa = graph(trialCoactiveAboveBaseline{mouseI});
    [bins,binsizes] = conncomp(aa);
    
    %coactivity{mouseI}{dayI,condI}(cellI,cellJ)
    trialNormalizedCoactivity,pctTrialsActive
    nCellsToday = sum(cellSSI{mouseI}>0,1);
    numCellsToday = mat2cell(repmat(nCellsToday(:),1,numCondPairs),ones(9,1),ones(1,numCondPairs));
    isCoactive = cellfun(@(x) x>0,coactivity{mouseI},'UniformOutput',false);
    
    numCoactivePartners{mouseI} = cellfun(@(x) sum(x,2),isCoactive,'UniformOutput',false);
    pctCoactivePartners{mouseI} = cellfun(@(x,y) x/(y*ones(numCells(mouseI),1)),numCoactivePartners{mouseI},numCellsToday,'UniformOutput',false);
    totalCoactive{mouseI} = cellfun(@(x) sum(x,2),coactivity{mouseI},'UniformOutput',false);
    meanCoactivity{mouseI} = cellfun(@(x,y) x./y,totalCoactive{mouseI},numCoactivePartners{mouseI},'UniformOutput',false);
end
disp('Done getting coactivity')

% Pool corrs by group

threshHere = 0.1;
corrsPooled = cell(2,1); meanCorrPooled = []; semCorrPooled = [];
for groupI = 1:2
    for dpI = 1:size(dayPairs,1)
        corrsPooled{groupI}{dpI} = [];
        for condI = 1:numCondPairs
            miceH = find(groupNum==groupI);
            for mouseI = 1:length(miceH)
                cellsHere = cellSSI{miceH(mouseI)}(:,dayPairs(dpI,1)) & cellSSI{miceH(mouseI)}(:,dayPairs(dpI,2));
                reliUse = trialReli{miceH(mouseI)}(:,dayPairs(dpI,1),condI)>threshHere & trialReli{miceH(mouseI)}(:,dayPairs(dpI,2),condI)>threshHere;
                cellsHere = cellsHere & reliUse;
                %corrsHere = singleCellCorrsRho{miceH(mouseI)}{condI}{dpI}(cellsHere);
                corrsHere = allSingleCellCorrsRho{miceH(mouseI)}{condI}{dpI}(cellsHere);
                meanCorrs{groupI,mouseI}(condI,dpI) = mean(corrsHere);
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
%threshHere = 0.1;
xAgg = cell(size(dayPairs,1),1);
yAgg = cell(size(dayPairs,1),1);
for dpI = 1:size(dayPairs,1)
    figure('Position',[328.5000 130 1028 627.5000]);
    for mouseI = 1:numMice
        subplot(2,3,mouseI)
        %title([mice{mouseI} ' ' groups{mouseI}])
        condColors = ['r';'g'];
        for condI = 1:numCondPairs
            cellsHere = cellSSI{mouseI}(:,dayPairs(dpI,1)) & cellSSI{mouseI}(:,dayPairs(dpI,2));
            %reliUse = trialReli{mouseI}(:,dayPairs(dpI,1),condI)>threshHere & trialReli{mouseI}(:,dayPairs(dpI,2),condI)>threshHere;
            reliUse = trialReliAll{mouseI}(:,dayPairs(dpI,1),condI)>threshHere & trialReliAll{mouseI}(:,dayPairs(dpI,2),condI)>threshHere;
            cellsHere = cellsHere & reliUse;
            xPlot = pctCoactivePartners{mouseI}{min(dayPairs(dpI,:)),condI}(cellsHere); %needs to be restricted by cells carried over?
            %yPlot = singleCellCorrsRho{mouseI}{condI}{dpI}(cellsHere);
            yPlot = allSingleCellCorrsRho{mouseI}{condI}{dpI}(cellsHere);
            plot(xPlot,yPlot,'.','MarkerFaceColor',condColors(condI))
            hold on
            
            xAgg{dpI} = [xAgg{dpI}; xPlot];
            yAgg{dpI} = [yAgg{dpI}; yPlot];
        end
        ylabel('PF corr')
        xlabel('mean coactivity')
    end
    suptitleSL(['Rate maps by coactivity day pair ' num2str(dayPairs(dpI,:))])
end

figure;
for dpI = 1:size(dayPairs,1)
    subplot(1,size(dayPairs,1),dpI)
    plot(xAgg{dpI},yAgg{dpI},'.')
    [rho,p] = corr(xAgg{dpI},yAgg{dpI},'type','Spearman');
    title(['rho ' num2str(rho) ' p: ' num2str(p)])
    ylabel('PF corr')
    xlabel('mean coactivity')
end

figure;
for mouseI = 1:numMice
    subplot(2,3,mouseI)
    histogram(trialReli{mouseI}(trialReli{mouseI}>0))
end

% Change of connectivity across days
for dpI = 1:size(dayPairs,1)
    figure('Position',[328.5000 130 1028 627.5000]);
    for mouseI = 1:numMice
        subplot(2,3,mouseI)
        title([mice{mouseI} ' ' groups{mouseI}])
        for condI = 1:numConds
            cellsHere = cellSSI{mouseI}(:,dayPairs(dpI,1)) & cellSSI{mouseI}(:,dayPairs(dpI,2));
            
            coactivityA = coactivity{mouseI}{dayPairs(dpI,1),condI}(cellsHere,:);
            coactivityA = coactivityA(:,cellsHere);
            coactivityB = coactivity{mouseI}{dayPairs(dpI,2),condI}(cellsHere,:);
            coactivityB = coactivityB(:,cellsHere);
            
            coactivityDiff = coactivityA - coactivityB;
            %meanCoactivityDiff = mean(coactivityA,2) - mean(coactivityB,2);
            
            [f,x] = ecdf(y);
            plot(x,f,condColors(condI))
            hold on
        end
        ylabel('CDF')
        xlabel('Coactivity change')
    end
    suptitleSL(['Change in coactivity day pair ' num2str(dayPair(dpI,:))])
end
            
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

%% Single-neuron place field changes
for mouseI = 1:numMice
    TMapMeans{mouseI} = cellfun(@mean, allTMap{mouseI});
    TMapStds{mouseI} = cellfun(@std, allTMap{mouseI});
    sdM = 1.645; % 1 tailed t test
    TMapThresh{mouseI} = cellfun(@(x,y) x+y*sdM,TmapMeans{mouseI},TMapStds{mouseI});
    [TmapAboveThresh{mouseI}(:,:,1)] = cellfun(@(x,y) x>y,cellTMap{mouseI}(:,:,1),num2cell(TMapThresh{mouseI}),'UniformOutput',false);
    [TmapAboveThresh{mouseI}(:,:,2)] = cellfun(@(x,y) x>y,cellTMap{mouseI}(:,:,2),num2cell(TMapThresh{mouseI}),'UniformOutput',false);
    % Has to be >, >= lets 0 be above mean
    
    [outputs] = PlaceFieldRemapping(cellTMap{mouseI},TmapAboveThresh{mouseI},dayPairs);
end


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

% ECDF for single Cell corrs differences
4-7 - 4-8



%% Pop vector corr analysis (most basic)
cellsUseOption = 'activeEither';
corrType = 'Spearman';
numPerms = 1000;

condPairs = [1 1; 2 2; 3 3; 4 4]; numCondPairs = size(condPairs,1);
dayPairs = [1 2; 1 3; 2 3]; numDayPairs = size(dayPairs,1);

traitLogical = threshAndConsec;
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
        PVcorrsWrapperBasic(cellTMap_unsmoothed{mouseI},condPairs,dayPairs,traitLogical{mouseI},cellsUseOption,corrType);
    
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


%% Single cell remapping
numConds = length(cellTBT{1});

dayPairsForward = [1 2; 1 3; 2 3]; numDayPairs = size(dayPairsForward,1);
%Center of mass shift
allFiringCOM = cell(numMice,1);
oneEnvCOMchanges = cell(numDayPairs,1);
twoEnvCOMchanges = cell(numDayPairs,1);

for mouseI = 1:numMice
    allFiringCOM{mouseI} = TMapFiringCOM(cellTMap_unsmoothed{mouseI});
    
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
histBins = 0:1:10;
oneEnvCOMchangeProps = []; twoEnvCOMchangeProps = [];
oneEnvCOMchangeCDF = []; twoEnvCOMchangeCDF = [];
for dpI = 1:numDayPairs
    for condI = 1:numConds
        oneEnvCOMchangeProps{dpI}{condI} = histcounts(oneEnvCOMchanges{dpI}(:,condI),histBins)...
            / sum(~isnan(oneEnvCOMchanges{dpI}(:,condI)));
        twoEnvCOMchangeProps{dpI}{condI} = histcounts(twoEnvCOMchanges{dpI}(:,condI),histBins)...
            / sum(~isnan(twoEnvCOMchanges{dpI}(:,condI)));
        
        oneEnvCOMchangeCDF{dpI}{condI} = CDFfromHistcounts(oneEnvCOMchangeProps{dpI}{condI});
        twoEnvCOMchangeCDF{dpI}{condI} = CDFfromHistcounts(twoEnvCOMchangeProps{dpI}{condI});
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
    maxRates{mouseI} = cell2mat(cellfun(@max,cellTMap_unsmoothed{mouseI},'UniformOutput',false));
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
    
    meanRates{mouseI} = cell2mat(cellfun(@mean,cellTMap_unsmoothed{mouseI},'UniformOutput',false));
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
    [armPref{mouseI}] = CondFiringPreference(cellTMap_unsmoothed{mouseI});
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
    firedThisCond = trialReli{mouseI}>0;
    
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