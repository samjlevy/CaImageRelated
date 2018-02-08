fname = '20170914WWY1R_1tiff-1.tiff'
info = imfinfo(fname)
imageStack = [];
numberOfImages = length(info);
for k = 1:numberOfImages
currentImage = imread(fname, k, 'Info', info);
imageStack(:,:,k) = currentImage;
end

maxValue = max(max(max(imageStack))); maxValue = 223;
minValue = min(min(min(imageStack))); minValue = 20;

radius = 5;
edge = floor(radius/2);
outName = 'myTiff.tiff';
gg = figure;
minVal = 1000;
maxVal = 1000;
for frameI = 1:numberOfImages
    filtMov = zeros(size(imageStack,1)+(radius-1),size(imageStack,2)+(radius-1),9);
    filtMov = convn(imageStack(:,:,frameI:frameI+(radius-1)),ones(radius,radius,radius));
    ff = filtMov(edge+1:end-edge,edge+1:end-edge,radius);
    
    newMin = min(min(ff)); if newMin<minVal; minVal = newMin; end
    newMax = max(max(ff)); if newMax>maxVal; maxVal = newMax; end
    
    frameToWrite = (ff - 2300) / 24000;
    
    %imshow(ff,[])
    %frameToWrite = gg.Children.Children.CData;
    
    %frameToWrite = rescale(single(filtMov(:,:,radius)),0,1);
    imwrite(frameToWrite, outName, 'WriteMode', 'append',  'Compression','none');
    disp(num2str(frameI))
end

pixCheckX = 151:250;
pixCheckY = 301:400;

imageFilt = zeros(length(pixCheckX),length(pixCheckY),numberOfImages);
for pcxI = 1:length(pixCheckX)
    for pcyI = 1:length(pixCheckY)
        

dataHere = squeeze([imageStack(pixCheckX(pcxI), pixCheckY(pcyI), :)]);


[peaks, peakLocs] = findpeaks(dataHere);
[troughs, troughLocs] = findpeaks(max(dataHere)-dataHere);3
troughs = max(dataHere)-troughs;
%figure; plot(dataHere)
%hold on
%plot(peakLocs,peaks,'*r')
%plot(troughLocs,max(dataHere)-troughs,'*r')

points = [peaks; troughs];
pointLocs = [peakLocs; troughLocs];
[locsSorted, sortOrder] = sort(pointLocs);
pointsSorted = points(sortOrder);

peakDiff = diff(pointsSorted,1)/2;
peakMids = pointsSorted(1:end-1)+peakDiff;
pdX = locsSorted(1:end-1) + diff(locsSorted,1)/2;

histogram(diff(locsSorted,1),0.5:1:10.5)

window = 4;
for winI = 1:length(dataHere)-(window-1)
slidingMean(winI) = mean(dataHere(winI:winI+(window-1)));
end

figure; plot(dataHere)
hold on
plot(locsSorted, pointsSorted)
plot(pdX, peakMids)

imageFilt(pcxI, pcyI, :) = 


dataDiff = diff(dataHere,1)/2;
diffX = 1.5:1:length(dataDiff)+0.5;
plot(diffX,dataHere(1:end-1)+dataDiff,'*g')

for offSet = 0:20
    compA = dataHere(1:end-offSet);
    compB = dataHere(1+offSet:end);
    