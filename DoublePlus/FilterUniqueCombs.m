function [uniqueCombs] = FilterUniqueCombs(combMatrix)

nCombs = size(combMatrix,1);
bitPerComb = size(combMatrix,2);
uniqueCombs = combMatrix(1,:);
for ii = 2:nCombs
    haveThisComb = [];
    for jj = 1:size(uniqueCombs,1)
        haveThisComb(jj) = sum(sum(uniqueCombs(jj,:) == combMatrix(ii,:)',2)) == bitPerComb;
    end

    if sum(haveThisComb)==0
        uniqueCombs = [uniqueCombs; combMatrix(ii,:)];
    end

end