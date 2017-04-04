function [ Durations, totalDurations ] = DurationsThisBlock (starts, stops, FT)

%hits = zeros(size(FT,1),1);
Durations = [];
for trialNum = 1:length(starts)
    theseInds = starts(trialNum):stops(trialNum);
    Durations = [Durations, sum(FT(:,theseInds),2)]; %#ok<*AGROW>
end

totalDurations = sum(Durations,2);

end