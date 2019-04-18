function [pvPooledByDayPair,dayPairList] = PoolPVcorrByDayPair(pvCorrs,dayPairs)
%Input is a cell of pv corrs {dayPair}(1 x bin) and list of day pairs
%Assumes dayPairs is actually a pair

dayPairs = sort(dayPairs,2);
numDayPairs = size(dayPairs,1);

%Get unique day pairs (this could be a callable function)
dayPairList = dayPairs(1,:);
for dpI = 1:numDayPairs
    dpHere = sort(dayPairs(dpI,:));
    
    dayPairHere = 0;
    for dplI = 1:size(dayPairList,1)
        if sum(dayPairList(dplI,:)==dpHere)==2
            dayPairHere = dayPairHere + 1;
        end
    end
    
    if dayPairHere==0
        dayPairList = [dayPairList; dpHere];
    end
end

%Mean for each day pair
pvPooledByDayPair = [];
for dplI = 1:size(dayPairList,1)
    dpHere = dayPairList(dplI,:);
    theseDPs = sum(dayPairs==dpHere,2)==2;
    pvsHere = cell2mat(pvCorrs(theseDPs));
    pvPooledByDayPair{dplI,1} = mean(pvsHere,1);
end   

end