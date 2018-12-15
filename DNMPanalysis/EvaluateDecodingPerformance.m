function aboveP = EvaluateDecodingPerformance(decodingResults,shuffledResults,pThresh)

numShuffles = size(shuffledResults,3);
pInd = round(pThresh*numShuffles);

sortedShuffles = sort(shuffledResults,3,'descend');

aboveP = decodingResults >= sortedShuffles(:,:,pInd);


end