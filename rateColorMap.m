function ptColors = rateColorMap(rates,colorMapUse,normLims)

if isempty(normLims)
    normMax = max(rates);
    normMin = min(rates);
    %outputClose = maxClose;
else
    normMax = normLims(2);
    normMin = normLims(1);
end
%minClose = min(ptsClose);

hh = figure;
cc = colormap(colorMapUse);
close(hh);

nColors = size(cc,1);
boundaries = linspace(normMin+0.00001,normMax-0.00001,nColors); %64

ptColors = zeros(length(rates),3);
for bdStops = 1:nColors
    thesePts = rates >= boundaries(bdStops);
    ptColors(thesePts,:) = repmat(cc(bdStops,:),sum(thesePts),1);
end

end