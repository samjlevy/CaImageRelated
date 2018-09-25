function [pVal,hVal,whichWon,eachDayPair] = RankSumAllDaypairs(dataVecA,dataVecB,dayPairs)

eachDayPair = unique(dayPairs);

for dpI = 1:length(eachDayPair)
    datA = dataVecA(dayPairs==eachDayPair(dpI));
    datB = dataVecB(dayPairs==eachDayPair(dpI));
    
    %Do the stat
    [pVal(dpI),hVal(dpI)] = ranksum(datA,datB);
    
    %Return a value for plotting
    markerVal = [zeros(length(datA),1); ones(length(datB),1)];
    [ranks,tiedRanks] = tiedrank([datA; datB]);
    aRank = sum(ranks(markerVal==0));
    bRank = sum(ranks(markerVal==1));
    
    if aRank > bRank
        whichWon(dpI) = 1;
    elseif bRank > aRank
        whichWon(dpI) = 2;
    else
        whichWon(dpI) = 0;
        %disp('Rank error?')
        %keyboard
    end
end

end