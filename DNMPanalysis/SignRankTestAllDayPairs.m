function [pVal,hVal,stats,whichWon,eachDayPair] = SignRankTestAllDayPairs(dataVecA,dataVecB,dayDiffs)

eachDayPair = unique(dayDiffs);

for dpI = 1:length(eachDayPair)
    [pVal(dpI),hVal(dpI),tstats] = signrank(...
        dataVecA(dayDiffs==eachDayPair(dpI)), dataVecB(dayDiffs==eachDayPair(dpI)));
    try
    stats(dpI).zval = tstats.zval;
    end
    try
    stats(dpI).signedrank = tstats.signedrank;
    end
    
    whichWon(dpI) = WhichWonRanks(...
        dataVecA(dayDiffs==eachDayPair(dpI)), dataVecB(dayDiffs==eachDayPair(dpI)));
end

end