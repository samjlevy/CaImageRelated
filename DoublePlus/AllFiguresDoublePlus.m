%AllFiguresDoublePlus
sepColors = [0.9 0.7 0.1; 0.6 0.1 0.2];
intColors = [0.3 0.75 0.9; 0 0.5 0.75];

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
 

saveFolder = 'G:\DoublePlus\SFNposter\cellDotplots';

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

        if strcmpi(condNames{cnI},'west')
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

for dpI = 1:size(dayPairs,1)
figHand = PlusMazePVcorrHeatmap({oneEnvMicePVcorrsMeans{dpI,:}},condNames,armAlignment,[],[],1);
title(['Mean 1-Env PV corrs, day pair ' num2str(dayPairs(dpI,:))])
end

for dpI = 1:size(dayPairs,1)
figHand = PlusMazePVcorrHeatmap({twoEnvMicePVcorrsMeans{dpI,:}},condNames,armAlignment,[],[],1);
title(['Mean 2-Env PV corrs, day pair ' num2str(dayPairs(dpI,:))])
end


%% PVcorrHeatmap subtraction
%Color scaling by positive or negative
%same - different: if different is higher, than score is negative; if
%different is lower, score is positive

for dpI = 1:size(dayPairs,1)
figHand = PlusMazePVcorrHeatmap({diffMinusSame{dpI,:}},condNames,armAlignment,{diffRank{dpI,:}},pThresh,1);
title(['Difference of Mean PV corrs, day pair ' num2str(dayPairs(dpI,:))])
end



%% PV corr by chunk of trials

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

for dcI = 1:numDayChunks
    for dpI = 1:size(dayPairs,1)
        figHand = PlusMazePVcorrHeatmap({sameMinusDiffTrim{dcI,dpI,:}},condNames,armAlignment,{diffRankTrim{dcI,dpI,:}},pThresh,1);
        title(['Difference of Mean PV corrs, day pair ' num2str(dayPairs(dpI,:)), ', dayChunk ' num2str(dayChunks(dcI,:))])
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
plot(pooledSplitterProps{1}(oneEnvMice,:),'.','Color',intColors(1,:),'MarkerSize',8)
plot(pooledSplitterProps{2}(oneEnvMice,:),'.','Color',intColors(2,:),'MarkerSize',8)
plot(pooledSplitterProps{1}(twoEnvMice,:),'.','Color',sepColors(1,:),'MarkerSize',8)
plot(pooledSplitterProps{2}(twoEnvMice,:),'.','Color',sepColors(2,:),'MarkerSize',8)
p1=plot(mean(pooledSplitterProps{1}(oneEnvMice,:),1),'Color',intColors(1,:),'LineWidth',2);
p2=plot(mean(pooledSplitterProps{2}(oneEnvMice,:),1),'Color',intColors(2,:),'LineWidth',2);
p3=plot(mean(pooledSplitterProps{1}(twoEnvMice,:),1),'Color',sepColors(1,:),'LineWidth',2);
p4=plot(mean(pooledSplitterProps{2}(twoEnvMice,:),1),'Color',sepColors(2,:),'LineWidth',2);
legend([p1 p2 p3 p4],['int ' groupNames{1}],['int ' groupNames{2}],['sep ' groupNames{1}],['sep ' groupNames{2}],'location','east')
ylim([0.5 1]); ylabel('Proportion of Cells'); xlabel('Day Number')
%hh.XTick = [0 0.5 1]; 
hh.XTickLabel = {'3' '7' '8'};

hh=subplot(1,3,2); hold on
plot(pooledSplitterProps{3}(oneEnvMice,:),'.','Color',intColors(1,:),'MarkerSize',8)
plot(pooledSplitterProps{4}(oneEnvMice,:),'.','Color',intColors(2,:),'MarkerSize',8)
plot(pooledSplitterProps{3}(twoEnvMice,:),'.','Color',sepColors(1,:),'MarkerSize',8)
plot(pooledSplitterProps{4}(twoEnvMice,:),'.','Color',sepColors(2,:),'MarkerSize',8)
p1=plot(mean(pooledSplitterProps{3}(oneEnvMice,:),1),'Color',intColors(1,:),'LineWidth',2);
p2=plot(mean(pooledSplitterProps{4}(oneEnvMice,:),1),'Color',intColors(2,:),'LineWidth',2);
p3=plot(mean(pooledSplitterProps{3}(twoEnvMice,:),1),'Color',sepColors(1,:),'LineWidth',2);
p4=plot(mean(pooledSplitterProps{4}(twoEnvMice,:),1),'Color',sepColors(2,:),'LineWidth',2);
legend([p1 p2 p3 p4],['int ' groupNames{3}],['int ' groupNames{4}],['sep ' groupNames{3}],['sep ' groupNames{4}],'location','east')
ylim([0 0.5]); ylabel('Proportion of Cells'); xlabel('Day Number')
%hh.XTick = [0 0.5 1]; 
hh.XTickLabel = {'3' '7' '8'};

hh=subplot(1,3,3); hold on
plot(pooledSplitterProps{5}(oneEnvMice,:),'.','Color',intColors(1,:),'MarkerSize',8)
plot(pooledSplitterProps{6}(oneEnvMice,:),'.','Color',intColors(2,:),'MarkerSize',8)
plot(pooledSplitterProps{5}(twoEnvMice,:),'.','Color',sepColors(1,:),'MarkerSize',8)
plot(pooledSplitterProps{6}(twoEnvMice,:),'.','Color',sepColors(2,:),'MarkerSize',8)
p1=plot(mean(pooledSplitterProps{5}(oneEnvMice,:),1),'Color',intColors(1,:),'LineWidth',2);
p2=plot(mean(pooledSplitterProps{6}(oneEnvMice,:),1),'Color',intColors(2,:),'LineWidth',2);
p3=plot(mean(pooledSplitterProps{5}(twoEnvMice,:),1),'Color',sepColors(1,:),'LineWidth',2);
p4=plot(mean(pooledSplitterProps{6}(twoEnvMice,:),1),'Color',sepColors(2,:),'LineWidth',2);
legend([p1 p2 p3 p4],['int ' groupNames{5}],['int ' groupNames{6}],['sep ' groupNames{5}],['sep ' groupNames{6}],'location','east')
ylim([0 1]); ylabel('Proportion of Cells'); xlabel('Day Number')
%hh.XTick = [0 0.5 1]; 
hh.XTickLabel = {'3' '7' '8'};

suptitleSL('Proportion of splitting type by group')







