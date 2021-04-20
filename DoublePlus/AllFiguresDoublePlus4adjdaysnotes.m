%% Ratemap corrs each mouse

% This is for change across rule epochs vs. change within
daysAcross = zeros(8,1);
daysAcross([3 6]) = 1;

figure;
oneEnvRhoMeans = []; twoEnvRhoMeans = [];
oneEnvWithinAll = []; oneEnvAcrossAll = [];
twoEnvWithinAll = []; twoEnvAcrossAll = [];
oneEnvAggGroup = cell(1,4); twoEnvAggGroup = cell(1,4);
for mouseI = 1:6
    meanRho = [];
    for dpI = 1:numDayPairs
        dataH = singleCellAllCorrsRho{mouseI}{1}{dpI}(pvCellsUse{mouseI}{dpI});
        meanRho(dpI) = nanmean(dataH);
        
        switch groupNum(mouseI)
        case 1
            %oneEnvAggGroup{aggGroups(dpI)} = [oneEnvAggGroup{aggGroups(dpI)}; dataH];
            
            if daysAcross(dpI) == 0
                oneEnvWithinAll = [oneEnvWithinAll; dataH];
            elseif daysAcross(dpI) == 1
                oneEnvAcrossAll = [oneEnvAcrossAll; dataH];
            end
            %}
        case 2
            %twoEnvAggGroup{aggGroups(dpI)} = [twoEnvAggGroup{aggGroups(dpI)}; dataH];
            
            if daysAcross(dpI) == 0
                twoEnvWithinAll = [twoEnvWithinAll; dataH];
            elseif daysAcross(dpI) == 1
                twoEnvAcrossAll = [twoEnvAcrossAll; dataH];
            end
            %}
    end
    end
    
    switch groupNum(mouseI)
        case 1
            oneEnvRhoMeans = [oneEnvRhoMeans; meanRho];
        case 2
            twoEnvRhoMeans = [twoEnvRhoMeans; meanRho];
    end
    
    plot(meanRho,groupColors{groupNum(mouseI)})
    %plot(oneEnvCorrsAll{dpI},groupColors{1})
    hold on
    %plot(twoEnvCorrsAll{dpI},groupColors{2})
    
end

%{
aggLabels = {'w/Turn1','Across','w/Place','w/Turn2'};
figure;
subplot(1,2,1)
for ii = 1:4
    zz = cdfplot(oneEnvAggGroup{ii}); %zz.Color = groupColors{1};
zz.DisplayName = aggLabels{ii}; %zz.LineStyle = ':';
hold on
%[~,kss] = kstest2(oneEnvWithinAll,oneEnvAcrossAll);
end
title('One-Maze')
legend('Location','NW')

subplot(1,2,2)
for ii = 1:4
    zz = cdfplot(twoEnvAggGroup{ii}); %zz.Color = groupColors{1};
zz.DisplayName = aggLabels{ii}; %zz.LineStyle = ':';
hold on
%[~,kss] = kstest2(oneEnvWithinAll,oneEnvAcrossAll);
end
title('Two-Maze')
legend('Location','NW')
%text(-0.75,0.7,['KS p = ' num2str(kss)])
%text(-0.75,0.6,['KS stat = ' num2str(kst)])
%}
% Difference of within vs. Across rules
figure;
subplot(2,2,1)
zz = cdfplot(oneEnvWithinAll); zz.Color = groupColors{1}; zz.LineWidth = 2;
zz.DisplayName = 'Within'; zz.LineStyle = ':';
hold on
yy = cdfplot(oneEnvAcrossAll); yy.Color = groupColors{1}; yy.LineWidth = 2;
yy.DisplayName = 'Across'; yy.LineStyle = '-.';
[~,kss,kst] = kstest2(oneEnvWithinAll,oneEnvAcrossAll);
title('One-Maze')
legend('Location','NW')
text(-0.75,0.7,['KS p = ' num2str(kss)])
text(-0.75,0.6,['KS stat = ' num2str(kst)])
xlabel('Rho')
ylabel('ECDF')
MakePlotPrettySL(gca);

subplot(2,2,2)
zz = cdfplot(twoEnvWithinAll); zz.Color = groupColors{2}; zz.LineWidth = 2;
zz.DisplayName = 'Within'; zz.LineStyle = ':';
hold on
yy = cdfplot(twoEnvAcrossAll); yy.Color = groupColors{2}; yy.LineWidth = 2;
yy.DisplayName = 'Across'; yy.LineStyle = '-.';
[~,kss,kst] = kstest2(twoEnvWithinAll,twoEnvAcrossAll);
title('Two-Maze')
legend('Location','NW')
text(-0.75,0.7,['KS p = ' num2str(kss)])
text(-0.75,0.6,['KS stat = ' num2str(kst)])
xlabel('Rho')
ylabel('ECDF')
MakePlotPrettySL(gca);
%suptitleSL('CDF of single neuron rate-map correlations across vs. within rule epochs')

% One vs Two within/across
%figure;
subplot(2,2,3)
zz = cdfplot(oneEnvWithinAll); zz.Color = groupColors{1}; zz.LineWidth = 2;
zz.DisplayName = 'OneMaze'; zz.LineStyle = ':';
hold on
yy = cdfplot(twoEnvWithinAll); yy.Color = groupColors{2}; yy.LineWidth = 2;
yy.DisplayName = 'TwoMaze'; yy.LineStyle = ':';
[~,kss,kst] = kstest2(oneEnvWithinAll,twoEnvWithinAll);
title('Within Rules')
legend('Location','NW')
text(-0.75,0.7,['KS p = ' num2str(kss)])
text(-0.75,0.6,['KS stat = ' num2str(kst)])
xlabel('Rho')
ylabel('ECDF')
MakePlotPrettySL(gca);

subplot(2,2,4)
zz = cdfplot(oneEnvAcrossAll); zz.Color = groupColors{1}; zz.LineWidth = 2;
zz.DisplayName = 'OneMaze'; zz.LineStyle = '-.';
hold on
yy = cdfplot(twoEnvAcrossAll); yy.Color = groupColors{2}; yy.LineWidth = 2;
yy.DisplayName = 'TwoMaze'; yy.LineStyle = '-.';
[~,kss,kst] = kstest2(oneEnvAcrossAll,twoEnvAcrossAll);
title('Across Rules')
legend('Location','NW')
text(-0.75,0.7,['KS p = ' num2str(kss)])
text(-0.75,0.6,['KS stat = ' num2str(kst)])
xlabel('Rho')
ylabel('ECDF')
MakePlotPrettySL(gca);

suptitleSL('CDF of single neuron rate-map correlations across vs. within rule epochs')
%

oneEnvRho = nanmean(oneEnvRhoMeans,1);
twoEnvRho = nanmean(twoEnvRhoMeans,1);
oneEnvRhoStd = nanstd(oneEnvRhoMeans,1);
oneEnvRhoSEM = oneEnvRhoStd./sum(~isnan(oneEnvRhoMeans),1);
twoEnvRhoStd = nanstd(twoEnvRhoMeans,1);
twoEnvRhoSEM = twoEnvRhoStd./sum(~isnan(twoEnvRhoMeans),1);
gg = figure; 
%plot(oneEnvRho,groupColors{1},'LineWidth',2)
errorbar([1:numDayPairs]-0.075,oneEnvRho,oneEnvRhoSEM,'Color',groupColors{1},'LineWidth',2)
hold on
%plot(twoEnvRho,groupColors{2},'LineWidth',2)
errorbar([1:numDayPairs]+0.075,twoEnvRho,twoEnvRhoSEM,'Color',groupColors{2},'LineWidth',2)
xlabs = cellfun(@num2str,mat2cell(dayPairsForward,ones(numDayPairs,1),2),'UniformOutput',false);
gg.Children(1).XTick = 1:numDayPairs;
gg.Children(1).XTickLabels = xlabs;
xlabel('Day Pair')
ylabel('Group rho Mean +/- SEM')
MakePlotPrettySL(gca);
xlim([0.5 numDayPairs+0.5])
%% COM changes, within vs. across conditions

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

withinEpochPairs = epochPairs > 0;
acrossEpochPairs = epochPairs == 0;

figure;
for dpI = 1:numDayPairs
    subplot(1,2,1)
    oneData = oneEnvCOMchanges{dpI}(oneEnvCOMchangesCellsUse{dpI});
    
    if epochPairs(dpI) > 0
        yy = cdfplot(oneData);
        yy.Color = groupColors{1};
        yy.LineWidth = 2;  
        yy.LineStyle = ':';
    elseif epochPairs(dpI)==0
        yy = cdfplot(oneData);
        yy.Color = groupColors{1};
        yy.LineWidth = 2;  
        yy.LineStyle = '--';
    end
    hold on
    
    subplot(1,2,2)
    twoData = twoEnvCOMchanges{dpI}(twoEnvCOMchangesCellsUse{dpI});
    
    if epochPairs(dpI) > 0
        yy = cdfplot(twoData);
        yy.Color = groupColors{2};
        yy.LineWidth = 2;  
        yy.LineStyle = ':';
    elseif epochPairs(dpI)==0
        yy = cdfplot(twoData);
        yy.Color = groupColors{2};
        yy.LineWidth = 2;  
        yy.LineStyle = '--';
    end
    hold on
end

for condI = 1:numConds
figure;
for dpI = 1:numDayPairs
    subplot(1,2,1)
    oneData = oneEnvCOMchanges{dpI}(oneEnvCOMchangesCellsUse{dpI}(:,condI),condI);
    
    if epochPairs(dpI) > 0
        yy = cdfplot(oneData);
        yy.Color = groupColors{1};
        yy.LineWidth = 2;  
        yy.LineStyle = ':';
    elseif epochPairs(dpI)==0
        yy = cdfplot(oneData);
        yy.Color = groupColors{1};
        yy.LineWidth = 2;  
        yy.LineStyle = '--';
    end
    hold on
    
    subplot(1,2,2)
    twoData = twoEnvCOMchanges{dpI}(twoEnvCOMchangesCellsUse{dpI}(:,condI),condI);
    
    if epochPairs(dpI) > 0
        yy = cdfplot(twoData);
        yy.Color = groupColors{2};
        yy.LineWidth = 2;  
        yy.LineStyle = ':';
    elseif epochPairs(dpI)==0
        yy = cdfplot(twoData);
        yy.Color = groupColors{2};
        yy.LineWidth = 2;  
        yy.LineStyle = '--';
    end
    hold on
end
end

%% Rate
gg = figure;%('Position'); %,[428 376 590 515]);%[428 613 897 278]
    
 label = 'mean firing rate pct changes';
for dpI = 1:numDayPairs
    subplot(1,2,1)
        
    oneCellsUse = oneEnvMaxRateCellsUse{dpI}; % This adds the >=3 laps one day; says max but it's the same
    changesHereOne = oneEnvMeanRatePctChange{dpI}; 
    %changesHereOne(oneEnvFiredEither{dpI}==0) = NaN; % Forces it to have fired on both days in the arm
        % This might be unnecessary...
    %changesHereOne(changesHereOne==1) = NaN;
    changesHereOne(oneEnvFiredBoth{dpI}==0) = NaN;
    %oneData = changesHereOne;
    oneData = changesHereOne(oneCellsUse);
    
    yy = cdfplot(oneData(:)); 
    yy.Color = groupColors{1}; 
    yy.LineWidth = 2;
    if epochPairs(dpI) > 0
        yy.LineStyle = ':';
    elseif epochPairs(dpI)==0
        yy.LineStyle = '--';
    end
    hold on
    
    subplot(1,2,2)
    
    twoCellsUse = twoEnvMaxRateCellsUse{dpI}; 
    changesHereTwo = twoEnvMeanRatePctChange{dpI}; 
    %changesHereTwo(twoEnvFiredEither{dpI}==0) = NaN;
    %changesHereTwo(changesHereTwo==1) = NaN;
    changesHereTwo(twoEnvFiredBoth{dpI}==0) = NaN;
    %twoData = changesHereTwo;
    twoData = changesHereTwo(twoCellsUse);
    
    zz = cdfplot(twoData(:)); zz.Color = groupColors{2}; 
    zz.LineWidth = 2; 
    if epochPairs(dpI) > 0
        zz.LineStyle = ':';
    elseif epochPairs(dpI)==0
        zz.LineStyle = '--';
    end
    hold on
    
    %{
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
    %}
end

%% Magnitude difference Turn 1 - Place vs. Turn 1 - Turn 2

%% COM

figure;
for dpI = 1:numDayTrips
    pData = twoEnvCOMchangeAB{dpI}(twoEnvCOMchangeCellsUse{dpI});
    %pData = oneEnvCOMchangeAB{dpI}(oneEnvCOMchangeCellsUse{dpI});
    
    yy = cdfplot(pData);
    yy.Color = groupColors{1};
    yy.LineStyle = ':';
    yy.LineWidth = 1.5;
    
    hold on
    
    tData = twoEnvCOMchangeCD{dpI}(twoEnvCOMchangeCellsUse{dpI});
    %tData = oneEnvCOMchangeCD{dpI}(oneEnvCOMchangeCellsUse{dpI});
    
    zz = cdfplot(tData);
    zz.Color = groupColors{1};
    zz.LineStyle = '--';
    zz.LineWidth = 1.5;
    
    [h,pKS] = kstest2(pData(:),tData(:));
    [p,h] = ranksum(pData(:),tData(:));
    
    disp(['Day trip ' num2str(allTriplePairs(dpI,:)) ', Ranksum p = ' num2str(p) ', KS p = ' num2str(pKS)])
    
    RSps(dpI) = p;
    KSps(dpI) = pKS;
    
    title('Cumulative distribution of Turn-place-turn COM changes')
end

figure; 
for dpI = 1:numDayTrips
    cData = twoEnvCOMchangeComp{dpI}(twoEnvCOMchangeCellsUse{dpI});
    %cData = oneEnvCOMchangeComp{dpI}(oneEnvCOMchangeCellsUse{dpI});
    cdfplot(cData)
    hold on
    
    title('Cumulative Magnitud of Turn-place-turn COM change differences')
    
    x = cData;
    SEM = std(x)/sqrt(length(x));               % Standard Error
    ts = tinv([0.025  0.975],length(x)-1);      % T-Score
    CI = mean(x) + ts*SEM;
    disp(num2str(CI))
end             
                
 %% Rate
 
figure;
for dpI = 1:numDayTrips
    %pData = twoEnvMeanRatePctChangeAB{dpI}(twoEnvRateDiffCellsUse{dpI});
    pData = oneEnvMeanRatePctChangeAB{dpI}(oneEnvRateDiffCellsUse{dpI});
    
    yy = cdfplot(pData);
    yy.Color = groupColors{1};
    yy.LineStyle = ':';
    yy.LineWidth = 1.5;
    
    hold on
    
    %tData = twoEnvMeanRatePctChangeCD{dpI}(twoEnvRateDiffCellsUse{dpI});
    tData = oneEnvMeanRatePctChangeCD{dpI}(oneEnvRateDiffCellsUse{dpI});
    
    zz = cdfplot(tData);
    zz.Color = groupColors{1};
    zz.LineStyle = '--';
    zz.LineWidth = 1.5;
    
    [h,pKS] = kstest2(pData(:),tData(:));
    [p,h] = ranksum(pData(:),tData(:));
    
    disp(['Day trip ' num2str(allTriplePairs(dpI,:)) ', Ranksum p = ' num2str(p) ', KS p = ' num2str(pKS)])
    
    RSps(dpI) = p;
    KSps(dpI) = pKS;
    
    title('Cumulative distribution of Turn-place-turn COM changes')
end

%{
figure; 
agg = []; 
agg2 = [];
for dpI = 1:numDayTrips
    agg = [agg; twoEnvAbsMagEachPos{dpI}];
    agg2 = [agg; oneEnvAbsMagEachPos{dpI}];
end
xx = rand(size(agg));
xxx = rand(size(agg2));

plot(xx+0.5,agg,'.')
hold on
plot(xxx+2.5,agg2,'.')
%}

%% Single-cell ratemap corr all day triplets

figure;
for dpI = 1:numDayTrips
    subplot(3,9,dpI)
    pData = oneEnvRhosABAggAll{dpI};
    %pData = twoEnvRhosABAggAll{dpI};
    
    yy = cdfplot(pData);
    yy.Color = groupColors{1};
    yy.LineStyle = ':';
    yy.LineWidth = 1.5;
    %yy.DisplayName = 'Turn1-Place';
    yy.DisplayName = num2str(oneTwoPairs(dpI,:));
    
    hold on
    
    tData = oneEnvRhosCDAggAll{dpI};
    %tData = twoEnvRhosCDAggAll{dpI};
    
    zz = cdfplot(tData);
    zz.Color = groupColors{1};
    zz.LineStyle = '--';
    zz.LineWidth = 1.5;
    %zz.DisplayName = 'Turn1-Turn2';
    zz.DisplayName = num2str(oneThreePairs(dpI,:));
    
    [h,pKS] = kstest2(pData(:),tData(:));
    [p,h] = ranksum(pData(:),tData(:));
    
    disp(['Day trip ' num2str(allTriplePairs(dpI,:)) ', Ranksum p = ' num2str(p) ', KS p = ' num2str(pKS)])
    
    RSps(dpI) = p;
    KSps(dpI) = pKS;
    
    legend('location','NW')
    title(num2str(allTriplePairs(dpI,:)))
end
title('All day triplets, cumulative rhos')
xlabel('Rho')
ylabel('ECDF')

figure; 
for dpI = 1:numDayTrips
    cData = oneEnvRhoDiffsAggAll{dpI};
    %cData = oneEnvCOMchangeComp{dpI}(oneEnvCOMchangeCellsUse{dpI});
    cdfplot(cData)
    hold on
    
    x = cData(~isnan(cData));
    SEM = std(x)/sqrt(length(x));               % Standard Error
    ts = tinv([0.025  0.975],length(x)-1);      % T-Score
    CI = mean(x) + ts*SEM;
    disp([num2str(dpI) ' ' num2str(mean(x)) ' ' num2str(CI)])
end             

title('Cumulative Magnitud of Turn-place-turn COM change differences')

% Pct cells with higher positive correlation in Turn1-Turn2 than
% Turn1-Place
% Re-extracting mouse, cell from this might be tough...
for dpI = 1:numDayTrips
    % Positive diffs: 
    aa = oneEnvRhoDiffsAgg{dpI} > 0;
    % Significant p val:
    bb = oneEnvPvalsCDAgg{dpI} < pThresh;
    % Positive Turn1-Turn2 rho
    cc = oneEnvRhosCDAgg{dpI} > 0;
    % Negative Turn1-place rho:
    dd = oneEnvRhosABAgg{dpI} < 0;
    % Significantly negative?
    ff = oneEnvPvalsABAgg{dpI} < pThresh;
    
    ee = aa & bb & cc & dd & ff;%;
    
    oneEnvEE(dpI) = sum(ee)/length(ee);
    
    aa = twoEnvRhoDiffsAgg{dpI} > 0;
    % Significant p val:
    bb = twoEnvPvalsCDAgg{dpI} < pThresh;
    % Positive Turn1-Turn2 rho
    cc = twoEnvRhosCDAgg{dpI} > 0;
    % Negative Turn1-place rho:
    dd = twoEnvRhosABAgg{dpI} < 0;
    % Significantly negative?
    ff = twoEnvPvalsABAgg{dpI} < pThresh;
    
    ee = aa & bb & cc & dd & ff;%;
    
    twoEnvEE(dpI) = sum(ee)/length(ee);
    
end
figure; 
for ii = 1:27; plot([1 2],[oneEnvEE(ii) twoEnvEE(ii)],'Color',[0.4 0.4 0.4]); hold on; end
title('Pct cells with higher rho Turn1-Turn2 than Turn1-Place')
set(gca,'XTick',[1 2])
set(gca,'XTickLabels',{'OneMaze','TwoMaze'})
xlim([0.75 2.25])
    %{
    mouseI = oneEnvMouseIDtracker{dpI}(1)
    cellI = oneEnvCellTracker{dpI}(1)
    vv = [cellTMap{mouseI}{cellI,1,:}];
    mm = [cellTMap{mouseI}{cellI,8,:}];
    nn = [cellTMap{mouseI}{cellI,4,:}];
    [vv(:), nn(:), mm(:)]
    [rr,pp] = corr(vv(:),nn(:))
    [rr,pp] = corr(vv(:),mm(:))
    %}
    