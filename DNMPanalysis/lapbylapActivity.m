lapbylapActivity(trialbytrial,xmin,xmax)

numConds = length(trialbytrial);
numSess = length(unique(trialbytrial(1).sessID));
numCells = size(trialbytrial(1).trialPSAbool{1},1);

for condI=1:numConds
    laps = length(trialbytrial(condI).sessID);
    for lapI = 1:length(laps)

        
        for cellI = 1:numCells
            minimumX{condI}(lapI,cellI) = min(trialbytrial(condI).trialsX{lapI}(trialbytrial(condI).trialPSAbool{lapI}(cellI)));
            maximumX{condI}(lapI,cellI) = max(trialbytrial(condI).trialsX{lapI}(trialbytrial(condI).trialPSAbool{lapI}(cellI)));
            transientDur{condI}(lapI,cellI) = sum(trialbytrial(condI).trialPSAbool{lapI}(cellI));
            transLength{condI}(lapI,cellI) = maximumX{condI}(lapI,cellI) - minimumX{condI}(lapI,cellI);
            transLengthPosNorm{condI}(lapI,cellI) = transLength{condI}(lapI,cellI) / transientDur{condI}(lapI,cellI);
        end
    end
end
            
    