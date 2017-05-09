FindBinEdges(pooled, x_adj_cm, anchorBin)
allPos = pooled.include.right | pooled.include.left;
allStarts = [pooled.bounds.right(:,1) ; pooled.bounds.left(:,1)];
allStops = [pooled.bounds.right(:,2) ; pooled.bounds.left(:,2)];

xstarts = x_adj_cm(allStarts)';
xstops = x_adj_cm(allStops)';

xmin = min(x_adj_cm(allPos));
xmax = max(x_adj_cm(allPos));

if sum(xstops > xstarts) == 0
    %starts to the right of stops
    binMod = -1;
    lims = [xmax xmin];
elseif sum(xstops > xstarts)/length(xstarts) >= 0.75
    %stops to the right of starts
    binMod = 1;
    lims = [xmin xmax];
end

anchorBin = 2.5;

ceil((xmax-xmin)/anchorBin)

cmperbin = 2.5

binsGood = 0;
while binsGood == 0
    nBins=ceil((xmax-xmin)/cmperbin);
    binEdges = (0:nBins)*cmperbin+xmin;
    
    startHist = histcounts(xstarts,binEdges);
    stopHist = histcounts(xstops,binEdges);
    
    figure; plot(x_adj_cm(allPos),y_adj_cm(allPos),'.')
    hold on
    plot(x_adj_cm(allStarts),y_adj_cm(allStarts),'.r')
    plot(x_adj_cm(allStops),y_adj_cm(allStops),'.g')
    plot([binEdges(1) binEdges(1)],[min(y_adj_cm(allStarts)) max(y_adj_cm(allStarts))],'k')
    plot([binEdges(2) binEdges(2)],[min(y_adj_cm(allStarts)) max(y_adj_cm(allStarts))],'k')
    plot([binEdges(end-1) binEdges(end-1)],[min(y_adj_cm(allStops)) max(y_adj_cm(allStops))],'k')
    plot([binEdges(end) binEdges(end)],[min(y_adj_cm(allStops)) max(y_adj_cm(allStops))],'k')



     %{
    plot(x(isrunning),y(isrunning),'.')
    for yy = 1:length(yEdges)
        hold on
        plot([xEdges(1) xEdges(end)],[yEdges(yy) yEdges(yy)],'b')
    end
    for xx = 1:length(xEdges)
        hold on
        plot([xEdges(xx) xEdges(xx)],[yEdges(1) yEdges(end)],'r')
    end
    plot(x(stem_frame_bounds.forced_r(:,1)),y(stem_frame_bounds.forced_r(:,1)),'.r')
    %}