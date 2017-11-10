
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

[StudyCorrs, TestCorrs, LeftCorrs, RightCorrs, numCells] =...
    PVcorrAllCond(TMap_gauss, RunOccMap, posThresh, threshAndConsec, Conds);
%Make original   
[~, RunOccMap, ~, ~, ~, TMap_gauss] =...
PFsLinTrialbyTrialCONDpool(trialbytrial,xlims, cmperbin, minspeed, 0, []);

%[TMap_zscore] = ZScoreLinPFs(TMap_gauss, zeronans);   

%PV corrs for original
[StudyTestCorrs, LeftRightCorrs] = PVcorrDimPooled(TMap_gauss, RunOccMap, posThresh, dayAllUse);
ccc = GenerateFigsAndHandles(2,'subplot');
PlotPVCorrsDays(StudyTestCorrs, ccc(1).pl, 'Study vs. Test')
PlotPVCorrsDays(LeftRightCorrs, ccc(2).pl, 'Left vs. Right')


%% Shuffle across Days

sdStudyCorrs = nan(11,10,numShuffles); sdTestCorrs = nan(11,10,numShuffles);
sdLeftCorrs = nan(11,10,numShuffles); sdRightCorrs = nan(11,10,numShuffles);
for shuffI = 1:numShuffles
    shuffledTBT = []; ROMforShuff = []; TMGforShuff = []; TMap_zscoreShuff = [];
    
    shuffledTBT = ShuffleTrialsAcrossDays(trialbytrial);
    
    [~, RunOccMapDayShuff, ~, TMap_unsmoothedDayShuff, ~, TMap_gaussDayShuff] =...
    PFsLinTrialbyTrial(shuffledTBT,xlims, cmperbin, minspeed, 0, [], sortedSessionInds);
    
    [dayUseShuff,threshAndConShuff] = GetUseCells(shuffledTBT, lapPctThresh, consecLapThresh);

    if shuffI<100; zerosBuff = '0'; end
    if shuffI<10; zerosBuff = '00'; end
    if shuffI>=100; zerosBuff = []; end
    saveName = ['PFsLinDayShuff' zerosBuff num2str(shuffI) '.mat'];
    save(fullfile(cd,'ShufflesDay2',saveName),'RunOccMapDayShuff','TMap_unsmoothedDayShuff','TMap_gaussDayShuff',...
        'shuffledTBT','dayUseShuff','threshAndConShuff')
    %[sdStudyCorrs(:,:,shuffI), sdTestCorrs(:,:,shuffI),...
    %    sdLeftCorrs(:,:,shuffI), sdRightCorrs(:,:,shuffI), sdnumCellslr(shuffI)] =...
    %    PVcorrAllCond(TMGforShuff, RunOccMap, posThresh, threshAndConShuff, Conds);
    %delete old TMap stuff (memory space)
    disp(['shuffle' num2str(shuffI)])
    
    
    %[~, ROMforShuff, ~, ~, ~, TMGforShuff] =...
    %PFsLinTrialbyTrialCONDpool(shuffledTBT,xlims, cmperbin, minspeed, 0, []);
    %[TMap_zscoreShuff] = ZScoreLinPFs(TMGforShuff, zeronans);
    %PV corrs for shuffle
    %[STcorrsShuff(:,:,shuffI), LRcorrsShuff(:,:,shuffI)] =...
    %    PVcorrDimPooled(TMap_zscoreShuff, RunOccMap, posThresh, threshAndConShuff);

end

ccc = GenerateFigsAndHandles(4,'subplot');
PlotPVCorrsDays(mean(sdStudyCorrs,3), ccc(1).pl, 'Study lr shuffDays')
PlotPVCorrsDays(mean(sdTestCorrs,3), ccc(2).pl, 'Test lr shuffDays')
PlotPVCorrsDays(mean(sdLeftCorrs,3), ccc(3).pl, 'Left st shuffDays')
PlotPVCorrsDays(mean(sdRightCorrs,3), ccc(4).pl, 'Right st shuffDays')

%Statistical comparison goes here



%% Conditions, unpooled
[~, RunOccMap, ~, ~, ~, TMap_gauss] =...
    PFsLinTrialbyTrial(trialbytrial,xlims, cmperbin, minspeed, 0, [], sortedSessionInds);

[~, threshAndConsec] = GetUseCells(trialbytrial, lapPctThresh, consecLapThresh);
[StudyCorrs, TestCorrs, LeftCorrs, RightCorrs, numCells] =...
    PVcorrAllCond(TMap_gauss, RunOccMap, posThresh, threshAndConsec, Conds);
bbb = GenerateFigsAndHandles(4,'subplot');
PlotPVCorrsDays(StudyCorrs, bbb(1).pl, 'Left vs. Right: Study')
PlotPVCorrsDays(TestCorrs, bbb(2).pl, 'Left vs. Right: Test')
PlotPVCorrsDays(LeftCorrs, bbb(3).pl, 'Study vs. Test: Left')
PlotPVCorrsDays(RightCorrs, bbb(4).pl, 'Study vs. Test: Right')

[accuracy] = sessionAccuracy(allfiles);
[colorOrder,~] = tiedrank(accuracy);
bbb = GenerateFigsAndHandles(4,'subplot');
PlotPVCorrsDays(StudyCorrs, bbb(1).pl, 'Left vs. Right: Study',colorOrder)
PlotPVCorrsDays(TestCorrs, bbb(2).pl, 'Left vs. Right: Test',colorOrder)
PlotPVCorrsDays(LeftCorrs, bbb(3).pl, 'Study vs. Test: Left',colorOrder)
PlotPVCorrsDays(RightCorrs, bbb(4).pl, 'Study vs. Test: Right',colorOrder)
suptitle('Colored by accuracy rank')
%% Shuffle across 1 dimension

%Left/Right shuffle
shStudyCorrs = nan(11,10,numShuffles); shTestCorrs = nan(11,10,numShuffles);
for shuffI = 1:numShuffles
    try
    shuffledTBTlr = [];
    shuffledTBTlr = ShuffleTrialsAcrossConditions(trialbytrial,'leftright');
    [~, threshAndConsecShufflr] = GetUseCells(shuffledTBTlr, lapPctThresh, consecLapThresh);
    [~, RunOccMapShufflr, ~, TMap_unsmoothedDayShuff, ~, TMap_gaussShufflr] =...
    PFsLinTrialbyTrial(shuffledTBTlr,xlims, cmperbin, minspeed, 0, [], sortedSessionInds);
    
    if shuffI<100; zerosBuff = '0'; end
    if shuffI<10; zerosBuff = '00'; end
    if shuffI>=100; zerosBuff = []; end
    saveName = ['PFsLinLRShuff' zerosBuff num2str(shuffI) '.mat'];
    save(fullfile(cd,'ShufflesConditionLR2',saveName),'RunOccMapShufflr','TMap_unsmoothedDayShuff','TMap_gaussShufflr',...
        'shuffledTBTlr','threshAndConsecShufflr')

    %[shStudyCorrs(:,:,shuffI), shTestCorrs(:,:,shuffI), ~, ~, shnumCellslr(shuffI)] =...
    %PVcorrAllCond(TMap_gaussShufflr, RunOccMap, posThresh, threshAndConsecShufflr, Conds);
    disp(['finished shuffle ' num2str(shuffI)])
    catch
        keyboard
    end
end    
    
%Study test shuffle    
shLeftCorrs = nan(11,10,numShuffles); shRightCorrs = nan(11,10,numShuffles);
for shuffI = 1:numShuffles
    shuffledTBTst = [];
    try
    shuffledTBTst = ShuffleTrialsAcrossConditions(trialbytrial,'studytest');
    [~, threshAndConsecShuffst] = GetUseCells(shuffledTBTst, lapPctThresh, consecLapThresh);
    [~, RunOccMapShuffst, ~, TMap_unsmoothedDayShuff, ~, TMap_gaussShuffst] =...
    PFsLinTrialbyTrial(shuffledTBTst,xlims, cmperbin, minspeed, 0, [], sortedSessionInds);
    
    if shuffI<100; zerosBuff = '0'; end
    if shuffI<10; zerosBuff = '00'; end
    if shuffI>=100; zerosBuff = []; end
    saveName = ['PFsLinSTShuff' zerosBuff num2str(shuffI) '.mat'];
    save(fullfile(cd,'ShufflesConditionST',saveName),'RunOccMapShuffst','TMap_unsmoothedDayShuff','TMap_gaussShuffst')


    %[~, ~, shLeftCorrs(:,:,shuffI), shRightCorrs(:,:,shuffI), shnumCellsst(shuffI)] =...
    %PVcorrAllCond(TMap_gaussShuffst, RunOccMap, posThresh, threshAndConsecShuffst, Conds);
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
    TMap_gaussSplit = []; TMap_unsmoothedSplit = [];
    [~, RunOccMapSplit, ~, TMap_unsmoothedSplit, ~, TMap_gaussSplit, LapIDs, Conditions]=...    
        PFsLinTrialbyTrialSplit(trialbytrial,xlims, cmperbin, minspeed, 0, [],sortedSessionInds, 1);
    
    if ns<100; zerosBuff = '0'; end
    if ns<10; zerosBuff = '00'; end
    if ns>=100; zerosBuff = []; end
    saveName = ['PFsLinSplit' zerosBuff num2str(ns) '.mat'];
    save(fullfile(cd,'Splits',saveName),'RunOccMapSplit','TMap_unsmoothedSplit','TMap_gaussSplit','LapIDs','Conditions')
    %[corrs, cells, dayPairs] =...
    %    PVcorrAcrossDays(TMap_gaussSplit,RunOccMap,posThresh,threshAndConsec,sortedSessionInds);
    load, 
    corrs 
    organize corrs
    %[StudyLCorrs(:,:,ns), StudyRCorrs(:,:,ns),...
    %    TestLCorrs(:,:,ns), TestRCorrs(:,:,ns), numCells2(:,:,ns)] =...
    %    PVcorrAllCondSelf(TMap_gaussSplit, RunOccMap, posThresh, threshAndConsec);
    corrs.StudyLCorrs = StudyLCorrs;
    corrs.StudyRCorrs = StudyRCorrs;
    corrs.TestLCorrs = TestLCorrs;
    corrs.TestRCorrs = TestRCorrs;
[corrMeans, corrStds, corrSEMs] = processPVcorrsSelfAcrossDays(corrs,dayPairs)
    disp(['finished split ' num2str(ns)])
end
%Mean split corrs
meanStudyL = mean(StudyLCorrs,3); meanStudyR = mean(StudyRCorrs,3);
meanTestL = mean(TestLCorrs,3); meanTestR = mean(TestRCorrs,3);


ddd = GenerateFigsAndHandles(4,'subplot');
PlotPVCorrsDays(meanStudyL, ddd(1).pl, 'StudyL vs self')
PlotPVCorrsDays(meanStudyR, ddd(2).pl, 'StudyR vs self')
PlotPVCorrsDays(meanTestL, ddd(3).pl, 'TestL vs self')
PlotPVCorrsDays(meanTestR, ddd(4).pl, 'TestR vs self')

%% Compare population vectors within a condition across days
[daysStudyLCorrs, daysStudyRCorrs, daysTestLCorrs, daysTestRCorrs, cells, dayPairs] =...
    PVcorrAcrossDays(TMap,RunOccMap,posThresh,threshAndConsec,sortedSessionInds);

corrs.daysStudyLCorrs = daysStudyLCorrs; corrs.daysStudyRCorrs = daysStudyRCorrs;
corrs.daysTestLCorrs = daysTestLCorrs; corrs.daysTestRCorrs = daysTestRCorrs;
[corrMeans, corrStds, corrSEMs, rawSort] = processPVcorrsSelfAcrossDays(corrs, dayPairs);
%% Quantify: Is the difference between conditions greater or less than the difference across days?
%Note: none of these are flipped LR; they go choice....stem 
    %Could (and probably should) do each of these for each day, rather than
    %mean-ing across days
    
    %Is the mean correlation within a condition within a day greater than
    %the mean correlation between  conditions within a day?
    mwdcSL = mean(meanStudyL,1);
    mwdcSR = mean(meanStudyR,1);
    mwdcTL = mean(meanTestL,1);
    mwdcTR = mean(meanTestR,1);
    
    mwdcSPV = mean(StudyCorrs,1); %Study LvR
    mwdcTPV = mean(TestCorrs,1);  %Test LvR
    mwdcLPV = mean(LeftCorrs,1);  %Left SvT
    mwdcRPV = mean(RightCorrs,1); %Right SvT
    
    studyLvR = mean([mwdcSL; mwdcSR],1) > mwdcSPV;
    testLvR = mean([mwdcTL; mwdcTR],1) > mwdcTPV;
    leftSvT = mean([mwdcSL; mwdcTL],1) > mwdcLPV;
    rightSvT = mean([mwdcSR; mwdcTR],1) > mwdcRPV;

    %Is the 1) mean correlation within a condition across days greater than the
    % 2) mean correlation across conditions within a single day?
    %(greater stability within a condition across days than across a condition within days)
    adselfSL = corrMeans{1}(1,:);
    adselfSR = corrMeans{2}(1,:);
    adselfTL = corrMeans{3}(1,:);
    adselfTR = corrMeans{4}(1,:);
    
    mwdcSPV = mean(StudyCorrs,1);
    mwdcTPV = mean(TestCorrs,1);
    mwdcLPV = mean(LeftCorrs,1);
    mwdcRPV = mean(RightCorrs,1);
    
    studyLvR = mean([adselfSL; adselfSR],1) > mwdcSPV;
    testLvR = mean([adselfTL; adselfTR],1) > mwdcTPV;
    leftSvT = mean([adselfSL; adselfTL],1) > mwdcLPV;
    rightSvT = mean([adselfSR; adselfTR],1) > mwdcRPV;
    
    %Is the mean correlation within a condition across a single day less
    %than the mean correlation bewteen conditions across a single day?
    msdcdSL = mean(diff(meanStudyL,1,1),1);
    msdcdSR = mean(diff(meanStudyR,1,1),1);
    msdcdTL = mean(diff(meanTestL,1,1),1);
    msdcdTR = mean(diff(meanTestR,1,1),1);
    
    msdcdSPV = mean(diff(StudyCorrs,1,1),1);
    msdcdTPV = mean(diff(TestCorrs,1,1),1);
    msdcdLPV = mean(diff(LeftCorrs,1,1),1);
    msdcdRPV = mean(diff(RightCorrs,1,1),1);
    
    studyLvR = mean([msdcdSL; msdcdSR],1) < msdcdSPV;
    testLvR = mean([msdcdTL; msdcdTR],1) < msdcdTPV;
    leftSvT = mean([msdcdSL; msdcdTL],1) < msdcdLPV;
    rightSvT = mean([msdcdSR; msdcdTR],1) < msdcdRPV;
    
%%
[bigCorrs, cells, dayPairs, condPairs ] =...
    PVcorrsAllCorrsAllCondsAllDays(TMap_gauss,RunOccMap,posThresh,threshAndConsec,sortedSessionInds,[]);
[corrMeans, corrStd, corrSEM] = processPVacacad(bigCorrs, cells, dayPairs, condPairs,realDays);

eee = GenerateFigsAndHandles(4,'subplot');
PlotPVCorrsDays(corrMeans{1,1}, eee(1).pl, 'StudyL vs self')
PlotPVCorrsDays(corrMeans{2,1}, eee(2).pl, 'StudyR vs self')
PlotPVCorrsDays(corrMeans{3,1}, eee(3).pl, 'TestL vs self')
PlotPVCorrsDays(corrMeans{4,1}, eee(4).pl, 'TestR vs self')


fff = GenerateFigsAndHandles(4,'subplot');
PlotPVCorrsDays(corrMeans{5,1}, fff(1).pl, 'StudyL vs StudyR')
PlotPVCorrsDays(corrMeans{10,1}, fff(2).pl, 'TestL vs TestR')
PlotPVCorrsDays(corrMeans{6,1}, fff(3).pl, 'StudyL vs TestL')
PlotPVCorrsDays(corrMeans{9,1}, fff(4).pl, 'StudyR vs TestR')
%PlotPVCorrsDays(corrMeans{7,1}, fff(5).pl, 'StudyL vs TestR')
%PlotPVCorrsDays(corrMeans{8,1}, fff(6).pl, 'StudyR vs TestL')

suptitle('Found both days, active above thresh on one')

% No activity threshold
alwaysAboveThresh = threshAndConsec;
alwaysAboveThresh = ones(size(threshAndConsec));
[bigCorrs, cells, dayPairs, condPairs ] =...
    PVcorrsAllCorrsAllCondsAllDays(TMap_gauss,RunOccMap,posThresh,alwaysAboveThresh,sortedSessionInds,Conds);
[corrMeans, corrStd, corrSEM] = processPVacacad(bigCorrs, cells, dayPairs, condPairs,realDays);

suptitle('Found both days, no activity thresh')

%Include silent cells
newDummyRow = size(sortedSessionInds,1)+1;
blankRates = zeros(1,numBins);
TMap_bonus = TMap_gauss;
for condI = 1:size(TMap_gauss,2)
    for dayI = 1:size(TMap_gauss,3)
        TMap_bonus{newDummyRow,condI,dayI} = blankRates;
    end
end
silentSessionInds = sortedSessionInds;
silentSessionInds(silentSessionInds==0) = newDummyRow;
[bigCorrs, cells, dayPairs, condPairs ] =...
    PVcorrsAllCorrsAllCondsAllDays(TMap_bonus,RunOccMap,posThresh,alwaysAboveThresh,silentSessionInds,[]);
[corrMeans, corrStd, corrSEM] = processPVacacad(bigCorrs, cells, dayPairs, condPairs,realDays);

suptitle('Includes silent cells, no activity thresh')



for qq = 1:100 
    if qq<100; zerosBuff = '0'; end
    if qq<10; zerosBuff = '00'; end
    if qq>=100; zerosBuff = []; end
    saveName = ['PFsLinDayShuff' zerosBuff num2str(qq) '.mat'];
    load(fullfile(cd,'ShufflesDay',saveName),'TMap_gaussDayShuff')
    [daybigCorrs, cells, dayPairs, condPairs ] =...
    PVcorrsAllCorrsAllCondsAllDays(TMap_gaussDayShuff,RunOccMap,posThresh,threshAndConsec,sortedSessionInds,Conds);
    [daycorrMeans{qq}, daycorrStd{qq}, daycorrSEM{qq}] = processPVacacad(daybigCorrs, cells, dayPairs, condPairs,realDays);
    %{shuffle}{condition pair}(days apart, bin num)
    disp(['finished corrs ' num2str(qq)])
end
 meanCorrDaysApart = processPCadacadStep2(dayCorrMeans);
 
for dayCheck = 1:10 
figure; 
for qq = 1:100 
    %}
    hold on
    plot(meanCorrDaysApart{dayCheck}(:,qq),'Color',[0.85 0.85 0.85],'LineWidth',1)
end
plot(mean(corrMeans{dayCheck},2),'b','LineWidth',1.5)
title(['condition pair ' num2str(condPairs(dayCheck,:))])
end




