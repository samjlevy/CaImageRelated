ManualLinearizeNotes

h = figure; 
axes(h); 
xlim([0 10]) 
ylim([0 10])

[xp, yp] = ginput(2);
plot(xp,yp,'*')
midX = mean(xp);
midY = mean(yp);
hold on
plot(midX, midY,'*c')

slope = (yp(2) - yp(1)) / (xp(2) - xp(1));
xLength = abs((xp(2) - xp(1)));
yLength = abs((yp(2) - yp(1)));
lineLength = sqrt(yLength^2 + xLength^2);

%Sanity check
plot([xp(1) xp(1)+xLength],[yp(1) yp(1)+slope*xLength],'r')

crossSlope = -1/slope;
halfLength = lineLength/2;
plot([midX midX-(yLength/2)/crossSlope],[midY midY-(xLength/2)*crossSlope],'g')
plot([midX midX+(yLength/2)/crossSlope],[midY midY+(xLength/2)*crossSlope],'g')