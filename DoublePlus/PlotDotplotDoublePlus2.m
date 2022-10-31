function PlotDotplotDoublePlus2(trialbytrial,cellI,condPlot,dayI,coloring,aboveThreshBins,radiusLimit)%

%aboveThreshBins should be a cell array with just the bin vertices for bins that the pts are 
%above threshold
%coloring is the style, dynamic colors all pts, aboveThresh is dark red
%above thresh, faded red below

if isempty(radiusLimit)
radiusLimit = 1.5;
end

numConds = length(condPlot);
eachSpikeColor = []; ptsClose = cell(numConds,1); maxRate = [];

spikePosXagg = [];
spikePosYagg = [];
xHagg = [];
yHagg = [];
spikingHagg = [];
                
figure;
for condJ = 1:numel(condPlot)
    condI = condPlot(condJ);
    
    lapsH = trialbytrial(condI).sessID == dayI;
    
    xLaps = trialbytrial(condI).trialsX(lapsH);
    yLaps = trialbytrial(condI).trialsY(lapsH);
    
    xH{condJ} = [trialbytrial(condI).trialsX{lapsH}];
    yH{condJ} = [trialbytrial(condI).trialsY{lapsH}];
    spikingH{condJ} = [trialbytrial(condI).trialPSAbool{lapsH}];
    spikingH{condJ} = spikingH{condJ}(cellI,:);
    spikePosX{condJ} = xH{condJ}(spikingH{condJ});
    spikePosY{condJ} = yH{condJ}(spikingH{condJ});
            
    for trialI = 1:length(xLaps)
        plot(xLaps{trialI},yLaps{trialI},'k'); hold on
    end
  
    if sum(spikingH{condJ}) > 0
    switch coloring
        case 'dynamic'
            spikePosXagg = [spikePosXagg; spikePosX{condJ}(:)];
            spikePosYagg = [spikePosYagg; spikePosY{condJ}(:)];
            xHagg = [xHagg; xH{condJ}(:)];
            yHagg = [yHagg; yH{condJ}(:)];
            spikingHagg = [spikingHagg; spikingH{condJ}(:)];
            %[eachSpikeColor{condJ},ptsClose{condJ},maxRate(condJ)] = DynamicColorMap(...
            %    spikePosX{condJ},spikePosY{condJ},xH{condJ},yH{condJ},spikingH{condJ},radiusLimit,[]);
        case 'aboveThresh'
            plot(spikePosX{condJ},spikePosY{condJ},'.','MarkerEdgeColor',[0.7000    0.3118    0.1608])
            nBins = size(aboveThreshBins.X{condJ},1);
            for binI = 1:nBins
                [in,on] = inpolygon(spikePosX{condJ},spikePosY{condJ},aboveThreshBins.X{condJ}(binI,:),aboveThreshBins.Y{condJ}(binI,:));
                binIn = in | on;
                plot(spikePosX{condJ}(binIn),spikePosY{condJ}(binIn),'.','MarkerEdgeColor',[1.0000    0    0])
            end
        case 'classicRed'
            plot(spikePosX{condJ},spikePosY{condJ},'.','MarkerEdgeColor','r')
        otherwise 
            disp('not a coloring option')
    end
    
    end
 
end
maxClose = max(maxRate);

if strcmpi(coloring,'dynamic')
    [eachSpikeColor,ptsClose,maxRate] = DynamicColorMap(...
                spikePosXagg,spikePosYagg,xHagg,yHagg,spikingHagg,radiusLimit,[]);
    [~,rateIndexOrder] = sort(ptsClose,'ascend');
    reorderedX = spikePosXagg(rateIndexOrder);
    reorderedY = spikePosYagg(rateIndexOrder);
    reorderedColors = eachSpikeColor(rateIndexOrder,:);
    for ptI = 1:length(spikePosXagg)
        plot(reorderedX(ptI),reorderedY(ptI),'.','Color',reorderedColors(ptI,:),'MarkerSize',9)
    end
end
        %{
for condJ = 1:length(condPlot)
    if strcmpi(coloring,'dynamic')
    if sum(spikingH{condJ}) > 0
        eachSpikeColor{condJ} = rateColorMap(ptsClose{condJ},'jet',[0 maxClose]);
        [~,rateIndexOrder] = sort(ptsClose{condJ},'ascend');
        reorderedX = spikePosX{condJ}(rateIndexOrder);
        reorderedY = spikePosY{condJ}(rateIndexOrder);
        reorderedColors = eachSpikeColor{condJ}(rateIndexOrder,:);
        for ptI = 1:length(spikePosX{condJ})
            plot(reorderedX(ptI),reorderedY(ptI),'.','Color',reorderedColors(ptI,:),'MarkerSize',9)
        end
    end
    end
end
   %}
end