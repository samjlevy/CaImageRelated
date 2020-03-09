function [reliability, aboveThresh, lapSpikes, goodSpikes] = TrialReliability(trialbytrial,thresh)
%organization is reliability{condition}(cell, session)
%reliability: how many laps had a transient
%lapSpikes: average number of spikes per lap
%goodSpikes: average number of spikes per lap for laps with hits

numCells = size(trialbytrial(1).trialPSAbool{1},1);
numDays = length(unique(trialbytrial(1).sessID));
numConds = length(trialbytrial);

reliability = zeros(numCells, numDays, numConds);
aboveThresh = cell(length(trialbytrial),1);
lapSpikes = cell(length(trialbytrial),1);
goodSpikes = cell(length(trialbytrial),1);

sessHere = unique(trialbytrial(1).sessID);

for condType = 1:numConds
    for sess = 1:length(sessHere)
        hitsThisCond = [];
        spikesThisCond = [];
        thisLaps = find(trialbytrial(condType).sessID == sessHere(sess));
        for lap = 1:length(thisLaps)
            thisLap = thisLaps(lap);
            hitsThisCond = [hitsThisCond,...
                any(trialbytrial(condType).trialPSAbool{thisLap},2)];
            spikesThisCond = [spikesThisCond, sum(trialbytrial(condType).trialPSAbool{thisLap},2)];
        end
        %cellfun(@(x) any(x(thisCell,:)), (trialbytrial(condType).trialPSAbool(lapsUse)));
       
        reliab = sum(hitsThisCond,2)/length(thisLaps);
        reliability(:,sess,condType) = reliab;
        aboveThresh{condType}(:,sess) = reliab >= thresh;
        
        lapSpikes{condType}(:,sess) = sum(spikesThisCond,2)/length(thisLaps);
        goodSpikes{condType}(:,sess) = sum(spikesThisCond,2)./sum(hitsThisCond,2);
        
    end
end


end