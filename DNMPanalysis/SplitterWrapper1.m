function [binsAboveShuffle, thisCellSplits] = SplitterWrapper1(trialbytrial, baseTMap_unsmoothed,...
    typeShuff, numShuffles, shuffDirFull, xlims, cmperbin, minspeed, trialReli, shuffThresh, binsMin)
%typeShuff = 'leftright' or 'studytest'      
if strcmp(typeShuff,'leftright'); na = 'LR'; elseif strcmp(typeShuff,'studytest'); na = 'ST'; end

%Shuffle things and make new rate maps
%{
bigName = fullfile(shuffDirFull,['allTMap_shuffles' na '.mat']);
if exist(bigName,'file')~=2
    disp('Did not find all shuffles file')
    allTMap_shuffle = cell(numShuffles,1);
    
    
%}
rateDiff = cell(numShuffles,1); rateDIall = cell(numShuffles,1); rateDI = cell(numShuffles,1);
possibleShuffles = dir(['shuff' na '*.mat']);
possibleShuffles([possibleShuffles(:).isdir]==1) = [];
if length(possibleShuffles) == numShuffles
    disp('Found existing individual shuffles, loading them')
    for shuffleI = 1:numShuffles
        load(fullfile(shuffDirFull,possibleShuffles(shuffleI).name),'TMap_unsmoothed')
        %allTMap_shuffle{shuffI} = TMap_unsmoothed;
        [~, ~, rateDiff{shuffleI}, rateDIall{shuffleI}, rateDI{shuffleI}] =...
            LookAtSplitters2(TMap_unsmoothed); %rates, nbormrates
    end
else
    disp('did not find (enough) individual shuffle files')
    for shuffleI = 1:numShuffles
        switch typeShuff
            case 'leftright'
                saveName = fullfile(shuffDirFull,['shuffLR' num2str(shuffleI) '.mat']);
            case 'studytest'
                saveName = fullfile(shuffDirFull,['shuffST' num2str(shuffleI) '.mat']);
        end
        
        shuffledTBT = ShuffleTrialsAcrossConditions(trialbytrial,typeshuff);
        %[~, ~, ~, allTMap_shuffleLR{shuffleI}, ~] =...
        %    PFsLinTrialbyTrial(shuffledTBT,xlims, cmperbin, minspeed, 1, saveName, trialReli{mouseI});
        %[allTMap_shuffle{shuffleI}, ~, ~, ~, ~, ~] =...
        [TMap_unsmoothed, ~, ~, ~, ~, ~] =...
            PFsLinTrialbyTrial2(shuffledTBT, xlims, cmperbin, minspeed,...
            saveName,'trialReli',trialReli{mouseI},'smooth',false);
        [~, ~, rateDiff{shuffleI}, rateDIall{shuffleI}, rateDI{shuffleI}] =...
            LookAtSplitters2(TMap_unsmoothed);
        %disp(['done shuffle ' num2str(shuffleI) ])
    end
end
    %disp('saving all tmaps file')
    %save(bigName,'allTMap_shuffle','-v7.3')
    %{
else
    disp('Found all shuffles file')
    load(bigName,'allTMap_shuffle')
end
    %}

%Evaluate those rate maps

%for shuffleI = 1:numShuffles
%    [~, ~, rateDiff{shuffleI}, rateDIall{shuffleI}, rateDI{shuffleI}] =...
%        LookAtSplitters2(allTMap_shuffle{shuffleI}); %rates, normrates
%end

[~, ~, rateDiff, rateDIall, rateDI] = LookAtSplitters2(baseTMap_unsmoothed);
[binsAboveShuffle, thisCellSplits] = SplitterRateRank(rateDiff, rateDiff, shuffThresh, binsMin);
    
    
end