function [training, testing, decoded, postProbs] = decodeAcrossConditions2(trialbytrial, condsInclude, typePredict, trainSess,...
    testSess, trainingCells, testingCells, trainingLaps, testingLaps, lblActivity, randomize)
% Version 2 of the program that does the decoding. Now has specification
% for which session to be used for training and testing.
% Use randomize (0 or 1) to auto randomization for significance
% lblActivity is something like transientDur
% uses each lap from each condition in order, gets a random lap from each
% other condition to build training model. Means that each lap will get
% used at least once, most more than once
% to understand what's going on look at:
% - trainingLapsI
% - trainX
% - trainingAnswers
% - testLapsI
% - testY
% - testAnswers

% Use typePredict to specify what kind of thing we're predicting
% 'all', 'leftright', 'studytest'

if isempty(trainingCells)
    trainingCells = true(size(trialbytrial(1).trialPSAbool{1},1),1);
end
if isempty(testingCells)
    testingCells = true(size(trialbytrial(1).trialPSAbool{1},1),1);
end
testingCells = logical(testingCells);
trainingCells = logical(trainingCells);

%if strcmpi(testingSess,'all')
%    testingSess = unique(trialbytrial(1).sessID);
%end
[Conds] = GetTBTconds(trialbytrial);

%First Step is to figure out the combinations of testing and training laps;
%or not? Allow for user to determine how this is done before this function
%[trainingLaps, testingLaps] = leaveOneOutAllCombs(trialbytrial);

training = []; testing = [];
for testCondJ = 1:length(condsInclude) 
    testCondI = condsInclude(testCondJ);
    otherConds = condsInclude(condsInclude~=testCondI);
    
    testLapsHere = testingLaps(testCondI).lapNums{testSess};
    numTestLaps = length(testLapsHere);
    numTrainLaps = length(trainingLaps(testCondI).lapNums{trainSess});
    
    testLaps = []; testAnswers = []; testSessions = [];  testConditions = [];
    trainLaps = []; trainAnswers = []; trainSessions = []; trainConditions = [];
    for testLapJ = 1:numTestLaps
        trainLapUse = testLapJ;
        % for each lap in this condition, base other stuff around this
        testLaps = testLapsHere{testLapJ};
        testAnswers = testCondI;
        testSessions = testSess;
        
        % get initial training laps and answers
        if trainLapUse > numTrainLaps %reassign if not enough in other sess
            trainLapUse = randi(numTrainLaps);
            %Alternative: trainLapUse = numTrainLaps;
                %will in many cases leave out a few laps
        end
        trainLaps = trainingLaps(testCondI).lapNums{trainSess}{trainLapUse};
        trainAnswers = testCondI*ones(length(trainLaps),1);
        trainSessions = trainSess*ones(length(trainLaps),1);
        
        for ocI = 1:length(otherConds)
            % randomly pick a lap from the other conditions
            otherHere = otherConds(ocI);
            otherTestLapsHere = testingLaps(otherHere).lapNums{testSess};
            otherTestLapsJ = randi(length(otherTestLapsHere));
            otherTrainLapsUse = otherTestLapsJ;
            
            %Throw it into the test laps
            testLaps(ocI+1,1) =  testingLaps(otherHere).lapNums{testSess}{otherTestLapsJ};
            testAnswers(ocI+1,1) = otherHere;
            testSessions(ocI+1,1) = testSess;
            
            % use that randomly picked lap to choose training data
            possibleOtherTrainLaps = length(trainingLaps(otherHere).lapNums{trainSess});
            if otherTrainLapsUse > possibleOtherTrainLaps %reassign if not enough in other sess
                otherTrainLapsUse = randi(possibleOtherTrainLaps);
                %Alternative: otherTrainLapsUse = possibleOtherTrainLaps;
                %will in many cases leave out a few laps
            end
            trainingLapsJ = trainingLaps(otherHere).lapNums{trainSess}{otherTrainLapsUse};
            trainLaps = [trainLaps; trainingLapsJ]; %#ok<*AGROW>
            trainAnswers = [trainAnswers; otherHere*ones(length(trainingLapsJ),1)];
            trainSessions = [trainSessions; trainSess*ones(length(trainingLapsJ),1)];
        end

        
        trainConditions = trainAnswers;
        testConditions = testAnswers;
        
        %Change it so everything has binary category of answers
        switch typePredict
            case 'all'
                %do nothing? Does this work?
            case 'leftright'
                trainAnswers(logical(sum(trainAnswers == Conds.Left,2))) = 9;
                trainAnswers(logical(sum(trainAnswers == Conds.Right,2))) = 10;
                trainAnswers = trainAnswers - 8;
                testAnswers(logical(sum(testAnswers == Conds.Left,2))) = 9;
                testAnswers(logical(sum(testAnswers == Conds.Right,2))) = 10;
                testAnswers = testAnswers - 8;
            case 'studytest'
                trainAnswers(logical(sum(trainAnswers == Conds.Study,2))) = 9;
                trainAnswers(logical(sum(trainAnswers == Conds.Test,2))) = 10;
                trainAnswers = trainAnswers - 8;
                testAnswers(logical(sum(testAnswers == Conds.Study,2))) = 9;
                testAnswers(logical(sum(testAnswers == Conds.Test,2))) = 10;
                testAnswers = testAnswers - 8;
        end
        
        training(length(training)+1).laps = trainLaps;
        training(length(training)).answers = trainAnswers;
        training(length(training)).sessions = trainSessions;
        training(length(training)).conditions = trainConditions;
        
        testing(length(testing)+1).laps = testLaps;
        testing(length(testing)).answers = testAnswers;
        testing(length(testing)).sessions = testSessions;
        testing(length(testing)).conditions = testConditions;
        
        %{
        %Validation
        condsC = unique(training(length(training)).conditions);
        for ccI = 1:length(condsC)
            checkI = 
            training(length(training)).laps(logical(training(length(training)).conditions == condsC(ccI))) ==
            trialbytrial(condsC(ccI)).sessID ==
            training(length(training)).laps(logical(training(length(training)).conditions
            == condsC(ccI)))(1))';
            
            allLapsGood = sum(sum(checkI,1)) == size(checkI,2)
        end
        %}
    end
end

%Next Step is actually go gather that data and run the classifier
decoded = []; %column 1 is the lap indicated by systematic leave-one-out, column 2 is randomly chosen other lap
for tcI = 1:length(testing)
    trainX = [];
    testY = [];
    
    %Gather training lap data
    for lapI = 1:length(training(tcI).laps)
        trainX = [trainX; lblActivity{training(tcI).conditions(lapI)}(training(tcI).laps(lapI),trainingCells)];
    end
    
    %Gather test lap data
    for lapJ = 1:length(testing(tcI).laps)
        testY = [testY; lblActivity{testing(tcI).conditions(lapJ)}(testing(tcI).laps(lapJ),testingCells)];
    end
    
    answersRun = training(tcI).answers;
    if randomize==1
        answersRun = answersRun(randperm(length(answersRun)));
        %trainingAnswers = trainingAnswers(randperm(length(trainingAnswers)));
    end
    
    try
    Mdl = fitcnb(trainX,answersRun,'distributionnames','mn');
    
    [decodedTrial,postProb] = predict(Mdl,testY);
    catch ME
        keyboard
    end
    
    decoded(tcI,:) = decodedTrial';
    postProbs(:,:,tcI) = postProb;
end


end