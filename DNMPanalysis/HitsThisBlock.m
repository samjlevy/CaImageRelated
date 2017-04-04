function [ hits, totalHits ] = HitsThisBlock (starts, stops, FT)

%hits = zeros(size(FT,1),1);
hits = [];
for trialNum = 1:length(starts)
    theseInds = starts(trialNum):stops(trialNum);
    hits = [hits, any(FT(:,theseInds),2)]; %#ok<*AGROW>
end

totalHits = sum(hits,2); 

end