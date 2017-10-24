
figure;
for ncp = 1:4
    hold on
plot(apart, mean(corrMeans{ncp},2),'o-','Color','b')%,'Color'
end

%figure;
for ncp = [5 10]
    hold on
plot(apart, mean(corrMeans{ncp},2),'o-','Color','r')%,'Color'
end

for ncp = [6 9]
    hold on
    plot(apart, mean(corrMeans{ncp},2),'o-','Color','g')%,'Color'
end

title('blue = self, red = LvR, green = SvT')

ncpUse = [1:4 5 10 6 9];
for ncp = 1:length(ncpUse)
    testcorrs(ncp,:) =  mean(corrMeans{ncpUse(ncp)},2);
end

tccoms = combnk(1:length(ncpUse),2);
for cc = 1:length(tccoms)
[p(cc), h(cc)] = ranksum(testcorrs(tccoms(cc,1),:),testcorrs(tccoms(cc,2),:));
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



for 


