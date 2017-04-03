function [ blockIndices, edges ] = BlockOfFTindices( starts, stops)

edges = 1;
blockIndices = [];
for trialNum = 1:length(starts)
    theseInds = starts(trialNum):stops(trialNum);
    blockIndices=[blockIndices, theseInds]; %#ok<AGROW>
    edges = [edges length(blockIndices)]; %#ok<AGROW>
end

end

