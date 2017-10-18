function [corrMeans, corrStds, corrSEMs] = processPVcorrsSelfAcrossDays(corrs)

ss = fieldnames(corrs);
numDays = size(corrs.(ss{1}),1);

dayPairs = combnk(1:numDays,2);
daysApart = diff(dayPairs,1,2);
apart = unique(daysApart);

numBins = size(corrs.(ss{1}),2);
numSplits = size(corrs.(ss{1}),3);

corrMeans = cell(1,4); corrStds = cell(1,4); corrSEMs = cell(1,4);

for apartI = 1:length(apart)
    
    pairUse = daysApart==apart(apartI);
    for splitI = 1:numSplits
        for condI = 1:4
            allCorrs=[corrs.(ss{condI}){pairUse}];
            corrMat=reshape(allCorrs,numBins,sum(pairUse))';

            corrMeans{condI}(apartI,1:numBins,splitI) = mean(corrMat,1);
            corrStds{condI}(apartI,:,splitI) = std(corrMat,1);
            corrSEMs{condI}(apartI,:,splitI) = std(corrMat,1)/size(corrMat,1);
        end
    end
end
    
end