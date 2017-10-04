function [maxConsec, enoughConsec] = ConsecutiveLaps(trialbytrial,lapThresh)

numCells = length(trialbytrial(1).trialPSAbool{1});
sessions = unique(trialbytrial(1).sessID);
maxConsec  = cell(1,4); enoughConsec = cell(1,4);
for condType = 1:length(trialbytrial)
    maxConsec{condType} = zeros(numCells, length(sessions));
    enoughConsec{condType} = zeros(numCells, length(sessions));
    
    for sess = 1:length(sessions)
        for thisCell = 1:length(trialbytrial(1).trialPSAbool{1})
            lapsUse = trialbytrial(condType).sessID == sess;
            firedLaps = [0; cellfun(@(x) any(x(thisCell,:)), (trialbytrial(condType).trialPSAbool(lapsUse))); 0];
        
            consecInds = [find(diff(firedLaps)==1) find(diff(firedLaps)==-1)];
            howManyConsec = diff(consecInds,1,2);
            
            if any(howManyConsec)
                maxConsec{condType}(thisCell,sess) = max(howManyConsec);
            
                if exist('lapThresh','var')
                enoughConsec{condType}(thisCell,sess) = any(howManyConsec >= lapThresh);
                end
            end
        end
    end
    enoughConsec{condType} = logical(enoughConsec{condType});
end


end