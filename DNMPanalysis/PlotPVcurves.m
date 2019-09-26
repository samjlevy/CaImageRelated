function [axHand,statsOut] = PlotPVcurves(CSpooledPVcorrs,CSpooledPVdaysApart,condSetColors,condSetLabels,plotRaw,plotError,axHand)
%Just plots within day
if isempty(axHand)
    figure;
    axHand = axes;
end
if isempty(plotError)
    plotError = 'sem'
end

numConds = length(CSpooledPVcorrs);
numBins = size(CSpooledPVcorrs{1},2);

csOffset = [];
if isempty(plotRaw)
    plotDots = false;
else
    if length(plotRaw) == 2
        csOffset = plotRaw{2};
        plotDots = plotRaw{1};
    else
        plotDots = plotRaw;
    end
end

if isempty(csOffset)
    csMod = linspace(1,numConds,numConds); csMod = (csMod - mean(csMod))/7;
else
    csMod = (1:numConds)*csOffset; csMod = csMod - mean(csMod);
end

plot([0.5 numBins+0.5],[0 0],'k'); hold on

for csI = 1:length(condSetColors)
    withinDay = CSpooledPVdaysApart{csI}==0;
    aggDat = []; aggDay = [];
    for binI = 1:numBins
        datH = CSpooledPVcorrs{csI}(withinDay,binI);
        dayH = binI+csMod(csI)*ones(sum(withinDay),1);
        aggDat = [aggDat; datH(:)];
        aggDay = [aggDay; dayH(:)];
        if plotDots == true
            scatter(dayH,datH,'filled',...
                'MarkerFaceColor',condSetColors{csI},'SizeData',20,'MarkerFaceAlpha',0.4);
        end
        [statsOut.eachCond{csI}.diffFromZeroSign(binI).pVal,statsOut.eachCond{csI}.diffFromZeroSign(binI).hVal,stt]=...
            signtest(CSpooledPVcorrs{csI}(withinDay,binI));
        try statsOut.eachCond{csI}.diffFromZeroSign(binI).zVal = stt.zval;
        catch statsOut.eachCond{csI}.diffFromZeroSign(binI).zVal = []; end
    end
    
    [statsOut.eachCond{csI}.rankCorrs.rho,statsOut.eachCond{csI}.rankCorrs.pVal] = corr(aggDay,aggDat,'type','Spearman');
end

if ~isempty(plotError)    
pp = [];
for csI = 1:length(condSetColors)
    errorHere = [];
    withinDay = CSpooledPVdaysApart{csI}==0;
    for binI = 1:numBins
        datHere = sort(CSpooledPVcorrs{csI}(withinDay,binI));
        meanHere(binI) = nanmean(datHere);
        switch plotError
            case {'sem','SEM'}
                errorHere(binI) = standarderrorSL(datHere); hold on
            case {'std','STD'}
                errorHere(binI) = std(datHere); hold on
            case {'bound'}
                tInds = round(length(datHere)*[0.025 0.975]);
                errorHere(:,binI) = datHere(tInds)';
        end
    end
    
    if strcmpi(plotError,'STD')
        patchY = [meanHere+errorHere fliplr(meanHere-errorHere)];
        %patchY = [errorHere(1,:) fliplr(errorHere(2,:))];
        patchX = [1:numBins fliplr(1:numBins)];
        patch(patchX,patchY,condSetColors{csI},'EdgeColor','none','FaceAlpha',0.4)
        pp(csI) = plot(1:numBins,meanHere,'Color',condSetColors{csI},'LineWidth',2);
    else
        pp(csI) = errorbar(1:numBins,nanmean(CSpooledPVcorrs{csI}(withinDay,:),1),errorHere,'Color',condSetColors{csI},'LineWidth',2);
    end
end

if ~isempty(condSetLabels)
    legend(pp,condSetLabels,'location','southwest')
end
end
 
xlim([0.5 numBins+0.5])
xlabel('Spatial Bin')
ylabel('Correlation')

comparisons = combnk(1:length(condSetColors),2);
statsOut.comparisons = comparisons;
for compI = 1:size(comparisons,1)
    withinDayA = CSpooledPVdaysApart{comparisons(compI,1)}==0;
    withinDayB = CSpooledPVdaysApart{comparisons(compI,2)}==0;
    for binI = 1:numBins
        datA = CSpooledPVcorrs{comparisons(compI,1)}(withinDayA,binI);
        datB = CSpooledPVcorrs{comparisons(compI,2)}(withinDayB,binI);
        try
            [p,h,stats] = signrank(datA,datB);
            statsOut.signranktests{compI}(binI).pVal = p;
            statsOut.signranktests{compI}(binI).hVal = h;
            statsOut.signranktests{compI}(binI).zVal = [];
            try
                statsOut.signranktests{compI}(binI).zVal = stats.zval;
            end
        end
        [statsOut.ranksumtests{compI}(binI).pVal,statsOut.ranksumtests{compI}(binI).hVal,sstats]=...
            ranksum(datA,datB);
        statsOut.ranksumtests{compI}(binI).zVal = [];
        try; statsOut.ranksumtests{compI}(binI).zVal = sstats.zval; end
    end
end


end