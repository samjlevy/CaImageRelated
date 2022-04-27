% PopulationVectorCorrs4_2
disp('Making corrs')

corrType = 'Spearman';
pvCorrs = cell(numMice,1); 
meanCorr = cell(numMice,1); 
numCellsUsed = cell(numMice,1); 
numNan = cell(numMice,1); 


pooledPVcorrs = cell(numDayPairs,numCondPairs); [pooledPVcorrs{:}] = deal(nan(numMice,nArmBins));
pooledMeanCorr = cell(numDayPairs,numCondPairs); [pooledMeanCorr{:}] = deal(nan(numMice,nArmBins));
pooledNumCellsUsed = cell(numDayPairs,numCondPairs); [pooledNumCellsUsed{:}] = deal(nan(numMice,nArmBins));
clear traitLogical
for mouseI = 1:numMice
    traitLogical{1} = dayUse{mouseI};
    traitLogical{2} = repmat(cellSSI{mouseI}>0,1,1,4);
    if mouseI==1
        traitLogical{2}(:,[5 6],:) = 0;
    end
    cellsUseOption = {'activeEither','activeBoth'};
    %traitLogical{2} = trialReli{mouseI}>0;
    disp(['Running mouse ' num2str(mouseI)])
    
    [pvCorrs, meanCorr, numCellsUsed, numNans] =...
        PVcorrsWrapperMedium(cellTMap{mouseI},condPairs,dayPairs,traitLogical,cellsUseOption,corrType);
    
    %mousePVcorrs{mouseI} = pvCorrs;
    for cpI = 1:numCondPairs
        for dpI = 1:numDayPairs
            if any(pvCorrs{dpI,cpI})
            %pooledPVcorrs{dpI,cpI}(mouseI,:) = [pooledPVcorrs{dpI,cpI}; pvCorrs{dpI,cpI}];
            %pooledMeanCorr{dpI,cpI}(mouseI,:) = [pooledMeanCorr{dpI,cpI}; meanCorr{dpI,cpI}];
            %pooledNumCellsUsed{dpI,cpI}(mouseI,:) = [pooledNumCellsUsed{dpI,cpI}; numCellsUsed{dpI,cpI}];
            
            pooledPVcorrs{dpI,cpI}(mouseI,:) = pvCorrs{dpI,cpI}; % corrs comes out (1,nBins)
            pooledMeanCorr{dpI,cpI}(mouseI,:) = meanCorr{dpI,cpI};
            pooledNumCellsUsed{dpI,cpI}(mouseI,:) = numCellsUsed{dpI,cpI};
            end
        end
    end
end
disp('done making corrs')