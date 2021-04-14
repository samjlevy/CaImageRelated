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