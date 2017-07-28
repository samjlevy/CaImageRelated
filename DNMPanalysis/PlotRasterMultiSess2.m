function PlotRasterMultiSess2(trialbytrial, thisCell, sessionInds,figHand)
%Works, could be redone to handle session by session

bH = 5;
plotLabels = {'Study Left','Study Right','Test Left','Test Right'};
plotColors = [1 0 0.65;... %magenta
              0 0.65 1;... %cyan
              1 0 0;... %red
              0 0 1];   %blue

%rastPlot = figure('name','Raster Plot','Position',[100 50 1000 800]);

for condType=1:4
    subHand(condType)=subplot(2,2,condType);
    
    plotLine = 0;
    sessBreaks = find(diff(trialbytrial(condType).sessID));
    for thisLap = 1:length(trialbytrial(condType).trialsX)
        plotLine = plotLine + 1;
        
        if sum([1; sessBreaks+1] == plotLine)==1
            thisSess = trialbytrial(condType).sessID(thisLap);
            %if aboveThresh{condType}(thisCell,thisSess) == 0
            if sessionInds(thisCell,thisSess) == 0
                blockHeight = sum(trialbytrial(condType).sessID==thisSess);
                xc = [0 35 35 0]; 
                yc = [plotLine-1 plotLine-1 blockHeight blockHeight]*bH;% + [1 1 0 0]
                v = [xc; yc]';
                hold on
                patch('Faces',1:4,'Vertices',v,'FaceColor',[0.45 0.45 0.45],'EdgeColor',[0.45 0.45 0.45]);
            end
        end
                
        thesePoints = find(trialbytrial(condType).trialPSAbool{thisLap,1}(thisCell,:));
        
        hold on
        if any(thesePoints)
        for point = 1:length(thesePoints)
            plotX = trialbytrial(condType).trialsX{thisLap,1}(thesePoints(point));
            plot(60-[plotX plotX], [0 bH]+bH*(plotLine-1),'Color',plotColors(condType,:))
        end
        end
        
        %if sum(sessBreaks==plotLine)==1
            %hold on
            %plot([0 35], [plotLine*bH plotLine*bH],'k')
        %end
    end
    
    for ss=1:length(sessBreaks)
        hold on
        plot([0 35], [sessBreaks(ss) sessBreaks(ss)]*bH,'k')
    end
    
    YTickPre = [];
    numSess = max(trialbytrial(condType).sessID);
    for sess = 1:numSess
        numLaps = sum(trialbytrial(condType).sessID == sess);
        YTickPre = [YTickPre 1:numLaps];
    end
    YTick = 1:length(YTickPre);
    YTickLabels = {YTickPre(rem(YTickPre,2)==0)};
    YTick = YTick(rem(YTickPre,2)==0);
    
    title(plotLabels{condType})
    
    subHand(condType).YTick = YTick*bH-bH/2;
    subHand(condType).YTickLabel = YTickLabels;
    ylabel('Lap number')
    xlabel('X position (cm)')
    %xlim([25 60])
    xlim([0 35])
    ylim([0 bH*plotLine])

    %yyaxis right
    %ylim([0 bH*plotLine])
    %subHand(cond).YTick = YTick2*bH-bH/2;
    %subHand(cond).YTickLabel={'160830'; '160831';'160901'};
    %ytickangle(90)
    %subHand(cond).YColor = [0 0 0];
end

end
