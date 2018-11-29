%% Model fig. of time vs. experience

%Need to add some fake data here to fill in background
figure;
%Just time
subplot(1,3,1)
xdatFWD = [1 10];
ydatFWD = [0.7 0.4];
xdatREV = [-1 -10];
ydatREV = [0.7 0.4];
plot(xdatFWD,ydatFWD,'k','LineWidth',2); hold on
plot(xdatREV,ydatREV,'k','LineWidth',2);
xlim([-10.5 10.5]); ylim([0 1])
title('Effect of Time Only'); xlabel('Time Between Comparisons')
%Just experience
subplot(1,3,2)
xdatFWD = [1 10];
ydatFWD = [0.55 0.3];
xdatREV = [-1 -10];
ydatREV = [0.55 0.8];
plot(xdatFWD,ydatFWD,'k','LineWidth',2); hold on
plot(xdatREV,ydatREV,'k','LineWidth',2);
xlim([-10.5 10.5]); ylim([0 1])
title('Effect of Experience Only'); xlabel('Time Between Comparisons')
%Both
subplot(1,3,3)
xdatFWD = [1 10];
ydatFWD = [0.7 0.4];
xdatREV = [-1 -10];
ydatREV = [0.7 0.6];
plot(xdatFWD,ydatFWD,'k','LineWidth',2); hold on
plot(xdatREV,ydatREV,'k','LineWidth',2);
xlim([-10.5 10.5]); ylim([0 1])
title('Effects of Time and Experience'); xlabel('Time Between Comparisons')

%%

cpsPlot = [1 2 3];
tgsPlot = pairsCompareInd(cpsPlot,:)'; tgsPlot = tgsPlot(:);

%% How many splitters pie chart

pieSplitLabels = {'splitBOTH','splitLRonly','dontSplit','splitSTonly'};
splitterTGinds = cell2mat(cellfun(@(x) find(strcmpi(traitLabels,x)),pieSplitLabels,'UniformOutput',false));
pieSplitColors = colorAssc(splitterTGinds);
pieSplitColors{3} = [1 1 1];
pieData = splitPropMeans(splitterTGinds);
pieSEMs = splitPropSEMs(splitterTGinds);

pieDataPct = round(pieData'*100,3); 
pieDataPct(rem(pieDataPct,0.01)==0) = pieDataPct(rem(pieDataPct,0.01)==0)+0.001;
pieDataPct = mat2cell(pieDataPct,ones(1,length(pieData)),1);
pieDataPct = cellfun(@num2str,pieDataPct,'UniformOutput',false);
pieDataPct = cellfun(@(x) x(1:end-1),pieDataPct,'UniformOutput',false);

pieDataSEMs = round(pieSEMs'*100,3); 
pieDataSEMs(rem(pieDataSEMs,0.01)==0) = pieDataSEMs(rem(pieDataSEMs,0.01)==0)+0.001;
pieDataSEMs = mat2cell(pieDataSEMs,ones(1,length(pieData)),1);
pieDataSEMs = cellfun(@num2str,pieDataSEMs,'UniformOutput',false);
pieDataSEMs = cellfun(@(x) x(1:end-1),pieDataSEMs,'UniformOutput',false);

pp=figure; axes(pp)
pie(pieData,pieSplitLabels);
colormap(reshape([pieSplitColors{:}],3,length(pieSplitColors))')
for ppI = 1:length(pp.Children.Children)
    if strcmpi(class(pp.Children.Children(ppI)),'matlab.graphics.primitive.Text')
        ppUse = find(cell2mat(cellfun(@(x) strcmpi(x,pp.Children.Children(ppI).String),pieSplitLabels,'UniformOutput',false)));
        pp.Children.Children(ppI).String = {pieSplitLabels{ppUse}; [pieDataPct{ppUse} ' ' char(177) ' ' pieDataSEMs{ppUse} '%']}; 
        pp.Children.Children(ppI).FontSize = 13;
    end
end

title('Mean number of each splitter, all days all mice')

%% How many ARM splitters pie chart

pieSplitLabels = {'splitBOTH','splitSTonly','dontSplit','splitLRonly'};
splitterTGinds = cell2mat(cellfun(@(x) find(strcmpi(traitLabels,x)),pieSplitLabels,'UniformOutput',false));
pieSplitColors = colorAssc(splitterTGinds);
pieSplitColors{3} = [1 1 1];
pieData = ARMsplitPropMeans(splitterTGinds);
pieSEMs = ARMsplitPropSEMs(splitterTGinds);

pieDataPct = round(pieData'*100,3); 
pieDataPct(rem(pieDataPct,0.01)==0) = pieDataPct(rem(pieDataPct,0.01)==0)+0.001;
pieDataPct = mat2cell(pieDataPct,ones(1,length(pieData)),1);
pieDataPct = cellfun(@num2str,pieDataPct,'UniformOutput',false);
pieDataPct = cellfun(@(x) x(1:end-1),pieDataPct,'UniformOutput',false);

pieDataSEMs = round(pieSEMs'*100,3); 
pieDataSEMs(rem(pieDataSEMs,0.01)==0) = pieDataSEMs(rem(pieDataSEMs,0.01)==0)+0.001;
pieDataSEMs = mat2cell(pieDataSEMs,ones(1,length(pieData)),1);
pieDataSEMs = cellfun(@num2str,pieDataSEMs,'UniformOutput',false);
pieDataSEMs = cellfun(@(x) x(1:end-1),pieDataSEMs,'UniformOutput',false);

pp=figure; axes(pp)
pie(pieData,pieSplitLabels);
colormap(reshape([pieSplitColors{:}],3,length(pieSplitColors))')
for ppI = 1:length(pp.Children.Children)
    if strcmpi(class(pp.Children.Children(ppI)),'matlab.graphics.primitive.Text')
        ppUse = find(cell2mat(cellfun(@(x) strcmpi(x,pp.Children.Children(ppI).String),pieSplitLabels,'UniformOutput',false)));
        pp.Children.Children(ppI).String = {pieSplitLabels{ppUse}; [pieDataPct{ppUse} ' ' char(177) ' ' pieDataSEMs{ppUse} '%']}; 
        pp.Children.Children(ppI).FontSize = 13;
    end
end

title('Mean number of each ARM splitter, all days all mice')
%% Proportion of each splitter type
hh = figure;
numDataPts = length(pooledSplitProp{tgI});
%grps = repmat(1:length(traitGroups{1}),numDataPts,1); grps = grps(:);
grps = repmat(1:length(tgsPlot),numDataPts,1); grps = grps(:);
%dataHere = [pooledSplitProp{:}]; 
dataHere = [pooledSplitProp{tgsPlot}]; 
dataHere = dataHere(:);
%colorsHere = repmat(colorsHere,8,1);        
colorsHere = colorAssc(tgsPlot);
allColors = cellfun(@(x) repmat(x,numDataPts,1),colorsHere,'UniformOutput',false)';
colorsUse = []; for aa = 1:length(allColors); colorsUse = [colorsUse; allColors{aa}]; end
%repmat for the color in colorAssc, put into circle colors
xLabels = traitLabels(tgsPlot);
scatterBoxSL(dataHere, grps, 'xLabel', xLabels, 'plotBox', true, 'circleColors', colorsUse, 'transparency', 0.8) % 'circleColors', colorsHere, 
ylabel('Proportion of Splitter Cells')
title('Proportion of Cells Each Splitter Type, all mice all days')
hold on
ylim([0 1.1])
heightBump = 0.03;
barXpos = hh.Children.XTick;
for pcI = 1:length(cpsPlot)
    %plot a bar across the pair of compare inds
    possibleHeight = max(round(cell2mat(cellfun(@max,pooledSplitProp(pairsCompareInd(cpsPlot(pcI),:)),'UniformOutput',false)),1));
    possibleHeight = possibleHeight + heightBump;
    plot(barXpos(pairsCompareInd(cpsPlot(pcI),:)),[possibleHeight possibleHeight],'k','LineWidth',2)
    
    %mark it significant or not with hSplitterPropDiffs, pVal in pSplitterPropDiffs
    switch hSplitterPropDiffs(cpsPlot(pcI))
        case 1
            if pSplitterPropDiffs(cpsPlot(pcI)) < 0.001
                textPlot = 'p < 0.001';
            else
                textPlot = ['p = ' num2str(pSplitterPropDiffs(cpsPlot(pcI)))];
            end
        case 0
            textPlot = 'n.s.';
    end
    text(mean(barXpos(pairsCompareInd(cpsPlot(pcI),:))),possibleHeight+0.025,textPlot,'Color','k','HorizontalAlignment','center')
end

%% Proportion of each splitter type ARMs
hh = figure;
numDataPts = length(ARMpooledSplitProp{tgI});
%grps = repmat(1:length(traitGroups{1}),numDataPts,1); grps = grps(:);
grps = repmat(1:length(tgsPlot),numDataPts,1); grps = grps(:);
%dataHere = [pooledSplitProp{:}]; 
dataHere = [ARMpooledSplitProp{tgsPlot}]; 
dataHere = dataHere(:);
%colorsHere = repmat(colorsHere,8,1);        
colorsHere = ARMcolorAssc(tgsPlot);
allColors = cellfun(@(x) repmat(x,numDataPts,1),colorsHere,'UniformOutput',false)';
colorsUse = []; for aa = 1:length(allColors); colorsUse = [colorsUse; allColors{aa}]; end
%repmat for the color in colorAssc, put into circle colors
xLabels = ARMtraitLabels(tgsPlot);
scatterBoxSL(dataHere, grps, 'xLabel', xLabels, 'plotBox', true, 'circleColors', colorsUse, 'transparency', 0.8) % 'circleColors', colorsHere, 
ylabel('Proportion of Splitter Cells')
title('Proportion of Cells Each ARM Splitter Type, all mice all days')
hold on
ylim([0 1.1])
heightBump = 0.03;
barXpos = hh.Children.XTick;
for pcI = 1:length(cpsPlot)
    %plot a bar across the pair of compare inds
    possibleHeight = max(round(cell2mat(cellfun(@max,ARMpooledSplitProp(pairsCompareInd(cpsPlot(pcI),:)),'UniformOutput',false)),1));
    possibleHeight = possibleHeight + heightBump;
    plot(barXpos(pairsCompareInd(cpsPlot(pcI),:)),[possibleHeight possibleHeight],'k','LineWidth',2)
    
    %mark it significant or not with hSplitterPropDiffs, pVal in pSplitterPropDiffs
    switch hArmSplitterPropDiffs(cpsPlot(pcI))
        case 1
            if pArmSplitterPropDiffs(cpsPlot(pcI)) < 0.001
                textPlot = 'p < 0.001';
            else
                textPlot = ['p = ' num2str(pArmSplitterPropDiffs(cpsPlot(pcI)))];
            end
        case 0
            textPlot = 'n.s.';
    end
    text(mean(barXpos(pairsCompareInd(cpsPlot(pcI),:))),possibleHeight+0.025,textPlot,'Color','k','HorizontalAlignment','center')
end

%% Change in Proportion of Each splitter type by days apart
%Comparison
plotREV=1;

gg=figure('Position',[65 410 1813 510]);
sRows = 1;
sCols = 3;
for pcI = 1:length(cpsPlot)
    subplot(sRows,sCols,pcI)
    pcIndsHere = pairsCompareInd(cpsPlot(pcI),:);
    %plot data
    plot(pooledDaysApartFWD-0.1,pooledSplitPctChangeFWD{pcIndsHere(1)},'.','Color',colorAssc{pcIndsHere(1)},'MarkerSize',12)
    hold on
    plot(pooledDaysApartFWD+0.1,pooledSplitPctChangeFWD{pcIndsHere(2)},'.','Color',colorAssc{pcIndsHere(2)},'MarkerSize',12)
    %plot reg fit line    
    plot(splitterFitPlotDays,splitterFitPlotPct{pcIndsHere(1)},'Color',colorAssc{pcIndsHere(1)},'LineWidth',2)
    plot(splitterFitPlotDays,splitterFitPlotPct{pcIndsHere(2)},'Color',colorAssc{pcIndsHere(2)},'LineWidth',2)
    
    if plotREV==1
        plot(pooledDaysApartREV-0.1,pooledSplitPctChangeREV{pcIndsHere(1)},'.','Color',colorAssc{pcIndsHere(1)},'MarkerSize',12)
        plot(pooledDaysApartREV+0.1,pooledSplitPctChangeREV{pcIndsHere(2)},'.','Color',colorAssc{pcIndsHere(2)},'MarkerSize',12)   
        plot(splitterFitPlotDaysREV,splitterFitPlotPctREV{pcIndsHere(1)},'Color',colorAssc{pcIndsHere(1)},'LineWidth',2)
        plot(splitterFitPlotDaysREV,splitterFitPlotPctREV{pcIndsHere(2)},'Color',colorAssc{pcIndsHere(2)},'LineWidth',2)
    end
    
    ylim([-0.5 0.5])
    xlim([0.5 max(pooledDaysApartFWD)-0.5]) %cell2mat(cellfun(@max,cellRealDays,'UniformOutput',false))
    if plotREV==1; xlim([min(pooledDaysApartREV)-0.5 max(pooledDaysApartFWD)-0.5]); end
    xlabel('Days Apart')
    ylabel('Proportion Change')
    %indicate the r2 of each line
    %switch slopeDiffRank(pcI)>=(1*numPerms-numPerms*pThresh); case 1; diffTxt='ARE'; case 0; diffTxt ='ARE NOT'; end
    %title([pairsCompare{pcI,1} ' vs ' pairsCompare{pcI,2} ', slopes ' diffTxt ' diff at p = ' num2str(1-slopeDiffRank(pcI)/1000)])
    switch pVal(cpsPlot(pcI))<pThresh; case 1; diffTxt='ARE'; case 0; diffTxt ='are NOT'; end
    title([traitLabels{pcIndsHere(1)} ' vs ' traitLabels{pcIndsHere(2)} ', slopes ' diffTxt ' diff at p = ' num2str(pVal(cpsPlot(pcI)))])
    legend(traitLabels{pcIndsHere(1)},traitLabels{pcIndsHere(2)})
end
suptitleSL('Changes by days apart in proportion of splitting type')

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

%% Prop of splitters that come back
%Comparison
figure;
sRows = 1;
sCols = 3;
for pcI = 1:length(cpsPlot)
    subplot(sRows,sCols,pcI)
    pcIndsHere = pairsCompareInd(cpsPlot(pcI),:);
    p1 = plot(pooledDaysApartFWD-0.1,pooledSplitterComesBackFWD{pcIndsHere(1)},'.','Color',colorAssc{pcIndsHere(1)},'MarkerSize',8,'DisplayName',pairsCompare{pcI,1});
    hold on
    p2 = plot(pooledDaysApartFWD+0.1,pooledSplitterComesBackFWD{pcIndsHere(2)},'.','Color',colorAssc{pcIndsHere(2)},'MarkerSize',8,'DisplayName',pairsCompare{pcI,2});
    
    plot(pooledDaysApartREV-0.1,pooledSplitterComesBackREV{pcIndsHere(1)},'.','Color',colorAssc{pcIndsHere(1)},'MarkerSize',8)
    plot(pooledDaysApartREV+0.1,pooledSplitterComesBackREV{pcIndsHere(2)},'.','Color',colorAssc{pcIndsHere(2)},'MarkerSize',8)
    
    ylim([-0.01 1.01])
    xlim([(min(pooledDaysApartREV)-0.5) (max(pooledDaysApartFWD)-0.5)])
    xlabel('Days Apart')
    ylabel('% of cells in model')
    
    if hValSplitterComesBackAll{pcI} == 1
        titleText = [pairsCompare{pcI,whichWonSplitterComesBackAll{pcI}} ' more stable, p = ' num2str(pValSplitterComesBackAll{pcI}) ];
    else 
        titleText = ['NOT diff at p = ' num2str(pValSplitterComesBackAll{pcI}) ];
    end
    title(titleText)
    
    %{
    yHeight = 0.8;
    for dpI = 1:length(dayPairsSCB{pcI})
        if hValSplitterComesBack{pcI}(dpI)==1
            plot(dayPairsSCB{pcI}(dpI),yHeight,'*','Color',colorAssc{pcIndsHere(whichWonSplitterComesBack{pcI}(dpI))})
        end
        %pValSplitterComesBack{pcI}
    end
    %}
    
    legend([p1; p2],'location','NW') 
end
suptitleSL('Percent cells of model day come back')

%% Prop of ARM splitters that come back
%Comparison
figure;
sRows = 1;
sCols = 3;
for pcI = 1:length(cpsPlot)
    subplot(sRows,sCols,pcI)
    pcIndsHere = pairsCompareInd(cpsPlot(pcI),:);
    p1 = plot(pooledDaysApartFWD-0.1,ARMpooledSplitterComesBackFWD{pcIndsHere(1)},'.','Color',ARMcolorAssc{pcIndsHere(1)},'MarkerSize',8,'DisplayName',pairsCompare{pcI,1});
    hold on
    p2 = plot(pooledDaysApartFWD+0.1,ARMpooledSplitterComesBackFWD{pcIndsHere(2)},'.','Color',ARMcolorAssc{pcIndsHere(2)},'MarkerSize',8,'DisplayName',pairsCompare{pcI,2});
    
    plot(pooledDaysApartREV-0.1,ARMpooledSplitterComesBackREV{pcIndsHere(1)},'.','Color',ARMcolorAssc{pcIndsHere(1)},'MarkerSize',8)
    plot(pooledDaysApartREV+0.1,ARMpooledSplitterComesBackREV{pcIndsHere(2)},'.','Color',ARMcolorAssc{pcIndsHere(2)},'MarkerSize',8)
    
    ylim([-0.01 1.01])
    xlim([(min(pooledDaysApartREV)-0.5) (max(pooledDaysApartFWD)-0.5)])
    xlabel('Days Apart')
    ylabel('% of cells in model')
    
    if hValSplitterComesBackAllARM{pcI} == 1 && whichWonSplitterComesBackAllARM{pcI}~=0
        titleText = [pairsCompare{pcI,whichWonSplitterComesBackAllARM{pcI}} ' more stable, p = ' num2str(pValSplitterComesBackAllARM{pcI}) ];
    else 
        titleText = ['NOT diff at p = ' num2str(pValSplitterComesBackAllARM{pcI}) ];
    end
    title(titleText)
       
    % legend([p1; p2],[pairsCompare{pcI,1}; pairsCompare{pcI,2}],'location','NW')  
    legend([p1; p2],'location','NW') 
end
suptitleSL('Percent ARM cells of model day come back on ARMs')

%% Prop of splitters that are still a splitter
figure;
sRows = 1;
sCols = 3;
for pcI = 1:length(cpsPlot)
    subplot(sRows,sCols,pcI)
    pcIndsHere = pairsCompareInd(cpsPlot(pcI),:);
    p1 = plot(pooledDaysApartFWD-0.1,pooledSplitterStillSplitterFWD{pcIndsHere(1)},'.','Color',colorAssc{pcIndsHere(1)},'MarkerSize',8,'DisplayName',pairsCompare{pcI,1});
    hold on
    p2 = plot(pooledDaysApartFWD+0.1,pooledSplitterStillSplitterFWD{pcIndsHere(2)},'.','Color',colorAssc{pcIndsHere(2)},'MarkerSize',8,'DisplayName',pairsCompare{pcI,2});
    
    plot(pooledDaysApartREV-0.1,pooledSplitterStillSplitterREV{pcIndsHere(1)},'.','Color',colorAssc{pcIndsHere(1)},'MarkerSize',8)
    plot(pooledDaysApartREV+0.1,pooledSplitterStillSplitterREV{pcIndsHere(2)},'.','Color',colorAssc{pcIndsHere(2)},'MarkerSize',8)
    
    ylim([-0.01 1.01])
    xlim([(min(pooledDaysApartREV)-0.5) (max(pooledDaysApartFWD)-0.5)])
    xlabel('Days Apart')
    ylabel('% of cells in model day')
    
    if hValSplitterStillSplitterAll{pcI} == 1
        titleText = [pairsCompare{pcI,whichWonSplitterStillSplitterAll{pcI}} ' more stable, p = ' num2str(pValSplitterStillSplitterAll{pcI}) ];
    else 
        titleText = ['NOT diff at p = ' num2str(pValSplitterStillSplitterAll{pcI}) ];
    end
    title(titleText)
    
    %{
    yHeight = 0.8;
    for dpI = 1:length(dayPairsSSS{pcI})
        if hValSplitterStillSplitter{pcI}(dpI)==1
            plot(dayPairsSSS{pcI}(dpI),yHeight,'*','Color',colorAssc{pcIndsHere(whichWonSplitterStillSplitter{pcI}(dpI))})
        end
        %pValSplitterComesBack{pcI}
    end
     %}
    
    % legend([p1; p2],[pairsCompare{pcI,1}; pairsCompare{pcI,2}],'location','NW')  
    legend([p1; p2],'location','NW') 
end
suptitleSL('Percent cells of model day apart still that trait')

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
    
    if hValSplitterStillSplitterAllARM{pcI} == 1 && whichWonSplitterStillSplitterAllARM{pcI}~=0
        titleText = [pairsCompare{pcI,whichWonSplitterStillSplitterAllARM{pcI}} ' more stable, p = ' num2str(pValSplitterStillSplitterAllARM{pcI}) ];
    else 
        titleText = ['NOT diff at p = ' num2str(pValSplitterStillSplitterAllARM{pcI}) ];
    end
    title(titleText)
    
    ylim([-0.01 1.01])
    xlim([(min(pooledDaysApartREV)-0.5) (max(pooledDaysApartFWD)-0.5)])
    xlabel('Days Apart')
    ylabel('% of cells in model day')
       
    % legend([p1; p2],[pairsCompare{pcI,1}; pairsCompare{pcI,2}],'location','NW')  
    legend([p1; p2],'location','NW') 
end
suptitleSL('Percent ARM cells of model day apart still that trait')

%% FWD vs. REV time within splitter type coming back
%Now plot within trait pos vs. negative day change
figure; 
sCols = 3;
sRows = ceil(length(tgsPlot)/sCols);
markerss = {'.' 'o'};
%for tgI = 1:length(traitGroups{1})
FWDREVtxt = {'FWD' 'REV'};
for tgI = 1:length(tgsPlot)
    subplot(sRows,sCols,tgI)
    color1 = colorAssc{tgsPlot(tgI)}+0.2; color1(color1>1) = 1; color1(color1<0) = 0;
    color2 = colorAssc{tgsPlot(tgI)}-0.2; color2(color2>1) = 1; color2(color2<0) = 0;
    p1 = plot(pooledDaysApartFWD+0.15,pooledSplitterComesBackFWD{tgsPlot(tgI)},markerss{1},'Color',color1,'MarkerSize',8,'DisplayName','Days Forward');
    hold on
    p2 = plot(-1*pooledDaysApartREV-0.15,pooledSplitterComesBackREV{tgsPlot(tgI)},markerss{2},'Color',color2,'MarkerSize',3,'DisplayName','Days Backwards');
    
    %{
    yHeight = 0.75;
    for dpI = 1:length(dayPairsCBpvn{tgsPlot(tgI)})
        if hValCBpvn{tgsPlot(tgI)}(dpI)
             markersz = [14 8]; colorss = [color1; color2];
            plot(dayPairsCBpvn{tgsPlot(tgI)}(dpI),yHeight,markerss{whichWonCBpvn{tgsPlot(tgI)}(dpI)},'Color',colorss(whichWonCBpvn{tgsPlot(tgI)}(dpI),:),'MarkerSize',markersz(whichWonCBpvn{tgI}(dpI)))    
        end
        %pValSplitCBpvn{tgI}
    end
    %}
    
    if hValSCBall{tgI} == 1
        titleText = [traitLabels{tgsPlot(tgI)} ': ' FWDREVtxt{whichWonSCBall{tgI}} ' more stable, p = ' num2str(pValSCBall{tgI}) ];
    else 
        titleText = [traitLabels{tgsPlot(tgI)} ': NOT diff at p = ' num2str(pValSCBall{tgI}) ];
    end
    title(titleText)
    
    xlabel('Days Apart')
    ylabel('Proportion of Model')
    ylim([-0.01 1.01])
    xlim([min(pooledDaysApartFWD)-0.5 max(pooledDaysApartFWD)+0.5])
    legend([p1; p2],'location','NE')
end
suptitleSL('Percent cells of model day come back, Positive vs. negative time')

%% FWD vs. REV time within splitter still splitter
figure; 
sCols = 3;
sRows = ceil(length(tgsPlot)/sCols);
markerss = {'.' 'o'}; 
%for tgI = 1:length(traitGroups{1})
for tgI = 1:length(tgsPlot)
    subplot(sRows,sCols,tgI)
    color1 = colorAssc{tgsPlot(tgI)}+0.2; color1(color1>1) = 1; color1(color1<0) = 0;
    color2 = colorAssc{tgsPlot(tgI)}-0.2; color2(color2>1) = 1; color2(color2<0) = 0;
    p1 = plot(pooledDaysApartFWD+0.15,pooledSplitterStillSplitterFWD{tgsPlot(tgI)},markerss{1},'Color',color1,'MarkerSize',8,'DisplayName','Days Forward');
    hold on
    p2 = plot(-1*pooledDaysApartREV-0.15,pooledSplitterStillSplitterREV{tgsPlot(tgI)},markerss{2},'Color',color2,'MarkerSize',3,'DisplayName','Days Backwards');
    
    %{
    yHeight = 0.8;
    for dpI = 1:length(dayPairsSSpvn{tgsPlot(tgI)})
        if hValSSpvn{tgsPlot(tgI)}(dpI)
            markersz = [14 8]; colorss = [color1; color2];
            plot(dayPairsSSpvn{tgsPlot(tgI)}(dpI),yHeight,markerss{whichWonSSpvn{tgsPlot(tgI)}(dpI)},'Color',colorss(whichWonSSpvn{tgsPlot(tgI)}(dpI),:),'MarkerSize',markersz(whichWonCBpvn{tgI}(dpI)))    
        end
        %pValSplitSSpvn{tgI}
    end
    %}
    
    if hValSSSall{tgI} == 1
        titleText = [traitLabels{tgsPlot(tgI)} ': ' FWDREVtxt{whichWonSSSall{tgI}} ' more stable, p = ' num2str(pValSSSall{tgI}) ];
    else 
        titleText = [traitLabels{tgsPlot(tgI)} ': NOT diff at p = ' num2str(pValSSSall{tgI}) ];
    end
    title(titleText)
    
    xlabel('Days Apart')
    ylabel('Proportion of Model')
    ylim([-0.01 1.01])
    xlim([min(pooledDaysApartFWD)-0.5 max(pooledDaysApartFWD)+0.5])
    legend([p1; p2],'location','NE')
end
suptitleSL('Percent cells of model day still that trait v self, Positive vs. negative time')











%% FWD v REV time ARM splitter persistence










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
    
