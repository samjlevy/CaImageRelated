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