function maxBin = MaxFiringBin(TMapOne)

[~,maxBin] = max(TMapOne);

maxBin = mean(maxBin);

end
