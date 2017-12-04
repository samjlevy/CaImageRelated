function [trainingLaps, testingLaps] = decodeAssignLeaveOneOut(trialbytrial)


numSess = length(unique(trialbytrial(1).sessID));
numConds = length(trialbytrial);

%trainingLaps = cell(numConds,1);
%testingLaps = cell(numConds,1);

for condI = 1:numConds
    
    trainingLaps(condI).lapNums = cell(numSess,1);
    testingLaps(condI).lapNums = cell(numSess,1);
    
    for sessI = 1:numSess
        theseLaps = find(trialbytrial(condI).sessID == sessI);
        
        randomLap = randi(length(theseLaps));
        testingLaps(condI).lapNums{sessI} = theseLaps(randomLap);
        
        tls = theseLaps; tls(randomLap) = [];
        trainingLaps(condI).lapNums{sessI} = tls;
    end
end

end