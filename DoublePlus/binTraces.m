function binnedTrace = binTraces(trace,binSize,overlap,binFunction)

tl = size(trace,2);
numCells = size(trace,1);

binStarts = 1:(binSize-overlap):(tl-binSize);
binStops = binStarts+(binSize-1);

bins = mat2cell([binStarts(:), binStops(:)],ones(length(binStarts),1))';

switch binFunction
    case 'mean'
        binnedTrace = cell2mat(cellfun(@(x) mean(trace(:,x(1):x(2)),2),bins,'UniformOutput',false));
    case 'max'
        binnedTrace = cell2mat(cellfun(@(x) max(trace(:,x(1):x(2)),[],2),bins,'UniformOutput',false));
end

end

