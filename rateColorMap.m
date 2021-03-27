function ptColors = rateColorMap(rates,colorMapUse,normMax)

if isempty(normMax)
    normMax = max(rates);
    %outputClose = maxClose;
end
%minClose = min(ptsClose);

hh = figure;
cc = colormap(colorMapUse);
close(hh);

nColors = size(cc,1);
boundaries = linspace(0,normMax-0.00001,nColors); %64

ptColors = zeros(length(rates),3);
for bdStops = 1:nColors
    thesePts = rates >= boundaries(bdStops);
    ptColors(thesePts,:) = repmat(cc(bdStops,:),sum(thesePts),1);
end

end