thingsNow = [3     4     5     8];

figure;
for ii = 1:4
    pooledHere = [];
    daysHere = [];
for mouseI = 1:4
    subplot(2,2,ii)
    dayss = cellRealDays{mouseI} - (cellRealDays{mouseI}(1)-1);
    %dayss = cellRealDays{mouseI};
    splitPropHere = splitPropEachDay{1}{mouseI}{thingsNow(ii)};% -min(splitPropEachDay{1}{mouseI}{thingsNow(ii)});
    splitPropHere = splitPropHere - mean(splitPropHere);
    plot(dayss,splitPropHere)
    pooledHere = [pooledHere; splitPropHere(:)];
    daysHere = [daysHere; dayss];
    hold on
end
ylabel('Proportion of cells')
xlabel('Recording day')

[fitVal,daysPlot] = FitLineForPlotting(pooledHere,daysHere);
plot(daysPlot,fitVal,'k','LineWidth',2)
[~, ~, ~, RR, Pval, ~] =...
            fitLinRegSL(pooledHere,daysHere);
        [Fval,dfNum,dfDen,pVal] =...
        slopeDiffFromZeroFtest(pooledHere,daysHere);
title([traitLabels{thingsNow(ii)} ', R=' num2str(sqrt(abs(RR.Adjusted))) ', p=' num2str(Pval)])
end

suptitleSL('Raw splitting pcts across all mice, and regression')


figure;
for ii = 1:4
    pooledHere = [];
    daysHere = [];
for mouseI = 1:4
    subplot(2,2,ii)
    dayss = cellRealDays{mouseI} - (cellRealDays{mouseI}(1)-1);
    dayss = dayss(2:end);
    %dayss = cellRealDays{mouseI};
    splitPropHere = traitFirstPcts{1}{mouseI}{thingsNow(ii)};%-mean(splitPropEachDay{1}{mouseI}{thingsNow(ii)});
    splitPropHere = splitPropHere - mean(splitPropHere);
    plot(dayss,splitPropHere)
    pooledHere = [pooledHere; splitPropHere(:)];
    daysHere = [daysHere; dayss];
    hold on
end
ylabel('Proportion of cells')
xlabel('Recording day')

[fitVal,daysPlot] = FitLineForPlotting(pooledHere,daysHere);
plot(daysPlot,fitVal,'k','LineWidth',2)
[~, ~, ~, RR, Pval, ~] =...
            fitLinRegSL(pooledHere,daysHere);
        [Fval,dfNum,dfDen,pVal] =...
        slopeDiffFromZeroFtest(pooledHere,daysHere);
title([traitLabels{thingsNow(ii)} ', R=' num2str(sqrt(abs(RR.Adjusted))) ', p=' num2str(Pval)])
end

suptitleSL('Pcts of new cells across all mice, and regression')
