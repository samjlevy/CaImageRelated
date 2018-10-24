function cdf = CDFfromHistcounts(histCounts)

numBins = length(histCounts);
for binI = 1:numBins
    cdf(binI) = sum(histCounts(1:binI));
end

%normalize to 1
cdf = cdf/sum(cdf);

end