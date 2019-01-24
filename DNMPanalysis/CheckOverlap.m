function [foundOverlap,overlapAtAll] = CheckOverlap(bigData,checkData)

for rowI = 1:size(bigData,1)
    if iscell(bigData)
        foundOverlap(rowI) = sum(sum(bigData{rowI}==checkData(:),2))>0;
        overlapAtAll(rowI) = sum(sum(min(bigData{rowI}):max(bigData{rowI}) == [min(checkData):max(checkData)]',2))>0;
    elseif isnumeric(bigData)
        foundOverlap(rowI) = sum(sum(bigData(rowI,:)==checkData(:),2))>0;
        overlapAtAll(rowI) = sum(sum(min(bigData(rowI,:)):max(bigData(rowI,:)) == [min(checkData):max(checkData)]',2))>0;
    end
end
    
end