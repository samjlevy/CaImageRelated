%% PV corrs plot

% Each group
locations = [0 0.5 1];
colors = [1.0000    0.0    0.000;
            1 1 1;
            0    0.45   0.74];           
newGradient = GradientMaker(colors,locations);

plotBins.X = []; plotBins.Y = [];
for condI = 1:4; plotBins.X = [plotBins.X; lgPlotHere{condI}.X]; plotBins.Y = [plotBins.Y; lgPlotHere{condI}.Y]; end 

corrsPlot = cell2mat(twoEnvMicePVcorrsMeans);
[figHand] = PlusMazePVcorrHeatmap3(corrsPlot,plotBins,newGradient,[0.4, -0.3]);
for dpI = 1:numDayPairs; subplot(1,numDayPairs,dpI); title(num2str(dayPairs(dpI,:))); [aa] = MakePlotPrettySL(gca); box on; end
suptitleSL('PV corrs for Two-Maze mice')

corrsPlot = cell2mat(oneEnvMicePVcorrsMeans);
[figHand] = PlusMazePVcorrHeatmap3(corrsPlot,plotBins,newGradient,[0.4, -0.3]);
for dpI = 1:numDayPairs; subplot(1,numDayPairs,dpI); title(num2str(dayPairs(dpI,:))); [aa] = MakePlotPrettySL(gca); box on; end
suptitleSL('PV corrs for One-Maze mice')

% Subtraction
locations = [0 0.5 1];
colors = [1.0000    1.0    1.000;
            1 0 0;
            0 0 0];
           
newGradient = GradientMaker(colors,locations);
dd =reshape(,256,1,3);
%figure; imagesc(dd)
corrsPlot = cell2mat(sameMinusDiff);
[figHand] = PlusMazePVcorrHeatmap3(corrsPlot,plotBins,'hot',[0.15, -0.25]);
for dpI = 1:numDayPairs; subplot(1,numDayPairs,dpI); title(num2str(dayPairs(dpI,:))); [aa] = MakePlotPrettySL(gca); box on; end
suptitleSL('Diff one maze - two maze')

%% Pooled COM change across arms

for dpI = 1:numDayPairs
    gg = figure;%('Position',[428 376 590 515]);%[428 613 897 278]
    
    yy = cdfplot(oneEnvCOMchanges{dpI}(:)); yy.Color = 'b'; yy.LineWidth = 2;
    hold on
    zz = cdfplot(twoEnvCOMchanges{dpI}(:)); zz.Color = 'r'; zz.LineWidth = 2; 
    %}
    % Log scale
    %{
    [yy,xxy] = ecdf(oneEnvCOMchanges{dpI}(:));
    [zz,xxz] = ecdf(twoEnvCOMchanges{dpI}(:));
    plot(log10(xxy),yy,'b','LineWidth',2)
    hold on
    plot(log10(xxz),zz,'r','LineWidth',2)
    xlim([-1 1])
    %}
    
    xlabel('CM change'); ylabel('Cumulative Proportion')
    %    title(condNames{condI})
        %xlim([0 1])
        %xx.XTick = [0 0.5 1]; xx.XTickLabel = {'0' num2str(numBins/2) num2str(numBins)};
        
    [p,h] = ranksum(oneEnvCOMchanges{dpI}(:),twoEnvCOMchanges{dpI}(:));
    [hKS,pKS] = kstest2(oneEnvCOMchanges{dpI}(:),twoEnvCOMchanges{dpI}(:));
    %text(4.5,0.5,['p=' num2str(round(p,3))])
    text(4.5,0.5,['RS p=' num2str(p)])
    text(4.5,0.65,['KS p=' num2str(pKS)])
    title(['Distribution of within-arm COM changes, day pair ' num2str(dayPairsForward(dpI,:))])
    
end

%% Pooled rate change across arms


for dpI = 1:numDayPairs
    gg = figure('Position'); %,[428 376 590 515]);%[428 613 897 278]
    
    changesHereOne = thingUseOne{dpI}; changesHereOne(oneEnvFiredEither{dpI}==0)=NaN;
    changesHereTwo = thingUseTwo{dpI}; changesHereTwo(twoEnvFiredEither{dpI}==0)=NaN;
    changesHereOne(changesHereOne==1) = NaN;
    changesHereTwo(changesHereTwo==1) = NaN;
    
    yy = cdfplot(changesHereOne(:)); yy.Color = 'b'; yy.LineWidth = 2;
    hold on
    zz = cdfplot(changesHereTwo(:)); zz.Color = 'r'; zz.LineWidth = 2; 
        
    xlabel(label(1:end-1))
    ylabel('Cumulative Proportion')
    %title(condNames{condI})
    %xlim([0 1])
    %xx.XTick = [0 0.5 1]; xx.XTickLabel = {'0' num2str(numBins/2) num2str(numBins)};
        
    [h,pKS] = kstest2(changesHereOne(:,condI),changesHereTwo(:,condI));
    [p,h] = ranksum(changesHereOne(:),changesHereTwo(:));
    text(0.4,0.5,['p=' num2str(round(p,3))])%'h=' num2str(h) ', 
    text(0.4,0.65,['KS p= ' num2str(pKS)])
    
    suptitleSL(['Distribution of within-arm ' label ', day pair ' num2str(dayPairsForward(dpI,:))])
    
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
    
    %plot((dpI-0.05)*ones(1,length(oneEnvMice)),oneEnvStoppedFiringPct(dpI),'.b','MarkerSize',18)
    %plot((dpI+0.05)*ones(1,length(twoEnvMice)),twoEnvStoppedFiringPct(dpI),'.r','MarkerSize',18)
    
    p = ranksum(stoppedFiringAll(oneEnvMice,dpI),stoppedFiringAll(twoEnvMice,dpI));
    text(dpI,0.18,['p= ' num2str(p)]) 
end
xlim([0.9 numDayPairs+0.1])
gg.Children.XTick = 1:numDayPairs;
nn = mat2cell(realDays{mouseI}(dayPairsForward),ones(1,numDayPairs),2);
gg.Children.XTickLabel = cellfun(@num2str,mat2cell(realDays{mouseI}(dayPairsForward),ones(1,numDayPairs),2),'UniformOutput',false);
xlabel('Day Pair')
ylabel('Pct. Cells that stopped firing')
ylim([0 0.2])

gg=figure; hold on
for dpI = 1:numDayPairs
    plot((dpI-0.05)*ones(1,length(oneEnvMice)),startedFiringAll(oneEnvMice,dpI),'.b','MarkerSize',18)
    plot((dpI+0.05)*ones(1,length(twoEnvMice)),startedFiringAll(twoEnvMice,dpI),'.r','MarkerSize',18)
    p = ranksum(startedFiringAll(oneEnvMice,dpI),startedFiringAll(twoEnvMice,dpI));
    text(dpI,0.2,['p= ' num2str(p)]) 
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
