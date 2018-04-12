function shuffledTBT = shuffleTBTposition(trialbytrial,xlims)%,trialReli
%Does a circular shuffle of spike times relative to positions (rotates
%PSAbool, leaves positions in place)
%If xlims is given as input, chops out those data so rotation stays within
%bounds. xlims has to be empty ( [] ) to not use it

numConds = length(trialbytrial);
%numCells = size(trialbytrial(1).trialPSAbool{1},1)
%numSess = length(unique(trialbytrial(1).sessID(:)))

shuffledTBT = trialbytrial; 
for condI = 1:numConds
    numTrials = length(trialbytrial(condI).trialPSAbool);
    for trialI = 1:numTrials
        
        tpbHere = trialbytrial(condI).trialPSAbool{trialI};
        
        if any(xlims)
            badInds = trialbytrial(condI).trialsX{trialI} > max(xlims) |...
                trialbytrial(condI).trialsX{trialI} < min(xlims);
            shuffledTBT(condI).trialsX{trialI}(badInds) = [];
            shuffledTBT(condI).trialsY{trialI}(badInds) = [];
            tpbHere(:,badInds) = [];
        end
        
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