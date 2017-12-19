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

xlims = [25.5 56];
numXbins = 8;
cmperbin = (max(xlims) - min(xlims))/numXbins;
minspeed = 0;
numShuffles = 25;
shuffThresh = 0.9;
lapPctThresh = 0.25;
consecLapThresh = 3;
binsMin = 2;
[Conds] = GetTBTconds(trialbytrial);
%load('PFsLin8bin.mat')
[rates, normrates, rateDiff] = LookAtSplitters2(TMap_unsmoothed);
[dayUse,threshAndConsec] = GetUseCells(trialbytrial, lapPctThresh, consecLapThresh);

rates_shuffLR = cell(numShuffles,1);
normrates_shuffLR = cell(numShuffles,1);
rateDiff_shuffLR = cell(numShuffles,1);
for shuffI = 1:numShuffles
    shuffledTBTlr = []; shuffLR_TMap_unsmoothed = [];   %#ok<NASGU>
    shuffledTBTlr = ShuffleTrialsAcrossConditions(trialbytrial,'leftright');
    [~, RunOccMapShufflr, ~, shuffLR_TMap_unsmoothed, ~, ~] =...
    PFsLinTrialbyTrial(shuffledTBTlr,xlims, cmperbin, minspeed, 0, [], sortedSessionInds);
    [rates_shuffLR{shuffI}, normrates_shuffLR{shuffI}, rateDiff_shuffLR{shuffI}] = LookAtSplitters2(shuffLR_TMap_unsmoothed);
end
[binsAboveShuffle, thisCellSplits] = SplitterRateRank(rateDiff, shuffledRateDiff, shuffThresh, binsMin);




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

sessPairs = GetAllCombs(trainingSess, testingSess);

%First Step is organize which day, which condition, which trials
for sessPairI = 1:size(sessPairs,1)
    trainSess = sessPairs(sessPairI,1);
    testSess = sessPairs(sessPairI,2);
