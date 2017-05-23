Occmap = position histogram
RunOccMap = same but only when isrunning
TCounts = spike histogram
TMap_unsmoothed = spike histogram divided by position histogram
TMap_gauss = smoothed from TMap_unsmoothed

positionThresh=3;
spikeThresh=3;
%Probably need to bump up cmperbin to 2 (more?)

%Use TMap_unsmoothed to threshold out too few samples between fields
FoL.maps=load('PlaceMaps_forced_left_2cm.mat');
FoL.stats=load('PlaceStats_forced_left_2cm.mat');
FoR.maps=load('PlaceMaps_forced_right_2cm.mat');
FoR.stats=load('PlaceStats_forced_right_2cm.mat');

blank=zeros(size(FoL.maps.OccMap));
%All positions where there are enough samples: 
enoughPositions = FoL.maps.RunOccMap > positionThresh;
enoughInds = find(enoughPositions);

%Left cell vs. Right Cell rate remapping
leftCell=FoL.maps.TMap_unsmoothed{1,4};
rightCell=FoR.maps.TMap_unsmoothed{1,4};

%Pixels counted
leftPixels=FoL.stats.PFpixels{4,1};
rightPixels=FoR.stats.PFpixels{4,1};


%Above rate thresh, unsmoothed
lot=leftPixels(FoL.maps.TCounts{1,4}(leftPixels) >= 3);%pixels
rot=rightPixels(FoR.maps.TCounts{1,4}(rightPixels) >= 3);%pixels

%These pixels in the smoothed field
leftRates=FoL.maps.TMap_gauss{1,4}(lot);%rates
rightRates=FoR.maps.TMap_gauss{1,4}(rot);%rates

remap1 = (mean(rightRates) - mean(leftRates)) / (mean(rightRates) + mean(leftRates));


leftInFieldRates = FoL.maps.TMap_gauss{1,4}(leftPixels);
rightInFieldRates = FoR.maps.TMap_gauss{1,4}(rightPixels);

remap2 = (mean(rightInFieldRates)-mean(leftInFieldRates))/(mean(rightInFieldRates)+mean(leftInFieldRates));


%Plot things
leftPix=blank; leftPix(lot)=leftRates;
rightPix=blank; rightPix(rot)=rightRates;

joint=blank; joint(lot)=0.6; joint(rot)=1;	

plotLeft=leftPix;
plotRight=rightPix;
figure;
subplot(1,4,[1,2])
imagesc(plotLeft)
title('Cell 4, FoLeft >= 3 transients')
subplot(1,4,[3,4])
imagesc(plotRight)
title('Cell 4, FoRight >= 3 transients')

figure;
subplot(1,4,[1,2])
imagesc(FoL.maps.TMap_gauss{1,4})
title('Cell 4, ForcedRight')
subplot(1,4,[3,4])
imagesc(FoR.maps.TMap_gauss{1,4})
title('Cell 4, ForcedLeft')


imagesc(thisCell)
enoughSpikes = FoL.maps.TCounts{1,4}>3;
figure; imagesc(FoL.maps.TCounts{1,4}>3)
thesePixelsA=FoL.stats.PFpixels{4,1}
FoL.maps.TCounts{1,4}(thesePixelsA)
FoL.maps.TCounts{1,4}(thesePixelsA)>3
sum(TCounts{1,4}(thesePixelsA)>3)

FoR.maps=load('PlaceMaps_forced_right_2cm.mat')
FoR.stats=load('PlaceStats_forced_right_2cm.mat')