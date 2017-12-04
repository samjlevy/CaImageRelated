function lapbylapActivity(trialbytrial,xmin,xmax)

numConds = length(trialbytrial);
numSess = length(unique(trialbytrial(1).sessID));
numCells = size(trialbytrial(1).trialPSAbool{1},1);

minimumX = cell(4,1); 
maximumX = cell(4,1);
transientDur = cell(4,1); 
transLength = cell(4,1); 
transLengthPosNorm = cell(4,1); 

for condI = 1:numConds
    laps = length(trialbytrial(condI).sessID);
    
    minimumX{condI} = zeros(laps,numCells); 
    maximumX{condI} = zeros(laps,numCells);
    transientDur{condI} = zeros(laps,numCells);
    transLength{condI} = zeros(laps,numCells);
    transLengthPosNorm{condI} = zeros(laps,numCells);
    
    for lapI = 1:length(laps) 
        for cellI = 1:numCells
            
            thisCellActivity = trialbytrial(condI).trialsX{lapI}(trialbytrial(condI).trialPSAbool{lapI}(cellI,:));
            
            minimumX{condI}(lapI,cellI) = min([0 thisCellActivity]);
            maximumX{condI}(lapI,cellI) = max([0 thisCellActivity]);
            transientDur{condI}(lapI,cellI) = sum(trialbytrial(condI).trialPSAbool{lapI}(cellI));
            transLength{condI}(lapI,cellI) = maximumX{condI}(lapI,cellI) - minimumX{condI}(lapI,cellI);
            transLengthPosNorm{condI}(lapI,cellI) = transLength{condI}(lapI,cellI) / transientDur{condI}(lapI,cellI);
        end
    end
end
            
end