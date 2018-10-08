function [pooledMeanCorr,pooledMeanCorrOutofShuff,pooledPVcorrs,pooledPVcorrsOutShuff,...
          pooledMeanPVcorrsOutShuff,pooledNumPVcorrsOutShuff,pooledCorrsOutCOM,pooledPVdayDiffs] =...
          PoolProcessedPVcorrs(pooledCompPairs,meanCorr,meanCorrOutOfShuff,pvCorrs,pvCorrsOutOfShuff,...
          meanCorrsOutShuff,numCorrsOutShuff,corrsOutCOM,PVdayPairs)

numMice = length(meanCorr);
numPooledCompPairs = size(pooledCompPairs,1);

pooledPVdayPairs = cell(1,numPooledCompPairs);
pooledMeanCorr = cell(1,numPooledCompPairs);
pooledMeanCorrOutofShuff = cell(1,numPooledCompPairs);
pooledPVcorrs = cell(1,numPooledCompPairs);
pooledPVcorrsOutShuff = cell(1,numPooledCompPairs);
pooledMeanPVcorrsOutShuff = cell(1,numPooledCompPairs);
pooledNumPVcorrsOutShuff = cell(1,numPooledCompPairs);
pooledCorrsOutCOM = cell(1,numPooledCompPairs);
pooledPVdayDiffs = cell(1,numPooledCompPairs);

for cpJ = 1:size(pooledCompPairs,1)
    for mouseI = 1:numMice   
        pooledPVdayPairs{cpJ} = [pooledPVdayPairs{cpJ}; (PVdayPairs{mouseI})];
        
        pooledMeanCorr{cpJ} = [pooledMeanCorr{cpJ}; cell2mat(meanCorr{mouseI}(:,cpJ))];
        pooledMeanCorrOutofShuff{cpJ} = [pooledMeanCorrOutofShuff{cpJ}; meanCorrOutOfShuff{mouseI}(:,cpJ)];
        
        pooledPVcorrs{cpJ} = [pooledPVcorrs{cpJ}; cell2mat({pvCorrs{mouseI}{:,cpJ}}')];
        pooledPVcorrsOutShuff{cpJ} = [pooledPVcorrsOutShuff{cpJ}; cell2mat({pvCorrsOutOfShuff{mouseI}{:,cpJ}}')];
        pooledMeanPVcorrsOutShuff{cpJ} = [pooledMeanPVcorrsOutShuff{cpJ}; meanCorrsOutShuff{mouseI}(:,cpJ)];
        pooledNumPVcorrsOutShuff{cpJ} = [pooledNumPVcorrsOutShuff{cpJ}; numCorrsOutShuff{mouseI}(:,cpJ)];
        pooledCorrsOutCOM{cpJ} = [pooledCorrsOutCOM{cpJ}; cell2mat({corrsOutCOM{mouseI}{:,cpJ}}')];
    end
    pooledPVdayDiffs{cpJ} = diff(fliplr(pooledPVdayPairs{cpJ}),1,2);
end

end