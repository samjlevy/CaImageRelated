function combinedPlot = PlotMultiSessDotField(x_adj_cm,y_adj_cm,epochs,PSAbool,sessionInds,thisCell,useLogical,allfiles)
%same as PlotRaster1 but works for multiple sessions
%thisCell = 119;
cmperbin = 1;
minspeed = 30;

plotLabels = {'Study Left','Study Right','Test Left','Test Right'};

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
    subHand(cond)=subplot(2,4,cond*2-1);
    plot(plotY,plotX, '.', 'Color', [0.5 0.5 0.5])
    hold on
    plot(spikeY, spikeX, '.', 'Color', [1 0 0])
    ylim([25 60])
    xlim([44 48])
    ylabel('Stem position (cm)')
    
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
    
    [OccMap,RunOccMap,xBin] = MakeOccMapLin(plotX,good,isrunning,xEdges);
    [TMap_unsmoothed,TCounts,TMap_gauss] = ...
            MakePlacefieldLin(logical(cellPSA),plotX,xEdges,RunOccMap,...
            'cmperbin',cmperbin,'smooth',true);
        
    %plot linplacefield
    subHand(cond)=subplot(2,4,cond*2);
    imagesc(flipud(TMap_gauss'))
    colormap(hot)
    %ylim([35.5 0.5])
    
end

%{
            for thisLap = 1:length(starts)
                %plotLine = plotLine + 1;
                spikePoints = [spikePoints,...
                    find(PSAbool{1,sess}(PSArow,starts(thisLap):stops(thisLap))) + starts(thisLap)-1];

                %hold on
                %if any(thesePoints)
                %for point = 1:length(thesePoints)
                %    plot(60-[x_adj_cm{1,sess}(thesePoints(point)) x_adj_cm{1,sess}(thesePoints(point))],...
                %        [0 bH]+bH*(plotLine-1),'Color',plotColors(cond,:))
                %end
                %end
            end
            
        %else
        %    plotLine = plotLine + length(starts);
        %    xcorn = [0 35 35 0]; ycorn = [oldBase oldBase plotLine plotLine]*bH;
        %    v = [xcorn; ycorn]';
        %    hold on
        %    patch('Faces',1:4,'Vertices',v,'FaceColor',[0.45 0.45 0.45],'EdgeColor',[0.45 0.45 0.45]);%,'FaceAlpha',0.3
        %end
        
        if sess < length(epochs)
            hold on
            plot([0 35], [plotLine*bH plotLine*bH],'k')
        end
        YTLadd = 2:2:length(starts);
        YTickLabels = [YTickLabels, YTLadd];
        Yblank = zeros(1,length(starts));
        Yblank(YTLadd) = 1;
        YTick = [YTick find(Yblank)+oldBase];
        YTick2 = [YTick2 oldBase+round(length(starts)/2)];
        %YTickLabels = [YTickLabels, 1:length(starts)];
    end

    title(plotLabels{cond})
    
    %subHand(cond).YTick = (1:plotLine)*bH-bH/2;
    subHand(cond).YTick = YTick*bH-bH/2;
    subHand(cond).YTickLabel = {YTickLabels}; %#ok<*AGROW>
    ylabel('Lap number')
    xlabel('X position (cm)')
    %xlim([25 60])
    xlim([0 35])
    ylim([0 bH*plotLine])

    yyaxis right
    ylim([0 bH*plotLine])
    subHand(cond).YTick = YTick2*bH-bH/2;
    subHand(cond).YTickLabel={'160830'; '160831';'160901'};
    ytickangle(90)
    subHand(cond).YColor = [0 0 0];
end
%}

borderPos = [430,748,176,29];
labelBorder = uicontrol('style','text','BackgroundColor',[0 0 0],...
    'Position',borderPos,'Parent',rastPlot);

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
    'Position',labelPos,'FontSize',12,'Parent',rastPlot);

drawnow
end
