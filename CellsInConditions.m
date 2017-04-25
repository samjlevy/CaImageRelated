function [conditionHits, isActive] = CellsInConditions(PSAbool, varargin)
numCells = size(PSAbool,1);

conditionHits = zeros(size(varargin{1}.stats.PFnHits,1),length(varargin));
for cond = 1:length(varargin)
    for thisCell = 1:numCells
        conditionHits(thisCell,cond) =... 
            sum(PSAbool(thisCell,varargin{cond}.maps.runningInds));
    end
end

isActive = conditionHits > 0;

end