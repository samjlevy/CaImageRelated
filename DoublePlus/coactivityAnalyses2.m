% Change in coactivity scores
% Do cells that leave an ensemble join another? End up correlated with that
% ensemble?

% This section runs on the simple correlation, no lags
%edgeThreshes = [0:0.05:0.35];
nEdgeThreshes = numel(edgeThreshes);

dealHere = cell(nEdgeThreshes,1); 
oneEnvTcorrs = cell(9,1);
twoEnvTcorrs = cell(9,1);
oneEnvNcorrEdges = cell(9,1); [oneEnvNcorrEdges{:}] = deal(cell(nEdgeThreshes,1));
oneEnvPctCorrEdges = cell(9,1); [oneEnvPctCorrEdges{:}] = deal(cell(nEdgeThreshes,1));
twoEnvNcorrEdges = cell(9,1); [twoEnvNcorrEdges{:}] = deal(cell(nEdgeThreshes,1));
twoEnvPctCorrEdges = cell(9,1); [twoEnvPctCorrEdges{:}] = deal(cell(nEdgeThreshes,1));                        
oneEnvNcomps = cellAndDeal([9, 1],dealHere);
oneEnvPctComps = cellAndDeal([9, 1],dealHere);
oneEnvCompPctSizes = cellAndDeal([9, 1],dealHere);
twoEnvNcomps = cellAndDeal([9, 1],dealHere);
twoEnvPctComps = cellAndDeal([9, 1],dealHere);
twoEnvCompPctSizes = cellAndDeal([9, 1],dealHere);
oneEnvPctCellsInComp = cellAndDeal([9, 1],dealHere);
twoEnvPctCellsInComp = cellAndDeal([9, 1],dealHere);
for mouseI = 1:numMice
    %{
    [pctStillCorr, pctStillUncorr, pctBecomeUncorr, pctBecomeCorr, numPairsStillCorr, numPairsBecomeUncorr,...
    numPairsBecomeCorr, numPairsStillUncorr, cellPairsByDayPair,numCellPirsByDayPair,...
    sessCorrs, NcorrEdges, PctCorrEdges, NconnComps, pctComps, compPctSizes, pctCellsInComp ] =...
    evaluateCorrelatedPairs1(corrs, cellPairsUsed, dayPairsHere, traitLogical, edgeThreshes) 
    %}
    
    [pctStillCorrH, pctStillUncorrH, pctBecomeUncorrH, pctBecomeCorrH, numPairsStillCorrH, numPairsBecomeUncorrH,...
    numPairsBecomeCorrH, numPairsStillUncorrH, cellPairsByDayPairH,numCellPairsByDayPairH,...
    sessCorrsH, NcorrEdgesH, PctCorrEdgesH, NconnCompsH, pctCompsH, compPctSizesH, pctCellsInCompH] =...
    evaluateCorrelatedPairs1(corrsTest{mouseI}, cellPairsUsed{mouseI}, dayPairsHere, dayUseAll{mouseI}, edgeThreshes);

    for sessI = 1:9
        if any(daysHere == sessI)
        for edgeI = 1:nEdgeThreshes
            switch groupNum(mouseI)
                case 1
                    oneEnvNcorrEdges{sessI}{edgeI} = [oneEnvNcorrEdges{sessI}{edgeI}; NcorrEdgesH(sessI,edgeI)];
                    oneEnvPctCorrEdges{sessI}{edgeI} = [oneEnvPctCorrEdges{sessI}{edgeI}; PctCorrEdgesH(sessI,edgeI)];
                    oneEnvNcomps{sessI}{edgeI} = [oneEnvNcomps{sessI}{edgeI}; NconnCompsH(sessI,edgeI)];
                    % number of comps as pct of cells here
                    oneEnvPctComps{sessI}{edgeI} = [oneEnvPctComps{sessI}{edgeI}; pctCompsH(sessI,edgeI)];
                    % Sizes of connComps as pct of cells here
                    oneEnvCompPctSizes{sessI}{edgeI} = [oneEnvCompPctSizes{sessI}{edgeI}; compPctSizesH(sessI,edgeI)]; %As pct of cells here
                    % percent of active cells in a comp
                    oneEnvPctCellsInComp{sessI}{edgeI} = [oneEnvPctCellsInComp{sessI}{edgeI}; pctCellsInCompH(sessI,edgeI)];
                    
                    
                case 2
                    twoEnvNcorrEdges{sessI}{edgeI} = [twoEnvNcorrEdges{sessI}{edgeI}; NcorrEdgesH(sessI,edgeI)];
                    twoEnvPctCorrEdges{sessI}{edgeI} = [twoEnvPctCorrEdges{sessI}{edgeI}; PctCorrEdgesH(sessI,edgeI)];
                    twoEnvNcomps{sessI}{edgeI} = [twoEnvNcomps{sessI}{edgeI}; NconnCompsH(sessI,edgeI)];
                    twoEnvPctComps{sessI}{edgeI} = [twoEnvPctComps{sessI}{edgeI}; pctCompsH(sessI,edgeI)];
                    twoEnvCompPctSizes{sessI}{edgeI} = [twoEnvCompPctSizes{sessI}{edgeI}; compPctSizesH(sessI,edgeI)];
                    twoEnvPctCellsInComp{sessI}{edgeI} = [twoEnvPctCellsInComp{sessI}{edgeI}; pctCellsInCompH(sessI,edgeI)];
            end
        end   
        end
    end 
    
    %numPairsBecomeCorrH, numPairsStillUncorrH, cellPairsByDayPairH,numCellPairsByDayPairH
    for dpH = 1:size(dayPairsHere,1)
        for edgeI = 1:nEdgeThreshes
            switch groupNum(mouseI)
                case 1
                    oneEnvPctStillCorr{dpH}(mouseI,edgeI) = pctStillCorrH(dpH,edgeI);
                    oneEnvPctStillUncorr{dpH}(mouseI,edgeI) = pctStillUncorrH(dpH,edgeI);
                    oneEnvPctBecomeUncorr{dpH}(mouseI,edgeI) = pctBecomeUncorrH(dpH,edgeI);
                    oneEnvPctBecomeCorr{dpH}(mouseI,edgeI) = pctBecomeCorrH(dpH,edgeI);
                case 2
                    twoEnvPctStillCorr{dpH}(mouseI-3,edgeI) = pctStillCorrH(dpH,edgeI);
                    twoEnvPctStillUncorr{dpH}(mouseI-3,edgeI) = pctStillUncorrH(dpH,edgeI);
                    twoEnvPctBecomeUncorr{dpH}(mouseI-3,edgeI) = pctBecomeUncorrH(dpH,edgeI);
                    twoEnvPctBecomeCorr{dpH}(mouseI-3,edgeI) = pctBecomeCorrH(dpH,edgeI);
            end
            
            
        end
    end
end

oneEnvPctStillCorrAgg = cell(nEdgeThreshes,1);
oneEnvPctBecomeCorrAgg = cell(nEdgeThreshes,1);
oneEnvPctBecomeUncorrAgg = cell(nEdgeThreshes,1);
oneEnvPctStillUncorrAgg = cell(nEdgeThreshes,1);
twoEnvPctStillCorrAgg = cell(nEdgeThreshes,1);
twoEnvPctBecomeCorrAgg = cell(nEdgeThreshes,1);
twoEnvPctBecomeUncorrAgg = cell(nEdgeThreshes,1);
twoEnvPctStillUncorrAgg = cell(nEdgeThreshes,1);
for edgeI = 1:nEdgeThreshes
    for dpH = 1:size(dayPairsHere,1)
        oneEnvPctStillCorrAgg{edgeI} = [oneEnvPctStillCorrAgg{edgeI}; oneEnvPctStillCorr{dpH}(:,edgeI)];
        oneEnvPctBecomeCorrAgg{edgeI} = [oneEnvPctBecomeCorrAgg{edgeI}; oneEnvPctBecomeCorr{dpH}(:,edgeI)];
        oneEnvPctBecomeUncorrAgg{edgeI} = [oneEnvPctBecomeUncorrAgg{edgeI}; oneEnvPctBecomeUncorr{dpH}(:,edgeI)];
        oneEnvPctStillUncorrAgg{edgeI} = [oneEnvPctStillUncorrAgg{edgeI}; oneEnvPctStillUncorr{dpH}(:,edgeI)];
        
        twoEnvPctStillCorrAgg{edgeI} = [twoEnvPctStillCorrAgg{edgeI}; twoEnvPctStillCorr{dpH}(:,edgeI)];
        twoEnvPctBecomeCorrAgg{edgeI} = [twoEnvPctBecomeCorrAgg{edgeI}; twoEnvPctBecomeCorr{dpH}(:,edgeI)];
        twoEnvPctBecomeUncorrAgg{edgeI} = [twoEnvPctBecomeUncorrAgg{edgeI}; twoEnvPctBecomeUncorr{dpH}(:,edgeI)];
        twoEnvPctStillUncorrAgg{edgeI} = [twoEnvPctStillUncorrAgg{edgeI}; twoEnvPctStillUncorr{dpH}(:,edgeI)];
    end
end

disp('Useful figures here')
%{
figure;
for edgeI = 1:nEdgeThreshes
    subplot(1,nEdgeThreshes,edgeI)
    datH = [];
    datJ = [];
    for sessJ = 1:numel(daysHere)
        sessI = daysHere(sessJ);
        datH = [datH; oneEnvPctCellsInComp{sessI}{edgeI}];
        datJ = [datJ; twoEnvPctCellsInComp{sessI}{edgeI}];
    end
    
    plot(1*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{1})
    hold on
    plot(2*ones(size(datJ)),datJ,'.','MarkerEdgeColor',groupColors{2})
end

figure;
subplot(1,2,1)
daysPlot = 1:3;
for edgeI = 1:nEdgeThreshes
    datH = [];
    datJ = [];
    for sessJ = 1:numel(daysPlot)
        sessI = daysPlot(sessJ);
        datH = [datH; oneEnvPctCellsInComp{sessI}{edgeI}];
        datJ = [datJ; twoEnvPctCellsInComp{sessI}{edgeI}];
    end
    
    plot((plotOffsets(1)+edgeI)*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{1})
    hold on
    plot((plotOffsets(2)+edgeI)*ones(size(datJ)),datJ,'.','MarkerEdgeColor',groupColors{2})
    
    [pHere, hHere] = ranksum(datH,datJ);
    text(edgeI,0.3,num2str(pHere),'Rotation',90)
end
xlim([1+plotOffsets(1)-0.1 numel(edgeThreshes)+plotOffsets(2)+0.1])
ylim([0.2 1.1])
ylabel('pct cellsInComp / cellsActive')
title('Days 1-3')
vv = gca;
vv.XTick = 1:numel(edgeThreshes);
vv.XTickLabel = cellfun(@(x) num2str(x),mat2cell(edgeThreshes',ones(numel(edgeThreshes),1),1),'UniformOutput',false);
vv.XTickLabelRotation = 45;
xlabel('Correlation Edge Threshold')
MakePlotPrettySL(vv);

subplot(1,2,2)
daysPlot = 7:9;
for edgeI = 1:nEdgeThreshes
    datH = [];
    datJ = [];
    for sessJ = 1:numel(daysPlot)
        sessI = daysPlot(sessJ);
        datH = [datH; oneEnvPctCellsInComp{sessI}{edgeI}];
        datJ = [datJ; twoEnvPctCellsInComp{sessI}{edgeI}];
    end
    
    plot((plotOffsets(1)+edgeI)*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{1})
    hold on
    plot((plotOffsets(2)+edgeI)*ones(size(datJ)),datJ,'.','MarkerEdgeColor',groupColors{2})
    
    [pHere, hHere] = ranksum(datH,datJ);
    text(edgeI,0.3,num2str(pHere),'Rotation',90)
end
xlim([1+plotOffsets(1)-0.1 numel(edgeThreshes)+plotOffsets(2)+0.1])
ylim([0.2 1.1])
ylabel('pct cellsInComp / cellsActive')
title('Days 7-9')
vv = gca;
vv.XTick = 1:numel(edgeThreshes);
vv.XTickLabel = cellfun(@(x) num2str(x),mat2cell(edgeThreshes',ones(numel(edgeThreshes),1),1),'UniformOutput',false);
vv.XTickLabelRotation = 45;
xlabel('Correlation Edge Threshold')
MakePlotPrettySL(vv);

suptitleSL('Pct Cells in a Cluster / number Cells Active')

    ylabel('pct cellsInComp / cellsActive')
    title(['Thresh = ' num2str(edgeThreshes(edgeI))])
    xlim([0.9 2.1])
    ylim([0 1.05])
end
%}
plotOffsets = [-0.1 0.1];



figure;
for edgeI = 1:numel(edgeThreshes)
    datH = oneEnvPctStillCorrAgg{edgeI};
    plot((edgeI-0.1)*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{1})
    hold on
    datJ = twoEnvPctStillCorrAgg{edgeI};
    plot((edgeI+0.1)*ones(size(datJ)),datJ,'.','MarkerEdgeColor',groupColors{2})
    [pp,hh] = ranksum(datH,datJ);
    text(edgeI,0.25,num2str(pp),'Rotation',90)
    
    plot([-0.3 0]+edgeI,mean(datH)*[1 1],'k')
    plot([0 0.3]+edgeI,mean(datJ)*[1 1],'k')
end
vv = gca;
vv.XTick = 1:numel(edgeThreshes);
vv.XTickLabel = cellfun(@(x) num2str(x),mat2cell(edgeThreshes',ones(numel(edgeThreshes),1),1),'UniformOutput',false);
vv.XTickLabelRotation = 45;
xlabel('Correlation Edge Threshold')
ylabel('Pct pairs still correlated / num pairs active')
MakePlotPrettySL(vv);
ylim([-0.01 0.3])
%{
figure;
for edgeI = 1:numel(edgeThreshes)
    datH = oneEnvPctBecomeCorrAgg{edgeI};
    plot((edgeI-0.1)*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{1})
    hold on
    datJ = twoEnvPctBecomeCorrAgg{edgeI};
    plot((edgeI+0.1)*ones(size(datJ)),datJ,'.','MarkerEdgeColor',groupColors{2})
    [pp,hh] = ranksum(datH,datJ);
    text(edgeI,0.325,num2str(pp),'Rotation',90)
    
    plot([-0.3 0]+edgeI,mean(datH)*[1 1],'k')
    plot([0 0.3]+edgeI,mean(datJ)*[1 1],'k')
end
vv = gca;
vv.XTick = 1:numel(edgeThreshes);
vv.XTickLabel = cellfun(@(x) num2str(x),mat2cell(edgeThreshes',ones(numel(edgeThreshes),1),1),'UniformOutput',false);
vv.XTickLabelRotation = 45;
xlabel('Correlation Edge Threshold')
ylabel('Pct pairs become correlated / num pairs active')
%ylim([-0.01 0.4])

figure;
for edgeI = 1:numel(edgeThreshes)
    datH = oneEnvPctBecomeUncorrAgg{edgeI};
    plot((edgeI-0.1)*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{1})
    hold on
    datJ = twoEnvPctBecomeUncorrAgg{edgeI};
    plot((edgeI+0.1)*ones(size(datJ)),datJ,'.','MarkerEdgeColor',groupColors{2})
    [pp,hh] = ranksum(datH,datJ);
    text(edgeI,0.325,num2str(pp),'Rotation',90)
    
    plot([-0.3 0]+edgeI,mean(datH)*[1 1],'k')
    plot([0 0.3]+edgeI,mean(datJ)*[1 1],'k')
end
vv = gca;
vv.XTick = 1:numel(edgeThreshes);
vv.XTickLabel = cellfun(@(x) num2str(x),mat2cell(edgeThreshes',ones(numel(edgeThreshes),1),1),'UniformOutput',false);
vv.XTickLabelRotation = 45;
xlabel('Correlation Edge Threshold')
ylabel('Pct pairs become ucorrelated / num pairs active')
%ylim([-0.01 0.4])
%}

%{
% number of comps as pct of cells here
plotOffsets = [-0.1 0.1];
figure;
subplot(1,2,1)
daysPlot = 1:3;
for edgeI = 1:nEdgeThreshes
    datH = [];
    datJ = [];
    for sessJ = 1:numel(daysPlot)
        sessI = daysPlot(sessJ);
        datH = [datH; oneEnvPctComps{sessI}{edgeI}];
        datJ = [datJ; twoEnvPctComps{sessI}{edgeI}];
    end
    
    plot((plotOffsets(1)+edgeI)*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{1})
    hold on
    plot((plotOffsets(2)+edgeI)*ones(size(datJ)),datJ,'.','MarkerEdgeColor',groupColors{2})
    
    [pHere, hHere] = ranksum(datH,datJ);
    text(edgeI,0.1,num2str(pHere),'Rotation',90)
end
ylim([0 0.15])
ylabel('number of connComps / cellsActive')
title('Days 1-3')
vv = gca;
vv.XTick = 1:numel(edgeThreshes);
vv.XTickLabel = cellfun(@(x) num2str(x),mat2cell(edgeThreshes',ones(numel(edgeThreshes),1),1),'UniformOutput',false);
vv.XTickLabelRotation = 45;
xlim([1+plotOffsets(1)-0.1 numel(edgeThreshes)+plotOffsets(2)+0.1])
xlabel('Correlation Edge Threshold')

subplot(1,2,2)
daysPlot = 7:9;
for edgeI = 1:nEdgeThreshes
    datH = [];
    datJ = [];
    for sessJ = 1:numel(daysPlot)
        sessI = daysPlot(sessJ);
        datH = [datH; oneEnvPctComps{sessI}{edgeI}];
        datJ = [datJ; twoEnvPctComps{sessI}{edgeI}];
    end
    
    plot((plotOffsets(1)+edgeI)*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{1})
    hold on
    plot((plotOffsets(2)+edgeI)*ones(size(datJ)),datJ,'.','MarkerEdgeColor',groupColors{2})
    
    [pHere, hHere] = ranksum(datH,datJ);
    text(edgeI,0.1,num2str(pHere),'Rotation',90)
end

ylim([0 0.15])
ylabel('number of connComps / cellsActive')
title('Days 7-9')
vv = gca;
vv.XTick = 1:numel(edgeThreshes);
vv.XTickLabel = cellfun(@(x) num2str(x),mat2cell(edgeThreshes',ones(numel(edgeThreshes),1),1),'UniformOutput',false);
vv.XTickLabelRotation = 45;
xlim([1+plotOffsets(1)-0.1 numel(edgeThreshes)+plotOffsets(2)+0.1])
xlabel('Correlation Edge Threshold')
suptitleSL('number of connComps / number Cells Active')
%}



%{
% Sizes of connComps as pct of cells here
plotOffsets = [-0.1 0.1];
figure;
subplot(1,2,1)
daysPlot = 1:3;
for edgeI = 1:nEdgeThreshes
    datH = [];
    datJ = [];
    for sessJ = 1:numel(daysPlot)
        sessI = daysPlot(sessJ);
        datH = [datH; cell2mat(oneEnvCompPctSizes{sessI}{edgeI})];
        datJ = [datJ; cell2mat(twoEnvCompPctSizes{sessI}{edgeI})];
    end
    
    plot((plotOffsets(1)+edgeI)*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{1})
    hold on
    plot((plotOffsets(2)+edgeI)*ones(size(datJ)),datJ,'.','MarkerEdgeColor',groupColors{2})
    
    [pHere, hHere] = ranksum(datH,datJ);
    text(edgeI,0.1,num2str(pHere),'Rotation',90)
end
%ylim([0 0.15])
ylabel('connComp sizes / cellsActive')
title('Days 1-3')
vv = gca;
vv.XTick = 1:numel(edgeThreshes);
vv.XTickLabel = cellfun(@(x) num2str(x),mat2cell(edgeThreshes',ones(numel(edgeThreshes),1),1),'UniformOutput',false);
vv.XTickLabelRotation = 45;
xlim([1+plotOffsets(1)-0.1 numel(edgeThreshes)+plotOffsets(2)+0.1])
xlabel('Correlation Edge Threshold')

subplot(1,2,2)
daysPlot = 7:9;
for edgeI = 1:nEdgeThreshes
    datH = [];
    datJ = [];
    for sessJ = 1:numel(daysPlot)
        sessI = daysPlot(sessJ);
        datH = [datH; cell2mat(oneEnvCompPctSizes{sessI}{edgeI})];
        datJ = [datJ; cell2mat(twoEnvCompPctSizes{sessI}{edgeI})];
    end
    
    plot((plotOffsets(1)+edgeI)*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{1})
    hold on
    plot((plotOffsets(2)+edgeI)*ones(size(datJ)),datJ,'.','MarkerEdgeColor',groupColors{2})
    
    [pHere, hHere] = ranksum(datH,datJ);
    text(edgeI,0.1,num2str(pHere),'Rotation',90)
end
%ylim([0 0.15])
ylabel('connComp sizes / cellsActive')
title('Days 7-9')
vv = gca;
vv.XTick = 1:numel(edgeThreshes);
vv.XTickLabel = cellfun(@(x) num2str(x),mat2cell(edgeThreshes',ones(numel(edgeThreshes),1),1),'UniformOutput',false);
vv.XTickLabelRotation = 45;
xlim([1+plotOffsets(1)-0.1 numel(edgeThreshes)+plotOffsets(2)+0.1])
xlabel('Correlation Edge Threshold')
suptitleSL('connComp sizes / number Cells Active')
%}



% Single Sess comparisons
%{
figure;
for sessJ = 1:numel(daysHere)
    sessI = daysHere(sessJ);
    subplot(2,numel(daysHere),sessJ)
    
    for edgeI = 4:nEdgeThreshes
        datH = oneEnvPctComps{sessI}{edgeI};
        plot(edgeThreshes(edgeI)*ones(size(datH)),datH,'.')
        hold on
    end
    title(['Day ' num2str(sessI)])
    
    if sessJ == 1; ylabel('nComps / cellsActive'); end
    
    subplot(2,numel(daysHere),sessJ+numel(daysHere))
    
    for edgeI = 4:nEdgeThreshes
        datH = twoEnvPctComps{sessI}{edgeI};
        plot(edgeThreshes(edgeI)*ones(size(datH)),datH,'.')
        hold on
    end
    if sessJ == 1; ylabel('nComps / cellsActive'); end
    xlabel('Corr Edge Thresh')
end
suptitleSL(' number of comps as pct of cells here (xxxEnvPctComps)')

figure;
for sessJ = 1:numel(daysHere)
    sessI = daysHere(sessJ);
    subplot(2,numel(daysHere),sessJ)
    
    for edgeI = 4:nEdgeThreshes
        datH = oneEnvPctCellsInComp{sessI}{edgeI};
        plot(edgeThreshes(edgeI)*ones(size(datH)),datH,'.')
        hold on
    end
    title(['Day ' num2str(sessI)])
    
    if sessJ == 1; ylabel('cellsInComp / cellsActive'); end
    
    subplot(2,numel(daysHere),sessJ+numel(daysHere))
    
    for edgeI = 4:nEdgeThreshes
        datH = twoEnvPctCellsInComp{sessI}{edgeI};
        plot(edgeThreshes(edgeI)*ones(size(datH)),datH,'.')
        hold on
    end
    if sessJ == 1; ylabel('cellsInComp / cellsActive'); end
    xlabel('Corr Edge Thresh')
end
suptitleSL(' pact active cells in a comp (xxxEnvPctCellsInComp)')
%}


% Across day pairs, among cells active both days:
% - number of cells that were in a connected comp, now are not
% - change in comp sizes among just these cells
% - are each pair of cells still in a comp togehter, are cells that weren't
% now in a comp together
%{
xlabs = {'C-C','U-C','C-U'};
figure;
for edgeI = 1:nEdgeThreshes
    subplot(1,nEdgeThreshes,edgeI)
    
    datH = oneEnvPctStillCorrAgg{edgeI};
    plot(0.9*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{1})
    hold on
    datJ = twoEnvPctStillCorrAgg{edgeI};
    plot(1.1*ones(size(datJ)),datJ,'.','MarkerEdgeColor',groupColors{2})
    [hh,pp] = ranksum(datH,datJ);
    
    datH = oneEnvPctBecomeCorrAgg{edgeI};
    plot(1.9*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{1})
    hold on
    datJ = twoEnvPctBecomeCorrAgg{edgeI};
    plot(2.1*ones(size(datJ)),datJ,'.','MarkerEdgeColor',groupColors{2})
    [hh,pp] = ranksum(datH,datJ);
    
    datH = oneEnvPctBecomeUncorrAgg{edgeI};
    plot(2.9*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{1})
    hold on
    datJ = twoEnvPctBecomeUncorrAgg{edgeI};
    plot(3.1*ones(size(datJ)),datJ,'.','MarkerEdgeColor',groupColors{2})
    [hh,pp] = ranksum(datH,datJ);
    
    xlabel('Corr category')
    ylabel('Pct')
    title(['thresh=' num2str(edgeThreshes(edgeI))])
    aa = gca;
    aa.XTick = [1 2 3];
    aa.XTickLabel = xlabs;
    xlim([0.8 3.2])
end
suptitleSL('Pct cell pairs correlated across day pairs 1:3 vs. 7:9')
%}

  %{  
figure;
%xlabs = {'C-C','U-C','C-U','U-U'};
xlabs = {'C-C','U-C','C-U'};
for dpH = 1:size(dayPairsHere,1)
    for edgeI = 4:nEdgeThreshes
        subplot(2,numel(4:nEdgeThreshes),edgeI - 3)
        xlabel('Corr category')
        ylabel('Pct')
        title(['One Env, th=' num2str(edgeThreshes(edgeI))])
        
        datH = oneEnvPctStillCorr{dpH}(:,edgeI);
        plot(1*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{1})
        hold on
        datH = oneEnvPctBecomeCorr{dpH}(:,edgeI);
        plot(2*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{1})
        hold on
        datH = oneEnvPctBecomeUncorr{dpH}(:,edgeI);
        plot(3*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{1})
        %hold on
        %datH = oneEnvPctStillUncorr{dpH}(:,edgeI);
        %plot(4*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{1})
        
        aa = gca; aa.XTickLabel = xlabs;
        xlim([0.9 3.1])
        
        subplot(2,numel(4:nEdgeThreshes),edgeI+numel(4:nEdgeThreshes)-3)
        xlabel('Corr category')
        ylabel('Pct')
        title(['Two Env, th=' num2str(edgeThreshes(edgeI))])
        
        datH = twoEnvPctStillCorr{dpH}(:,edgeI);
        plot(1*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{2})
        hold on
        datH = twoEnvPctBecomeCorr{dpH}(:,edgeI);
        plot(2*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{2})
        hold on
        datH = twoEnvPctBecomeUncorr{dpH}(:,edgeI);
        plot(3*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{2})
        %hold on
        %datH = twoEnvPctStillUncorr{dpH}(:,edgeI);
        %plot(4*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{2})
        
        aa = gca; aa.XTickLabel = xlabs;
        %xlim([0.9 4.1])
        xlim([0.9 3.1])
    end
end
suptitleSL('Need to aggregate these by category, across dayPairs, ranksum test')
%}

disp('Work here on change over days, not sure which is right yet')
for sessJ = 1:numel(daysHere)
    sessI = daysHere(sessJ);
    subplot(2,numel(daysHere),sessJ)
    
    for edgeI = 4:nEdgeThreshes
        datH = oneEnvPctComps{sessI}{edgeI};
        plot(edgeThreshes(edgeI)*ones(size(datH)),datH,'.')
        hold on
    end
    title(['Day ' num2str(sessI)])
    
    if sessJ == 1; ylabel('nComps / cellsActive'); end
    
    subplot(2,numel(daysHere),sessJ+numel(daysHere))
    
    for edgeI = 4:nEdgeThreshes
        datH = twoEnvPctComps{sessI}{edgeI};
        plot(edgeThreshes(edgeI)*ones(size(datH)),datH,'.')
        hold on
    end
    if sessJ == 1; ylabel('nComps / cellsActive'); end
    xlabel('Corr Edge Thresh')
end
suptitleSL(' number of comps as pct of cells here (xxxEnvPctComps)')


figure;
for sessJ = 1:numel(daysHere)
    sessI = daysHere(sessJ);
    
    subplot(2,numel(daysHere),sessJ)
    histogram(oneEnvTcorrs{sessI},[-1.05:0.1:1.05],'FaceColor',groupColors{1})
    title(['OneMaze tCorrs day ' num2str(sessI)])
    xlabel('Pearson R')
    
    subplot(2,numel(daysHere),sessJ+numel(daysHere))
    histogram(twoEnvTcorrs{sessI},[-1.05:0.1:1.05],'FaceColor',groupColors{2})
    title(['TwoMaze tCorrs day ' num2str(sessI)])
    xlabel('Pearson R')
    
    ppp = ranksum(oneEnvTcorrs{sessI},twoEnvTcorrs{sessI});
    [~,pppks] = kstest2(oneEnvTcorrs{sessI},twoEnvTcorrs{sessI});
    disp(['day ' num2str(sessI) ' ranksum p = ' num2str(ppp) ', ks p = ' num2str(pppks)])
end
suptitleSL('Distribution of corrs each day')

oneEnvTcorrsBefore = cell2mat(oneEnvTcorrs(1:3));
oneEnvTcorrsAfter = cell2mat(oneEnvTcorrs(7:9));
twoEnvTcorrsBefore = cell2mat(twoEnvTcorrs(1:3));
twoEnvTcorrsAfter = cell2mat(twoEnvTcorrs(7:9));
figure; 
subplot(2,2,1)
histogram(oneEnvTcorrsBefore,[-1.05:0.1:1.05],'FaceColor',groupColors{1})
subplot(2,2,3)
histogram(twoEnvTcorrsBefore,[-1.05:0.1:1.05],'FaceColor',groupColors{2})
subplot(2,2,2)
histogram(oneEnvTcorrsAfter,[-1.05:0.1:1.05],'FaceColor',groupColors{1})
subplot(2,2,4)
histogram(twoEnvTcorrsAfter,[-1.05:0.1:1.05],'FaceColor',groupColors{2})
ppp = ranksum(oneEnvTcorrsBefore,twoEnvTcorrsBefore);
[~,pppks] = kstest2(oneEnvTcorrsBefore,twoEnvTcorrsBefore);
disp(['days 1:3 ranksum p = ' num2str(ppp) ', ks p = ' num2str(pppks)])
ppp = ranksum(oneEnvTcorrsAfter,twoEnvTcorrsAfter);
[~,pppks] = kstest2(oneEnvTcorrsAfter,twoEnvTcorrsAfter);
disp(['days 7:9 ranksum p = ' num2str(ppp) ', ks p = ' num2str(pppks)])
suptitleSL('Distribution of corrs days 1:3, 7:9')

for edgeI = 1:nEdgeThreshes
    figure;
    for sessJ = 1:numel(daysHere)
        sessI = daysHere(sessJ);
        subplot(2,numel(daysHere),sessJ)
        %histogram(oneEnvNcorrEdges{sessI}{edgeI},'FaceColor',groupColors{1})
        histogram(oneEnvPctCorrEdges{sessI}{edgeI},'FaceColor',groupColors{1})
        
        subplot(2,numel(daysHere),sessJ+numel(daysHere))
        %histogram(twoEnvNcorrEdges{sessI}{edgeI},'FaceColor',groupColors{2})
        histogram(twoEnvPctCorrEdges{sessI}{edgeI},'FaceColor',groupColors{2})
        
        %ppp = ranksum(oneEnvNcorrEdges{sessI}{edgeI},twoEnvNcorrEdges{sessI}{edgeI});
        %[~,pppKS] = kstest2(oneEnvNcorrEdges{sessI}{edgeI},twoEnvNcorrEdges{sessI}{edgeI});
        ppp = ranksum(oneEnvPctCorrEdges{sessI}{edgeI},twoEnvPctCorrEdges{sessI}{edgeI});
        [~,pppKS] = kstest2(oneEnvPctCorrEdges{sessI}{edgeI},twoEnvPctCorrEdges{sessI}{edgeI});
        title([num2str(ppp) ' ' num2str(pppKS)])
    end
    suptitleSL(['edgeThreshold ' num2str(edgeThreshes(edgeI))])
end

oneEnvTcorrChanges = cell(size(dayPairsHere,1),1);
oneEnvNcorrEdgeChanges = cell(size(dayPairsHere,1),1); [oneEnvNcorrEdgeChanges{:}] = deal(cell(nEdgeThreshes,1));
oneEnvPctCorrEdgeChanges = cell(size(dayPairsHere,1),1); [oneEnvPctCorrEdgeChanges{:}] = deal(cell(nEdgeThreshes,1));
twoEnvTcorrChanges = cell(size(dayPairsHere,1),1);
twoEnvNcorrEdgeChanges = cell(size(dayPairsHere,1),1); [twoEnvNcorrEdgeChanges{:}] = deal(cell(nEdgeThreshes,1));
twoEnvPctCorrEdgeChanges = cell(size(dayPairsHere,1),1); [twoEnvPctCorrEdgeChanges{:}] = deal(cell(nEdgeThreshes,1));


for mouseI = 1:numMice
    corrsBlank = zeros(numCells(mouseI));
    
    % Distribution of corr changes
    for dpI = 1:size(dayPairsHere,1)
        dayA = dayPairsHere(dpI,1);
        dayB = dayPairsHere(dpI,2);
        if any(any(cellPairsUsed{mouseI}{dayA})) && any(any(cellPairsUsed{mouseI}{dayB}))
            crossCorrMatA = corrsBlank;
            [cellPairsInds] = sub2ind([1 1]*numCells(mouseI),cellPairsUsed{mouseI}{dayA}(:,1),cellPairsUsed{mouseI}{dayA}(:,2));
            [cellPairsIndss] = sub2ind([1 1]*numCells(mouseI),cellPairsUsed{mouseI}{dayA}(:,2),cellPairsUsed{mouseI}{dayA}(:,1));
            crossCorrMatA(cellPairsInds) = temporalCorrsR{mouseI}{dayA};
            crossCorrMatA(cellPairsIndss) = temporalCorrsR{mouseI}{dayA};
            
            crossCorrMatB = corrsBlank;
            [cellPairsInds] = sub2ind([1 1]*numCells(mouseI),cellPairsUsed{mouseI}{dayB}(:,1),cellPairsUsed{mouseI}{dayB}(:,2));
            [cellPairsIndss] = sub2ind([1 1]*numCells(mouseI),cellPairsUsed{mouseI}{dayB}(:,2),cellPairsUsed{mouseI}{dayB}(:,1));
            crossCorrMatB(cellPairsInds) = temporalCorrsR{mouseI}{dayB};
            crossCorrMatB(cellPairsIndss) = temporalCorrsR{mouseI}{dayB};
            
            cellsUseHere = dayUseAll{mouseI}(:,dayA) & dayUseAll{mouseI}(:,dayB);
            cellPairsUse = cellsUseHere(:) & cellsUseHere(:)';
            
            % Distribution of all corr changes
            corrChanges = crossCorrMatB(cellPairsUse) -  crossCorrMatA(cellPairsUse);
            
            switch groupNum(mouseI)
                case 1
                    oneEnvTcorrChanges{dpI} = [oneEnvTcorrChanges{dpI}; corrChanges];
                case 2
                    twoEnvTcorrChanges{dpI} = [twoEnvTcorrChanges{dpI}; corrChanges];
            end
            
            for edgeI = 1:numel(edgeThreshes)
                edgeThresh = edgeThreshes(edgeI);
                
                % Edge changes
                crossCorrEdgesA = crossCorrMatA > edgeThresh;
                crossCorrEdgesB = crossCorrMatB > edgeThresh;

                nEdgesA = sum(crossCorrEdgesA,2);
                nEdgesB = sum(crossCorrEdgesB,2);
                nEdgeChanges = nEdgesB - nEdgesA;
                pctEdgesA = nEdgesA / sum(cellsUseHere);
                pctEdgesB = nEdgesB / sum(cellsUseHere);
                pctEdgeChanges = pctEdgesB - pctEdgesA;

                switch groupNum(mouseI)
                    case 1
                        oneEnvNcorrEdgeChanges{dpI}{edgeI} = [oneEnvNcorrEdgeChanges{dpI}{edgeI}; nEdgeChanges(cellsUseHere)];
                        oneEnvPctCorrEdgeChanges{dpI}{edgeI} = [oneEnvPctCorrEdgeChanges{dpI}{edgeI}; pctEdgeChanges(cellsUseHere)];
                    case 2
                        twoEnvNcorrEdgeChanges{dpI}{edgeI} = [twoEnvNcorrEdgeChanges{dpI}{edgeI}; nEdgeChanges(cellsUseHere)];
                        twoEnvPctCorrEdgeChanges{dpI}{edgeI} = [twoEnvPctCorrEdgeChanges{dpI}{edgeI}; pctEdgeChanges(cellsUseHere)];
                end

            end
            
            % Other metrics from gava, chokanathan
            
        end
    end
end
            
oneEnvNedgeChanges = cell(numel(edgeThreshes),1);
twoEnvNedgeChanges = cell(numel(edgeThreshes),1);
oneEnvPctEdgeChanges = cell(numel(edgeThreshes),1);
twoEnvPctEdgeChanges = cell(numel(edgeThreshes),1);
for edgeI = 1:numel(edgeThreshes)
    for dpI = 1:size(dayPairsHere,1)
        oneEnvNedgeChanges{edgeI} = [oneEnvNedgeChanges{edgeI}; oneEnvNcorrEdgeChanges{dpI}{edgeI}];
        twoEnvNedgeChanges{edgeI} = [twoEnvNedgeChanges{edgeI}; twoEnvNcorrEdgeChanges{dpI}{edgeI}];
        oneEnvPctEdgeChanges{edgeI} = [oneEnvPctEdgeChanges{edgeI}; oneEnvNcorrEdgeChanges{dpI}{edgeI}];
        twoEnvPctEdgeChanges{edgeI} = [twoEnvPctEdgeChanges{edgeI}; twoEnvNcorrEdgeChanges{dpI}{edgeI}];
    end
end

for edgeI = 1:nEdgeThreshes
    ppp = ranksum(oneEnvNedgeChanges{edgeI},twoEnvNedgeChanges{edgeI});
    [~,pppKS] = kstest2(oneEnvNedgeChanges{edgeI},twoEnvNedgeChanges{edgeI});
    disp(['Number: Edge ' num2str(edgeThreshes(edgeI)) ': ranksum = ' num2str(ppp) ', ks = ' num2str(pppKS)])
    ppp = ranksum(oneEnvPctEdgeChanges{edgeI},twoEnvPctEdgeChanges{edgeI});
    [~,pppKS] = kstest2(oneEnvPctEdgeChanges{edgeI},twoEnvPctEdgeChanges{edgeI});
    disp(['Pct: Edge ' num2str(edgeThreshes(edgeI)) ': ranksum = ' num2str(ppp) ', ks = ' num2str(pppKS)])
end
        
        
        
        