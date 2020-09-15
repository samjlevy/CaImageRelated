function [reliability, aboveThresh, nLapsActive, goodSpikes] = TrialReliability(trialbytrial,thresh,poolConds,xBinLims,yBinLims)
%organization is reliability{condition}(cell, session)
%reliability: how many laps had a transient
%lapSpikes: average number of frames spiking per lap
%goodSpikes: average number of frames spiking per lap for laps with hits 

numCells = size(trialbytrial(1).trialPSAbool{1},1);
numDays = length(unique(trialbytrial(1).sessID));
numConds = length(trialbytrial);


sessHere = unique(trialbytrial(1).sessID);

if poolConds == false
    reliability = zeros(numCells, numDays, numConds);
aboveThresh = cell(length(trialbytrial),1);
lapSpikes = cell(length(trialbytrial),1);
goodSpikes = cell(length(trialbytrial),1);

    for condType = 1:numConds
        for sess = 1:length(sessHere)
            hitsThisCond = [];
            spikesThisCond = [];
            thisLaps = find(trialbytrial(condType).sessID == sessHere(sess));
            for lap = 1:length(thisLaps)
                thisLap = thisLaps(lap);
                psaLap = trialbytrial(condType).trialPSAbool{thisLap};
                lapFilter = true(1,size(psaLap,2));
                if any(xBinLims)
                    xHere = trialbytrial(condType).trialsX{thisLap};
                    lapFilter = lapFilter & xHere>=min(xBinLims) & xHere<=max(xBinLims);
                end
                if any(yBinLims)
                    yHere = trialbytrial(condType).trialsY{thisLap};
                    lapFilter = lapFilter & yHere>=min(yBinLims) & yHere<=max(yBinLims);
                end
                psaLap = psaLap(:,lapFilter);
                
                hitsThisCond = [hitsThisCond,...
                    any(psaLap,2)];
                spikesThisCond = [spikesThisCond, sum(trialbytrial(condType).trialPSAbool{thisLap},2)];
            end
            %cellfun(@(x) any(x(thisCell,:)), (trialbytrial(condType).trialPSAbool(lapsUse)));
            nLapsActive(:,sess,condType) = sum(hitsThisCond,2);

            reliab = sum(hitsThisCond,2)/length(thisLaps);
            reliability(:,sess,condType) = reliab;
            aboveThresh{condType}(:,sess) = reliab >= thresh;

            lapSpikes{condType}(:,sess) = sum(spikesThisCond,2)/length(thisLaps);
            goodSpikes{condType}(:,sess) = sum(spikesThisCond,2)./sum(hitsThisCond,2);

        end
    end
elseif poolConds == true
    for sess = 1:length(sessHere)
        hitsAllConds = [];
        spikesAllConds = [];
        allLaps = [];
        for condType = 1:numConds
            
            hitsThisCond = [];
            spikesThisCond = [];
            thisLaps = find(trialbytrial(condType).sessID == sessHere(sess));
            for lap = 1:length(thisLaps)
                thisLap = thisLaps(lap);
                
                psaLap = trialbytrial(condType).trialPSAbool{thisLap};
                lapFilter = true(1,size(psaLap,2));
                if any(xBinLims)
                    xHere = trialbytrial(condType).trialsX{thisLap};
                    lapFilter = lapFilter & xHere>=min(xBinLims) & xHere<=max(xBinLims);
                end
                if any(yBinLims)
                    yHere = trialbytrial(condType).trialsY{thisLap};
                    lapFilter = lapFilter & yHere>=min(yBinLims) & yHere<=max(yBinLims);
                end
                psaLap = psaLap(:,lapFilter);
                
                hitsThisCond = [hitsThisCond,...
                    any(trialbytrial(condType).trialPSAbool{thisLap},2)];
                spikesThisCond = [spikesThisCond, sum(trialbytrial(condType).trialPSAbool{thisLap},2)];
            end
            
            hitsAllConds = [hitsAllConds, hitsThisCond];
            spikesAllConds = [spikesAllConds, spikesThisCond];
            allLaps = [allLaps; thisLaps];
            
        end
        %cellfun(@(x) any(x(thisCell,:)), (trialbytrial(condType).trialPSAbool(lapsUse)));
        nLapsActive(:,sess,condType) = sum(hitsAllConds,2);
        
        reliab = sum(hitsAllConds,2)/length(allLaps);
        reliability(:,sess) = reliab;
        aboveThresh(:,sess) = reliab >= thresh;
        
        lapSpikes{condType}(:,sess) = sum(spikesAllConds,2)/length(allLaps);
        goodSpikes{condType}(:,sess) = sum(spikesAllConds,2)./sum(hitsAllConds,2);
        
    end
    
end

end