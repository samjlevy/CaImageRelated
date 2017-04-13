function [overlaps, pctsA, pctsB]=PFoverLapBatch(PlacefieldsA, PlacefieldsB, matches)
%Runs a batch version of Placefieldoverlap, assumes sizes are right

numCells = size(matches,1);
width = max([size(PlacefieldsA,2) size(PlacefieldsB,2)]);

%overlaps = cell(numCells,width);
overlaps=NaN(numCells,width);
pctsA = cell(numCells,width);
pctsB = cell(numCells,width);


for thisCell = 1:numCells
    theseMatches = [matches{thisCell,1}];
    if ~isempty(theseMatches)
        for match = 1:length(theseMatches)
            if theseMatches(match)~=0
                FieldA = PlacefieldsA{thisCell,theseMatches(match)};
                FieldB = PlacefieldsB{thisCell,match};
                [overlaps(thisCell,match),...
                    pctsA{thisCell,match},pctsB{thisCell,match}] = ...
                    PlaceFieldOverlap(FieldA, FieldB);
            end
        end
    end
end
                    
end