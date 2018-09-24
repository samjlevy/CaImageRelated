function [rho,pVal,whichWon] = RankSumAllDaypairs(dataVecA,dataVecB,dayPairs)

eachDayPair = unique(dayPairs);

for dpI = 1:length(eachDayPair)
    datX = dataVecA(dayPairs==eachDayPair(dpI));
    datY = dataVecB(dayPairs==eachDayPair(dpI));
    
    %Do the stat
    [rho(dpI),pVal(dpI)] = ranksum(datX,datY);
    
    %Return a value for plotting
    markerVal = [zeros(length(datX),1); ones(length(datY),1)];
    [ranks,tiedRanks] = tiedrank([datX; datY]);
    xRank = sum(ranks(markerVal==0));
    yRank = sum(ranks(markerVal==1));
    
    if xRank > yRank
        whichWon(dpI) = 1;
    elseif yRank > xRank
        whichWon(dpI) = 2;
    else
        whichWon(dpI) = 0;
        %disp('Rank error?')
        %keyboard
    end
end

end