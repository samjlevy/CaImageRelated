function [allActivity, meanActivity]=dumbRates(PFactivePSA)

numCells = size(PFactivePSA,1);
numFields = size(PFactivePSA,2);

allActivity = nan(numCells,numFields);
meanActivity = nan(numCells,numFields);

for thisCell = 1:numCells
    for thisField = 1:numFields
        activity = PFactivePSA{thisCell,thisField};
        if ~isempty(activity)
            hereAct = 0;
            for thisEpoch = 1:size(activity,1)
                hereAct = hereAct + sum(activity{thisEpoch,1});
            end    
        end
        allActivity(thisCell,thisField) = hereAct;
        meanActivity(thisCell,thisField) = hereAct/size(activity,1);
        %hitActivity(thisCell,thisField) = hereAct/numHits
    end
end
