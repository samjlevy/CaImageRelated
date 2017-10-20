AcrossDaysRankSum(corrs)

numDays = size(corrs,1);
dayPairs = combnk(1:numDays,2);
daysApart = diff(dayPairs,1,2);
apart = unique(daysApart);

for apartI = 1:length(apart)
    
    pairUse = find(daysApart==apart(apartI));
    for pairI = 1:length(pairUse)
        days = dayPairs(pairUse(pairI),:);
        [p(pairI),h(pairI)] = ranksum(corrs(days(1),:)',corrs(days(2),:)');
    end
end

ks test for diffs between curves, then ttest those differences against 0?
h = kstest(corrs(1,:)-corrs(2,:))
ttest(corrs(1,:)-corrs(2,:))