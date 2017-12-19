%work171107
%This is to get all my working PVshuffled and stuff all in one place
load('trialbytrial.mat')
load('realDays.mat')
xmin = 25.5;
xmax = 56;
numBins = 10; numBins = 8
cmperbin = (xmax-xmin)/numBins;
xlims = [xmin xmax];
numSess = length(unique(trialbytrial(1).sessID));
minspeed = 0;
zeronans = 1;
posThresh = 3;

%numShuffles = 25;

lapPctThresh = 0.25;
consecLapThresh = 3;
[dayAllUse, threshAndConsec] = GetUseCells(trialbytrial, lapPctThresh, consecLapThresh);
[Conds] = GetTBTconds(trialbytrial);

%load('PFsLin.mat')
[~, RunOccMap, ~, TMap_unsmoothed, ~, TMap_gauss] =...
    PFsLinTrialbyTrial(trialbytrial,xlims, cmperbin, minspeed, 0, [], sortedSessionInds);

%% Only cells above activity threshold

[StudyCorrs, TestCorrs, LeftCorrs, RightCorrs, numCells] =...
    PVcorrAllCond(TMap_gauss, RunOccMap, posThresh, threshAndConsec, Conds);

[StudyCorrs, TestCorrs, LeftCorrs, RightCorrs, numCells] =...
PVcorrAllCondConfusion(TMap_gauss, RunOccMap, posThresh, threshAndConsec, Conds);
%{
bbb = GenerateFigsAndHandles(4,'subplot');
PlotPVCorrsDays(StudyCorrs, bbb(1).pl, 'Left vs. Right: Study')
PlotPVCorrsDays(TestCorrs, bbb(2).pl, 'Left vs. Right: Test')
PlotPVCorrsDays(LeftCorrs, bbb(3).pl, 'Study vs. Test: Left')
PlotPVCorrsDays(RightCorrs, bbb(4).pl, 'Study vs. Test: Right')
suptitle('Original Corrs, Colored by Day Order')
    
[accuracy] = sessionAccuracy(allfiles);
[colorOrder,~] = tiedrank(accuracy);
ccc = GenerateFigsAndHandles(4,'subplot');
PlotPVCorrsDays(StudyCorrs, ccc(1).pl, 'Left vs. Right: Study',colorOrder)
PlotPVCorrsDays(TestCorrs, ccc(2).pl, 'Left vs. Right: Test',colorOrder)
PlotPVCorrsDays(LeftCorrs, ccc(3).pl, 'Study vs. Test: Left',colorOrder)
PlotPVCorrsDays(RightCorrs, ccc(4).pl, 'Study vs. Test: Right',colorOrder)
suptitle('Original Corrs, Colored by accuracy rank')
%}

cellsPresent = sortedSessionInds > 0;
[bigCorrs, cells, dayPairs, condPairs ] =...
    PVcorrsAllCorrsAllCondsAllDays(TMap_gauss,RunOccMap,posThresh,threshAndConsec,cellsPresent,[]);
[corrMeans, corrStd, corrSEM] = processPVacacad(bigCorrs, cells, dayPairs, condPairs,realDays);

meanCurves = cell2mat(cellfun(@(x) mean(x,2)',corrMeans,'UniformOutput',false));
%1:4 is self, 5:6 is svt, 7:8 is lvr
curvesUse = [1:4 6 9 5 10];
cl = {'b' 'b' 'b' 'b' 'g' 'g' 'r' 'r'};
meanCurves = meanCurves(curvesUse,:)'; cm = {'b' 'g' 'r'};
compCurves = [mean(meanCurves(:,1:4),2) mean(meanCurves(:,5:6),2) mean(meanCurves(:,7:8),2)];

dayDiffs = abs(diff(dayPairs,1,2));
apart = unique(dayDiffs);
figure; for aa = 1:length(curvesUse); hold on; plot(apart,meanCurves(:,aa),'o','Color',cl{aa}); end
for bb = 1:size(compCurves,2); hold on; plot(apart,compCurves(:,bb),'Color',cm{bb}); end
title('Mean Corr by Days Apart, blue self, green ST, red LR')


%% Include silent cells
oneCondThresh = sum(threshAndConsec,3);
silentThreshConsec = repmat(oneCondThresh>0,1,1,4);

[StudyCorrs, TestCorrs, LeftCorrs, RightCorrs, numCells] =...
    PVcorrAllCond(TMap_gauss, RunOccMap, posThresh, silentThreshConsec, Conds);

%{
bbb = GenerateFigsAndHandles(4,'subplot');
PlotPVCorrsDays(StudyCorrs, bbb(1).pl, 'Left vs. Right: Study')
PlotPVCorrsDays(TestCorrs, bbb(2).pl, 'Left vs. Right: Test')
PlotPVCorrsDays(LeftCorrs, bbb(3).pl, 'Study vs. Test: Left')
PlotPVCorrsDays(RightCorrs, bbb(4).pl, 'Study vs. Test: Right')
suptitle('Original Corrs, including silent cells Colored by Day Order')
    
%}

silentCellsPresent = ones(size(sortedSessionInds));
%cellsPresent = sortedSessionInds > 0;
[bigCorrs, cells, dayPairs, condPairs ] =...
    PVcorrsAllCorrsAllCondsAllDays(TMap_gauss,RunOccMap,posThresh,silentThreshConsec,silentCellsPresent,[]);
[corrMeans, corrStd, corrSEM] = processPVacacad(bigCorrs, cells, dayPairs, condPairs,realDays);

meanCurves = cell2mat(cellfun(@(x) mean(x,2)',corrMeans,'UniformOutput',false));
%1:4 is self, 5:6 is svt, 7:8 is lvr
curvesUse = [1:4 6 9 5 10];
cl = {'b' 'b' 'b' 'b' 'g' 'g' 'r' 'r'}; cm = {'b' 'g' 'r'};
meanCurves = meanCurves(curvesUse,:)';
compCurves = [mean(meanCurves(:,1:4),2) mean(meanCurves(:,5:6),2) mean(meanCurves(:,7:8),2)];

dayDiffs = abs(diff(realDays(dayPairs),1,2));
apart = unique(dayDiffs);
figure; for aa = 1:size(meanCurves,2); hold on; plot(apart,meanCurves(:,aa),'o','Color',cl{aa}); end
for bb = 1:size(compCurves,2); hold on; plot(apart,compCurves(:,bb),'Color',cm{bb}); end
title('Mean Corr by Days Apart including silent cells, blue self, green ST, red LR')

%% Stats maybe?
groups = [1 1 1 1 2 2 3 3];
groupAll = repmat(groups,size(meanCurves,1),1);
apartAll = repmat(apart,1,size(meanCurves,2)); 

condsCompareNow = [2 3];
useCols = logical(sum(groups==condsCompareNow',1));
daysUse = (2:15);

groupID = groupAll(daysUse,useCols); groupID = groupID(:);
apartID = apartAll(daysUse,useCols); apartID = apartID(:);
data = meanCurves(daysUse,useCols); data = data(:);

[h,atab,ctab,stats] = aoctool(apartID, data, groupID)


%{
%Results:
self vs SvT: 
    group:          F = 15.43   p = 0.0002
    days:           F = 69.31   p = 0    
    interaction:    F = 0.71    p = 0.4
self vs LvR:
    group:          F = 316.63   p = 0
    days:           F = 48.35   p = 0    
    interaction:    F = 2.59    p = 0.1112
SvT vs LvR:
    group:          F = 316.63   p = 0
    days:           F = 48.35   p = 0    
    interaction:    F = 2.59    p = 0.1112

%}





[~, RunOccMapSplit, ~, TMap_unsmoothedSplit, ~, TMap_gaussSplit, LapIDs, Conditions]=...    
        PFsLinTrialbyTrialSplit(trialbytrial,xlims, cmperbin, minspeed, 0, [],sortedSessionInds, 1);






