function diffRank = PermutationTestSL(vectorA,vectorB,numPerms)

vectorA = vectorA(:);
vectorB = vectorB(:);

existDiff = abs(mean(vectorA) - mean(vectorB));

labels = [zeros(length(vectorA),1); ones(length(vectorB),1)];
allData = [vectorA; vectorB];

for permI = 1:numPerms
    shuffLabels = labels(randperm(length(labels)));
    
    mixA = allData(shuffLabels==0);
    mixB = allData(shuffLabels==1);

    shuffDiff(permI,1) = abs(mean(mixA) - mean(mixB));
end

diffRank = sum(existDiff > shuffDiff) / numPerms;

end

    
    