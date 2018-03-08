function [binsAboveShuffle, numBinsAboveShuffle, thisCellSplits] = SplitterRateRank2(baseRateDiff, rateDiffReorg, shuffThresh, binsMin)
%Shuffled rate diff needs to be organized so that all shuffles are aligned
%in the same cell array

%Basic setup
numCells = size(baseRateDiff,1);
numSess = size(baseRateDiff,2);
numCondPairs = size(baseRateDiff,3);

%Where are things
stuffHere = cellfun(@any, rateDiffReorg, 'UniformOutput', false);
stuffHere = cell2mat(cellfun(@any, stuffHere, 'UniformOutput', false));
firstThing = find(stuffHere,1,'first');

%Continued Setup
numBins = length(baseRateDiff{firstThing});
numShuffles = size(rateDiffReorg{firstThing},1);
indThresh = round(numShuffles*shuffThresh);
%indThreshOther = round(numShuffles*(1-shuffThresh)); %in case rebuild with cellfuns

%Sort the shuffles (smallest to greatest)
sortedReorg = cellfun(@(x) sort(x,1), rateDiffReorg, 'UniformOutput', false); 

%Pre-allocate
binsAboveShuffle = cell(numCells,numSess,numCondPairs);
numBinsAboveShuffle = nan(numCells,numSess,numCondPairs);
%thisCellSplits = nan(numCells,numSess,numCondPairs);

%Compare to shuffles
for cpI = 1:numCondPairs
    for cellI = 1:numCells
        for sessI = 1:numSess
            ratesHere = baseRateDiff{cellI,sessI,cpI};
            if any(ratesHere)
                rateGreaterThanShuffles = sum(ratesHere > sortedReorg{cellI,sessI,cpI},1);
                rateLessThanShuffles = sum(ratesHere < sortedReorg{cellI,sessI,cpI},1);
                
                rateGreaterUse = ratesHere > 0;
                rateLesserUse = ratesHere < 0;
                
                binsAboveShuffle{cellI,sessI,cpI} = zeros(1,numBins);
                binsAboveShuffle{cellI,sessI,cpI}(rateGreaterUse) = rateGreaterThanShuffles(rateGreaterUse) > indThresh;
                binsAboveShuffle{cellI,sessI,cpI}(rateLesserUse) = rateLessThanShuffles(rateLesserUse) > indThresh;
                    
                numBinsAboveShuffle(cellI,sessI,cpI) = sum(binsAboveShuffle{cellI,sessI,cpI});
            end
        end
    end
end

thisCellSplits = numBinsAboveShuffle >= binsMin;
end
                    