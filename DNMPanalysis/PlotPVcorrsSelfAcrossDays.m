function PVcorrsSelfAcrossDays(corrs,dayPairs)
%corrs from...PVcorrAcrossDays, but that's getting structured


daysApart = diff(dayPairs,1,2);

apart = unique(daysApart);

numBins = length(corrs(1).corrs{1});

corrMeans = cell(1,4); corrStds = cell(1,4); corrSEMs = cell(1,4);


for apartI = 1:length(apart)
    
    pairUse = daysApart==apart(apartI);
    for splitI = 1:numSplits
        for condI = 1:4
            allCorrs=[corrs(condI).corrs{pairUse}];
            corrMat=reshape(allCorrs,numBins,sum(pairUse))';

            corrMeans{condI}(apartI,1:numBins) = mean(corrMat,1);
            corrStds{condI}(apartI,:) = std(corrMat,1);
            corrSEMs{condI}(apartI,:) = std(corrMat,1)/size(corrMat,1);
        end
    end
end
    
end