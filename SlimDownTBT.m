function trimmedTBT = SlimDownTBT(trialbytrial,dayChunk)
%This pares down a trialbytrial to the day chunk indicators, for example [0 0.34] 
%would slim it down to the first third of laps
%dayChunk needs to be a 2 number vector indicating the proportion of laps
%to start and finish on. In theory, could also do it as a proportion of
%actual laps that should be there (to account for error laps)

numConds = length(trialbytrial);
daysHere = unique(trialbytrial(1).sessID);
numDays = length(daysHere);

trimmedTBT.trialsX = {};
trimmedTBT.trialsY = {};
trimmedTBT.trialPSAbool = {};
trimmedTBT.trialRawTrace = {};
trimmedTBT.sessID = [];
trimmedTBT.lapNumber = [];
trimmedTBT.name = trialbytrial.name;
for condI = 1:numConds
    trimmedTBT(condI).name = trialbytrial(condI).name;
    for sessI = 1:numDays
        lapsHere = trialbytrial(condI).sessID == daysHere(sessI);
        lapsHereInds = find(lapsHere);
        numLapsHere = length(lapsHereInds);
        
        lapBounds = round(dayChunk*numLapsHere);
        lapBounds(1) = lapBounds(1)+1;
        if lapBounds(1) == 0; lapBounds(1) = 1; end
        if lapBounds(2) > numLapsHere; lapBounds(2) = numLapsHere; end
        
        lapsGet = lapsHereInds(lapBounds(1):lapBounds(2));
        
        trimmedTBT(condI).trialsX = [trimmedTBT(condI).trialsX; trialbytrial(condI).trialsX(lapsGet)];
        trimmedTBT(condI).trialsY = [trimmedTBT(condI).trialsY; trialbytrial(condI).trialsY(lapsGet)];
        trimmedTBT(condI).trialPSAbool = [trimmedTBT(condI).trialPSAbool; trialbytrial(condI).trialPSAbool(lapsGet)];
        trimmedTBT(condI).trialRawTrace = [trimmedTBT(condI).trialRawTrace; trialbytrial(condI).trialRawTrace(lapsGet)];
        trimmedTBT(condI).sessID = [trimmedTBT(condI).sessID; trialbytrial(condI).sessID(lapsGet)];
        trimmedTBT(condI).lapNumber = [trimmedTBT(condI).lapNumber; trialbytrial(condI).lapNumber(lapsGet)];
    end
end

end