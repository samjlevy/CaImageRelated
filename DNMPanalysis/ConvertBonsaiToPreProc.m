function ConvertBonsaiToPreProc

csvread('polygonCoords.csv')
bonsaiCoords = csvread('180417_bonsaiTracking.csv');

bRed = []; 
for ii = 1:2:size(bonsaiCoords,1) 
    bRed = [bRed; nanmean(bonsaiCoords(ii:ii+1,:),1)]; 
end
bRed = [bRed; bonsaiCoords(end,:)];

xAVI = nanmean(bRed(:,[1 3]),2);
yAVI = 480-nanmean(bRed(:,[2 4]),2);

% Coordinates offset by polygon boundaries
xDiff = min(polyCoords(:,1));
xAVI = xAVI+xDiff;
yDiff = min(polyCoords(:,2));
yAVI = yAVI-yDiff;

save('bonsaiCoords.mat','xAVI','yAVI','polyCoords');

