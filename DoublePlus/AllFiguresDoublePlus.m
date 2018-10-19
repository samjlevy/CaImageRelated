%AllFiguresDoublePlus

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
for smouseI = 1:size(sameMice,1)
    plot(realDays{sameMice(smouseI)},accuracy{sameMice(smouseI)},'.b','MarkerSize',8)
    plot(realDays{sameMice(smouseI)},accuracy{sameMice(smouseI)},'b','LineWidth',1.5)
end
for dmouseI = 1:size(sameMice,1)
    plot(realDays{diffMice(dmouseI)},accuracy{diffMice(dmouseI)},'.r','MarkerSize',8)
    plot(realDays{diffMice(dmouseI)},accuracy{diffMice(dmouseI)},'r','LineWidth',1.5)
end 
xlim([0.5 9.5])
xlabel('Day Number')
ylabel('Performance')
title('Performance over time, b = same, r = diff')

load webPerformance.mat
figure; hold on
patch([3.5 6.5 6.5 3.5],[0.4 0.4 1.05 1.05],[0.9 0.7 0.1294],'EdgeColor','none','FaceAlpha',0.4)
for smouseI = 1:size(sameMice,1)
    plot(webPerformance(sameMice(smouseI),:),'.b','MarkerSize',8)
    plot(webPerformance(sameMice(smouseI),:),'b','LineWidth',2.5)
end
for dmouseI = 1:size(diffMice,1)
    plot(webPerformance(diffMice(dmouseI),:),'.r','MarkerSize',10)
    plot(webPerformance(diffMice(dmouseI),:),'r','LineWidth',2.5)
end 
xlim([0.95 9.05])
ylim([0.4 1.05])
xlabel('Day Number')
ylabel('Performance')
title('Performance over time, b = same, r = diff')

%% Sample dot/heatmaps

%load(fullfile(mainFolder,mice{1},'daybyday.mat'))

%cellsUse = 102; 141 272 378 1295 861 594 419 (all mouse 1)

cellsUse = notSameSplitters{1}{1}(notSameSplitters{1}{1}>400);

%plot dot plot
for cellI = 1:length(cellsUse)
    cellJ = cellsUse(cellI);

    hh=figure('Position',[65 398 1775 580]);
    for sessI = 1:3
        bStarts = []; bStops = [];
        %cellHere = cellSSI{mouseI}(cellJ,sessI);
        cellHere = cellJ;
        lapsFetch = [daybyday.behavior{sessI}(:).goodSequence] & [daybyday.behavior{sessI}(:).isCorrect];
        bStarts = [daybyday.behavior{sessI}(lapsFetch).startLap];
        bStops = [daybyday.behavior{sessI}(lapsFetch).endLap];

        xPos = []; yPos = []; PSAhere = [];
        for bI = 1:length(bStarts)
            xPos = [xPos daybyday.all_x_adj_cm{sessI}(bStarts(bI):bStops(bI))];
            yPos = [yPos daybyday.all_y_adj_cm{sessI}(bStarts(bI):bStops(bI))];
            PSAhere = [PSAhere daybyday.PSAbool{sessI}(cellHere,bStarts(bI):bStops(bI))];
        end
        PSAhere = logical(PSAhere);
        
        subplot(1,3,sessI)
        plot(xPos,yPos,'.k','MarkerSize',5)
        hold on
        plot(xPos(PSAhere),yPos(PSAhere),'.r','MarkerSize',8)
        axis equal
        xlim([-60 60])
        ylim([-60 60])
        title(['Day ' num2str(realDays{mouseI}(sessI))])
    end
    
    suptitleSL(['Mouse ' num2str(mouseI) ', cell ' num2str(cellJ)])
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

%% PV corr figure
%armAlignment = GetDoublePlusArmAlignment;
%condNames = {cellTBT{1}.name};
xBins = 1:numBins;

for dpI = 1:numDayPairs
figure; 
    for cpI = 1:4
        subplot(2,2,cpI); hold on
        allCorrsSame = sameMicePVcorrs{dpI,cpI};
        meanCorrSame = sameMicePVcorrsMeans{dpI,cpI};
        allCorrsDiff = diffMicePVcorrs{dpI,cpI};
        meanCorrDiff = diffMicePVcorrsMeans{dpI,cpI};

        if strcmpi(condNames{cnI},'west')
            allCorrsSame = fliplr(allCorrsSame); meanCorrSame = fliplr(meanCorrSame);
            allCorrsDiff = fliplr(allCorrsDiff); meanCorrDiff = fliplr(meanCorrDiff);
        end

        plot(repmat(xBins,length(sameMice),1),allCorrsSame,'.c','MarkerSize',8)
        plot(repmat(xBins,length(diffMice),1),allCorrsDiff,'.m','MarkerSize',8)

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


%% PVcorrHeatmap
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
        allCorrsSame = sameMiceTrimPVcorrs{dcI,dpI,cpI};
        meanCorrSame = sameMiceTrimPVcorrsMeans{dcI,dpI,cpI};
        allCorrsDiff = diffMiceTrimPVcorrs{dcI,dpI,cpI};
        meanCorrDiff = diffMiceTrimPVcorrsMeans{dcI,dpI,cpI};

        plot(repmat(xBins,length(sameMice),1),allCorrsSame,'.c','MarkerSize',4)
        plot(repmat(xBins,length(diffMice),1),allCorrsDiff,'.m','MarkerSize',4)

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

