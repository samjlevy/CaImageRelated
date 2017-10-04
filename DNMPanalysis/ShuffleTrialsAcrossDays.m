function shuffledTBT = ShuffleTrialsAcrossDays(trialbytrial)

for condI = 1:length(trialbytrial)
    shuffleOrder = randperm(length(trialbytrial(condI).sessID));
    
    shuffledTBT(condI).trialsX = {trialbytrial(condI).trialsX{shuffleOrder}};
    shuffledTBT(condI).trialsY = {trialbytrial(condI).trialsY{shuffleOrder}};
    shuffledTBT(condI).trialsPSAbool = {trialbytrial(condI).trialsPSAbool{shuffleOrder}};
    
    shuffledTBT(condI).sessID = trialbytrial(condI).sessID;
    shuffledTBT(condI).name = trialbytrial(condI).name;
    
end

end