function [growingShuffTbtOne, growingShuffTbtTwo] = DayShuffleGrowingTBT(trialbytrial,dayPairs)
%Shuffles trials across the pairs of days, puts the shuffled days into
%separate TBTs, in which sessID refers to an index in day pair
numDayPairs = size(dayPairs,1);

growingShuffTbtOne(1:length(trialbytrial)) = struct('trialsX',[],'trialsY',[],'trialPSAbool',[],'trialRawTrace',[],'lapNumber',[],'sessID',[]); 
growingShuffTbtTwo = growingShuffTbtOne;
              
for dpI = 1:numDayPairs
    %Shuffle trials
    condDayShuffA = ShuffleTrialsAcrossDays(trialbytrial,dayPairs(dpI,1),dayPairs(dpI,2));
    
    %Pile them into a new tbt format
    for condI = 1:length(trialbytrial) 
        %Day pair(x,1)
        trialsGetAone = find(condDayShuffA(condI).sessID == dayPairs(dpI,1));%1st column in day pair
        
        growingShuffTbtOne(condI).trialsX = [growingShuffTbtOne(condI).trialsX; condDayShuffA(condI).trialsX(trialsGetAone)];
        growingShuffTbtOne(condI).trialsY = [growingShuffTbtOne(condI).trialsY; condDayShuffA(condI).trialsY(trialsGetAone)];
        growingShuffTbtOne(condI).trialPSAbool = [growingShuffTbtOne(condI).trialPSAbool; condDayShuffA(condI).trialPSAbool(trialsGetAone)];
        growingShuffTbtOne(condI).trialRawTrace = [growingShuffTbtOne(condI).trialRawTrace; condDayShuffA(condI).trialRawTrace(trialsGetAone)];
        growingShuffTbtOne(condI).lapNumber = [growingShuffTbtOne(condI).lapNumber; condDayShuffA(condI).lapNumber(trialsGetAone)];
        
        growingShuffTbtOne(condI).sessID = [growingShuffTbtOne(condI).sessID; dpI*ones(length(trialsGetAone),1)];
        
        %Day pair(x,2)
        trialsGetAtwo = find(condDayShuffA(condI).sessID == dayPairs(dpI,2));%2nd column in day pair
        
        growingShuffTbtTwo(condI).trialsX = [growingShuffTbtTwo(condI).trialsX; condDayShuffA(condI).trialsX(trialsGetAtwo)];
        growingShuffTbtTwo(condI).trialsY = [growingShuffTbtTwo(condI).trialsY; condDayShuffA(condI).trialsY(trialsGetAtwo)];
        growingShuffTbtTwo(condI).trialPSAbool = [growingShuffTbtTwo(condI).trialPSAbool; condDayShuffA(condI).trialPSAbool(trialsGetAtwo)];
        growingShuffTbtTwo(condI).trialRawTrace = [growingShuffTbtTwo(condI).trialRawTrace; condDayShuffA(condI).trialRawTrace(trialsGetAtwo)];
        growingShuffTbtTwo(condI).lapNumber = [growingShuffTbtTwo(condI).lapNumber; condDayShuffA(condI).lapNumber(trialsGetAtwo)];
        
        growingShuffTbtTwo(condI).sessID = [growingShuffTbtTwo(condI).sessID; dpI*ones(length(trialsGetAtwo),1)];
    end
end

end