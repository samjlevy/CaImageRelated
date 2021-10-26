function [SEM, means] = BinnedMean(data,binningMarker,bins)

nBins = numel(bins)-1;
for binI = 1:nBins
    datH = binningMarker >= bins(binI) &...
           binningMarker < bins(binI+1);
       
    SEM(binI) = standarderrorSL(data(datH));
    means(binI) = mean(data(datH));
    
end

end



