xH = daybydayBig.all_x_adj_cm{9};
yH = daybydayBig.all_y_adj_cm{9};

psaH = daybydayBig.PSAbool{9};

goodPts = xH > -60 & xH < -2 & yH > -3 & yH < 3;

psaGood = psaH(1027,gootPts)

figure; plot(xH(goodPts),yH(goodPts),'.k')
hold on
plot(xH(psaH(1027,:) & goodPts),yH(psaH(1027,:) & goodPts),'.r')

possL = diff(xH(goodPts)) > 20;
lapBs = find(possL);

xHH = xH(goodPts);
psaHH = psaH(1027,goodPts);
lapBs = [0 lapBs numel(xHH)];
figure;
for lapI=1:numel(lapBs)-1
    dHere = lapBs(lapI)+1 : lapBs(lapI+1);

    posHere = xHH(dHere);
    sHere = psaHH(dHere);

    plot(posHere,lapI*ones(size(posHere)),'|','MarkerEdgeColor',[0.5 0.5 0.5])
    hold on
    plot(posHere(sHere),lapI*ones(size(posHere(sHere))),'|','MarkerEdgeColor',[1 0.25 0.25])
end