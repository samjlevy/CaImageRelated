function ptColors = rateColorMap(rates,colorMapUse,normMax)

if isempty(normMax)
    normMax = max(rates);
    %outputClose = maxClose;
end
%minClose = min(ptsClose);

hh = figure;
cc = colormap(colorMapUse);
close(hh);

boundaries = linspace(0,normMax-0.00001,size(cc,1));% 64

ptColors = zeros(length(rates),3);
for bdStops = 1:size(cc,1)%64
    thesePts = rates >= boundaries(bdStops);
    ptColors(thesePts,:) = repmat(cc(bdStops,:),sum(thesePts),1);
end

end