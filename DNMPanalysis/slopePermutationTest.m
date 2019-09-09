function [pValSlope,pValRR] = slopePermutationTest(proportions,cellRealDays,nPerms)

if iscell(proportions)
numMice = length(cellRealDays);
    %Original
    [slope, ~, ~, ~, ~, ~] = fitLinRegSL([proportions{:}]', vertcat(cellRealDays{:}));

    %Shuffle
    for permI = 1:nPerms 
        for mouseI = 1:numMice
            dayOrder = randperm(length(cellRealDays{mouseI}));
            shuffledProps{mouseI} = proportions{mouseI}(dayOrder);
        end
        [slopeShuff(permI), ~, ~, ~, ~, ~] = fitLinRegSL([shuffledProps{:}], vertcat(cellRealDays{:}));
    end
elseif isnumeric(proportions)
    %original
    [slope, ~, ~, rr, ~, ~] = fitLinRegSL(proportions(:), cellRealDays(:));
    %Shuffle
    for permI = 1:nPerms
        shuffledProps = proportions(randperm(length(proportions)));
        
        [slopeShuff(permI), ~, ~, rrShuff(permI), ~, ~] = fitLinRegSL(shuffledProps(:), cellRealDays(:));
    end
end

switch slope > mean(slopeShuff)
    case 1
        pVal = 1 - sum(slope>slopeShuff)/nPerms;
    case 0
        pVal = 1 - sum(slope<slopeShuff)/nPerms;
end

pValRR = 1- sum(rr>rrShuf)/nPerms;

end

