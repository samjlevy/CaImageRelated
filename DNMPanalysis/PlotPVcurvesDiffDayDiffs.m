function [axHand,statsOut] = PlotPVcurvesDiffDayDiffs(CSpooledPVcorrs,CSpooledPVdaysApart,binsUse,dayDiffMin,condSetColors,condSetLabels,plotRaw,axHand)
%This one just plots the diff. Assumes ind 1 is the ref

for cdI = 2:length(CSpooledPVcorrs)
    PVcorrsDiff{cdI-1,1} = CSpooledPVcorrs{1} - CSpooledPVcorrs{cdI}; 
end

[axHand,statsOut] = PlotPVcurvesDayDiffs(PVcorrsDiff,CSpooledPVdaysApart(2:end),binsUse,dayDiffMin,condSetColors(2:end),condSetLabels(2:end),plotRaw,axHand);
                    
end