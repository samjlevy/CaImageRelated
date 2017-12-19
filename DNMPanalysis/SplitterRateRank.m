function [binsAboveShuffle, thisCellSplits] = SplitterRateRank(rateDiff, shuffledRateDiff, shuffThresh, binsMin)
%Right now only built out for comparison of bins from rateDiff; might work
%for other metrics with no editing?
%shuffThresh is what proportion of comparisons you want it to be above
%binsMin is how many bins it remaps to call it a splitter

comparisons = fieldnames(rateDiff);
numCompares = length(comparisons);
numSess = size(rateDiff.(comparisons{1}),2);
numCells = size(rateDiff.(comparisons{1}),1);
numBins = length(rateDiff.(comparisons{1}){1,1});
numShuffles = length(shuffledRateDiff);

%Reorganize for easier compariszons
for shuffI = 1:numShuffles
    for compI = 1:numCompares
        for cellI = 1:numCells
            for sessI = 1:numSess
                reorgRates.(comparisons{compI}){cellI,sessI}(shuffI,:) =...
                    shuffledRateDiff{shuffI}.(comparisons{compI}){cellI,sessI};
            end
        end
    end
end

%Compare to each how it ranks
for compI = 1:numCompares
    for cellI = 1:numCells
        for sessI = 1:numSess
            ratesHere = rateDiff.(comparisons{compI}){cellI,sessI};
            ShuffledRates = sort(reorgRates.(comparisons{compI}){cellI,sessI},1);
            for binI = 1:numBins
                switch ratesHere(binI) > 0 
                    case 1 %rate is positive
                        binsAboveShuffle.(comparisons{compI}){cellI,sessI}(binI) =...
                            sum(ratesHere(binI) > ShuffledRates(:,binI))/numShuffles;                        
                    case 0 %rate is negative
                        binsAboveShuffle.(comparisons{compI}){cellI,sessI}(binI) =...
                            sum(ratesHere(binI) < ShuffledRates(:,binI))/numShuffles;
                end
            end
            thisCellSplits.(comparisons{compI})(cellI,sessI) =...
                sum(binsAboveShuffle.(comparisons{compI}){cellI,sessI} > shuffThresh) >= binsMin;
        end
    end
end
        
end
    