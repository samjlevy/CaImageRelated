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

%% How many cells active?
figure;
plot(pooledRealDayDiffs,pooledActiveCellsChange,'.k','MarkerSize',8)
hold on
plot(-1*pooledRealDayDiffs,-1*pooledActiveCellsChange,'.k','MarkerSize',8)
plot([-20 20],[0 0],'k')
plot(cellsActiveFitLine(:,1),cellsActiveFitLine(:,2),'k','LineWidth',2)
plot(-1*cellsActiveFitLine(:,1),-1*cellsActiveFitLine(:,2),'k','LineWidth',2)
title(['Change in cells above activity threshold, slope diff from 0 at p=' num2str(cellsActivepVal)])
xlabel('Days Apart')
ylabel('STEM Change in Proportion of Cells Active on Stem')

figure;
plot(pooledRealDayDiffs,pooledActiveCellsChangeARM,'.k','MarkerSize',8)
hold on
plot(-1*pooledRealDayDiffs,-1*pooledActiveCellsChangeARM,'.k','MarkerSize',8)
plot([-20 20],[0 0],'k')
plot(cellsActiveFitLineARM(:,1),cellsActiveFitLineARM(:,2),'k','LineWidth',2)
plot(-1*cellsActiveFitLineARM(:,1),-1*cellsActiveFitLineARM(:,2),'k','LineWidth',2)
title(['ARM Change in cells above activity threshold, slope diff from 0 at p=' num2str(cellsActivepValARM)])
xlabel('Days Apart')
ylabel('Change in Proportion of Cells Active')
ylim([-0.15 0.15])

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
sCols = 4;
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
hh = figure('Position',[680 459 1049 519]);
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
    
    plot(splitterCBFitPlotDaysFWD{pcIndsHere(1)},splitterCBFitPlotPctFWD{pcIndsHere(1)},'Color',colorAssc{pcIndsHere(1)},'LineWidth',2)
    plot(splitterCBFitPlotDaysFWD{pcIndsHere(2)},splitterCBFitPlotPctFWD{pcIndsHere(2)},'Color',colorAssc{pcIndsHere(2)},'LineWidth',2)
    plot(splitterCBFitPlotDaysREV{pcIndsHere(1)},splitterCBFitPlotPctREV{pcIndsHere(1)},'Color',colorAssc{pcIndsHere(1)},'LineWidth',2)
    plot(splitterCBFitPlotDaysREV{pcIndsHere(2)},splitterCBFitPlotPctREV{pcIndsHere(2)},'Color',colorAssc{pcIndsHere(2)},'LineWidth',2)
    
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
hh = figure('Position',[680 459 1049 519]);
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
    
    plot(ARMsplitterCBFitPlotDaysFWD{pcIndsHere(1)},ARMsplitterCBFitPlotPctFWD{pcIndsHere(1)},'Color',ARMcolorAssc{pcIndsHere(1)},'LineWidth',2)
    plot(ARMsplitterCBFitPlotDaysFWD{pcIndsHere(2)},ARMsplitterCBFitPlotPctFWD{pcIndsHere(2)},'Color',ARMcolorAssc{pcIndsHere(2)},'LineWidth',2)
    plot(ARMsplitterCBFitPlotDaysREV{pcIndsHere(1)},ARMsplitterCBFitPlotPctREV{pcIndsHere(1)},'Color',ARMcolorAssc{pcIndsHere(1)},'LineWidth',2)
    plot(ARMsplitterCBFitPlotDaysREV{pcIndsHere(2)},ARMsplitterCBFitPlotPctREV{pcIndsHere(2)},'Color',ARMcolorAssc{pcIndsHere(2)},'LineWidth',2)
    
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
hh = figure('Position',[680 459 1049 519]);
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
    
    plot(splitterSSFitPlotDaysFWD{pcIndsHere(1)},splitterSSFitPlotPctFWD{pcIndsHere(1)},'Color',colorAssc{pcIndsHere(1)},'LineWidth',2)
    plot(splitterSSFitPlotDaysFWD{pcIndsHere(2)},splitterSSFitPlotPctFWD{pcIndsHere(2)},'Color',colorAssc{pcIndsHere(2)},'LineWidth',2)
    plot(splitterSSFitPlotDaysREV{pcIndsHere(1)},splitterSSFitPlotPctREV{pcIndsHere(1)},'Color',colorAssc{pcIndsHere(1)},'LineWidth',2)
    plot(splitterSSFitPlotDaysREV{pcIndsHere(2)},splitterSSFitPlotPctREV{pcIndsHere(2)},'Color',colorAssc{pcIndsHere(2)},'LineWidth',2)
    
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
hh = figure('Position',[680 459 1049 519]);
sRows = 1;
sCols = 3;
for pcI = 1:length(cpsPlot)
    gg(pcI) = subplot(sRows,sCols,pcI);
    pcIndsHere = pairsCompareInd(cpsPlot(pcI),:);
    p1 = plot(pooledDaysApartFWD-0.1,ARMpooledSplitterStillSplitterFWD{pcIndsHere(1)},'.','Color',ARMcolorAssc{pcIndsHere(1)},'MarkerSize',8,'DisplayName',pairsCompare{pcI,1});
    hold on
    p2 = plot(pooledDaysApartFWD+0.1,ARMpooledSplitterStillSplitterFWD{pcIndsHere(2)},'.','Color',ARMcolorAssc{pcIndsHere(2)},'MarkerSize',8,'DisplayName',pairsCompare{pcI,2});
    
    plot(pooledDaysApartREV-0.1,ARMpooledSplitterStillSplitterREV{pcIndsHere(1)},'.','Color',ARMcolorAssc{pcIndsHere(1)},'MarkerSize',8)
    plot(pooledDaysApartREV+0.1,ARMpooledSplitterStillSplitterREV{pcIndsHere(2)},'.','Color',ARMcolorAssc{pcIndsHere(2)},'MarkerSize',8)
    
    plot(ARMsplitterSSFitPlotDaysFWD{pcIndsHere(1)},ARMsplitterSSFitPlotPctFWD{pcIndsHere(1)},'Color',ARMcolorAssc{pcIndsHere(1)},'LineWidth',2)
    plot(ARMsplitterSSFitPlotDaysFWD{pcIndsHere(2)},ARMsplitterSSFitPlotPctFWD{pcIndsHere(2)},'Color',ARMcolorAssc{pcIndsHere(2)},'LineWidth',2)
    plot(ARMsplitterSSFitPlotDaysREV{pcIndsHere(1)},ARMsplitterSSFitPlotPctREV{pcIndsHere(1)},'Color',ARMcolorAssc{pcIndsHere(1)},'LineWidth',2)
    plot(ARMsplitterSSFitPlotDaysREV{pcIndsHere(2)},ARMsplitterSSFitPlotPctREV{pcIndsHere(2)},'Color',ARMcolorAssc{pcIndsHere(2)},'LineWidth',2)
    
    
    if hValSplitterStillSplitterAllARM{pcI} == 1 && whichWonSplitterStillSplitterAllARM{pcI}~=0
        titleText = [pairsCompare{pcI,whichWonSplitterStillSplitterAllARM{pcI}} ' more stable, p = ' num2str(pValSplitterStillSplitterAllARM{pcI}) ];
    else 
        titleText = ['NOT diff at p = ' num2str(pValSplitterStillSplitterAllARM{pcI}) ];
    end
    title(titleText)
    
    dim = [0.15 0.6 0.4 0.2];
    textPlot{1,1} = ['FWD slopes p= ' num2str(ARMpValSSSslopeFWD{pcI})];
    textPlot{2,1} = ['FWD slopes p= ' num2str(ARMpValSSSslopeREV{pcI})];
    %qq = annotation(gg(pcI),'textbox',dim,'String',textPlot,'FitBoxToText','on');

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
    
    plot(splitterCBFitLineFWD{tgI}(:,1),splitterCBFitLineFWD{tgI}(:,2),'LineWidth',2)
    plot(-1*splitterCBFitLineREV{tgI}(:,1),splitterCBFitLineREV{tgI}(:,2),'LineWidth',2)
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
    plot(splitterSSFitLineFWD{tgI}(:,1),splitterSSFitLineFWD{tgI}(:,2),'LineWidth',2)
    plot(-1*splitterSSFitLineREV{tgI}(:,1),splitterSSFitLineREV{tgI}(:,2),'LineWidth',2)
    
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

%% FWD vs. REV time within splitter type coming back ARM
%Now plot within trait pos vs. negative day change
figure; 
sCols = 3;
sRows = ceil(length(tgsPlot)/sCols);
markerss = {'.' 'o'};
%for tgI = 1:length(traitGroups{1})
FWDREVtxt = {'FWD' 'REV'};
for tgI = 1:length(tgsPlot)
    subplot(sRows,sCols,tgI)
    color1 = ARMcolorAssc{tgsPlot(tgI)}+0.2; color1(color1>1) = 1; color1(color1<0) = 0;
    color2 = ARMcolorAssc{tgsPlot(tgI)}-0.2; color2(color2>1) = 1; color2(color2<0) = 0;
    p1 = plot(pooledDaysApartFWD+0.15,ARMpooledSplitterComesBackFWD{tgsPlot(tgI)},markerss{1},'Color',color1,'MarkerSize',8,'DisplayName','Days Forward');
    hold on
    p2 = plot(-1*pooledDaysApartREV-0.15,ARMpooledSplitterComesBackREV{tgsPlot(tgI)},markerss{2},'Color',color2,'MarkerSize',3,'DisplayName','Days Backwards');
     
    if ARMhValSCBall{tgI} == 1
        titleText = [ARMtraitLabels{tgsPlot(tgI)} ': ' FWDREVtxt{ARMwhichWonSCBall{tgI}} ' more stable, p = ' num2str(ARMpValSCBall{tgI}) ];
    else 
        titleText = [ARMtraitLabels{tgsPlot(tgI)} ': NOT diff at p = ' num2str(ARMpValSCBall{tgI}) ];
    end
    title(titleText)
    
    xlabel('Days Apart')
    ylabel('Proportion of Model')
    ylim([-0.01 1.01])
    xlim([min(pooledDaysApartFWD)-0.5 max(pooledDaysApartFWD)+0.5])
    legend([p1; p2],'location','NE')
end
suptitleSL('ARM Percent cells of model day come back, Positive vs. negative time')

%% FWD vs. REV time within splitter still splitter ARM
figure; 
sCols = 3;
sRows = ceil(length(tgsPlot)/sCols);
markerss = {'.' 'o'}; 
%for tgI = 1:length(traitGroups{1})
for tgI = 1:length(tgsPlot)
    subplot(sRows,sCols,tgI)
    color1 = ARMcolorAssc{tgsPlot(tgI)}+0.2; color1(color1>1) = 1; color1(color1<0) = 0;
    color2 = ARMcolorAssc{tgsPlot(tgI)}-0.2; color2(color2>1) = 1; color2(color2<0) = 0;
    p1 = plot(pooledDaysApartFWD+0.15,ARMpooledSplitterStillSplitterFWD{tgsPlot(tgI)},markerss{1},'Color',color1,'MarkerSize',8,'DisplayName','Days Forward');
    hold on
    p2 = plot(-1*pooledDaysApartREV-0.15,ARMpooledSplitterStillSplitterREV{tgsPlot(tgI)},markerss{2},'Color',color2,'MarkerSize',3,'DisplayName','Days Backwards');
    
    if ARMhValSSSall{tgI} == 1
        titleText = [ARMtraitLabels{tgsPlot(tgI)} ': ' FWDREVtxt{ARMwhichWonSSSall{tgI}} ' more stable, p = ' num2str(ARMpValSSSall{tgI}) ];
    else 
        titleText = [ARMtraitLabels{tgsPlot(tgI)} ': NOT diff at p = ' num2str(ARMpValSSSall{tgI}) ];
    end
    title(titleText)
    
    xlabel('Days Apart')
    ylabel('Proportion of Model')
    ylim([-0.01 1.01])
    xlim([min(pooledDaysApartFWD)-0.5 max(pooledDaysApartFWD)+0.5])
    legend([p1; p2],'location','NE')
end
suptitleSL('ARM Percent cells of model day still that trait v self, Positive vs. negative time')

%% Splitters becoming another type of splitter STEM

%Don't yet have reverse day order

figure;
for scI = 1:length(pooledSplitterChanges)/2
    subplot(2,3,scI)
    plot(pooledDaysApartFWD-0.15,pooledSplitterChanges{scI*2-1},'.','MarkerSize',10)
    hold on
    plot(pooledDaysApartFWD+0.15,pooledSplitterChanges{scI*2},'.','MarkerSize',10)
    [p,h] = ranksum(pooledSplitterChanges{scI*2-1},pooledSplitterChanges{scI*2});
    ww = WhichWonRanks(pooledSplitterChanges{scI*2-1},pooledSplitterChanges{scI*2});
    title(['h = ' num2str(h) ', ww= ' num2str(ww) ', p = ' num2str(p)])
    xlabel([transLabels{scI*2-1,1} '>>' transLabels{scI*2-1,2} '  vs ' transLabels{scI*2,1} '>>' transLabels{scI*2,2}])
end
    



%% Cells splitter type in STEM and ARM
nPts = size( pctTraitBothPooled{1},1);
dataHere = [pctTraitBothPooled{:}]; dataHere = dataHere(:);
grps = repmat(1:numTraitGroups,nPts,1); grps = grps(:); 

scatterBoxSL(dataHere,grps,'transparency',1,'xLabels',traitLabels)
title('% of cells that split the same way on stem and arm')

%%  STEM vs ARM proportion splitting
statBump = 0.025;
nPts = size( pctTraitBothPooled{1},1);
dataHere = []; 
grps = [];
labelsHere = cell(numTraitGroups*2,1);
colorsPlot = [];
for tgI = 1:numTraitGroups
    dataHere = [dataHere; pooledSplitProp{tgI}(:); ARMpooledSplitProp{tgI}(:)];
    grps = [grps; (tgI*2-1)*ones(nPts,1); (tgI*2)*ones(nPts,1)];
    labelsHere{tgI*2-1} = traitLabels{tgI};
    labelsHere{tgI*2} = ARMtraitLabels{tgI};
    colorsPlot = [colorsPlot; repmat(colorAssc{tgI},nPts,1); repmat(ARMcolorAssc{tgI},nPts,1)];
end
hh = figure;
scatterBoxSL(dataHere,grps,'transparency',1,'xLabels',labelsHere,'circleColors',colorsPlot)
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
    
%% ARM vs STEM prop splitting

nPts = length(pooledSplitProp{1});
dataHere = [];
grps= [];
labelsHere = cell(numTraitGroups*2,1)



pSvAsplitPropDiffs{tgI}, hSvAsplitPropDiffs{tgI}

%% What are new cells?
figure;
for pcI = 1:length(cpsPlot)
    subplot(1,length(cpsPlot),pcI)
    plot(pooledDaysApartFWD,pooledNewCellPropChanges{pairsCompareInd(pcI,1)},'.','MarkerSize',6,'Color',colorAssc{pairsCompareInd(pcI,1)})
    hold on
    plot(pooledDaysApartFWD,pooledNewCellPropChanges{pairsCompareInd(pcI,2)},'.','MarkerSize',6,'Color',colorAssc{pairsCompareInd(pcI,2)})
    
    plot([0 20],[0 0],'k')
    
    plot(newCellFit{pairsCompareInd(pcI,1)}(:,1),newCellFit{pairsCompareInd(pcI,1)}(:,2),'Color',colorAssc{pairsCompareInd(pcI,1)},'LineWidth',2)
    plot(newCellFit{pairsCompareInd(pcI,2)}(:,1),newCellFit{pairsCompareInd(pcI,2)}(:,2),'Color',colorAssc{pairsCompareInd(pcI,2)},'LineWidth',2)
    
    title(['p = ' num2str(newCellsSlopeDiffpVal{pcI})]) 
    ylim([-0.8 0.8])
    xlabel('Days apart') 
end
suptitleSL('Comparisons of change in proportion of new cells')


%% Mean pop vector corr all animals all days, each condSet

%mean =/- sem corr each bin, corr to decorr, decorr to corr, flat

hh = PlotAllPVcorrsCurves(CSpooledPVcorrs,CSpooledPVdaysApart,pvNames,condSetColors);
suptitleSL({'Mean PV curves, all mice All Days'; 'B - VS Self,   G - Study vs. Test,   R - Left vs. Right'})

ii = PlotAllPVcorrsCurves(CSpooledPVcorrsARM,CSpooledPVdaysApart,pvNames,condSetColors);
suptitleSL({'ARM Mean PV curves, all mice All Days'; 'B - VS Self,   G - Study vs. Test,   R - Left vs. Right'})
%

%% First two bins vs. last two bins
csColorNums = {[0 0 1]; [0 1 0]; [1 0 0]};
[figHand,statsOut] = FirstHalfVsSecondHaldf(CSpooledPVcorrs,CSpooledPVdaysApart,pvNames,csColorNums,4);
suptitleSL('1st Half vs 2nd half Stem Correlations')
    
csColorNums = {[0 0 1]; [0 1 0]; [1 0 0]};
[figHand,statsOut] = FirstHalfVsSecondHaldf(CSpooledPVcorrs,CSpooledPVdaysApart,pvNames,csColorNums,2);
suptitleSL('1st 2 bins vs Last 2 bins Stem Correlations')
    
csColorNums = {[0 0 1]; [0 1 0]; [1 0 0]};
[figHand,statsOut] = FirstHalfVsSecondHaldf(CSpooledPVcorrsARM,CSpooledPVdaysApart,pvNames,csColorNums,4);
suptitleSL('1st Half vs 2nd half ARM Correlations')
    
csColorNums = {[0 0 1]; [0 1 0]; [1 0 0]};
[figHand,statsOut] = FirstHalfVsSecondHaldf(CSpooledPVcorrsARM,CSpooledPVdaysApart,pvNames,csColorNums,2);
suptitleSL('1st 2 bins vs Last 2 bins ARM Correlations')

%% Pop Vector corrs by days apart
gg = figure('Position',[288 37 1521 849]); 
hht = [];
for pvtI = 1:length(pvNames)
    hht{pvtI} = subplot(2,3,pvtI);
[hht{pvtI}, statsOut] = PlotMeanPVcorrsDaysApart(CSpooledMeanPVcorrs{pvtI}, CSpooledPVdaysApart{pvtI}, 'mean', condSetColors, condSetLabels, hht{pvtI});
hht{pvtI}.Title.String = [pvNames{pvtI}; hht{pvtI}.Title.String];
end
suptitleSL('PV by days apart')

% Pop Vector corrs by days apart FIRST HALF
gg = figure('Position',[288 37 1521 849]); 
hht = [];
for pvtI = 1:length(pvNames)
    hht{pvtI} = subplot(2,3,pvtI);
[hht{pvtI}, statsOut] = PlotMeanPVcorrsDaysApart(CSpooledMeanPVcorrsHalfFirst{pvtI}, CSpooledPVdaysApart{pvtI}, 'mean', condSetColors, condSetLabels, hht{pvtI});
hht{pvtI}.Title.String = [pvNames{pvtI}; hht{pvtI}.Title.String];
end
suptitleSL('PV by days apart, FRIST HALF')

% Pop Vector corrs by days apart SECOND HALF
gg = figure('Position',[288 37 1521 849]); 
hht = [];
for pvtI = 1:length(pvNames)
    hht{pvtI} = subplot(2,3,pvtI);
    [hht{pvtI}, statsOut] = PlotMeanPVcorrsDaysApart(CSpooledMeanPVcorrsHalfSecond{pvtI}, CSpooledPVdaysApart{pvtI}, 'mean', condSetColors, condSetLabels, hht{pvtI});
    hht{pvtI}.Title.String = [pvNames{pvtI}; hht{pvtI}.Title.String];
end
suptitleSL('PV by days apart, SECOND HALF')
%% PV corr self change by days apart
figure('Position',[288 37 1521 849]);
for pvtI = 1:length(pvNames)
    ggt{pvtI} = subplot(2,3,pvtI);
    [ggt{pvtI},statsOut] = PlotChangeByDaysApartFWDonly(withinCSdayChangeMean{pvtI},sameDayDayDiffsPooled{pvtI},condSetColors,condSetLabels,ggt{pvtI});
    ggt{pvtI}.Title.String = [pvNames{pvtI}; ggt{pvtI}.Title.String];
end
suptitleSL('Chance in Each Correlation over Experience')

% PV corr self change by days apart FIRST HALF
figure('Position',[288 37 1521 849]);
for pvtI = 1:length(pvNames)
    ggt{pvtI} = subplot(2,3,pvtI);
    [ggt{pvtI},statsOut] = PlotChangeByDaysApartFWDonly(withinCSdayChangeMeanHalfFirst{pvtI},sameDayDayDiffsPooled{pvtI},condSetColors,condSetLabels,ggt{pvtI});
    ggt{pvtI}.Title.String = [pvNames{pvtI}; ggt{pvtI}.Title.String];
end
suptitleSL('Chance in Each Correlation over Experience First Half')

% PV corr self change by days apart SECOND HALF
figure('Position',[288 37 1521 849]);
for pvtI = 1:length(pvNames)
    ggt{pvtI} = subplot(2,3,pvtI);
    [ggt{pvtI},statsOut] = PlotChangeByDaysApartFWDonly(withinCSdayChangeMeanHalfSecond{pvtI},sameDayDayDiffsPooled{pvtI},condSetColors,condSetLabels,ggt{pvtI});
    ggt{pvtI}.Title.String = [pvNames{pvtI}; ggt{pvtI}.Title.String];
end
suptitleSL('Chance in Each Correlation over Experience Second Half')

%% PV corr separation by days apart

cscColors = {'m'; 'c'; 'k'};%[0.8 0.2 0]
figure('Position',[288 37 1521 849]);
for pvtI = 1:length(pvNames)
    ggt{pvtI} = subplot(2,3,pvtI);
    [ggt{pvtI},statsOut] = PlotChangeByDaysApartFWDonly(cscDiffsChangeMeanPooled{pvtI},sameDayDayDiffsPooled{pvtI},cscColors,cscLabels,ggt{pvtI});
    ggt{pvtI}.Title.String = [pvNames{pvtI}; ggt{pvtI}.Title.String];
end
suptitleSL('Change in Separation between Correlations')

% PV corr separation by days apart FIRST HALF
figure('Position',[288 37 1521 849]);
for pvtI = 1:length(pvNames)
    ggt{pvtI} = subplot(2,3,pvtI);
    [ggt{pvtI},statsOut] = PlotChangeByDaysApartFWDonly(cscDiffsChangeMeanHalfFirstPooled{pvtI},sameDayDayDiffsPooled{pvtI},cscColors,cscLabels,ggt{pvtI});
    ggt{pvtI}.Title.String = [pvNames{pvtI}; ggt{pvtI}.Title.String];
end
suptitleSL('Change in Separation between Correlations FIRST HALF')

% PV corr separation by days apart SECOND HALF
figure('Position',[288 37 1521 849]);
for pvtI = 1:length(pvNames)
    ggt{pvtI} = subplot(2,3,pvtI);
    [ggt{pvtI},statsOut] = PlotChangeByDaysApartFWDonly(cscDiffsChangeMeanHalfSecondPooled{pvtI},sameDayDayDiffsPooled{pvtI},cscColors,cscLabels,ggt{pvtI});
    ggt{pvtI}.Title.String = [pvNames{pvtI}; ggt{pvtI}.Title.String];
end
suptitleSL('Change in Separation between Correlations SECOND HALF')
%% Pop Vector corrs by days apart ARMs
gg = figure('Position',[288 37 1521 849]); 
hht = [];
for pvtI = 1:length(pvNames)
    hht{pvtI} = subplot(2,3,pvtI);
[hht{pvtI}, statsOut] = PlotMeanPVcorrsDaysApart(CSpooledMeanPVcorrsARM{pvtI}, CSpooledPVdaysApart{pvtI}, 'mean', condSetColors, condSetLabels, hht{pvtI});
hht{pvtI}.Title.String = [pvNames{pvtI}; hht{pvtI}.Title.String];
end
suptitleSL('PV by days apart ARMS')

gg = figure('Position',[288 37 1521 849]); 
hht = [];
for pvtI = 1:length(pvNames)
    hht{pvtI} = subplot(2,3,pvtI);
[hht{pvtI}, statsOut] = PlotMeanPVcorrsDaysApart(CSpooledMeanPVcorrsHalfFirstARM{pvtI}, CSpooledPVdaysApart{pvtI}, 'mean', condSetColors, condSetLabels, hht{pvtI});
hht{pvtI}.Title.String = [pvNames{pvtI}; hht{pvtI}.Title.String];
end
suptitleSL('PV by days apart ARMS FIRST HALF')


gg = figure('Position',[288 37 1521 849]); 
hht = [];
for pvtI = 1:length(pvNames)
    hht{pvtI} = subplot(2,3,pvtI);
[hht{pvtI}, statsOut] = PlotMeanPVcorrsDaysApart(CSpooledMeanPVcorrsHalfSecondARM{pvtI}, CSpooledPVdaysApart{pvtI}, 'mean', condSetColors, condSetLabels, hht{pvtI});
hht{pvtI}.Title.String = [pvNames{pvtI}; hht{pvtI}.Title.String];
end
suptitleSL('PV by days apart ARMS SECOND HALF')



%% PV corr self change by days apart ARMS
figure('Position',[288 37 1521 849]);
for pvtI = 1:length(pvNames)
    ggt{pvtI} = subplot(2,3,pvtI);
    [ggt{pvtI},statsOut] = PlotChangeByDaysApartFWDonly(withinCSdayChangeMeanARM{pvtI},sameDayDayDiffsPooled{pvtI},condSetColors,condSetLabels,ggt{pvtI});
    ggt{pvtI}.Title.String = [pvNames{pvtI}; ggt{pvtI}.Title.String];
end
suptitleSL('Chance in Each Correlation over Experience ARMS')

figure('Position',[288 37 1521 849]);
for pvtI = 1:length(pvNames)
    ggt{pvtI} = subplot(2,3,pvtI);
    [ggt{pvtI},statsOut] = PlotChangeByDaysApartFWDonly(withinCSdayChangeMeanHalfFirstARM{pvtI},sameDayDayDiffsPooled{pvtI},condSetColors,condSetLabels,ggt{pvtI});
    ggt{pvtI}.Title.String = [pvNames{pvtI}; ggt{pvtI}.Title.String];
end
suptitleSL('Chance in Each Correlation over Experience ARMS first half')

figure('Position',[288 37 1521 849]);
for pvtI = 1:length(pvNames)
    ggt{pvtI} = subplot(2,3,pvtI);
    [ggt{pvtI},statsOut] = PlotChangeByDaysApartFWDonly(withinCSdayChangeMeanHalfSecondARM{pvtI},sameDayDayDiffsPooled{pvtI},condSetColors,condSetLabels,ggt{pvtI});
    ggt{pvtI}.Title.String = [pvNames{pvtI}; ggt{pvtI}.Title.String];
end
suptitleSL('Chance in Each Correlation over Experience ARMS second half')
%% PV corr separation by days apart ARMS

cscColors = {'m'; 'c'; 'k'};%[0.8 0.2 0]
figure('Position',[288 37 1521 849]);
for pvtI = 1:length(pvNames)
    ggt{pvtI} = subplot(2,3,pvtI);
    [ggt{pvtI},statsOut] = PlotChangeByDaysApartFWDonly(cscDiffsChangeMeanPooledARM{pvtI},sameDayDayDiffsPooled{pvtI},cscColors,cscLabels,ggt{pvtI});
    ggt{pvtI}.Title.String = [pvNames{pvtI}; ggt{pvtI}.Title.String];
end
suptitleSL('Change in Separation between Correlations ARMS')

cscColors = {'m'; 'c'; 'k'};%[0.8 0.2 0]
figure('Position',[288 37 1521 849]);
for pvtI = 1:length(pvNames)
    ggt{pvtI} = subplot(2,3,pvtI);
    [ggt{pvtI},statsOut] = PlotChangeByDaysApartFWDonly(cscDiffsChangeMeanHalfFirstPooledARM{pvtI},sameDayDayDiffsPooled{pvtI},cscColors,cscLabels,ggt{pvtI});
    ggt{pvtI}.Title.String = [pvNames{pvtI}; ggt{pvtI}.Title.String];
end
suptitleSL('Change in Separation between Correlations ARMS First Half')

cscColors = {'m'; 'c'; 'k'};%[0.8 0.2 0]
figure('Position',[288 37 1521 849]);
for pvtI = 1:length(pvNames)
    ggt{pvtI} = subplot(2,3,pvtI);
    [ggt{pvtI},statsOut] = PlotChangeByDaysApartFWDonly(cscDiffsChangeMeanHalfSecondPooledARM{pvtI},sameDayDayDiffsPooled{pvtI},cscColors,cscLabels,ggt{pvtI});
    ggt{pvtI}.Title.String = [pvNames{pvtI}; ggt{pvtI}.Title.String];
end
suptitleSL('Change in Separation between Correlations ARMS Second Half')

%% Stem vs Arms

statsOut = [];
for condI = 1:length(condSet)
[figHand, statsOut{condI}] = PVcorrCompStemVsArmDaysApart(CSpooledMeanPVcorrs,CSpooledMeanPVcorrsARM,CSpooledPVdaysApart,pvNames,condI);
suptitleSL(['Difference between Stem (l) and ARM (r) corrs in ' condSetLabels{condI}])
end


%% Decoder results 

%Decoder FWD vs REV self.
statsOut = [];
for dtI = 1:length(decodingType)
    dimsDecoded = regDecoding{dtI}{1}.titles;
    figure('Position',[403 461 771 496]);
    for ddI = 1:length(dimsDecoded)
        axH(ddI) = subplot(length(dimsDecoded),1,ddI);
        [axH(ddI),statsOut{dtI}{ddI}] = PlotDecodingFWDvsREVwrapper(decodingResultsPooled{dtI}{ddI},decodedWellPooled{dtI}{ddI},sessDayDiffs{dtI}{ddI},axH(ddI));
        title(['Decoding ' dimsDecoded{ddI} ' ' fileName{dtI} ' cells'])
    end
end
       
%LvR vs. SvT comparison
statsOut = [];
for dtI = 1:length(decodingType)
    [axH, statsOut{dtI}] = PlotDecodingOneVSother(decodingResultsPooled{dtI},shuffledResultsPooled{dtI},decodedWellPooled{dtI},...
                                                sessDayDiffs{dtI}{1},sessDayDiffs{dtI}{1},{'Turn Direction','Task Phase'});
    suptitleSL(['Decoding Comparison, ' fileName{dtI} ' cells'])
end

%Within dimension, which cell inclusion is better?
dimsDecoded = regDecoding{1}{1}.titles;
statsOut = [];
for dwI = 1:length(dimsDecoded)
[axH, statsOut{dwI}] = PlotDecodingOneVSother({decodingResultsPooled{1}{dwI} decodingResultsPooled{2}{dwI}},...
                                         {shuffledResultsPooled{1}{dwI} shuffledResultsPooled{2}{dwI}},...
                                         {decodedWellPooled{1}{dwI} decodedWellPooled{2}{dwI}},sessDayDiffs{1}{dwI},decodingType);
      suptitleSL(['Decoding Cell Inclusion Comparison, ' dimsDecoded{dwI}])
end

%Regular vs Downsampling
dimsDecoded = regDecoding{1}{1}.titles;
statsOut = [];
for dtI = 1:length(decodingType)
    [axH, statsOut{dtI}] = PlotDecodingOneVSother(decodingResultsPooled{dtI},...
           downsampledResultsPooled{dtI},decodeOutofDSpooled{dtI},sessDayDiffs{dtI}{1},sessDayDiffs{dtI}{1},{'Turn Direction','Task Phase'});
    suptitleSL(['Reg vs. downsampled distribution, ' fileName{dtI} ' cells'])
end

%Downsampled inclusion comparison
%Is each downsample above 95% of shuffles?
statsOut = [];
for dtI = 1:length(decodingType)
    [axH, statsOut{dtI}] = PlotDecodingOneVSother(downsampledResultsPooled{dtI},shuffledResultsPooled{dtI},DSaboveShuffPpooled{dtI},...
                    sessDayDiffs{dtI}{1},sessDayDiffs{dtI}{1},dimsDecoded);
    suptitleSL(['Downsampled Decoding vs. Original Shuffle, ' fileName{dtI} ' cells'])
end


%% PV condset each mouse

for pvtI = 1:length(pvNames)
    figure;
    for mouseI = 1:numMice
        subplot(2,2,mouseI)
        for csI = 1:length(condSet)
            plot(CSpooledSameDaymeanCorr{pvtI}{mouseI}{csI},condSetColors{csI})
            hold on
        end
    end
    suptitleSL(pvNames{pvtI})
end
            


    