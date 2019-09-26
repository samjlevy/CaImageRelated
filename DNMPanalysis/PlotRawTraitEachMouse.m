function statsOut = PlotRawTraitEachMouse(traitProps,realDays,normalization,mouseColors,regColor)
%Normalization is used to minimize across-animal variance
%   - empty or 'none'
%   - 'min' - subtracts min value
%   - 'first' - subtracts first value
%   - 'mean' - subtracts mean value
%   - 'zscore' - not implemented
%   - 'minmax'  - scales to within animal 0 min 1 max - not implemented

numMice = length(traitProps);
if isempty(regColor)
    regColor = 'k';
end

pooledHere = [];
daysHere = [];
for mouseI = 1:numMice
    dayss = realDays{mouseI} - (realDays{mouseI}(1)-1);
    splitPropHere = traitProps{mouseI};
    ylabelText = 'Proportion';
    if ~isempty(normalization) || ~strcmpi(normalization,'none')
    switch normalization
        case 'min'
            splitPropHere = splitPropHere - min(splitPropHere);
            ylabelText = 'Proportion diff from min';
        case 'first'
            splitPropHere = splitPropHere - (1);
            ylabelText = 'Proportion diff from first day';
        case 'mean'
            splitPropHere = splitPropHere - mean(splitPropHere);
            ylabelText = 'Proportion diff from mean';
    end
    end
    
    if ~isempty(mouseColors)
        plot(dayss,splitPropHere,'Color',mouseColors(mouseI,:))
    else
       plot(dayss,splitPropHere)
    end
    pooledHere = [pooledHere; splitPropHere(:)];
    daysHere = [daysHere; dayss];
    hold on
end
ylabel(ylabelText)
xlabel('Recording day')

[fitVal,daysPlot] = FitLineForPlotting(pooledHere,daysHere);
plot(daysPlot,fitVal,'Color',regColor,'LineWidth',2)

[~, ~, ~, statsOut.slope.RR, statsOut.slope.pVal, ~] =...
    fitLinRegSL(pooledHere,daysHere);
[statsOut.slopeDiffZero.Fval,statsOut.slopeDiffZero.dfNum,...
statsOut.slopeDiffZero.dfDen,statsOut.slopeDiffZero.pVal] =...
    slopeDiffFromZeroFtest(pooledHere,daysHere);

[statsOut.corr.pVal,statsOut.corr.rho] = corr(daysHere,pooledHere,'type','Spearman');

end