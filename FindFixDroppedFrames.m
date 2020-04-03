%Find frames for replacement

frameDiffs = diff([0; badFrames]);
oneFrames = frameDiffs==1;
oneOns = find(diff([0; oneFrames])==1);
oneOffs = find(diff([oneFrames; 0])==-1);
framesFix = nan(size(badFrames));
framesFix(frameDiffs~=1) = badFrames(frameDiffs~=1)-1;
oneEpochs = [oneOns oneOffs];
for ii = 1:size(oneEpochs,1)
framesFix(oneEpochs(ii,1):oneEpochs(ii,2)) = framesFix(oneEpochs(ii,1)-1);
end