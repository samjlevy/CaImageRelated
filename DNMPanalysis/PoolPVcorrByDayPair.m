function [pvPooledByDayPair,dayPairList] = PoolPVcorrByDayPair(pvCorrs,dayPairs)
%Input is a cell of pv corrs {dayPair}(1 x bin) and list of day pairs
%Assumes dayPairs is actually a pair

dayPairs = sort(dayPairs,2);
numDayPairs = size(dayPairs,1);
numBins = size(pvCorrs{1},2);

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
    
    if size(pvCorrs{1},1)==size(pvCorrs{1},2)
        %It's bin i x bin j
        pvsHere = cell2mat(pvCorrs(theseDPs)');
        pvsHere = reshape(pvsHere,numBins,numBins,sum(theseDPs));
        pvPooledByDayPair{dplI,1} = mean(pvsHere,3);
    else
        pvsHere = cell2mat(pvCorrs(theseDPs));
        pvPooledByDayPair{dplI,1} = mean(pvsHere,1);
    end     
end   

end