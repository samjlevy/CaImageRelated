function correctPct = PoolCorrectIndivDecodingShuffles(shuffleIndiv)

numShuffles = size(shuffleIndiv,1);

for shuffI = 1:numShuffles
    correctPct(:,1,shuffI) = PoolCorrectIndivDecoding(shuffleIndiv{shuffI});
end

end
    
