function [slopeRank, RsquaredRank] = slopeRankWrapper(dataVec, days, numPerms)
%dataVec = dailySplitterProp{mouseI}
%days = realDays, etc.
%This works for any set of points where data vec is the y, days is x

numEntries = length(dataVec);

if isempty(days)
    days = 1:numEntries;
end

for permI = 1:numPerms
    dataPerm = dataVec(randperm(length(dataVec)));
    [shuffSlope(permI), ~, ~, rr] = fitLinRegSL(dataPerm,days);
    shuffRsquared(permI) = rr.Ordinary;
end
    
[slope, ~, ~, rr] = fitLinRegSL(dataVec,days);
Rsquared = rr.Ordinary;

RsquaredRank = sum(Rsquared > shuffRsquared);

slopeRank = sum(slope > shuffSlope);

end
        