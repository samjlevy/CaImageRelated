function growingTraitLogical = DayPairGrowingTraitLogical(traitLogical,dayPairs,compPair)

numCells = size(traitLogical,1);
numDayPairs = size(dayPairs,1);

growingTraitLogical = zeros(numCells,numDayPairs,size(traitLogical,3));
for dpI = 1:numDayPairs
    %Slot in everything from that day pair
    growingTraitLogical(:,dpI,:) = traitLogical(:,dayPairs(dpI,1),:);
    
    %Fix the other condition
    growingTraitLogical(:,dpI,compPair(2)) = traitLogical(:,dayPairs(dpI,2),compPair(2));
end

end
    