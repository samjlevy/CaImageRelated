function [corrMeans, corrStds, corrSEMs] = PVcorrsSelfAcrossDays(corrs)

ss = fieldnames(corrs)
numDays = size(corrs(1).StudyLCorrs,1)

daysApart = diff(dayPairs,1,2);
apart = unique(daysApart);

numBins = length(corrs(1).corrs{1});
numSplits = size(StudyLCorrs,3);

corrMeans = cell(1,4); corrStds = cell(1,4); corrSEMs = cell(1,4);

for apartI = 1:length(apart)
    
    pairUse = daysApart==apart(apartI);
    for splitI = 1:numSplits
        for condI = 1:4
            allCorrs=[corrs(condI).corrs{pairUse}];
            corrMat=reshape(allCorrs,numBins,sum(pairUse))';

            corrMeans{condI}(apartI,1:numBins,splitI) = mean(corrMat,1);
            corrStds{condI}(apartI,:,splitI) = std(corrMat,1);
            corrSEMs{condI}(apartI,:,splitI) = std(corrMat,1)/size(corrMat,1);
        end
    end
end
    
end