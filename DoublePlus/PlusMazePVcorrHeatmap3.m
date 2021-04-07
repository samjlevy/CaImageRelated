function [figHand] = PlusMazePVcorrHeatmap3(corrsPlot,plotBins,gradientUse,gradientLims)

%numDayPairs = size(dayPairs,1);
numDayPairs = size(corrsPlot,1);
numBins = size(corrsPlot,2);

bff = 10; xll = [min(plotBins.X(:))-bff max(plotBins.X(:))+bff]; yll = [min(plotBins.Y(:))-bff max(plotBins.Y(:))+bff];
figHand = figure('Position',[243.5000 207 1.0605e+03 405]);
for dpI = 1:numDayPairs
    subplot(1,numDayPairs,dpI)
    axis equal
    dataHere = corrsPlot(dpI,:);
    
    ptColors = rateColorMap(dataHere,gradientUse,gradientLims(1),gradientLims(2));%max(dataThisDP),min(dataThisDP)
    for binI = 1:numel(dataHere)
        if ~isnan(dataHere(binI))
            patch(plotBins.X(binI,:),plotBins.Y(binI,:),ptColors(binI,:))
        end
    end
    axis equal
    xlim(xll); ylim(yll);
    %axis manual
    %title(['Day Pair ' num2str(dayPairs(dpI,:))])
end

end