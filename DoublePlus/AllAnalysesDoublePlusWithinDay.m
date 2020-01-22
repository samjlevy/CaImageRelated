%% All analyses within-day double plus

mainFolder = 'E:\DoublePlus\';
mice = {'December'};
numMice = length(mice);

nArmBins = 5;
load(fullfile(mainFolder,'mainPosAnchor.mat'),'posAnchorIdeal')
[dataBins,plotBins] = SmallPlusBounds(posAnchorIdeal,nArmBins);
binVertices = {dataBins.X, dataBins.Y};

minSpeed = 0;
pThresh = 0.05;
lapPctThresh = 0.25;
consecLapThresh = 3;

disp('loading root data')
for mouseI = 1:numMice
    load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'))
    cellTBT{mouseI} = trialbytrial;
    cellSSI{mouseI} = sortedSessionInds;
    cellAllFiles{mouseI} = allfiles;
    cellRealDays{mouseI} = realdays;

    end

%Pre-process behavior type
for mouseI = 1:numMice
    for sessI = 1:length(unique(cellTBT{mouseI}(1).sessID))
        for epochI = 1:3
            trialsHere = cellTBT{mouseI}(epochI).sessID == sessI;
            rules(sessI,epochI) = mode([cellTBT{mouseI}(epochI).rewardArm{trialsHere}]);
            mazes(sessI,epochI) = mode([cellTBT{mouseI}(epochI).MazeID(trialsHere)]);
        end
        %nRules 
        %rulesFollowed
    end
end

%Make place fields 
[cellTMap_unsmoothed{1},RunOccMap,OccMap,spikeCounts] =...
    PFsTBTarbitraryBins(trialbytrial,binVertices,minSpeed,[]);%'PlaceFields.mat'

%% Population vector correlations, all trials
cellsUseOption = 'activeEither';
corrType = 'Spearman';
traitLogical{1} = repmat(cellSSI{1}>0,1,1,3);

condPairs = [1 2; 1 3; 2 3]; numCondPairs = size(condPairs,1);
dayPairs = [1 1; 2 2]; numDayPairs = size(dayPairs,1);

for mouseI = 1:numMice
    
    [pvCorrs, meanCorr, numCellsUsed, numNans] =...
        PVcorrsWrapperBasic(cellTMap_unsmoothed{mouseI},condPairs,dayPairs,traitLogical{mouseI},cellsUseOption,corrType);
    
    for dpI = 1:numDayPairs
        for cpI = 2%1:numCondPairs
            figHand = PlusMazePVcorrHeatmap2(pvCorrs{dpI,cpI},{plotBins.X, plotBins.Y},'jet');
            title(['PV corrs All trials day ' num2str(dayPairs(dpI,1)) ' conds ' num2str(condPairs(cpI,:))])
        end
    end
    %For use with multiple mice    
    %{
    for cpI = 1:numCondPairs
        for dpI = 1:numDayPairs
            pooledPVcorrs{dpI,cpI} = [pooledPVcorrs{dpI,cpI}; pvCorrs{dpI,cpI}];
            pooledMeanCorr{dpI,cpI} = [pooledMeanCorr{dpI,cpI}; meanCorr{dpI,cpI}];
            pooledNumCellsUsed{dpI,cpI} = [pooledNumCellsUsed{dpI,cpI}; numCellsUsed{dpI,cpI}];
        end
    end
    %}
end

%% Population vector correlations, trial blocks
cellsUseOption = 'activeEither';
corrType = 'Spearman';
traitLogical{1} = repmat(cellSSI{1}>0,1,1,3);

%Population vector correlations, trial blocks
condPairs = [1 2; 1 3; 2 3]; numCondPairs = size(condPairs,1);
dayPairs = [1 1; 2 2]; numDayPairs = size(dayPairs,1);
dayChunks = [0 0.34; 0.33 0.67; 0.66 1];
nc = size(dayChunks,1);


for mouseI = 1:numMice
    for dpI = 1:numDayPairs
        for cpI = 1:3 %cond I
            for cpJ = 1:3 %cond J
                for dcI = 1:nc %chunk I
                    for dcJ = 1:nc %chunk J
                        
                        %Check we're not using the same chunk in the same day                       %day
                        sameCond = cpI==cpJ;    sameChunk = dcI==dcJ;
                        if sameCond && sameChunk
                           %skip it
                        else
                            %Get the appropriate tbt chunks
                            trimmedTBTa = SlimDownTBT(cellTBT{mouseI},dayChunks(dcI,:));
                            trimmedTBTb = SlimDownTBT(cellTBT{mouseI},dayChunks(dcJ,:));
                                
                            %Make rate maps
                            [cellTMapA,~,~,~] =...
                                PFsTBTarbitraryBins(trimmedTBTa,binVertices,minSpeed,[]);%'PlaceFields.mat'
                            [cellTMapB,~,~,~] =...
                                PFsTBTarbitraryBins(trimmedTBTb,binVertices,minSpeed,[]);%'PlaceFields.mat'
                            
                            %Make correlations.
                            allCells = cellSSI{mouseI}(:,dpI)>0;
                            TMapA = cellTMapA(:,dpI,cpI);
                            TMapB = cellTMapB(:,dpI,cpJ);
                            [chunkCorrs{dpI}{dcI+(nc*(cpI-1)),dcJ+(nc*(cpJ-1))},~,~,~] =...
                                PopVectorCorrsSmallTMaps(TMapA,TMapB,allCells,allCells,cellsUseOption,corrType);
                        end
                    end
                end
            end
        end
    end
end

%Plot similarity to chunk 3 on day 1
dayColors = {'r','b'};
for mouseI=1:numMice
    figure;
    for dpI =1:2
        dataHere = cell2mat(chunkCorrs{dpI}(:,3));
        dataHere = [dataHere([1:(nc-1)],:); ones(1,size(dataHere,2)); dataHere([nc:8],:)];
        for binI = 1:size(dataHere,2)
            plot(1:nc*3,dataHere(:,binI),dayColors{dpI})
            hold on
        end
        dForStats{dpI} = dataHere;
    end
    
    for dayI = 1:size(dataHere,1)
        [p,h] = signrank(dForStats{1}(dayI,:),dForStats{2}(dayI,:));
        text(dayI-0.25,1.1,[num2str(round(p,2))]) 
    end
end
    
