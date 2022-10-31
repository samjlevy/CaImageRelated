function [sortedData,reorderedData] = SortAndReorder(sortData,dataToReorder)

% assume that sorted data is an n x 1 vector

[sortedData,sortOrder] = sort(sortData,1,'ascend');
reorderedData = dataToReorder(sortOrder,:);

end