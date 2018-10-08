function shuffledTBT = ShuffleTrialsAcrossDays(trialbytrial,dayA,dayB)
%Randomly reassigns shuffles over days, independently for each condition

shuffledTBT = trialbytrial;

for condI = 1:length(trialbytrial)
    trialsA = find(trialbytrial(condI).sessID==dayA);
    trialsB = find(trialbytrial(condI).sessID==dayB);
    
    trialsBoth = [trialsA; trialsB];
    dayMarker = [1*ones(length(trialsA),1); 2*ones(length(trialsB),1)];
    newOrder = trialsBoth(randperm(length(trialsBoth)));
    
    shuffledTBT(condI).trialsX(newOrder) = trialbytrial(condI).trialsX(trialsBoth);
    shuffledTBT(condI).trialsY(newOrder) = trialbytrial(condI).trialsY(trialsBoth);
    shuffledTBT(condI).trialPSAbool(newOrder) = trialbytrial(condI).trialPSAbool(trialsBoth);
    shuffledTBT(condI).trialRawTrace(newOrder) = trialbytrial(condI).trialRawTrace(trialsBoth);
    shuffledTBT(condI).lapNumber(newOrder) = trialbytrial(condI).lapNumber(trialsBoth);
    %leave sessID alone
end




%{
for condI = 1:length(trialbytrial)
    shuffleOrder = randperm(length(trialbytrial(condI).sessID));
    
    %shuffledTBT(condI).trialsX = cell(length(trialbytrial(condI).trialsX),1);
    %shuffledTBT(condI).trialsY = cell(length(trialbytrial(condI).trialsY),1);
    %shuffledTBT(condI).trialPSAbool = cell(length(trialbytrial(condI).trialPSAbool),1);
    
    shuffledTBT(condI).trialsX = {trialbytrial(condI).trialsX{shuffleOrder}}';
    shuffledTBT(condI).trialsY = {trialbytrial(condI).trialsY{shuffleOrder}}';
    shuffledTBT(condI).trialPSAbool = {trialbytrial(condI).trialPSAbool{shuffleOrder}}';
    
    shuffledTBT(condI).sessID = trialbytrial(condI).sessID;
    shuffledTBT(condI).name = trialbytrial(condI).name;
    
end
%}
end