function [corrMeans, corrStd, corrSEM] = processPVacacad(bigCorrs, cells, dayPairs, condPairs, realDays)
%Takes outputs from PVcorrsAllCorrsAllCondsAllDays to draw a curve for each
%condition pair showing mean correlation drop off by number of days apart

numCondPairs = size(condPairs,1);
numDayPairs = size(dayPairs,1);

if any(realDays)
realDayPairs = [realDays(dayPairs(:,1))' realDays(dayPairs(:,2))'];
dayPairs = realDayPairs;
end

daysApart = abs(diff(dayPairs,1,2));
apart = unique(daysApart);

corrMeans = cell(numCondPairs,1);
corrStd = cell(numCondPairs,1);
corrSEM = cell(numCondPairs,1);
%for ddd = 1:length(condPairs)
%     = nan(length(apart),numBins);
%end

for cpI = 1:numCondPairs
    for dpI = 1:length(apart)
        pairCorrs = []; pairSEM = []; pairStd = [];
        pairUse = daysApart==apart(dpI);
        
        pairCorrs = bigCorrs{cpI}(pairUse,:);
        
        corrMeans{cpI}(dpI,:) = nanmean(pairCorrs,1);
        corrStd{cpI}(dpI,:) = nanstd(pairCorrs,1);
        corrSEM{cpI}(dpI,:) = nanstd(pairCorrs,1)/sqrt(size(pairCorrs,1));
    end
end

end