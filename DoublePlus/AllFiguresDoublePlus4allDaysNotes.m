%% COM change

% Pool across epoch groups
cgs = [0 1]; % Turn1; Turn1 - Turn2; Turn2  ; epochConds 
cgs = [1 0 2];
cgsLabel = {'Turn1 - Turn2';'Turn2 - self'};
cgsLabel = {'Turn1 - self';'Turn1 - Turn2';'Turn2 - self'};
oneDataAgg = cell(1,length(cgs)); twoDataAgg = cell(1,length(cgs));
oneDataAggEach = cell(length(cgs),numConds); twoDataAggEach = cell(length(cgs),numConds);
dpAggCheck = cell(1,length(cgs));
for cgI = 1:length(cgs)
    eeH = cgs(cgI);
    dpHere = find(epochConds==eeH);
    
    oneDataH = [];
    twoDataH = [];
    for dpJ = 1:length(dpHere)
        dpI = dpHere(dpJ);
        
        % COM
        %{
        oneDataAgg{cgI} = [oneDataAgg{cgI}; oneEnvCOMchanges{dpI}(oneEnvCOMchangesCellsUse{dpI})];
        twoDataAgg{cgI} = [twoDataAgg{cgI}; twoEnvCOMchanges{dpI}(twoEnvCOMchangesCellsUse{dpI})];
        %}
        
        % Rate
        %{
        oneCellsUse = oneEnvMaxRateCellsUse{dpI}; % This adds the >=3 laps one day; says max but it's the same
        changesHereOne = oneEnvMeanRatePctChange{dpI}; 
        changesHereOne(oneEnvFiredBoth{dpI}==0) = NaN;
        oneDataAgg{cgI} = changesHereOne(oneCellsUse);
        twoCellsUse = twoEnvMaxRateCellsUse{dpI}; % This adds the >=3 laps one day; says max but it's the same
        changesHereTwo = twoEnvMeanRatePctChange{dpI}; 
        changesHereTwo(twoEnvFiredBoth{dpI}==0) = NaN;
        twoDataAgg{cgI} = changesHereTwo(twoCellsUse);
        %}
        oneDataAgg{cgI} = [oneDataAgg{cgI}; oneEnvCorrsAll{dpI}];
        twoDataAgg{cgI} = [twoDataAgg{cgI}; twoEnvCorrsAll{dpI}];
        for condI = 1:numConds
            %{
            oneDataAggEach{cgI,condI} = [oneDataAggEach{cgI,condI}; ...
                oneEnvCOMchanges{dpI}(oneEnvCOMchangesCellsUse{dpI}(:,condI),condI)];
            twoDataAggEach{cgI,condI} = [twoDataAggEach{cgI,condI}; ...
                twoEnvCOMchanges{dpI}(twoEnvCOMchangesCellsUse{dpI}(:,condI),condI)];
            %}
            oneDataAggEach{cgI,condI} = [oneDataAggEach{cgI,condI}; ...
                changesHereOne(oneCellsUse(:,condI),condI)];
            twoDataAggEach{cgI,condI} = [twoDataAggEach{cgI,condI}; ...
                changesHereTwo(twoCellsUse(:,condI),condI)];
        end
        dpAggCheck{cgI} = [dpAggCheck{cgI}; dayPairsForward(dpI,:)];
    end
end
    
cgs = [1 0 2];



%GetAllCombs([1:3 13:15],[4:12])


for mouseI = 1:numMice
    zoKS = []; zzKS = []; ooKS = [];
for dpI = 1:numDayPairs
    for dpJ = 1:numDayPairs
        if dpI ~=dpJ
            
            dataOne = COMchanges{mouseI}{dpI}(COMcellsUse{mouseI}{dpI});
            dataTwo = COMchanges{mouseI}{dpJ}(COMcellsUse{mouseI}{dpJ});
            [hKS,pKS,kstat] = kstest2(dataOne,dataTwo);
            
            if mouseI==1
                daysS{dpI,dpJ} = [epochConds(dpI) epochConds(dpJ)];
            end
            
            pAgg{mouseI}(dpI,dpJ) = pKS;
            ksAgg{mouseI}(dpI,dpJ) = kstat;
            
            if sum(daysS{dpI,dpJ}==0)==1 
                zoKS = [zoKS; ksAgg{mouseI}(dpI,dpJ)];
            elseif sum(daysS{dpI,dpJ}==0)==2
                zzKS = [zzKS; ksAgg{mouseI}(dpI,dpJ)];
            elseif sum(daysS{dpI,dpJ}>0)==2
                ooKS = [ooKS; ksAgg{mouseI}(dpI,dpJ)];
            else 
                disp('huh')
                keyboard
            end
        end
        ranksum(zoKS,ooKS)
    end
    
end
end

x = [zoKS(:); zzKS(:); ooKS(:)];
grps = [ones(size(zoKS(:))); 2*ones(size(zzKS(:))); 3*ones(size(ooKS(:)))];
  scatterBoxSL(x,grps)
    
    
for cgI = 1:length(cgs)
    gg = figure;%('Position',[428 376 590 515]);%[428 613 897 278]

    oneData = oneDataAgg{cgI};
    twoData = twoDataAgg{cgI};
    
    yy = cdfplot(oneData); 
    yy.Color = groupColors{1}; %yy.Color = 'b';
    yy.LineWidth = 2;
    hold on
    zz = cdfplot(twoData); 
    zz.Color = groupColors{2}; %zz.Color = 'r'; 
    zz.LineWidth = 2; 
    
    xlabel('COM change'); ylabel('Cumulative Proportion')

    [p,h] = ranksum(oneData,twoData);
    [hKS,pKS,kstat] = kstest2(oneData,twoData);
    text(4.5,0.8,['KS stat= ' num2str(kstat)])
    text(4.5,0.5,['RS p= ' num2str(p)])
    text(4.5,0.65,['KS p= ' num2str(pKS)])
    
    title(['Distribution of within-arm COM changes, ' cgsLabel{cgI}])
end

for dpI = 1:numDayPairs
    gg = figure;%('Position',[428 376 590 515]);%[428 613 897 278]

    oneData = oneEnvCOMchanges{dpI}(oneEnvCOMchangesCellsUse{dpI});
    twoData = twoEnvCOMchanges{dpI}(twoEnvCOMchangesCellsUse{dpI});
    
    yy = cdfplot(oneData); 
    yy.Color = groupColors{1}; %yy.Color = 'b';
    yy.LineWidth = 2;
    hold on
    zz = cdfplot(twoData); 
    zz.Color = groupColors{2}; %zz.Color = 'r'; 
    zz.LineWidth = 2; 
    
    xlabel('COM change'); ylabel('Cumulative Proportion')

    [p,h] = ranksum(oneData,twoData);
    [hKS,pKS,kstat] = kstest2(oneData,twoData);
    text(4.5,0.8,['KS stat= ' num2str(kstat)])
    text(4.5,0.5,['RS p= ' num2str(p)])
    text(4.5,0.65,['KS p= ' num2str(pKS)])
    
    ppKS(dpI) = pKS;
    kks(dpI) = kstat;
    
    title(['Distribution of within-arm COM changes, ' num2str(dayPairsForward(dpI,:))])
end

kks(13:15)<kks(4:12)'
ppKS(13:15)>ppKS(4:12)'

for cgI = 1:length(cgs)
    gg = figure;%('Position',[428 376 590 515]);%[428 613 897 278]
    for condI = 1:numConds
        subplot(2,2,condI)
    oneData = oneDataAggEach{cgI,condI};
    twoData = twoDataAggEach{cgI,condI};
    
    yy = cdfplot(oneData); 
    yy.Color = groupColors{1}; %yy.Color = 'b';
    yy.LineWidth = 2;
    hold on
    zz = cdfplot(twoData); 
    zz.Color = groupColors{2}; %zz.Color = 'r'; 
    zz.LineWidth = 2; 
    
    xlabel('COM change'); ylabel('Cumulative Proportion')

    [p,h] = ranksum(oneData,twoData);
    [hKS,pKS,kstat] = kstest2(oneData,twoData);
    text(4.5,0.8,['KS stat= ' num2str(kstat)])
    text(4.5,0.5,['RS p= ' num2str(p)])
    text(4.5,0.65,['KS p= ' num2str(pKS)])
    title(upper(armLabels{condI}))
    end
    suptitleSL(['Distribution of within-arm COM changes, ' cgsLabel{cgI}])
end



for cgI = 1:length(cgs)
    gg = figure;%('Position',[428 376 590 515]);%[428 613 897 278]
    subplot(1,2,1)
        oneData = oneDataAgg{2};
        twoData = oneDataAgg{3};
        
    yy = cdfplot(oneData); 
    yy.Color = groupColors{1}; %yy.Color = 'b';
    yy.LineWidth = 2;
    hold on
    zz = cdfplot(twoData); 
    zz.Color = groupColors{2}; %zz.Color = 'r'; 
    zz.LineWidth = 2; 
    
    xlabel('COM change'); ylabel('Cumulative Proportion')

    [p,h] = ranksum(oneData,twoData);
    [hKS,pKS,kstat] = kstest2(oneData,twoData);
    text(4.5,0.8,['KS stat= ' num2str(kstat)])
    text(4.5,0.5,['RS p= ' num2str(p)])
    text(4.5,0.65,['KS p= ' num2str(pKS)])
    
    subplot(1,2,2)
        oneData = twoDataAgg{2};
        twoData = twoDataAgg{3};
        
    yy = cdfplot(oneData); 
    yy.Color = groupColors{1}; %yy.Color = 'b';
    yy.LineWidth = 2;
    hold on
    zz = cdfplot(twoData); 
    zz.Color = groupColors{2}; %zz.Color = 'r'; 
    zz.LineWidth = 2; 
    
    xlabel('COM change'); ylabel('Cumulative Proportion')

    [p,h] = ranksum(oneData,twoData);
    [hKS,pKS,kstat] = kstest2(oneData,twoData);
    text(4.5,0.8,['KS stat= ' num2str(kstat)])
    text(4.5,0.5,['RS p= ' num2str(p)])
    text(4.5,0.65,['KS p= ' num2str(pKS)])
    
    title(['Distribution of within-arm COM changes, ' cgsLabel{cgI}])
    title(['Distribution of within-arm COM changes, ' cgsLabel{cgI}])
end


% Each condition individually
for dpI = 1:numDayPairs
    gg = figure('Position',[530 303 450 370.5000]);
    
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
        title(['COM change ' upper(armLabels{condI}) ' arm'])
        %title(['Distribution of within-arm COM changes, day pair ' num2str(dayPairsForward(dpI,:))])
        
        MakePlotPrettySL(gca);
    end
    suptitleSL(['Days ' num2str(dayPairsForward(dpI,:))])
end