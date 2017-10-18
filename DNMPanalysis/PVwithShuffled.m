
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

numSess = length(unique(trialbytrial(1).sessID));
%xlims = [25 60]
%cmperbin = 2.5
minspeed = 0;
zeronans = 1;
posThresh = 3;

numShuffles = 25;

lapPctThresh = 0.25;
consecLapThresh = 3;
[dayAllUse, threshAndConsec] = GetUseCells(trialbytrial, lapPctThresh, consecLapThresh);
[Conds] = GetTBTconds(trialbytrial);

%Make original   
[~, RunOccMap, ~, ~, ~, TMap_gauss] =...
PFsLinTrialbyTrialCONDpool(trialbytrial,xlims, cmperbin, minspeed, 0, []);

%[TMap_zscore] = ZScoreLinPFs(TMap_gauss, zeronans);   

%PV corrs for original
[StudyTestCorrs, LeftRightCorrs] = PVcorrDimPooled(TMap_gauss, RunOccMap, posThresh, dayAllUse);

%Days, pooled
%% Get some shuffled distributions for Days


sdStudyCorrs = nan(11,10,numShuffles); sdTestCorrs = nan(11,10,numShuffles);
sdLeftCorrs = nan(11,10,numShuffles); sdRightCorrs = nan(11,10,numShuffles);
for shuffI = 1:numShuffles
    shuffledTBT = []; ROMforShuff = []; TMGforShuff = []; TMap_zscoreShuff = [];
    
    shuffledTBT = ShuffleTrialsAcrossDays(trialbytrial);
    
    [~, ROMforShuff, ~, ~, ~, TMGforShuff] =...
    PFsLinTrialbyTrial(shuffledTBT,xlims, cmperbin, minspeed, 0, []);
    %[~, ROMforShuff, ~, ~, ~, TMGforShuff] =...
    %PFsLinTrialbyTrialCONDpool(shuffledTBT,xlims, cmperbin, minspeed, 0, []);
    
    %[TMap_zscoreShuff] = ZScoreLinPFs(TMGforShuff, zeronans);
    
    [dayUseShuff,threshAndConShuff] = GetUseCells(shuffledTBT, lapPctThresh, consecLapThresh);
    %PV corrs for shuffle
    %[STcorrsShuff(:,:,shuffI), LRcorrsShuff(:,:,shuffI)] =...
    %    PVcorrDimPooled(TMap_zscoreShuff, RunOccMap, posThresh, threshAndConShuff);
    [sdStudyCorrs(:,:,shuffI), sdTestCorrs(:,:,shuffI),...
        sdLeftCorrs(:,:,shuffI), sdRightCorrs(:,:,shuffI), sdnumCellslr(shuffI)] =...
        PVcorrAllCond(TMGforShuff, RunOccMap, posThresh, threshAndConShuff, Conds);
    %delete old TMap stuff (memory space)
    disp(['shuffle' num2str(shuffI)])
end


ccc = GenerateFigsAndHandles(4,'subplot');
PlotPVCorrsDays(mean(sdStudyCorrs,3), ccc(1).pl, 'Study lr shuffDays')
PlotPVCorrsDays(mean(sdTestCorrs,3), ccc(2).pl, 'Test lr shuffDays')
PlotPVCorrsDays(mean(sdLeftCorrs,3), ccc(3).pl, 'Left st shuffDays')
PlotPVCorrsDays(mean(sdRightCorrs,3), ccc(4).pl, 'Right st shuffDays')
%Statistical comparison



%% Conditions, unpooled
tic
[~, RunOccMap, ~, ~, ~, TMap_gauss] =...
    PFsLinTrialbyTrial(trialbytrial,xlims, cmperbin, minspeed, 0, [], []);
toc
tic
[~, RunOccMap, ~, ~, ~, TMap_gauss] =...
    PFsLinTrialbyTrial(trialbytrial,xlims, cmperbin, minspeed, 0, [], sortedSessionInds);
toc
[~, threshAndConsec] = GetUseCells(trialbytrial, lapPctThresh, consecLapThresh);
[StudyCorrs, TestCorrs, LeftCorrs, RightCorrs, numCells] =...
    PVcorrAllCond(TMap_gauss, RunOccMap, posThresh, threshAndConsec, Conds);
bbb = GenerateFigsAndHandles(4,'subplot');
PlotPVCorrsDays(StudyCorrs, bbb(1).pl, 'Study lr')
PlotPVCorrsDays(TestCorrs, bbb(2).pl, 'Test lr')
PlotPVCorrsDays(LeftCorrs, bbb(3).pl, 'Left st')
PlotPVCorrsDays(RightCorrs, bbb(4).pl, 'Right st')
%% Shuffle across 1 dimension
tempDir = fullfile(cd,'tempPFs');
shStudyCorrs = nan(11,10,numShuffles); shTestCorrs = nan(11,10,numShuffles);
for shuffI = 1:numShuffles
    try
    shuffledTBTlr = [];

    %Left/Right shuffle
    shuffledTBTlr = ShuffleTrialsAcrossConditions(trialbytrial,'leftright');
    [~, threshAndConsecShufflr] = GetUseCells(shuffledTBTlr, lapPctThresh, consecLapThresh);
    [~, RunOccMapShufflr, ~, ~, ~, TMap_gaussShufflr] =...
    PFsLinTrialbyTrial(shuffledTBTlr,xlims, cmperbin, minspeed, 0, []);
    [shStudyCorrs(:,:,shuffI), shTestCorrs(:,:,shuffI), ~, ~, shnumCellslr(shuffI)] =...
    PVcorrAllCond(TMap_gaussShufflr, RunOccMap, posThresh, threshAndConsecShufflr, Conds);
    shuffI
    catch
        keyboard
    end
end    
%saveLR = fullfile(tempDir,['shuffPFsLR' num2str(shuffI) '.mat'])
    %save(saveLR,'
    
shLeftCorrs = nan(11,10,numShuffles); shRightCorrs = nan(11,10,numShuffles);
for shuffI = 1:numShuffles
    shuffledTBTst = [];
    try
    %Study test shuffle
    shuffledTBTst = ShuffleTrialsAcrossConditions(trialbytrial,'studytest');
    [~, threshAndConsecShuffst] = GetUseCells(shuffledTBTst, lapPctThresh, consecLapThresh);
    [~, RunOccMapShuffst, ~, ~, ~, TMap_gaussShuffst] =...
    PFsLinTrialbyTrial(shuffledTBTst,xlims, cmperbin, minspeed, 0, []);
    [~, ~, shLeftCorrs(:,:,shuffI), shRightCorrs(:,:,shuffI), shnumCellsst(shuffI)] =...
    PVcorrAllCond(TMap_gaussShuffst, RunOccMap, posThresh, threshAndConsecShuffst, Conds);
    disp(['finished shuffle ' num2str(shuffI)])
    catch
        keyboard
    end
end

aaa = GenerateFigsAndHandles(4,'subplot');
PlotPVCorrsDays(mean(shStudyCorrs,3), aaa(1).pl, 'Study shuff-lr')
PlotPVCorrsDays(mean(shTestCorrs,3), aaa(2).pl, 'Test shuff-lr')
PlotPVCorrsDays(mean(shLeftCorrs,3), aaa(3).pl, 'Left shuff-st')
PlotPVCorrsDays(mean(shRightCorrs,3), aaa(4).pl, 'Right shuff-st')
%% Corrs Against Self


[~, RunOccMap, ~, ~, ~, TMap_gauss] =...
    PFsLinTrialbyTrial(trialbytrial,xlims, cmperbin, minspeed, 0, []);


numSplits = 10;

StudyLCorrs = nan(numSess,numBins,numSplits); StudyRCorrs = nan(numSess,numBins,numSplits); 
TestLCorrs = nan(numSess,numBins,numSplits); TestRCorrs = nan(numSess,numBins,numSplits);
for ns = 1:numSplits
    TMap_gaussSplit = [];
    [~, RunOccMapSplit, ~, TMap_unsmoothedSplit, ~, TMap_gaussSplit, LapIDs, Conditions]=...    
        PFsLinTrialbyTrialSplit(trialbytrial,xlims, cmperbin, minspeed, 0, [],sortedSessionInds, 1);
    
    %[corrs, cells, dayPairs] =...
    %    PVcorrAcrossDays(TMap_gaussSplit,RunOccMap,posThresh,threshAndConsec,sortedSessionInds);
    
    %[corrs.StudyLCorrs(:,:,ns), corrs.StudyRCorrs(:,:,ns),...
    %    corrs.TestLCorrs(:,:,ns), corrs.TestRCorrs(:,:,ns), numCells2(:,:,ns)] =...
    %    PVcorrAllCondSelf(TMap_gaussSplit, RunOccMap, posThresh, threshAndConsec);
    disp(['finished split ' num2str(ns)])
end

corrs.StudyLCorrs = StudyLCorrs;
corrs.StudyRCorrs = StudyRCorrs;
corrs.TestLCorrs = TestLCorrs;
corrs.TestRCorrs = TestRCorrs;
[corrMeans, corrStds, corrSEMs] = processPVcorrsSelfAcrossDays(corrs,dayPairs);
