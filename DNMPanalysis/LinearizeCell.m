function [allData, allMarker] = LinearizeCell(dataIn,useMarker)
%dataIn can be numeric or cell, marker is cell array

allData = [];
allMarker = [];

for dpI = 1:length(useMarker)
    allMarker = [allMarker; useMarker{dpI}(:)];
    if iscell(dataIn(1))
        allData = [allData; dataIn{dpI}(:)];
    elseif isnumeric(dataIn(1))
        rTemp = dataIn(dpI,1:length(useMarker{dpI}));
        allData = [allData; rTemp(:)];
    end
end

end

   