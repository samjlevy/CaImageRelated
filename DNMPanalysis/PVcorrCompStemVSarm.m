function [statsOut] = PVcorrCompStemVSarm(stemCorrsPooled,armCorrsPooled,pooledDaysApart,plotColors)   
    
plot([-0.5 max(pooledDaysApart)+0.5],[0 0],'k')
hold on

plot(pooledDaysApart-0.2,stemCorrsPooled,'.','Color',plotColors{1})
plot(pooledDaysApart+0.2,armCorrsPooled,'.','Color',plotColors{2})

daysHere = unique(pooledDaysApart);
for dayI = 1:length(daysHere)
    [statsOut.rankSum.pVal(dayI),statsOut.rankSum.hVal(dayI)] = ranksum(...
        stemCorrsPooled(pooledDaysApart==daysHere(dayI)),...
        armCorrsPooled(pooledDaysApart==daysHere(dayI)));
    statsOut.rankSum.whichWon(dayI) = WhichWonRanks(...
        stemCorrsPooled(pooledDaysApart==daysHere(dayI)),...
        armCorrsPooled(pooledDaysApart==daysHere(dayI)));
    [statsOut.signTest.pVal(dayI),statsOut.signTest.hVal(dayI)] = signtest(...
        stemCorrsPooled(pooledDaysApart==daysHere(dayI)),...
        armCorrsPooled(pooledDaysApart==daysHere(dayI)));
    
    if statsOut.rankSum.hVal(dayI)==1
        plot(daysHere(dayI),0.8,'*k')
        switch statsOut.rankSum.whichWon(dayI)
            case 1
                text(daysHere(dayI),0.85,'S','Color','k')
            case 2
                text(daysHere(dayI),0.75,'A','Color','k')
        end
    end
end

xlim([min(pooledDaysApart)-0.5 max(pooledDaysApart)+0.5])

end