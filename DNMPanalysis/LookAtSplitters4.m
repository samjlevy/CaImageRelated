function [rateDiff, rateSplit, meanRateDiff, DIeach, DImean] = LookAtSplitters4(TMap_unsmoothed,condPairs,trialReli)
%includes a basic splitting which is sum of differences in firing rates,
%and normalized across the number of bins where there was activity in at
%least one of the conditions
%condpairs is like in PFsLin2, but here describes comparisons being made.
%So LvR is [1 2; 3 4]; SvT is [1 3; 2 4];
%Differences measured as (second column - first column)

%rateDiff      - rate differences of individual bins
%rateSplit     - sum of rate differences in all bins
%meanRateDiff  - rateSplit / number of bins cell is active
%DIeach        - DI score each bin (rateDiff / total amount of firing in that bin)
%DImax         - max of the DIeach
%DImean        - nanmean of DIeach
%add one that is ...?

if isempty(condPairs); condPairs = combnk(1:size(TMap_unsmoothed,2),2); end

numSess = size(TMap_unsmoothed,3);
numConds = size(condPairs,1);
numCells = size(TMap_unsmoothed,1);
%numBins = length(TMap_unsmoothed{1,1,1});

if isempty(trialReli)
    trialReli = ones(numCells,numSess); 
else
    trialReli = sum(trialReli,3) > 0;
end

rateDiff = cell(numCells,numSess,numConds);
rateSplit = nan(numCells,numSess,numConds);
meanRateDiff = nan(numCells,numSess,numConds);
DIeach = cell(numCells,numSess,numConds);
%DImax = nan(numCells,numSess,numConds);
DImean = nan(numCells,numSess,numConds);

for cpI = 1:numConds
    for sessI = 1:numSess
        for cellI = 1:numCells
            if trialReli(cellI,sessI)==1
                ratesA = TMap_unsmoothed{cellI,condPairs(cpI,1),sessI};
                ratesB = TMap_unsmoothed{cellI,condPairs(cpI,2),sessI};
                
                rateDiff{cellI,sessI,cpI} = ratesB - ratesA;
                rateSplit(cellI,sessI,cpI) = sum(rateDiff{cellI,sessI,cpI});
                binsActive = ratesA ~=0 | ratesB~=0;
                meanRateDiff(cellI,sessI,cpI) = rateSplit(cellI,sessI,cpI)/sum(binsActive);
                DIeach{cellI,sessI,cpI} = rateDiff{cellI,sessI,cpI} ./ (ratesA + ratesB);
                %DImax(cellI,sessI,cpI) = max(DIeach(cellI,sessI,cpI));
                DImean(cellI,sessI,cpI) = nanmean(DIeach{cellI,sessI,cpI});
            end
        end
    end
end
   
end