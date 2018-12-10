GetAndSetDayPairsRestriction(dayPairs)


%Get all possible day pairs


%Convert to day diffs

%How many of each day diff
cell2mat(cellfun(@(x) sum(x==[0:maxDay],1)/2,daysApart,'UniformOutput',false))

%Eliminate day diffs without enough of those
    %Return 
        %Day pairs without problem ones
        %Day diffs without problem ones
        %Logical vector of original of which to include
