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
        
        testingLaps(condI).lapNums{sessI} = randi(length(theseLaps));
        
        tls = theseLaps; tls(testingLaps(condI).lapNums{sessI}) = [];
        trainingLaps(condI).lapNums{sessI} = tls;
    end
end

end