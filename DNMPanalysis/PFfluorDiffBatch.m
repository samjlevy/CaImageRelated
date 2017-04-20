function fluorDiffAB = PFfluorDiffBatch(PFstuffA, PFstuffB, LPtraces, matches, hitThresh, posThresh)
numCells = size(PFstuffA.stats.PFnHits,1);

%[GoodOccMap]=GoodOccMapShared...
%    ( PFstuffA.maps.RunOccMap, PFstuffB.maps.RunOccMap, posThresh);

%Only use cells that have fields with thresh number transients
useCellsA = CellsAboveThresh(PFstuffA.stats.PFnHits, hitThresh);
useCellsB = CellsAboveThresh(PFstuffB.stats.PFnHits, hitThresh);
allUseCells = useCellsA & useCellsB;

%Align LPtrace to tracking
load('Pos_brain.mat','PSAboolUseIndices')
LPtracesAdj = zeros(numCells,length(PSAboolUseIndices));
for cellLine = 1:numCells
    LPtracesAdj(cellLine,:) = LPtraces(cellLine,PSAboolUseIndices);
end    

fluorDiffAB = nan(size(PFstuffA.stats.PFnHits));
fluorsA = nan(size(PFstuffA.stats.PFnHits));
fluorsB = nan(size(PFstuffA.stats.PFnHits));

for thisCell = 1:numCells
    theseMatches = [matches{thisCell,1}];
    if ~isempty(theseMatches)
        LPtrace = LPtracesAdj(thisCell,:);
        for match = 1:length(theseMatches)
            if theseMatches(match)~=0 %...
                %&& useCellsA(thisCell,theseMatches(match))...
                %&& useCellsB(thisCell,match)
                epochsA = PFstuffA.stats.PFepochs{thisCell,theseMatches(match)};
                PFfluorA = PFfluorPix(epochsA, PFstuffA.maps.isrunning,LPtrace);
                epochsB = PFstuffB.stats.PFepochs{thisCell,match};
                PFfluorB = PFfluorPix(epochsB, PFstuffB.maps.isrunning,LPtrace);
                fluorsA(thisCell,theseMatches(match)) = PFfluorA;
                fluorsB(thisCell,theseMatches(match)) = PFfluorB;
                fluorDiffAB(thisCell,theseMatches(match)) = ...
                    (PFfluorB - PFfluorA) / (PFfluorB + PFfluorA);
            end
        end
    end
end

end