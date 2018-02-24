function shuffledTBT = shuffleTBTposition(trialbytrial)%,trialReli
%Does a circular shuffle of spike times relative to positions (rotates
%PSAbool, leaves positions in place)

numConds = length(trialbytrial);
%numCells = size(trialbytrial(1).trialPSAbool{1},1)
%numSess = length(unique(trialbytrial(1).sessID(:)))

shuffledTBT = trialbytrial; 
for condI = 1:numConds
    numTrials = length(trialbytrial(condI).trialPSAbool);
    for trialI = 1:numTrials
        
        tpbHere = trialbytrial(condI).trialPSAbool{trialI};
        trialDur = size(tpbHere,2);
        
        offset = randi(trialDur);
       
        switch offset
            case 1
                indsOrder = 1:trialDur;
            otherwise
                indsOrder = [offset:trialDur 1:(offset-1)];
        end
        
        shuffledTBT(condI).trialPSAbool{trialI,1} = tpbHere(:, indsOrder); 
    end
end

end