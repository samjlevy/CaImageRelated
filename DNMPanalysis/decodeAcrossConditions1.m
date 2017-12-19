function [trainLapNumbers, trainLapConds, testLapNumbers, testLapConds,...
    testCondDecoded] = decodeAcrossConditions1(trialbytrial, condsInclude,...
    trainingLaps, testingLaps, lblActivity, sessI, typePredict, cellsUse)
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

if isempty(cellsUse)
    cellsUse = true(size(trialbytrial(1).trialPSAbool{1},1),1);
end
cellsUse = logical(cellsUse);

numSess = length(unique(trialbytrial(1).sessID));
numConds = length(trialbytrial);
[Conds] = GetTBTconds(trialbytrial);

trainX = [];
condsY = [];
%for sessI = 1:numSess

trainLapNumbers = [];
trainLapConds = [];
testLapNumbers = [];
testLapConds = [];
testCondDecoded = [];

for testcondJ = 1:length(condsInclude)
    testCondI = condsInclude(testcondJ);
        
    otherConds = condsInclude(condsInclude~=testCondI);    
    
    %testLapsI = nan(length(condsInclude),1);
    %testAnswers = nan(length(condsInclude),1);
    %trainingLapsI = [];
    %trainingAnswers = [];
    
    %Preallocate?
    for testLapJ = 1:length(testingLaps(testCondI).lapNums{sessI})
        % for each lap in this condition, base other stuff around this
        testLapsI = testingLaps(testCondI).lapNums{sessI}{testLapJ};
        testAnswers = testCondI;
        
        % get initial training laps and answers
        trainingLapsI = trainingLaps(testCondI).lapNums{sessI}{testLapJ};
        trainingAnswers = testCondI*ones(length(trainingLapsI),1);
        
        trainX = lblActivity{testCondI,1}(trainingLapsI,cellsUse);
        testY = lblActivity{testCondI,1}(testLapsI(1),cellsUse);
        % and get the same for each of the other conditions
        for ocI = 1:length(otherConds)
            % randomly pick a lap from the other conditions
            otherTestLapsJ = randi(length(testingLaps(otherConds(ocI)).lapNums{sessI}));
            testLapsI(ocI+1,1) =  testingLaps(otherConds(ocI)).lapNums{sessI}{otherTestLapsJ};
            testAnswers(ocI+1,1) = otherConds(ocI);
            
            % use that randomly picked lap to choose training data
            trainingLapsJ = trainingLaps(otherConds(ocI)).lapNums{sessI}{otherTestLapsJ};
            trainingLapsI = [trainingLapsI; trainingLapsJ];
            trainingAnswers = [trainingAnswers; otherConds(ocI)*ones(length(trainingLapsJ),1)];
            
            trainX = [trainX; lblActivity{otherConds(ocI),1}(trainingLapsJ,cellsUse)];
            testY = [testY; lblActivity{otherConds(ocI),1}(testLapsI(ocI+1),cellsUse)];
        end
        
        switch typePredict
            case 'all'
                %do nothing?
            case 'leftright'
                trainingAnswers(logical(sum(trainingAnswers == Conds.Left,2))) = 9;
                trainingAnswers(logical(sum(trainingAnswers == Conds.Right,2))) = 10;
                trainingAnswers = trainingAnswers - 8;
                testAnswers(logical(sum(testAnswers == Conds.Left,2))) = 9;
                testAnswers(logical(sum(testAnswers == Conds.Right,2))) = 10;
                testAnswers = testAnswers - 8;
            case 'studytest'
                trainingAnswers(logical(sum(trainingAnswers == Conds.Study,2))) = 9;
                trainingAnswers(logical(sum(trainingAnswers == Conds.Test,2))) = 10;
                trainingAnswers = trainingAnswers - 8;
                testAnswers(logical(sum(testAnswers == Conds.Study,2))) = 9;
                testAnswers(logical(sum(testAnswers == Conds.Test,2))) = 10;
                testAnswers = testAnswers - 8;
        end
        
        Mdl = fitcnb(trainX,trainingAnswers,'distributionnames','mn');

        [decodedTrial,postProbs] = predict(Mdl,testY);
        
        
        trainLapNumbers = [trainLapNumbers; trainingLapsI'];
        trainLapConds = [trainLapConds; trainingAnswers'];
        testLapNumbers = [testLapNumbers; testLapsI'];
        testLapConds = [testLapConds; testAnswers'];
        testCondDecoded = [testCondDecoded; decodedTrial'];
        
        
        %Could either do model and prediction here, or organize for output
        %(testcondJ).{testLapJ}
    end

end

end