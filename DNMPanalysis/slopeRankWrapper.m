function [slopeRank, RsquaredRank] = slopeRankWrapper(dataVec, days, numPerms)
%dataVec = dailySplitterProp{mouseI}
%days = realDays, etc.

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
        