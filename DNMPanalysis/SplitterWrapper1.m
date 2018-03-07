function [binsAboveShuffle, thisCellSplits] = SplitterWrapper1(trialbytrial, TMap_unsmoothed,...
    typeShuff, numShuffles, shuffDirFull, xlims, cmperbin, minspeed, trialReli, shuffThresh, binsMin)
%typeShuff = 'leftright' or 'studytest'      
    


allTMap_shuffleLR = cell(numShuffles,1);
for shuffleI = 1:numShuffles
    switch typeShuff
        case 'leftright'
            saveName = fullfile(shuffDirFull,['shuffLR' num2str(shuffleI) '.mat']);
        case 'studytest'
            saveName = fullfile(shuffDirFull,['shuffST' num2str(shuffleI) '.mat']);
    end
    
    shuffledTBT = ShuffleTrialsAcrossConditions(trialbytrial,typeshuff);
    [~, ~, ~, allTMap_shuffleLR{shuffleI}, ~] =...
        PFsLinTrialbyTrial(shuffledTBT,xlims, cmperbin, minspeed, 1, saveName, trialReli{mouseI});
    disp(['done shuffle ' num2str(shuffleI) ])
end

rateDiff = cell(numShuffles,1); rateDIall = cell(numShuffles,1); rateDI = cell(numShuffles,1);
for shuffleI = 1:numShuffles
    [~, ~, rateDiff{shuffleI}, rateDIall{shuffleI}, rateDI{shuffleI}] =...
        LookAtSplitters2(allTMap_shuffleLR{shuffleI}); %rates, normrates
end

[~, ~, rateDiff, rateDIall, rateDI] = LookAtSplitters2(TMap_unsmoothed);
[binsAboveShuffle, thisCellSplits] = SplitterRateRank(rateDiff, rateDiff, shuffThresh, binsMin);
    
    
end