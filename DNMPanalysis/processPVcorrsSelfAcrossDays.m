function [corrMeans, corrStds, corrSEMs, rawSort, pairsRaw] = processPVcorrsSelfAcrossDays(corrs, dayPairs)
%Takes the corrs from PVcorrAcrossDays
%rawSort is the correlations split (cell dim 1) by number of days apart
%outputs are: {condition}(days apart,binNum)
%pairs raw tells which days are being compared

ss = fieldnames(corrs);
numPairs = size(dayPairs,1);
numConds = length(ss);
daysApart = diff(dayPairs,1,2);
apart = unique(daysApart);

numBins = size(corrs.(ss{1}),2);

corrMeans = cell(1,numConds); corrStds = cell(1,numConds); corrSEMs = cell(1,numConds);
rawSort = {numPairs,numConds};
for apartI = 1:length(apart)
    
    pairUse = daysApart==apart(apartI);
    pairsRaw{apartI,1} = dayPairs(pairUse,:);
    for condI = 1:4
        allCorrs=corrs.(ss{condI})(pairUse,:);
            %corrMat=reshape(allCorrs,numBins,sum(pairUse))';
        rawSort{apartI,condI} = allCorrs;
        
        corrMeans{condI}(apartI,1:numBins) = mean(allCorrs,1);
        corrStds{condI}(apartI,:) = std(allCorrs,1);
        corrSEMs{condI}(apartI,:) = std(allCorrs,1)/sqrt(size(allCorrs,1));
    end
end
    
end