function [figHand, statsOut] = PlotMeanPVcorrsDaysApart(meanPVcorrs, daysApart, fitLineType, condSetColors, condSetLabels) 
%fitLineType = 'mean';
%fitLineType = 'regression';

numConds = length(meanPVcorrs);
condSetComps = combnk(1:numConds,2);
maxDay = max(cell2mat(cellfun(@max,daysApart,'UniformOutput',false)));

figHand = figure('Position',[680 305 968 673]);
plot([-0.5 maxDay+0.75],[0 0],'k'); hold on
%condSetColors = {'b' 'r' 'g'};
%csMod = [-0.1 0 0.1];
csMod = linspace(1,numConds,numConds); csMod = (csMod - mean(csMod))/10;
for csI = 1:numConds
    dayPairsHere = unique(abs(daysApart{csI}));
    pvsHere = meanPVcorrs{csI};
    pp{csI} = plot(daysApart{csI}+csMod(csI),pvsHere,'.','MarkerSize',6,'Color',condSetColors{csI});
    if ~isempty(condSetLabels); pp{csI}.DisplayName = condSetLabels{csI}; end
   
    for dpI = 1:length(dayPairsHere)
        meanLine(dpI,csI) = mean(pvsHere(daysApart{csI}==dayPairsHere(dpI)));
    end
end

switch fitLineType
    case 'mean'
        for csI = 1:numConds
            meanLinePlot = meanLine(:,csI);
            plot(dayPairsHere,meanLinePlot,'LineWidth',2,'Color',condSetColors{csI})
        end
        %ranksum results
        plotHeights = 0.6:0.1:(0.5+0.1*size(condSetComps,1));%[0.8 0.7 0.6];
        for cscI = 1:size(condSetComps,1)
            allPVdayDiffs = unique([daysApart{condSetComps(cscI,1)}; daysApart{condSetComps(cscI,2)}]);
            for ddI = 1:length(allPVdayDiffs)
                dataA = meanPVcorrs{condSetComps(cscI,1)}(daysApart{condSetComps(cscI,1)}==allPVdayDiffs(ddI));
                dataB = meanPVcorrs{condSetComps(cscI,2)}(daysApart{condSetComps(cscI,2)}==allPVdayDiffs(ddI));
                [statsOut.pDDmeanPV(cscI,ddI),statsOut.hDDmeanPV(cscI,ddI)] = ranksum(dataA,dataB);
                if statsOut.hDDmeanPV(cscI,ddI)==1
                    plot(allPVdayDiffs(ddI),plotHeights(cscI),'*k','MarkerSize',6) 
                end
            end
            compStr{cscI,1} = [condSetColors{condSetComps(cscI,1)} ' vs. ' condSetColors{condSetComps(cscI,2)}];
            text(-1.5,plotHeights(cscI),compStr{cscI})
        end
        xlim([-2 maxDay])
        
    case 'regression'
        for csI = 1:length(condSet)
            [meanCSpvPlotReg,~] = FitLineForPlotting(meanPVcorrs{csI},daysApart);
            plot(dayPairsHere,meanCSpvPlotReg,'LineWidth',2,'Color',condSetColors{csI})
        end
        
        for cscI = 1:size(condSetComps,1)            
            [statsOut.Fval(cscI),statsOut.dfNum(cscI),statsOut.dfDen(cscI),statsOut.pVal(cscI)] = TwoSlopeFTest(meanPVcorrs{condSetComps(cscI,1)},...
                meanPVcorrs{condSetComps(cscI,2)}, daysApart{condSetComps(cscI,1)}, daysApart{condSetComps(cscI,2)});
            plotStr{csI,1} = [condSetColors{condSetComps(csI,1)} ' vs. ' condSetColors{condSetComps(csI,2)} ': p=' num2str(statsOut.pVal(csI))];
        end       
        %legend with comparison results
        dim = [0.7 0.55 0.25 0.25];
        qq = annotation('textbox',dim,'String',plotStr,'FitBoxToText','on');
        xlim([ -0.5 maxDay])
end
figHand.Children(2).YLim(2) = 1;
ylabel('Mean Correlation')
xlabel('Days Apart')
title(['Mean Population vector correlation by number of days apart with ' fitLineType ' line'])
legend([pp{:}],'Location','ne')

end