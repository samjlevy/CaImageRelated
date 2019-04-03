function [statsOut] = PlotTraitChangeOverDaysOne(pooledTraitChanges,pooledDaysApart,colorsHere,labels,plotDots,lineType,yLabel,ylims)
numConds = length(pooledTraitChanges);

plot([0.5 max(pooledDaysApart)+0.5],[0 0],'k')
hold on

daysHere = unique(pooledDaysApart);

pp = []; qq = [];
csMod = linspace(1,numConds,numConds); csMod = (csMod - mean(csMod))/10;
for condI = 1:numConds   
    if plotDots==true
    %pp(condI) = plot(pooledDaysApart+csMod(condI),pooledTraitChanges{condI},'.',...
    %    'Color',colorsHere{condI},'MarkerSize',12,'DisplayName',labels{condI});
    pp(condI) = scatter(pooledDaysApart+csMod(condI),pooledTraitChanges{condI},'filled','MarkerFaceColor',colorsHere{condI},...
        'SizeData',20,'MarkerFaceAlpha',0.6,'DisplayName',labels{condI});
    end
    
    for ddI = 1:length(daysHere)
        dayData = pooledTraitChanges{condI}(pooledDaysApart==daysHere(ddI));
        meanLine{condI}(ddI) = mean(dayData);
        errorLine{condI}(ddI) = standarderrorSL(dayData);
    end
end

for condI = 1:numConds 
    switch lineType
        case 'regress'
            [fitVal,daysPlot] = FitLineForPlotting(pooledTraitChanges{condI},pooledDaysApart);
            qq(condI) = plot(daysPlot,fitVal,'Color',colorsHere{condI},'LineWidth',2,'DisplayName',labels{condI});
        case 'mean'
            qq(condI) =  errorbar(daysHere+csMod(condI),meanLine{condI},errorLine{condI},'Color',colorsHere{condI},'LineWidth',2,'DisplayName',labels{condI});
        case 'meanNoErr'
            qq(condI) = plot(daysHere,meanLine{condI}+csMod(condI),'Color',colorsHere{condI},'LineWidth',2,'DisplayName',labels{condI});
        case 'none'
            %do nothing
    end
   
    xlim([0.5 max(pooledDaysApart)+0.5])
    xlabel('Day Lag')
    ylim(ylims)
    ylabel(yLabel)
end

if ~strcmpi(lineType,'none')
    legend(qq)
elseif plotDots==true && strcmpi(lineType,'none')
    legend(pp)
end
 
comps = combnk(1:numConds,2);
for compI = 1:size(comps,1)
    %Slopes different from each other?
    [statsOut.slopeDiffComp(compI).Fval,statsOut.slopeDiffComp(compI).dfNum,...
     statsOut.slopeDiffComp(compI).dfDen,statsOut.slopeDiffComp(compI).pVal] =...
        TwoSlopeFTest(pooledTraitChanges{comps(compI,1)},pooledTraitChanges{comps(compI,2)},...
                      pooledDaysApart,pooledDaysApart);
                  
    %Sign test each day
    [statsOut.signtests(compI).pVal,statsOut.signtests(compI).hVal,...
     statsOut.signtests(compI).whichWon,statsOut.signtests(compI).eachDayPair] =...
        SignTestAllDayPairs(pooledTraitChanges{comps(compI,1)},...
        pooledTraitChanges{comps(compI,2)},pooledDaysApart);
    
    %Rank sum all
    [statsOut.rankSumAll(compI).pVal, statsOut.rankSumAll(compI).hVal] = ...
        ranksum(pooledTraitChanges{comps(compI,1)},pooledTraitChanges{comps(compI,2)});
    statsOut.rankSumAll(compI).whichWon = WhichWonRanks(pooledTraitChanges{comps(compI,1)},pooledTraitChanges{comps(compI,2)});
    
    for aa = 1:2
        [~, ~, ~, statsOut.slope(compI).slopeRR(aa), statsOut.slope(compI).slopePval(aa), ~] =...
            fitLinRegSL(pooledTraitChanges{comps(compI,aa)}, pooledDaysApart);
    
        [statsOut.slope(compI).slopeDiffZero(aa).Fval,statsOut.slope(compI).slopeDiffZero(aa).dfNum,...
         statsOut.slope(compI).slopeDiffZero(aa).dfDen,statsOut.slope(compI).slopeDiffZero(aa).pVal] =...
            slopeDiffFromZeroFtest(pooledTraitChanges{comps(compI,aa)}, pooledDaysApart);
    end
end
statsOut.comps = comps;
end