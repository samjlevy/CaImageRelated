function [difference, percent]=dumbRateRemapping(PFpcthitsA, PFpcthitsB, matches)

numCells = size(matches,1);
numFields = size(PFpcthitsA,2);

difference = nan(numCells, numFields);
percent = nan(numCells, numFields);

for thisCell = 1:numCells
    theseMatches = [matches{thisCell,1}];
    if ~isempty(theseMatches)
        for match = 1:length(theseMatches)
            if theseMatches(match)~=0
                hitsA = PFpcthitsA(thisCell,theseMatches(match));
                hitsB = PFpcthitsB(thisCell,match);
                difference(thisCell,match) = hitsB - hitsA;
                percent(thisCell,match) = min([hitsA hitsB])/max([hitsA hitsB]);
            end
        end
    end
end

end