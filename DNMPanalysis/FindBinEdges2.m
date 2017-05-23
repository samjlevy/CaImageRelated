xmin=min(x(allInclude));
ymin=min(y(allInclude));
allXmax = max(x);
allXmin = min(x);
allYmax = max(y);
allYmin = min(y);
xbinsUp = floor((allXmax-xmin)/cmperbin);
ybinsUp = floor((allYmax-ymin)/cmperbin);
xbinsDown = floor((maybeX-allXmin)/cmperbin);
ybinsDown = floor((maybeY-allYmin)/cmperbin);

xBins1 = xmin+(0:xbinsUp)*cmperbin;
yBins1 = ymin+(0:ybinsUp)*cmperbin;
xBins2 = sort(xmin-(1:xbinsDown)*cmperbin);
yBins2 = sort(ymin-(1:ybinsDown)*cmperbin);

xEdges = [xBins2, xBins1];
yEdges = [yBins2, yBins1];

plot(x,y,'.')
hold on
plot(x(allInclude),y(allInclude),'.r')
for xx = 1:length(xEdges)
    hold on
    plot([xEdges(xx) xEdges(xx)],[allYmin allYmax],'k')
end
for yy = 1:length(yEdges)
    hold on
    plot([allXmin allXmax],[yEdges(yy) yEdges(yy)],'k')
end