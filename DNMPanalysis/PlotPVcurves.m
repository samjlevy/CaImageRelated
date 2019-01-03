function axHand = PlotPVcurves(CSpooledPVcorrs,CSpooledPVdaysApart,condSetColors,condSetLabels,axHand)

if isempty(axHand)
    figure;
    axHand = axes;
end

numBins = size(CSpooledPVcorrs{1},2);

plot([0.5 numBins+0.5],[0 0],'k'); hold on
pp = [];
for csI = 1:length(condSetColors)
    errorHere = [];
    withinDay = CSpooledPVdaysApart{csI}==0;
    for binI = 1:numBins
        errorHere(binI) = standarderrorSL(CSpooledPVcorrs{csI}(withinDay,binI)); hold on
    end
    pp(csI) = errorbar(1:numBins,nanmean(CSpooledPVcorrs{csI}(withinDay,:),1),errorHere,'Color',condSetColors{csI},'LineWidth',2,'CapSize',1);
end

if ~isempty(condSetLabels)
    legend(pp,condSetLabels,'location','southwest')
end

xlim([0.5 numBins+0.5])
xlabel('Spatial Bin')
ylabel('Correlation')

end