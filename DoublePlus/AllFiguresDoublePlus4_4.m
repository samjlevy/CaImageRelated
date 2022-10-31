%% Registration Statistics

% ROI overlaps and center distances
for mouseI = 1:numMice
    cellCenters = [];
    cellCenterDistances = [];
    cellROIoverlapTotal = [];
    cellROIoverlapCellI = [];
    
    footprintsFolder = fullfile(mainFolder,mice{mouseI},[mice{mouseI} 'Footprints']);
    cd(footprintsFolder)
    fpFiles = ls('NeuronFootprint*.mat');
    
    for fileI = 1:9
        disp(['Doing Session ' num2str(fileI)])
        tic
        NeuronFootprintCell = [];
        %fpts = strsplit(cellAllFiles{mouseI}{fileI},'\');
        %fileH = fullfile(mainFolder,mice{mouseI},fpts{end},'RegisteredImageSL2buffered.mat');
        load(fpFiles(fileI,:))
        
        nCellsHere = size(NeuronFootprint,1);
        for cellI = 1:nCellsHere
            NeuronFootprintCell{cellI} = squeeze(NeuronFootprint(cellI,:,:));
        end
        
        cellCenters{fileI} = getAllCellCenters(NeuronFootprintCell,true);
        
        
        
        cellCenterDistances{fileI} = GetAllPtToPtDistances2(cellCenters{fileI}(:,1),cellCenters{fileI}(:,2),cellCenters{fileI}(:,1),cellCenters{fileI}(:,2),[]);
        
        cellPairsCheck = cellCenterDistances{fileI} < 50;
        cellPairsCheck(logical(eye(nCellsHere))) = false;
        cellPairsCheck = find(cellPairsCheck);
        
        
        [cellsI,cellsJ] = ind2sub([nCellsHere nCellsHere],cellPairsCheck);
        %allCellCombs = nchoosek(1:size(NeuronFootprint,3),2);
        
        
        %cellROIoverlaps{fileI} = arrayfun(@(x,y) sum(sum(NeuronFootprint(:,:,x) & NeuronFootprint(:,:,y))) / sum(sum(NeuronFootprint(:,:,x) | NeuronFootprint(:,:,y))),...
        %    allCellCombs(:,1),allCellCombs(:,2));
        
        % Slow, but it works
        cellROIoverlaps{fileI} = zeros(nCellsHere,nCellsHere);
        for pairI = 1:numel(cellsI)
            cellI = cellsI(pairI);
            cellJ = cellsJ(pairI);
                
            cellROIoverlapTotal{fileI}(cellI,cellJ) = ...
                    sum(sum(NeuronFootprintCell{cellI} & NeuronFootprintCell{cellJ})) / ...
                    sum(sum(NeuronFootprintCell{cellI} | NeuronFootprintCell{cellJ}));
                
            cellROIoverlapCellI{fileI}(cellI,cellJ) = ...
                    sum(sum(NeuronFootprintCell{cellI} & NeuronFootprintCell{cellJ})) / ...
                    sum(sum(NeuronFootprintCell{cellI}));
        end
        %}
        toc
    end
    
    save(fullfile(mainFolder,mice{mouseI},'ROIinfo.mat'),'cellCenters','cellCenterDistances','cellROIoverlapTotal','cellROIoverlapCellI')
    disp(['Done mouse ' num2str(mouseI)])
end

% Registration
for mouseI = 1:numMice
    if mouseI == 1
        load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'), 'sortedSessionInds')
        ssI = sortedSessionInds > 0;
    else
        ssI = cellSSI{mouseI} > 0;
    end
    
    % Percent found any other day
    for sessI = 1:9
        ssA = ssI(:,sessI);
        ssB = ssI;
        ssB(:,sessI) = [];
        ssB = sum(ssB,2)>0;
        
        pctRegOtherDay{mouseI}(1,sessI) = sum(ssA & ssB) / sum(ssA);
    end
    
    % Percent found each day pair
    for sessI = 1:9
        for sessJ = 1:9
            if sessI ~= sessJ
                ssA = ssI(:,sessI);
                ssB = ssI(:,sessJ);
                
                pctRegEachDayPair{mouseI}(sessI,sessJ) = sum(ssA & ssB) / sum(ssA);
                
            end
        end
    end
    
end

figure; 
for mouseI = 1:numMice
    colorH = groupColors{groupNum(mouseI)};
    plot(1:9,pctRegOtherDay{mouseI}*100,'Color',colorH,'LineWidth',1.5)
    hold on
end
xlabel('Day Number')
ylabel('pct cells Reg')
title('Percentage of cells registered any other day')
xlim([0.75 9.25])
ylim([90 100.5])
MakePlotPrettySL(gca);

figure('Position',[332.5000 133 1.0455e+03 521]);
for mouseI = 1:numMice
    subplot(2,3,mouseI)
    imagesc(pctRegEachDayPair{mouseI})
    ylabel('Session i')
    xlabel('Session j')
    title(['Mouse ' num2str(mouseI)])
    colorbar
end
suptitleSL('Day-Pair Registration Proportion')

%% Ziv style raster plots
largeRasterNotes1


%% Remapping Turn1-Turn2

% COM shift
oneData = oneEnvCOMagg;
twoData = twoEnvCOMagg;
oneData = oneData(~isnan(oneData));
twoData = twoData(~isnan(twoData));
% Histogram
rangeHere = [0 12];
histbins = linspace(min(rangeHere),max(rangeHere),51);
%{
histcountsOne = histcounts(oneData,histbins);
histcountsTwo = histcounts(twoData,histbins);
oneFirst = histcountsOne < histcountsTwo;
bd = find(oneFirst);
figure;
ii = histogram(oneData,histbins,'FaceColor',[0.0745    0.6235    1.0000],'FaceAlpha',1);
ii.DisplayName = 'One-Maze';
hold on
hh = histogram(twoData,histbins,'FaceColor',[1 0.3235 0.0745],'FaceAlpha',1);
hh.DisplayName = 'Two-Maze';
%jj = histogram(twoData,histbins(bd==1),'FaceColor',[1 0.3235 0.0745],'FaceAlpha',1);
%kk = histogram(oneData,histbins(bd==0),'FaceColor',[0.0745    0.6235    1.0000],'FaceAlpha',1);
xlabel('Center-of-Mass shift (bins)')
ylabel('Number of cells')
%legend('Two-Maze','One-Maze','Location','NE')
legend('Location','NE')
MakePlotPrettySL(gca)
%}

figure('Position',[661.5000 184.5000 303 351.5000]); subplot(2,1,1)
ii = histogram(oneData,histbins,'FaceColor',groupColors{1},'FaceAlpha',1); %[0.0745    0.6235    1.0000]
ii.DisplayName = 'One-Maze';
title('One-Maze')
%ylabel('Number of cells')
ylabel('Proportion of cells')
xlabel('Center-of-Mass shift (bins)')
ii.Normalization = 'probability';
ylim([0 0.15])
xlim(rangeHere)
MakePlotPrettySL(gca)

subplot(2,1,2)
hh = histogram(twoData,histbins,'FaceColor',groupColors{2},'FaceAlpha',1);%[1 0.3235 0.0745]
hh.DisplayName = 'Two-Maze';
hh.Normalization = 'probability';
ylim([0 0.15])
xlim(rangeHere)
title('Two-Maze')
xlabel('Center-of-Mass shift (bins)')
%ylabel('Number of cells')
ylabel('Proportion of cells')
MakePlotPrettySL(gca)
suptitleSL('Turn Right 1 vs. Turn Right 2')

% ECDF
figure; 
yy = cdfplot(oneData);
yy.Color = groupColors{1}; %yy.Color = 'b';
yy.LineWidth = 2;
hold on
zz = cdfplot(twoData);
zz.Color = groupColors{2}; %zz.Color = 'r';
zz.LineWidth = 2;
xlabel('COM change (bin)'); ylabel('Cumulative Proportion')
[p,h] = ranksum(oneData,twoData);
[hKS,pKS,ksStat] = kstest2(oneData,twoData);
textX = (max(rangeHere)-min(rangeHere))*0.45+min(rangeHere);
text(textX,0.5,['RS p = ' num2str(p)])
text(textX,0.65,['KS p = ' num2str(pKS)])
text(textX,0.8,['KS stat = ' num2str(ksStat)])
MakePlotPrettySL(gca);


oneData = oneEnvRateAgg;
twoData = twoEnvRateAgg;
oneData = oneData(~isnan(oneData));
twoData = twoData(~isnan(twoData));
% Histogram
rangeHere = [0 1];
histbins = linspace(min(rangeHere),max(rangeHere),25);
%{
histcountsOne = histcounts(oneData,histbins);
histcountsTwo = histcounts(twoData,histbins);
oneFirst = histcountsOne < histcountsTwo;
bd = 14;
figure;
ii = histogram(oneData,histbins,'FaceColor',[0.0745    0.6235    1.0000],'FaceAlpha',1);
ii.DisplayName = 'One-Maze';
hold on
hh = histogram(twoData,histbins,'FaceColor',[1 0.3235 0.0745],'FaceAlpha',1);
hh.DisplayName = 'Two-Maze';
%hh = histogram(twoData,histbins(1:bd+1),'FaceColor',[1 0.3235 0.0745],'FaceAlpha',1);
%hold on
%ii = histogram(oneData,histbins(bd+1:end),'FaceColor',[0.0745    0.6235    1.0000],'FaceAlpha',1);
%jj = histogram(twoData,histbins(bd+1:end),'FaceColor',[1 0.3235 0.0745],'FaceAlpha',1);
%kk = histogram(oneData,histbins(1:bd+1),'FaceColor',[0.0745    0.6235    1.0000],'FaceAlpha',1);
xlabel('Mean event likelihood change')
ylabel('Number of cells')
legend('Location','NW')
MakePlotPrettySL(gca)
%}
figure('Position',[661.5000 184.5000 303 351.5000]); subplot(2,1,1)
ii = histogram(oneData,histbins,'FaceColor',groupColors{1},'FaceAlpha',1); %[0.0745    0.6235    1.0000]
ii.DisplayName = 'One-Maze';
title('One-Maze')
%ylabel('Number of cells')
ylabel('Proportion of cells')
xlabel('Mean event likelihood change')
ii.Normalization = 'probability';
ylim([0 0.1])
xlim([0 1])
MakePlotPrettySL(gca)

subplot(2,1,2)
hh = histogram(twoData,histbins,'FaceColor',groupColors{2},'FaceAlpha',1);%[1 0.3235 0.0745]
hh.DisplayName = 'Two-Maze';
hh.Normalization = 'probability';
ylim([0 0.1])
xlim([0 1])
title('Two-Maze')
xlabel('Mean event likelihood change')
%ylabel('Number of cells')
ylabel('Proportion of cells')
MakePlotPrettySL(gca)
suptitleSL('Turn Right 1 vs. Turn Right 2')

% ECDF
figure; 
yy = cdfplot(oneData);
yy.Color = groupColors{1}; %yy.Color = 'b';
yy.LineWidth = 2;
hold on
zz = cdfplot(twoData);
zz.Color = groupColors{2}; %zz.Color = 'r';
zz.LineWidth = 2;
xlabel('Mean event likelihood change'); ylabel('Cumulative Proportion')
[p,h] = ranksum(oneData,twoData);
[hKS,pKS,ksStat] = kstest2(oneData,twoData);
textX = (max(rangeHere)-min(rangeHere))*0.45+min(rangeHere);
text(textX,0.5,['RS p= ' num2str(p)])
text(textX,0.65,['KS p= ' num2str(pKS)])
text(textX,0.8,['KS stat = ' num2str(ksStat)])
MakePlotPrettySL(gca);

% Single neuron corrs

oneData = oneEnvCorrsAgg;
twoData = twoEnvCorrsAgg;
oneData = oneData(~isnan(oneData));
twoData = twoData(~isnan(twoData));
% Histogram
%{
rangeHere = [-1 1];
histbins = linspace(min(rangeHere),max(rangeHere),25);
histcountsOne = histcounts(oneData,histbins);
histcountsTwo = histcounts(twoData,histbins);
oneFirst = histcountsOne < histcountsTwo;
bd = 14;
figure;
ii = histogram(oneData,histbins,'FaceColor',groupColors{1},'FaceAlpha',1); %[0.0745    0.6235    1.0000]
ii.DisplayName = 'One-Maze';
ii.Normalization = 'Probability';
hold on
hh = histogram(twoData,histbins,'FaceColor',groupColors{2},'FaceAlpha',1);%[1 0.3235 0.0745]
hh.DisplayName = 'Two-Maze';
hh.Normalization = 'Probability';
xlabel('Correlation (Spearman rho)')
ylabel('Number of cells')
legend('Location','NW')
MakePlotPrettySL(gca)
%}
figure('Position',[661.5000 184.5000 303 351.5000]); subplot(2,1,1)
ii = histogram(oneData,histbins,'FaceColor',groupColors{1},'FaceAlpha',1); %[0.0745    0.6235    1.0000]
ii.DisplayName = 'One-Maze';
title('One-Maze')
%ylabel('Number of cells')
ylabel('Proportion of cells')
xlabel('Correlation (Spearman rho)')
ii.Normalization = 'probability';
%ylim([0 0.04])
xlim(rangeHere)
MakePlotPrettySL(gca)

subplot(2,1,2)
hh = histogram(twoData,histbins,'FaceColor',groupColors{2},'FaceAlpha',1);%[1 0.3235 0.0745]
hh.DisplayName = 'Two-Maze';
hh.Normalization = 'probability';
%ylim([0 0.04])
xlim(rangeHere)
title('Two-Maze')
xlabel('Correlation (Spearman rho)')
%ylabel('Number of cells')
ylabel('Proportion of cells')
MakePlotPrettySL(gca)
suptitleSL('Turn Right 1 vs. Turn Right 2')

% ECDF
figure; 
yy = cdfplot(oneData);
yy.Color = groupColors{1}; %yy.Color = 'b';
yy.LineWidth = 4;
hold on
zz = cdfplot(twoData);
zz.Color = groupColors{2}; %zz.Color = 'r';
zz.LineWidth = 4;
xlabel('Correlation (Spearman rho)'); 
ylabel('Cumulative Proportion')
[p,h] = ranksum(oneData,twoData);
[hKS,pKS,ksStat] = kstest2(oneData,twoData);
textX = (max(rangeHere)-min(rangeHere))*0.45+min(rangeHere);
text(textX,0.5,['RS p= ' num2str(p)])
text(textX,0.65,['KS p= ' num2str(pKS)])
text(textX,0.8,['KS stat = ' num2str(ksStat)])
title('Turn Right 1 vs. Turn Right 2')
MakePlotPrettySL(gca);

oneDat = oneEnvMIagg(~isnan(oneEnvMIagg));
twoDat = twoEnvMIagg(~isnan(twoEnvMIagg));
figure('Position',[389 309 748.5000 331.5000]); 
subplot(1,2,1); histogram(oneDat,19,'FaceColor',groupColors{1},'Normalization','probability');  %[-1 -0.95:0.1:0.95 1]
title('OneMaze')
xlabel('MI score change'); ylabel('Proportion of cells')
xlim([-1 1])
ylim([0 0.3])
MakePlotPrettySL(gca);
subplot(1,2,2); histogram(twoDat,19,'FaceColor',groupColors{2},'Normalization','probability');
xlabel('MI score change'); ylabel('Proportion of cells')
xlim([-1 1])
title('TwoMaze')
MakePlotPrettySL(gca);
ylim([0 0.3])

figure('Position',[645 306.5000 321 332]); 
[f,x] = ecdf(oneEnvMIagg); 
plot(x,f,'Color',groupColors{1},'LineWidth',1.5,'DisplayName','OneMaze'); 
hold on 
[f,x] = ecdf(twoEnvMIagg); 
plot(x,f,'Color',groupColors{2},'LineWidth',1.5,'DisplayName','TwoMaze');
xlabel('MI score change'); ylabel('Cumuluative Proportion')
legend('location','NW')
[~,p] = kstest2(oneEnvMIagg,twoEnvMIagg);
title(['Turn 1 - Turn 2 change in MI score, p=' num2str(p)])

figure('Position',[645 306.5000 321 332]); 
[f,x] = ecdf(abs(oneEnvMIagg)); 
plot(x,f,'Color',groupColors{1},'LineWidth',1.5,'DisplayName','OneMaze'); 
hold on 
[f,x] = ecdf(abs(twoEnvMIagg)); 
plot(x,f,'Color',groupColors{2},'LineWidth',1.5,'DisplayName','TwoMaze');
xlabel('absolute val MI score change'); ylabel('Cumuluative Proportion')
legend('location','NW')
[ss,p,ksStat] = kstest2(abs(oneEnvMIagg),abs(twoEnvMIagg));
title(['Turn 1 - Turn 2 change in MI score, p=' num2str(p)])

%% Each arms
% COM shift

for groupI = 1:2
figure('Position',[520 131 735.5000 667]); 
craw = numel(condsUse)-1;
for ccI = 1:size(condsCompare,1)
    cRow = condsCompare(ccI,1);
    cCol = condsCompare(ccI,2);
    subplot(craw,craw,(cRow-1)*craw+cCol-1)
    
    switch groupI
        case 1
            oneData = oneEnvCOMaggEach{cRow};
            twoData = oneEnvCOMaggEach{cCol};
            sTitle = 'One';
        case 2
            oneData = twoEnvCOMaggEach{cRow};
            twoData = twoEnvCOMaggEach{cCol};
            sTitle = 'Two';
    end
    
    oneLab = armLabels{condsUse(cRow)};
    twoLab = armLabels{condsUse(cCol)};

    yy = cdfplot(oneData);
    yy.Color = groupColors{groupI}; %yy.Color = 'b';
    yy.LineWidth = 2;
    yy.LineStyle = ':';
    yy.DisplayName = upper(oneLab);
    hold on
    zz = cdfplot(twoData);
    zz.Color = groupColors{groupI}; %zz.Color = 'r';
    zz.LineWidth = 2;
    zz.DisplayName = upper(twoLab);
    zz.LineStyle = '--';
    xlabel('Mean COM shift'); ylabel('Cumulative Proportion')
    [p,h] = ranksum(oneData,twoData);
    [hKS,pKS,ksStat] = kstest2(oneData,twoData);
    textX = (max(rangeHere)-min(rangeHere))*0.45+min(rangeHere);
    text(textX,0.5,['RS p= ' num2str(p)])
    text(textX,0.65,['KS p= ' num2str(pKS)])
    text(textX,0.8,['KS stat = ' num2str(ksStat)])
    %title([upper(oneLab) ' vs. ' upper(twoLab)])
    legend('Location','SE')
    MakePlotPrettySL(gca);
end
suptitleSL([sTitle '-Maze COM shifts'])
end

% Rate remapping
rangeHere = [0 1];
for groupI = 1:2
figure('Position',[520 131 735.5000 667]); 
craw = numel(condsUse)-1;
for ccI = 1:size(condsCompare,1)
    cRow = condsCompare(ccI,1);
    cCol = condsCompare(ccI,2);
    subplot(craw,craw,(cRow-1)*craw+cCol-1)
    
    switch groupI
        case 1
            oneData = oneEnvRateAggEach{cRow};
            twoData = oneEnvRateAggEach{cCol};
            sTitle = 'One';
        case 2
            oneData = twoEnvRateAggEach{cRow};
            twoData = twoEnvRateAggEach{cCol};
            sTitle = 'Two';
    end
    
    oneLab = armLabels{condsUse(cRow)};
    twoLab = armLabels{condsUse(cCol)};

    yy = cdfplot(oneData);
    yy.Color = groupColors{groupI}; %yy.Color = 'b';
    yy.LineWidth = 2;
    yy.LineStyle = ':';
    yy.DisplayName = upper(oneLab);
    hold on
    zz = cdfplot(twoData);
    zz.Color = groupColors{groupI}; %zz.Color = 'r';
    zz.LineWidth = 2;
    zz.DisplayName = upper(twoLab);
    zz.LineStyle = '--';
    xlabel('Mean event likelihood change'); ylabel('Cumulative Proportion')
    [p,h] = ranksum(oneData,twoData);
    [hKS,pKS,ksStat] = kstest2(oneData,twoData);
    textX = (max(rangeHere)-min(rangeHere))*0.45+min(rangeHere);
    text(textX,0.5,['RS p= ' num2str(p)])
    text(textX,0.65,['KS p= ' num2str(pKS)])
    text(textX,0.8,['KS stat = ' num2str(ksStat)])
    %title([upper(oneLab) ' vs. ' upper(twoLab)])
    legend('Location','SE')
    MakePlotPrettySL(gca);
end
suptitleSL([sTitle '-Maze Event Likelihood change'])
end

% Plot all...
lineStyles = {':','--','-.','-'};
for groupI = 1:2
    figure;
    for condI = 1:4
         switch groupI
        case 1
            oneData = oneEnvRateAggEach{condI};
            sTitle = 'One';
        case 2
            oneData = twoEnvRateAggEach{condI};
            sTitle = 'Two';
         end
    yy = cdfplot(oneData);
    %yy.Color = groupColors{groupI}; %yy.Color = 'b';
    yy.LineWidth = 2;
    yy.LineStyle = lineStyles{condI};
    yy.DisplayName = upper(armLabels{condI});
    hold on
    end
    legend('Location','SE')
    title([sTitle '-Maze Event Likelihood change'])
    xlabel('Mean event likelihood change'); ylabel('Cumulative Proportion')
end
   

% Corrs 
rangeHere = [-1 1];
for groupI = 1:2
figure('Position',[520 131 735.5000 667]); 
craw = numel(condsUse)-1;
for ccI = 1:size(condsCompare,1)
    cRow = condsCompare(ccI,1);
    cCol = condsCompare(ccI,2);
    subplot(craw,craw,(cRow-1)*craw+cCol-1)
    
    switch groupI
        case 1
            oneData = oneEnvCorrsAggEach{cRow};
            twoData = oneEnvCorrsAggEach{cCol};
            sTitle = 'One';
        case 2
            oneData = twoEnvCorrsAggEach{cRow};
            twoData = twoEnvCorrsAggEach{cCol};
            sTitle = 'Two';
    end
    
    oneLab = armLabels{condsUse(cRow)};
    twoLab = armLabels{condsUse(cCol)};

    yy = cdfplot(oneData);
    yy.Color = groupColors{groupI}; %yy.Color = 'b';
    yy.LineWidth = 2;
    yy.LineStyle = ':';
    yy.DisplayName = upper(oneLab);
    hold on
    zz = cdfplot(twoData);
    zz.Color = groupColors{groupI}; %zz.Color = 'r';
    zz.LineWidth = 2;
    zz.DisplayName = upper(twoLab);
    zz.LineStyle = '--';
    xlabel('Rho'); ylabel('Cumulative Proportion')
    [p,h] = ranksum(oneData,twoData);
    [hKS,pKS,ksStat] = kstest2(oneData,twoData);
    textX = (max(rangeHere)-min(rangeHere))*0.45+min(rangeHere);
    text(textX,0.5,['RS p= ' num2str(p)])
    text(textX,0.65,['KS p= ' num2str(pKS)])
    text(textX,0.8,['KS stat = ' num2str(ksStat)])
    %title([upper(oneLab) ' vs. ' upper(twoLab)])
    legend('Location','SE')
    MakePlotPrettySL(gca);
end
suptitleSL([sTitle '-Maze Single Cell Correlations'])
end
%% PV corrs Turn1-Turn2

locations = [0 0.5 1];
colors = [1.0000    0.0    0.000;
            1 1 1;
            0    0.45   0.74];           
newGradient = GradientMaker(colors,locations);
figure; colormap parula; gradientH = colormap; close(gcf); 
newGradient = gradientH;

plotBins.X = []; plotBins.Y = [];
for condI = 1:numel(condsUse)
    plotBins.X = [plotBins.X; lgPlotHere{condsUse(condI)}.X];
    plotBins.Y = [plotBins.Y; lgPlotHere{condsUse(condI)}.Y];
end
[figHand] = PlusMazePVcorrHeatmap3(oneEnvPVcorrs,plotBins,newGradient,[0, 0.4],[]);
figHand.Position=[243.5000 212.5000 531.5000 399.5000];
title('One-Maze')

[figHand] = PlusMazePVcorrHeatmap3(twoEnvPVcorrs,plotBins,newGradient,[0, 0.4],[]);
figHand.Position=[243.5000 212.5000 531.5000 399.5000];
title('Two-Maze')

labelsH = {'0.3','0.15','0'};
PlotColorbar(newGradient,labelsH)

condsCompare
for ccI = 1:size(condsCompare,1)
    condA = condsCompare(ccI,1);
    condB = condsCompare(ccI,2);
    
    binsA = [1:nArmBins]+nArmBins*(condA-1);
    binsB = [1:nArmBins]+nArmBins*(condB-1);
    [p,~] = ranksum(oneEnvPVcorrs(binsA(:)),oneEnvPVcorrs(binsB(:)));
    %oneEnvMicePVcorrsMeans(:,binsA(:)),
    oneEnvCorrsP(condA,condB) = p;

    [p,~] = ranksum(twoEnvPVcorrs(binsA(:)),twoEnvPVcorrs(binsB(:)));
    
    twoEnvCorrsP(condA,condB) = p;
    
end

%% Day 1 - day 2 singleNeuron corr by MI change

oneEnvClusterRemapCorrs = [];
oneEnvClusterRemapMIdiff = [];
twoEnvClusterRemapCorrs = [];
twoEnvClusterRemapMIdiff = [];
for mouseI = 1:numMice
    for dpI = 1:numDayPairs
         haveCellBothDays = sum(cellSSI{mouseI}(:,dayPairsForward(dpI,:))>0,2)==2;
         aboveThreshOneDay = sum(dayUseAll{mouseI}(:,dayPairsForward(dpI,:)),2) >= 1;
         firedOnMazeOneDays = sum(trialReliAll{mouseI}(:,dayPairsForward(dpI,:))>0,2) >= 1;
         firedOnMazeBothDays = sum(trialReliAll{mouseI}(:,dayPairsForward(dpI,:))>0,2) == 2;
         % This version restricts to conds used...
         % firedOnMazeBothDays = sum(sum(trialReli{mouseI}(:,dayPairsForward(dpI,:),condsUse),3)>0,2) == 2;
         
         cellsUseH = haveCellBothDays & firedOnMazeBothDays & aboveThreshOneDay;
         
         corrsH = singleCellAllCorrsRho{mouseI}{1}{dpI}(cellsUseH);
         MIdiffHere = MIdiff{mouseI}{dpI}(cellsUseH);
         
         switch groupNum(mouseI)
             case 1
                 oneEnvClusterRemapCorrs = [oneEnvClusterRemapCorrs; corrsH(:)];
                 oneEnvClusterRemapMIdiff = [oneEnvClusterRemapMIdiff; MIdiffHere(:)];
             case 2
                 twoEnvClusterRemapCorrs = [twoEnvClusterRemapCorrs; corrsH(:)];
                 twoEnvClusterRemapMIdiff = [twoEnvClusterRemapMIdiff; MIdiffHere(:)];
         end
    end
end

figure('Position',[338 210.5000 692.5000 349.5000]);
subplot(1,2,1); 
plot(oneEnvClusterRemapMIdiff,oneEnvClusterRemapCorrs,'.','MarkerFaceColor',groupColors{1},'MarkerEdgeColor',groupColors{1})
[rr,pp] = corr(oneEnvClusterRemapMIdiff,oneEnvClusterRemapCorrs,'type','Spearman');
title(['OneEnv rho=' num2str(rr) ', p=' num2str(pp)])
xlabel('MI change'); ylabel('rho de Spearman')
MakePlotPrettySL(gca);
subplot(1,2,2); 
plot(twoEnvClusterRemapMIdiff,twoEnvClusterRemapCorrs,'.','MarkerFaceColor',groupColors{2},'MarkerEdgeColor',groupColors{2})
[rr,pp] = corr(twoEnvClusterRemapMIdiff,twoEnvClusterRemapCorrs,'type','Spearman');
title(['TwoEnv rho=' num2str(rr) ', p=' num2str(pp)])
xlabel('MI change'); ylabel('rho de Spearman')
MakePlotPrettySL(gca);
suptitleSL('Turn1 - Turn2')

%% Adj days (day to day drift)

% This is for change across rule epochs vs. change within


%figure;
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
    
    %plot(meanRho,'Color',groupColors{groupNum(mouseI)})
    %plot(oneEnvCorrsAll{dpI},groupColors{1})
    %hold on
    %plot(twoEnvCorrsAll{dpI},groupColors{2})
    
end

%{
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
%}

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

% PV Corrs
gg = figure;
errorbar([1:numDayPairs]-0.1,oneEnvPVmeansAll,oneEnvPVsemAll,'Color',groupColors{1},'LineWidth',2)
hold on
errorbar([1:numDayPairs]+0.1,twoEnvPVmeansAll,twoEnvPVsemAll,'Color',groupColors{2},'LineWidth',2)

xlim([0.8 8.2])
gg.Children.XTick = 1:numDayPairs;
gg.Children.XTickLabel = num2str(dayPairsForward);
xlabel('Day Pairs')
ylabel('Correlation (Spearman rho)')
MakePlotPrettySL(gg.Children);

% Single cell PV corr by reliability
% Relationship between remapping and activity rate

% Bias of activity to a particular arm, does that change (Modulation index)


% Whole maze remapping by reli
oneEnvRemapRhoValsWithin = []; 
oneEnvRemapReliValsWithin = [];
oneEnvRemapPvalsWithin = [];
oneEnvRemapRhoValsAcross = []; 
oneEnvRemapReliValsAcross = [];
oneEnvRemapPvalsAcross = [];
oneEnvRemapReliChangeWithin = [];
oneEnvRemapReliChangeAcross = [];
twoEnvRemapRhoValsWithin = []; 
twoEnvRemapReliValsWithin = [];
twoEnvRemapPvalsWithin = [];
twoEnvRemapRhoValsAcross = []; 
twoEnvRemapReliValsAcross = [];
twoEnvRemapPvalsAcross = [];
twoEnvRemapReliChangeWithin = [];
twoEnvRemapReliChangeAcross = [];

for mouseI = 1:6
    for dpI = 1:numDayPairs
        switch daysAcross(dpI)
            case 0
                switch groupNum(mouseI)
                    case 1
                        oneEnvRemapRhoValsWithin = [oneEnvRemapRhoValsWithin; oneEnvRemapRho{mouseI}{dpI}];
                        oneEnvRemapReliValsWithin = [oneEnvRemapReliValsWithin; oneEnvRemapReli{mouseI}{dpI}];
                        oneEnvRemapPvalsWithin = [oneEnvRemapPvalsWithin; oneEnvRemapP{mouseI}{dpI}];
                        oneEnvRemapReliChangeWithin = [oneEnvRemapReliChangeWithin; oneEnvRemapReliChange{mouseI}{dpI}];
                    case 2
                        twoEnvRemapRhoValsWithin = [twoEnvRemapRhoValsWithin; twoEnvRemapRho{mouseI}{dpI}];
                        twoEnvRemapReliValsWithin = [twoEnvRemapReliValsWithin; twoEnvRemapReli{mouseI}{dpI}];
                        twoEnvRemapPvalsWithin = [twoEnvRemapPvalsWithin; twoEnvRemapP{mouseI}{dpI}];
                        twoEnvRemapReliChangeWithin = [twoEnvRemapReliChangeWithin; twoEnvRemapReliChange{mouseI}{dpI}];
                end
            case 1
                switch groupNum(mouseI)
                    case 1
                        oneEnvRemapRhoValsAcross = [oneEnvRemapRhoValsAcross; oneEnvRemapRho{mouseI}{dpI}];
                        oneEnvRemapReliValsAcross = [oneEnvRemapReliValsAcross; oneEnvRemapReli{mouseI}{dpI}];
                        oneEnvRemapPvalsAcross = [oneEnvRemapPvalsAcross; oneEnvRemapP{mouseI}{dpI}];
                        oneEnvRemapReliChangeAcross = [oneEnvRemapReliChangeAcross; oneEnvRemapReliChange{mouseI}{dpI}];
                    case 2
                        twoEnvRemapRhoValsAcross = [twoEnvRemapRhoValsAcross; twoEnvRemapRho{mouseI}{dpI}];
                        twoEnvRemapReliValsAcross = [twoEnvRemapReliValsAcross; twoEnvRemapReli{mouseI}{dpI}];
                        twoEnvRemapPvalsAcross = [twoEnvRemapPvalsAcross; twoEnvRemapP{mouseI}{dpI}];
                        twoEnvRemapReliChangeAcross = [twoEnvRemapReliChangeAcross; twoEnvRemapReliChange{mouseI}{dpI}];
                end
        end
    end
end

figure; 
subplot(1,2,1)
xData = [oneEnvRemapReliValsWithin(:); oneEnvRemapReliValsAcross(:)];
yData = [oneEnvRemapRhoValsWithin(:); oneEnvRemapRhoValsAcross(:)];
goodDat = (~isnan(xData)) & ~(isnan(yData));
plot(xData,yData,'.','MarkerFaceColor',groupColors{1},'MarkerEdgeColor',groupColors{1})
xlabel('trialReli'); ylabel('rho');
[rr,pp] = corr(xData(goodDat),yData(goodDat),'type','Spearman');
title(['OneMaze, p=' num2str(pp) ' rho=' num2str(rr)])
[SEM, means] = BinnedMean(yData(goodDat),xData(goodDat),[0:0.1:1]);
hold on; errorbar([0.05:0.1:0.95],means,SEM,'k','LineWidth',1.5)

subplot(1,2,2)
xData = [twoEnvRemapReliValsWithin(:); twoEnvRemapReliValsAcross(:)];
yData = [twoEnvRemapRhoValsWithin(:); twoEnvRemapRhoValsAcross(:)];
goodDat = (~isnan(xData)) & ~(isnan(yData));
plot(xData,yData,'.','MarkerFaceColor',groupColors{2},'MarkerEdgeColor',groupColors{2})
xlabel('trialReli'); ylabel('rho');
[rr,pp] = corr(xData(goodDat),yData(goodDat),'type','Spearman');
title(['TwoMaze, p=' num2str(pp) ' rho=' num2str(rr)])
[SEM, means] = BinnedMean(yData(goodDat),xData(goodDat),[0:0.1:1]);
hold on; errorbar([0.05:0.1:0.95],means,SEM,'k','LineWidth',1.5)       
       
       
figure('Position',[370.5000 87.5000 852 636.5000]);
subplot(2,2,1)
xData = oneEnvRemapReliValsWithin;
yData = oneEnvRemapRhoValsWithin;
goodDat = (~isnan(xData)) & ~(isnan(yData));
plot(xData,yData,'.','MarkerFaceColor',groupColors{1},'MarkerEdgeColor',groupColors{1})
xlabel('trialReli'); ylabel('rho');
[rr,pp] = corr(xData(goodDat),yData(goodDat),'type','Spearman');
title(['OneMaze, Within, p=' num2str(pp) ' rho=' num2str(rr)])
[SEM, means] = BinnedMean(yData(goodDat),xData(goodDat),[0:0.1:1]);
hold on; errorbar([0.05:0.1:0.95],means,SEM,'k','LineWidth',1.5)

subplot(2,2,2)
xData = twoEnvRemapReliValsWithin;
yData = twoEnvRemapRhoValsWithin;
goodDat = (~isnan(xData)) & ~(isnan(yData));
plot(xData,yData,'.','MarkerFaceColor',groupColors{2},'MarkerEdgeColor',groupColors{2})
xlabel('trialReli'); ylabel('rho');
[rr,pp] = corr(xData(goodDat),yData(goodDat),'type','Spearman');
title(['TwoMaze, Within, p=' num2str(pp) ' rho=' num2str(rr)])
[SEM, means] = BinnedMean(yData(goodDat),xData(goodDat),[0:0.1:1]);
hold on; errorbar([0.05:0.1:0.95],means,SEM,'k','LineWidth',1.5)

subplot(2,2,3)
xData = oneEnvRemapReliValsAcross;
yData = oneEnvRemapRhoValsAcross;
goodDat = (~isnan(xData)) & ~(isnan(yData));
plot(xData,yData,'.','MarkerFaceColor',groupColors{1},'MarkerEdgeColor',groupColors{1})
xlabel('trialReli'); ylabel('rho');
[rr,pp] = corr(xData(goodDat),yData(goodDat),'type','Spearman');
title(['OneMaze, Across, p=' num2str(pp) ' rho=' num2str(rr)])
[SEM, means] = BinnedMean(yData(goodDat),xData(goodDat),[0:0.1:1]);
hold on; errorbar([0.05:0.1:0.95],means,SEM,'k','LineWidth',1.5)

subplot(2,2,4)
xData = twoEnvRemapReliValsAcross;
yData = twoEnvRemapRhoValsAcross;
goodDat = (~isnan(xData)) & ~(isnan(yData));
plot(xData,yData,'.','MarkerFaceColor',groupColors{2},'MarkerEdgeColor',groupColors{2})
xlabel('trialReli'); ylabel('rho');
[rr,pp] = corr(xData(goodDat),yData(goodDat),'type','Spearman');
title(['TwoMaze, Across, p=' num2str(pp) ' rho=' num2str(rr)])
[SEM, means] = BinnedMean(yData(goodDat),xData(goodDat),[0:0.1:1]);
hold on; errorbar([0.05:0.1:0.95],means,SEM,'k','LineWidth',1.5)

suptitleSL('Single-Cell Corr DayN-N+1 by DayN reliability')

% Comparisons here:
binsH = 0:0.1:1; nBins = numel(binsH)-1;

xxData{1} = oneEnvRemapReliValsWithin;
yyData{1} = oneEnvRemapRhoValsWithin;
labelsH{1} = 'One-Within';

xxData{2} = twoEnvRemapReliValsWithin;
yyData{2} = twoEnvRemapRhoValsWithin;
labelsH{2} = 'Two-Within';

xxData{3} = oneEnvRemapReliValsAcross;
yyData{3} = oneEnvRemapRhoValsAcross;
labelsH{3} = 'One-Across';

xxData{4} = twoEnvRemapReliValsAcross;
yyData{4} = twoEnvRemapRhoValsAcross;
labelsH{4} = 'Two-Across';

compsH = [1 3; 1 2; 2 4; 3 4];
for compI = 1:size(compsH,1)
    pVals = nan(1,nBins);
    hVals = nan(1,nBins);
        
    datA = compsH(compI,1);
    datB = compsH(compI,2);
        
    for binI = 1:nBins
        
        try
        [pVals(binI),hVals(binI)] = ranksum(...
            yyData{datA}((xxData{datA} >= binsH(binI)) & (xxData{datA} < binsH(binI+1))),...
            yyData{datB}((xxData{datB} >= binsH(binI)) & (xxData{datB} < binsH(binI+1))) );
        end
        
    end
    
    disp([labelsH{datA} ' vs ' labelsH{datB}]);
    pVals
end

% Same as above, but reli change
bbinsH = [-0.55:0.1:0.55];
figure('Position',[370.5000 87.5000 852 636.5000]);
subplot(2,2,1)
xData = oneEnvRemapReliChangeWithin;
yData = oneEnvRemapRhoValsWithin;
goodDat = (~isnan(xData)) & ~(isnan(yData));
plot(xData,yData,'.','MarkerFaceColor',groupColors{1},'MarkerEdgeColor',groupColors{1})
xlabel('trialReli Change'); ylabel('rho');
[rr,pp] = corr(xData(goodDat & (xData < 0)),yData(goodDat& (xData < 0)),'type','Spearman');
[rr2,pp2] = corr(xData(goodDat & (xData > 0)),yData(goodDat & (xData > 0)),'type','Spearman');
title({'TwoMaze, Across'; ['Pos: p=' num2str(pp) ' rho=' num2str(rr)];['Neg: p=' num2str(pp2) ' rho=' num2str(rr2)]})
[SEM, means] = BinnedMean(yData(goodDat),xData(goodDat),bbinsH);
hold on; errorbar([-0.5:0.1:0.5],means,SEM,'k','LineWidth',1.5)
MakePlotPrettySL(gca);

subplot(2,2,2)
xData = twoEnvRemapReliChangeWithin;
yData = twoEnvRemapRhoValsWithin;
goodDat = (~isnan(xData)) & ~(isnan(yData));
plot(xData,yData,'.','MarkerFaceColor',groupColors{2},'MarkerEdgeColor',groupColors{2})
xlabel('trialReli change'); ylabel('rho');
[rr,pp] = corr(xData(goodDat& (xData < 0)),yData(goodDat& (xData < 0)),'type','Spearman');
[rr2,pp2] = corr(xData(goodDat & (xData > 0)),yData(goodDat & (xData > 0)),'type','Spearman');
title({'TwoMaze, Across'; ['Pos: p=' num2str(pp) ' rho=' num2str(rr)];['Neg: p=' num2str(pp2) ' rho=' num2str(rr2)]})
[SEM, means] = BinnedMean(yData(goodDat),xData(goodDat),bbinsH);
hold on; errorbar([-0.5:0.1:0.5],means,SEM,'k','LineWidth',1.5)
MakePlotPrettySL(gca);

subplot(2,2,3)
xData = oneEnvRemapReliChangeAcross;
yData = oneEnvRemapRhoValsAcross;
goodDat = (~isnan(xData)) & ~(isnan(yData));
plot(xData,yData,'.','MarkerFaceColor',groupColors{1},'MarkerEdgeColor',groupColors{1})
xlabel('trialReli change'); ylabel('rho');
[rr,pp] = corr(xData(goodDat & (xData < 0)),yData(goodDat & (xData < 0)),'type','Spearman');
[rr2,pp2] = corr(xData(goodDat & (xData > 0)),yData(goodDat & (xData > 0)),'type','Spearman');
title({'TwoMaze, Across'; ['Pos: p=' num2str(pp) ' rho=' num2str(rr)];['Neg: p=' num2str(pp2) ' rho=' num2str(rr2)]})
[SEM, means] = BinnedMean(yData(goodDat),xData(goodDat),bbinsH);
hold on; errorbar([-0.5:0.1:0.5],means,SEM,'k','LineWidth',1.5)
MakePlotPrettySL(gca);

subplot(2,2,4)
xData = twoEnvRemapReliChangeAcross;
yData = twoEnvRemapRhoValsAcross;
goodDat = (~isnan(xData)) & ~(isnan(yData));
plot(xData,yData,'.','MarkerFaceColor',groupColors{2},'MarkerEdgeColor',groupColors{2})
xlabel('trialReli change'); ylabel('rho');
[rr,pp] = corr(xData(goodDat & (xData < 0)),yData(goodDat & (xData < 0)),'type','Spearman');
[rr2,pp2] = corr(xData(goodDat & (xData > 0)),yData(goodDat & (xData > 0)),'type','Spearman');
title({'TwoMaze, Across'; ['Pos: p=' num2str(pp) ' rho=' num2str(rr)];['Neg: p=' num2str(pp2) ' rho=' num2str(rr2)]})
[SEM, means] = BinnedMean(yData(goodDat),xData(goodDat),bbinsH);
hold on; errorbar([-0.5:0.1:0.5],means,SEM,'k','LineWidth',1.5)
MakePlotPrettySL(gca);

suptitleSL('Single-Cell Corr DayN-N+1 by reliability change')


%{            
for dpI = 1:numDayPairs
    figure;
    subplot(1,2,1)
    yData = oneEnvRemapRho{dpI};
    xData = oneEnvRemapReli{dpI};
    goodDat = (~isnan(xData)) & ~(isnan(yData));
    %yData = oneEnvRemapP{dpI};
    plot(xData,yData,'.','MarkerFaceColor',groupColors{1},'MarkerEdgeColor',groupColors{1})
    xlabel('trialReli'); ylabel('rho');
    [rr,pp] = corr(xData(goodDat),yData(goodDat),'type','Spearman');
    title(['OneMaze, p=' num2str(pp) ' rho=' num2str(rr)])
    
    subplot(1,2,2)
    yData = twoEnvRemapRho{dpI};
    %yData = twoEnvRemapP{dpI};
    xData = twoEnvRemapReli{dpI};
    goodDat = (~isnan(xData)) & ~(isnan(yData));
    plot(xData(goodDat),yData(goodDat),'.','MarkerFaceColor',groupColors{2},'MarkerEdgeColor',groupColors{2})
    xlabel('trialReli'); ylabel('rho');
    [rr,pp] = corr(xData(goodDat),yData(goodDat),'type','Spearman');
    title(['TwoMaze, p=' num2str(pp) ' rho=' num2str(rr)])
    
    suptitleSL(num2str(dayPairsForward(dpI,:)))
end
%}
%Each Cond
for dpI = 1:numDayPairs
    figure;
    for condI = 1:numel(condsUse)
        subplot(2,4,condI*2-1)
        xData = oneEnvRemapReliEach{dpI,condI};
        yData = oneEnvRemapRhoEach{dpI,condI};
        goodDat = (~isnan(xData)) & ~(isnan(yData));
        plot(xData(goodDat),yData(goodDat),'.','MarkerFaceColor',groupColors{1},'MarkerEdgeColor',groupColors{1})
        xlabel('trialReli'); ylabel('rho');
        [rr,pp] = corr(xData(goodDat),yData(goodDat),'type','Spearman');
        title(['p=' num2str(pp) ' rho=' num2str(rr)])

        subplot(2,4,condI*2)
        xData = twoEnvRemapReliEach{dpI,condI};
        yData = twoEnvRemapRhoEach{dpI,condI};
        goodDat = (~isnan(xData)) & ~(isnan(yData));
        plot(xData(goodDat),yData(goodDat),'.','MarkerFaceColor',groupColors{2},'MarkerEdgeColor',groupColors{2})
        xlabel('trialReli'); ylabel('rho');
        [rr,pp] = corr(xData(goodDat),yData(goodDat),'type','Spearman');
        title(['p=' num2str(pp) ' rho=' num2str(rr)])
    end
    suptitleSL(num2str(dayPairsForward(dpI,:)))
end
% How to use p values here?

% Each cond



%% Separate states

figure;
for dpgI = 1:3
    for condI = 1:3
        subplot(3,3,condI+3*(dpgI-1))
        %plot(oneEnvDGcorrsMean{dpgI}{cpI},groupColors{1})
        errorbar(oneEnvDGcorrsMean{dpgI}{condI},oneEnvDGcorrsSEM{dpgI}{condI},'Color',groupColors{1},'LineWidth',2)
        hold on
        %plot(twoEnvDGcorrsMean{dpgI}{cpI},groupColors{2})
        errorbar(twoEnvDGcorrsMean{dpgI}{condI},twoEnvDGcorrsSEM{dpgI}{condI},'Color',groupColors{2},'LineWidth',2)
        title([dayGroupLabels{dpgI} ' ' armLabels{condsHere(condI)}])
        xlabel('Bin'); ylabel('Corr. (rho)')
        MakePlotPrettySL(gca);
    end
end
suptitleSL('PV corrs averaged across all day pairs for epoch indicated')


locations = [0 0.5 1];
colors = [1.0000    0.0    0.000;
            1 1 1;
            0    0.45   0.74];           
newGradient = GradientMaker(colors,locations);

oneEnvDGmeanAll = cell2mat(oneEnvDGmeanAgg);
twoEnvDGmeanAll = cell2mat(twoEnvDGmeanAgg);
plotBins.X = []; plotBins.Y = [];
for condI = 1:length(condsUse)
    plotBins.X = [plotBins.X; lgPlotHere{condsUse(condI)}.X];
    plotBins.Y = [plotBins.Y; lgPlotHere{condsUse(condI)}.Y];
end
%{
    figure;
    for binI = 1:size(plotBins.X,1)
        text(mean(plotBins.X(binI,:)),mean(plotBins.Y(binI,:)),num2str(binI))
        hold on
    end
    xlim([min(plotBins.X(:))-5, max(plotBins.X(:))+5])
    ylim([min(plotBins.Y(:))-5, max(plotBins.Y(:))+5])
    title('PlotBins Order')

    figure;


    title('tMap / pvcorr bin order')
%}
[figHand] = PlusMazePVcorrHeatmap3(oneEnvDGmeanAll,plotBins,newGradient,[-0.35, 0.35],dayGroupLabels);
for ii = 1:3; subplot(1,3,ii); MakePlotPrettySL(gca); end
suptitleSL('One-Maze')

[figHand] = PlusMazePVcorrHeatmap3(twoEnvDGmeanAll,plotBins,newGradient,[-0.35, 0.35],dayGroupLabels);
for ii = 1:3; subplot(1,3,ii); MakePlotPrettySL(gca); end
suptitleSL('Two-Maze')

labelsH = {'0.35','0','-0.35'};
PlotColorbar(newGradient,labelsH)


%% Reinstatement

% Aggregate aggregate
oneEnvABall = [];
oneEnvCDall = [];
twoEnvABall = [];
twoEnvCDall = [];
for dpI = 1:numDayTrips
    pData = oneEnvRhosABAggAll{dpI};
    tData = oneEnvRhosCDAggAll{dpI};
    oneEnvABall = [oneEnvABall; pData];
    oneEnvCDall = [oneEnvCDall; tData];
    
    pData = twoEnvRhosABAggAll{dpI};
    tData = twoEnvRhosCDAggAll{dpI};
    twoEnvABall = [twoEnvABall; pData];
    twoEnvCDall = [twoEnvCDall; tData];
end

figure; 
yy = cdfplot(oneEnvCDall - oneEnvABall);
%yy.LineStyle = ':';
yy.Color = groupColors{1};
yy.DisplayName = 'One-Maze';
yy.LineWidth = 2;
hold on
zz = cdfplot(twoEnvCDall - twoEnvABall);
%zz.LineStyle = '--';
zz.Color = groupColors{2};
zz.DisplayName = 'Two-Maze';
zz.LineWidth = 2;
xlabel('Correlation Difference')
title('corr(Turn1, Turn2) - corr(Turn1, Place)')
ylabel('Cumulative proportion')
[h,pKS,kstat] = kstest2(twoEnvCDall - twoEnvABall,oneEnvCDall - oneEnvABall);
text(-1.5,0.7,['KS p = ' num2str(pKS)])
text(-1.5,0.8,['KS stat = ' num2str(kstat)])
MakePlotPrettySL(gca);

figure;
bbins = linspace(-2,2,40);
subplot(2,1,1)
yyDat = oneEnvCDall - oneEnvABall;
h = histogram(yyDat,bbins,'Normalization','probability');
h.FaceColor = groupColors{1};
xlabel('corr(Turn1, Turn2) - corr(Turn1, Place)')
ylabel('Proportion / Active Cells')
title('OneMaze')
ylim([0 0.15])
xlim([-2 2])
MakePlotPrettySL(gca);

subplot(2,1,2)
zzDat = twoEnvCDall - twoEnvABall;
i = histogram(zzDat,bbins,'Normalization','probability');
i.FaceColor = groupColors{2};
xlabel('corr(Turn1, Turn2) - corr(Turn1, Place)')
ylabel('Proportion / Active Cells')
title('TwoMaze')
ylim([0 0.15])
xlim([-2 2])
MakePlotPrettySL(gca);
% searchString:reinstatement

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
    ee = aa & dd;
    
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
    ee = aa & dd;
    
    twoEnvEE(dpI) = sum(ee)/length(ee);
    
end
figure('Position',[247 246.5000 252.5000 423.5000]); 
for ii = 1:27; plot([1 2],[oneEnvEE(ii) twoEnvEE(ii)],'Color',[0.4 0.4 0.4]); hold on; end
[p,h] = signrank(oneEnvEE,twoEnvEE)
title({'Pct cells with higher rho Turn1-Turn2 than Turn1-Place';'p<0.05 only';['signed rank p= ' num2str(p)]})
set(gca,'XTick',[1 2])
set(gca,'XTickLabels',{'OneMaze','TwoMaze'})
xlim([0.75 2.25])

%% Finding cells for example reinstatement
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

mouseI = 1;
dayTripletCheck = [3 5 8];
dayPairA = find(sum(corrsLoaded.allDayPairs == dayTripletCheck([1 2]),2)==2);
dayPairB = find(sum(corrsLoaded.allDayPairs == dayTripletCheck([1 3]),2)==2);
checkCells = ...
sum(trialReli{mouseI}(:,dayTripletCheck(1),[1 3 4]) > 0.25,3) >= 1 &...
sum(trialReli{mouseI}(:,dayTripletCheck(2),[1 3 4]) > 0.25,3) >= 1 &...
sum(trialReli{mouseI}(:,dayTripletCheck(3),[1 3 4]) > 0.25,3) >= 1 &...
sum(trialReli{mouseI}(:,dayTripletCheck(1),2) == 0) &...
sum(trialReli{mouseI}(:,dayTripletCheck(2),2) == 0) &...
sum(trialReli{mouseI}(:,dayTripletCheck(3),2) == 0) &...
corrsLoaded.singleCellThreeCorrsRho{mouseI}{1}{dayPairA} < -0.1 &...
corrsLoaded.singleCellThreeCorrsRho{mouseI}{1}{dayPairB} > 0.75;
checkCells = find(checkCells)
%  corrsLoaded.singleCellThreeCorrsRho{mouseI}{1}{dayPairB}(find(checkCells))

load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'),'tbtLapCorrect')

 %mouseI = 5: [3 6 8], 126     [3 5 8], 61, 245, 712    
 %
cellPlot = checkCells(6); 
PlotDotplotDoublePlus2(tbtLapCorrect,cellPlot,[1 2],dayTripletCheck(1),'dynamic',[],3) 
title(['Mouse ' num2str(mouseI) ', cell ' num2str(cellPlot) ', day ' num2str(dayTripletCheck(1))])
set(gcf,'Position',[21.6667 203.6667 432.6667 344.0000]); axis equal
PlotDotplotDoublePlus2(tbtLapCorrect,cellPlot,[1 2],dayTripletCheck(2),'dynamic',[],3) 
title(['Mouse ' num2str(mouseI) ', cell ' num2str(cellPlot) ', day ' num2str(dayTripletCheck(2))])
set(gcf,'Position',[495.6667 220.3333 432.6667 344.0000]); axis equal
PlotDotplotDoublePlus2(tbtLapCorrect,cellPlot,[1 2],dayTripletCheck(3),'dynamic',[],3) 
title(['Mouse ' num2str(mouseI) ', cell ' num2str(cellPlot) ', day ' num2str(dayTripletCheck(3))])
set(gcf,'Position',[891 212.3333 432.6667 344.0000]); axis equal

msgTxt = {['Corr day ' num2str(dayTripletCheck(1)) ' v ' num2str(dayTripletCheck(2)) ' = ' num2str(corrsLoaded.singleCellThreeCorrsRho{mouseI}{1}{dayPairA}(cellPlot))];...
          ['Corr day ' num2str(dayTripletCheck(1)) ' v ' num2str(dayTripletCheck(3)) ' = ' num2str(corrsLoaded.singleCellThreeCorrsRho{mouseI}{1}{dayPairB}(cellPlot))] };
msgbox(msgTxt)

close all

mouseI = 5; cellPlot = 245
for ii = 2:9
PlotDotplotDoublePlus2(tbtLapCorrect,cellPlot,[1 2],ii,'dynamic',[],3) 
title(['Mouse ' num2str(mouseI) ', cell ' num2str(cellPlot) ', day ' num2str(ii)])
end

%% Reinstatement Single-cell ratemap corr all day triplets
for groupI = 1:2
figure;
for dpI = 1:numDayTrips
    subplot(3,9,dpI)
    switch groupI
        case 1
            pData = oneEnvRhosABAggAll{dpI};
            tData = oneEnvRhosCDAggAll{dpI};
        case 2
            pData = twoEnvRhosABAggAll{dpI};
            tData = twoEnvRhosCDAggAll{dpI};
    end
    yy = cdfplot(pData);
    yy.Color = groupColors{groupI};
    yy.LineStyle = ':';
    yy.LineWidth = 1.5;
    %yy.DisplayName = 'Turn1-Place';
    yy.DisplayName = num2str(oneTwoPairs(dpI,:));
    
    hold on
    
    zz = cdfplot(tData);
    zz.Color = groupColors{groupI};
    zz.LineStyle = '--';
    zz.LineWidth = 1.5;
    %zz.DisplayName = 'Turn1-Turn2';
    zz.DisplayName = num2str(oneThreePairs(dpI,:));
    
    [h,pKS] = kstest2(pData(:),tData(:));
    [p,h] = ranksum(pData(:),tData(:));
    
    %disp(['Day trip ' num2str(allTriplePairs(dpI,:)) ', Ranksum p = ' num2str(p) ', KS p = ' num2str(pKS)])
    
    RSps(dpI) = p;
    KSps(dpI) = pKS;
    
    legend('location','NW')
    title(num2str(allTriplePairs(dpI,:)))
end
suptitleSL(['All day triplets, cumulative rhos, group ' num2str(groupI)])
end
xlabel('Rho')
ylabel('ECDF')

figure; 
for groupI = 1:2
subplot(1,2,groupI)
for dpI = 1:numDayTrips
    switch groupI
        case 1
            pData = oneEnvRhosABAggAll{dpI};
            tData = oneEnvRhosCDAggAll{dpI};
        case 2
            pData = twoEnvRhosABAggAll{dpI};
            tData = twoEnvRhosCDAggAll{dpI};
    end
    yy = cdfplot(pData);
    yy.Color = groupColors{groupI};
    yy.LineStyle = ':';
    yy.LineWidth = 1.5;
    %yy.DisplayName = 'Turn1-Place';
    yy.DisplayName = num2str(oneTwoPairs(dpI,:));
    
    hold on
    
    zz = cdfplot(tData);
    zz.Color = groupColors{groupI};
    zz.LineStyle = '--';
    zz.LineWidth = 1.5;
    %zz.DisplayName = 'Turn1-Turn2';
    zz.DisplayName = num2str(oneThreePairs(dpI,:));
    
    [h,pKS] = kstest2(pData(:),tData(:));
    [p,h] = ranksum(pData(:),tData(:));
    
    %disp(['Day trip ' num2str(allTriplePairs(dpI,:)) ', Ranksum p = ' num2str(p) ', KS p = ' num2str(pKS)])
    
    RSps(dpI) = p;
    KSps(dpI) = pKS;
    
    legend('location','NW')
    title(num2str(allTriplePairs(dpI,:)))
end
end

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

title('Cumulative Magnitude of Turn-place-turn COM change differences')   

%% Absolute remapping

figure; 
subplot(1,3,1)
oneData = oneHaveBoth;
twoData = twoHaveBoth;
plot(ones(size(oneData)),oneData,'.','MarkerSize',12,'MarkerFaceColor',groupColors{1})
hold on
plot(2*ones(size(twoData)),twoData,'.','MarkerSize',12,'MarkerFaceColor',groupColors{2})
title('Pct cells active both days')

subplot(1,3,2)
oneData = oneStartFiring;
twoData = twoStartFiring;
plot(ones(size(oneData)),oneData,'.','MarkerSize',12,'MarkerFaceColor',groupColors{1})
hold on
plot(2*ones(size(twoData)),twoData,'.','MarkerSize',12,'MarkerFaceColor',groupColors{2})
title('Pct cells start firing')

subplot(1,3,3)
oneData = oneStopFiring;
twoData = twoStopFiring;
plot(ones(size(oneData)),oneData,'.','MarkerSize',12,'MarkerFaceColor',groupColors{1})
hold on
plot(2*ones(size(twoData)),twoData,'.','MarkerSize',12,'MarkerFaceColor',groupColors{2})
title('Pct cells stop firing')

for condI = 1:numConds
figure; 
subplot(1,3,1)
oneData = oneHaveBothEach{condI};
twoData = twoHaveBothEach{condI};
plot(ones(size(oneData)),oneData,'.','MarkerSize',12,'MarkerFaceColor',groupColors{1})
hold on
plot(2*ones(size(twoData)),twoData,'.','MarkerSize',12,'MarkerFaceColor',groupColors{2})
title('Pct cells active both days')

subplot(1,3,2)
oneData = oneStartFiringEach{condI};
twoData = twoStartFiringEach{condI};
plot(ones(size(oneData)),oneData,'.','MarkerSize',12,'MarkerFaceColor',groupColors{1})
hold on
plot(2*ones(size(twoData)),twoData,'.','MarkerSize',12,'MarkerFaceColor',groupColors{2})
title('Pct cells start firing')

subplot(1,3,3)
oneData = oneStopFiringEach{condI};
twoData = twoStopFiringEach{condI};
plot(ones(size(oneData)),oneData,'.','MarkerSize',12,'MarkerFaceColor',groupColors{1})
hold on
plot(2*ones(size(twoData)),twoData,'.','MarkerSize',12,'MarkerFaceColor',groupColors{2})
title('Pct cells stop firing')

suptitleSL(upper(armLabels{condsUse(condI)}))
end

% Change in pct cells on arms
figure;
for condI = 1:numConds
    oneData = oneArmPctChange(:,condI);
    twoData = twoArmPctChange(:,condI);
    plot((0.8+(condI-1))*ones(size(oneData)),oneData,'.','MarkerSize',12,'MarkerFaceColor',groupColors{1},'MarkerEdgeColor',groupColors{1})
    hold on
    plot((1.2+(condI-1))*ones(size(twoData)),twoData,'.','MarkerSize',12,'MarkerFaceColor',groupColors{2},'MarkerEdgeColor',groupColors{2})
end

%% Remapping 3-7, 3-8, 7-8

%COM change:
gg = figure('Position',[186.5000 310.5000 1.1485e+03 315]);
for dpI = 1:numDayPairs
    subplot(1,numDayPairs,dpI)

    oneData = oneEnvCOMchanges{dpI}(oneEnvCOMchangesCellsUse{dpI});
    twoData = twoEnvCOMchanges{dpI}(twoEnvCOMchangesCellsUse{dpI});
    
    yy = cdfplot(oneData); 
    yy.Color = groupColors{1}; %yy.Color = 'b';
    yy.LineWidth = 2;
    hold on
    zz = cdfplot(twoData); 
    zz.Color = groupColors{2}; %zz.Color = 'r'; 
    zz.LineWidth = 2; 

    xlabel('COM change (bin)'); ylabel('Cumulative Proportion')
       
    [p,h] = ranksum(oneData,twoData);
    [hKS,pKS,ksStat] = kstest2(oneData,twoData);
    text(4.5,0.5,['RS p=' num2str(p)])
    text(4.5,0.65,['KS p=' num2str(pKS)])
    text(4.5,0.8,['KS p=' num2str(ksStat)])
    title(['Yithin-arm COM changes, day pair ' num2str(dayPairsForward(dpI,:))])
    
    MakePlotPrettySL(gca)
    
    ksPvals(dpI) = pKS;
end

% Rate remapping
label = 'mean firing rate pct changes';
gg = figure('Position',[186.5000 310.5000 1.1485e+03 315]);
for dpI = 1:numDayPairs
    subplot(1,3,dpI)
    
    oneCellsUse = oneEnvMeanRateCellsUse{dpI}; % This adds the >=3 laps one day; says max but it's the same
    changesHereOne = oneEnvMeanRatePctChange{dpI}; 
    changesHereOne(oneEnvFiredBoth{dpI}==0) = NaN;
    %oneData = changesHereOne;
    oneData = changesHereOne(oneCellsUse);
    
    twoCellsUse = twoEnvMeanRateCellsUse{dpI}; 
    changesHereTwo = twoEnvMeanRatePctChange{dpI}; 
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

    [h,pKS] = kstest2(oneData(:),twoData(:));
    [p,h] = ranksum(oneData(:),twoData(:));
    text(0.4,0.5,['ranksum p=' num2str(p)])
    text(0.4,0.65,['KS p= ' num2str(pKS)])
    
    title(['With arm mean rate changes days ' num2str(dayPairsForward(dpI,:))])
    
    MakePlotPrettySL(gca);
end

% Rate map corrs
gg = figure('Position',[186.5000 310.5000 1.1485e+03 315]);
for dpI = 1:numDayPairs
    subplot(1,numDayPairs,dpI)
    
    dataOne = oneEnvCorrsAll{dpI};
    dataTwo = twoEnvCorrsAll{dpI};
    %dataOne = abs(oneEnvCorrsSingle{dpI});
    %dataTwo = abs(twoEnvCorrsSingle{dpI});
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
    
    MakePlotPrettySL(gca);
end
suptitleSL('Single Neuron Ratemap correlations')

%% PV corrs plot 3-7, 3-8, 7-8

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
        
        %disp(['For days ' num2str(dayPairs(dpI,:)) ' N vs ' armLabels{condI} ', p = ' num2str(pp)]) '+/-' std(dataB)])
    end
end
end



%% Single-cell remapping 3-7, 3-8, 7-8 arms individually

% COM shifts
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


% Rate remapping
for dpI = 1:numDayPairs
    gg = figure('Position',[530 303 450 370.5000]);
    
    for condI = 1:numConds
        subplot(2,2,condI)
        oneCellsUse = oneEnvMeanRateCellsUse{dpI}(:,condI); % This adds the >=3 laps one day; says max but it's the same
        changesHereOne = oneEnvMeanRatePctChange{dpI}(:,condI); 
        changesHereOne(oneEnvFiredBoth{dpI}(:,condI)==0) = NaN;
        oneData = changesHereOne(oneCellsUse);

        twoCellsUse = twoEnvMeanRateCellsUse{dpI}(:,condI); 
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
        
        MakePlotPrettySL(gca);
    end
    
    suptitleSL(['Distribution of within-arm ' label ', day pair ' num2str(dayPairsForward(dpI,:))])
end


% Single neuron rate map corrs
for dpI = 1:numDayPairs
    figure('Position',[420.5000 238 531 442]);
    for condI = 1:numConds
        subplot(2,2,condI)
        %dataOne = abs(oneEnvCorrsEach{dpI,condI});
        %dataTwo = abs(twoEnvCorrsEach{dpI,condI});
        dataOne = oneEnvCorrsEach{dpI,condI};
        dataTwo = twoEnvCorrsEach{dpI,condI};
        yy = cdfplot(dataOne);
        yy.Color = groupColors{1};
        yy.LineWidth = 2;
        hold on
        
        zz = cdfplot(dataTwo);
        zz.Color = groupColors{2};
        zz.LineWidth = 2;
        
        xlabel('Rho')
        ylabel('ECDF')
        title(upper(turnArmLabels{condI}))
        
        [h,pKS,ksstats] = kstest2(dataOne,dataTwo);
        [p,h] = ranksum(dataOne,dataTwo);
        text(0.4,0.5,['ranksum p=' num2str(round(p,3))])%'h=' num2str(h) ',
        text(0.4,0.65,['KS p= ' num2str(pKS)])
        text(0.4,0.8,['KS stat ' num2str(ksstats)])
        MakePlotPrettySL(gca);
    end 
    suptitleSL(['Days ' num2str(dayPairsForward(dpI,:))])
end

%% Pooled COM change across arms

% Greater N than each other
for dpI = 1:numDayPairs
    gg = figure('Position', [418.5000 326.5000 810.5000 299.5000]);
    
    oneCOM = oneEnvCOMchanges{dpI};
    oneCells = oneEnvCOMchangesCellsUse{dpI}; % above lap activity threshold
    
    for condI = 2:numConds
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
        zz.DisplayName = upper(turnArmLabels{condI});

        xlabel('COM change'); ylabel('Cumulative Proportion')
        [p,h] = ranksum(NWoneData,SEoneData);
        [hKS,pKS] = kstest2(NWoneData,SEoneData);
        %text(4.5,0.5,['p=' num2str(round(p,3))])
        text(4.5,0.5,['RS p=' num2str(p)])
        text(4.5,0.65,['KS p=' num2str(pKS)])
        legend('Location','NW')

        title(['N vs. ' upper(turnArmLabels{condI})])
        
        MakePlotPrettySL(gca);
    end
    suptitleSL(['Days ' num2str(dayPairsForward(dpI,:))])
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

% More in North than others
for dpI = 1:numDayPairs
    gg = figure('Position', [418.5000 326.5000 810.5000 299.5000]);
    
    for condI = 2:numConds
        subplot(1,numConds-1,condI-1)
        
        oneCellsUse = oneEnvMeanRateCellsUse{dpI}(:,condI); % This adds the >=3 laps one day; says max but it's the same
        changesHereOne = oneEnvMeanRatePctChange{dpI}(:,condI); 
        changesHereOne(oneEnvFiredBoth{dpI}(:,condI)==0) = NaN;
        oneData = changesHereOne(oneCellsUse);
        
        northCellsUse = oneEnvMeanRateCellsUse{dpI}(:,1);
        northChangesHereOne = oneEnvMeanRatePctChange{dpI}(:,1); 
        northChangesHereOne(oneEnvFiredBoth{dpI}(:,1)==0) = NaN;
        northData = northChangesHereOne(northCellsUse);
        
        yy = cdfplot(oneData(:)); yy.Color = groupColors{1}; 
        yy.LineWidth = 2;
        yy.LineStyle = ':';
        yy.DisplayName = upper(turnArmLabels{condI});
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
        %legend('location','NW')
        title(['N vs. ' upper(armLabels{condI})])
        
        MakePlotPrettySL(gca)
    end
    
    suptitleSL(['Distribution of within-arm ' label ', day pair ' num2str(dayPairsForward(dpI,:))])
end

% Each cond vs. Each other cond
for dpI = 1:numDayPairs
    for condJ = 1:numConds
    for condI = 1:numConds
        oneCellsUse = oneEnvMeanRateCellsUse{dpI}(:,condI); % This adds the >=3 laps one day; says max but it's the same
        changesHereOne = oneEnvMeanRatePctChange{dpI}(:,condI); 
        changesHereOne(oneEnvFiredBoth{dpI}(:,condI)==0) = NaN;
        oneData = changesHereOne(oneCellsUse);
        
        northCellsUse = oneEnvMeanRateCellsUse{dpI}(:,condJ);
        northChangesHereOne = oneEnvMeanRatePctChange{dpI}(:,condJ); 
        northChangesHereOne(oneEnvFiredBoth{dpI}(:,condJ)==0) = NaN;
        northData = northChangesHereOne(northCellsUse);
        
        [h,ppKS{dpI}(condJ,condI),ksstats] = kstest2(oneData(:),northData(:));
        [ppRS{dpI}(condJ,condI),h] = ranksum(oneData(:),northData(:));
    end
    end
end

% Same cell more in North than others
for dpI = 1:numDayPairs
    gg = figure;%('Position'); %,[428 376 590 515]);%[428 613 897 278]
    
    
    for condI = 2:numConds
        subplot(1,numConds-1,condI-1)
        
        oneCellsUse = oneEnvMeanRateCellsUse{dpI}(:,condI) & oneEnvFiredBoth{dpI}(:,condI); 
            % This adds the >=3 laps one day; says max but it's the same
        changesHereOne = oneEnvMeanRatePctChange{dpI}(:,condI); 
        changesHereOne(oneEnvFiredBoth{dpI}(:,condI)==0) = NaN;
        
        northCellsUse = oneEnvMeanRateCellsUse{dpI}(:,1) & oneEnvFiredBoth{dpI}(:,1);
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


%% Single cell corrs



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
        
        [h,pKS,ksstats] = kstest2(dataOne,dataTwo);
        [p,h] = ranksum(dataOne,dataTwo);
        text(0.4,0.5,['ranksum p=' num2str(round(p,3))])%'h=' num2str(h) ',
        text(0.4,0.65,['KS p= ' num2str(pKS)])
        text(0.4,0.8,['KS stat ' num2str(ksstats)])
        
        title(['N vs. ' upper(armLabels{condI})])
        
        MakePlotPrettySL(gca);
    end 
    suptitleSL(['Days ' num2str(dayPairsForward(dpI,:))])
end


for dpI = 1:numDayPairs
    for condJ = 1:numConds
    for condI = 1:numConds
        
        dataOne = abs(oneEnvCorrsEach{dpI,condJ});
        dataTwo = abs(twoEnvCorrsEach{dpI,condI});
       
        [h,ppKS{dpI}(condJ,condI),ksstats] = kstest2(dataOne,dataTwo);
        [p,h] = ranksum(dataOne,dataTwo);
        text(0.4,0.5,['ranksum p=' num2str(round(p,3))])%'h=' num2str(h) ',
        text(0.4,0.65,['KS p= ' num2str(pKS)])
        text(0.4,0.8,['KS stat ' num2str(ksstats)])
        
        title(['N vs. ' upper(armLabels{condI})])
        
        MakePlotPrettySL(gca);
    end 
    suptitleSL(['Days ' num2str(dayPairsForward(dpI,:))])
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
    %dataOne = abs(oneEnvCorrsSingle{dpI});
    %dataTwo = abs(twoEnvCorrsSingle{dpI});
    dataOne = oneEnvCorrsSingle{dpI};
    dataTwo = twoEnvCorrsSingle{dpI};
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
    MakePlotPrettySL(gca);
    
end
suptitleSL('Single Neuron Ratemap correlations')

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