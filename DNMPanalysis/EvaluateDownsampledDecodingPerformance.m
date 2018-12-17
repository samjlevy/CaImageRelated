function [decodingAboveDSrate, DSbetterThanShuff, DSaboveShuffP] = EvaluateDownsampledDecodingPerformance(...
    decodingResults,downsampledResults,shuffledResults,cellDownsamples,pThresh)
%This should probably happen within a mouse... (or pooled)
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
        DSbetterThanShuff{sessPairI}(shuffI,1) =...
            sum(downsampledResults(sessPairI,1,shuffI) > squeeze(shuffledResults(sessPairI,1,:)))/numShuffles;
    end
    DSaboveShuffP{sessPairI} = DSbetterThanShuff{sessPairI} > pPct;
    
    %mean within sess pair?
end
 

end