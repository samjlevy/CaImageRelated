function [lengthSigDiff, stdSigDiff, lengthRankSumP, lengthData] = TrialLengthWrapper1(trialbytrial, typeShuff,...
    pooledunpooled, numShuffles, binEdges, shuffThresh)
%typeShuff = 'leftright' or 'studytest'  
%pooledunpooled = 'pooled' or 'unpooled' - e.g. puts study l and r together
%against test l and r
%this pools across dim 3 assuming there are multiple combinations to test
%splitting across (e.g., left right could test 1v2 and 3v4)
numCells = size(trialbytrial(1).trialPSAbool{1},1);
numSess = length(unique(trialbytrial(1).sessID));
Conds = GetTBTconds(trialbytrial);
switch pooledunpooled
    case 'pooled'
        switch typeShuff
            case {'leftright','LR'}
                meascondPairs = [1 2]; % condpairs to test splitting along in shuffled tmaps
                shuffPFcondpairs = [Conds.Left; Conds.Right]; %cond pairs to make placefields with
                baseCondPairs = [1 2]; %cond pairs to test splitting along in baseTMap
                condLabels = {'Left','Right'};
            case {'studytest','ST'}
                meascondPairs = [1 2]; 
                shuffPFcondpairs = [Conds.Study; Conds.Test];
                baseCondPairs = [3 4];
                condLabels = {'Study','Test'};
        end
        
        tbtPooled = PoolTBTacrossConds(trialbytrial,shuffPFcondpairs,condLabels);
        [lengthDiff,stdDiff,lengthRankSumP,lengthData] = TrialLengthDiff(tbtPooled,meascondPairs);
    
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
        [lengthDiff,stdDiff,lengthRankSumP,lengthData] = TrialLengthDiff(trialbytrial,meascondPairs);
end

numCondPairs = size(meascondPairs,1);
%h = waitbar(0,'Starting to shuffle');
for shuffleI = 1:numShuffles
    shuffledTBT = ShuffleTrialsAcrossConditions(trialbytrial,typeShuff);
    
    if strcmpi(pooledunpooled,'pooled')
        shuffledTBT = PoolTBTacrossConds(shuffledTBT,shuffPFcondpairs,condLabels);
    end
    
    [lengthDiffShuff(:,:,shuffleI),stdDiffShuff(:,:,shuffleI)] = TrialLengthDiff(shuffledTBT,meascondPairs);
    
    %waitbar(shuffleI/numShuffles,h,'Still shuffling');
end

%close(h)
for mcpI = 1:size(meascondPairs,1)
    for sessI = 1:numSess
        lengthSigDiff(sessI,mcpI) = sum(abs(lengthDiff(sessI))>abs(lengthDiffShuff(sessI,mcpI,:)))/numShuffles>shuffThresh;
        stdSigDiff(sessI,mcpI) = sum(abs(stdDiff(sessI))>abs(stdDiffShuff(sessI,mcpI,:)))/numShuffles>shuffThresh;
    end
end

end