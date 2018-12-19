function [figHand] = PlotAllPVcorrsCurves(CSpooledPVcorrs,CSpooledPVdaysApart,pvNames,condSetColors)

numBins = size(CSpooledPVcorrs{1}{1},2);

figHand = figure('Position',[680 147 1088 831]); qq = [];
for pvtI = 1:length(pvNames)
    qq{pvtI} = subplot(2,3,pvtI);
    for csI = 1:length(condSetColors)
        errorHere = [];
        withinDay = CSpooledPVdaysApart{pvtI}{csI}==0;
        for binI = 1:numBins
            errorHere(binI) = standarderrorSL(CSpooledPVcorrs{pvtI}{csI}(withinDay,binI)); hold on
        end
        errorbar(1:numBins,nanmean(CSpooledPVcorrs{pvtI}{csI},1),errorHere,'Color',condSetColors{csI},'LineWidth',2)
    end
    title(pvNames{pvtI})
    xlim([0.5 numBins+0.5])
    xlabel('Spatial Bin')
    ylabel('Correlation')
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
    