function pooledCorrs = PoolCorrsAcrossMice(corrs)

numMice = length(corrs);
numComparisons = size(corrs{1},2);
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
        pooledCorrs{pcI} = [pooledCorrs{pcI}; corrs{mouseI}(:,pcI)];
    end
end

if iscell(pooledCorrs{1})
    pooledCorrs = cellfun(@cell2mat,pooledCorrs,'UniformOutput',false);
end

end