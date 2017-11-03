c = uisetcolor
%% Selectivity Histograms
load('trialbytrial.mat')
[LRsel, STsel] = LRSTselectivity(trialbytrial);
numDays = size(LRsel.spikes,2);

onebarColorST = [0.3020    0.7490    0.9294];
allbarColorST = [0    0.4510    0.7412];
onebarColorLR = [ 1.0000    0.3020    0.8000];
allbarColorLR = [0.7020    0.1804    0.4000];

binSize = 0.1;
bins = -1:binSize:1;
figure;
for dayI = 1:numDays
    %hold on
    lrtheseSel = LRsel.spikes(:,dayI);
    lrCounts(dayI,:) = histcounts(lrtheseSel(~isnan(lrtheseSel)),bins);
    sttheseSel = STsel.spikes(:,dayI);
    stCounts(dayI,:) = histcounts(sttheseSel(~isnan(sttheseSel)),bins);
    %hold on
    %histogram(theseSel(~isnan(lrtheseSel)),bins,'FaceAlpha',0.4)
end

lrMeans = mean(lrCounts,1);
%lrNumCells = sum(lrCounts,2);
lrNumCells = repmat(sum(lrCounts,2),1,length(bins)-1);
lrProportion = lrCounts./lrNumCells;
lrPropMeans = mean(lrProportion,1);
lrSEMs = std(lrCounts,1)./sqrt(numDays);

stMeans = mean(stCounts,1);
stNumCells = repmat(sum(stCounts,2),1,length(bins)-1);
stProportion = stCounts./stNumCells;
stPropMeans = mean(stProportion,1);
stSEMs = std(stProportion,1)./sqrt(numDays);

figure;
bar(bins(1:end-1)+binSize/2,stProportion(1,:),1,'FaceColor',onebarColorST)
title('Day 1 Study/Test Selectivity')
ylabel('Proportion'); set(gca,'xticklabel',{[]}) 

figure; 
bar(bins(1:end-1)+binSize/2,stPropMeans,1,'FaceColor',allbarColorST)
title('All days mean Study/Test Selectivity')
ylabel('Proportion'); set(gca,'xticklabel',{[]}) 
hold on
for bI = 1:length(bins)-1
plot([bins(bI) bins(bI)]+binSize/2,[stPropMeans(bI)-stSEMs(bI) stPropMeans(bI)+stSEMs(bI)],'k','LineWidth',2)
end


figure;
bar(bins(1:end-1)+binSize/2,lrProportion(1,:),1,'FaceColor',onebarColorLR)
title('Day 1 Left/Right Selectivity')
ylabel('Proportion'); set(gca,'xticklabel',{[]}) 

figure; 
bar(bins(1:end-1)+binSize/2,lrPropMeans,1,'FaceColor',allbarColorLR)
title('All days mean Left/Right Selectivity')
ylabel('Proportion'); set(gca,'xticklabel',{[]}) 
hold on
for bI = 1:length(bins)-1
plot([bins(bI) bins(bI)]+binSize/2,[lrPropMeans(bI)-stSEMs(bI) lrPropMeans(bI)+stSEMs(bI)],'k','LineWidth',2)
end

%% Staying in region (edge, quadrant, 16-ant)
load('trialbytrial.mat')
[LRsel, STsel] = LRSTselectivity(trialbytrial);
numDays = size(LRsel.spikes,2);
numCells = size(LRsel.spikes,1);

%Change sign
LRabsSel = LRsel.spikes./abs(LRsel.spikes);
STabsSel = STsel.spikes./abs(STsel.spikes);
LRposHits = sum(LRabsSel>0,2);
LRnegHits = sum(LRabsSel<0,2);
STposHits = sum(STabsSel>0,2);
STnegHits = sum(STabsSel<0,2);

LRboth = [LRposHits, LRnegHits];
LRchanged = sum(LRboth>0,2) == 2;
LRchangeSignAtAll = sum(LRchanged) / sum(sum(LRboth,2)>0);

STboth = [STposHits, STnegHits];
STchanged = sum(STboth>0,2) == 2;
STchangeSignAtAll = sum(sum(STboth>0,2) == 2) / sum(sum(STboth,2)>0);

bothChanged = [STchanged LRchanged];

actuallyBothChanged = sum(bothChanged,2)==2;

STnotLRchanged = STchanged; STnotLRchanged(actuallyBothChanged)=0;
LRnotSTchanged = LRchanged; LRnotSTchanged(actuallyBothChanged)=0;

sum(double(actuallyBothChanged)+STnotLRchanged+LRnotSTchanged)
totalSelective = sum(sum(bothChanged,2)>0)


pf = figure; axes(pf);
props = [sum(actuallyBothChanged) sum(STnotLRchanged) sum(LRcounts>0)-totalSelective sum(LRnotSTchanged)];
labels = {'L/R and S/T','S/T only','Never changed','L/R only'};
labels = num2cell(round((props/sum(props))*100));
labels = cellfun(@(x) strcat(num2str(x),'%'),labels,'UniformOutput',false);
pie(pf.Children,props,labels)
%ST blue, LR red, Both purple, other green (white?)
title({'Breakdown of cells that changed sign on a dimension';'Blue ST, Red LR, Purp both'})

pieColors = [ 0.7020    0.1804    0.4000;... %purple
         0.3020    0.7490    0.9294; %Blue...
    1 1 1;... %White
    1 0.302 0.302]; %RED
     %0.4660    0.6740    0.1880;...%Green
    
colormap(pieColors)

for aa = 1:length(props)
    oldPos = pf.Children.Children(aa*2-1).Position(1:2);
    newPos = (oldPos./abs(oldPos))*0.5;
    pf.Children.Children(aa*2-1).Position = newPos; 
    pf.Children.Children(aa*2-1).FontSize = 16;
end








LRcounts = sum(~isnan(LRsel.spikes),2);
LRminusOne = LRsel.spikes==-1;
LRplusOne = LRsel.spikes==1;
LRalwaysMinusOne = (sum(LRminusOne,2)./LRcounts) ==1;
LRalwaysPlusOne = (sum(LRplusOne,2)./LRcounts) ==1;

STcounts = sum(~isnan(STsel.spikes),2);
STminusOne = STsel.spikes==-1;
STplusOne = STsel.spikes==1;
STalwaysMinusOne = (sum(STminusOne,2)./STcounts) ==1;
STalwaysPlusOne = (sum(STplusOne,2)./STcounts) ==1;

STalwaysCompletelySelectiveRate = sum(STalwaysMinusOne + STalwaysPlusOne) / sum(STcounts>0);
LRalwaysCompletelySelectiveRate = sum(LRalwaysMinusOne + LRalwaysPlusOne) / sum(LRcounts>0);


alwaysBoth = [(STalwaysMinusOne | STalwaysPlusOne)  (LRalwaysMinusOne + LRalwaysPlusOne)];
alwaysBothRate = sum(sum(alwaysBoth,2)==2) / sum(sum(alwaysBoth,2)>0);

actuallyAlwaysBoth = sum(alwaysBoth,2)==2;
STnotLR = alwaysBoth(:,1); STnotLR(actuallyAlwaysBoth) = 0;
LRnotST = alwaysBoth(:,2); LRnotST(logical(actuallyAlwaysBoth)) = 0;

sum(double(actuallyAlwaysBoth)+STnotLR+LRnotST)
totalSelective = sum(sum(alwaysBoth,2)>0)

pf = figure; axes(pf);
props = [sum(actuallyAlwaysBoth) sum(STnotLR) sum(LRcounts>0)-totalSelective sum(LRnotST) ];
labels = {'L/R and S/T','S/T only','Not always selective','L/R only'};
labels = num2cell(round((props/sum(props))*100));
labels = cellfun(@(x) strcat(num2str(x),'%'),labels,'UniformOutput',false);
pie(pf.Children,props,labels)
%ST blue, LR red, Both purple, other green (white?)
title({'Breakdown of cells with complete selectivity';'Blue ST, Red LR, Purp both'})

pieColors = [ 0.7020    0.1804    0.4000;... %purple
         0.3020    0.7490    0.9294; %Blue...
    1 1 1;... %White
    1 0.302 0.302]; %RED
     %0.4660    0.6740    0.1880;...%Green
    
colormap(pieColors)

for aa = 1:length(props)
    oldPos = pf.Children.Children(aa*2-1).Position(1:2);
    newPos = (oldPos./abs(oldPos))*0.5;
    pf.Children.Children(aa*2-1).Position = newPos; 
    pf.Children.Children(aa*2-1).FontSize = 16;
end


%% Path lengths
load('trialbytrial.mat')
[LRsel, STsel] = LRSTselectivity(trialbytrial);
numDays = size(LRsel.spikes,2);
numCells = size(LRsel.spikes,1);

lapPctThresh = 0.25;
consecLapThresh = 3;
[dayAllUse, threshAndConsec] = GetUseCells(trialbytrial, lapPctThresh, consecLapThresh);

pathLengths = zeros(numCells,numDays-1);
daysFired = zeros(numCells,1);
for cellI = 1:numCells
    %daysActive = ~isnan(LRsel.spikes(cellI,:));
    daysActive = find(dayAllUse(cellI,:));%threshold for cells firing enough
    %daysActive2 = sum(~isnan(STsel.spikes),2);
    if length(daysActive) > 1
    for dayI = 1:length(daysActive)-1
        days = [daysActive(dayI) daysActive(dayI+1)];
        pathLengths(cellI,dayI) = sqrt(...
            (LRsel.spikes(cellI,days(1)) - LRsel.spikes(cellI,days(2)))^2 +...
            (STsel.spikes(cellI,days(1)) - STsel.spikes(cellI,days(2)))^2);
    end
    end
    daysFired(cellI) = length(daysActive);
end

totalLength = sum(pathLengths,2);
averageStep = sum(pathLengths,2)./daysFired;

figure; h=histogram(averageStep(daysFired>1),20); title('All Cells'); xlabel('Average Selectivity Change')

alwaysOne = (STalwaysMinusOne + STalwaysPlusOne + LRalwaysMinusOne + LRalwaysPlusOne) > 0;

averageStep(isnan(averageStep)) = 0;
actuallyActive = daysFired>1;
otherColor = [0.3020    0.7490    0.9294];
allColor = [0    0.35    0.56];
figure; histogram(averageStep(alwaysOne & actuallyActive),h.BinEdges,'FaceColor',otherColor); 
title('Other Cells'); xlabel('Average Selectivity Change')
figure; histogram(averageStep(~alwaysOne & actuallyActive),h.BinEdges,'FaceColor',allColor); 
title('Cells Always Completely Selective'); xlabel('Average Selectivity Change')

%% Convex hull area of points

load('trialbytrial.mat')
[LRsel, STsel] = LRSTselectivity(trialbytrial);
numDays = size(LRsel.spikes,2);
numCells = size(LRsel.spikes,1);

lapPctThresh = 0.25;
consecLapThresh = 3;
[dayAllUse, threshAndConsec] = GetUseCells(trialbytrial, lapPctThresh, consecLapThresh);

daysActive = sum(~isnan(LRsel.spikes),2)>1;


vi = convhull(x1,y1);
polyarea(x1(vi),y1(vi))

 plot(x1,y1,'.')
 axis equal
 hold on
 fill ( x1(vi), y1(vi), 'r','facealpha', 0.5 ); 
 hold off

