function shuffledTBT = ShuffleTrialsAcrossDays(trialbytrial)
%Randomly reassigns shuffles over days, independently for each condition

for condI = 1:length(trialbytrial)
    shuffleOrder = randperm(length(trialbytrial(condI).sessID));
    
    shuffledTBT(condI).trialsX = {trialbytrial(condI).trialsX{shuffleOrder}};
    shuffledTBT(condI).trialsY = {trialbytrial(condI).trialsY{shuffleOrder}};
    shuffledTBT(condI).trialPSAbool = {trialbytrial(condI).trialPSAbool{shuffleOrder}};
    
    shuffledTBT(condI).sessID = trialbytrial(condI).sessID;
    shuffledTBT(condI).name = trialbytrial(condI).name;
    
end

end