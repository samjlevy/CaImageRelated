xHere = daybydayBig.all_x_adj_cm{4};
yHere = daybydayBig.all_y_adj_cm{4};





for ppi = 1:length(pts)-1; vel(ppi) = hypot(abs(xHere(pts(ppi))-xHere(pts(ppi+1))),abs(yHere(pts(ppi))-yHere(pts(ppi+1)))); end
figure; plot(vel)
bad = vel>4;
velBstart = find(diff(bad)==1)+1;
velBstop = find(diff(bad)==-1);

for vvI = 1:length(velBstart)
    badPs = pts(velBstart(vvI):velBstop(vvI));
    
    
    xf = interp1([badPs(1)-1 badPs(end)+1],xHere([badPs(1)-1 badPs(end)+1]),badPs);
    yf = interp1([badPs(1)-1 badPs(end)+1],yHere([badPs(1)-1 badPs(end)+1]),badPs);
    
    xHere(badPs) = xf;
    yHere(badPs) = yf;
end


daybydayBig.all_x_adj_cm{4} = xHere;
daybydayBig.all_y_adj_cm{4} = yHere;


lapsH = cellTBT{4}(2).sessID == 6;
xHere = [cellTBT{4}(2).trialsX{lapsH}];
yHere = [cellTBT{4}(2).trialsY{lapsH}];

lapsHH = find(lapsH);
for lapI = 1:length(lapsHH)
    lapP = lapsHH(lapI);
    xHere = cellTBT{4}(2).trialsX{lapP};
    yHere = cellTBT{4}(2).trialsY{lapP};
    
    aa = figure;
    plot(xHere,yHere,'.k')
    title(num2str(lapP))
    
    input('keep going','s')
    figure(aa)
end