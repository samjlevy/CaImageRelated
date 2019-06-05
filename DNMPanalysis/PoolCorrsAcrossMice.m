function pooledCorrs = PoolCorrsAcrossMice(corrs)
%Expects mouseI to be the lowest cell array

numMice = length(corrs);
numComparisons = size(corrs{1},2);
if iscell(corrs{1})
    numBinsJ = size(corrs{1}{1},1);
else
    numBinsJ = 1;
end
%{
if strcmpi(class(corrs{1}),'cell')
    numComparisons = length(corrs{1});
elseif isnumeric(corrs{1})
    numComparisons = size(corrs{1},2);
end
%}
pooledCorrs = cell(numComparisons,1);
for mouseI = 1:numMice
    for pcI = 1:numComparisons
        if numBinsJ==1
            pooledCorrs{pcI} = [pooledCorrs{pcI}; corrs{mouseI}(:,pcI)];
        else
            %it's bin I x bin J
            corrsHere = corrs{mouseI}(:,pcI);
            corrsHereMat = [corrsHere{:}];
            corrsHereLong = reshape(corrsHereMat,numBinsJ,numBinsJ,[]);
            pooledCorrs{pcI} = cat(3,pooledCorrs{pcI},corrsHereLong);
        end
    end
end

if iscell(pooledCorrs{1})
    pooledCorrs = cellfun(@cell2mat,pooledCorrs,'UniformOutput',false);
end

end