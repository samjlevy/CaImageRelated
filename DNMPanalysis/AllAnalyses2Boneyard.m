%% Splitter cells: Shuffle versions, unpooled
% Older version: will pool by averaging across tmap conds
% Left/Right
for mouseI = 1:numMice
    %condPairsLR = [1 2; 3 4];
    condPairsLR = [Conds.Study; Conds.Test]; %Compare study L v study r, then test l v test r
    %condPairsLR = [1 3 2 4];
    shuffDirFullLR = fullfile(mainFolder,mice{mouseI},shuffleDirLR);
    [rateDiffLR{mouseI}, rateSplitLR{mouseI}, meanRateDiffLR{mouseI}, DIeachLR{mouseI}, DImeanLR{mouseI}, DIallLR{mouseI}] =...
        LookAtSplitters4(cellTMap_unsmoothed{mouseI}, condPairsLR, trialReli{mouseI});
    splitterFileLR = fullfile(shuffDirFullLR,'splittersLR.mat');
    if exist(splitterFileLR,'file')==2
        load(splitterFileLR)
    else
        disp(['did not find LR splitting for ' num2str(mouseI) ', making now'])
        [binsAboveShuffleLR, thisCellSplitsLR] = SplitterWrapper2(cellTBT{mouseI}, cellTMap_unsmoothed{mouseI},...
            'leftright', 'pooled', numShuffles, shuffDirFullLR, xlims, cmperbin, minspeed, trialReli{mouseI}, shuffThresh, binsMin);
        save(splitterFileLR,'binsAboveShuffleLR','thisCellSplitsLR')
    end
    LRbinsAboveShuffle{mouseI} = binsAboveShuffleLR; 
    LRthisCellSplits{mouseI} = thisCellSplitsLR;
    disp(['done Left/Right splitters mouse ' num2str(mouseI)])
end

% Study/Test
for mouseI = 1:numMice
    %condPairsST = [1 3; 2 4];
    condPairsST = [Conds.Left; Conds.Right]; %Compare study L v test l, then study r v test r
    shuffDirFullST = fullfile(mainFolder,mice{mouseI},shuffleDirST);
    [rateDiffST{mouseI}, rateSplitST{mouseI}, meanRateDiffST{mouseI}, DIeachST{mouseI}, DImeanST{mouseI}, DIallST{mouseI}] =...
        LookAtSplitters4(cellTMap_unsmoothed{mouseI}, condPairsST, trialReli{mouseI});
    splitterFileST = fullfile(shuffDirFullST,'splittersST.mat');
    if exist(splitterFileST,'file')==2
        load(splitterFileST)
    else
        disp(['did not find ST splitting for ' num2str(mouseI) ', making now'])
        [binsAboveShuffleST, thisCellSplitsST] = SplitterWrapper2(cellTBT{mouseI}, cellTMap_unsmoothed{mouseI},...
            'studytest', 'unpooled', numShuffles, shuffDirFullST, xlims, cmperbin, minspeed, trialReli{mouseI}, shuffThresh, binsMin);
        save(splitterFileST,'binsAboveShuffleST','thisCellSplitsST')
    end
    STbinsAboveShuffle{mouseI} = binsAboveShuffleST; 
    STthisCellSplits{mouseI} = thisCellSplitsST;
    disp(['done Study/Test splitters mouse ' num2str(mouseI)])
end
