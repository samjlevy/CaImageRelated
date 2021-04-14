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
%dd =reshape(,256,1,3);
%figure; imagesc(dd)
corrsPlot = cell2mat(sameMinusDiff);
[figHand] = PlusMazePVcorrHeatmap3(corrsPlot,plotBins,'hot',[0.15, -0.25]);
for dpI = 1:numDayPairs; subplot(1,numDayPairs,dpI); title(num2str(dayPairs(dpI,:))); [aa] = MakePlotPrettySL(gca); box on; end
suptitleSL('Diff one maze - two maze')


% OneMaze, north/west changes more than south east
% Pools across all mice
for dpI = 1:numDayPairs
    for condI = 2:numConds
        dataA = oneEnvMicePVcorrs{dpI,1}(:);
        dataB = oneEnvMicePVcorrs{dpI,condI}(:);
        
        pp = ranksum(dataA,dataB);
        [~,pp] = kstest2(dataA,dataB);
        
        disp([num2str(mean(dataA)) '+/-' num2str(std(dataA)) '   ---   ' num2str(mean(dataB)) '+/-' num2str(std(dataB))])
        disp(['For days ' num2str(dayPairs(dpI,:)) ' N vs ' armLabels{condI} ', p = ' num2str(pp)])
        
    end
end

for mouseI = 1:3
    disp(['mouse ' num2str(mouseI)])
for dpI = 1:numDayPairs
    for condI = 2:numConds
        dataA = oneEnvMicePVcorrs{dpI,1}(mouseI,:);
        dataB = oneEnvMicePVcorrs{dpI,condI}(mouseI,:);
        
        pp = ranksum(dataA,dataB);
        
        disp(['For days ' num2str(dayPairs(dpI,:)) ' N vs ' armLabels{condI} ', p = ' num2str(pp)])
        ) '+/-' std(dataB)])
    end
end
end

%% Pooled COM change across arms

for dpI = 1:numDayPairs
    gg = figure;%('Position',[428 376 590 515]);%[428 613 897 278]
    
    %oneData = oneEnvCOMchanges{dpI}(:);
    oneData = oneEnvCOMchanges{dpI}(oneEnvCOMchangesCellsUse{dpI});
    
    yy = cdfplot(oneData); 
    yy.Color = groupColors{1}; %yy.Color = 'b';
    yy.LineWidth = 2;
    hold on
    %twoData = twoEnvCOMchanges{dpI}(:);
    twoData = twoEnvCOMchanges{dpI}(twoEnvCOMchangesCellsUse{dpI});
    zz = cdfplot(twoData); 
    zz.Color = groupColors{2}; %zz.Color = 'r'; 
    zz.LineWidth = 2; 
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
    
    xlabel('COM change'); ylabel('Cumulative Proportion')
    %    title(condNames{condI})
        %xlim([0 1])
        %xx.XTick = [0 0.5 1]; xx.XTickLabel = {'0' num2str(numBins/2) num2str(numBins)};
        
    [p,h] = ranksum(oneData,twoData);
    [hKS,pKS] = kstest2(oneData,twoData);
    %text(4.5,0.5,['p=' num2str(round(p,3))])
    text(4.5,0.5,['RS p=' num2str(p)])
    text(4.5,0.65,['KS p=' num2str(pKS)])
    title(['Distribution of within-arm COM changes, day pair ' num2str(dayPairsForward(dpI,:))])
    
end

% Each condition individually
for dpI = 1:numDayPairs
    gg = figure;%('Position',[428 376 590 515]);%[428 613 897 278]
    
    for condI = 1:numConds
        subplot(2,2,condI)
    
        oneData = oneEnvCOMchanges{dpI}(:,condI);
        oneCells = oneEnvCOMchangesCellsUse{dpI}(:,condI);
        
        oneData = oneData(oneCells);
        
        twoData = twoEnvCOMchanges{dpI}(:,condI);
        twoCells = twoEnvCOMchangesCellsUse{dpI}(:,condI);
        
        twoData = twoData(twoCells);
    
        yy = cdfplot(oneData); 
        yy.Color = groupColors{1}; %yy.Color = 'b';
        yy.LineWidth = 2;
        hold on
        zz = cdfplot(twoData); 
        zz.Color = groupColors{2}; %zz.Color = 'r'; 
        zz.LineWidth = 2; 
    
        xlabel('COM change'); ylabel('Cumulative Proportion')

        [p,h] = ranksum(oneData,twoData);
        [hKS,pKS] = kstest2(oneData,twoData);
        text(4.5,0.5,['RS p=' num2str(p)])
        text(4.5,0.65,['KS p=' num2str(pKS)])
        title(['COM change cond ' num2str(condI)])
        %title(['Distribution of within-arm COM changes, day pair ' num2str(dayPairsForward(dpI,:))])
    end
end


% Greater N-W than S-E
for dpI = 1:numDayPairs
    gg = figure;%('Position');
    
    oneCOM = oneEnvCOMchanges{dpI};
    oneCells = oneEnvCOMchangesCellsUse{dpI};
    
    nwOne = oneCOM(:,[1 2]); 
    nwOneCells = oneCells(:,[1 2]);
    
    seOne = oneCOM(:,[3 4]);
    seOneCells = oneCells(:,[3 4]);
    
    %NWoneData = nwOne(:);
    NWoneData = nwOne(nwOneCells);
    %SEoneData = seOne(:);
    SEoneData = seOne(seOneCells);
    
    yy = cdfplot(NWoneData); 
    yy.Color = groupColors{1}; %yy.Color = 'b';
    yy.LineWidth = 2;
    yy.LineStyle = '--';
    yy.DisplayName = 'NW';
    hold on
    zz = cdfplot(SEoneData); 
    zz.Color = groupColors{1}; %zz.Color = 'r'; 
    zz.LineWidth = 2; 
    zz.LineStyle = ':';
    zz.DisplayName = 'SE';
    
    xlabel('COM change'); ylabel('Cumulative Proportion')
    [p,h] = ranksum(NWoneData,SEoneData);
    [hKS,pKS] = kstest2(NWoneData,SEoneData);
    %text(4.5,0.5,['p=' num2str(round(p,3))])
    text(4.5,0.5,['RS p=' num2str(p)])
    text(4.5,0.65,['KS p=' num2str(pKS)])
    legend
    
    title(['Distribution of within-arm COM changes, OneMaze, day pair ' num2str(dayPairsForward(dpI,:))])
end

% Greater N than each other
for dpI = 1:numDayPairs
    gg = figure;%('Position');
    
    oneCOM = oneEnvCOMchanges{dpI};
    oneCells = oneEnvCOMchangesCellsUse{dpI}; % above lap activity threshold
    
    for condI = 2:4
        subplot(1,3,condI-1)
        
        nwOne = oneCOM(:,[1]); 
        nwOneCells = oneCells(:,[1]);

        seOne = oneCOM(:,[condI]);
        seOneCells = oneCells(:,[condI]);

        %NWoneData = nwOne(:);
        NWoneData = nwOne(nwOneCells);
        %SEoneData = seOne(:);
        SEoneData = seOne(seOneCells);

        yy = cdfplot(NWoneData); 
        yy.Color = groupColors{1}; %yy.Color = 'b';
        yy.LineWidth = 2;
        yy.LineStyle = '--';
        yy.DisplayName = 'N';
        hold on
        zz = cdfplot(SEoneData); 
        zz.Color = groupColors{1}; %zz.Color = 'r'; 
        zz.LineWidth = 2; 
        zz.LineStyle = ':';
        zz.DisplayName = turnArmLabels{condI};

        xlabel('COM change'); ylabel('Cumulative Proportion')
        [p,h] = ranksum(NWoneData,SEoneData);
        [hKS,pKS] = kstest2(NWoneData,SEoneData);
        %text(4.5,0.5,['p=' num2str(round(p,3))])
        text(4.5,0.5,['RS p=' num2str(p)])
        text(4.5,0.65,['KS p=' num2str(pKS)])
        legend

        title(['Distribution of within-arm COM changes, OneMaze, day pair ' num2str(dayPairsForward(dpI,:))])
    end
end

% Same cell remaps more?
for dpI = 1:numDayPairs
    gg = figure;%('Position');
    
    oneCOM = oneEnvCOMchanges{dpI};
    oneCells = oneEnvCOMchangesCellsUse{dpI};
    anyActivity = ~isnan(oneCOM);
    
    for condI = 2:4
        subplot(1,3,condI-1)
        cellsActiveBoth = anyActivity(:,1) & anyActivity(:,condI);
        
        nOne = oneCOM(:,[1]); 
        nOneCells = oneCells(:,[1]) & cellsActiveBoth;
    
        otherOne = oneCOM(:,[condI]);
        otherOneCells = oneCells(:,[condI]) & cellsActiveBoth;
    
        nOneData = nOne(nOneCells);
        otherOneData = otherOne(otherOneCells);
    
        yy = cdfplot(nOneData); 
        yy.Color = groupColors{1}; %yy.Color = 'b';
        yy.LineWidth = 2;
        yy.LineStyle = '--';
        yy.DisplayName = 'N';
        hold on
        zz = cdfplot(otherOneData); 
        zz.Color = groupColors{1}; %zz.Color = 'r'; 
        zz.LineWidth = 2; 
        zz.LineStyle = ':';
        zz.DisplayName = turnArmLabels{condI};

        xlabel('COM change'); ylabel('Cumulative Proportion')
        [p,h] = ranksum(nOneData,otherOneData);
        [hKS,pKS] = kstest2(nOneData,otherOneData);
        %text(4.5,0.5,['p=' num2str(round(p,3))])
        text(4.5,0.5,['RS p=' num2str(p)])
        text(4.5,0.65,['KS p=' num2str(pKS)])
        legend
        
        title(['Same cells remapping, ' num2str(sum(nOneData > otherOneData)/length(nOneData))])
    end
end
%% Pooled rate change across arms

 %thingUseOne = oneEnvMeanRatePctChange;
 %thingUseTwo = twoEnvMeanRatePctChange;
 label = 'mean firing rate pct changes';
for dpI = 1:numDayPairs
    gg = figure;%('Position'); %,[428 376 590 515]);%[428 613 897 278]
    
    oneCellsUse = oneEnvMaxRateCellsUse{dpI}; % This adds the >=3 laps one day; says max but it's the same
    changesHereOne = oneEnvMeanRatePctChange{dpI}; 
    %changesHereOne(oneEnvFiredEither{dpI}==0) = NaN; % Forces it to have fired on both days in the arm
        % This might be unnecessary...
    %changesHereOne(changesHereOne==1) = NaN;
    changesHereOne(oneEnvFiredBoth{dpI}==0) = NaN;
    %oneData = changesHereOne;
    oneData = changesHereOne(oneCellsUse);
    
    twoCellsUse = twoEnvMaxRateCellsUse{dpI}; 
    changesHereTwo = twoEnvMeanRatePctChange{dpI}; 
    %changesHereTwo(twoEnvFiredEither{dpI}==0) = NaN;
    %changesHereTwo(changesHereTwo==1) = NaN;
    changesHereTwo(twoEnvFiredBoth{dpI}==0) = NaN;
    %twoData = changesHereTwo;
    twoData = changesHereTwo(twoCellsUse);
    
    yy = cdfplot(oneData(:)); yy.Color = groupColors{1}; 
    yy.LineWidth = 2;
    hold on
    zz = cdfplot(twoData(:)); zz.Color = groupColors{2}; 
    zz.LineWidth = 2; 
        
    xlabel(label(1:end-1))
    ylabel('Cumulative Proportion')
    %title(condNames{condI})
    %xlim([0 1])
    %xx.XTick = [0 0.5 1]; xx.XTickLabel = {'0' num2str(numBins/2) num2str(numBins)};
        
    [h,pKS] = kstest2(oneData(:),twoData(:));
    [p,h] = ranksum(oneData(:),twoData(:));
    text(0.4,0.5,['ranksum p=' num2str(round(p,3))])%'h=' num2str(h) ', 
    text(0.4,0.65,['KS p= ' num2str(pKS)])
    
    suptitleSL(['Distribution of within-arm ' label ', day pair ' num2str(dayPairsForward(dpI,:))])
    
    %print(fullfile(saveFolder,['COMchangeKS' num2str(dpI)]),'-dpdf') 
    %close(gg)
end
    
% Individual arms
for dpI = 1:numDayPairs
    gg = figure;%('Position'); %,[428 376 590 515]);%[428 613 897 278]
    
    for condI = 1:numConds
        subplot(2,2,condI)
        oneCellsUse = oneEnvMaxRateCellsUse{dpI}(:,condI); % This adds the >=3 laps one day; says max but it's the same
        changesHereOne = oneEnvMeanRatePctChange{dpI}(:,condI); 
        changesHereOne(oneEnvFiredBoth{dpI}(:,condI)==0) = NaN;
        oneData = changesHereOne(oneCellsUse);

        twoCellsUse = twoEnvMaxRateCellsUse{dpI}(:,condI); 
        changesHereTwo = twoEnvMeanRatePctChange{dpI}(:,condI); 
        changesHereTwo(twoEnvFiredBoth{dpI}(:,condI)==0) = NaN;
        twoData = changesHereTwo(twoCellsUse);

        yy = cdfplot(oneData(:)); yy.Color = groupColors{1}; 
        yy.LineWidth = 2;
        hold on
        zz = cdfplot(twoData(:)); zz.Color = groupColors{2}; 
        zz.LineWidth = 2; 

        xlabel(label(1:end-1))
        ylabel('Cumulative Proportion')

        [h,pKS,ksstats] = kstest2(oneData(:),twoData(:));
        [p,h] = ranksum(oneData(:),twoData(:));
        text(0.4,0.5,['ranksum p=' num2str(round(p,3))])%'h=' num2str(h) ', 
        text(0.4,0.65,['KS p= ' num2str(pKS)])
        text(0.4,0.8,['KS stat ' num2str(ksstats)])
        title(['Cond ' num2str(condI)])
    end
    
    suptitleSL(['Distribution of within-arm ' label ', day pair ' num2str(dayPairsForward(dpI,:))])
end

% More in North than others
for dpI = 1:numDayPairs
    gg = figure;%('Position'); %,[428 376 590 515]);%[428 613 897 278]
    
    for condI = 2:numConds
        subplot(1,numConds-1,condI-1)
        
        oneCellsUse = oneEnvMaxRateCellsUse{dpI}(:,condI); % This adds the >=3 laps one day; says max but it's the same
        changesHereOne = oneEnvMeanRatePctChange{dpI}(:,condI); 
        changesHereOne(oneEnvFiredBoth{dpI}(:,condI)==0) = NaN;
        oneData = changesHereOne(oneCellsUse);
        
        northCellsUse = oneEnvMaxRateCellsUse{dpI}(:,1);
        northChangesHereOne = oneEnvMeanRatePctChange{dpI}(:,1); 
        northChangesHereOne(oneEnvFiredBoth{dpI}(:,1)==0) = NaN;
        northData = northChangesHereOne(northCellsUse);
        
        yy = cdfplot(oneData(:)); yy.Color = groupColors{1}; 
        yy.LineWidth = 2;
        yy.LineStyle = ':';
        yy.DisplayName = turnArmLabels{condI};
        hold on
        zz = cdfplot(northData(:)); zz.Color = groupColors{1}; 
        zz.LineWidth = 2; 
        zz.LineStyle = '--';
        zz.DisplayName = 'N';

        xlabel(label(1:end-1))
        ylabel('Cumulative Proportion')

        [h,pKS,ksstats] = kstest2(oneData(:),northData(:));
        [p,h] = ranksum(oneData(:),northData(:));
        text(0.4,0.5,['ranksum p=' num2str(round(p,3))])%'h=' num2str(h) ', 
        text(0.4,0.65,['KS p= ' num2str(pKS)])
        text(0.4,0.8,['KS stat ' num2str(ksstats)])
        legend
        title(['Cond ' num2str(condI)])
    end
    
    suptitleSL(['Distribution of within-arm ' label ', day pair ' num2str(dayPairsForward(dpI,:))])
end

% Same cell more in North than others
for dpI = 1:numDayPairs
    gg = figure;%('Position'); %,[428 376 590 515]);%[428 613 897 278]
    
    
    for condI = 2:numConds
        subplot(1,numConds-1,condI-1)
        
        oneCellsUse = oneEnvMaxRateCellsUse{dpI}(:,condI) & oneEnvFiredBoth{dpI}(:,condI); 
            % This adds the >=3 laps one day; says max but it's the same
        changesHereOne = oneEnvMeanRatePctChange{dpI}(:,condI); 
        changesHereOne(oneEnvFiredBoth{dpI}(:,condI)==0) = NaN;
        
        northCellsUse = oneEnvMaxRateCellsUse{dpI}(:,1) & oneEnvFiredBoth{dpI}(:,1);
        northChangesHereOne = oneEnvMeanRatePctChange{dpI}(:,1); 
        northChangesHereOne(oneEnvFiredBoth{dpI}(:,1)==0) = NaN;
        
        bothCellsUse = oneCellsUse & northCellsUse;
        oneData = changesHereOne(bothCellsUse);
        northData = northChangesHereOne(bothCellsUse);
        
        yy = cdfplot(oneData(:)); yy.Color = groupColors{1}; 
        yy.LineWidth = 2;
        yy.LineStyle = ':';
        yy.DisplayName = turnArmLabels{condI};
        hold on
        zz = cdfplot(northData(:)); zz.Color = groupColors{1}; 
        zz.LineWidth = 2; 
        zz.LineStyle = '--';
        zz.DisplayName = 'N';

        xlabel(label(1:end-1))
        ylabel('Cumulative Proportion')

        [h,pKS,ksstats] = kstest2(oneData(:),northData(:));
        [p,h] = ranksum(oneData(:),northData(:));
        text(0.4,0.5,['ranksum p=' num2str(round(p,3))])%'h=' num2str(h) ', 
        text(0.4,0.65,['KS p= ' num2str(pKS)])
        text(0.4,0.8,['KS stat ' num2str(ksstats)])
        legend
        
        pctH = sum(northData > oneData) / length(northData);
        title(['Cond ' num2str(condI) ', pct greater ' num2str(pctH)])
    end
    
    suptitleSL(['Same cell comparisons rate changes' label ', day pair ' num2str(dayPairsForward(dpI,:))])
end
   


%% trialReliChange

for dpI = 1:numDayPairs
    figure;
    dataOne = abs(oneEnvReliChangeAll{dpI});
    dataTwo = abs(twoEnvReliChangeAll{dpI});
    yy = cdfplot(dataOne); 
    yy.Color = groupColors{1};
    yy.LineWidth = 2;
    hold on
        
    zz = cdfplot(dataTwo); 
    zz.Color = groupColors{2};
    zz.LineWidth = 2;
    
    xlabel('reli Change')
    ylabel('ECDF')
    title([num2str(dayPairsForward(dpI,:))])
    
    [h,pKS,ksstats] = kstest2(dataOne,dataTwo);
    [p,h] = ranksum(dataOne,dataTwo);
    text(0.4,0.5,['ranksum p=' num2str(round(p,3))])%'h=' num2str(h) ', 
    text(0.4,0.65,['KS p= ' num2str(pKS)])
    text(0.4,0.8,['KS stat ' num2str(ksstats)])
        
end

% Each arm individually
for dpI = 1:numDayPairs
    figure;
    for condI = 1:numConds
        subplot(2,2,condI)
        dataOne = abs(oneEnvReliChangeEach{dpI,condI});
        dataTwo = abs(twoEnvReliChangeEach{dpI,condI});
        yy = cdfplot(dataOne);
        yy.Color = groupColors{1};
        yy.LineWidth = 2;
        hold on
        
        zz = cdfplot(dataTwo);
        zz.Color = groupColors{2};
        zz.LineWidth = 2;
        
        xlabel('reli change')
        ylabel('ECDF')
        title([num2str(dayPairsForward(dpI,:))])
        
        [h,pKS,ksstats] = kstest2(dataOne,dataTwo);
        [p,h] = ranksum(dataOne,dataTwo);
        text(0.4,0.5,['ranksum p=' num2str(round(p,3))])%'h=' num2str(h) ',
        text(0.4,0.65,['KS p= ' num2str(pKS)])
        text(0.4,0.8,['KS stat ' num2str(ksstats)])
    end 
end

% oneMaze N more than others?
for dpI = 1:numDayPairs
    figure;
    for condI = 2:numConds
        subplot(1,3,condI-1)
        dataOne = abs(oneEnvReliChangeEach{dpI,1});
        dataTwo = abs(oneEnvReliChangeEach{dpI,condI});
        yy = cdfplot(dataOne);
        yy.Color = groupColors{1};
        yy.LineWidth = 2;
        yy.LineStyle = '--';
        hold on
        yy.DisplayName = 'n';
        
        zz = cdfplot(dataTwo);
        zz.Color = groupColors{1};
        zz.LineWidth = 2;
        zz.LineStyle = ':';
        zz.DisplayName = armLabels{condI};
        
        xlabel('reli change')
        ylabel('ECDF')
        title([num2str(dayPairsForward(dpI,:))])
        
        [h,pKS,ksstats] = kstest2(dataOne,dataTwo);
        [p,h] = ranksum(dataOne,dataTwo);
        text(0.4,0.5,['ranksum p=' num2str(round(p,3))])%'h=' num2str(h) ',
        text(0.4,0.65,['KS p= ' num2str(pKS)])
        text(0.4,0.8,['KS stat ' num2str(ksstats)])
    end 
end


%% Rate map corrs

for dpI = 1:numDayPairs
    figure;
    dataOne = abs(oneEnvCorrsAll{dpI});
    dataTwo = abs(twoEnvCorrsAll{dpI});
    yy = cdfplot(dataOne); 
    yy.Color = groupColors{1};
    yy.LineWidth = 2;
    hold on
        
    zz = cdfplot(dataTwo); 
    zz.Color = groupColors{2};
    zz.LineWidth = 2;
    
    xlabel('Rho')
    ylabel('ECDF')
    title([num2str(dayPairsForward(dpI,:))])
    
    [h,pKS,ksstats] = kstest2(dataOne,dataTwo);
    [p,h] = ranksum(dataOne,dataTwo);
    text(0.4,0.5,['ranksum p=' num2str(round(p,3))])%'h=' num2str(h) ', 
    text(0.4,0.65,['KS p= ' num2str(pKS)])
    text(0.4,0.8,['KS stat ' num2str(ksstats)])
        
end

% Each arm individually
for dpI = 1:numDayPairs
    figure;
    for condI = 1:numConds
        subplot(2,2,condI)
        dataOne = abs(oneEnvCorrsEach{dpI,condI});
        dataTwo = abs(twoEnvCorrsEach{dpI,condI});
        yy = cdfplot(dataOne);
        yy.Color = groupColors{1};
        yy.LineWidth = 2;
        hold on
        
        zz = cdfplot(dataTwo);
        zz.Color = groupColors{2};
        zz.LineWidth = 2;
        
        xlabel('Rho')
        ylabel('ECDF')
        title([num2str(dayPairsForward(dpI,:))])
        
        [h,pKS,ksstats] = kstest2(dataOne,dataTwo);
        [p,h] = ranksum(dataOne,dataTwo);
        text(0.4,0.5,['ranksum p=' num2str(round(p,3))])%'h=' num2str(h) ',
        text(0.4,0.65,['KS p= ' num2str(pKS)])
        text(0.4,0.8,['KS stat ' num2str(ksstats)])
    end 
end

% North vs. others
for dpI = 1:numDayPairs
    figure;
    for condI = 2:numConds
        subplot(1,numConds-1,condI-1)
        dataOne = abs(oneEnvCorrsEach{dpI,1});
        dataTwo = abs(twoEnvCorrsEach{dpI,condI});
        yy = cdfplot(dataOne);
        yy.Color = groupColors{1};
        yy.LineWidth = 2;
        yy.LineStyle = '--';
        yy.DisplayName = 'n';
        hold on
        
        zz = cdfplot(dataTwo);
        zz.Color = groupColors{1};
        zz.LineWidth = 2;
        zz.LineStyle = ':';
        zz.DisplayName = armLabels{condI};
        
        xlabel('Rho')
        ylabel('ECDF')
        title([num2str(dayPairsForward(dpI,:))])
        
        [h,pKS,ksstats] = kstest2(dataOne,dataTwo);
        [p,h] = ranksum(dataOne,dataTwo);
        text(0.4,0.5,['ranksum p=' num2str(round(p,3))])%'h=' num2str(h) ',
        text(0.4,0.65,['KS p= ' num2str(pKS)])
        text(0.4,0.8,['KS stat ' num2str(ksstats)])
        legend
    end 
end

% Pct pvals significant
gg=figure;
for dpI = 1:numDayPairs
    plot((dpI-0.05)*ones(1,length(oneEnvMice)),... 
    oneEnvCorrsPallPct{dpI},'.','MarkerSize',18,'MarkerFaceColor',groupColors{1},'MarkerEdgeColor',groupColors{1})
    hold on
    plot((dpI+0.05)*ones(1,length(twoEnvMice)),...
    twoEnvCorrsPallPct{dpI},'.','MarkerSize',18,'MarkerFaceColor',groupColors{2},'MarkerEdgeColor',groupColors{2})
end
gg.Children.XTickLabel = cellfun(@num2str,mat2cell(dayPairsForward,ones(1,numDayPairs),2),'UniformOutput',false);
xlabel('Day Pair')
ylabel(['Pct corrs p < ' num2str(pThresh)])

% Pct pvals significant each arm
for dpI = 1:numDayPairs
    gg=figure;
    for condI = 1:numConds
        subplot(2,2,condI)
        plot((dpI-0.05)*ones(1,length(oneEnvMice)),... 
        oneEnvCorrsPeachPct{dpI,condI},'.','MarkerSize',18,'MarkerFaceColor',groupColors{1},'MarkerEdgeColor',groupColors{1})
        hold on
        plot((dpI+0.05)*ones(1,length(twoEnvMice)),...
        twoEnvCorrsPeachPct{dpI,condI},'.','MarkerSize',18,'MarkerFaceColor',groupColors{2},'MarkerEdgeColor',groupColors{2})
    end
    %gg.Children.XTickLabel = cellfun(@num2str,mat2cell(dayPairsForward,ones(1,numDayPairs),2),'UniformOutput',false);
    suptitleSL([num2str(dayPairsForward(dpI,:))])
end


% Rate map whole maze
for dpI = 1:numDayPairs
    figure;
    dataOne = abs(oneEnvCorrsSingle{dpI});
    dataTwo = abs(twoEnvCorrsSingle{dpI});
    yy = cdfplot(dataOne); 
    yy.Color = groupColors{1};
    yy.LineWidth = 2;
    hold on
        
    zz = cdfplot(dataTwo); 
    zz.Color = groupColors{2};
    zz.LineWidth = 2;
    
    xlabel('Rho')
    ylabel('ECDF')
    title([num2str(dayPairsForward(dpI,:))])
    
    [h,pKS,ksstats] = kstest2(dataOne,dataTwo);
    [p,h] = ranksum(dataOne,dataTwo);
    text(0.4,0.5,['ranksum p=' num2str(round(p,3))])%'h=' num2str(h) ', 
    text(0.4,0.65,['KS p= ' num2str(pKS)])
    text(0.4,0.8,['KS stat ' num2str(ksstats)])  
end
%% Same arm max firing?

gg=figure; hold on
for dpI = 1:numDayPairs
    plot((dpI-0.05)*ones(1,length(oneEnvMice)),sameArmPct(oneEnvMice,dpI),'.','MarkerSize',18,'MarkerFaceColor',groupColors{1},'MarkerEdgeColor',groupColors{1})
    hold on
    plot((dpI+0.05)*ones(1,length(twoEnvMice)),sameArmPct(twoEnvMice,dpI),'.','MarkerSize',18,'MarkerFaceColor',groupColors{2},'MarkerEdgeColor',groupColors{2})
end
xlim([0.9 numDayPairs+0.1])
gg.Children.XTick = 1:numDayPairs;
nn = mat2cell(dayPairsForward,ones(1,numDayPairs),2);
gg.Children.XTickLabel = cellfun(@num2str,mat2cell(dayPairsForward,ones(1,numDayPairs),2),'UniformOutput',false);
xlabel('Day Pair')
ylabel('Pct. Cells with same arm max firing')

% Same preferred arm distribution
figure;
for dpI = 1:numDayPairs
    subplot(2,numDayPairs,dpI)
    histogram(oneEnvSameArmsID{dpI},'FaceColor',groupColors{1})
    title([num2str(dayPairsForward(dpI,:))])
    subplot(2,numDayPairs,dpI+numDayPairs)
    histogram(twoEnvSameArmsID{dpI},'FaceColor',groupColors{2})
end
suptitleSL('Distribution of ID of same preferred arm')

% Trial reli across arms
oneEnvTrialReli = cell(numConds,9);
twoEnvTrialReli = cell(numConds,9);
daysForward = unique(dayPairsForward(:));
for mouseI = 1:numMice
    anyReli = trialReli{mouseI} > 0;
    
    for dayI = 1:9 %length(daysForward)
        for condI = 1:numConds
            reliH = trialReli{mouseI}(:,dayI,condI);
            reliHH = reliH(anyReli(:,dayI,condI));
            
            switch groupNum(mouseI)
                case 1
                    oneEnvTrialReli{condI,dayI} = [oneEnvTrialReli{condI,dayI}; reliHH];
                case 2
                    twoEnvTrialReli{condI,dayI} = [twoEnvTrialReli{condI,dayI}; reliHH];
            end
        end
    end
end

figure;
for dayI = 1:length(daysForward)
    subplot(2,length(daysForward),dayI)
    for condI = 1:numConds
        yy = cdfplot(oneEnvTrialReli{condI,daysForward(dayI)}); 
        %yy.Color = groupColors{1}; 
        yy.LineWidth = 2;
        hold on
    end
    legend
    xlabel('Trial Reli')
    ylabel('ECDF')
    title([num2str(daysForward(dayI))])
    
    subplot(2,length(daysForward),dayI+length(daysForward))
    for condI = 1:numConds
        yy = cdfplot(twoEnvTrialReli{condI,daysForward(dayI)}); 
        %yy.Color = groupColors{1}; 
        yy.LineWidth = 2;
        hold on
    end
    legend
    xlabel('Trial Reli')
    ylabel('ECDF')
end
    
%% Diff num arms active/above thresh
for dpI = 1:numDayPairs
    figure;
    %dataOne = oneEnvDiffArmsActive{dpI};
    %dataTwo = twoEnvDiffArmsActive{dpI};
    
    dataOne = oneEnvDiffArmsAboveThresh{dpI};
    dataTwo = twoEnvDiffArmsAboveThresh{dpI};
    
    yy = cdfplot(dataOne); 
    yy.Color = groupColors{1};
    yy.LineWidth = 2;
    hold on
        
    zz = cdfplot(dataTwo); 
    zz.Color = groupColors{2};
    zz.LineWidth = 2;
    
    xlabel('Rho')
    ylabel('ECDF')
    title([num2str(dayPairsForward(dpI,:))])
    
    [h,pKS,ksstats] = kstest2(dataOne,dataTwo);
    [p,h] = ranksum(dataOne,dataTwo);
    text(0.4,0.5,['ranksum p=' num2str(round(p,3))])%'h=' num2str(h) ', 
    text(0.4,0.65,['KS p= ' num2str(pKS)])
    text(0.4,0.8,['KS stat ' num2str(ksstats)])
        
end


%% Newer stopped/started firing

% These won't work for Kerberos because have roi day 7, but no correct
% trials so below thresh
gg=figure; hold on
for dpI = 1:numDayPairs
    plot((dpI-0.05)*ones(1,3),oneEnvStoppedFiringAll{dpI},'.','MarkerSize',18,'MarkerFaceColor',groupColors{1})
    plot((dpI+0.05)*ones(1,3),twoEnvStoppedFiringAll{dpI},'.','MarkerSize',18,'MarkerFaceColor',groupColors{2})
    
    %p = ranksum(stoppedFiringAll(oneEnvMice,dpI),stoppedFiringAll(twoEnvMice,dpI));
    %text(dpI,0.18,['p= ' num2str(p)]) 
end
xlim([0.9 numDayPairs+0.1])
gg.Children.XTick = 1:numDayPairs;
gg.Children.XTickLabel = cellfun(@num2str,mat2cell(dayPairsForward,ones(1,numDayPairs),2),'UniformOutput',false);
xlabel('Day Pair')
ylabel('Pct. Cells that stopped firing')
%ylim([0 0.2])

% Each arm
for dpI = 1:numDayPairs
    gg=figure; hold on
    for condI = 1:numConds
        subplot(2,2,condI)
        plot((dpI-0.05)*ones(1,3),oneEnvStoppedFiringEach{dpI},'.','MarkerSize',18,'MarkerFaceColor',groupColors{1},'MarkerEdgeColor',groupColors{1})
        hold on
        plot((dpI+0.05)*ones(1,3),twoEnvStoppedFiringEach{dpI},'.','MarkerSize',18,'MarkerFaceColor',groupColors{2},'MarkerEdgeColor',groupColors{2})
    end
    %p = ranksum(stoppedFiringAll(oneEnvMice,dpI),stoppedFiringAll(twoEnvMice,dpI));
    %text(dpI,0.18,['p= ' num2str(p)]) 
end
    

gg=figure; hold on
for dpI = 1:numDayPairs
    plot((dpI-0.05)*ones(1,3),oneEnvStartedFiringAll{dpI},'.','MarkerSize',18,'MarkerFaceColor',groupColors{1})
    plot((dpI+0.05)*ones(1,3),twoEnvStartedFiringAll{dpI},'.','MarkerSize',18,'MarkerFaceColor',groupColors{2})
    
    %p = ranksum(stoppedFiringAll(oneEnvMice,dpI),stoppedFiringAll(twoEnvMice,dpI));
    %text(dpI,0.18,['p= ' num2str(p)]) 
end
xlim([0.9 numDayPairs+0.1])
gg.Children.XTick = 1:numDayPairs;
gg.Children.XTickLabel = cellfun(@num2str,mat2cell(dayPairsForward,ones(1,numDayPairs),2),'UniformOutput',false);
xlabel('Day Pair')
ylabel('Pct. Cells that stopped firing')
%ylim([0 0.2])

% Each arm

for dpI = 1:numDayPairs
    gg=figure; hold on
    for condI = 1:numConds
        subplot(2,2,condI)
        plot((dpI-0.05)*ones(1,3),oneEnvStartedFiringEach{dpI},'.','MarkerSize',18,'MarkerFaceColor',groupColors{1},'MarkerEdgeColor',groupColors{1})
        hold on
        plot((dpI+0.05)*ones(1,3),twoEnvStartedFiringEach{dpI},'.','MarkerSize',18,'MarkerFaceColor',groupColors{2},'MarkerEdgeColor',groupColors{2})
    end
    %p = ranksum(stoppedFiringAll(oneEnvMice,dpI),stoppedFiringAll(twoEnvMice,dpI));
    %text(dpI,0.18,['p= ' num2str(p)]) 
end
%% Totally stopped/started firing

% Result here depends on how denominator is counted, numCells that animal
% vs. cells that were active at all both days

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
gg.Children.XTickLabel = cellfun(@num2str,mat2cell(dayPairsForward,ones(1,numDayPairs),2),'UniformOutput',false);
xlabel('Day Pair')
ylabel('Pct. Cells that stopped firing')
%ylim([0 0.2])

gg=figure; hold on
for dpI = 1:numDayPairs
    plot((dpI-0.05)*ones(1,length(oneEnvMice)),startedFiringAll(oneEnvMice,dpI),'.b','MarkerSize',18)
    plot((dpI+0.05)*ones(1,length(twoEnvMice)),startedFiringAll(twoEnvMice,dpI),'.r','MarkerSize',18)
    p = ranksum(startedFiringAll(oneEnvMice,dpI),startedFiringAll(twoEnvMice,dpI));
    text(dpI,0.2,['p= ' num2str(p)]) 
end
xlim([0.9 numDayPairs+0.1])
gg.Children.XTick = 1:numDayPairs;
gg.Children.XTickLabel = cellfun(@num2str,mat2cell(dayPairsForward,ones(1,numDayPairs),2),'UniformOutput',false);
xlabel('Day Pair')
ylabel('Pct. Cells that started firing')
%ylim([0 0.2])

% Each cond independently

gg=figure; hold on
for dpI = 1:numDayPairs
    for condI = 1:numConds
        subplot(2,2,condI)
        plot((dpI-0.05)*ones(1,length(oneEnvMice)),stoppedFiringAllEach{condI}(oneEnvMice,dpI),'.b','MarkerSize',18)
        hold on
        plot((dpI+0.05)*ones(1,length(twoEnvMice)),stoppedFiringAllEach{condI}(twoEnvMice,dpI),'.r','MarkerSize',18)

    %plot((dpI-0.05)*ones(1,length(oneEnvMice)),oneEnvStoppedFiringPct(dpI),'.b','MarkerSize',18)
    %plot((dpI+0.05)*ones(1,length(twoEnvMice)),twoEnvStoppedFiringPct(dpI),'.r','MarkerSize',18)
    
    p = ranksum(stoppedFiringAllEach{condI}(oneEnvMice,dpI),stoppedFiringAllEach{condI}(twoEnvMice,dpI));
    text(dpI,0.18,['p= ' num2str(p)]) 
    end
end
xlabel('Day Pair')
ylabel('Pct. Cells that stopped firing')
xlim([0.9 numDayPairs+0.1])
gg.Children.XTick = 1:numDayPairs;
gg.Children.XTickLabel = cellfun(@num2str,mat2cell(dayPairsForward,ones(1,numDayPairs),2),'UniformOutput',false);

gg=figure;
for dpI = 1:numDayPairs
    for condI = 1:numConds
        subplot(2,2,condI)
        plot((dpI-0.05)*ones(1,length(oneEnvMice)),startedFiringAllEach{condI}(oneEnvMice,dpI),'.b','MarkerSize',18)
        hold on
        plot((dpI+0.05)*ones(1,length(twoEnvMice)),startedFiringAllEach{condI}(twoEnvMice,dpI),'.r','MarkerSize',18)

    %plot((dpI-0.05)*ones(1,length(oneEnvMice)),oneEnvStoppedFiringPct(dpI),'.b','MarkerSize',18)
    %plot((dpI+0.05)*ones(1,length(twoEnvMice)),twoEnvStoppedFiringPct(dpI),'.r','MarkerSize',18)
    
    p = ranksum(startedFiringAllEach{condI}(oneEnvMice,dpI),startedFiringAllEach{condI}(twoEnvMice,dpI));
    text(dpI,0.18,['p= ' num2str(p)]) 
    end
end
xlabel('Day Pair')
ylabel('Pct. Cells that started firing')

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

%% Relationship between remapping and activity rate

% Whole maze
oneEnvRemapReli = cell(1,numDayPairs); oneEnvRemapRho = cell(1,numDayPairs); oneEnvRemapP = cell(1,numDayPairs);
twoEnvRemapReli = cell(1,numDayPairs); twoEnvRemapRho = cell(1,numDayPairs); twoEnvRemapP = cell(1,numDayPairs);

oneEnvRemapReliEach = cell(numDayPairs,numConds); oneEnvRemapRhoEach = cell(numDayPairs,numConds); oneEnvRemapPEach = cell(numDayPairs,numConds);
twoEnvRemapReliEach = cell(numDayPairs,numConds); twoEnvRemapRhoEach = cell(numDayPairs,numConds); twoEnvRemapPEach = cell(numDayPairs,numConds);
for mouseI = 1:numMice
    for dpI = 1:numDayPairs
        haveCellBothDays = sum(cellSSI{mouseI}(:,dayPairsForward(dpI,:))>0,2)==2;
        %aboveThreshOneDay = sum(dayUseAll{mouseI}(:,dayPairsForward(dpI,:)),2) >= 1;
        firedOnMazeOneDays = sum(trialReliAll{mouseI}(:,dayPairsForward(dpI,:))>0,2) >= 1;
        firedOnMazeBothDays = sum(trialReliAll{mouseI}(:,dayPairsForward(dpI,:))>0,2) == 2;
        
        reliAllH = trialReliAll{mouseI}(:,dayPairsForward(dpI,1));
        
        cellsUseH = haveCellBothDays & firedOnMazeBothDays; %& aboveThreshOneDay;
        switch groupNum(mouseI)
            case 1
                oneEnvRemapReli{dpI} = [oneEnvRemapReli{dpI}; reliAllH(cellsUseH)];
                oneEnvRemapRho{dpI} = [oneEnvRemapRho{dpI}; singleCellAllCorrsRho{mouseI}{1}{dpI}(cellsUseH)];
                oneEnvRemapP{dpI} = [oneEnvRemapP{dpI}; singleCellAllCorrsP{mouseI}{1}{dpI}(cellsUseH)];
            case 2
                twoEnvRemapReli{dpI} = [twoEnvRemapReli{dpI}; reliAllH(cellsUseH)];
                twoEnvRemapRho{dpI} = [twoEnvRemapRho{dpI}; singleCellAllCorrsRho{mouseI}{1}{dpI}(cellsUseH)];
                twoEnvRemapP{dpI} = [twoEnvRemapP{dpI}; singleCellAllCorrsP{mouseI}{1}{dpI}(cellsUseH)];
        end
        
        for condI = 1:numConds
            if numSessTrials{mouseI}(dayPairsForward(dpI,1),condI) > 1
            firedOnMazeOneDays = sum(trialReli{mouseI}(:,dayPairsForward(dpI,:),condI)>0,2) >= 1;
            firedOnMazeBothDays = sum(trialReli{mouseI}(:,dayPairsForward(dpI,:),condI)>0,2) == 2;
            
            % Need something here to kick out cond with less than 1 trial
            
            
            reliAllH = trialReli{mouseI}(:,dayPairsForward(dpI,1),condI);
            cellsUseH = haveCellBothDays & firedOnMazeBothDays;
            switch groupNum(mouseI)
                case 1
                    oneEnvRemapReliEach{dpI,condI} = [oneEnvRemapReliEach{dpI,condI}; reliAllH(cellsUseH)];
                    oneEnvRemapRhoEach{dpI,condI} = [oneEnvRemapRhoEach{dpI,condI}; singleCellCorrsRho{mouseI}{condI}{dpI}(cellsUseH)];
                    oneEnvRemapPEach{dpI,condI} = [oneEnvRemapPEach{dpI,condI}; singleCellCorrsP{mouseI}{condI}{dpI}(cellsUseH)];
                case 2
                    twoEnvRemapReliEach{dpI,condI} = [twoEnvRemapReliEach{dpI,condI}; reliAllH(cellsUseH)];
                    twoEnvRemapRhoEach{dpI,condI} = [twoEnvRemapRhoEach{dpI,condI}; singleCellCorrsRho{mouseI}{condI}{dpI}(cellsUseH)];
                    twoEnvRemapPEach{dpI,condI} = [twoEnvRemapPEach{dpI,condI}; singleCellCorrsP{mouseI}{condI}{dpI}(cellsUseH)];
            end
            
            end
        end
    end
end

% Whole maze
for dpI = 1:numDayPairs
    figure;
    subplot(1,2,1)
    %yData = oneEnvRemapRho{dpI};
    yData = oneEnvRemapP{dpI};
    plot(oneEnvRemapReli{dpI},yData,'.','MarkerFaceColor',groupColors{1},'MarkerEdgeColor',groupColors{1})
    xlabel('trialReli'); ylabel('rho');
    [rr,pp] = corr(oneEnvRemapReli{dpI},yData,'type','Spearman');
    title(['p=' num2str(pp) ' rho=' num2str(rr)])
    
    subplot(1,2,2)
    %yData = twoEnvRemapRho{dpI};
    yData = twoEnvRemapP{dpI};
    plot(twoEnvRemapReli{dpI},yData,'.','MarkerFaceColor',groupColors{2},'MarkerEdgeColor',groupColors{2})
    xlabel('trialReli'); ylabel('rho');
    [rr,pp] = corr(twoEnvRemapReli{dpI},yData,'type','Spearman');
    title(['p=' num2str(pp) ' rho=' num2str(rr)])
    
    suptitleSL(num2str(dayPairsForward(dpI,:)))
end

%Each Cond
for dpI = 1:numDayPairs
    figure;
    for condI = 1:numConds
        subplot(2,4,condI*2-1)
        plot(oneEnvRemapReliEach{dpI,condI},oneEnvRemapRhoEach{dpI,condI},'.','MarkerFaceColor',groupColors{1},'MarkerEdgeColor',groupColors{1})
        xlabel('trialReli'); ylabel('rho');
        [rr,pp] = corr(oneEnvRemapReliEach{dpI,condI},oneEnvRemapRhoEach{dpI,condI},'type','Spearman');
        title(['p=' num2str(pp) ' rho=' num2str(rr)])

        subplot(2,4,condI*2)
        plot(twoEnvRemapReliEach{dpI,condI},twoEnvRemapRhoEach{dpI,condI},'.','MarkerFaceColor',groupColors{2},'MarkerEdgeColor',groupColors{2})
        xlabel('trialReli'); ylabel('rho');
        [rr,pp] = corr(twoEnvRemapReliEach{dpI,condI},twoEnvRemapRhoEach{dpI,condI},'type','Spearman');
        title(['p=' num2str(pp) ' rho=' num2str(rr)])
    end
    suptitleSL(num2str(dayPairsForward(dpI,:)))
end
% How to use p values here?

% Each cond
singleCellCorrsRho{mouseI}{condI}{dayPairI}