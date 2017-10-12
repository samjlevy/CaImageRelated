
%(base_path)

%cd(base_path)
load('trialbytrial.mat')
%{
for aa = [1 3 4]
MinX(aa) = mean(cell2mat(cellfun(@min,trialbytrial(aa).trialsX,'UniformOutput',false)));
minStd(aa) = std(cellfun(@min,trialbytrial(aa).trialsX));
MaxX(aa) = mean(cellfun(@max,trialbytrial(aa).trialsX));
maxStd(aa) = std(cellfun(@max,trialbytrial(aa).trialsX));
end
MinX - minStd
MaxX + maxStd
%}
xmin = 25.5;
xmax = 56;
numBins = 10;
cmperbin = (xmax-xmin)/numBins;
xlims = [xmin xmax];

numShuffles = 100;
%xlims = [25 60]
%cmperbin = 2.5
minspeed = 0;
zeronans = 1;
posThresh = 3;

lapPctThresh = 0.3;
consecLapThresh = 3;
[dayAllUse, threshAndConsec] = GetUseCells(trialbytrial, lapPctThresh, consecLapThresh);

%Make original   
[~, RunOccMap, ~, ~, ~, TMap_gauss] =...
PFsLinTrialbyTrialCONDpool(trialbytrial,xlims, cmperbin, minspeed, 0, []);

[TMap_zscore] = ZScoreLinPFs(TMap_gauss, zeronans);   

%PV corrs for original
[StudyTestCorrs, LeftRightCorrs] = PVcorrDimPooled(TMap_zscore, RunOccMap, posThresh, dayAllUse);

%Days, pooled
%Get some shuffled distributions for Days
STcorrsShuff = nan(11,10,100);
LRcorrsShuff = nan(11,10,100);
for shuffI = 1:numShuffles
    shuffledTBT = []; ROMforShuff = []; TMGforShuff = []; TMap_zscoreShuff = [];
    
    shuffledTBT = ShuffleTrialsAcrossDays(trialbytrial);
    
    %[~, ROMforShuff{shuffI}, ~, ~, ~, TMGforShuff{shuffI}] =...
    %PFsLinTrialbyTrial(trialbytrial,xlims, cmperbin, minspeed, 0, []);
    [~, ROMforShuff, ~, ~, ~, TMGforShuff] =...
    PFsLinTrialbyTrialCONDpool(shuffledTBT,xlims, cmperbin, minspeed, 0, []);
    
    [TMap_zscoreShuff] = ZScoreLinPFs(TMGforShuff, zeronans);
    
    [dayUseShuff] = GetUseCells(trialbytrial, lapPctThresh, consecLapThresh);
    %PV corrs for shuffle
    [STcorrsShuff(:,:,shuffI), LRcorrsShuff(:,:,shuffI)] =...
        PVcorrDimPooled(TMap_zscoreShuff, ROMforShuff, posThresh, dayUseShuff);
    %delete old TMap stuff (memory space)
    shuffI
end

%Statistical comparison



%Conditions, unpooled

[~, RunOccMap, ~, ~, ~, TMap_gauss] =...
    PFsLinTrialbyTrial(trialbytrial,xlims, cmperbin, minspeed, 0, []);
%
shuffledTBT = ShuffleTrialsAcrossConditions(trialbytrial,'leftright')
shuffledTBT = ShuffleTrialsAcrossConditions(trialbytrial,'studytest')

%Separate Conditions corrs
[~, RunOccMap, ~, ~, ~, TMap_gauss] =...
    PFsLinTrialbyTrial(trialbytrial,xlims, cmperbin, minspeed, 0, []);

%[~, RunOccMap, ~, ~, ~, TMap_gauss, ~] =...
[OccMapSplit, RunOccMapSplit, xBinSplit, TMap_unsmoothedSplit, TCountsSplit, TMap_gaussSplit, LapIDs, Conditions]=...    
    PFsLinTrialbyTrialSplit(trialbytrial,xlims, cmperbin, minspeed, 1, 'PFsLinSplit.mat', 0);

[StudyCorrs, TestCorrs, LeftCorrs, RightCorrs, numCells] =...
    PVcorrAllCond(TMap_gauss, RunOccMap, posThresh, threshAndConsec, Conds);
%{
studyFig=figure; PlotPVCorrsDays(StudyCorrs, studyFig, 'Study LvR')
testFig=figure; PlotPVCorrsDays(TestCorrs, testFig, 'Test LvR')
leftFig=figure; PlotPVCorrsDays(LeftCorrs, leftFig, 'Left SvT')
rightFig=figure; PlotPVCorrsDays(RightCorrs, rightFig, 'Right SvT')
%}
[StudyLCorrs, StudyRCorrs, TestLCorrs, TestRCorrs, numCells2] =...
    PVcorrAllCondSelf(TMap_gaussSplit, RunOccMap, posThresh, threshAndConsec);
%{
studyLFig=figure; PlotPVCorrsDays(StudyLCorrs, studyLFig, 'Study L self')
studyRFig=figure; PlotPVCorrsDays(StudyRCorrs, studyRFig, 'Study R self')
testLFig=figure; PlotPVCorrsDays(TestLCorrs, testLFig, 'Test L self')
testRFig=figure; PlotPVCorrsDays(TestRCorrs, testRFig, 'Test R self')
%}
