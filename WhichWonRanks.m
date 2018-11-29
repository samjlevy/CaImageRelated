function whichWon = WhichWonRanks(datA, datB)

markerVal = [zeros(length(datA),1); ones(length(datB),1)];
[ranks,tiedRanks] = tiedrank([datA; datB]);
aRank = nanmean(ranks(markerVal==0));
bRank = nanmean(ranks(markerVal==1));

if aRank > bRank
    whichWon = 1;
elseif bRank > aRank
    whichWon = 2;
else
    whichWon = 0;
    %disp('Rank error?')
    %keyboard
end
    
end