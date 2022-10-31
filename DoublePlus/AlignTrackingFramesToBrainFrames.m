function [alignedTable] = AlignTrackingFramesToBrainFrames(dataTable,trackingTime,brainTime,columnsInterp)
% This assumes that the frame numbers in tracking time are still aligned
% (e.g. 1==1) to those in the table

cNames = dataTable.Properties.VariableNames;
alignedTable = dataTable;
if isempty(columnsInterp)
    for colI = 1:size(behavTable,2)
        if isnumeric(dataTable.(cNames{colI}))
            columnsInterp{numel(columnsInterp)+1} = cNames{colI};
        end
    end
end


for inI = 1:numel(columnsInterp)
    nLaps = numel(dataTable.(columnsInterp{inI}));
    datH = nan(size(dataTable.(columnsInterp{inI})));
    origFrames = dataTable.(columnsInterp{inI});
    for lapI = 1:nLaps
        frameH = origFrames(lapI);
        [minH,minInd] = min(abs(brainTime - trackingTime(frameH)));

         datH(lapI) = minInd;
    end

    alignedTable.(columnsInterp{inI}) = datH;
end

end