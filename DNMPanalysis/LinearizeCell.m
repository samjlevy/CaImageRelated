function [allData, allSecond, allMarker] = LinearizeCell(dataIn,secondDat,useMarker)
%dataIn can be numeric or cell, marker is cell array

allData = [];
allMarker = [];
allSecond = [];

for dpI = 1:length(useMarker)
    allMarker = [allMarker; useMarker{dpI}(:)];
    if iscell(dataIn(1))
        allData = [allData; dataIn{dpI}(:)];
        
        if any(secondDat)
            allSecond = [allSecond; secondDat(dpI)*ones(length(dataIn{dpI}),1)]; 
        end
    elseif isnumeric(dataIn(1))
        rTemp = dataIn(dpI,1:length(useMarker{dpI}));
        allData = [allData; rTemp(:)];
        
        if any(secondDat)
            allSecond = [allSecond; secondDat(dpI)*ones(length(useMarker{dpI}),1)];
        end
    end
end

end

   