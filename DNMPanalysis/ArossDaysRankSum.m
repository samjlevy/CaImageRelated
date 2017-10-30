AcrossDaysRankSum(corrs, realDays)

numDays = length(realDays);
dayPairs = combnk(1:numDays,2);
realDayPairs = [realDays(dayPairs(:,1))' realDays(dayPairs(:,2))']; 
daysApart = abs(diff(realDayPairs,1,2));
apart = unique(daysApart);

for pairI = 1:length(dayPairs)
    [p(pairI),h(pairI)] = ranksum(corrs(dayPairs(pairI,1),:)',corrs(dayPairs(pairI,2),:)');
end

for apartI = 1:length(apart)
    pctDiff(apartI,1) = apart(apartI);
    pctDiff(apartI,2) = sum(h(daysApart==apart(apartI)))/sum(daysApart==apart(apartI));
end

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