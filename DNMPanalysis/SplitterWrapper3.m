function [rateDiff, binsAboveShuffle, thisCellSplits] = SplitterWrapper3(trialbytrial, typeShuff,...
    pooledunpooled, numShuffles, shuffDirFull, xlims, cmperbin, minspeed, trialReli, shuffThresh, binsMin)
%typeShuff = 'leftright' or 'studytest'  
%pooledunpooled = 'pooled' or 'unpooled' - e.g. puts study l and r together
%against test l and r
%this pools across dim 3 assuming there are multiple combinations to test
%splitting across (e.g., left right could test 1v2 and 3v4)

if strcmp(typeShuff,'leftright'); na = 'LR'; elseif strcmp(typeShuff,'studytest'); na = 'ST'; end

Conds = GetTBTconds(trialbytrial);
switch pooledunpooled
    case 'pooled'
        switch typeShuff
            case 'leftright'
                shuffPFcondpairs = [Conds.Left; Conds.Right];
            case 'studytest'
                shuffPFcondpairs = [Conds.Study; Conds.Test];
        end
    case 'unpooled'
        shuffPFcondpairs = [1;2;3;4];
end

[baseTMap_unsmoothed, ~, ~, ~, ~, ~] =...
    PFsLinTrialbyTrial2(trialbytrial, xlims, cmperbin, minspeed,...
    [],'trialReli',trialReli,'smooth',false,'condPairs',shuffPFcondpairs);

numCells = size(baseTMap_unsmoothed,1);
numSess = size(baseTMap_unsmoothed,2);

%Shuffle things and make new rate maps
if exist(shuffDirFull,'dir')==0
    mkdir(shuffDirFull)
end
cd(shuffDirFull)
possibleShuffles = dir(['shuff' na '*.mat']);
possibleShuffles([possibleShuffles(:).isdir]==1) = [];
if length(possibleShuffles) < numShuffles
    disp('did not find (enough) individual shuffle files, working now')
    for shuffleI = 1:numShuffles
        saveName = fullfile(shuffDirFull,['shuff' na num2str(shuffleI) '.mat']);
        
        shuffledTBT = ShuffleTrialsAcrossConditions(trialbytrial,typeShuff);
        [~, ~, ~, ~, ~, ~] =...
            PFsLinTrialbyTrial2(shuffledTBT, xlims, cmperbin, minspeed,...
            saveName,'trialReli',trialReli,'smooth',false,'condPairs',shuffPFcondpairs);
        disp(['done shuffle ' num2str(shuffleI) ])
    end
    disp('Done with shuffling')
else
    disp('Found shuffles, using them')
end

switch pooledunpooled
    case 'unpooled'
        switch typeShuff
            case 'leftright'
                condPairs = [1 2; 3 4];
            case 'studytest'
                condPairs = [1 3; 2 4];
        end
    case 'pooled'
        switch typeShuff
            case 'leftright'
                %condPairs = [1 3 2 4]; %Average; doesn't change much
                condPairs = [1 2];
            case 'studytest'
                %condPairs = [1 2 3 4]; %Average
                condPairs = [1 2];
        end
end

numCondPairs = size(condPairs,1);

%Load shuffles and get splitter stuff
rateDiffReorg = cell(numCells,numSess,numCondPairs);
disp('Looking at how much splitting')
possibleShuffles = dir(['shuff' na '*.mat']);
possibleShuffles([possibleShuffles(:).isdir]==1) = [];
p = ProgressBar(numShuffles);
for shuffleI = 1:numShuffles
    load(fullfile(shuffDirFull,possibleShuffles(shuffleI).name),'TMap_unsmoothed')
    for cpI = 1:numCondPairs
        [rateDiff, ~, ~, ~, ~] =... % rateSplit{shuffleI}, meanRateDiff{shuffleI}, DIeach{shuffleI}, DImean{shuffleI}
            LookAtSplitters4(TMap_unsmoothed,condPairs(cpI,:),trialReli);

        %Need to reorganize here , takes too much memory
        for cellI = 1:numCells
            for sessI = 1:numSess
                if any(rateDiff{cellI,sessI})
                    rateDiffReorg{cellI,sessI,cpI}(shuffleI,:) = rateDiff{cellI,sessI};
                end
            end
        end
    end
    %disp(['done split shuffle ' num2str(shuffleI)]) 
    p.progress;
end
p.stop;
disp('Done measuring split')

[baseRateDiff, ~, ~, ~, ~, ~] = LookAtSplitters4(baseTMap_unsmoothed,condPairs,trialReli);
[~, binsAboveShuffle, thisCellSplits] = SplitterRateRank2(baseRateDiff, rateDiffReorg, shuffThresh, binsMin);
    
thisCellSplits = sum(thisCellSplits,3) > 0;
end