function meanCorrDaysApart = processPCadacadStep2(bigCorrs)

numShuffles = length(bigCorrs);
numCondPairs = length(bigCorrs{1});

for condI = 1:numCondPairs
    for shuffI = 1:numShuffles
        meanCorrDaysApart{condI}(:,shuffI) = mean(bigCorrs{shuffI}{condI},2);
    end
end

end

    
        