function [shuffMinTbtA, shuffMinTbtB] = ShuffleMinTBTs(minTbtA,minTbtB,shuffType)

eachNumTrials =[length(minTbtA.trialsX) length(minTbtB.trialsX)];
numTrials = max(eachNumTrials);
switch shuffType
    case 'random'
        shuffZero = zeros(round(numTrials/2),1);
        shuffOne = ones(numTrials-length(shuffZero),1);
        shuffThis = [shuffZero; shuffOne];
        shuffThis = logical(shuffThis(randperm(numTrials)));
    case 'alternate'
        shuffThis = zeros(numTrials,1);
        shuffThis(1:2:numTrials) = 1;
        shuffThis = logical(shuffThis);
end
shuffFromA = shuffThis;
shuffFromB = ~shuffThis;

if eachNumTrials(1) < length(shuffFromA)
    extraIndsA = length(shuffFromA) - eachNumTrials(1);
    shuffFromA(end-(extraIndsA-1):end) = [];
end

if eachNumTrials(2) < length(shuffFromB)
    extraIndsB = length(shuffFromB) - eachNumTrials(2);
    shuffFromB(end-(extraIndsB-1):end) = [];
end
    

shuffMinTbtA.trialsX(shuffFromA,1) = minTbtA.trialsX(shuffFromA);
shuffMinTbtA.trialsX(shuffFromB,1) = minTbtB.trialsX(shuffFromB);
shuffMinTbtA.trialsY(shuffFromA,1) = minTbtA.trialsY(shuffFromA);
shuffMinTbtA.trialsY(shuffFromB,1) = minTbtB.trialsY(shuffFromB);
shuffMinTbtA.trialPSAbool(shuffFromA,1) = minTbtA.trialPSAbool(shuffFromA);
shuffMinTbtA.trialPSAbool(shuffFromB,1) = minTbtB.trialPSAbool(shuffFromB);
shuffMinTbtA.trialRawTrace(shuffFromA,1) = minTbtA.trialRawTrace(shuffFromA);
shuffMinTbtA.trialRawTrace(shuffFromB,1) = minTbtB.trialRawTrace(shuffFromB);
shuffMinTbtA.sessID(shuffFromA,1) = minTbtA.sessID(shuffFromA);
shuffMinTbtA.sessID(shuffFromB,1) = minTbtB.sessID(shuffFromB);
shuffMinTbtA.name = minTbtA.name;
shuffMinTbtA.lapNumber(shuffFromA,1) = minTbtA.lapNumber(shuffFromA);
shuffMinTbtA.lapNumber(shuffFromB,1) = minTbtB.lapNumber(shuffFromB);

shuffMinTbtB.trialsX(~shuffFromA,1) = minTbtA.trialsX(~shuffFromA);
shuffMinTbtB.trialsX(~shuffFromB,1) = minTbtB.trialsX(~shuffFromB);
shuffMinTbtB.trialsY(~shuffFromA,1) = minTbtA.trialsY(~shuffFromA);
shuffMinTbtB.trialsY(~shuffFromB,1) = minTbtB.trialsY(~shuffFromB);
shuffMinTbtB.trialPSAbool(~shuffFromA,1) = minTbtA.trialPSAbool(~shuffFromA);
shuffMinTbtB.trialPSAbool(~shuffFromB,1) = minTbtB.trialPSAbool(~shuffFromB);
shuffMinTbtB.trialRawTrace(~shuffFromA,1) = minTbtA.trialRawTrace(~shuffFromA);
shuffMinTbtB.trialRawTrace(~shuffFromB,1) = minTbtB.trialRawTrace(~shuffFromB);
shuffMinTbtB.sessID(~shuffFromA,1) = minTbtA.sessID(~shuffFromA);
shuffMinTbtB.sessID(~shuffFromB,1) = minTbtB.sessID(~shuffFromB);
shuffMinTbtB.name = minTbtB.name;
shuffMinTbtB.lapNumber(~shuffFromA,1) = minTbtA.lapNumber(~shuffFromA);
shuffMinTbtB.lapNumber(~shuffFromB,1) = minTbtB.lapNumber(~shuffFromB);

badIndsA = cell2mat(cellfun(@isempty,shuffMinTbtA.trialsX,'UniformOutput',false));
shuffMinTbtA.trialsX(badIndsA) = [];
shuffMinTbtA.trialsY(badIndsA) = [];
shuffMinTbtA.trialPSAbool(badIndsA) = [];
shuffMinTbtA.trialRawTrace(badIndsA) = [];
shuffMinTbtA.sessID(badIndsA) = [];
shuffMinTbtA.lapNumber(badIndsA) = [];

badIndsB = cell2mat(cellfun(@isempty,shuffMinTbtB.trialsX,'UniformOutput',false));
shuffMinTbtB.trialsX(badIndsB) = [];
shuffMinTbtB.trialsY(badIndsB) = [];
shuffMinTbtB.trialPSAbool(badIndsB) = [];
shuffMinTbtB.trialRawTrace(badIndsB) = [];
shuffMinTbtB.sessID(badIndsB) = [];
shuffMinTbtB.lapNumber(badIndsB) = [];

end