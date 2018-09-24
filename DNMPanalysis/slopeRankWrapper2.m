function [slopeRank, RsquaredRank] = slopeRankWrapper2(dataVec, days, numPerms,pThresh)
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

firstLim = numPerms*(pThresh/2);
CIbounds = [firstLim numPerms-firstLim];

pUse = numPerms*pThresh;

rrLow = sum(Rsquared < shuffRsquared) > pUse;
rrHigh = sum(Rsquared > shuffRsquared) > numPerms-pUse;
switch rrLow + rrHigh
    case 0
        RsquaredRank = 0;
    case 1
        if rrLow==1
            RsquaredRank = numPerms - sum(Rsquared < shuffRsquared);
        elseif rrHigh==1
            RsquaredRank = numPerms - sum(Rsquared > shuffRsquared);
        end
    case 2
        disp('rank error')
        keyboard
end



slLow = sum(slope < shuffSlope) > numPerms-pUse;
slHigh = sum(slope > shuffSlope) > numPerms-pUse;
switch slLow + slHigh
    case 0
        slopeRank = 0;
    case 1
        if slLow==1
            slopeRank = sum(slope < shuffSlope);
        elseif slHigh==1
            slopeRank = sum(slope > shuffSlope);
        end
    case 2
        disp('rank error')
        keyboard
end
%slopeRank = sum(slope > shuffSlope);

end
        