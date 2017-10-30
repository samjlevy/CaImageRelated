
[LRsel, STsel] = LRSTselectivity(trialbytrial);
numDays = size(LRsel.spikes,2);
bins = -1:0.1:1;
figure;
for dayI = 1:numDays
    %hold on
    lrtheseSel = LRsel.spikes(:,dayI);
    lrCounts(dayI,:) = histcounts(lrtheseSel(~isnan(lrtheseSel)),bins);
    sttheseSel = STsel.spikes(:,dayI);
    stCounts(dayI,:) = histcounts(sttheseSel(~isnan(sttheseSel)),bins);
    hold on
    histogram(theseSel(~isnan(lrtheseSel)),bins,'FaceAlpha',0.4)
end

lrMeans = mean(lrCounts,1);
lrNumCells = sum(lrCounts,2);
lrNumCells = repmat(sum(lrCounts,2),1,length(bins)-1);
lrProportion = lrCounts./lrNumCells;
lrSEMs = std(lrCounts,1)./sqrt(numDays);
stMeans = mean(stCounts,1);
stNumCells = repmat(sum(stCounts,2),1,length(bins)-1);
stProportion = stCounts./stNumCells;
stSEMs = std(stProportion,1)./sqrt(numDays);

bar(barx,stProportion(1,:),1,'c')
stSEMs = std(stProportion,1)./sqrt(numDays);
hold on
plot([-0.95 -0.95],[stProportion(1,1)-stSEMs(1) stProportion(1,1)+stSEMs(1)],'k','LineWidth',2)