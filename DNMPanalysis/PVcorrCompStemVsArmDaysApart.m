function [figHand, statsOut] = PVcorrCompStemVsArmDaysApart(stemCorrsPooled,armCorrsPooled,pooledDaysApart,pvNames,condI)

plotColors = {[0 0 1], [0 1 1];...
              [0.6392    0.0784    0.1804],[0.8510    0.3294    0.1020];...
              [0.4706    0.6706    0.1882],[0 1 0]};

figHand = figure('Position',[680 421 1177 557]); qq = [];
for pvtI = 1:length(pvNames)
    
    PVcorrCompStemVSarm 
    
    title(pvNames{pvtI})
    xlim([-0.5 max(pooledDaysApart{pvtI}{condI})+0.5])
end

end
    
    
