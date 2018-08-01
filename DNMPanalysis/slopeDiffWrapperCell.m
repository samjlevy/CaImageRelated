function [slopeDiff, slopeDiffRank, RsquaredRank, comps] = slopeDiffWrapperCell(dataCell, dayDiffs, numPerms)
%dataMat = pooledAllMiceSplitDayCorrsMean;
%dataCell is a cell array for each type of data (self, lvr, svt)
%dayDiffs is the marker for that data

numCols = length(dataCell);

comps = combnk(1:numCols,2);

for permI = 1:numPerms    
    for csI = 1:numCols
        dataHere = dataCell{csI};
        dataPerm = dataHere(randperm(length(dataHere)));
        [shuffSlope(permI,csI), ~, ~, rr] = fitLinRegSL(dataPerm,dayDiffs{csI});
        shuffRsquared(permI,csI) = rr.Ordinary;
    end
    
    for cI = 1:size(comps,1)
        shuffSlopeDiff(permI,cI) = shuffSlope(permI,comps(cI,2)) - shuffSlope(permI,comps(cI,1));
    end
end
    
for csI = 1:numCols
    dataHere = dataCell{csI};
    [slope(1,csI), ~, ~, rr] = fitLinRegSL(dataHere,dayDiffs{csI});
    Rsquared(1,csI) = rr.Ordinary;
    
    RsquaredRank(1,csI) = sum(Rsquared(1,csI) > shuffRsquared(:,csI));
end

for cJ = 1:size(comps,1)
    slopeDiff(1,cJ) = slope(1,comps(cJ,2)) - slope(1,comps(cJ,1));
    slopeDiffRank(1,cJ) = sum(abs(slopeDiff(1,cJ)) > abs(shuffSlopeDiff(:,cJ))); %Abs to give magnitude of difference
end

end
        