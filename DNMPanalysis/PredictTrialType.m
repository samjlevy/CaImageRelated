function [decodedTrial,postProb] = PredictTrialType(trainingData,trainingAnswers,testingData,modelType)

switch modelType
    case 'bayes'
        Mdl = fitcnb(trainingData,trainingAnswers,'distributionnames','mn');
    case 'linear'
        Mdl = fitcdiscr(trainingData,trainingAnswers);
end
    
[decodedTrial,postProb] = predict(Mdl,testingData);

end