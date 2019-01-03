function PVcorrCompStemVSarm 
    qq{pvtI} = subplot(2,3,pvtI);  
    
    plot([-0.5 max(pooledDaysApart{pvtI}{condI})+0.5],[0 0],'k')
    hold on
    
    plot(pooledDaysApart{pvtI}{condI}-0.2,stemCorrsPooled{pvtI}{condI},'.','Color',plotColors{condI,1})
    plot(pooledDaysApart{pvtI}{condI}+0.2,armCorrsPooled{pvtI}{condI},'.','Color',plotColors{condI,2})
    
    daysHere = unique(pooledDaysApart{pvtI}{condI});
    for dayI = 1:length(daysHere)
        [statsOut{pvtI}.rankSum.pVal(dayI),statsOut{pvtI}.rankSum.hVal(dayI)] = ranksum(...
            stemCorrsPooled{pvtI}{condI}(pooledDaysApart{pvtI}{condI}==daysHere(dayI)),...
            armCorrsPooled{pvtI}{condI}(pooledDaysApart{pvtI}{condI}==daysHere(dayI)));
            statsOut{pvtI}.rankSum.whichWon(dayI) = WhichWonRanks(...
                stemCorrsPooled{pvtI}{condI}(pooledDaysApart{pvtI}{condI}==daysHere(dayI)),...
                armCorrsPooled{pvtI}{condI}(pooledDaysApart{pvtI}{condI}==daysHere(dayI)));
            
        if statsOut{pvtI}.rankSum.hVal(dayI)==1
            plot(daysHere(dayI),0.8,'*k')
            switch statsOut{pvtI}.rankSum.whichWon(dayI)
                case 1
                    text(daysHere(dayI),0.85,'S','Color','k')
                case 2
                    text(daysHere(dayI),0.75,'A','Color','k')
            end
        end
    end