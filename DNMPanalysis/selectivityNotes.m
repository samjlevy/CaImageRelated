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
LRdayDiffs = cell(1,numDays-1);
STdayDiffs = cell(1,numDays-1);
LRnums = []; LRmeans = []; LRstd = []; LRsem = [];
STnums = []; STmeans = []; STstd = []; STsem = [];
for dayDiff = 1:(numDays-1)
    for tc = 1:numCells
        LRhere = LRstuff(tc,:);
            LRhere(abo(tc,:)==0) = NaN;
        SThere = STstuff(tc,:);
            SThere(abo(tc,:)==0) = NaN;
        LRchange = []; STchange = [];
        for tp = 1:(numDays-dayDiff)
            LRchange(1,tp) = abs(LRhere(tp+dayDiff)-LRhere(tp));
            STchange(1,tp) = abs(SThere(tp+dayDiff)-SThere(tp));
        end
            
        LRdayDiffs{dayDiff}(tc,:) = nanmean(LRchange);
        STdayDiffs{dayDiff}(tc,:) = nanmean(STchange);
        
        %xPlot = ones(1,sum(~isnan(LRchange)))*dayDiff;
        %plot(LRfig.Children, xPlot, LRchange(~isnan(LRchange)),'o')
        %xPlot2 = ones(1,sum(~isnan(STchange)))*dayDiff;
        %plot(STfig.Children, xPlot2, STchange(~isnan(STchange)),'o')
        
        plot(LRfig.Children, dayDiff, nanmean(LRchange),'o')
        plot(STfig.Children, dayDiff, nanmean(STchange),'o')
    end
    LRnums(dayDiff) = sum(~isnan(LRdayDiffs{dayDiff}(:)));
    LRmeans(dayDiff) = nanmean(LRdayDiffs{dayDiff}(:));
    LRstd(dayDiff) = nanstd(LRdayDiffs{dayDiff}(:));
    LRsem(dayDiff) = LRstd(dayDiff)/LRnums(dayDiff);
    
    STnums(dayDiff) = sum(~isnan(STdayDiffs{dayDiff}(:)));
    STmeans(dayDiff) = nanmean(STdayDiffs{dayDiff}(:));
    STstd(dayDiff) = nanstd(STdayDiffs{dayDiff}(:));
    STsem(dayDiff) = STstd(dayDiff)/STnums(dayDiff);
end
    
    




    
        