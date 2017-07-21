function combinedPlot = PlotMultiSessDotField(x_adj_cm,y_adj_cm,epochs,PSAbool,sessionInds,thisCell,useLogical,allfiles)
%same as PlotRaster1 but works for multiple sessions
%thisCell = 119;
cmperbin = 1;
minspeed = 30;

plotLabels = {'Study Left','Study Right','Test Left','Test Right'};
dotPlots = [3 4 7 8];
heatPlots = [1 2 5 6];


[~,~,~, pooled{1}] =...
    GetBlockDNMPbehavior( fullfile(allfiles{1},'Bellatrix_160830DNMPsheet_BrainTime_Adjusted.xlsx'), 'stem_only', length(x_adj_cm{1,1}));
[~,~,~, pooled{2}] =...
    GetBlockDNMPbehavior( fullfile(allfiles{2},'Bellatrix_160831DNMPsheet_BrainTime_Adjusted.xlsx'), 'stem_only', length(x_adj_cm{1,2}));
[~,~,~, pooled{3}] =...
    GetBlockDNMPbehavior( fullfile(allfiles{3},'Bellatrix_160901DNMPsheet_BrainTime_Adjusted.xlsx'), 'stem_only', length(x_adj_cm{1,3}));
for pp = 1:3
    allInc{1,pp} = pooled{1,pp}.include.forced & pooled{1,pp}.include.left; %studyLeft
    allInc{2,pp} = pooled{1,pp}.include.forced & pooled{1,pp}.include.right; %studyRight
    allInc{3,pp} = pooled{1,pp}.include.free & pooled{1,pp}.include.left;%testLeft
    allInc{4,pp} = pooled{1,pp}.include.free & pooled{1,pp}.include.right; %testRight
end

%bH = 5;


%plotColors = [1 0 0.65;... %magenta
%              0 0.65 1;... %cyan
%              1 0 0;... %red
%              0 0 1];   %blue
              

combinedPlot = figure('name','Raster Plot','Position',[100 50 1000 800]);

numSessions = length(epochs);
for cond=1:4
    %plotLine = 0;
    %YTickLabels = [];
    %YTick = [];
    %YTick2 = [];
    
    %Get data
    plotX = [];
    plotY = [];
    spikeX = [];
    spikeY = [];
    cellPSA = [];
    for sess = 1:numSessions           
        %oldBase = plotLine;
        %starts = epochs(sess).epochs(cond).starts;
        %stops = epochs(sess).epochs(cond).stops;
        
        PSArow = sessionInds(thisCell,sess);
        if PSArow ~= 0
            if useLogical{1,sess}(PSArow)==1
                hereTime = allInc{cond,sess};
                plotX = [plotX x_adj_cm{1,sess}(hereTime)];
                plotY = [plotY y_adj_cm{1,sess}(hereTime)];
                spikeX = [spikeX x_adj_cm{1,sess}(hereTime & PSAbool{1,sess}(PSArow,:))];
                spikeY = [spikeY y_adj_cm{1,sess}(hereTime & PSAbool{1,sess}(PSArow,:))];
                
                cellPSA = [cellPSA  PSAbool{1,sess}(PSArow,allInc{cond,sess})];
            end
        end
    end
    
    %plot dotplot
    subHand(dotPlots(cond))=subplot(4,2,dotPlots(cond));
    plot(60-plotX,plotY, '.', 'Color', [0.5 0.5 0.5],'MarkerSize',7)
    hold on
    plot(60-spikeX, spikeY, '.', 'Color', [1 0 0],'MarkerSize',10)
    %xlim([25 60])
    xlim([0 35])
    ylim([44 48])
    xlabel('Stem position (cm)')
    
    %make linPlace Field
    xmin = 25;
    xmax = 60;
    Xrange = xmax-xmin; 
    nXBins = ceil(Xrange/cmperbin); 
    xEdges = (0:nXBins)*cmperbin+xmin;
    
    nFrames = length(plotX);
    SR=20;
    dx = diff(plotX);
    dy = diff(plotY);
    speed = hypot(dx,dy)*SR;
    velocity = convtrim(speed,ones(1,2*20))./(2*20);
    good = true(1,nFrames);
    isrunning = good;                                   %Running frames that were not excluded. 
    isrunning(velocity < minspeed) = false;
    
    [OccMap{cond},RunOccMap{cond},xBin{cond}] = MakeOccMapLin(plotX,good,isrunning,xEdges);
    [TMap_unsmoothed{cond},TCounts{cond},TMap_gauss{cond}] = ...
            MakePlacefieldLin(logical(cellPSA),plotX,xEdges,RunOccMap{cond},...
            'cmperbin',cmperbin,'smooth',true);
end

%scale TMAPs
maxRate = max([TMap_gauss{:}]);
scaledTmaps = cellfun(@(x) x/maxRate,TMap_gauss,'UniformOutput',false);



for condA = 1:4
    %plot linplacefield
    subHand(heatPlots(condA))=subplot(4,2,heatPlots(condA));
    imagesc(fliplr(scaledTmaps{condA})) %fliplr?
    xlim([0.5 35.5])
    caxis([0 1])
    colormap(hot)
    title(plotLabels{condA})
    %ylim([35.5 0.5])
end


borderPos = [430,748,176,29];
labelBorder = uicontrol('style','text','BackgroundColor',[0 0 0],...
    'Position',borderPos,'Parent',combinedPlot);

labelBump = [3 2 -6 -4];
labelPos = borderPos+labelBump;

cellnums = num2str(sessionInds(thisCell,:));
spaceLocs = strfind(cellnums,' ');
cellnums([spaceLocs(1) spaceLocs(find(diff(spaceLocs)>1)+1)])='/';
cellnums(strfind(cellnums,' '))=[];
cellnums(strfind(cellnums,' '))=[];

cellLabel = uicontrol('style','text','String',...
    ['Cell #: ' cellnums],...
    'BackgroundColor',[1 1 1],'FontWeight','bold',...
    'Position',labelPos,'FontSize',12,'Parent',combinedPlot);

drawnow
end
