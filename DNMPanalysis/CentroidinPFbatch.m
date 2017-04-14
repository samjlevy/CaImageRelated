function[AinB, BinA, inBoth]=CentroidinPFbatch...
    (CentroidsA, CentroidsB, PFsA, PFsB, matches,arenaSize)

numCells=size(CentroidsA,1);
numFields=size(CentroidsA,2);

AinB = NaN(numCells,numFields);
BinA = NaN(numCells,numFields);

%Need to do both directions,
for thisCell = 1:numCells
    theseMatches = matches{thisCell,1};
    if any(theseMatches)
    for match = 1:length(theseMatches)
        if theseMatches(match)~=0
            centroidB = CentroidsB{thisCell,match};    
            centroidA = CentroidsA{thisCell,theseMatches(match)};
            placeFieldB = PFsB{thisCell,match};
            placeFieldA = PFsA{thisCell,theseMatches(match)};
            
            [AinB(thisCell,match), ~, ~, ~]=CentroidInPlaceField...
                (centroidA, placeFieldB,arenaSize);
            [BinA(thisCell,match), ~, ~, ~]=CentroidInPlaceField...
                (centroidB, placeFieldA,arenaSize);
        end
    end
    end
end

inBoth=AinB==BinA;

end
