function PlotRasterMultiSess2(trialbytrial, thisCell, sessionInds,figHand,orientation,dates, plotPos, xlims)
%Works, could be redone to handle session by session
%Dates could be swapped in with anything, like reliability or selectivity
%Orientation is 'portrait' or 'landscape'

bH = 5;
plotLabels = {'Study Left','Study Right','Test Left','Test Right'};
plotColors = [1 0 0.65;... %magenta
              0 0.65 1;... %cyan
              1 0 0;... %red
              0 0 1];   %blue
posColor = [0.8 0.8 0.8];

xRange = ceil(max(xlims) - min(xlims));
xUL = ceil(max(xlims) + 3);

if isempty('orientation')
    if figHand.OuterPosition(4) >= figHand.OuterPosition(3)
        orientation = 'portrait';
    elseif figHand.OuterPosition(4) < figHand.OuterPosition(3)
        orientation = 'landscape';
    end
end

if isempty(dates)
    filenames = cellstr(num2str(unique(trialbytrial(1).sessID)));
end

for condType=1:4
    switch orientation
        case 'portrait'
            subHand(condType)=subplot(2,2,condType);
        case 'landscape'
            subHand(condType)=subplot(2,4,[0 4]+condType);
    end
    
    %Here is where we could trim out sessions with no firing
    %Would have to identify bad sess first, then get a height that is
    %cumulative good sess * bH and bad sess* bH/5 or 10 
    ylim([0 bH*length(trialbytrial(condType).trialsX)])
    
    %Here too we'd have to cut this down, like change the local bH to 1 or
    %0.5 or something
    badSess = find(sessionInds(thisCell,:)==0);
    if any(badSess)
         for bS = 1:length(badSess)
              sessLaps = trialbytrial(condType).sessID == badSess(bS);
              startB = find(sessLaps,1,'first');
              stopB =  find(sessLaps,1,'last');
              xc = [0 xRange xRange 0]; %xc = [0 35 35 0];
              yc = [startB-1 startB-1 stopB stopB]*bH;
              v = [xc; yc]';
              hold on
              patch('Faces',1:4,'Vertices',v,'FaceColor',[0.5 0.5 0.5],'EdgeColor',[0.5 0.5 0.5]);
         end
    end
    
    plotLine = 0;
    sessBreaks = find(diff(trialbytrial(condType).sessID));
    for thisLap = 1:length(trialbytrial(condType).trialsX)
        plotLine = plotLine + 1;
        
        if plotPos==1
            sessNum = trialbytrial(condType).sessID(thisLap);
            if sessionInds(thisCell,sessNum)~=0 %doesn't work if sessID isn't 1:1:numSess
            theseX = trialbytrial(condType).trialsX{thisLap,1};
            if any(theseX) %probably always good
            hold on
            for posp = 1:length(theseX)
                thisX = theseX(posp);
                %plot(60-[thisX thisX], [0 bH]+bH*(plotLine-1),'Color',posColor);
                plot(xUL-[thisX thisX], [0 bH]+bH*(plotLine-1),'Color',posColor);
            end
            end
            end
        end
        
        thesePoints = find(trialbytrial(condType).trialPSAbool{thisLap,1}(thisCell,:));
        
        hold on
        if any(thesePoints)
        for point = 1:length(thesePoints)
            plotX = trialbytrial(condType).trialsX{thisLap,1}(thesePoints(point));
            %plot(60-[plotX plotX], [0 bH]+bH*(plotLine-1),'Color',plotColors(condType,:),'LineWidth',1)
            plot(xUL-[plotX plotX], [0 bH]+bH*(plotLine-1),'Color',plotColors(condType,:),'LineWidth',1)
        end
        end
    end
    
    for ss=1:length(sessBreaks)
        hold on
        %plot([0 35], [sessBreaks(ss) sessBreaks(ss)]*bH,'k')
        plot([0 xRange], [sessBreaks(ss) sessBreaks(ss)]*bH,'k')
    end
    
    YTickPre = [];
    numSess = max(trialbytrial(condType).sessID);
    for sess = 1:numSess
        numLaps = sum(trialbytrial(condType).sessID == sess);
        YTickPre = [YTickPre 1:numLaps];
    end
    YTick = 1:length(YTickPre);
    YTickLabels = {YTickPre(rem(YTickPre,3)==0)};
    YTick = YTick(rem(YTickPre,3)==0);
    
    title(plotLabels{condType})
    
    subHand(condType).YTick = YTick*bH-bH/2;
    subHand(condType).YTickLabel = YTickLabels;
    ylabel('Lap number')
    xlabel('X position (cm)')
    %xlim([25 60])
    %xlim([0 35])
    xlim([0 xRange])
    %ylim([0 bH*plotLine])

    sesses = [find(diff(trialbytrial(condType).sessID)); length(trialbytrial(condType).sessID)];
    YTick2 = [0; sesses(1:end-1)] + ceil([ sesses(1); diff(sesses)]/2);
    
    yyaxis right
    ylim([0 bH*plotLine])
    subHand(condType).YTick = YTick2*bH-bH/2;
    subHand(condType).YTickLabel = dates;%{'160830'; '160831';'160901'}
    subHand(condType).YTickLabelRotation = 90;%ytickangle(90)
    subHand(condType).YColor = [0 0 0];
end

%{
figHand;
hold on
figDims = figHand.Position;
borderPos = [figDims(3)/2-70 figDims(4)-52, 176, 29];
%borderPos = [430,748,176,29];
labelBorder = uicontrol('Parent',figHand,'style','text','BackgroundColor',[0 0 0],...
    'Position',borderPos);%

labelBump = [3 2 -6 -4];
labelPos = borderPos+labelBump;
cellLabel = uicontrol('Parent',figHand,'style','text','String',...
    ['Cell #: ' cellnums],...
    'BackgroundColor',[1 1 1],'FontWeight','bold',...
    'Position',labelPos,'FontSize',12);%
%}

cellnums = num2str(sessionInds(thisCell,:));
spaces = [-2 strfind(cellnums,'  ')];
cellnums(spaces(find(diff(spaces)>1)+1))='/';
cellnums(strfind(cellnums,' '))=[];
cellnums(strfind(cellnums,' '))=[];

%suptitleSL(['Cell #: ' cellnums])
suptitleSL(['Cell #: ' num2str(thisCell)])

drawnow

%boneyard
%{
        if sum([1; sessBreaks+1] == plotLine)==1
            thisSess = trialbytrial(condType).sessID(thisLap);
            %if aboveThresh{condType}(thisCell,thisSess) == 0
            if sessionInds(thisCell,thisSess) == 0
                blockHeight = sum(trialbytrial(condType).sessID==thisSess);
                xc = [0 35 35 0]; 
                yc = [plotLine-1 plotLine-1 blockHeight blockHeight]*bH;% + [1 1 0 0]
                v = [xc; yc]';
                hold on
                patch('Faces',1:4,'Vertices',v,'FaceColor',[0.5 0.5 0.5],'EdgeColor',[0.5 0.5 0.5]);
            end
        end
        %}
end
