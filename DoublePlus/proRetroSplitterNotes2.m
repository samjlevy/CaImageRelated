%proRetroSplitterNotes 2

% GLM to check pct splitters as a function of performance, diff in number
% of trials, total number of trials, other factors?

% North: 
armPairs = ...
{'n' 'w';...
 'n' 'e'};   
lapConds = [1 1];
binVs{1} = lgBinVertices{1}(lgDataBins.labels=='n',:);
binVs{2} = lgBinVertices{2}(lgDataBins.labels=='n',:);
% East:
armPairs = ...
{'n' 'e';...
 's' 'e'};
lapConds = [4 4];
binVs{1} = lgBinVertices{1}(lgDataBins.labels=='e',:);
binVs{2} = lgBinVertices{2}(lgDataBins.labels=='e',:);

for mouseI = 1:6
load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'),'tbtForSplitters')

numCells(mouseI) = size(tbtForSplitters(1).trialPSAbool{1},1);

sessNums = []; % Defaults to 1:9
[splitTBT,nLapsH] = SmallSplitterTBT(tbtForSplitters,armPairs,lapConds,sessNums);

condPairs = [1;2];
pfName = [];
[splitTMap,~] = RateMapsDoublePlusV2(splitTBT, binVs, 'vertices', condPairs, 0, 'zeroOut', pfName, false);

tEmpty = cellfun(@isempty,splitTMap);
[splitTMap(tEmpty)] = deal({zeros(nArmBins,1)});

binRateDiffs = cellfun(@(x,y) x-y,splitTMap(:,:,1),splitTMap(:,:,2),'UniformOutput',false);

preserveNumLaps = true;

nGreaterThan = cell(numCells(mouseI),9);
[nGreaterThan{:}] = deal([zeros(12,1)]);
nLessThan = cell(numCells(mouseI),9);
[nLessThan{:}] = deal([zeros(12,1)]);
tic
for shuffI = 1:1000
[shuffTBT] = ShuffleTBT2(splitTBT,[1 2],preserveNumLaps);

[shuffTMap,~] = RateMapsDoublePlusV2(shuffTBT, binVs, 'vertices', condPairs, 0, 'zeroOut', pfName, false);

tEmpty = cellfun(@isempty,shuffTMap);
[shuffTMap(tEmpty)] = deal({zeros(nArmBins,1)});

brdTwo = cellfun(@(x,y) x-y,shuffTMap(:,:,1),shuffTMap(:,:,2),'UniformOutput',false);

nGreaterThan = cellfun(@(x,y,z) z+(x>y),binRateDiffs,brdTwo,nGreaterThan,'UniformOutput',false);
nLessThan = cellfun(@(x,y,z) z+(x<y),binRateDiffs,brdTwo,nLessThan,'UniformOutput',false);
%{
if shuffI == 1
    binRateDiffsShuff = brdTwo;
else
    binRateDiffsShuff = cellfun(@(x,y) [x,y],binRateDiffsShuff,brdTwo,'UniformOutput',false);
end
   %} 
end
toc
save(fullfile(mainFolder,mice{mouseI},'splittersE.mat'),'splitTMap','binRateDiffs','nGreaterThan','nLessThan')
end

gThresh = 97;
lThresh = 4;
greaterThanA = cellfun(@(x,y) sum(x > y,2) > gThresh,binRateDiffs,binRateDiffsShuff,'UniformOutput',false);
lessThanA = cellfun(@(x,y) sum(x < y,2) > gThresh,binRateDiffs,binRateDiffsShuff,'UniformOutput',false);

greaterThan = cellfun(@sum, greaterThanA);
lessThan = cellfun(@sum, lessThanA);

binsSplitDir = greaterThan - lessThan;

% Sessions where we have at least 3 laps each turn direction
sessCheck = sum(nLapsH >= lapsActiveThresh,2)==2;

% On North: cells that split west (greater) in 1-3, become east (less) in
% 4-6, stay east/stop firing in 7-9
for cellI = 1:numCells(mouseI)
    

    
end

nLapsH = [];
sessCheck = [];

for mouseI = 1:6
     % %{
%load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'),'tbtForSplitters')

%spTBT{mouseI} = tbtForSplitters;
numCells(mouseI) = size(spTBT{mouseI}(4).trialPSAbool{1},1);


sessNums = []; % Defaults to 1:9
[~,nLapsH{mouseI}] = SmallSplitterTBT(spTBT{mouseI},armPairs,lapConds,sessNums);

sessCheck{mouseI} = sum(nLapsH{mouseI} >= lapsActiveThresh,2)==2;
%}
    spLoad = load(fullfile(mainFolder,mice{mouseI},'splittersE.mat'),'splitTMap','binRateDiffs','nGreaterThan','nLessThan');
    splitTMap = spLoad.splitTMap;
    binRateDiffs = spLoad.binRateDiffs;
    nGreaterThan = spLoad.nGreaterThan;
    nLessThan = spLoad.nLessThan;

    % How many splitters out of eligible cells? Eligible cells meet
    % dayUse on north arm, and are present on the sess check days
    dayUseCells = dayUse{mouseI}(:,:,4); % For north
    sessCheckCells = logical(repmat(sessCheck{mouseI}(:)',numCells(mouseI),1));
    
    eligibleCells = dayUseCells & sessCheckCells;
    nEligibleCells{mouseI} = sum(eligibleCells,1);
    
    %splitsW = eligibleCells & (cellfun(@(x) any(x>950),nGreaterThan)); 
    %splitsE = eligibleCells & (cellfun(@(x) any(x>950),nLessThan)); 
    
    %pctSplitsW{mouseI} = sum(splitsW,1) ./ sum(eligibleCells,1);
    %pctSplitsE{mouseI} = sum(splitsE,1) ./ sum(eligibleCells,1);
    %pctSplitsBoth{mouseI} = sum(splitsW & splitsE,1) ./ sum(eligibleCells,1);
    
    splitsN = eligibleCells & (cellfun(@(x) any(x>950),nGreaterThan)); 
    splitsS = eligibleCells & (cellfun(@(x) any(x>950),nLessThan)); 
    
    pctSplitsN{mouseI} = sum(splitsN,1) ./ sum(eligibleCells,1);
    pctSplitsS{mouseI} = sum(splitsS,1) ./ sum(eligibleCells,1);
    pctSplitsBoth{mouseI} = sum(splitsN & splitsS,1) ./ sum(eligibleCells,1);
end

% Figure out if this looks different for one
figure; 
subplot(1,3,1)
for mouseI = 1:numMice
    xp = find(~isnan(pctSplitsW{mouseI}));
    yp = pctSplitsW{mouseI}(xp);
    
    
    plot(xp,yp,'o','MarkerSize',8,...
        'Color',groupColors{groupNum(mouseI)},...
        'MarkerFaceColor',groupColors{groupNum(mouseI)})
    hold on 
    
    ylim([0 1]); ylabel('Prop. Eligible Cells')
    xlim([0.5 9.5]); xlabel('Session Num.')
end
title('Pct Split West')
subplot(1,3,2)
for mouseI = 1:numMice
    xp = find(~isnan(pctSplitsE{mouseI}));
    yp = pctSplitsE{mouseI}(xp);
    
    
    plot(xp,yp,'o','MarkerSize',8,...
        'Color',groupColors{groupNum(mouseI)},...
        'MarkerFaceColor',groupColors{groupNum(mouseI)})
    hold on 
    
    ylim([0 1]); ylabel('Prop. Eligible Cells')
    xlim([0.5 9.5]); xlabel('Session Num.')
end
title('Pct Split East')
subplot(1,3,3)
for mouseI = 1:numMice
    xp = find(~isnan(pctSplitsBoth{mouseI}));
    yp = pctSplitsBoth{mouseI}(xp);
    
    
    plot(xp,yp,'o','MarkerSize',8,...
        'Color',groupColors{groupNum(mouseI)},...
        'MarkerFaceColor',groupColors{groupNum(mouseI)})
    hold on 
    
    ylim([0 1]); ylabel('Prop. Eligible Cells')
    xlim([0.5 9.5]); xlabel('Session Num.')
end
title('Pct Split Both')
suptitleSL('North Arm splitters')

figure; 
subplot(1,3,1)
for mouseI = 1:numMice
    xp = find(~isnan(pctSplitsN{mouseI}));
    yp = pctSplitsN{mouseI}(xp);
    
    
    plot(xp,yp,'o','MarkerSize',8,...
        'Color',groupColors{groupNum(mouseI)},...
        'MarkerFaceColor',groupColors{groupNum(mouseI)})
    hold on 
    
    ylim([0 1]); ylabel('Prop. Eligible Cells')
    xlim([0.5 9.5]); xlabel('Session Num.')
end
title('Pct Split North')
subplot(1,3,2)
for mouseI = 1:numMice
    xp = find(~isnan(pctSplitsS{mouseI}));
    yp = pctSplitsS{mouseI}(xp);
    
    
    plot(xp,yp,'o','MarkerSize',8,...
        'Color',groupColors{groupNum(mouseI)},...
        'MarkerFaceColor',groupColors{groupNum(mouseI)})
    hold on 
    
    ylim([0 1]); ylabel('Prop. Eligible Cells')
    xlim([0.5 9.5]); xlabel('Session Num.')
end
title('Pct Split South')
subplot(1,3,3)
for mouseI = 1:numMice
    xp = find(~isnan(pctSplitsBoth{mouseI}));
    yp = pctSplitsBoth{mouseI}(xp);
    
    
    plot(xp,yp,'o','MarkerSize',8,...
        'Color',groupColors{groupNum(mouseI)},...
        'MarkerFaceColor',groupColors{groupNum(mouseI)})
    hold on 
    
    ylim([0 1]); ylabel('Prop. Eligible Cells')
    xlim([0.5 9.5]); xlabel('Session Num.')
end
title('Pct Split Both')
suptitleSL('East Arm splitters')


cellI = 46;
sessI = 3;

for sessI = 1:9
    
lapsA = splitTBT(1).sourceLap(splitTBT(1).sessID==sessI); %These are the laps in tbtForSpliters
lapsAA = tbtForSplitters(1).sourceLap(lapsA);
lapsB = splitTBT(2).sourceLap(splitTBT(2).sessID==sessI); %These are the laps in tbtForSpliters
lapsBB = tbtForSplitters(1).sourceLap(lapsB); %These are laps in trialbytrialAll

figure;
subplot(1,2,1);
xpos = [trialbytrialAll(1).trialsX{lapsAA}];
ypos = [trialbytrialAll(1).trialsY{lapsAA}];
if any(xpos)
allSpikes = [trialbytrialAll(1).trialPSAbool{lapsAA}];
thisSpikes = allSpikes(cellI,:);
plot(xpos,ypos,'.k')
hold on
plot(xpos(thisSpikes),ypos(thisSpikes),'.r')
end

subplot(1,2,2);
xpos = [trialbytrialAll(1).trialsX{lapsBB}];
ypos = [trialbytrialAll(1).trialsY{lapsBB}];
if any(xpos)
allSpikes = [trialbytrialAll(1).trialPSAbool{lapsBB}];
thisSpikes = allSpikes(cellI,:);
plot(xpos,ypos,'.k')
hold on
plot(xpos(thisSpikes),ypos(thisSpikes),'.r')
end
suptitleSL(['Mouse ' num2str(mouseI) ', cell ' num2str(cellI) ', sess ' num2str(sessI)])

end

    
