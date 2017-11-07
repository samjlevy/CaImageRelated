figure;
for cellI = 1:length(NeuronImage)
B = bwboundaries(NeuronImage{cellI});
hold on
plot(B{1,1}(:,2),500-B{1,1}(:,1),'LineWidth',1.5)
end
title('Cell Outlines 160831')


duration = 12.5*60*20-1;
tStart = 10000;
cellsUse = [xx xx xx xx xx xx xx];
lineOffset = 1.25
hh = figure;
for cellJ = 1:length(cellsUse)
    hold on
    traceUse = NeuronTraces.LPtrace(tStart:tStart+duration);
    traceUse = traceUse - min(traceUse);
    traceUse = traceUse/max(traceUse);
    plot(1:duration,traceUse+lineOffset)
end
title('Fluoresence Over Time')
xlabel('Minutes')
hh.YTickLabels
hh.XTickLabels

%%
load('trialbytrial.mat')
lapThresh = 3;
reliableThresh = 0.25;

[LRsel, STsel] = LRSTselectivity(trialbytrial);
figure; 
subplot(1,2,1);
plot(LRsel.spikes(:,1),STsel.spikes(:,1),'o')
xlim([-1.03 1.03])
ylim([-1.03 1.03])
xlabel('Left/Right selectivity')
ylabel('Study/Test selectivity')
title('Single Cell Selectivity, Day 1')

%figure;
subplot(1,2,2);
for aa=1:11
    hold on
    plot(LRsel.spikes(:,aa),STsel.spikes(:,aa),'o')
end
xlim([-1.03 1.03])
ylim([-1.03 1.03])
xlabel('Left/Right selectivity')
ylabel('Study/Test selectivity')
title('Single Cell Selectivity, Days 1-11')


cellsTry = [14 37 38 51 55 68 87 89 134 188 175 162 119 111 240 312 314 373 287];
cellsTry = [38   14 37 89 111 55 87 134 188 240 ];%287 175
cellsTry = [77 96 146 162 256] 
for ff = 1:length(cellsTry)
figure; 
plot(LRsel.spikes(cellsTry(ff),:),STsel.spikes(cellsTry(ff),:),'-o','LineWidth',1.5,'MarkerSize',3)
title(['cell ' num2str(cellsTry(ff))]); ylim([-1 1]); xlim([-1 1])
end

plotColors = ...
[ 1.0000         0         0
    0.8500    0.3250    0.0980;...
    0.9290    0.6540    0.0250;...
    0.4940    0.1840    0.5560;...
    0.4660    0.6740    0.1880;...
    0.3010    0.7450    0.9330;...
    .9000     0.90000    0.000;...
         0    0.5000         0;...
     0    0.4470    0.7410;...
     0    0.7500    0.7500;...         
    ]

figure;
for pc = 1:size(plotColors,1)
    rectangle('Position',[0+5*(pc-1) 0 5 5],'FaceColor',plotColors(pc,:))
end
    % 0.6350    0.0780    0.1840;...
cellsTry = [  14 37 89 111 55 87 134  240 146];%287 175  38
figure;
for ff = 1:length(cellsTry)
    hold on
    plot(LRsel.spikes(cellsTry(ff),:),STsel.spikes(cellsTry(ff),:),'-o','LineWidth',1.5,'MarkerSize',3,'Color',plotColors(ff,:))
end
ylim([-1.02 1.02]); xlim([-1.02 1.02])
xlabel('LEFT          preferred side                RIGHT')
ylabel('STUDY          preferred task                TEST')
title('Selectivity over days, cells: 14, 37, 55, 89, 111, 134, 146, 240')

numDays = 11;
h = figure;
jetTrips = colormap(jet);
close(h)
jetUse = round(linspace(1,64,numDays));
plotColors = jetTrips(jetUse,:);

figure;
rectSize = 5;
for ss = 1:numDays
    hold on
rectangle('Position',[rectSize*(ss-1) 0 rectSize rectSize],'FaceColor',plotColors(ss,:))
end
xlim([-10 rectSize*ss+10]); ylim([-5 rectSize+5]);
   

threshes = 0:0.05:1;
for day = 1:size(LRsel.spikes,2)
for tt = 1:length(threshes)
    LRselECDF(tt,day) = sum(abs(LRsel.spikes(:,day))<=threshes(tt))/sum(~isnan(LRsel.spikes(:,day)));
    STselECDF(tt,day) = sum(abs(STsel.spikes(:,day))<=threshes(tt))/sum(~isnan(STsel.spikes(:,day)));
end
end

jetTrips = colormap(jet);
jetUse = round(linspace(1,64,numDays));
plotColors = jetTrips(jetUse,:);

figure;
subplot(1,2,1); hold on
for aa = 1:11; plot(threshes,LRselECDF(:,aa),'Color',plotColors(aa,:),'LineWidth',1.5); end %,'DisplayName',lg{aa}
%legend('show'); legend('Location','northwest'); 
xlabel('Left/Right Selectivity Threshold'); ylabel('Proportion of Cells')
subplot(1,2,2); hold on
for aa = 1:11; plot(threshes,STselECDF(:,aa),'Color',plotColors(aa,:),'LineWidth',1.5); end %,'DisplayName',lg{aa}
%legend('show'); legend('Location','northwest'); 
xlabel('Study/Test Selectivity Threshold')
suptitle('Cumulative Density of Selectivity')

%% Plot many heatmaps

xmin = 25.5; xmax = 56; xlims = [xmin xmax];
numBins = 30;
cmperbin = (xmax-xmin)/numBins;
[~, ~, ~, ~, ~, TMap_gauss] =...
    PFsLinTrialbyTrial(trialbytrial,xlims, cmperbin, 0, 0, [], []);
dayUse = sum(dayAllUse>0,2);
plotTitles={'Study Left','Study Right','Test Left','Test Right'};
dayI = 5;
useCells = [11 14 15 18 37 40 43 51 54 77 87 89 90 104 130];    %      44    96  55 58 72 73  80  91 92  105  132 150 162 175 188 193 194];
PlotAllHeatmaps(TMap_gauss, useCells, dayI, plotTitles)


%% Session accuracy

load('trialbytrial.mat')
[accuracy] = sessionAccuracy(allfiles);
[numCells] = sessionNumcells(allfiles);
figure; plot(accuracy,'-o','LineWidth',2,'MarkerFaceColor','b')
xlim([0.9 11.1]); xlabel('Recording Day'); ylabel('Percent Correct'); title('Performance')

[LRsel, STsel] = LRSTselectivity(trialbytrial);
lapThresh = 3;
reliableThresh = 0.25;
[dayAllUse, threshAndConsec] = GetUseCells(trialbytrial, lapPctThresh, consecLapThresh);


[~, ~, rsq1] = LeastSquaresRegressionSL(numCells, accuracy,1);
xlabel('Number of Cells Active'); ylabel('Session Accuracy'); ylim([0.5 1])




