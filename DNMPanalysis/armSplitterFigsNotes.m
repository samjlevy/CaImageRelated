%% How many splitters pie chart

pieSplitLabels = {'splitBOTH','splitLRonly','dontSplit','splitSTonly'};
splitterTGinds = cell2mat(cellfun(@(x) find(strcmpi(traitLabels,x)),pieSplitLabels,'UniformOutput',false));
pieSplitColors = colorAssc(splitterTGinds);
pieSplitColors{3} = [1 1 1];
pieData = ARMsplitPropMeans(splitterTGinds);
%pieSEMs = ARMsplitPropSEMs(splitterTGinds);

pieDataPct = round(pieData'*100,3); 
pieDataPct(rem(pieDataPct,0.01)==0) = pieDataPct(rem(pieDataPct,0.01)==0)+0.001;
pieDataPct = mat2cell(pieDataPct,ones(1,length(pieData)),1);
pieDataPct = cellfun(@num2str,pieDataPct,'UniformOutput',false);
pieDataPct = cellfun(@(x) x(1:end-1),pieDataPct,'UniformOutput',false);

%{
pieDataSEMs = round(pieSEMs'*100,3); 
pieDataSEMs(rem(pieDataSEMs,0.01)==0) = pieDataSEMs(rem(pieDataSEMs,0.01)==0)+0.001;
pieDataSEMs = mat2cell(pieDataSEMs,ones(1,length(pieData)),1);
pieDataSEMs = cellfun(@num2str,pieDataSEMs,'UniformOutput',false);
pieDataSEMs = cellfun(@(x) x(1:end-1),pieDataSEMs,'UniformOutput',false);
%}
pp=figure; axes(pp)
pie(pieData,pieSplitLabels);
colormap(reshape([pieSplitColors{:}],3,length(pieSplitColors))')
for ppI = 1:length(pp.Children.Children)
    if strcmpi(class(pp.Children.Children(ppI)),'matlab.graphics.primitive.Text')
        ppUse = find(cell2mat(cellfun(@(x) strcmpi(x,pp.Children.Children(ppI).String),pieSplitLabels,'UniformOutput',false)));
        %pp.Children.Children(ppI).String = {pieSplitLabels{ppUse}; [pieDataPct{ppUse} ' ' char(177) ' ' pieDataSEMs{ppUse} '%']}; 
        pp.Children.Children(ppI).String = {pieSplitLabels{ppUse}; [pieDataPct{ppUse} '%']};
        pp.Children.Children(ppI).FontSize = 13;
    end
end

title('Mean number of each ARM splitter, all days all mice')

%% Change in Proportion of Each ARM splitter type by days apart
%Comparison
plotREV=1;

gg=figure('Position',[65 410 1813 510]);
sRows = 1;
sCols = 3;
for pcI = 1:length(cpsPlot)
    subplot(sRows,sCols,pcI)
    pcIndsHere = pairsCompareInd(cpsPlot(pcI),:);
    %plot data
    plot(pooledDaysApartFWD-0.1,ARMpooledSplitPctChangeFWD{pcIndsHere(1)},'.','Color',colorAssc{pcIndsHere(1)},'MarkerSize',12)
    hold on
    plot(pooledDaysApartFWD+0.1,ARMpooledSplitPctChangeFWD{pcIndsHere(2)},'.','Color',colorAssc{pcIndsHere(2)},'MarkerSize',12)
    %plot reg fit line    
    plot(ARMsplitterFitPlotDays,ARMsplitterFitPlotPct{pcIndsHere(1)},'Color',colorAssc{pcIndsHere(1)},'LineWidth',2)
    plot(ARMsplitterFitPlotDays,ARMsplitterFitPlotPct{pcIndsHere(2)},'Color',colorAssc{pcIndsHere(2)},'LineWidth',2)
    
    if plotREV==1
        plot(pooledDaysApartREV-0.1,ARMpooledSplitPctChangeREV{pcIndsHere(1)},'.','Color',colorAssc{pcIndsHere(1)},'MarkerSize',12)
        plot(pooledDaysApartREV+0.1,ARMpooledSplitPctChangeREV{pcIndsHere(2)},'.','Color',colorAssc{pcIndsHere(2)},'MarkerSize',12)   
        plot(ARMsplitterFitPlotDaysREV,ARMsplitterFitPlotPctREV{pcIndsHere(1)},'Color',colorAssc{pcIndsHere(1)},'LineWidth',2)
        plot(ARMsplitterFitPlotDaysREV,ARMsplitterFitPlotPctREV{pcIndsHere(2)},'Color',colorAssc{pcIndsHere(2)},'LineWidth',2)
    end
    
    ylim([-0.5 0.5])
    xlim([0.5 max(pooledDaysApartFWD)-0.5]) %cell2mat(cellfun(@max,cellRealDays,'UniformOutput',false))
    if plotREV==1; xlim([min(pooledDaysApartREV)-0.5 max(pooledDaysApartFWD)-0.5]); end
    xlabel('Days Apart')
    ylabel('Proportion Change')
    %indicate the r2 of each line
    %switch slopeDiffRank(pcI)>=(1*numPerms-numPerms*pThresh); case 1; diffTxt='ARE'; case 0; diffTxt ='ARE NOT'; end
    %title([pairsCompare{pcI,1} ' vs ' pairsCompare{pcI,2} ', slopes ' diffTxt ' diff at p = ' num2str(1-slopeDiffRank(pcI)/1000)])
    switch ARMpVal(cpsPlot(pcI))<pThresh; case 1; diffTxt='ARE'; case 0; diffTxt ='are NOT'; end
    title([ARMtraitLabels{pcIndsHere(1)} ' vs ' ARMtraitLabels{pcIndsHere(2)} ', slopes ' diffTxt ' diff at p = ' num2str(ARMpVal(cpsPlot(pcI)))])
    legend(ARMtraitLabels{pcIndsHere(1)},ARMtraitLabels{pcIndsHere(2)})
end
suptitleSL('Changes by days apart in proportion of ARM splitting type')

%% Prop of ARM splitters that come back
%Comparison
figure;
sRows = 1;
sCols = 3;
for pcI = 1:length(cpsPlot)
    subplot(sRows,sCols,pcI)
    pcIndsHere = pairsCompareInd(cpsPlot(pcI),:);
    p1 = plot(pooledDaysApartFWD-0.1,ARMpooledSplitterComesBackFWD{pcIndsHere(1)},'.','Color',colorAssc{pcIndsHere(1)},'MarkerSize',8,'DisplayName',pairsCompare{pcI,1});
    hold on
    p2 = plot(pooledDaysApartFWD+0.1,ARMpooledSplitterComesBackFWD{pcIndsHere(2)},'.','Color',colorAssc{pcIndsHere(2)},'MarkerSize',8,'DisplayName',pairsCompare{pcI,2});
    
    plot(pooledDaysApartREV-0.1,ARMpooledSplitterComesBackREV{pcIndsHere(1)},'.','Color',colorAssc{pcIndsHere(1)},'MarkerSize',8)
    plot(pooledDaysApartREV+0.1,ARMpooledSplitterComesBackREV{pcIndsHere(2)},'.','Color',colorAssc{pcIndsHere(2)},'MarkerSize',8)
    
    ylim([-0.01 1.01])
    %xlim([(-1*max(numDays)+0.5) (max(numDays)-0.5)])
    xlim([(min(pooledDaysApartREV)-0.5) (max(pooledDaysApartFWD)-0.5)])
    xlabel('Days Apart')
    ylabel('% of cells in model')
    
    yHeight = 0.8;
    for dpI = 1:length(ARMdayPairsSCB{pcI})
        if ARMwhichWonSplitterComesBack{pcI}(dpI) > 0
        if ARMhValSplitterComesBack{pcI}(dpI)==1
            plot(ARMdayPairsSCB{pcI}(dpI),yHeight,'*','Color',colorAssc{pcIndsHere(ARMwhichWonSplitterComesBack{pcI}(dpI))})
        end
        end
        %pValSplitterComesBack{pcI}
    end
       
    % legend([p1; p2],[pairsCompare{pcI,1}; pairsCompare{pcI,2}],'location','NW')  
    legend([p1; p2],'location','NW') 
end
suptitleSL('Percent ARM cells of model day come back on ARMs')

%% Prop of ARM splitters that are still an ARM splitter
figure;
sRows = 1;
sCols = 3;
for pcI = 1:length(cpsPlot)
    subplot(sRows,sCols,pcI)
    pcIndsHere = pairsCompareInd(cpsPlot(pcI),:);
    p1 = plot(pooledDaysApartFWD-0.1,ARMpooledSplitterStillSplitterFWD{pcIndsHere(1)},'.','Color',colorAssc{pcIndsHere(1)},'MarkerSize',8,'DisplayName',pairsCompare{pcI,1});
    hold on
    p2 = plot(pooledDaysApartFWD+0.1,ARMpooledSplitterStillSplitterFWD{pcIndsHere(2)},'.','Color',colorAssc{pcIndsHere(2)},'MarkerSize',8,'DisplayName',pairsCompare{pcI,2});
    
    plot(pooledDaysApartREV-0.1,ARMpooledSplitterStillSplitterREV{pcIndsHere(1)},'.','Color',colorAssc{pcIndsHere(1)},'MarkerSize',8)
    plot(pooledDaysApartREV+0.1,ARMpooledSplitterStillSplitterREV{pcIndsHere(2)},'.','Color',colorAssc{pcIndsHere(2)},'MarkerSize',8)
    
    ylim([-0.01 1.01])
    %xlim([(-1*max(numDays)+0.5) (max(numDays)-0.5)])
    xlim([(min(pooledDaysApartREV)-0.5) (max(pooledDaysApartFWD)-0.5)])
    xlabel('Days Apart')
    ylabel('% of cells in model day')
    
    yHeight = 0.8;
    for dpI = 1:length(ARMdayPairsSSS{pcI})
        if ARMwhichWonSplitterStillSplitter{pcI}(dpI) > 0
        if ARMhValSplitterStillSplitter{pcI}(dpI)==1
            plot(ARMdayPairsSSS{pcI}(dpI),yHeight,'*','Color',colorAssc{pcIndsHere(ARMwhichWonSplitterStillSplitter{pcI}(dpI))})
        end
        end
        %pValSplitterComesBack{pcI}
    end
       
    % legend([p1; p2],[pairsCompare{pcI,1}; pairsCompare{pcI,2}],'location','NW')  
    legend([p1; p2],'location','NW') 
end
suptitleSL('Percent ARM cells of model day apart still that trait')

%% Cells splitter type in STEM and ARM
nPts = size( pctTraitBothPooled{1},1);
dataHere = [pctTraitBothPooled{:}]; dataHere = dataHere(:);
grps = repmat(1:numTraitGroups,nPts,1); grps = grps(:); 

scatterBoxSL(dataHere,grps,'transparency',1,'xLabels',traitLabels)
title('% of cells that split the same way on stem and arm')

%% Comparison of each type of splitter in STEM and ARM
statBump = 0.025;
nPts = size( pctTraitBothPooled{1},1);
dataHere = []; 
grps = [];
labelsHere = cell(numTraitGroups*2,1);
for tgI = 1:numTraitGroups
    dataHere = [dataHere; pooledSplitProp{tgI}(:); ARMpooledSplitProp{tgI}(:)];
    grps = [grps; (tgI*2-1)*ones(nPts,1); (tgI*2)*ones(nPts,1)];
    labelsHere{tgI*2-1} = traitLabels{tgI};
    labelsHere{tgI*2} = ARMtraitLabels{tgI};
end
hh = figure;
scatterBoxSL(dataHere,grps,'transparency',1,'xLabels',labelsHere)
ylabel('Proportion of Cells')
title('Comparison of Number of Splitters in STEM and ARMS')

xMarks = hh.Children.XTick;
for tgI = 1:numTraitGroups
    sHeight = max([pooledSplitProp{tgI}(:); ARMpooledSplitProp{tgI}(:)]) + statBump;
    plot(xMarks((tgI*2-1):tgI*2),[sHeight sHeight],'k','LineWidth',1.5)
    switch hSvAsplitPropDiffs{tgI}
        case 0; txtPlot = 'n.s.';
        case 1
            switch pSvAsplitPropDiffs{tgI}<0.001
                case 1; txtPlot = '*p < 0.001';
                case 0; txtPlot = ['*p = ' num2str(round(pSvAsplitPropDiffs{tgI},2))];
            end
    end
    text(mean(xMarks((tgI*2-1):tgI*2)),sHeight+0.01,txtPlot,'Color','k','HorizontalAlignment','center')
end
    


%% Compare arm and stem splitters that come back, are still splitters
 
 
 
 
 
 