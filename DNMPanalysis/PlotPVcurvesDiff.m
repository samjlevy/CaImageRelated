function [axHand,statsOut] = PlotPVcurvesDiff(CSpooledPVcorrs,CSpooledPVdaysApart,condSetColors,condSetLabels,axHand)

if isempty(axHand)
    figure;
    axHand = axes;
end

numBins = size(CSpooledPVcorrs{1},2);

plot([0.5 numBins+0.5],[0 0],'k'); hold on
pp = [];

for csI = 2:length(condSetColors)
    vsSelfDays = CSpooledPVdaysApart{1}==0;
    vsSelfCorrs = CSpooledPVcorrs{1}(vsSelfDays,:);
    
    signalDays = CSpooledPVdaysApart{csI}==0;
    signalCorrs = CSpooledPVcorrs{csI}(signalDays,:);
    
    for binI = 1:numBins
        [dPrime(csI-1,binI), pVal(csI-1,binI)] = SensitivityIndexSL(signalCorrs(:,binI),vsSelfCorrs(:,binI),1000);
        %errorHere(binI) = standarderrorSL(CSpooledPVcorrs{csI}(withinDay,binI)); hold on
    end
    dPrime = abs(dPrime);
    pp(csI-1) = plot(1:numBins,dPrime(csI-1,:),'Color',condSetColors{csI},'LineWidth',2);
end

if ~isempty(condSetLabels)
    legend(pp,condSetLabels{2:end},'location','northwest')
end

[~,whch] = max(mean(dPrime,2));
for csJ = 1:size(dPrime,1)
    for binI = 1:numBins
        switch pVal(csJ,binI) < 0.05
            case 1
                sigText = '*';
            case 0
                sigText = 'n.s.';
        end
        heightMod = 1; if csJ~=whch; heightMod=-1; end
        text(binI,dPrime(csJ,binI)+0.25*heightMod,sigText,'Color',condSetColors{csJ+1},'HorizontalAlignment','Center')
    end
end

xlim([0.75 numBins+0.25])
xlabel('Spatial Bin')
ylabel('Sensitivity Index')

statsOut.pVal = pVal;

end