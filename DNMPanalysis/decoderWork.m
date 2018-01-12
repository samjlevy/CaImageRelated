sessI = 6;
condI = 4;

X = transientDur{condI,1}(trainingLaps(condI).lapNums{sessI,1},:);
Y = lapBlockNums{4}(trainingLaps(condI).lapNums{sessI,1},:);

testX = transientDur{condI,1}(testingLaps(condI).lapNums{sessI,1},:);
answer = lapBlockNums{condI,1}(testingLaps(condI).lapNums{sessI,1});


Mdl = fitcnb(X,Y,'distributionnames','mn');

[decodedTrial,postProbs] = predict(Mdl,testX);


% Here what we're gonna do is build a model and test each 
load('trialbytrial.mat');
[tbtActivity] = lapbylapActivity(trialbytrial);
[trainingLaps, testingLaps] = leaveOneOutAllCombs(trialbytrial);

condsInclude = [1 2 3 4];
sessI = 6;
lblActivity = tbtActivity.transientDur;

[trainLapNumbers, trainLapConds, testLapNumbers, testLapConds,...
    testCondDecoded] = decodeAcrossConditions1(trialbytrial, condsInclude,...
    trainingLaps, testingLaps, lblActivity, sessI,'all',[]);

%Run again for random lap assignments

inCs = length(unique(testLapConds(:,1)));
outCs = length(unique(testCondDecoded(:,1)));
for inputCond = 1:4
    for outputCond = 1:outCs
        %outResults(inputCond,outputCond) = sum(testCondDecoded(testLapConds==inputCond)==outputCond);
        rowsUse = testLapConds(:,1)==inputCond;
        outResults(inputCond,outputCond) = sum(testCondDecoded(rowsUse,1)==outputCond);
    end
    outResults(inputCond,:) = outResults(inputCond,:)/sum(outResults(inputCond,:));
end

%compare to same for chance




%% Splitters
load('trialbytrial.mat')
xlims = [25.5 56];
numXbins = 8;
cmperbin = (max(xlims) - min(xlims))/numXbins;
minspeed = 0;
numShuffles = 100;
shuffThresh = 0.9;
lapPctThresh = 0.25;
consecLapThresh = 3;
binsMin = 2;
[Conds] = GetTBTconds(trialbytrial);
%load('PFsLin8bin.mat')
[rates, normrates, rateDiff, rateDIall, rateDI] = LookAtSplitters2(TMap_unsmoothed);
[dayUse,threshAndConsec] = GetUseCells(trialbytrial, lapPctThresh, consecLapThresh);

%Left/Right
rates_shuffLR = cell(numShuffles,1);
normrates_shuffLR = cell(numShuffles,1);
rateDiff_shuffLR = cell(numShuffles,1);
for shuffI = 1:numShuffles
    shuffledTBTlr = []; shuffLR_TMap_unsmoothed = [];   %#ok<NASGU>
    shuffledTBTlr = ShuffleTrialsAcrossConditions(trialbytrial,'leftright');
    [~, RunOccMapShufflr, ~, shuffLR_TMap_unsmoothed, ~, ~] =...
    PFsLinTrialbyTrial(shuffledTBTlr,xlims, cmperbin, minspeed, 0, [], sortedSessionInds);
    [rates_shuffLR{shuffI}, normrates_shuffLR{shuffI}, rateDiff_shuffLR{shuffI}] = LookAtSplitters2(shuffLR_TMap_unsmoothed);
    disp(['Finished shuffle ' num2str(shuffI)])
end
[binsAboveShuffleLR, thisCellSplitsLR] = SplitterRateRank(rateDiff, rateDiff_shuffLR, shuffThresh, binsMin);

%Study/Test
rates_shuffST = cell(numShuffles,1);
normrates_shuffST = cell(numShuffles,1);
rateDiff_shuffST = cell(numShuffles,1);
for shuffI = 1:numShuffles
    shuffledTBTst = []; shuffST_TMap_unsmoothed = [];   %#ok<NASGU>
    shuffledTBTst= ShuffleTrialsAcrossConditions(trialbytrial,'studytest');
    [~, RunOccMapShuffst, ~, shuffST_TMap_unsmoothed, ~, ~] =...
    PFsLinTrialbyTrial(shuffledTBTst,xlims, cmperbin, minspeed, 0, [], sortedSessionInds);
    [rates_shuffST{shuffI}, normrates_shuffST{shuffI}, rateDiff_shuffST{shuffI}] = LookAtSplitters2(shuffST_TMap_unsmoothed);
    disp(['Finished shuffle ' num2str(shuffI)])
end
[binsAboveShuffleST, thisCellSplitsST] = SplitterRateRank(rateDiff, rateDiff_shuffST, shuffThresh, binsMin);

%Look at how many splitters
for dayI = 1:size(dayUse,2)
    howManySplittersCell{dayI,1} = find(dayUse(:,dayI).*thisCellSplitsLR.StudyLvR(:,dayI));
    howManySplittersCell{dayI,2} = find(dayUse(:,dayI).*(thisCellSplitsLR.StudyLvR(:,dayI)==0));
    howManySplittersCell{dayI,3} = find(dayUse(:,dayI).*thisCellSplitsLR.TestLvR(:,dayI));
    howManySplittersCell{dayI,4} = find(dayUse(:,dayI).*(thisCellSplitsLR.TestLvR(:,dayI)==0));
    howManySplittersCell{dayI,5} = find(dayUse(:,dayI).*thisCellSplitsST.LeftSvT(:,dayI));
    howManySplittersCell{dayI,6} = find(dayUse(:,dayI).*(thisCellSplitsST.LeftSvT(:,dayI)==0));
    howManySplittersCell{dayI,7} = find(dayUse(:,dayI).*thisCellSplitsST.RightSvT(:,dayI));
    howManySplittersCell{dayI,8} = find(dayUse(:,dayI).*(thisCellSplitsST.RightSvT(:,dayI)==0));
end
howManySplitters = cellfun(@length,howManySplittersCell,'UniformOutput',false);

trainLapNumbers = [];
trainLapConds = []; 
testLapNumbers = [];
testLapConds = [];
testCondDecoded = [];
outResults = [];
[tbtActivity] = lapbylapActivity(trialbytrial);
lblActivity = tbtActivity.transientDur;
[trainingLaps, testingLaps] = leaveOneOutAllCombs(trialbytrial);

%All
[trainLapNumbers{1}, trainLapConds{1}, testLapNumbers{1}, testLapConds{1},...
    testCondDecoded{1}] = decodeAcrossConditions1(trialbytrial, Conds.Test,...
    trainingLaps, testingLaps, lblActivity, sessI, 'leftright', []);

%Active only
[trainLapNumbers{2}, trainLapConds{2}, testLapNumbers{2}, testLapConds{2},...
    testCondDecoded{2}] = decodeAcrossConditions1(trialbytrial, Conds.Test,...
    trainingLaps, testingLaps, lblActivity, sessI, 'leftright', dayUse(:,sessI));

%Splitters
cellsUse = dayUse(:,sessI).*thisCellSplits.TestLvR(:,sessI);
[trainLapNumbers{3}, trainLapConds{3}, testLapNumbers{3}, testLapConds{3},...
    testCondDecoded{3}] = decodeAcrossConditions1(trialbytrial, Conds.Test,...
    trainingLaps, testingLaps, lblActivity, sessI, 'leftright', cellsUse);

%Non-Splitters
cellsUse = dayUse(:,sessI).*(thisCellSplits.TestLvR(:,sessI)==0);
[trainLapNumbers{4}, trainLapConds{4}, testLapNumbers{4}, testLapConds{4},...
    testCondDecoded{4}] = decodeAcrossConditions1(trialbytrial, Conds.Test,...
    trainingLaps, testingLaps, lblActivity, sessI, 'leftright', cellsUse);

%Shuffled
shuffledTBTlr = ShuffleTrialsAcrossConditions(trialbytrial,'leftright');
[shufftbtActivity] = lapbylapActivity(shuffledTBTlr);
[shufftrainingLaps, shufftestingLaps] = leaveOneOutAllCombs(shuffledTBTlr);
shufflblActivity = shufftbtActivity.transientDur;
[trainLapNumbers{5}, trainLapConds{5}, testLapNumbers{5}, testLapConds{5},...
    testCondDecoded{5}] = decodeAcrossConditions1(shuffledTBTlr, Conds.Test,...
    shufftrainingLaps, shufftestingLaps, shufflblActivity, sessI, 'leftright', []);

%Shuffle only labels to trial types before decoder.

%Probably need to do shuffled again for limited sets

for dcI = 1:5
    [outResults{dcI}] = decoderResults1(testLapConds{dcI}, testCondDecoded{dcI});
end


%% Decode across days
%condsInclude = Conds.Test
%typePredict = 'leftright'
%trainingCells = [];
%testingCells = [];

%Set up all permutations of things to run
condsInclude = [Conds.Study; Conds.Test; Conds.Left; Conds.Right]; 
    condsInclude = [condsInclude; condsInclude]; condsInclude = [condsInclude; condsInclude];
titles = {'StudyLvR', 'TestLvR', 'LeftSvT', 'RightSvT'}; 
    titles = [titles titles]; titles = [titles titles];
typePredict = {'leftright', 'leftright', 'studytest', 'studytest'}; 
    typePredict = [typePredict typePredict]; typePredict = [typePredict typePredict];
randomizeNow = [0 0 0 0 1 1 1 1]; randomizeNow = [randomizeNow randomizeNow];
usesplitters = [1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0];

trainingSessions = 1:length(realDays);
testingSessions = 1:length(realDays);
sessPairs = GetAllCombs(trainingSessions, testingSessions);


%[ some comment here ] 
performance = [];
numSetups = length(condsInclude);
for setupI = 1:numSetups
    decoded = [];
    testing = [];
    actual = [];
    
    for sessPairI = 1:size(sessPairs,1)
        %Assign sessions
        trainSess = sessPairs(sessPairI,1);
        testSess = sessPairs(sessPairI,2);
        
        %Select cells
        if strcmp(typePredict{setupI}, 'leftright')
                cellsUse = dayUse(:,trainSess).*(thisCellSplitsLR.(titles{setupI})(:,trainSess)==usesplitters(setupI));
        elseif strcmp(typePredict{setupI}, 'studytest')
                cellsUse = dayUse(:,trainSess).*(thisCellSplitsST.(titles{setupI})(:,trainSess)==usesplitters(setupI));
        end
        
        trainingCells = cellsUse;
        testingCells = cellsUse;
        
        %Decode the things
        [~, testing, decoded{sessPairI}, ~] = decodeAcrossConditions2(trialbytrial,...
            condsInclude(setupI,:), typePredict{setupI}, trainSess, testSess,...
            trainingCells, testingCells, trainingLaps, testingLaps, lblActivity, randomizeNow(setupI));
        
        actual{sessPairI} = [testing(:).answers]';
        
    end
    
    %Log performance
    [performance{setupI}, miscoded] = decoderResults2(decoded, actual, sessPairs, realDays);

    disp(['Finished combination ' num2str(setupI)])
end

daysApart = diff(realDays(sessPairs), 1, 2);
daysApart = abs(daysApart);

%Make some figures
notRandom = find(randomizeNow==0);
for plotI = 1:length(notRandom)
    figure; 
    plot(daysApart,performance{notRandom(plotI)},'*b')
    hold on
    plot(daysApart,performance{notRandom(plotI)+4},'*r')
    ylim([0 1])
    xlabel('Days apart')
    ylabel('Proportion decoded correctly')
    switch usesplitters(notRandom(plotI)); case 1; sps = 'Splitters Only'; case 0; sps = 'Non-Splitters Only'; end
    %switch randomizeNow(plotI); case 1; rdr = 'Shuffled Training Data'; case 0; rdr = 'Original Training Data'; end
    %titleText = [titles{plotI} ', ' sps ', ' rdr];
    titleText = [titles{notRandom(plotI)} ', ' sps ', blue/red real/shuffled'];
    title(titleText)
end

%Test significance of differences
data = [performance{11}; performance{15}];
group = [zeros(length(performance{11}),1); ones(length(performance{15}),1)];
[h,atab,ctab,stats] = aoctool([daysApart; daysApart], data, group,[], [], [], [],'on');