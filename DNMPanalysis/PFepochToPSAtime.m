function [PFepochPSA] = PFepochToPSAtime ( place_stats_file, isRunningInds, pos_file )
%returns timestamps in PSAbool time where PFstats says the mouse is in the
%field

if ischar(isRunningInds)
    load(isRunningInds,'runningInds')
elseif isdouble(isRunningInds)
    runningInds = isRunningInds;
end

load(place_stats_file,'PFepochRaw')
load(pos_file,'x_adj_cm','y_adj_cm')

numCells = size(PFepochRaw,1); numFields = size(PFepochRaw,2);
PFepochPSA = cell(numCells,numFields);
for thisCell = 1:numCells
    for thisField = 1:numFields
        if any(PFepochRaw{thisCell,thisField})
            PFepochPSA = runningInds(PFepochRaw{thisCell,thisField});
        end
    end
end



end