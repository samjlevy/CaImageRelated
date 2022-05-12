function plotLocalErrorBars(xData,yData,xBins,errorType,plotColor)

nBins = numel(xBins)-1;

for binI = 1:nBins
    xH = (xData >= xBins(binI)) & (xData < xBins(binI+1));
    if binI == nBins
        xH = (xData >= xBins(binI)) & (xData <= xBins(binI+1));
    end
    
    means(binI) = mean(yData(xH));
    binX(binI) = mean([xBins(binI) xBins(binI+1)]);
    switch errorType
        case 'std'
            SEMS(binI) = std(yData(xH));
        case {'sem','SEM'}
            SEMS(binI) = standarderrorSL(yData(xH));
    end
end

errorbar(binX,means,SEMS,'Color',plotColor)

end