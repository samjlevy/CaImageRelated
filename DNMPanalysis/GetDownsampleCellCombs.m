function cellDownsamples = GetDownsampleCellCombs(traitLogical,sessPairs,numDownsamples)

warning('off','all')

numSessPairs = size(sessPairs,1);
%Find the minimum number of cells shared across all day pairs
for sessPairI = 1:numSessPairs
    trainCells = traitLogical(:,sessPairs(sessPairI,1));
    testCells = traitLogical(:,sessPairs(sessPairI,2));
    
    sharedCellsLog = trainCells.*testCells;
    sharedCellsHere(sessPairI) = sum(sharedCellsLog);
end

minSharedCells = min(sharedCellsHere);

for sessPairI = 1:numSessPairs
    %Find how many cells are shared in the day pair
    trainCells = traitLogical(:,sessPairs(sessPairI,1));
    testCells = traitLogical(:,sessPairs(sessPairI,2));
    sharedCells = find(trainCells.*testCells);
    numSharedCells = length(sharedCells);
    
    %Get downsamples of the shared cells
    if numSharedCells == minSharedCells
        downsamples = sharedCells;
    else
    numPossibleCombs = nchoosek(numSharedCells,minSharedCells);
    switch numPossibleCombs > 100000
        case 0
            %Generate all the combs, pick randomly
            possibleDownsamples = nchoosek(sharedCells,minSharedCells);
            switch size(possibleDownsamples,1) < numDownsamples
                case 1
                    downsamples = possibleDownsamples;
                case 0
                    getThese = randperm(size(possibleDownsamples,1),numDownsamples);
                    downsamples = possibleDownsamples(getThese,:);
            end
        case 1
            downsamples = sort(randperm(numSharedCells,minSharedCells));
            while size(downsamples,1) < numDownsamples
                newOrder = sort(randperm(numSharedCells,minSharedCells));
                if sum(ismember(downsamples,newOrder,'rows')) == 0 
                    downsamples = [downsamples; newOrder];
                end
            end
    end
    end
    
    cellDownsamples{sessPairI,1} = downsamples;
end

warning('on','all')

end