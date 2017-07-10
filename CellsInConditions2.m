function [totalHits, activeLaps, reliability] = CellsInConditions2(PSAbool, starts, stops) %varargin
numCells = size(PSAbool,1);
numLaps = length(starts);

totalHits = zeros(numCells,numLaps);
%for cond = 1:length(varargin)
    %for thisCell = 1:numCells
        for thisEpoch = 1:numLaps
            totalHits(:,thisEpoch) = sum(PSAbool(:,starts(thisEpoch):stops(thisEpoch)),2);
        end
    %end
%end

activeLaps = totalHits > 0;
reliability = sum(activeLaps,2)/numLaps;

end