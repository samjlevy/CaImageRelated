function [decodingAboveDSrate, DSbetterThanShuff, DSaboveShuffP, meanDSperformance] = EvaluateDownsampledDecodingPerformance(...
    decodingResults,downsampledResults,shuffledResults,cellDownsamples,pThresh)
%This should probably happen within a mouse... (or pooled)
%DSbetter than shuff is number of shuffles that instance of downsampled
%decoding is better than. 
%DSaboveP is is that rate above the pThresh
%Mean: what's the rate of decoding above shuffle across all downsamples

numShuffles = size(shuffledResults,3);
pPct = 1 - pThresh;

numSessPairs = size(cellDownsamples);
for sessPairI = 1:numSessPairs
    numShuffHere = size(cellDownsamples{sessPairI},1);
    
    %What pct of shuffles is regular greater than downsampled? (or not,
    %a similar result comes with regular evaluate)
    decodingAboveDSrate(sessPairI,1) = ...
        sum(decodingResults(sessPairI) > squeeze(downsampledResults(sessPairI,1,1:numShuffHere))) / numShuffHere;
    
    for shuffI = 1:numShuffHere
        DSbetterThanShuff{sessPairI,1}(shuffI,1) =...
            sum(downsampledResults(sessPairI,1,shuffI) > squeeze(shuffledResults(sessPairI,1,:)))/numShuffles;
    end
    DSaboveShuffP{sessPairI,1} = DSbetterThanShuff{sessPairI} > pPct;
    
    meanDSperformance(sessPairI,1) = mean(DSbetterThanShuff{sessPairI});
end
 

end