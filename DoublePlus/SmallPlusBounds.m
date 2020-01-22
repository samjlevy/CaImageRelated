function [dataBins,plotBins] = SmallPlusBounds(posAnchorIdeal,nArmBins)

%nArmBins = 5;

midPoint = abs(posAnchorIdeal(1,1));
armEnd = abs(posAnchorIdeal(6,1));
armWidth = midPoint*2;
armBins = linspace(midPoint,armEnd,nArmBins+1);

%{
theseTrials = trialbytrial(1).sessID==1;
ptsX = [trialbytrial(1).trialsX{theseTrials}];
ptsY = [trialbytrial(1).trialsY{theseTrials}];
figure; 
plot(ptsX,ptsY,'.')
plot(posAnchorIdeal(:,1),posAnchorIdeal(:,2),'.r')
hold on
plot(midPoint*ones(5,1),armBins,'.g')
%}

%extWidth = midPoint + armWidth;
extWidth = midPoint + armBins(2) - armBins(1);

%Mid
midBinX = [-midPoint -midPoint midPoint midPoint];
midBinY = [-midPoint midPoint midPoint -midPoint];

%Arm and Extended
armLongY = [midPoint extWidth*ones(1,nArmBins)];
armLongX = armBins; armLongX(end) = armLongX(end)+armWidth;
    plotLongX = armBins;
    plotLongY = midPoint*ones(1,nArmBins+1);

%East arm temp
armXtemp = [armLongX; armLongX]; armXtemp = armXtemp(:);
armYtemp = [armLongY; -armLongY]; armYtemp = armYtemp(:);
    plotXtemp = [plotLongX; plotLongX]; plotXtemp = plotXtemp(:);
    plotYtemp = [plotLongY; -plotLongY]; plotYtemp = plotYtemp(:);
%Center to end east arm
for abI = 1:nArmBins
    %Each row is the coordinates for that bin
    armBinTemplateX(abI,1:4) = [armXtemp([1:4]+2*(abI-1))];
    armBinTemplateY(abI,1:4) = [armYtemp([1:4]+2*(abI-1))];
        plotTemplateX(abI,1:4) = [plotXtemp([1 2 4 3]+2*(abI-1))];
        plotTemplateY(abI,1:4) = [plotYtemp([1 2 4 3]+2*(abI-1))];
end

%{
figure;
colorsP = {'r','g','b','m','y'};
for abI = 1:nArmBins
    %patch(armBinTemplateX(abI,1:4),armBinTemplateY(abI,1:4),colorsP{abI})
    patch(plotTemplateX(abI,1:4),plotTemplateY(abI,1:4),colorsP{abI})
end
%}

%East
eastArmX = armBinTemplateX;
eastArmY = armBinTemplateY;
    eastPlotX = plotTemplateX;
    eastPlotY = plotTemplateY;
[eastLabels(1:nArmBins,1)] = deal('e');

%West
westArmX = -armBinTemplateX;
westArmY = armBinTemplateY;
    westPlotX = -plotTemplateX;
    westPlotY = plotTemplateY;
[westLabels(1:nArmBins,1)] = deal('w');

%North
northArmX = armBinTemplateY; 
northArmY = armBinTemplateX;
    northPlotX = plotTemplateY;
    northPlotY = plotTemplateX;
[northLabels(1:nArmBins,1)] = deal('n');

%South
southArmX = armBinTemplateY;
southArmY = -armBinTemplateX;
    southPlotX = plotTemplateY;
    southPlotY = -plotTemplateX;
[southLabels(1:nArmBins,1)] = deal('s');

dataBins.X = [midBinX; eastArmX; westArmX; northArmX; southArmX];
dataBins.X(2:end,:) = dataBins.X(2:end,[1 2 4 3]);
dataBins.Y = [midBinY; eastArmY; westArmY; northArmY; southArmY];
dataBins.Y(2:end,:) = dataBins.Y(2:end,[1 2 4 3]);
dataBins.labels = ['m'; eastLabels(:); westLabels(:); northLabels(:); southLabels(:)];
plotBins.X = [midBinX; eastPlotX; westPlotX; northPlotX; southPlotX];
plotBins.Y = [midBinY; eastPlotY; westPlotY; northPlotY; southPlotY];
plotBins.labels = dataBins.labels;

end
