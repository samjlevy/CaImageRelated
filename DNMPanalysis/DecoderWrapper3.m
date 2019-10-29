function [decodingResults, shuffledResults, testConds, titles, sessPairs] =...
    DecoderWrapper3(trialbytrial,traitLogical,numShuffles,activityType,pooledUnpooled,discType)
%This function is built as a wrapper for looking at decoding results by
%splitting. Pretty much the only thing that needs to be given is basic
%data and parameters, testing for significance, etc., is handled here
%Trait logical is cells X days does the cell do the thing. Should come in
%pre-filtered for dayUse
%Using same set on training on testing, but functionality is there to try something else
%activityType is what kind of reduction of PSAbool to use. Default (and
%only tested so far) is transientDur. Right now can only handle one option

%discType = 'linear'; %Doesn't work yet
discType = 'bayes';

Conds = GetTBTconds(trialbytrial);
switch pooledUnpooled
    case 'unpooled'
        %condsInclude = [Conds.Study; Conds.Test; Conds.Left; Conds.Right];
        %titles = {'StudyLvR', 'TestLvR', 'LeftSvT', 'RightSvT'}; 
        %typePredict = {'leftright', 'leftright', 'studytest', 'studytest'}; 
    case 'pooled'
        titles = {'Left/Right'; 'Study/Test'};
        testConds = [1 2; 3 4];
        condsPool = [Conds.Left; Conds.Right; Conds.Study; Conds.Test];
        condLabels = {'Left','Right','Study','Test'};
        trialbytrial = PoolTBTacrossConds(trialbytrial,condsPool,condLabels);
    case 'custom'
        condLabels = {trialbytrial(:).name};
        titles = {'Maze 2 from 1';'Maze 1 from 2'};
        trainConds = [1 2; 3 4];
        testConds = [3 4; 1 2];
end

randomizeNow = [0; ones(numShuffles,1)];

numDays = length(unique(trialbytrial(1).sessID));
trainingSessions = 1:numDays;
testingSessions = 1:numDays;
sessPairs = GetAllCombs(trainingSessions, testingSessions);
numSessPairs = size(sessPairs,1);

%Lap Combinations (leave one out)
[trainingLaps, testingLaps] = leaveOneOutAllCombs(trialbytrial);

%Actual activity to give to decoder
[tbtActivity] = lapbylapActivity(trialbytrial);
switch activityType
    case 'transientDur'
        lblActivity = tbtActivity.transientDur;
    case 'rawTraceAvg'
        lblActivity = tbtActivity.fluorAvg;
end      

%Repackage laps, etc. into cell arrays
if numShuffles>0
    h = waitbar(0,'Starting');
end
for permI = 1:numShuffles+1

for testI = 1:size(testConds,1)
    testingActivity = cell(numSessPairs,size(testConds,2));
    testingAnswers =  cell(numSessPairs,size(testConds,2));
    trainingActivity = cell(numSessPairs,size(testConds,2));
    trainingAnswers =  cell(numSessPairs,size(testConds,2));

    numCondsHere = length(testConds(testI,:));
    for tcJ = 1:numCondsHere
        testCond = testConds(testI,tcJ);
        parfor sessPairI = 1:numSessPairs
            testSess = sessPairs(sessPairI,2);
            trainSess = sessPairs(sessPairI,1);
            
            %Select cells
            cellsUse = traitLogical(:,trainSess);
            trainingCells = logical(cellsUse);
            testingCells = logical(cellsUse);
            
            numTestLaps = length(testingLaps(testCond).lapNums{testSess});
            trainingActivity{sessPairI,tcJ} = cell(numTestLaps,1);
            trainingAnswers{sessPairI,tcJ} = cell(numTestLaps,1);
            testingActivity{sessPairI,tcJ} = cell(numTestLaps,1);
            testingAnswers{sessPairI,tcJ} = cell(numTestLaps,1);
            for lapI = 1:numTestLaps
                lapsGet = testingLaps(testCond).lapNums{testSess}{lapI};
                testingActivity{sessPairI,tcJ}{lapI,1} = lblActivity{testCond}(lapsGet,testingCells);
                testingAnswers{sessPairI,tcJ}{lapI,1} = testCond;
                
                if strcmpi(pooledUnpooled,'custom')
                    testingAnswers{sessPairI,tcJ}{lapI,1} = trainConds(testI,tcJ);
                end
                
                for trainI = 1:length(testConds(testI,:))
                    if strcmpi(pooledUnpooled,'custom')
                        trainCond = trainConds(testI,trainI);
                    else
                        trainCond = testConds(testI,trainI);
                    end
                    
                    numTrainLaps = length(trainingLaps(trainCond).lapNums{trainSess});
                    lapUse = lapI;
                    if lapUse > numTrainLaps
                        lapUse = randi(numTrainLaps);
                    end
                    
                    trainLapsHere = trainingLaps(trainCond).lapNums{trainSess}{lapUse};
                    trainingActivity{sessPairI,tcJ}{lapI,1} = [trainingActivity{sessPairI,tcJ}{lapI,1}; lblActivity{trainCond}(trainLapsHere,trainingCells)];
                    trainingAnswers{sessPairI,tcJ}{lapI,1} = [trainingAnswers{sessPairI,tcJ}{lapI,1}; trainCond*ones(length(trainLapsHere),1)];
                end
                
                if randomizeNow(permI)==1
                    trainingAnswers{sessPairI,tcJ}{lapI,1} = trainingAnswers{sessPairI,tcJ}{lapI,1}(randperm(length(trainingAnswers{sessPairI,tcJ}{lapI,1})));    
                end
            end
        end
    end
                
    %Do all the decoding
    decodedTrial = cell(numSessPairs,size(testConds,2));
    postProb = cell(numSessPairs,size(testConds,2));
    correctIndiv = cell(numSessPairs,size(testConds,2));
    correctPct = cell(numSessPairs,size(testConds,2));
    miscodedLapNums = cell(numSessPairs,size(testConds,2));
    for testJ = 1:size(testConds,2)
        parfor sessPairI = 1:numSessPairs
            [dt,pp] = cellfun(@(x,y,z) PredictTrialType(x,y,z,discType),...
                trainingActivity{sessPairI,testJ},trainingAnswers{sessPairI,testJ},testingActivity{sessPairI,testJ},'UniformOutput',false);
            
            decodedTrial{sessPairI,testJ} = cell2mat(dt); 
            postProb{sessPairI,testJ} = cell2mat(pp);
            
            rightAnswers = cell2mat(testingAnswers{sessPairI,testJ});
            rightHere = decodedTrial{sessPairI,testJ} == rightAnswers;
            correctIndiv{sessPairI,testJ} = rightHere;
            correctPct{sessPairI,testJ} = sum(correctIndiv{sessPairI,testJ}) / length(correctIndiv{sessPairI,testJ}); 
            miscoded{sessPairI,testJ} = rightAnswers(rightHere==0);
            if sum(rightHere==0) > 0
                missLNs = testingLaps(testJ).lapNums{sessPairs(sessPairI,2)}{rightHere==0};
                miscodedLapNums{sessPairI,testJ} = missLNs;
            end
        end
        condDecoding{testI,testJ} = condLabels{testConds(testI,testJ)};
    end
    
    if randomizeNow(permI)==0
        decodingResults.decodedTrial{testI} = decodedTrial;
        decodingResults.postProb{testI} = postProb;
        decodingResults.correctIndiv{testI} = correctIndiv;
        decodingResults.correctPct{testI} = cell2mat(correctPct); %sessPair x testCond 
        decodingResults.miscodedLapNums{testI} = miscodedLapNums;  
        decodingResults.whatDecoding = condDecoding;
    else
        shuffledResults.decodedTrial{permI-1,testI} = decodedTrial;
        shuffledResults.postProb{permI-1,testI} = postProb;
        shuffledResults.correctIndiv{permI-1,testI} = correctIndiv;
        shuffledResults.correctPct{1,testI}(:,:,permI-1) = cell2mat(correctPct);
        shuffledResults.miscodedLapNums{permI-1,testI} = miscodedLapNums;  
    end
end 

if numShuffles>0
    waitbar(permI/numShuffles,h,'done so far')
end

end

if numShuffles>0
    close(h)
end

end