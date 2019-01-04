function [figHand, statsOut] = PVcorrCompStemVsArmDaysApart(stemCorrsPooled,armCorrsPooled,pooledDaysApart,pvNames,condI)

plotColors = {[0 0 1], [0 1 1];...
              [0.6392    0.0784    0.1804],[0.8510    0.3294    0.1020];...
              [0.4706    0.6706    0.1882],[0 1 0]};

figHand = figure('Position',[680 421 1177 557]); qq = [];

subRows = ceil(length(pvNames)/3);
for pvtI = 1:length(pvNames)
    qq{pvtI} = subplot(subRows,3,pvtI);
    
    [statsOut{pvtI}] = PVcorrCompStemVSarm(stemCorrsPooled{pvtI}{condI},armCorrsPooled{pvtI}{condI},...
                        pooledDaysApart{pvtI}{condI},plotColors(condI,:));
                        
    title(pvNames{pvtI})
end

end
    
    
