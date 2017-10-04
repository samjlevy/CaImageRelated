%find timestamps per spatial bin size

xmin = 25.6
xmax = 56
numBins = 10

cmperbin = (xmax-xmin)/numBins

numBins = 5:1:35;
for bsI = 1:length(binSizes)
    binSize = (xmax - xmin)/numBins(bsI);
    for trialI = 1:length(trialbytrial(1).trialsX)
        
        histCounts
    end
end
        
        
        
for aa = [1 3 4]
    MinX(aa) = mean(cell2mat(cellfun(@min,trialbytrial(aa).trialsX,'UniformOutput',false)));
    minStd(aa) = std(cellfun(@min,trialbytrial(aa).trialsX));
    MaxX(aa) = mean(cellfun(@max,trialbytrial(aa).trialsX));
    maxStd(aa) = std(cellfun(@max,trialbytrial(aa).trialsX));
end

dd = cellfun(@min,trialbytrial(aa).trialsX,'UniformOutput',false);
