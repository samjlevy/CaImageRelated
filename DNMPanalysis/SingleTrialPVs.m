function [singleTrialTMap] = SingleTrialPVs(trialbytrial,xBinLims,yBinLims)

numConds = length(trialbytrial);
numCells = size(trialbytrial(1).trialPSAbool{1},1);

linearEdges = xBinLims;

for condI = 1:numConds
    numTrials = length(trialbytrial(condI).trialPSAbool);
    firedAtAll{condI} = cell(numTrials,1);
    likelihood{condI} = cell(numTrials,1);
    for trialI = 1:numTrials
        xHere = trialbytrial(condI).trialsX{trialI};
        yHere = trialbytrial(condI).trialsY{trialI};
        PSAhere = trialbytrial(condI).trialPSAbool{trialI};
        
        posUse = xHere;
        
        %Same code as for place fields
        [OccMap{condI,trialI},RunOccMap{condI,trialI},xBin{condI,trialI}]...
            = MakeOccMapLin(xHere,true(length(xHere),1),true(length(xHere),1),xBinLims);
            
        cellSpiking = mat2cell(PSAhere,ones(numCells,1),size(PSAhere,2)); %Indiv cellArr slot per cell
        spikePos = cellfun(@(x) posUse(x),cellSpiking,'UniformOutput',false); %only positions by logical cell activity
        spikeCounts = cellfun(@(x) histcounts(x,linearEdges),spikePos,'UniformOutput',false); %counts of positions in bins
        singleTrialTMap{condI}{trialI,1}(1:numCells,1) = cellfun(@(x) x./RunOccMap{condI,trialI},spikeCounts,'UniformOutput',false); %normalize by occupancy
        singleTrialTMap{condI}{trialI} = cell2mat(singleTrialTMap{condI}{trialI});
    end
    
end

end
