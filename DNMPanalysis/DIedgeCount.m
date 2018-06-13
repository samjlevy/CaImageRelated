function [edgeMidEdge, edgeMid] = DIedgeCount(inputCounts)

numDays = size(inputCounts,2);

edgeMidEdge = [inputCounts(:,1) sum(inputCounts(:,2:numDays-1),2) inputCounts(:,end)];
edgeMid = [sum(inputCounts(:,[1 numDays]),2) sum(inputCounts(:,2:numDays-1),2)];

end