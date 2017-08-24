(trialbytrial, allfiles, 

numCells = size(trialbytrial(1).trialPSAbool{1,1},1);
[LRsel, STsel] = LRSTselectivity(trialbytrial);
%comparison of how selectivity is different laps with a hit vs. total spikes

figure;
tc = 14
nonans = isnan(LRsel.hits);
nonans = sum(nonans,2)==0;
    


for tc = 1:numCells
    if any(LRsel.hits(tc,:))
        sels = find(~isnan(LRsel.hits(tc,:)));
        hold on
        if sels>1
        plot(LRsel.hits(tc,[sels(1) sels(end)]),STsel.hits(tc,[sels(1) sels(end)]),'-o')
        end
    end
    xlabel('Left                         Right')
    ylabel('Study                        Test')
end

%look at change over days, from day before
LRdayChange = nan(size(LRsel.hits)); STdayChange = nan(size(LRsel.hits));
LRfig = figure('name','LRfig'); plot(0,0,'*'); xlim(LRfig.Children,[1 11]);
title(LRfig.Children,'Left/Right selectivity change')
STfig = figure('name','STfig'); plot(0,0,'*'); xlim(STfig.Children,[1 11]);
title(STfig.Children,'Study/Test selectivity change') 
passed = 0;
for tc = 1:numCells
if any(LRsel.hits(tc,:))
sels = find(~isnan(LRsel.hits(tc,:)));
sels2 = find(~isnan(STsel.hits(tc,:)));
    if length(sels)~=length(sels2)
        disp(['different days with non nan selectivity cell ' num2str(tc)])
    end
if length(sels)>1
    passed = passed+1;
    LRplot = [0 diff(LRsel.hits(tc,sels))];
    STplot = [0 diff(STsel.hits(tc,sels))];
    xNum = sels-(sels(1)-1);
    
    hold(LRfig.Children,'on')
    %plot(LRfig.Children,xNum,LRplot,'-o')
    
    hold(STfig.Children,'on')
    %plot(STfig.Children,xNum,STplot,'-o')
    
    LRdayChange(tc,1:length(LRplot)) = LRplot;
    STdayChange(tc,1:length(STplot)) = STplot;
end
end
end
    
    
        