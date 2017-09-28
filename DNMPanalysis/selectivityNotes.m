function selectivityNotes

[LRsel, STsel] = LRSTselectivity(trialbytrial);
numCells = size(trialbytrial(1).trialPSAbool{1,1},1);
numDays = size(LRsel.hits,2);
h = figure;
jetTrips = colormap(jet);
close(h)
jetUse = round(linspace(1,64,numDays));
plotColors = jetTrips(jetUse,:);

%comparison of how selectivity is different laps with a hit vs. total spikes

figure;
tc = 14
nonans = isnan(LRsel.hits);
nonans = sum(nonans,2)==0;
    


for tc = 1:numCells
    if any(LRsel.hits(tc,:))
        sels = find(~isnan(LRsel.hits(tc,:)));
        hold on
        if sels>1
        plot(LRsel.hits(tc,[sels(1) sels(end)]),STsel.hits(tc,[sels(1) sels(end)]),'-o')
        end
    end
    xlabel('Left                         Right')
    ylabel('Study                        Test')
end

%look at change over days, from day before
LRstuff = LRsel.spikes;
STstuff = STsel.spikes;
LRdayChange = nan(size(LRstuff)); STdayChange = nan(size(LRstuff));
LRfig = figure('name','LRfig'); plot(0,0,'*'); xlim(LRfig.Children,[1 11]);
title(LRfig.Children,'Left/Right selectivity change')
STfig = figure('name','STfig'); plot(0,0,'*'); xlim(STfig.Children,[1 11]);
title(STfig.Children,'Study/Test selectivity change') 
passed = 0;
for tc = 1:numCells
if any(LRstuff(tc,:))
sels = find(~isnan(LRstuff(tc,:)));
sels2 = find(~isnan(STstuff(tc,:)));
    if length(sels)~=length(sels2)
        disp(['different days with non nan selectivity cell ' num2str(tc)])
    end
if length(sels)>1
    passed = passed+1;
    LRplot = [0 diff(LRstuff(tc,sels))];
    STplot = [0 diff(STstuff(tc,sels))];
    xNum = sels-(sels(1)-1); %should be replaced with day from fullReg.RegDay
    
    hold(LRfig.Children,'on')
    plot(LRfig.Children,xNum,LRplot,'-o')
    
    hold(STfig.Children,'on')
    plot(STfig.Children,xNum,STplot,'-o')
    
    LRdayChange(tc,1:length(LRplot)) = LRplot;
    STdayChange(tc,1:length(STplot)) = STplot;
    %Here's a version which aggregates everything by the number of days
    %it occurs relative to last point
end
end
end

LRnums = sum(~isnan(LRdayChange),1);
LRmeans = nanmean(LRdayChange,1);
LRstd = nanstd(LRdayChange,1);
LRsem = LRstd./sqrt(LRnums);

STnums = sum(~isnan(STdayChange),1);
STmeans = nanmean(STdayChange,1);
STstd = nanstd(STdayChange,1);
STsem = STstd./sqrt(STnums);

hold on
plot([1:length(LRmeans)],STmeans,'k','LineWidth',2)
plot([1:length(LRsem)],STmeans+STsem,'r','LineWidth',2)
%plot([1:length(LRsem)],STmeans-STsem,'r','LineWidth',2)
%plot([1:length(LRstd)],-STstd,'b','LineWidth',2)
plot([1:length(LRstd)],STstd,'b','LineWidth',2)

hold on
plot([1:length(LRmeans)],LRmeans,'k','LineWidth',2)
plot([1:length(LRsem)],LRmeans+LRsem,'r','LineWidth',2)
%plot([1:length(LRsem)],LRmeans-LRsem,'r','LineWidth',2)
%plot([1:length(LRstd)],-LRstd,'b','LineWidth',2)
plot([1:length(LRstd)],LRstd,'b','LineWidth',2)


abo = aboveThresh{1}+aboveThresh{2}+aboveThresh{3}+aboveThresh{4};

%maxDiff = max(sels(2:end) - sels(1));
hold(LRfig.Children,'on')
hold(STfig.Children,'on')
%LRdayDiffs = cell(1,numDays-1);
%STdayDiffs = cell(1,numDays-1);
LRnums = []; LRmeans = []; LRstd = []; LRsem = [];
STnums = []; STmeans = []; STstd = []; STsem = [];
for dayDiff = 1:(numDays-1)
    for tc = 1:numCells
        LRhere = LRstuff(tc,:);
            LRhere(abo(tc,:)==0) = NaN;
        SThere = STstuff(tc,:);
            SThere(abo(tc,:)==0) = NaN;
        LRchange = []; STchange = [];
        
        %Here this finds pairs of selectivity dayDiff apart and gets the
        %absolute value of their differences. Diff is not the right
        %function for this
        for tp = 1:(numDays-dayDiff)
            LRchange(1,tp) = abs(LRhere(tp+dayDiff)-LRhere(tp));
            STchange(1,tp) = abs(SThere(tp+dayDiff)-SThere(tp));
        end
            
        LRdayDiffs(tc,dayDiff) = nanmean(LRchange);
        STdayDiffs(tc,dayDiff) = nanmean(STchange);
        
        %LRdayDiffs{dayDiff}(tc,:) = LRchange;
        %STdayDiffs{dayDiff}(tc,:) = STchange;
        
        %xPlot = ones(1,sum(~isnan(LRchange)))*dayDiff;
        %plot(LRfig.Children, xPlot, LRchange(~isnan(LRchange)),'o')
        %xPlot2 = ones(1,sum(~isnan(STchange)))*dayDiff;
        %plot(STfig.Children, xPlot2, STchange(~isnan(STchange)),'o')
        
        %plot(LRfig.Children, dayDiff, nanmean(LRchange),'o')
        %plot(STfig.Children, dayDiff, nanmean(STchange),'o')
    end
    LRnums(dayDiff) = sum(~isnan(LRdayDiffs(tc,dayDiff)));
    LRmeans(dayDiff) = nanmean(LRdayDiffs(tc,dayDiff));
    LRstd(dayDiff) = nanstd(LRdayDiffs(tc,dayDiff));
    LRsem(dayDiff) = LRstd(dayDiff)/LRnums(dayDiff);
    
    STnums(dayDiff) = sum(~isnan(STdayDiffs(tc,dayDiff)));
    STmeans(dayDiff) = nanmean(STdayDiffs(tc,dayDiff));
    STstd(dayDiff) = nanstd(STdayDiffs(tc,dayDiff));
    STsem(dayDiff) = STstd(dayDiff)/STnums(dayDiff);
end

notNanCells = sum(sum(~isnan(LRdayDiffs),2)>0);
numNotNans = sum(sum(~isnan(LRdayDiffs)));
figure; 
for tc = 1:numCells
    if sum(~isnan(LRdayDiffs(tc,:)))>0
        hold on
        plot(LRdayDiffs(tc,:),'-o')%,STdayDiffs(tc,:)
    end
end
xlim([0 2]); ylim([0 2])

steps = [0:0.05:2];
for st = 1:length(steps)
    step = steps(st);
    howManyLR(st) = sum(sum(LRdayDiffs>=step));
    howManyST(st) = sum(sum(STdayDiffs>=step));
end
subplot(1,2,1)
plot(steps,howManyLR/numNotNans)

%difference as a percentage of adjacent day differences
LRdiffDiffs = (abs(LRdayDiffs(:,2:end) - LRdayDiffs(:,1))./LRdayDiffs(:,1))*100; 
STdiffDiffs = (abs(STdayDiffs(:,2:end) - STdayDiffs(:,1))./STdayDiffs(:,1))*100;
   
mn = nanmean(abs(LRdiffDiffs),1);
std = nanstd(abs(LRdiffDiffs),1);
sem = std./sqrt(sum(~isnan(LRdiffDiffs),1));
%for nc = 1:numCells
    %if mn

for tc = 1:numCells
    selfStd(tc) = nanstd(abs(LRdiffDiffs(tc,:)));
    selfSem(tc) = selfStd(tc)/sqrt(sum(~isnan(LRdiffDiffs(tc,:))));
end
figure;
for tc = 1:numCells
    hold on
    plot(abs(LRdiffDiffs(tc,:)),'-o')
end
title('LR Percentage change for multiday comparisons of 1 day comparison')

figure;
for tc = 1:numCells
    hold on
    plot(STdiffDiffs(tc,:),'-o')
end
title('ST Percentage change for multiday comparisons of 1 day comparison')


%Basic again
LRmeans = nanmean(LRstuff,2);
LRnums = sum(~isnan(LRstuff),2);
LRstd = nan(numCells,1); LRsem = nan(numCells,1); 
for nc = 1:numCells; if sum(~isnan(LRstuff(nc,:)))>1
    LRstd(nc) = nanstd(LRstuff(nc,:)); 
    LRsem(nc) = LRstd(nc)/LRnums(nc);
end; end
STmeans = nanmean(STstuff,2);
STnums = sum(~isnan(STstuff),2);
STstd = nan(numCells,1); STsem = nan(numCells,1); 
for nc = 1:numCells; if sum(~isnan(STstuff(nc,:)))>1
    STstd(nc) = nanstd(STstuff(nc,:)); 
    STsem(nc) = STstd(nc)/STnums(nc);
end; end

figure;
plot(LRmeans,STmeans,'*')
xlabel('LR selectivity'); ylabel('ST selectivity')
figure;
plot(LRstd,STstd,'*')
xlabel('LR selectivity STD'); ylabel('ST selectivitySTD')
figure;
plot(LRmeans,LRstd,'*')
xlabel('Mean LR selectiviy'); ylabel('STD of LR selectivity')
figure;
plot(STmeans,STstd,'*')
xlabel('Mean ST selectiviy'); ylabel('STD of ST selectivity')


totalSpikes = lapSpikes{1,1} + lapSpikes{2,1} + lapSpikes{3,1} + lapSpikes{4,1};





for tc = 1:numCells
    if ~isnan(LRmeans(tc)) & LRnums(tc)>3
        hold on
        plot(LRmeans(tc),STmeans(tc),'r*')
        plot([LRmeans(tc)-LRstd(tc) LRmeans(tc)+LRstd(tc) LRmeans(tc) LRmeans(tc)],...
            [STmeans(tc) STmeans(tc) STmeans(tc)-STstd(tc) STmeans(tc)+STstd(tc)],'m+')
    end
    xlabel('Mean LR selectivity')
end

use = ~isnan(LRstd) 

figure; histogram(LRsel.spikes(~isnan(LRsel.spikes)),[-1.05:0.1:1.05])
xlim([-1.05 1.05]); title('Left/Right selectivity')
xlabel('Left                         Right')
figure; histogram(STsel.spikes(~isnan(STsel.spikes)),[-1.05:0.1:1.05])
xlim([-1.05 1.05]); title('Study/Test selectivity')
xlabel('Study                         Test')

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
xlabel('LR Threshold'); ylabel('Proportion of Cells')
subplot(1,2,2); hold on
for aa = 1:11; plot(threshes,STselECDF(:,aa),'Color',plotColors(aa,:),'LineWidth',1.5); end %,'DisplayName',lg{aa}
%legend('show'); legend('Location','northwest'); 
xlabel('ST Threshold')
suptitle('Proportion of cells above selectivity threshold (Bellatrix)')


for bb = 1:21
    [~,LRorder(bb,:)] = sort(LRselECDF(bb,:));
    [~,STorder(bb,:)] = sort(STselECDF(bb,:));
end
LRorder = LRorder'; STorder=STorder';
%column is thresh level, row is day; list is rank order of days


figure; subplot(1,2,1);
hold on; for cc=7:20; plot(1:11,LRorder(:,cc),'-o','DisplayName',num2str(cc)); end
xlabel('LR');
subplot(1,2,2); hold on; for cc=7:20; plot(1:11,STorder(:,cc),'-o','DisplayName',num2str(cc)); end
xlabel('ST')
suptitle('Sorting of days by selectivity thresh')

check = [1:10, 12:20];
for cd = 1:length(check)
    [LRr(cd), LRp(cd)] = corr(LRorder(:,check(cd)),LRorder(:,11));
    [STr(cd), STp(cd)] = corr(STorder(:,check(cd)),STorder(:,11));
end
figure; 
subplot(1,2,1); plot(check,LRr); hold on; plot(check(LRp<0.05),LRr(LRp<0.05),'*r')
xlabel('LR, day number'); ylim([-0.5 1])
subplot(1,2,2); plot(check,STr); hold on; plot(check(STp<0.05),STr(STp<0.05),'*r')
xlabel('ST, day number'); ylim([-0.5 1])
suptitle('Correlation of rank order with middle threshold');

LRrankSum = sum(LRorder(:,1:end-1),2);
LRrankMean = mean(LRorder(:,1:end-1),2);
STrankSum = sum(STorder(:,1:end-1),2);
STrankMean = mean(STorder(:,1:end-1),2);

figure; plot(1:11,LRrankMean,'-o')
figure; plot(1:11,STrankMean,'-o')

[~, ~, ~] = LeastSquaresRegressionSL(1:numDays, LRrankMean);
[~, ~, ~] = LeastSquaresRegressionSL(1:numDays, STrankMean);


%Modulation index stuff
[MIhits, MIspikes] = LRSTselectivityEach(trialbytrial);
figure; histogram(MIspikes,[0.05:0.1:1.05]); xlabel('Modulation Index'); ylabel('Frequency')

figure; plot(STsel.spikes,MIspikes,'o')
ylabel('Modulation Index'); xlabel('Study                    Test')
figure; plot(LRsel.spikes,MIspikes,'o')
ylabel('Modulation Index'); xlabel('Study                    Test')

%plot selectivity against place field stuff
load('PFsLin.mat','TMap_gauss')
%get bin location of max firing rate (ignoring condition)
maxRateBin = nan(numCells,numDays);
for cellI = 1:numCells
    for dayI = 1:numDays
        %figure;
        for condI = 1:4
            [rate(condI),rInd(condI)] = max(fliplr(TMap_gauss{cellI,condI,dayI}));
            %subplot(4,1,condI); plot(fliplr(TMap_gauss{cellI,condI,dayI}),'-o'); hold on
        end
        if any(rate)
            [~,loc]=max(rate);
            maxRateBin(cellI,dayI) = rInd(loc);
            %subplot(4,1,loc); plot([rInd(loc) rInd(loc)], [max(rate)-1 max(rate)+1],'r') 
        end
    end
end
figure; plot(maxRateBin(:,:),abs(STsel.spikes(:,:)),'o')
ylabel('Frequency'); xlabel('Max firing rate position (bin#)')     

%plot against selectivity
figure; plot(maxRateBin(:,:),abs(STsel.spikes(:,:)),'o')
ylabel('ST selectivity'); xlabel('Max firing rate position (bin#)')
figure; plot(maxRateBin(:,:),abs(LRsel.spikes(:,:)),'o')
ylabel('LR selectivity'); xlabel('Max firing rate position (bin#)')
%plot against MIscore
figure; plot(maxRateBin(:,:),MIspikes(:,:),'o')
ylabel('Modulation Index'); xlabel('Max firing rate position (bin#)')

%any trends over days in selectivity vs rate position?
for dayJ = 1:numDays
    for binJ = 1:length(TMap_gauss{1,1,1})
        selInds = maxRateBin(:,dayJ)==binJ;
        LRbinSelMean(dayJ,binJ) = nanmean(abs(LRsel.spikes(selInds,dayJ)));
        STbinSelMean(dayJ,binJ) = nanmean(abs(STsel.spikes(selInds,dayJ)));
    end
end
LRbinSels = [];
STbinSels = [];
selsBin = [];
for binJ = 1:length(TMap_gauss{1,1,1})
    selInds = maxRateBin==binJ;
    selsBin = [selsBin; ones(sum(sum(selInds)),1)*binJ];
    LRbinSels = [LRbinSels; abs(LRsel.spikes(selInds))];
    STbinSels = [STbinSels; abs(STsel.spikes(selInds))];
    LRbinSelMean(binJ) = nanmean(abs(LRsel.spikes(selInds)));
    STbinSelMean(binJ) = nanmean(abs(STsel.spikes(selInds)));
end

[slope, intercept, rsq] = LeastSquaresRegressionSL(selsBin, STbinSels)
for dayK = 1:numDays
    plot(1:14,STbinSelMean(dayK,:),'Color',plotColors(dayK,:),'LineWidth',2)
end

end


%Frank paper well selectivity
"To calculate the well specificity index (WSI) of a unit, the well firing rate at each
of the three wells of the task was first determined. Well firing rate was specifically
calculated from the intersection of well periods with non-SWR immobility periods
(well intersectional time). Next, each of the three well firing rates was divided by
the numerical sum of the three well firing rates (normalization) to create a three-
category (well A versus B versus C) probability distribution of firing activity. This
probability distribution was subsequently treated as a circular distribution with a
vector whose length corresponded to the probability mass for well A placed at 0°,
a vector for well B at 120°, and a vector for well C at 240°. The magnitude of the
vector sum (resultant), defined as the WSI, was used as a measure of well-specific
firing. The WSI directly reflects specificity of firing: a WSI=0 corresponds to equal
firing at all three wells (completely non-specific), WSI=0.5 corresponds to firing
at two wells, and WSI=1 corresponds to firing at one well.
The WSI was calculated in a unit’s highest mean firing task epoch, and was only
calculated when (i) at least 100 spikes were observed during well intersectional
time, (ii) at least 5 s of well intersectional time was available for each of the three
wells, (iii) the firing rate (during well intersectional time) for at least one well

exceeded 0.5Hz. These minimum activity criteria ensured that the WSI was calcu-
lated only for units that were unequivocally active at wells and for which adequate

data at each well were available."
        