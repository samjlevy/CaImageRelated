RoughSplitterPlot(baseTMap,cellPlot)


mazeSplit = squeeze(~isnan(numBinsAboveShuffle));
mazeSplitActive = [mazeSplit(:,1) & dayUse, mazeSplit(:,2) & dayUse];
bothSplit = sum(mazeSplitActive,2)==2;

splitDir = squeeze(meanRateDiff);
splitAbs = splitDir./abs(splitDir);


splitsSameWay = diff(splitAbs(thisCellSplits,:),1,2)==0;%(bothSplit,:)bothSplit & activeBoth
sum(splitsSameWay)/length(splitsSameWay)

activeBoth = [(aboveThresh{1}+aboveThresh{2})>0 (aboveThresh{3}+aboveThresh{4})>0];
activeBoth = sum(activeBoth,2)==2;


baseTMap = TMap_unsmoothed;
cellPlot = aa(9);
rateHere = {TMap_unsmoothed{cellPlot,1,:}};

numBins = length(rateHere{1});

figure; 
subplot(1,2,1)
plot(rateHere{1},'r','LineWidth',2)
hold on
plot(rateHere{2},'b','LineWidth',2)


subplot(1,2,2)
plot(rateHere{3},'r','LineWidth',2)
hold on
plot(rateHere{4},'b','LineWidth',2)

use rate diff to look at if they split the same way


figg = [];
            cp = splittersPlot{mouseI}(cellI);
            pd = find(cellSSI{mouseI}(cp,:)>0);
            [figg] = PlotSplittingDotPlot(daybyday,cellTBTarm{mouseI},cp,pd,'arm','line','wholeLap');
            
            
            
Decoding