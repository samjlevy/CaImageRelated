function [axHand,statsOut] = PlotPVcurvesDiff(CSpooledPVcorrs,CSpooledPVdaysApart,condSetColors,condSetLabels,plotRaw,axHand)
%This one just plots the diff. Assumes ind 1 is the ref

for cdI = 2:length(CSpooledPVcorrs)
    PVcorrsDiff{cdI-1,1} = abs(CSpooledPVcorrs{cdI} - CSpooledPVcorrs{1}); 
end

[axHand,statsOut] = PlotPVcurves(PVcorrsDiff,CSpooledPVdaysApart(2:end),condSetColors(2:end),condSetLabels(2:end),plotRaw,axHand);
                    
end