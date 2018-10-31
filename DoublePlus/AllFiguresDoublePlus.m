%AllFiguresDoublePlus
twoColors = [0.9 0.7 0.1; 0.6 0.1 0.2];
oneColors = [0.3 0.75 0.9; 0 0.5 0.75];

%Interesting cells
sameSplitters = [];
notSameSplitters = [];
phaseSplitters = [];
notPhaseSplitters = [];
for mouseI = 1:numMice
    for dayI = 1:size(dayUse{mouseI},2)
        activeCells{mouseI}{dayI} = find(dayUse{mouseI}(:,dayI));
        
        sameSplitters{mouseI}{dayI} = find(dayUse{mouseI}(:,dayI).*splittersSame{mouseI}(:,dayI));
        notSameSplitters{mouseI}{dayI} = find(dayUse{mouseI}(:,dayI).*(splittersSame{mouseI}(:,dayI)==0));
        phaseSplitters{mouseI}{dayI} = find(dayUse{mouseI}(:,dayI).*splittersPhase{mouseI}(:,dayI));
        notPhaseSplitters{mouseI}{dayI} = find(dayUse{mouseI}(:,dayI).*(splittersPhase{mouseI}(:,dayI)==0));
    end
end


%% Demo figure for task setup

[mazeOneA,mazeOneB,mazeTwo] = DoublePlusDemoFig;


%% Performance figure

figure; hold on
patch([3.5 6.5 6.5 3.5],[0.5 0.5 1 1],[0.9 0.7 0.1294],'EdgeColor','none','FaceAlpha',0.4)
for smouseI = 1:size(oneEnvMice,1)
    plot(realDays{oneEnvMice(smouseI)},accuracy{oneEnvMice(smouseI)},'.b','MarkerSize',8)
    plot(realDays{oneEnvMice(smouseI)},accuracy{oneEnvMice(smouseI)},'b','LineWidth',1.5)
end
for dmouseI = 1:size(oneEnvMice,1)
    plot(realDays{twoEnvMice(dmouseI)},accuracy{twoEnvMice(dmouseI)},'.r','MarkerSize',8)
    plot(realDays{twoEnvMice(dmouseI)},accuracy{twoEnvMice(dmouseI)},'r','LineWidth',1.5)
end 
xlim([0.5 9.5])
xlabel('Day Number')
ylabel('Performance')
title('Performance over time, b = same, r = diff')

load webPerformance.mat
figure; hold on
patch([3.5 6.5 6.5 3.5],[0.4 0.4 1.05 1.05],[0.9 0.7 0.1294],'EdgeColor','none','FaceAlpha',0.4)
for smouseI = 1:size(oneEnvMice,1)
    plot(webPerformance(oneEnvMice(smouseI),:),'.b','MarkerSize',8)
    plot(webPerformance(oneEnvMice(smouseI),:),'b','LineWidth',2.5)
end
for dmouseI = 1:size(twoEnvMice,1)
    plot(webPerformance(twoEnvMice(dmouseI),:),'.r','MarkerSize',10)
    plot(webPerformance(twoEnvMice(dmouseI),:),'r','LineWidth',2.5)
end 
xlim([0.95 9.05])
ylim([0.4 1.05])
xlabel('Day Number')
ylabel('Performance')
title('Performance over time, b = same, r = diff')

%% Sample dot/heatmaps

%load(fullfile(mainFolder,mice{1},'daybyday.mat'))

%cellsUse = 102; 141 272 378 1295 861 594 419 (all mouse 1)
cellsUse = cell(numMice,1);
for mouseI = 1:numMice
    cellsUse{mouseI} = [cellsUse{mouseI}; notSameSplitters{mouseI}{1}];
    cellsUse{mouseI} = [cellsUse{mouseI}; notPhaseSplitters{mouseI}{1}];
    cellsUse{mouseI} = [cellsUse{mouseI}; find(sum(splittersPhase{mouseI},2)==3)];
    cellsUse{mouseI} = [cellsUse{mouseI}; find(sum(splittersSame{mouseI},2)==3)];
    
    cellsUse{mouseI} = unique(cellsUse{mouseI});
end



mouseI = 1;
while mouseI<numMice+1
    cellI = 1;
    mouseFolder = fullfile(mainFolder,mice{mouseI});
    load(fullfile(mouseFolder,'daybyday.mat'))
    while cellI < length(cellsUse{mouseI})+1
        thisCell = cellsUse{mouseI}(cellI);
        figHand = PlotDotplotDoublePlus(daybyday,thisCell ,realDays{mouseI}); 

        suptitleSL(['Mouse ' num2str(mouseI) ', cell ' num2str(thisCell)])

        getInput=1;
        while getInput==1
            getInput = 0;
            what = input('save (s), previous cell (a), next cell(d), next mouse (m), previous mouse (b), be done (g). >>','s');
            switch what
                case 's'
                    saveFolder = 'G:\DoublePlus\SFNposter\cellDotplots';
                    print(fullfile(saveFolder,['dotplotM' num2str(mouseI) 'cell' num2str(thisCell)]),'-dpdf')
                case 'a'
                    if cellI~=1
                    cellI = cellI - 2;
                    end
                case 'd'
                    %do nothing
                case 'm'
                    cellI = length(cellsUse{mouseI})+1;
                case 'b'
                    if mouseI~=1
                    cellI = length(cellsUse{mouseI})+1;
                    mouseI = mouseI-2;
                    end
                    getInput=1;
                case 'g'
                    cellI = length(cellsUse{mouseI})+1;
                    mouseI = numMice;
            end

        end
        close(figHand)
        cellI = cellI + 1;
    end
    mouseI = mouseI + 1;
end
 

saveFolder = 'G:\DoublePlus\SFNposter\cellDotplots\gray';

cellsUse = {{8 22 27 50 72};{85 129 154 173 201 207 217 277 281};{}; {} ;{48 69 713};{224 355 377 399 463}};
for mouseI = 1:numMice
    if ~isempty(cellsUse{mouseI})
        mouseFolder = fullfile(mainFolder,mice{mouseI});
        load(fullfile(mouseFolder,'daybyday.mat'))
        
        for cellI = 1:length(cellsUse{mouseI})
            thisCell = cellsUse{mouseI}{cellI};
            figHand = PlotDotplotDoublePlus(daybyday,thisCell ,realDays{mouseI},'vertical'); 
            
            %if strcmpi('individual')
            %    for sessI = 1:length(realDays{mouseI})
            %        figure(figHand{sessI});
            %        title(['Mouse ' num2str(mouseI) ', cell ' num2str(thisCell) ', day' num2str(realDays{mouseI}(sessI)])
            %        print(fullfile(saveFolder,['dotplotM' num2str(mouseI) 'cell' num2str(thisCell)]),'-dpdf')
            %    end
            %else
            suptitleSL(['Mouse ' num2str(mouseI) ', cell ' num2str(thisCell)])
            
            print(fullfile(saveFolder,['dotplotM' num2str(mouseI) 'cell' num2str(thisCell)]),'-dpdf')
            try
                close(figHand);
            end
            %end
        end
    end
end
            
    
%% plot heatmap

%this needs to be tested
for cellI = 1:length(cellsUse)
    cellJ = cellsUse(cellI);
    transparentBkg = 0;
    figHand = PlusMazeHeatmap(cellTMap_unsmoothed{mouseI},cellJ,realDays{mouseI},condNames,transparentBkg) ;
    suptitleSL(['Mouse ' num2str(mouseI) ', cell ' num2str(cellJ)])
end

%{
bins.north = [[1:numBins]'+1, (numBins+1)*ones(numBins,1)+1];
bins.south = [[1:numBins]'+ numBins+2, (numBins+1)*ones(numBins,1)+1];
bins.south(:,1) = flipud(bins.south(:,1));
bins.east = [(numBins+1)*ones(numBins,1)+1, [1:numBins]'+ numBins+2];
bins.west = [(numBins+1)*ones(numBins,1)+1, [1:numBins]'+1];


figure;
jj = colormap(jet);
jj(end-1,:) = jj(end,:);
jj(end,:) = [1 1 1];
close(gcf);
for cellI = 1:length(cellsUse)
    cellJ = cellsUse(cellI);

    allData = [];
    for sessJ = 1:3
        for cnI = 1:length(condNames)
            allData = [allData cellTMap_unsmoothed{mouseI}{cellJ,sessJ,cnI}];
        end
    end
    roundSteps = [0:0.1:1];
    maxRateHere = max(allData);
    rateScaleMax = roundSteps(find(roundSteps>maxRateHere,1,'first'));
    PlusMapBlank = ones(numBins*2+3,numBins*2+3)*(rateScaleMax + 0.01);
    
    ii=figure('Position',[65 398 1775 580]);
    for sessI = 1:3

        thisMap = PlusMapBlank;
        for cnI = 1:length(condNames)
            ratesHere = cellTMap_unsmoothed{mouseI}{cellJ,sessI,cnI};
            if strcmpi(condNames{cnI},'west')
                ratesHere = fliplr(ratesHere);
            end
            for binI = 1:numBins 
                thisMap(bins.(condNames{cnI})(binI,1),bins.(condNames{cnI})(binI,2)) = ratesHere(binI);
            end
        end
        
        subplot(1,3,sessI)
        imagesc(thisMap) 
        hold on
        colormap(jj)
        %caxis([0 1])
        qq=colorbar;
        qq.Limits = [0 rateScaleMax];
        axis equal
        xlim([1 23])
        ylim([1 23])
        if plotBins == 1
            for cnI = 1:length(condNames)
            sBins = bins.(condNames{cnI});
                for binI = 1:numBins
                    xCorns = [sBins(binI,2)-0.5 sBins(binI,2)+0.5 sBins(binI,2)+0.5 sBins(binI,2)-0.5 sBins(binI,2)-0.5];
                    yCorns = [sBins(binI,1)-0.5 sBins(binI,1)-0.5 sBins(binI,1)+0.5 sBins(binI,1)+0.5 sBins(binI,1)-0.5];
                    plot(xCorns,yCorns,'k','LineWidth',0.5)
                end
            end
        end

        title(['Day ' num2str(realDays{mouseI}(sessI))])
    end
    suptitleSL(['Mouse ' num2str(mouseI) ', cell ' num2str(cellJ)])
end
%}

%% PV corr figure individual and mean data
%armAlignment = GetDoublePlusArmAlignment;
%condNames = {cellTBT{1}.name};
xBins = 1:numBins;

for dpI = 1:numDayPairs
figure; 
    for cpI = 1:4
        subplot(2,2,cpI); hold on
        allCorrsSame = oneEnvMicePVcorrs{dpI,cpI};
        meanCorrSame = oneEnvMicePVcorrsMeans{dpI,cpI};
        allCorrsDiff = twoEnvMicePVcorrs{dpI,cpI};
        meanCorrDiff = twoEnvMicePVcorrsMeans{dpI,cpI};

        if strcmpi(condNames{cpI},'west')
            allCorrsSame = fliplr(allCorrsSame); meanCorrSame = fliplr(meanCorrSame);
            allCorrsDiff = fliplr(allCorrsDiff); meanCorrDiff = fliplr(meanCorrDiff);
        end

        plot(repmat(xBins,length(oneEnvMice),1),allCorrsSame,'.c','MarkerSize',8)
        plot(repmat(xBins,length(twoEnvMice),1),allCorrsDiff,'.m','MarkerSize',8)

        plot(xBins,meanCorrSame,'.-b','MarkerSize',8,'LineWidth',2)
        plot(xBins,meanCorrDiff,'.-r','MarkerSize',8,'LineWidth',2)

        ylabel('Correlation Value')
        switch condNames{cpI}
            case {'north','south'} 
                xlabel('START      CENTER')
            case {'east','west'}
                xlabel('CENTER     REWARD')
        end
        title(['PVcorrs ' condNames{cpI} ' arm'])
        xlim([0.95 numBins+0.05])
    end
    suptitleSL(['Day pair ' num2str(dayPairs(dpI,:)) ', red=diff blue=same'])
end

%% PVcorrHeatmap groups alone
%Color scaling by positive or negative
%same - different: if different is higher, than score is negative; if
%different is lower, score is positive
locations = [0.1 0.5 0.85];
colors = [1.0000    0.4000    0.2000;
          1.0000    1.0000         0;
               0    0.4510    0.7412];
locations = [0 0.15 0.3 0.5 0.7 0.85 1];
colors = [0.0000    0.0    0.000;
            1 0.0 0;
            0.9    0    0;
            1 1 1;
            0.3020    0.7490    0.9294;
            0    0.4510    0.7412;
            0 0 0];
        
locations = [0 0.5 1];
colors = [1.0000    0.0    0.000;
            1 1 1;
            0    0.45   0.74];
           
newGradient = GradientMaker(colors,locations);
           
for dpI = 1:size(dayPairs,1)
figHand = PlusMazePVcorrHeatmap({oneEnvMicePVcorrsMeans{dpI,:}},condNames,armAlignment,[],[],1);
title(['Mean 1-Env PV corrs, day pair ' num2str(dayPairs(dpI,:))])
colormap(newGradient);
end

for dpI = 1:size(dayPairs,1)
figHand = PlusMazePVcorrHeatmap({twoEnvMicePVcorrsMeans{dpI,:}},condNames,armAlignment,[],[],1);
title(['Mean 2-Env PV corrs, day pair ' num2str(dayPairs(dpI,:))])
colormap(newGradient);
end


%% PVcorrHeatmap subtraction
%Color scaling by positive or negative
%same - different: if different is higher, than score is negative; if
%different is lower, score is positive
locations = [0 0.5 1];
colors = [1.0000    0.0    0.000;
            1 1 0;
            0.2   0.9   0.2];
           
newGradient = GradientMaker(colors,locations);

for dpI = 1:size(dayPairs,1)
figHand = PlusMazePVcorrHeatmap({sameMinusDiff{dpI,:}},condNames,armAlignment,{diffRank{dpI,:}},pThresh,1);
title(['Difference of Mean PV corrs, day pair ' num2str(dayPairs(dpI,:))])
colormap(hot); 
caxis([-0.4 0])
end



%% PV corr by chunk of trials


for dcI = 1:numDayChunks
    for dpI = 1:size(dayPairs,1)
        figHand = PlusMazePVcorrHeatmap({sameMinusDiffTrim{dcI,dpI,:}},condNames,armAlignment,{diffRankTrim{dcI,dpI,:}},pThresh,1);
        title(['Difference of Mean PV corrs, day pair ' num2str(dayPairs(dpI,:)), ', dayChunk ' num2str(dayChunks(dcI,:))])
    end
end

%Graph of these values
fourColors = [0.47 0.67 0.19;...
              0.49 0.18 0.56;...
              0.93 0.69 0.13;...
              0.30 0.75 0.93];
conAdj = 0.1;
figure('Position',[449 288 1149 511]);
for dpI = 1:numDayPairs
    hh = subplot(1,numDayPairs,dpI); hold on;
    ylim([-0.3 0.1]); xlim([0.9 numDayChunks+0.1])
    for condI = 1:numConds
        dpTmap = {sameMinusDiffTrim{:,dpI,condI}};
        meanCorrs = cell2mat(cellfun(@mean,dpTmap,'UniformOutput',false));
        for dcI = 1:numDayChunks
            pHere = 1 - diffRankTrim{dcI,dpI,condI};
            if pHere < pThresh 
                txtColor = 'r';
            else
                txtColor = 'k';
            end
            
            text(dcI,meanCorrs(dcI),condNames{condI}(1),'HorizontalAlignment','center','Color',txtColor,...
                'FontSize',15)
            
            %if pHere > pThresh
            %    if phere==1
            %        pText = 'p<0.001';
            %    else 
            %        pText = ['p=' num2str(1-pHere)];
            %    end
            %    text(dpI+0.2,meanCorr,pText)
            %     text(dcI+0.2,meanCorrs(dcI)+0.02,'n.s.','HorizontalAlignment','center','Color','k')
            %end           
        end
        for dcJ = 1:numDayChunks-1
            plot([dcJ+conAdj dcJ+1-conAdj],[meanCorrs(dcJ) meanCorrs(dcJ+1)],'Color',fourColors(condI,:),'LineWidth',1.5)
        end
    end
    hh.XTick = 1:1:numDayChunks;
    hh.XTickLabels = cellfun(@num2str,mat2cell(hh.XTick',ones(numDayChunks,1),1),'UniformOutput',false);
    xlabel('Day Portion')
    ylabel('Mean Correlation')
    title(['Days ' num2str(realDays{mouseI}(dayPairsForward(dpI,1))) ' vs ' num2str(realDays{mouseI}(dayPairsForward(dpI,2)))])
end
suptitleSL('Mean Within Arm Correlation Difference by Portion of Session')
        

for dpI = 1:numDayPairs

for dcI = 1:numDayChunks
figure; 
    for cpI = 1:4
        subplot(2,2,cpI); hold on
        allCorrsSame = oneEnvMiceTrimPVcorrs{dcI,dpI,cpI};
        meanCorrSame = oneEnvMiceTrimPVcorrsMeans{dcI,dpI,cpI};
        allCorrsDiff = twoEnvMiceTrimPVcorrs{dcI,dpI,cpI};
        meanCorrDiff = twoEnvMiceTrimPVcorrsMeans{dcI,dpI,cpI};

        plot(repmat(xBins,length(oneEnvMice),1),allCorrsSame,'.c','MarkerSize',4)
        plot(repmat(xBins,length(twoEnvMice),1),allCorrsDiff,'.m','MarkerSize',4)

        plot(xBins,meanCorrSame,'.-b','MarkerSize',6)
        plot(xBins,meanCorrDiff,'.-r','MarkerSize',6)

        ylabel('Correlation Value')
        switch condNames{cpI}
            case {'north','south'} 
                xlabel('START      CENTER')
            case {'east','west'}
                xlabel('CENTER     REWARD')
        end
        title(['PVcorrs ' condNames{cpI} ' arm'])
        
    end
    suptitleSL(['Day pair ' num2str(dayPairs(dpI,:)) ', trial chunk ' num2str(dcI) ', red=diff blue=same'])
end

end

%% Splitters plot

plotColors = {'g'  'r'  ; 'c'  'm'};
pairsPlot = [1 2; 3 4];
xLabels = {'NORTH          SOUTH'; 'EAST             WEST'};
yLabels = {'START          CENTER'; 'CENTER          END'};

daysPlot = 1:3;
            
cellsUse = 141;
for cellI = 1:length(cellsUse)
    for daysPlotI = 1:3
        TMapPlot = {cellTMap_unsmoothed{mouseI}{cellsUse(cellI),daysPlot(daysPlotI),:}};
        PlotSplitterFigDoublePlus(TMapPlot, pairsPlot, xLabels, plotColors, yLabels, [], [])
    end
end


posUse =  [584   324   305   427];
hh = gcf;
        hh.Position = posUse;
   
%% Splitter changes

%individual mice
for mouseI = 1:numMice
    figure;
    subplot(1,3,1); hold on
    plot(splitterGroupPct{mouseI}{1})
    plot(splitterGroupPct{mouseI}{2})
    legend(groupNames{1},groupNames{2})
    subplot(1,3,2); hold on
    plot(splitterGroupPct{mouseI}{3})
    plot(splitterGroupPct{mouseI}{4})
    legend(groupNames{3},groupNames{4})
    subplot(1,3,3); hold on
    plot(splitterGroupPct{mouseI}{5})
    plot(splitterGroupPct{mouseI}{6})
    legend(groupNames{5},groupNames{6})
end

%Grouped
figure;
hh=subplot(1,3,1); hold on
plot(pooledSplitterProps{1}(oneEnvMice,:),'.','Color',oneColors(1,:),'MarkerSize',8)
plot(pooledSplitterProps{2}(oneEnvMice,:),'.','Color',oneColors(2,:),'MarkerSize',8)
plot(pooledSplitterProps{1}(twoEnvMice,:),'.','Color',twoColors(1,:),'MarkerSize',8)
plot(pooledSplitterProps{2}(twoEnvMice,:),'.','Color',twoColors(2,:),'MarkerSize',8)
p1=plot(mean(pooledSplitterProps{1}(oneEnvMice,:),1),'Color',oneColors(1,:),'LineWidth',2);
p2=plot(mean(pooledSplitterProps{2}(oneEnvMice,:),1),'Color',oneColors(2,:),'LineWidth',2);
p3=plot(mean(pooledSplitterProps{1}(twoEnvMice,:),1),'Color',twoColors(1,:),'LineWidth',2);
p4=plot(mean(pooledSplitterProps{2}(twoEnvMice,:),1),'Color',twoColors(2,:),'LineWidth',2);
legend([p1 p2 p3 p4],['int ' groupNames{1}],['int ' groupNames{2}],['sep ' groupNames{1}],['sep ' groupNames{2}],'location','east')
ylim([0.5 1]); ylabel('Proportion of Cells'); xlabel('Day Number')
%hh.XTick = [0 0.5 1]; 
hh.XTickLabel = {'3' '7' '8'};

hh=subplot(1,3,2); hold on
plot(pooledSplitterProps{3}(oneEnvMice,:),'.','Color',oneColors(1,:),'MarkerSize',8)
plot(pooledSplitterProps{4}(oneEnvMice,:),'.','Color',oneColors(2,:),'MarkerSize',8)
plot(pooledSplitterProps{3}(twoEnvMice,:),'.','Color',twoColors(1,:),'MarkerSize',8)
plot(pooledSplitterProps{4}(twoEnvMice,:),'.','Color',twoColors(2,:),'MarkerSize',8)
p1=plot(mean(pooledSplitterProps{3}(oneEnvMice,:),1),'Color',oneColors(1,:),'LineWidth',2);
p2=plot(mean(pooledSplitterProps{4}(oneEnvMice,:),1),'Color',oneColors(2,:),'LineWidth',2);
p3=plot(mean(pooledSplitterProps{3}(twoEnvMice,:),1),'Color',twoColors(1,:),'LineWidth',2);
p4=plot(mean(pooledSplitterProps{4}(twoEnvMice,:),1),'Color',twoColors(2,:),'LineWidth',2);
legend([p1 p2 p3 p4],['int ' groupNames{3}],['int ' groupNames{4}],['sep ' groupNames{3}],['sep ' groupNames{4}],'location','east')
ylim([0 0.5]); ylabel('Proportion of Cells'); xlabel('Day Number')
%hh.XTick = [0 0.5 1]; 
hh.XTickLabel = {'3' '7' '8'};

hh=subplot(1,3,3); hold on
plot(pooledSplitterProps{5}(oneEnvMice,:),'.','Color',oneColors(1,:),'MarkerSize',8)
plot(pooledSplitterProps{6}(oneEnvMice,:),'.','Color',oneColors(2,:),'MarkerSize',8)
plot(pooledSplitterProps{5}(twoEnvMice,:),'.','Color',twoColors(1,:),'MarkerSize',8)
plot(pooledSplitterProps{6}(twoEnvMice,:),'.','Color',twoColors(2,:),'MarkerSize',8)
p1=plot(mean(pooledSplitterProps{5}(oneEnvMice,:),1),'Color',oneColors(1,:),'LineWidth',2);
p2=plot(mean(pooledSplitterProps{6}(oneEnvMice,:),1),'Color',oneColors(2,:),'LineWidth',2);
p3=plot(mean(pooledSplitterProps{5}(twoEnvMice,:),1),'Color',twoColors(1,:),'LineWidth',2);
p4=plot(mean(pooledSplitterProps{6}(twoEnvMice,:),1),'Color',twoColors(2,:),'LineWidth',2);
legend([p1 p2 p3 p4],['int ' groupNames{5}],['int ' groupNames{6}],['sep ' groupNames{5}],['sep ' groupNames{6}],'location','east')
ylim([0 1]); ylabel('Proportion of Cells'); xlabel('Day Number')
%hh.XTick = [0 0.5 1]; 
hh.XTickLabel = {'3' '7' '8'};

suptitleSL('Proportion of splitting type by group')


%% Center of mass changes

saveFolder = 'G:\DoublePlus\SFNposter';
for dpI = 1:numDayPairs
    gg = figure('Position',[428 376 590 515]);%[428 613 897 278]
    for condI = 1:numConds
        xx = subplot(2,numConds/2,condI); hold on
        yy = cdfplot(oneEnvCOMchangeProps{dpI}{condI}); yy.Color = 'b'; yy.LineWidth = 2;
        hold on
        zz = cdfplot(twoEnvCOMchangeProps{dpI}{condI}); zz.Color = 'r'; zz.LineWidth = 2; 
        
        xlabel('CM change'); ylabel('Cumulative Proportion')
        title(condNames{condI})
        xlim([0 1])
        xx.XTick = [0 0.5 1]; xx.XTickLabel = {'0' num2str(numBins/2) num2str(numBins)};
        
        [h,p] = kstest2(oneEnvCOMchangeProps{dpI}{condI},twoEnvCOMchangeProps{dpI}{condI});
        text(0.4,0.5,['p=' num2str(round(p,2))])
    end
    suptitleSL(['Distribution of within-arm COM changes, day pair ' num2str(realDays{mouseI}(dayPairsForward(dpI,:))')])
    
    print(fullfile(saveFolder,['COMchangeKS' num2str(dpI)]),'-dpdf') 
    close(gg)
end

%Pooled across arms
for dpI = 1:numDayPairs
    gg = figure;%('Position',[428 376 590 515]);%[428 613 897 278]
    
    %yy = cdfplot(oneEnvCOMchanges{dpI}(:)); yy.Color = 'b'; yy.LineWidth = 2;
    %hold on
    %zz = cdfplot(twoEnvCOMchanges{dpI}(:)); zz.Color = 'r'; zz.LineWidth = 2; 
    [yy,xxy] = ecdf(oneEnvCOMchanges{dpI}(:));
    [zz,xxz] = ecdf(twoEnvCOMchanges{dpI}(:));
    plot(log10(xxy),yy,'b','LineWidth',2)
    hold on
    plot(log10(xxz),zz,'r','LineWidth',2)
    xlim([-1 1])
    
    
    xlabel('CM change'); ylabel('Cumulative Proportion')
    %    title(condNames{condI})
        %xlim([0 1])
        %xx.XTick = [0 0.5 1]; xx.XTickLabel = {'0' num2str(numBins/2) num2str(numBins)};
        
    [p,h] = ranksum(oneEnvCOMchanges{dpI}(:),twoEnvCOMchanges{dpI}(:));
    text(4.5,0.5,['p=' num2str(round(p,3))])
    
    title(['Distribution of within-arm COM changes, day pair ' num2str(realDays{mouseI}(dayPairsForward(dpI,:))')])
    
end

%% Rate remapping

saveFolder = 'G:\DoublePlus\SFNposter';
thingUseOne = oneEnvMeanRateDiffs;
thingUseTwo = twoEnvMeanRateDiffs;
label = 'mean firing rate differences';
thingUseOne = oneEnvMeanRatePctChange;
thingUseTwo = twoEnvMeanRatePctChange;
label = 'mean firing rate pct changes';
thingUseOne = oneEnvMaxRatePctChange;
thingUseTwo = twoEnvMaxRatePctChange;
label = 'max firing rate pct changes';
thingUseOne = oneEnvMaxRateDiffs;
thingUseTwo = twoEnvMaxRateDiffs;
label = 'max firing rate differences';

for dpI = 1:numDayPairs
    gg = figure('Position',[428 376 590 515]);%[428 613 897 278]
    
    changesHereOne = thingUseOne{dpI}; changesHereOne(oneEnvFiredEither{dpI}==0)=NaN;
    changesHereTwo = thingUseTwo{dpI}; changesHereTwo(twoEnvFiredEither{dpI}==0)=NaN;
    
    for condI = 1:numConds
        xx = subplot(2,numConds/2,condI); hold on
        
        yy = cdfplot(changesHereOne(:,condI)); yy.Color = 'b'; yy.LineWidth = 2;
        hold on
        zz = cdfplot(changesHereTwo(:,condI)); zz.Color = 'r'; zz.LineWidth = 2; 
        
        %xlabel('Max rate change'); 
        xlabel(label(1:end-1))
        ylabel('Cumulative Proportion')
        title(condNames{condI})
        %xlim([0 1])
        %xx.XTick = [0 0.5 1]; xx.XTickLabel = {'0' num2str(numBins/2) num2str(numBins)};
        
        %[h,p] = kstest2(changesHereOne(:,condI),changesHereTwo(:,condI));
        [p,h] = ranksum(changesHereOne(:,condI),changesHereTwo(:,condI));
        text(0.4,0.5,['p=' num2str(round(p,3))])%'h=' num2str(h) ', 
    end
    suptitleSL(['Distribution of within-arm ' label ', day pair ' num2str(realDays{mouseI}(dayPairsForward(dpI,:))')])
    
    %print(fullfile(saveFolder,['COMchangeKS' num2str(dpI)]),'-dpdf') 
    %close(gg)
end

for dpI = 1:numDayPairs
    gg = figure('Position',[428 376 590 515]);%[428 613 897 278]
    
    changesHereOne = thingUseOne{dpI}; changesHereOne(oneEnvFiredEither{dpI}==0)=NaN;
    changesHereTwo = thingUseTwo{dpI}; changesHereTwo(twoEnvFiredEither{dpI}==0)=NaN;
    changesHereOne(changesHereOne==1) = NaN;
    changesHereTwo(changesHereTwo==1) = NaN;
    
    yy = cdfplot(changesHereOne(:)); yy.Color = 'b'; yy.LineWidth = 2;
    hold on
    zz = cdfplot(changesHereTwo(:)); zz.Color = 'r'; zz.LineWidth = 2; 
        
    xlabel(label(1:end-1))
    ylabel('Cumulative Proportion')
    title(condNames{condI})
    %xlim([0 1])
    %xx.XTick = [0 0.5 1]; xx.XTickLabel = {'0' num2str(numBins/2) num2str(numBins)};
        
    %[h,p] = kstest2(changesHereOne(:,condI),changesHereTwo(:,condI));
    [p,h] = ranksum(changesHereOne(:),changesHereTwo(:));
    text(0.4,0.5,['p=' num2str(round(p,3))])%'h=' num2str(h) ', 
    
    suptitleSL(['Distribution of within-arm ' label ', day pair ' num2str(realDays{mouseI}(dayPairsForward(dpI,:))')])
    
    %print(fullfile(saveFolder,['COMchangeKS' num2str(dpI)]),'-dpdf') 
    %close(gg)
end
            
%% Same arm max firing?

gg=figure; hold on
for dpI = 1:numDayPairs
    plot((dpI-0.05)*ones(1,length(oneEnvMice)),sameArmPct(oneEnvMice,dpI),'.b','MarkerSize',18)
    plot((dpI+0.05)*ones(1,length(twoEnvMice)),sameArmPct(twoEnvMice,dpI),'.r','MarkerSize',18)
end
xlim([0.9 numDayPairs+0.1])
gg.Children.XTick = 1:numDayPairs;
nn = mat2cell(realDays{mouseI}(dayPairsForward),ones(1,numDayPairs),2);
gg.Children.XTickLabel = cellfun(@num2str,mat2cell(realDays{mouseI}(dayPairsForward),ones(1,numDayPairs),2),'UniformOutput',false);
xlabel('Day Pair')
ylabel('Pct. Cells with same arm max firing')

%% Totally stopped/started firing

gg=figure; hold on
for dpI = 1:numDayPairs
    plot((dpI-0.05)*ones(1,length(oneEnvMice)),stoppedFiringAll(oneEnvMice,dpI),'.b','MarkerSize',18)
    plot((dpI+0.05)*ones(1,length(twoEnvMice)),stoppedFiringAll(twoEnvMice,dpI),'.r','MarkerSize',18)
end
xlim([0.9 numDayPairs+0.1])
gg.Children.XTick = 1:numDayPairs;
nn = mat2cell(realDays{mouseI}(dayPairsForward),ones(1,numDayPairs),2);
gg.Children.XTickLabel = cellfun(@num2str,mat2cell(realDays{mouseI}(dayPairsForward),ones(1,numDayPairs),2),'UniformOutput',false);
xlabel('Day Pair')
ylabel('Pct. Cells that stopped firing')
%ylim([0 0.2])

gg=figure; hold on
for dpI = 1:numDayPairs
    plot((dpI-0.05)*ones(1,length(oneEnvMice)),startedFiringAll(oneEnvMice,dpI),'.b','MarkerSize',18)
    plot((dpI+0.05)*ones(1,length(twoEnvMice)),startedFiringAll(twoEnvMice,dpI),'.r','MarkerSize',18)
end
xlim([0.9 numDayPairs+0.1])
gg.Children.XTick = 1:numDayPairs;
nn = mat2cell(realDays{mouseI}(dayPairsForward),ones(1,numDayPairs),2);
gg.Children.XTickLabel = cellfun(@num2str,mat2cell(realDays{mouseI}(dayPairsForward),ones(1,numDayPairs),2),'UniformOutput',false);
xlabel('Day Pair')
ylabel('Pct. Cells that started firing')
%ylim([0 0.2])

%% Registration rate across day pairs
gg=figure; hold on
for dpI = 1:numDayPairs
    plot((dpI-0.05)*ones(1,length(oneEnvMice)),goodReg(oneEnvMice,dpI),'.b','MarkerSize',18)
    plot((dpI+0.05)*ones(1,length(twoEnvMice)),goodReg(twoEnvMice,dpI),'.r','MarkerSize',18)
end
xlim([0.9 numDayPairs+0.1])
gg.Children.XTick = 1:numDayPairs;
nn = mat2cell(realDays{mouseI}(dayPairsForward),ones(1,numDayPairs),2);
gg.Children.XTickLabel = cellfun(@num2str,mat2cell(realDays{mouseI}(dayPairsForward),ones(1,numDayPairs),2),'UniformOutput',false);
xlabel('Day Pair')
ylabel('Pct. Cells registered')
%ylim([0 0.2])


%% Cell Activity Demo


%load(fullfile(mainFolder,mice{1},'daybyday.mat'))
try
close(hh)
end

cellsPlot = [25 93 370 110 450 240 514 612 700];
durMins = 8;
duration = durMins*60*20-1;
tStart = 1.25*10000;
%cellsUse = [14 40 75 100 140 150 110];
lineOffset = 1.25;
hh = figure;
plotSpiking = 1;
for cellJ = 1:length(cellsPlot)
    hold on
    traceUse = daybyday.RawTrace{1}(cellsPlot(cellJ),tStart:tStart+duration);
    traceUse = traceUse - min(traceUse);
    traceUse = traceUse/max(traceUse);
    xplot = 1:duration+1;
    plot(xplot,traceUse+lineOffset*(cellJ-1),'LineWidth',1.5)
    if plotSpiking==1
        spikingUse = logical(daybyday.PSAbool{1}(cellsPlot(cellJ),tStart:tStart+duration));
        plot(xplot(spikingUse),traceUse(spikingUse)+lineOffset*(cellJ-1),'.r','MarkerSize',12)
    end
end
title('Fluoresence Over Time')
xlabel('Minutes')
hh.Children.XLim = [0 durMins*1000];
hh.Children.YTick = 0.5+1.25*(0:length(cellsPlot)-1);
hh.Children.YTickLabels = cellfun(@num2str,num2cell(1:length(cellsPlot)),'UniformOutput',false);
hh.Children.XTick = [1 (2:2:durMins)*1000];
hh.Children.XTickLabels =  cellfun(@num2str,num2cell([0 (2:2:durMins)]),'UniformOutput',false);
