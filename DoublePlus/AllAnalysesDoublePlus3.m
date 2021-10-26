%AllAnalysesDoublePlus

%mainFolder = 'G:\DoublePlus';
%mainFolder = 'C:\Users\Sam\Desktop\DoublePlusFinalData';
mainFolder = 'E:\DoublePlus';
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
sessDays(strcmpi(sessTypes,'Turn')) = 1; sessDays(strcmpi(sessTypes,'Place')) = 2;

nArmBins = 14;
lgAnchor = load(fullfile(mainFolder,'mainPosAnchor.mat'));
[lgDataBins,lgPlotBins] = SmallPlusBounds(lgAnchor.posAnchorIdeal,nArmBins,nArmBins-2);
lgBinVertices = {lgDataBins.X, lgDataBins.Y};
binMidsX = mean(lgDataBins.X,2);
binMidsY = mean(lgDataBins.Y,2);
allMazeBound.Y = [lgDataBins.bounds.north.Y; lgDataBins.bounds.east.Y; lgDataBins.bounds.south.Y; flipud(lgDataBins.bounds.west.Y)];
allMazeBound.X = [flipud(lgDataBins.bounds.north.X); lgDataBins.bounds.east.X; lgDataBins.bounds.south.X; lgDataBins.bounds.west.X];
numBins = size(lgDataBins.X,1);
%{
figure; plot(allMazeBound.X,allMazeBound.Y)
hold on
plot(allMazeBound.X(1),allMazeBound.Y(1),'*r')
plot(allMazeBound.X(end),allMazeBound.Y(end),'og')
%}

% Validate bins
%{
startsB = cell(2,1); [startsB{:}] = deal(zeros(1,numBins));
stopsB = cell(2,1); [stopsB{:}] = deal(zeros(1,numBins));
stopsBt = cell(2,1); [stopsBt{:}] = deal(zeros(1,numBins));
stopsBp = cell(2,1); [stopsBp{:}] = deal(zeros(1,numBins));
for mouseI = 1:numMice 
    [startHist{mouseI},stopHist{mouseI}] = GetStartStopCounts(cellTBT{mouseI},lgDataBins); 
    %if mouseI == 1
    %    startHist{mouseI}{1} = [startHist{mouseI}{1}
    startsB{1} = [startsB{1} + sum(startHist{mouseI}{1},1)];
    startsB{2} = [startsB{2} + sum(startHist{mouseI}{2},1)];
    stopsB{1} = [stopsB{1} + sum(stopHist{mouseI}{1},1)];
    stopsB{2} = [stopsB{2} + sum(stopHist{mouseI}{2},1)];
    
% Divide into turn and place
    stopsBt{1} = [stopsBt{1} + sum(stopHist{mouseI}{1}(sessDays==1,:),1)];
    stopsBt{2} = [stopsBt{2} + sum(stopHist{mouseI}{2}(sessDays==1,:),1)];
    stopsBp{1} = [stopsBp{1} + sum(stopHist{mouseI}{1}(sessDays==2,:),1)];
    stopsBp{2} = [stopsBp{2} + sum(stopHist{mouseI}{2}(sessDays==2,:),1)];
    
    badP = stopHist{mouseI}{1}(sessDays==2,29);
    if any(badP)
        disp(['Found it, mouse ' num2str(mouseI) ', place day ' num2str(find(badP))])
    end
end
%}
[binOrderIndex] = SetBinOrder(lgDataBins,binLabelsUse,[]);
binsOrdered.X = cellfun(@(x) lgDataBins.X(x,:),binOrderIndex,'UniformOutput',false);
binsOrdered.Y = cellfun(@(x) lgDataBins.Y(x,:),binOrderIndex,'UniformOutput',false);
for condI = 1:2
    %for ll = 1:length(binLabelsUse{1,condI})
    turnBinsUse{condI} = logical(sum(lgDataBins.labels == binLabelsUse{1,condI},2));
    placeBinsUse{condI} = logical(sum(lgDataBins.labels == binLabelsUse{2,condI},2));
end
% Each Arm Bins
binOrderArmsLabels = {'n','w','s','e'};
[binOrderArms] = SetBinOrder(lgDataBins,binOrderArmsLabels,[]);
binsOrderedArms.X = cellfun(@(x) lgDataBins.X(x,:),binOrderArms,'UniformOutput',false);
binsOrderedArms.Y = cellfun(@(x) lgDataBins.Y(x,:),binOrderArms,'UniformOutput',false);
% n w s e
eachArmBoundsT{1}.Y = lgDataBins.bounds.north.Y; eachArmBoundsT{2}.Y = lgDataBins.bounds.west.Y;
eachArmBoundsT{3}.Y = lgDataBins.bounds.south.Y; eachArmBoundsT{4}.Y = lgDataBins.bounds.east.Y;
eachArmBoundsT{1}.X = lgDataBins.bounds.north.X; eachArmBoundsT{2}.X = lgDataBins.bounds.west.X;
eachArmBoundsT{3}.X = lgDataBins.bounds.south.X; eachArmBoundsT{4}.X = lgDataBins.bounds.east.X;
% n e s e
eachArmBoundsP{1}.Y = lgDataBins.bounds.north.Y; eachArmBoundsP{2}.Y = lgDataBins.bounds.east.Y;
eachArmBoundsP{3}.Y = lgDataBins.bounds.south.Y; eachArmBoundsP{4}.Y = lgDataBins.bounds.east.Y;
eachArmBoundsP{1}.X = lgDataBins.bounds.north.X; eachArmBoundsP{2}.X = lgDataBins.bounds.east.X;
eachArmBoundsP{3}.X = lgDataBins.bounds.south.X; eachArmBoundsP{4}.X = lgDataBins.bounds.east.X;
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

    %{
    catch
        disp(['Tiralbytrial each not found for mouse ' num2str(mouseI)])
        load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'),'trialbytrialAll')
        
        % split up tbt to four conditions, each arm
        [trialbytrialAllEach] = BreakUpTrialbyTrial(trialbytrialAll,[1;1;2;2;],eachArmBoundsT,'firstlast');
        [buTBTb] = BreakUpTrialbyTrial(trialbytrialAll,[1;1;2;2;],eachArmBoundsP,'firstlast');
        for condI = 1:4
            for sessI =4:6
                sessTrials = trialbytrialAllEach(condI).sessID == sessI;
                trialbytrialAllEach(condI).trialsX(sessTrials,1) = buTBTb(condI).trialsX(sessTrials,1);
                trialbytrialAllEach(condI).trialsY(sessTrials,1) = buTBTb(condI).trialsY(sessTrials,1);
                trialbytrialAllEach(condI).trialPSAbool(sessTrials,1) = buTBTb(condI).trialPSAbool(sessTrials,1);
                trialbytrialAllEach(condI).trialDFDTtrace(sessTrials,1) = buTBTb(condI).trialDFDTtrace(sessTrials,1);
                trialbytrialAllEach(condI).trialRawTrace(sessTrials,1) = buTBTb(condI).trialRawTrace(sessTrials,1);
            end
        end
        save(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'),'trialbytrialAllEach','-append')
    end
    
    % split up tbt to four conditions, each arm
    [trialbytrialEach] = BreakUpTrialbyTrial(trialbytrial,[1;1;2;2;],eachArmBoundsT,'firstlast');
    [buTBTb] = BreakUpTrialbyTrial(trialbytrial,[1;1;2;2;],eachArmBoundsP,'firstlast');
    for condI = 1:4
        for sessI =4:6
            sessTrials = trialbytrialEach(condI).sessID == sessI;
            trialbytrialEach(condI).trialsX(sessTrials,1) = buTBTb(condI).trialsX(sessTrials,1);
            trialbytrialEach(condI).trialsY(sessTrials,1) = buTBTb(condI).trialsY(sessTrials,1);
            trialbytrialEach(condI).trialPSAbool(sessTrials,1) = buTBTb(condI).trialPSAbool(sessTrials,1);
            trialbytrialEach(condI).trialDFDTtrace(sessTrials,1) = buTBTb(condI).trialDFDTtrace(sessTrials,1);
            trialbytrialEach(condI).trialRawTrace(sessTrials,1) = buTBTb(condI).trialRawTrace(sessTrials,1);
        end
    end
    %}
    cellTBT{mouseI} = trialbytrial;
    cellSSI{mouseI} = sortedSessionInds;
    
    cellAllFiles{mouseI} = allfiles;
    try cellRealDays{mouseI} = realDays; catch cellRealDays{mouseI} = realdays; end
    
    % split up tbt to four conditions, each arm
    [trialbytrialEach] = BreakUpTrialbyTrial(trialbytrial,[1;1;2;2;],eachArmBoundsT,'firstlast');
    [buTBTb] = BreakUpTrialbyTrial(trialbytrial,[1;1;2;2;],eachArmBoundsP,'firstlast');
    for condI = 1:4
        for sessI =4:6
            sessTrials = trialbytrialEach(condI).sessID == sessI;
            trialbytrialEach(condI).trialsX(sessTrials,1) = buTBTb(condI).trialsX(sessTrials,1);
            trialbytrialEach(condI).trialsY(sessTrials,1) = buTBTb(condI).trialsY(sessTrials,1);
            trialbytrialEach(condI).trialPSAbool(sessTrials,1) = buTBTb(condI).trialPSAbool(sessTrials,1);
            trialbytrialEach(condI).trialDFDTtrace(sessTrials,1) = buTBTb(condI).trialDFDTtrace(sessTrials,1);
            trialbytrialEach(condI).trialRawTrace(sessTrials,1) = buTBTb(condI).trialRawTrace(sessTrials,1);
        end
    end
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
    %if exist(reliFileName,'file')==0
        [dayUse,trialReli,threshAndConsec,numTrials] = TrialReliability2(cellTBT{mouseI},allMazeBound,lapPctThresh, consecLapThresh,[1;2]);
        [dayUseAll,trialReliAll,threshAndConsecAll,numTrialsAll] = TrialReliability2(cellTBT{mouseI},allMazeBound,lapPctThresh, consecLapThresh,[1 2]);
        
        [dayUseEach,trialReliEach,threshAndConsecEach,numTrialsEach] = TrialReliability2(cellTBT{mouseI},eachArmBoundsT,lapPctThresh, consecLapThresh,[1;1;2;2]);
        [dayUseE,trialReliE,threshAndConsecE,numTrialsE] = TrialReliability2(cellTBT{mouseI},eachArmBoundsP,lapPctThresh, consecLapThresh,[1;1;2;2]);
        dayUseEach(:,4:6,:) = dayUseE(:,4:6,:); trialReliEach(:,4:6,:) = trialReliE(:,4:6,:); threshAndConsecEach(:,4:6,:) = threshAndConsecE(:,4:6,:); numTrialsEach(:,4:6,:) = numTrialsE(:,4:6,:);

        save(reliFileName,'dayUse','trialReli','threshAndConsec','numTrials','dayUseAll','trialReliAll','threshAndConsecAll','numTrialsAll','dayUseEach','trialReliEach','threshAndConsecEach','numTrialsEach')
   % end

end
clear dayUse threshAndConsec trialReli dayUseAll threshAndConsecAll trialReliAll dayUseEach trialReliEach threshAndConsecEach numTrialsEach%dayUse = cell(1,numMice); threshAndConsec = cell(1,numMice);
nTrialsThresh = 1;
for mouseI = 1:numMice
    reliFileName = fullfile(mainFolder,mice{mouseI},'trialReli.mat');
    reliLoad = load(reliFileName);
    
    dayUse{mouseI} = reliLoad.dayUse;
    trialReli{mouseI} = reliLoad.trialReli; 
    trialReli{mouseI} = trialReli{mouseI}.*(reliLoad.numTrials>nTrialsThresh);
    threshAndConsec{mouseI} = reliLoad.threshAndConsec;
    dayUseAll{mouseI} = reliLoad.dayUseAll;
    trialReliAll{mouseI} = reliLoad.trialReliAll;
    trialReliAll{mouseI} = trialReli{mouseI}.*(reliLoad.numTrialsAll>nTrialsThresh);
    threshAndConsecAll{mouseI} = reliLoad.threshAndConsecAll;
    dayUseEach{mouseI} = reliLoad.dayUseEach;
    trialReliEach{mouseI} = reliLoad.trialReliEach; 
    trialReliEach{mouseI} = trialReliEach{mouseI}.*(reliLoad.numTrialsEach>nTrialsThresh);
    threshAndConsecEach{mouseI} = reliLoad.threshAndConsecEach;
  
    disp(['Mouse ' num2str(mouseI) ' completed'])
end
disp('done reliability')


disp('checking place fields')
condPairs = [1; 2];
numCondPairs = size(condPairs,1);
for mouseI = 1:numMice
    pfName= fullfile(mainFolder,mice{mouseI},'PFsLin.mat');
    %if exist(pfName,'file')==0
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
        %{
        TMap_unsmoothed(:,[1:3 7:9],1) = cellfun(@(x) x(binOrderIndex{1}),TMap_unsmoothed(:,[1:3 7:9],1),'UniformOutput',false);
        TMap_unsmoothed(:,[1:3 7:9],2) = cellfun(@(x) x(binOrderIndex{3}),TMap_unsmoothed(:,[1:3 7:9],2),'UniformOutput',false);
        TMap_unsmoothed(:,[4:6],1) = cellfun(@(x) x(binOrderIndex{2}),TMap_unsmoothed(:,[4:6],1),'UniformOutput',false);
        TMap_unsmoothed(:,[4:6],2) = cellfun(@(x) x(binOrderIndex{4}),TMap_unsmoothed(:,[4:6],2),'UniformOutput',false);
        %}
        save(pfName,'TMap_unsmoothed','binLabels','binVertices','-append')
    %end
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


