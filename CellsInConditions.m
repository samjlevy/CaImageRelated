function [conditionHits, isActive] = CellsInConditions(PSAbool, varargin)
numCells = size(PSAbool,1);

conditionHits = zeros(size(varargin{1}.stats.PFnHits,1),length(varargin));
for cond = 1:length(varargin)
    for thisCell = 1:numCells
        %conditionHits(thisCell,cond) =... 
            %sum(PSAbool(thisCell,varargin{cond}.maps.runningInds));
        nowHits = 0;
        for thisEpoch = 1:size(varargin{cond}.epochs,1)
            nowHits = nowHits + any(PSAbool(thisCell,...
                varargin{cond}.epochs(thisEpoch,1):varargin{cond}.epochs(thisEpoch,2)));
        end
        conditionHits(thisCell,cond) = nowHits;
    end
end

isActive = conditionHits > 0;

end