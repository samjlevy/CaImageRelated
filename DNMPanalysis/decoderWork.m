sessI = 6;
condI = 4;

X = transientDur{condI,1}(trainingLaps(condI).lapNums{sessI,1},:);
Y = lapBlockNums{4}(trainingLaps(condI).lapNums{sessI,1},:);

testX = transientDur{condI,1}(testingLaps(condI).lapNums{sessI,1},:);
answer = lapBlockNums{condI,1}(testingLaps(condI).lapNums{sessI,1});


Mdl = fitcnb(X,Y,'distributionnames','mn');

[decodedTrial,postProbs] = predict(Mdl,testX);