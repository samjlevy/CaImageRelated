function [trainingLaps, testingLaps] = leaveOneOutAllCombs(trialbytrial)
%organisation: trainingLaps(condition).lapNums{session,1}{lapNum}

numSess = length(unique(trialbytrial(1).sessID));
numConds = length(trialbytrial);

%trainingLaps = cell(numConds,1);
%testingLaps = cell(numConds,1);

for condI = 1:numConds
    
    trainingLaps(condI).lapNums = cell(numSess,1);
    testingLaps(condI).lapNums = cell(numSess,1);
    
    for sessI = 1:numSess
        theseLaps = find(trialbytrial(condI).sessID == sessI);
        
        numLaps = length(theseLaps);
        
        trainingLaps(condI).lapNums{sessI} = cell(numLaps,1);
        testingLaps(condI).lapNums{sessI} = cell(numLaps,1);
        
        for lapI = 1:numLaps
            testingLaps(condI).lapNums{sessI}{lapI} = theseLaps(lapI);
            tempLaps = theseLaps; tempLaps(lapI) = [];
            trainingLaps(condI).lapNums{sessI}{lapI} = tempLaps;
        end
    end
end

end