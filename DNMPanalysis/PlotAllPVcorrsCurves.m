function [figHand] = PlotAllPVcorrsCurves(CSpooledPVcorrs,CSpooledPVdaysApart,pvNames,condSetColors)

figHand = figure('Position',[680 147 1088 831]); qq = [];
for pvtI = 1:length(pvNames)
    qq{pvtI} = subplot(2,3,pvtI);
    
    qq{pvtI} = PlotPVcurves(CSpooledPVcorrs{pvtI},CSpooledPVdaysApart{pvtI},condSetColors,qq{pvtI});
    
    title(pvNames{pvtI})
    %{
    switch mean(qq{pvtI}.YLim)>0
        case 1
            qq{pvtI}.YLim = [0 0.5];
        case 0
            qq{pvtI}.YLim = [-0.5 0];
    end
    %}
end

end
    