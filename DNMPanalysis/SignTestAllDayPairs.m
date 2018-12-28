function [pVal,hVal,whichWon,eachDayPair] = SignTestAllDayPairs(dataVecA,dataVecB,dayDiffs)

eachDayPair = unique(dayDiffs);

for dpI = 1:length(eachDayPair)
    [pVal(dpI),hVal(dpI)] = signtest(...
        dataVecA(dayDiffs==eachDayPair(dpI)) - dataVecB(dayDiffs==eachDayPair(dpI)));
    
    whichWon(dpI) = WhichWonRanks(...
        dataVecA(dayDiffs==eachDayPair(dpI)), dataVecB(dayDiffs==eachDayPair(dpI)));
end

end