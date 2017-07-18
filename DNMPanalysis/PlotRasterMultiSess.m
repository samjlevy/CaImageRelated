function rastPlot = PlotRasterMultiSess(x_adj_cm,epochs,PSAbool,sessionInds,thisCell)
%same as PlotRaster1 but works for multiple sessions
%thisCell = 119;
bH = 5;

plotLabels = {'Study Left','Study Right','Test Left','Test Right'};
plotColors = [1 0 0.65;... %magenta
              0 0.65 1;... %cyan
              1 0 0;... %red
              0 0 1];   %blue
              

rastPlot = figure('name','Raster Plot','Position',[100 50 1000 800]);

for cond=1:4
    subHand(cond)=subplot(2,2,cond);
    plotLine = 0;
    
    YTickLabels = [];
    YTick = [];
    YTick2 = [];
    for sess = 1:length(epochs)
        oldBase = plotLine;
        starts = epochs(sess).epochs(cond).starts;
        stops = epochs(sess).epochs(cond).stops;
        PSArow = sessionInds(thisCell,sess);
        if PSArow ~= 0            
            for thisLap = 1:length(starts)
                plotLine = plotLine + 1;
                thesePoints =...
                    find(PSAbool{1,sess}(PSArow,starts(thisLap):stops(thisLap))) + starts(thisLap)-1;

                hold on
                if any(thesePoints)
                for point = 1:length(thesePoints)
                    plot(60-[x_adj_cm{1,sess}(thesePoints(point)) x_adj_cm{1,sess}(thesePoints(point))],...
                        [0 bH]+bH*(plotLine-1),'Color',plotColors(cond,:))
                end
                end
            end
        else
            plotLine = plotLine + length(starts);
            xcorn = [0 35 35 0]; ycorn = [oldBase oldBase plotLine plotLine]*bH;
            v = [xcorn; ycorn]';
            hold on
            patch('Faces',1:4,'Vertices',v,'FaceColor',[0.45 0.45 0.45],'EdgeColor',[0.45 0.45 0.45]);%,'FaceAlpha',0.3
        end
        
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

borderPos = [430,748,176,29];
labelBorder = uicontrol('style','text','BackgroundColor',[0 0 0],...
    'Position',borderPos,'Parent',rastPlot);

labelBump = [3 2 -6 -4];
labelPos = borderPos+labelBump;

cellnums = num2str(sessionInds(thisCell,:));
cellnums(strfind(cellnums,'  '))='/';
cellnums(strfind(cellnums,' '))=[];

cellLabel = uicontrol('style','text','String',...
    ['Cell #: ' cellnums],...
    'BackgroundColor',[1 1 1],'FontWeight','bold',...
    'Position',labelPos,'FontSize',12,'Parent',rastPlot);

drawnow
end
