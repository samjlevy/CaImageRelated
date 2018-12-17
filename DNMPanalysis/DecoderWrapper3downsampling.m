function [decodingResults, downsampledResults, testConds, titles, sessPairs, cellDownsamples] =...
    DecoderWrapper3downsampling(trialbytrial,traitLogical,numDownsamples,activityType,pooledUnpooled,discType)
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
        titles = {'Left vs. Right'; 'Study vs. Test'};
        testConds = [1 2; 3 4];
        condsPool = [Conds.Left; Conds.Right; Conds.Study; Conds.Test];
        trialbytrial = PoolTBTacrossConds(trialbytrial,condsPool,{'Left','Right','Study','Test'});
end

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

%Downsample cells
cellDownsamples = GetDownsampleCellCombs(traitLogical,sessPairs,numDownsamples);

%Repackage laps, etc. into cell arrays
if numDownsamples>0
    try
        h = waitbar(0,'Starting');
    end
end

for dsI = 1:numDownsamples+1
testingActivity = cell(numSessPairs,size(testConds,2));
testingAnswers =  cell(numSessPairs,size(testConds,2));
trainingActivity = cell(numSessPairs,size(testConds,2));
trainingAnswers =  cell(numSessPairs,size(testConds,2));
for testI = 1:size(testConds,1) 
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
            for lapI = 1:numTestLaps
                if dsI > 1
                    if size(cellDownsamples{sessPairI},1) >= dsI-1
                        cellsUse = cellDownsamples{sessPairI}(dsI-1,:);
                        trainingCells = cellsUse;
                        testingCells = cellsUse;
                    end
                end 
                   
                testingActivity{sessPairI,tcJ}{lapI,1} = lblActivity{testCond}(testingLaps(testCond).lapNums{testSess}{lapI},testingCells);
                testingAnswers{sessPairI,tcJ}{lapI,1} = testCond;
                
                for trainI = 1:length(testConds(testI,:))
                    trainCond = testConds(testI,trainI);
                    
                    numTrainLaps = length(trainingLaps(trainCond).lapNums{trainSess});
                    lapUse = lapI;
                    if lapUse > numTrainLaps
                        lapUse = randi(numTrainLaps);
                    end
                    
                    trainLapsHere = trainingLaps(trainCond).lapNums{trainSess}{lapUse};
                    trainingActivity{sessPairI,tcJ}{lapI,1} = [trainingActivity{sessPairI,tcJ}{lapI,1}; lblActivity{trainCond}(trainLapsHere,trainingCells)];
                    trainingAnswers{sessPairI,tcJ}{lapI,1} = [trainingAnswers{sessPairI,tcJ}{lapI,1}; trainCond*ones(length(trainLapsHere),1)];
                end
                
                %if randomizeNow(dsI)==1
                %    trainingAnswers{sessPairI,tcJ}{lapI,1} = trainingAnswers{sessPairI,tcJ}{lapI,1}(randperm(length(trainingAnswers{sessPairI,tcJ}{lapI,1})));    
                %end
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
    end
    
    if dsI==1
        decodingResults.decodedTrial{testI} = decodedTrial;
        decodingResults.postProb{testI} = postProb;
        decodingResults.correctIndiv{testI} = correctIndiv;
        decodingResults.correctPct{testI} = cell2mat(correctPct);
        decodingResults.miscodedLapNums{testI} = miscodedLapNums;  
    else
        downsampledResults.decodedTrial{dsI-1,testI} = decodedTrial;
        downsampledResults.postProb{dsI-1,testI} = postProb;
        downsampledResults.correctIndiv{dsI-1,testI} = correctIndiv;
        downsampledResults.correctPct{1,testI}(:,:,dsI-1) = cell2mat(correctPct);
        downsampledResults.miscodedLapNums{dsI-1,testI} = miscodedLapNums;  
    end
end 


if numDownsamples>0
    try
    waitbar(permI/numShuffles,h,'done so far')
    end
end

end

if numDownsamples>0
    try
    close(h)
    end
end

end