(trialbytrial, allfiles, 

numCells = size(trialbytrial(1).trialPSAbool{1,1},1);
numDays = size(LRsel.hits,2);
[LRsel, STsel] = LRSTselectivity(trialbytrial);
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
for nc = 1:numCells
    if mn

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
    ylabel(
end

use = ~isnan(LRstd) 



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
        