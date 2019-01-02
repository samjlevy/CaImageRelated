function [rateDiff, rateSplit, meanRateDiff, DIeach, DImean, DIall] = LookAtSplitters4(TMap_unsmoothed,condPairs,trialReli)
%includes a basic splitting which is sum of differences in firing rates,
%and normalized across the number of bins where there was activity in at
%least one of the conditions
%condpairs is like in PFsLin2, but here describes comparisons being made.
%So LvR is [1 2; 3 4]; SvT is [1 3; 2 4]; (for unpooled); pool is just [1 2]
%Differences measured as (second column - first column)

%rateDiff      - rate differences of individual bins
%rateSplit     - sum of rate differences in all bins
%meanRateDiff  - mean of rate diffs / number of bins cell is active
%DIeach        - DI score each bin (rateDiff / total amount of firing in that bin)
%DImax         - max of the DIeach
%DImean        - nanmean of DIeach
%DIall?        - DI on all firing?

if isempty(condPairs); condPairs = combnk(1:size(TMap_unsmoothed,3),2); end

if rem(size(condPairs,2),2)~=0
    disp('error: size of cond pairs is not even')
    keyboard
end

numSess = size(TMap_unsmoothed,2);
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
DIall = nan(numCells,numSess,numConds);

for cpI = 1:numConds
    for sessI = 1:numSess
        for cellI = 1:numCells
            if trialReli(cellI,sessI)==1
                %Get the each half of the conditions in condPairs row cpI
                condsA = condPairs(cpI, 1:(size(condPairs,2)/2) );
                condsB = condPairs(cpI, (size(condPairs,2)/2+1):size(condPairs,2) );
                
                %Get the rates
                ratesA = [TMap_unsmoothed{cellI,sessI,condsA}];
                ratesB = [TMap_unsmoothed{cellI,sessI,condsB}];
                
                %Make some discrimination indices
                rateDiff{cellI,sessI,cpI} = ratesB - ratesA;
                rateSplit(cellI,sessI,cpI) = sum(rateDiff{cellI,sessI,cpI});
                binsActive = ratesA ~=0 | ratesB~=0;
                meanRateDiff(cellI,sessI,cpI) = rateSplit(cellI,sessI,cpI)/sum(binsActive);
                DIeach{cellI,sessI,cpI} = rateDiff{cellI,sessI,cpI} ./ (ratesA + ratesB);
                %DImax(cellI,sessI,cpI) = max(DIeach(cellI,sessI,cpI));
                DImean(cellI,sessI,cpI) = nanmean(DIeach{cellI,sessI,cpI});
                DIall(cellI,sessI,cpI) = (mean(ratesB) - mean(ratesA)) / (sum(ratesA) + sum(ratesB));
            end
        end
    end
end
   
end