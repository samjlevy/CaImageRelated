function diffRank = PermutationTestSL(vectorA,vectorB,numPerms)

vectorA = vectorA(:);
vectorB = vectorB(:);

existDiff = abs(mean(vectorA) - mean(vectorB));

labels = [zeros(length(vectorA),1); ones(length(vectorB),1)];
allData = [vectorA; vectorB];

if isnumeric(numPerms)

for permI = 1:numPerms
    shuffLabels = labels(randperm(length(labels)));
    
    mixA = allData(shuffLabels==0);
    mixB = allData(shuffLabels==1);

    shuffDiff(permI,1) = abs(mean(mixA) - mean(mixB));
end

elseif ischar(numPerms)
    if strcmpi(numPerms,'eachPerm')
        
        nDataA = length(vectorA);
        nDataB = length(vectorB);
        perms = nchoosek(1:length(allData),nDataA);
        numPerms = size(perms,1);
        
        for permI = 1:numPerms
            shuffLabels = ones(length(allData),1);
            shuffLabels(perms(permI,:)) = 0;
            
            %shuffLabels = labels(perms(permI,:));
    
            mixA = allData(shuffLabels==0);
            mixB = allData(shuffLabels==1);

            shuffDiff(permI,1) = abs(mean(mixA) - mean(mixB));
        end
        
    else
        keyboard
    end
else
    keyboard
end

diffRank = sum(existDiff > shuffDiff) / numPerms;

end

    
    