function [figHandOut, statsOut] = PlotMeanPVcorrsDaysApart(meanPVcorrs, daysApart, fitLineType, condSetColors, condSetLabels, plotDots, figHand) 
%fitLineType = 'mean';
%fitLineType = 'regression';

titleText = {['Mean correlation change by days with ' fitLineType ' line']};
numConds = length(meanPVcorrs);
condSetComps = combnk(1:numConds,2); statsOut.comparisons = condSetComps;
maxDay = max(cell2mat(cellfun(@max,daysApart,'UniformOutput',false)));
if isempty(figHand)
    figHandOut = figure('Position',[680 305 968 673]);
else
    figHandOut = figHand;
end
plot([-0.5 maxDay+0.5],[0 0],'k'); hold on
%condSetColors = {'b' 'r' 'g'};
%csMod = [-0.1 0 0.1];
csMod = linspace(1,numConds,numConds); csMod = (csMod - mean(csMod))/10;
for csI = 1:numConds
    dayPairsHere = unique(abs(daysApart{csI}));
    pvsHere = meanPVcorrs{csI};
    for dpI = 1:length(dayPairsHere)
        meanLine(dpI,csI) = mean(pvsHere(daysApart{csI}==dayPairsHere(dpI)));
        errorBar(dpI,csI) = standarderrorSL(pvsHere(daysApart{csI}==dayPairsHere(dpI)));
    end
    
    if plotDots == true
        pp(csI) = plot(daysApart{csI}+csMod(csI),pvsHere,'.','MarkerSize',6,'Color',condSetColors{csI});
        xlim([-0.5 maxDay+0.75])
        if ~isempty(condSetLabels); pp(csI).DisplayName = condSetLabels{csI}; end
    else
        pp(csI) = errorbar(dayPairsHere,meanLine(:,csI),errorBar(:,csI),'Color',condSetColors{csI},'LineWidth',2,'CapSize',3);
        xlim([-0.5 maxDay+0.5])
    end
end

for cscI = 1:size(condSetComps,1)            
    [statsOut.TwoSlope.Fval(cscI),statsOut.TwoSlope.dfNum(cscI),statsOut.TwoSlope.dfDen(cscI),statsOut.TwoSlope.pVal(cscI)] =...
        TwoSlopeFTest(meanPVcorrs{condSetComps(cscI,1)},...
        meanPVcorrs{condSetComps(cscI,2)}, daysApart{condSetComps(cscI,1)}, daysApart{condSetComps(cscI,2)});
    %plotStr{csI,1} = [condSetColors{condSetComps(csI,1)} ' vs. ' condSetColors{condSetComps(csI,2)} ': p=' num2str(statsOut.pVal(csI))];
    
    allPVdayDiffs = unique([daysApart{condSetComps(cscI,1)}; daysApart{condSetComps(cscI,2)}]);
    for ddI = 1:length(allPVdayDiffs)
        dataA = meanPVcorrs{condSetComps(cscI,1)}(daysApart{condSetComps(cscI,1)}==allPVdayDiffs(ddI));
        dataB = meanPVcorrs{condSetComps(cscI,2)}(daysApart{condSetComps(cscI,2)}==allPVdayDiffs(ddI));
        [statsOut.ranksum.pVal(cscI,ddI),statsOut.ranksum.hVal(cscI,ddI)] = ranksum(dataA,dataB);
        %[statsOut.signtest.pVal(cscI,ddI),statsOut.signtest.hVal(cscI,ddI)] = signtest(dataA,dataB);
        %{
                if statsOut.hDDmeanPV(cscI,ddI)==1
                    plot(allPVdayDiffs(ddI),plotHeights(cscI),'*k','MarkerSize',6)
                end
        %}
    end
end  
        
switch fitLineType
    case 'none'
        %Do nothing
    case 'mean'
        for csI = 1:numConds
            meanLinePlot = meanLine(:,csI);
            plot(dayPairsHere,meanLinePlot,'LineWidth',2,'Color',condSetColors{csI})
        end
        %ranksum results
        plotHeights = -0.8:0.1:(0.5+0.1*size(condSetComps,1));%[0.8 0.7 0.6];
        for cscI = 1:size(condSetComps,1)
            
            %compStr{cscI,1} = [condSetColors{condSetComps(cscI,1)} ' vs. ' condSetColors{condSetComps(cscI,2)}];
            %text(-1.5,plotHeights(cscI),compStr{cscI})
        end
        %xlim([-2 maxDay])
        
    case 'regression'
        for csI = 1:length(condSet)
            [meanCSpvPlotReg,~] = FitLineForPlotting(meanPVcorrs{csI},daysApart);
            plot(dayPairsHere,meanCSpvPlotReg,'LineWidth',2,'Color',condSetColors{csI})
        end
             
        %legend with comparison results
        %{
        if isempty(figHand)
            dim = [0.7 0.55 0.25 0.25];
            qq = annotation('textbox',dim,'String',plotStr,'FitBoxToText','on');
        else
            titleText = [titleText; plotStr];
        end
        xlim([-0.5 maxDay])
        %}
end

if isempty(figHand)
    figHandOut.Children.YLim(2) = 1;
else
    try
        figHandOut.YLim(2) = 1;
    catch
        figHandOut.Children.YLim(2) = 1;
    end
end

ylabel('Mean Correlation')
xlabel('Days Apart')
title(titleText)
if plotDots == true
    legend(pp,'Location','ne')
else
    legend(pp,condSetLabels,'Location','ne')
end

end