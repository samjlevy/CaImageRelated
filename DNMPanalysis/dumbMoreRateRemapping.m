function [difference, percent]=dumbMoreRateRemapping(FiringA, FiringB, matches)

numCells = size(matches,1);
numFields = size(PFpcthitsA,2);

[totalActA, hitsA]=totalActivity(FiringA);
[totalActB, hitsB]=totalActivity(FiringB);
meanA = totalActA/size(FiringA,1);
meanB = totalActB/size(FiringB,1);
nonZeroMeanA = totalActA/hitsA;
nonZeroMeanB = totalActB/hitsB;

difference = nan(numCells, numFields);
percent = nan(numCells, numFields);

activityA = totalActA;
activityB = totalActB;
for thisCell = 1:numCells
    theseMatches = [matches{thisCell,1}];
    if ~isempty(theseMatches)
        for match = 1:length(theseMatches)
            if theseMatches(match)~=0
                actA = activityA(thisCell,theseMatches(match));
                actB = activityB(thisCell,match);
                difference(thisCell,match) = actB - actA;
                percent(thisCell,match) = min([actA actB])/max([actA actB]);
            end
        end
    end
end

end
function [totalAct, allHits]=totalActivity(activityVector)
numCells = size(acivityVector,1);
numFields = size(activityVector,2);
activity = nan(numCells, numFields);
allHits = nan(numCells, numFields);

for thisCell = 1:numCells
    for thisField = 1:numFields
        if any(activityVector{thisCell,thisField})
        totalAct = 0; hits = 0;
            for epoch=1:size(activityVector,1)
                totalAct = totalAct + sum(activityVector{epoch});
                hits = hits + any(activityVector{epoch});
            end
        activity(thisCell,thisField) = totalAct;   
        allHits(thisCell,thisField) = hits;
        end
    end
end

end

