function [slopeDiffRank] = multiSlopeRankWrapper(dataVecA, dataVecB, days, numPerms)
%This isn't exacly the same as the other one, it shuffles points between
%Right now requires that vectors use the same days
%dataVecA and dataVecB
%dataVec = dailySplitterProp{mouseI}
%days = realDays, etc.

numEntriesA = length(dataVecA);
if isempty(days)
    days = 1:numEntriesA;
end

both = [dataVecA(:) dataVecB(:)];

for permI = 1:numPerms
    
    shuffleColsA = logical(randi(2,numEntriesA,1)-1);
    shuffleColsB = ~shuffleColsA;
    
    shuffDataA(shuffleColsA) = dataVecA(shuffleColsA);
    shuffDataA(shuffleColsB) = dataVecB(shuffleColsB);
    
    shuffDataB(shuffleColsB) = dataVecA(shuffleColsB);
    shuffDataB(shuffleColsA) = dataVecB(shuffleColsA);
    
    [shuffSlopeA(permI), ~, ~, ~] = fitLinRegSL(shuffDataA,days);
    [shuffSlopeB(permI), ~, ~, ~] = fitLinRegSL(shuffDataB,days);
    
    slopeDiffShuff(permI) = shuffSlopeA(permI) - shuffSlopeB(permI);
end
    
[slopeA, ~, ~, ~] = fitLinRegSL(dataVecA,days);
[slopeB, ~, ~, ~] = fitLinRegSL(dataVecB,days);

slopeDiff = slopeA - slopeB;
    
slopeDiffRank = sum(slopeDiff > slopeDiffShuff);

end
        