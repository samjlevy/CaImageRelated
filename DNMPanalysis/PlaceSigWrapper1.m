function PlaceSigWrapper1(trialbytrial, xlims, cmperbin, minspeed, trialReli, numShuffles, mouseDir, shuffDirFull, pThresh )

numConds = length(trialbytrial);
numCells = size(trialbytrial(1).trialPSAbool{1},1);
numSess = length(unique(trialbytrial(1).sessID));
pInd = round((1-pThresh)*numShuffles);
    
if ~exist(shuffDirFull,'dir')
    mkdir(shuffDirFull)
end
cd(shuffDirFull)
possibleShuffles = dir(['shuffPos*.mat']);
possibleShuffles([possibleShuffles(:).isdir]==1) = [];
if length(possibleShuffles) ~= numShuffles
    disp('did not find (enough) individual shuffle files, working now')
    for shuffleI = 1:numShuffles
        shuffledTBT = shuffleTBTposition(trialbytrial);
        saveName = fullfile(shuffDirFull,['shuffPos' num2str(shuffleI) '.mat']);
        [~, ~, ~, ~, ~, ~] =...
            PFsLinTrialbyTrial2(shuffledTBT, xlims, cmperbin, minspeed,...
                saveName,'trialReli',trialReli,'smooth',false); 
        disp(['done shuffle ' num2str(shuffleI) ])
    end
    save(fullfile(shuffDirFull,'allTMap_shuffled.mat'),'allTMap_shuffled')
end

%Reorganize for sorting etc.
shuffTMapReorg = cell(numCells,numSess,numConds);
if exist(fullfile(shuffDirFull,'shuffledRatesSorted.mat'),'file')~=2
disp('Loading and reorganizing and place maps')

possibleShuffles = dir('shuffPos*.mat');
possibleShuffles([possibleShuffles(:).isdir]==1) = [];
p = ProgressBar(numShuffles);
for shuffleI = 1:numShuffles
    load(fullfile(shuffDirFull,possibleShuffles(shuffleI).name),'TMap_unsmoothed')
    for condI = 1:numConds
        for cellI = 1:numCells
            for sessI = 1:numSess
                if any(TMap_unsmoothed{cellI,condI,sessI})
                    shuffTMapReorg{cellI,sessI,condI}(shuffleI,:) = TMap_unsmoothed{cellI,condI,sessI};
                end
            end
        end
    end
    %disp(['done split shuffle ' num2str(shuffleI)]) 
    p.progress;
end
p.stop;
disp('Done loading reorganizing split')

%Sort, etc. 
shuffledRatesSorted = cell(size(shuffTMapReorg));
%shuffledRatesMean = cell(size(shuffTMapReorg));
%shuffledRates95 = cell(size(shuffTMapReorg));    
for cellI = 1:numCells %Takes a few minues with 1000 shuffles
    for condI = 1:numConds
        for dayI = 1:numSess
            shuffledRatesSorted{cellI,condI,dayI} = sort(shuffTMapReorg{cellI,dayI,condI},1);
            %shuffledRatesMean{cellI,condI,dayI} = nanmean(shuffledRatesSorted{cellI,condI,dayI},1); %Uses nanmean
            %shuffledRates95{cellI,condI,dayI} = shuffledRatesSorted{cellI,condI,dayI}(pInd,:);
        end
    end
end
save(fullfile(shuffDirFull,'shuffledRatesSorted.mat'),'shuffledRatesSorted','-v7.3')
disp('Saved shuffledRatesSorted')
end
    
load(fullfile(shuffDirFull,'shuffledRatesSorted.mat'))
load(fullfile(mouseDir,'PFsLin.mat'),'TMap_unsmoothed')
binsAbove95 = cell(size(TMap_unsmoothed));
for cellI = 1:numCells 
    for condI = 1:numConds
        for dayI = 1:numSess
            if trialReli(cellI,dayI,condI) == 1
            binsAbove95{cellI,condI,dayI} = ...
                TMap_unsmoothed{cellI,condI,dayI} > shuffledRatesSorted{cellI,condI,dayI}(pInd,:);
            end
        end
    end
end
    
numBins = size(shuffledRatesSorted{1,1,1},2);
numAbove95 = cell2mat(cellfun(@sum,binsAbove95,'UniformOutput',false));
placeAtAll = numAbove95 > 0;
lessThanHalf = numAbove95 < round(numBins/2); %Fires on less than half the stem
                    %Bins are next to each other
placeToday = squeeze(sum(placeAtAll,2) > 0);
    
%Save placefield results
save(fullfile(shuffDirFull,'PFresults.mat'),'binsAbove95','numAbove95','lessThanHalf','placeAtAll','placeToday','-v7.3')
disp('saved place stuff')

end