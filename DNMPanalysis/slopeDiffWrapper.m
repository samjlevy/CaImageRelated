function [slopeDiff, slopeDiffRank, RsquaredRank, comps] = slopeDiffWrapper(dataMat, realDays, numPerms)
%dataMat = splitDayCorrsMeanCS{1};
%dataMat has to be day (entry) x type (self, lvr, etc)

numD = size(dataMat,2);
if isempty(realDays)
    realDays = (1:size(dataMat,1))';
end

comps = combnk(1:numD,2);

for permI = 1:numPerms
    dataPerm = dataMat(randperm(length(realDays)),:);
    for csI = 1:numD
        data = dataPerm(:,csI);
        [shuffSlope(permI,csI), ~, ~, rr] = fitLinRegSL(data,realDays);
        shuffRsquared(permI,csI) = rr.Ordinary;
    end
    
    for cI = 1:size(comps,1)
        shuffSlopeDiff(permI,cI) = shuffSlope(permI,comps(cI,2)) - shuffSlope(permI,comps(cI,1));
    end
end
    
for csI = 1:numD
    data = splitDayCorrsMeanCS(:,csI);
    [slope(1,csI), ~, ~, rr] = fitLinRegSL(dataMat,realDays);
    Rsquared(1,csI) = rr.Ordinary;
    
    RsquaredRank(1,csI) = sum(Rsquared(1,csI) > shuffRsquared(:,csI));
end

for cJ = 1:size(comps,1)
    slopeDiff(1,cJ) = slope(1,comps(cJ,2)) - slope(1,comps(cJ,1));
    slopeDiffRank(1,cJ) = sum(abs(slopeDiff(1,cJ)) > abs(shuffSlopeDiff(:,cJ))); %Abs to give magnitude of difference
end

end
        