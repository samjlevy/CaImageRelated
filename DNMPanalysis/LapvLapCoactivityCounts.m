function [coacCounts] = LapvLapCoactivityCounts(trialbytrial)
% This would be for other kinds of operations
% Lap pairing describes how to get laps to compaire
%   - allToAll: all trials in condPairs(condI,1) vs all trials in condPairs(condI,2)
%   - seqLaps: will look for lap numbers that immediately follow each other
%   and do those pairs
%   - randSubset: will get randPct % of lap pairs and use those

numSess = 1:length(unique(trialbytrial(1).sessID));
numCells = size(trialbytrial(1).trialPSAbool{1},1);
numConds = length(trialbytrial);

for condI = 1:numConds
    ca(condI).cellActive = cellfun(@(x) sum(x,2)>0,trialbytrial(condI).trialPSAbool,'UniformOutput',false);
end

for sessI = 1:numSess
    for condI = 1:numConds
        coacCounts{sessI,condI} = zeros(numCells,numCells);
        
        laps = find(trialbytrial(condI).sessID == sessI);
        
        for lapI = 1:length(laps)
            coacCounts{sessI,condI} = coacCounts{sessI,condI} +...
                (ca(condI).cellActive{lapI}(:) & ca(condI).cellActive{lapI}(:)');
        end
        
        % Many different ways to normalize, leave that for later
    end
end

end