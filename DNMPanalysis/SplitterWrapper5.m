function [binsAboveShuffle, numBinsAboveShuffle, thisCellSplits] = SplitterWrapper5(trialbytrial, baseTMap, typeShuff,...
    pooledunpooled, numShuffles, binEdges, minspeed, shuffThresh, binsMin, dimUse)
%typeShuff = 'leftright' or 'studytest'  
%pooledunpooled = 'pooled' or 'unpooled' - e.g. puts study l and r together
%against test l and r
%this pools across dim 3 assuming there are multiple combinations to test
%splitting across (e.g., left right could test 1v2 and 3v4)

baseTMapSomething = cell2mat(cellfun(@(x) sum(x)>0,baseTMap,'UniformOutput',false));

%Conds = GetTBTconds(trialbytrial);
switch pooledunpooled
    case 'pooled'
        switch typeShuff
            case {'leftright','LR'}
                meascondPairs = [1 2]; % condpairs to test splitting along in shuffled tmaps
                shuffPFcondpairs = [Conds.Left; Conds.Right]; %cond pairs to make placefields with
                baseCondPairs = [1 2]; %cond pairs to test splitting along in baseTMap
            case {'studytest','ST'}
                meascondPairs = [1 2]; 
                shuffPFcondpairs = [Conds.Study; Conds.Test];
                baseCondPairs = [3 4];
        end
    case 'unpooled'
        shuffPFcondpairs = [1;2;3;4];
        switch typeShuff
            case {'leftright','LR'}
                meascondPairs = [1 2; 3 4];
                baseCondPairs = [1 2; 3 4];
            case {'studytest','ST'}
                baseCondPairs = [1 3; 2 4];
                meascondPairs = [1 3; 2 4];
        end
    case 'delayEpoch'
        shuffPFcondpairs = [1; 2];
        meascondPairs = [1 2];
        baseCondPairs = [1 2];
        typeShuff = [1 2];
end

numCells = size(baseTMap,1);
numSess = size(baseTMap,2);
numBins = length(baseTMap{1});

%Shuffle things and make new rate maps
numCondPairs = size(meascondPairs,1);
rateDiffReorg = cell(numCells,numSess,numCondPairs);
%p = ProgressBar(numShuffles);

[baseRateDiff, ~, ~, ~, ~, ~] = LookAtSplitters4(baseTMap,baseCondPairs,[]);
baseRDsomething = cell2mat(cellfun(@(x) sum(abs(x))>0,baseRateDiff,'UniformOutput',false));
h = waitbar(0,'Starting to shuffle');

for shuffleI = 1:numShuffles
    shuffledTBT = ShuffleTrialsAcrossConditions(trialbytrial,meascondPairs);
    [tmapShuff, ~, ~, ~, ~, ~, ~] =...
        PFsLinTBTalternation(shuffledTBT, binEdges, minspeed, [], false,shuffPFcondpairs,dimUse);
    
    tmapShuffSomething = cell2mat(cellfun(@(x) sum(x)>0,tmapShuff,'UniformOutput',false));
    anyWrong = find((baseTMapSomething==tmapShuffSomething)==0);
    if any(anyWrong)
        %disp('bad shuffle')
    end
    [rateDiff, ~, ~, ~, ~] =... % rateSplit{shuffleI}, meanRateDiff{shuffleI}, DIeach{shuffleI}, DImean{shuffleI}
        LookAtSplitters4(tmapShuff,meascondPairs,[]);
       
    shuffRDsomething = cell2mat(cellfun(@(x) sum(abs(x))>0,rateDiff,'UniformOutput',false));
    anyWrong = find((baseRDsomething==shuffRDsomething)==0);
    for cpI = 1:numCondPairs
        if any(anyWrong)
        %    disp('bad shuffle')
        end
        for cellI = 1:numCells
            for sessI = 1:numSess
                %if any(rateDiff{cellI,sessI})
                    rateDiffReorg{cellI,sessI,cpI}(shuffleI,:) = rateDiff{cellI,sessI,cpI};
                %end
            end
        end
    end
    waitbar(shuffleI/numShuffles,h,'Still shuffling');
end

%p.stop;
close(h)
disp('Done with shuffling')


[binsAboveShuffle, numBinsAboveShuffle, thisCellSplits] = SplitterRateRank2(baseRateDiff, rateDiffReorg, shuffThresh, binsMin);
    
thisCellSplits = sum(thisCellSplits,3) > 0;

end