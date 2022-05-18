function percentileRanks = percentileOfEach(vector)

nNums = numel(vector);
%[sorted,sortOrder] = sort(vector,'ascend');
%percentileRanks = (sortOrder-1) / (nNums-1);
for ii = 1:nNums
    percentileRanks(ii,1) = (sum(vector(ii) > vector) / (nNums-1));
end

end