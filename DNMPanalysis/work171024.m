
figure;
for ncp = 1:4
    hold on
plot(apart, mean(corrMeans{ncp},2),'o-','Color','b')%,'Color'
end
title('comparisons with self')

%figure;
for ncp = [5 10]
    hold on
plot(apart, mean(corrMeans{ncp},2),'o-','Color','r')%,'Color'
end
title('left/right comparisons')

%figure;
for ncp = [6 9]
    hold on
    plot(apart, mean(corrMeans{ncp},2),'o-','Color','g')%,'Color'
end
title('study/test comparisons')

title('blue = self, red = LvR, green = SvT')

ncpUse = [1:4 5 10 6 9];
for ncp = 1:length(ncpUse)
    testcorrs(ncp,:) =  mean(corrMeans{ncpUse(ncp)},2);
end

tccoms = combnk(1:length(ncpUse),2);
for cc = 1:length(tccoms)
[p(cc), h(cc)] = ranksum(testcorrs(tccoms(cc,1),:),testcorrs(tccoms(cc,2),:));
end


for qq = 1:100
    if qq<100; zerosBuff = '0'; end
    if qq<10; zerosBuff = '00'; end
    if qq>=100; zerosBuff = []; end
    saveName = ['PFsLinLRShuff' zerosBuff num2str(qq) '.mat'];
    load(fullfile(cd,'ShufflesConditionLR',saveName),'TMap_gaussShufflr')
    [lrbigCorrs, cells, dayPairs, condPairs ] =...
    PVcorrsAllCorrsAllCondsAllDays(TMap_gaussShufflr,RunOccMap,posThresh,threshAndConsec,sortedSessionInds,Conds);
        [lrcorrMeans{qq}, lrcorrStd{qq}, lrcorrSEM{qq}] = processPVacacad(lrbigCorrs, cells, dayPairs, condPairs,realDays);
    disp(['finished corrs ' num2str(qq)])
end

for shuffI = 1:25
    if shuffI<100; zerosBuff = '0'; end
    if shuffI<10; zerosBuff = '00'; end
    if shuffI>=100; zerosBuff = []; end
    saveName = ['PFsLinSTShuff' zerosBuff num2str(shuffI) '.mat'];
    load(fullfile(cd,'ShufflesConditionST',saveName),'TMap_gaussShuffst')
    [stbigCorrs, cells, dayPairs, condPairs ] =...
    PVcorrsAllCorrsAllCondsAllDays(TMap_gaussShuffst,RunOccMap,posThresh,threshAndConsec,sortedSessionInds,Conds);
    [stcorrMeans{shuffI}, stcorrStd{shuffI}, stcorrSEM{shuffI}] = processPVacacad(stbigCorrs, cells, dayPairs, condPairs,realDays);
    disp(['finished corrs ' num2str(shuffI)])
end

for dayCheck = 1:11

%dayCheck = 1;
%plot(plotBins,fliplr(StudyCorrs(dayCheck,:)),'-o','Color','b','LineWidth',1.5)
for qq = 1:100 
  
    if qq<100; zerosBuff = '0'; end
    if qq<10; zerosBuff = '00'; end
    if qq>=100; zerosBuff = []; end
    saveName = ['PFsLinLRShuff' zerosBuff num2str(qq) '.mat'];
    load(fullfile(cd,'ShufflesConditionLR',saveName),'TMap_gaussShufflr')
     [lrStudyCorrs, ~, ~, ~, ~] =...
    PVcorrAllCond(TMap_gaussShufflr, RunOccMap, posThresh, threshAndConsec, Conds);
    lrDayKeep{dayCheck}(qq,:) = lrStudyCorrs(dayCheck,:);
    %}
end
figure;
plotBins = 1:10;
for qq = 1:100 
    %}
    hold on
    plot(plotBins,fliplr(lrDayKeep{dayCheck}(qq,:)),'Color',[0.85 0.85 0.85],'LineWidth',1)
%disp(['finished corrs ' num2str(qq)])
end

plot(plotBins,fliplr(StudyCorrs(dayCheck,:)),'-o','Color','b','LineWidth',1.5)
xlim([0.99 10.01]); ylim([-1 1]);
title(['Day ' num2str(dayCheck) ' Study Left vs. Study Right, shuffled in gray'])
ylabel('R value'); xlabel('Position (Start to Choice)')

%for dayCheck = 1:11
%numShuffs = size(lrDay5Keep,1);
cis = [ceil(0.025*numShuffs) ceil(0.975*numShuffs)];
sortedlr = sort(lrDayKeep{dayCheck},1);
for vv = 1:numBins
    isOut(dayCheck,vv) = StudyCorrs(dayCheck,vv) < sortedlr(cis(1),vv) | StudyCorrs(dayCheck,vv) > sortedlr(cis(2),vv);
end

isOut = fliplr(isOut(dayCheck,:));
tCorrs = fliplr(StudyCorrs(dayCheck,:))-0.1;
plot(plotBins(isOut(dayCheck,:)),tCorrs(isOut(dayCheck,:)),'*r','MarkerSize',7)
end

daysI = [5 10];
for dayI = 1:2
    lrshuff{dayI} = [];
    for shI=1:length(lrcorrMeans)
        lrshuff{dayI} = [lrshuff{dayI} mean(lrcorrMeans{shI}{daysI(dayI)},2)];
    end
end

figure;
for aa = 1:25
    hold on
    plot(apart, lrshuff{1,1}(:,aa),'o-','Color',[0.65 0.65 0.65])
end
plot(apart, mean(corrMeans{5},2),'o-','Color','m')
plot(apart, mean(corrMeans{1},2),'o-','Color','b')
plot(apart, mean(corrMeans{2},2),'o-','Color','r')
title('b = studyl, r = studyr, m = study lvr, gray = shuff study lvr')
xlabel('days apart'); ylim([-1 1])

figure;
for aa = 1:25
    hold on
    plot(apart, lrshuff{1,2}(:,aa),'o-','Color',[0.65 0.65 0.65])
end
plot(apart, mean(corrMeans{10},2),'o-','Color','m')
plot(apart, mean(corrMeans{3},2),'o-','Color','b')
plot(apart, mean(corrMeans{4},2),'o-','Color','r')
title('b = testl, r = testr, m = test lvr, gray = shuff test lvr')
xlabel('days apart'); ylim([-1 1])

daysI = [6 9];
for dayI = 1:2
    stshuff{dayI} = [];
    for shI=1:length(stcorrMeans)
        stshuff{dayI} = [stshuff{dayI} mean(stcorrMeans{shI}{daysI(dayI)},2)];
    end
end

figure;
for aa = 1:25
    hold on
    plot(apart, stshuff{1,1}(:,aa),'o-','Color',[0.65 0.65 0.65])
end
plot(apart, mean(corrMeans{6},2),'o-','Color','m')
plot(apart, mean(corrMeans{1},2),'o-','Color','b')
plot(apart, mean(corrMeans{3},2),'o-','Color','r')
title('b = studyl, r = testl, m = left svt, gray = shuff left svt')
xlabel('days apart'); ylim([-1 1])

figure;
for aa = 1:25
    hold on
    plot(apart, stshuff{1,2}(:,aa),'o-','Color',[0.65 0.65 0.65])
end
plot(apart, mean(corrMeans{9},2),'o-','Color','m')
plot(apart, mean(corrMeans{2},2),'o-','Color','b')
plot(apart, mean(corrMeans{4},2),'o-','Color','r')
title('b = studyr, r = testr, m = right svt, gray = shuff right svt')
xlabel('days apart'); ylim([-1 1])


condPairsUse = [1:10];
for condI = 1:length(condPairsUse)
    dayshuff{condI} = [];
    for shI=1:length(daycorrMeans)
        dayshuff{condI} = [dayshuff{condI} mean(daycorrMeans{shI}{condPairsUse(condI)},2)];
    end
end

condpairs = [1 2 3 4 5 6 9 10];
for shuffI = 1:100
    if shuffI<100; zerosBuff = '0'; end
    if shuffI<10; zerosBuff = '00'; end
    if shuffI>=100; zerosBuff = []; end
    saveName = ['PFsLinDayShuff' zerosBuff num2str(shuffI) '.mat'];
    load(fullfile(cd,'ShufflesDay2',saveName),'TMap_gaussDayShuff')
    [daybigCorrs, cells, dayPairs, condPairs ] =...
    PVcorrsAllCorrsAllCondsAllDays(TMap_gaussDayShuff,RunOccMap,posThresh,alwaysAboveThresh,sortedSessionInds,Conds);
    [daycorrMeans, stcorrStd, stcorrSEM] = processPVacacad(daybigCorrs, cells, dayPairs, condPairs,realDays);
    for cpI = 1:length(condpairs)
        dayshuff{shuffI}(cpI,:) = mean(daycorrMeans{condpairs(cpI)},2);
    end
    disp(['finished ' num2str(shuffI)])
end

figure; 
condI = 5;
for shuffI = 1:100
    hold on
    plot(apart, dayshuff{shuffI}(condI,:),'Color',[0.65 0.65 0.65])
end
plot(apart, mean(corrMeans{condpairs(condI)},2),'o-','Color','b')

meanCurves = cell2mat(cellfun(@(x) mean(x,2)',corrMeans,'UniformOutput',false));
meanCurves(7:8,:) = [];
meanmean(1,:) = mean(meanCurves(1:4,:),1);
meanmean(2,:) = mean(meanCurves([5 8],:),1);
meanmean(3,:) = mean(meanCurves([6 7],:),1);
meanmean = meanmean';
meanmean(1,:) = []
curveID = ones(17,3) .* [1 2 3]
apartlong = repmat([1:17]',3,1)
[h,atab,ctab,stats] = aoctool(apartlong, meanmean(:), curveID(:))