function ptColors = rateColorMap(rates,colorMapUse,normMax,normMin)

if isempty(normMax)
    normMax = max(rates);
    %outputClose = maxClose;
end

if isempty(normMin)
    normMin = 0;
end
%minClose = min(ptsClose);


if ischar(colorMapUse)
hh = figure;
cc = colormap(colorMapUse);
close(hh);
elseif isnumeric(colorMapUse)
cc = colorMapUse;
end

boundaries = linspace(normMin,normMax-0.00001,size(cc,1));% 64

ptColors = zeros(length(rates),3);
for bdStops = 1:size(cc,1)%64
    thesePts = rates >= boundaries(bdStops);
    ptColors(thesePts,:) = repmat(cc(bdStops,:),sum(thesePts),1);
end

end