function PreProcessLEDtracking

testDir = 'G:\DoublePlus\Marble11_180721';
if ~isempty(strfind(version,'R2016a'))
    disp('Sorry, 2016a not going to work; use 2016b')
    return
end

xAVI = zeros(nFrames,1);
yAVI = zeros(nFrames,1);
mcfScaleFactor = 1;
mcfOriginalSize = [680 558 560 420];
DVTtoAVIscale = 0.6246;
definitelyGood = false(nFrames,1);
load('PosLED_temp.mat')

%{
doneDVTs = 0; dd = 1;
while doneDVTs == 0
    [DVTfile, DVTpath] = uigetfile('*.DVT', 'Select DVT file');
    filepath = fullfile(DVTpath, DVTfile);

    pos_data{dd} = importdata(filepath);
    
    ss = input('Done loading DVTs? (y/n) >> ','s');
    if strcmpi(ss,'y')
        doneDVTs = 1;
    else
        dd = dd+1;
    end

    dvtPos{dd}.redX = pos_data{dd}(:,5)*DVTtoAVIscale;
    dvtPos{dd}.redY = pos_data{dd}(:,6)*DVTtoAVIscale;
    dvtPos{dd}.redY = frameSize(1) - dvtPos{dd}.redY;
    dvtPos{dd}.greenX = pos_data{dd}(:,3)*DVTtoAVIscale;
    dvtPos{dd}.greenY = pos_data{dd}(:,4)*DVTtoAVIscale;
    dvtPos{dd}.greenY = frameSize(1) - dvtPos{dd}.greenY;

    dvtPos{dd}.redX( dvtPos{dd}.redX==0 & dvtPos{dd}.redY==0 ) = NaN;
    dvtPos{dd}.redY( dvtPos{dd}.redX==0 & dvtPos{dd}.redY==0 ) = NaN;
end
%}


        
avi_filepath = ls('*.avi');
if size(avi_filepath,1)~=1
    [avi_filepath,~] = uigetfile('*.avi','Choose appropriate video:');
end
disp(['Using ' avi_filepath ])
obj = VideoReader(avi_filepath);
aviSR = obj.FrameRate;
nFrames = obj.Duration*aviSR;  
frameSize = [obj.Height obj.Width];

%[v0] = AdjustWithBackgroundImage(avi_filepath, obj, []);

v0r = double(v0(:,:,1) - v0(:,:,3));
v0g = double(v0(:,:,2));  

%Find the onmaze area
bb = figure; imagesc(v0); title('Draw onMaze boundary')

[onMazeMask,onMazeX,onMazeY] = roipoly;

close(bb);

v0g = v0g.*onMazeMask;
v0r = v0r.*onMazeMask;

nBrightPoints = 5;
load('C:\Users\Sam\Documents\GitHub\CaImageRelated\DoublePlus\ledtrackteststuff.mat')
load calstuff.mat
%{
%Get frames with mouse on the maze, ideally throughout the session
nTestFrames = 8;
tfEdges = linspace(1,nFrames,nTestFrames+1);
%Look at the brightness value for red and green leds
for tfI = 1:nTestFrames
    %Get the random frame
    mouseInFrame = 0;
    while mouseInFrame == 0
        rFrameNum = randi(round(tfEdges(tfI+1) - (tfEdges(tfI)-1))) + tfEdges(tfI);
        obj.CurrentTime = (rFrameNum-1)/aviSR;
        uFrame = readFrame(obj);
        gg = figure; imagesc(uFrame)
        ss = input('Is the mouse somewhere good in this frame? (y/n) >>','s')
        if strcmpi(ss,'y')
            mouseInFrame=1;
        end
        close(gg);
    end
    gg = figure; imagesc(uFrame)
    
    [rfRsub, rfGsub] =  GetSelfSubFrame(uFrame, v0r, v0g, onMazeMask);
    
    [allIndR,redX,redY] = GetBrightBlobPixels(rfRsub,nBrightPoints);
    [allIndG,greenX,greenY] = GetBrightBlobPixels(rfGsub,nBrightPoints);
    
    %Check it's ok, if not do it manually
    [Rrind,Rcind] = ind2sub(frameSize,allIndR);
    redGood = 0;
    while redGood==0
        redF = figure; imagesc(uFrame); title(['Red Frame number ' num2str(rFrameNum)]); hold on
        plot(Rcind,Rrind,'og'); plot(Rcind,Rrind,'.g')
        sss = input('is this good?','s');
        if strcmpi(sss,'y')
            redGood = 1;
        elseif strcmpi(sss,'n')
            doneZoom = input('type Y when done zooming in for manual at pixel level','s');
            for pnR = 1:nBrightPoints
                [xx,yy] = ginput(1);
                Rcind(pnR) = round(xx); Rrind(pnR) = round(yy);
                plot(Rcind(pnR),Rrind(pnR),'og');plot(Rcind(pnR),Rrind(pnR),'.g')
            end
        end
        close(redF);
    end      
    
    greenGood = 0;
    [Grind,Gcind] = ind2sub(frameSize,allIndG);
    while greenGood==0
        greenF = figure; imagesc(uFrame); title(['Green Frame number ' num2str(rFrameNum)]); hold on
        plot(Gcind,Grind,'or'); plot(Gcind,Grind,'.r')
        sss = input('is this good?','s');
        if strcmpi(sss,'y')
            greenGood = 1;
        elseif strcmpi(sss,'n')
            doneZoom = input('type Y when done zooming in for manual at pixel level','s');
            for pnG = 1:nBrightPoints
                [xx,yy] = ginput(1);
                Gcind(pnG) = round(xx); Grind(pnG) = round(yy);
                plot(Gcind(pnG),Rrind(pnG),'or');plot(Gcind(pnG),Grind(pnG),'.r')
            end
        end
        close(greenF);
    end             
    
    close(gg);
    
    Rbrightness{tfI,1} = rfRsub(allIndR); 
    Gbrightness{tfI,1} = rfGsub(allIndG); 
    
    calibrateFrames(tfI,1) = rFrameNum;
    
    for uh = 1:length(Rrind)
        howRed{tfI,1}(uh,1) = double(uFrame(Rrind(uh),Rcind(uh),1));
        howGreen{tfI,1}(uh,1) = double(uFrame(Grind(uh),Gcind(uh),2));
    end
end
%}
rMeans = cell2mat(cellfun(@mean,howRed,'UniformOutput',false));
gMeans = cell2mat(cellfun(@mean,howGreen,'UniformOutput',false));

howRedThresh =  mean(rMeans) - 1.5*std(rMeans); %Use in raw frame
howGreenThresh = mean(gMeans) - 2*std(gMeans); %Use in raw frame


%save calstuff.mat calibrateFrames Rbrightness Gbrightness howRed howGreen

%Check brightness calibration

subMultRedX = nan(nFrames,1);
subMultRedY = nan(nFrames,1);
subMultGreenX = nan(nFrames,1);
subMultGreenY = nan(nFrames,1);
nRed = nan(nFrames,1);
nGreen = nan(nFrames,1);
redPix = cell(nFrames,1);
greenPix = cell(nFrames,1);

mcfCurrentSize = mcfOriginalSize;
mcfCurrentSize(3:4) = mcfCurrentSize(3:4)*mcfScaleFactor;
manCorrFig = figure('Position',mcfOriginalSize);
imagesc(v0)
rawColorThresh = 1;
%p = ProgressBar(nFrames);
for corrFrame = 1:nFrames
%for corrFrame = 2610:2700
    %Get the frame to correct
    obj.CurrentTime = (corrFrame-1)/aviSR;
    uFrame = readFrame(obj);
    
    %Do some friendly UI stuff
    
    imagesc(manCorrFig.Children,uFrame);
    title(['Frame# ' num2str(corrFrame)])
    
    boundaryX = onMazeX; boundaryX = [boundaryX; boundaryX(1)];
    boundaryY = onMazeY; boundaryY = [boundaryY; boundaryY(1)];
    hold(manCorrFig.Children,'on')
    plot(manCorrFig.Children,boundaryX,boundaryY,'r','LineWidth',1.5)
    hold(manCorrFig.Children,'off')
    
    %Do our image subtract and mult
    [rfRsub, rfGsub] =  GetSelfSubFrame(uFrame, v0r, v0g, onMazeMask);
    
    %Threshold frames by how much the right color
    if rawColorThresh == 1
        ufRthreshed = uFrame(:,:,1) > howRedThresh;
        ufGthreshed = uFrame(:,:,2) > howGreenThresh;

        rfRsub = rfRsub.*ufRthreshed;
        rfGsub = rfGsub.*ufGthreshed;
    end
    
    %Find the red and green LEDs
    [allIndR,redX,redY] = GetBrightBlobPixels(rfRsub,nBrightPoints);
    [allIndG,greenX,greenY] = GetBrightBlobPixels(rfGsub,nBrightPoints);
    
    hold(manCorrFig.Children,'on')
    plot(manCorrFig.Children,redX,redY,'or')
    plot(manCorrFig.Children,greenX,greenY,'og')
    hold(manCorrFig.Children,'off') 
    
    subMultRedX(corrFrame) = redX;
    subMultRedY(corrFrame) = redY;
    subMultGreenX(corrFrame) = greenX;
    subMultGreenY(corrFrame) = greenY;
    nRed(corrFrame) = length(allIndR);
    nGreen(corrFrame) = length(allIndG);
    redPix{corrFrame} = allIndR;
    greenPix{corrFrame} = allIndG;
    
    %p.progress;
end
%p.stop;
%{
p = ProgressBar(nFrames);
for corrFrame = 1:nFrames
     obj.CurrentTime = (corrFrame-1)/aviSR;
    uFrame = readFrame(obj);
    ufRthreshed = uFrame(:,:,1) > howRedThresh;
    ufGthreshed = uFrame(:,:,2) > howGreenThresh;

    rPixFrame = ufRthreshed.*onMazeMask;
    gPixFrame = ufGthreshed.*onMazeMask;
    
    anyRpix(corrFrame) = sum(sum(rPixFrame));
    anyGpix(corrFrame) = sum(sum(gPixFrame));
    
    p.progress;
end
p.stop;
%}
disp('ss')
save testPos.mat subMultRedX subMultRedY subMultGreenX subMultGreenY nRed nGreen...
    redPix greenPix v0 onMazeMask onMazeX onMazeY anyRpix anyGpix

disp('Done, saved')

figure;
subplot(3,1,1)
plot(1:nFrames,subMultGreenX,'b','LineWidth',1.5)
title('X position subMult')
subplot(3,1,2)
plot(1:nFrames,subMultGreenY,'b','LineWidth',1.5)
title('Y position subMult')
velSubMult = hypot(diff(subMultGreenX,1),diff(subMultGreenY,1));
subplot(3,1,3)
plot(1:nFrames-1,velSubMult,'b','LineWidth',1.5)
title('Velocity subMult')

haveRedX = ~isnan(subMultRedX);
haveRedY = ~isnan(subMultRedY);
haveRedBoth = (haveRedX+haveRedY)==2;

haveGreenX = ~isnan(subMultGreenX);
haveGreenY = ~isnan(subMultGreenY);
haveGreenBoth = (haveGreenX+haveGreenY)==2;

haveBothColors = (haveRedBoth + haveGreenBoth) == 2;
haveRedOnly = ((haveRedBoth + haveGreenBoth) == 1) & haveRedBoth;
haveGreenOnly = ((haveRedBoth + haveGreenBoth) == 1) & haveGreenBoth;

haveColorData = haveRedBoth | haveGreenBoth;
missingPoints = haveColorData == 0;
%sum([sum(haveBothColors) sum(haveRedOnly) sum(haveGreenOnly)]) == sum((haveRedBoth + haveGreenBoth) > 0)

velRed = hypot(diff(subMultRedX,1),diff(subMultRedY,1));
velGreen = hypot(diff(subMultGreenX,1),diff(subMultGreenY,1));




%Fill in where we have color information
xAVI(haveBothColors) = mean([subMultRedX(haveBothColors) subMultGreenX(haveBothColors)],2);
yAVI(haveBothColors) = mean([subMultRedY(haveBothColors) subMultGreenY(haveBothColors)],2);

xAVI(haveRedOnly) = subMultRedX(haveRedOnly);
yAVI(haveRedOnly) = subMultRedY(haveRedOnly);
xAVI(haveGreenOnly) = subMultGreenX(haveGreenOnly);
yAVI(haveGreenOnly) = subMultGreenY(haveGreenOnly);



%Find epochs of missing points based on expected plus maze behavior
ff = figure;
imagesc(v0);
[centerMask,centerX,centerY,] = roipoly;
inCenter = inpolygon(xAVI,yAVI,centerX,centerY);
close(ff);
inCenter = inCenter';

nStartLocs = 2;
for slI = 1:nStartLocs
    ff = figure; imagesc(v0); title(['Draw boundary for start area ' num2str(slI)])
    [startMask{slI},startX{slI},startY{slI}] = roipoly;
    close(ff);
end

nEndLocs = 2;
for elI = 1:nEndLocs
    ff = figure; imagesc(v0); title(['Draw boundary for end area ' num2str(elI)])
    [endMask{elI},endX{elI},endY{elI}] = roipoly;
    close(ff);
end

minCenterDur = 2;

enterCenter = find(diff(inCenter) == 1);
leaveCenter = find(diff(inCenter) == -1)+1;

outEpochs = [leaveCenter(1:end-1) enterCenter(2:end)];
outDurations = diff(outEpochs,1,2);

badEpochs = outDurations < minCenterDur; %unlikely to be real

enterCenter(logical([0; badEpochs])) = [];
leaveCenter(logical([badEpochs; 0])) = [];

offMazeMin = 10; %Minimum number of frames an entrance is separated from an exit to be considered real
onMazeMin = 20;

behaviorMarker = inCenter';
behBoundsX = [startX, endX];
behBoundsY = [startY, endY];
bbsStartsEnds = [1*ones(1,nStartLocs) 2*ones(1,nEndLocs)];

for bbxI = 1:length(bbsStartsEnds)
    inHere = inpolygon(xAVI,yAVI,behBoundsX{bbxI},behBoundsY{bbxI});
    behaviorMarker = behaviorMarker+(1+bbxI)*inHere;
end
behaviorMarker = behaviorMarker';

%Get entries/exits of maze arm ends, refine by duration
leaveArmEnd = find(diff([0; behaviorMarker]>1) == -1); laeHold = leaveArmEnd;
enterArmEnd = find(diff([0; behaviorMarker]>1) == 1);    eaeHold = enterArmEnd;    

%Eliminate out of center that doesn't include other arms
cbI = 1;
while cbI < length(enterCenter)
    armHere = sum(behaviorMarker(leaveCenter(cbI):enterCenter(cbI+1)) > 1);
    switch armHere > 0
        case 0
            leaveCenter(cbI) = [];
            enterCenter(cbI+1) = [];
        case 1
            cbI = cbI+1;
        otherwise
            disp('switch error')
            keyboard
    end
end

%Delete too short off maze epochs
offMazeEpochs = [enterArmEnd(2:end) leaveArmEnd(1:end-1)];
outArmDurations = diff(fliplr(offMazeEpochs),1,2);
badArmEpochs = outArmDurations < offMazeMin; %unlikely to be real
offMazeEpochs(badArmEpochs,:) = [];

leaveArmEnd = [offMazeEpochs(:,2); leaveArmEnd(end)];
enterArmEnd = [enterArmEnd(1); offMazeEpochs(:,1)];

probablyOnMaze = zeros(length(xAVI),1);
for ceI = 1:length(enterCenter)
    probablyOnMaze(enterCenter(ceI):leaveCenter(ceI)) = 1;
end
for aeI = 1:length(enterArmEnd)
    probablyOnMaze(enterArmEnd(aeI):leaveArmEnd(aeI)) = 1;
end

%Check for leaveCenter - enterCenter where there's only one arm entry and
%exit
behTable = [zeros(length(enterCenter),2) enterCenter leaveCenter zeros(length(enterCenter),2)];
behTable(1,1) = enterArmEnd(1);
behTable(1,2) = leaveArmEnd(1);
possibleBadMazeExit = zeros(length(enterCenter),1);
possibleBadMazeEntry = zeros(length(enterCenter),1);
for ceJ = 1:(length(leaveCenter)-1)
    armEntries = enterArmEnd(enterArmEnd > leaveCenter(ceJ) & enterArmEnd < enterCenter(ceJ+1));
    armLeavings = leaveArmEnd(leaveArmEnd > leaveCenter(ceJ) & leaveArmEnd < enterCenter(ceJ+1));
    
    switch length(armEntries)
        case 2
            behTable(ceJ,5) = armEntries(1);
            behTable(ceJ,6) = armLeavings(1);

            if behTable(ceJ+1,2) == 0
                behTable(ceJ+1,2) = armLeavings(2);
            end
            if behTable(ceJ+1,1) == 0
                behTable(ceJ+1,1) = armEntries(2);
            end
        case 1 %Either mouse is carried through the maze to the start of the next trial, or 
               %Mouse was allowed to correct his mistake, or
               %Mouse was carried off the maze through the center at the end of a trial
            behTable(ceJ,5) = armEntries;
            behTable(ceJ,6) = armLeavings;
            
            behTable(ceJ+1,1) = armEntries;
            behTable(ceJ+1,2) = armLeavings;
            
            possibleBadMazeExit(ceJ) = 1;
            possibleBadMazeEntry(ceJ+1) = 1;
        case 0
            %Won't happen
            keyboard
        otherwise
            %Figure out if any are the same as the first and last, and assume they go with that one
            %If they are all the same, could up to the first and last one
            %with each, we'll have to sort out overlap to find off maze later
            %This will skip points that are not the same (can't jump from
            %one arm to another without going through middle
            armEndInds = 1:length(armEntries);
            
            whichArmEnds = [];
            for aeI = 1:length(armEntries)
                whichArmEnds(aeI) = mode(behaviorMarker(armEntries(aeI):armLeavings(aeI)));
            end
            
            sameAsFirst = whichArmEnds(2:end-1) == whichArmEnds(1);
            sameAsLast = whichArmEnds(2:end-1) == whichArmEnds(end);
            
            sharedFirstLast =  sum([sameAsFirst; sameAsLast],1)==2;
            
            changesFromStart = find(diff([whichArmEnds(1:end-1)==whichArmEnds(1) 0])==-1);
            changesFromEnd = find(diff([0 whichArmEnds(2:end)==whichArmEnds(end)])==1)+1;
            %changesFromStart = find(diff([whichArmEnds(1:end-1)==whichArmEnds(1) 0])==-1,1,'first');
            %changesFromEnd = find(diff([0 whichArmEnds(2:end)==whichArmEnds(end)])==1,1,'last')+1;
                
            if length(changesFromStart)==1 && length(changesFromEnd)==1
                armEndsStart = armEndInds(1:changesFromStart);
                armEndsEnd = armEndInds(changesFromEnd:end);
                
                posFirst = [armEntries(armEndsStart) armLeavings(armEndsStart)];
                posLast = [armEntries(armEndsEnd) armLeavings(armEndsEnd)];
                
                behTable(ceJ,5) = posFirst(1,1);
                behTable(ceJ,6) = posFirst(end,2);
                
                behTable(ceJ+1,1) = posLast(1,1);
                behTable(ceJ+1,2) = posLast(end,2);
            else
                keyboard
                %probably just take first in changes from start, last in changes from end
                %see commented out modification for ^^          and          ^^
            end
            
    end  
%figure; imagesc(v0); hold on; plot(xAVI(behaviorMarker==5),yAVI(behaviorMarker==5),'.g')    
end
armEntries = enterArmEnd(enterArmEnd > leaveCenter(length(leaveCenter)));
armLeavings = leaveArmEnd(leaveArmEnd > leaveCenter(length(leaveCenter)));
if any(armEntries)
    behTable(length(leaveCenter),5) = armEntries(1);
    behTable(length(leaveCenter),5) = armLeavings(end);
else %probably carried through center? 
    keyboard
    behTable(length(leaveCenter),5) = NaN;
    behTable(length(leaveCenter),5) = NaN;
end
%Get user input on overlapped segments, check if mouse is on the maze
for ceK = 1:size(behTable,1)-1
    if behTable(ceK,5) == behTable(ceK+1,1) %|| behTable(ceK,6) == behTable(ceK+1,2)
        segsComp = [4 5; 2 3];
        for segI = 1:2
             stretchCheck = behTable(ceK+(segI-1),segsComp(segI,1)):behTable(ceK+(segI-1),segsComp(segI,2));
             midFrameInd = round(length(stretchCheck)/2);
             midFrameN = stretchCheck(midFrameInd);
             obj.CurrentTime = (midFrameN-1)/aviSR;
             midFrame = readFrame(obj);
             orFrame = figure; imagesc(midFrame);
             usrApp = figure('Position',mcfOriginalSize);
             imagesc(midFrame); hold on
             plot(xAVI(stretchCheck(1:midFrameInd-1)),yAVI(stretchCheck(1:midFrameInd-1)),'og')
             plot(xAVI(stretchCheck(midFrameInd+1:end)),yAVI(stretchCheck(midFrameInd+1:end)),'or')
             plot(xAVI(midFrameN),yAVI(midFrameN),'*y')
             title(['Is this segment on the maze?  midFrame= ' num2str(midFrameN) ' (y/n) (input)'])
             ss = 'g';
             while (strcmpi(ss,'y') + strcmpi(ss,'n'))==0
                ss = input('Is this segment on the maze? (y/n) >>','s');
             end
             
             segsDel = [5 6; 1 2];
             if strcmpi(ss,'n')
                behTable(ceK+(segI-1),segsDel(segI,1)) = NaN;
                behTable(ceK+(segI-1),segsDel(segI,2)) = NaN;
                %Do the same thing for the segment preceeding this middle chunk
             end
             
             close(orFrame); close(usrApp);
        end  
    end
end


%{
realOnMazeDur = 0;
for ii = 1:size(handCoded,1)
    realOnMazeDur = realOnMazeDur + handCoded(ii,2) - handCoded(ii,1) + 1;
end
%}



%Find possible trial boundaries
posTrialEnd = [];
posTrialStart = [];
for tbI = 1:(length(leaveArmEnd)-1)
    centerHere = sum(behaviorMarker(enterArmEnd(tbI):leaveArmEnd(tbI+1))==1);
    switch centerHere > 0
        case 1
            %Not a trial boundary
        case 0
            %possibly a trial boundary
            posTrialEnd = [posTrialEnd; enterArmEnd(tbI)];
            posTrialStart = [posTrialStart; leaveArmEnd(tbI+1)];
        otherwise
            disp('switch error')
            keyboard
    end
end   

checkMazeStarts = [leaveArmEnd(1); posTrialStart];
checkMazeEnds = [posTrialEnd; enterArmEnd(end)];

%Do this working out from centers
behTable = zeros(1,6);
for cbI = 1:length(enterCenter)
    %Work backwards
    behTable(cbI+1,3) = enterCenter(cbI);
    try
        behTable(cbI+1,1) = checkMazeStarts(find(checkMazeStarts < behTable(cbI+1,3),1,'last'));
    catch
        %Case is likely where carrying from ITI platform, through center,
        %to arm end
        behTable(cbI+1,1) = NaN;
    end
    
    %Work forwards
    behTable(cbI+1,4) = leaveCenter(cbI);
    try
        behTable(cbI+1,6) = checkMazeEnds(find(checkMazeEnds > behTable(cbI+1,4),1,'first'));    
    catch
        %Case is likely moving mouse from end, through center back to ITI
        %platform
        behTable(cbI+1,6) = NaN;
    end
end
behTable(1,:) = [];

%Look at start/end overlaps
cbJ = 1;
while cbJ < size(behTable,1)
    doubleRows = find(behTable(:,1)==behTable(cbJ,1));
    centerDursHere = behTable(doubleRows,4) - behTable(doubleRows,3);

    [~,deleteRow] = min(centerDursHere)
    
    
    
end


%{


%leaveArmEnd = [1; leaveArmEnd];
%enterArmEnd = [enterArmEnd; nFrames];
posOnMazeEpochs = [leaveArmEnd(1:end-1) enterArmEnd(2:end)];

passedThruCenter = zeros(length(leaveArmEnd)-1,1);
for oaeI = 1:size(length(leaveArmEnd)-1,1)
    centerNow = sum(behaviorMarker(posOnMazeEpochs(oaeI,1):posOnMazeEpochs(oaeI,2))==1); 
    passedThruCenter(oaeI) = centerNow > 1;
end


possibleLap = passedThruCenter==1;

posOnMazeEpochs = posOnMazeEpochs(possibleLap,:);






yesAnITI = passedThruCenter == 0; %Epochs where tracking jumps from one arm end to another (good, that's an ITI)






%Delete off maze too short first
offMazeEpochs = [leaveArmEnd(1:end-1) enterArmEnd(2:end)];
outArmDurations = diff(offMazeEpochs,1,2);
badArmEpochs = outArmDurations < offMazeMin; %unlikely to be real
offMazeEpochs(badArmEpochs,:) = [];

%Delete off maze where passed through center
passedThruCenter = zeros(size(offMazeEpochs,1),1);
for oaeI = 1:size(offMazeEpochs,1)
    centerNow = sum(behaviorMarker(offMazeEpochs(oaeI,1):offMazeEpochs(oaeI,2))==1); 
    passedThruCenter(oaeI) = centerNow > 1;
end
yesAnITI = passedThruCenter == 0; %Epochs where tracking jumps from one arm end to another (good, that's an ITI)

offMazeEpochs = offMazeEpochs(yesAnITI,:);

posOntoMaze = [enterArmEnd(1); offMazeEpochs(:,2)];
posOffofMaze = [offMazeEpochs(:,1); leaveArmEnd(end)];

posOnMazeEpochs = [posOntoMaze posOffofMaze];







%Delete on maze too short
enterArmEnd2 = [enterArmEnd(1); offMazeEpochs(:,2)]; 
leaveArmEnd2 = [offMazeEpochs(:,1); leaveArmEnd(end)]; 

posOnMazeEpochs = [enterArmEnd2 leaveArmEnd2];
tooShortOnMaze = diff(posOnMazeEpochs,1,2) < onMazeMin;
posOnMazeEpochs(tooShortOnMaze,:) = [];

%Delete off maze that includes the center
offMazeEpochs2 = [posOnMazeEpochs(:,1:end-1) posOnMazeEpochs(:,2:end)]; %[leave enter]
passedThruCenter = zeros(size(offMazeEpochs2,1),1);
for oaeI = 1:size(offMazeEpochs2,1)
    centerNow = sum(behaviorMarker(offMazeEpochs2(oaeI,1):offMazeEpochs2(oaeI,2))==1); 
    passedThruCenter(oaeI) = centerNow > 1;
end
possibleITIs = passedThruCenter == 0; %Epochs where tracking jumps from one arm end to another (good, that's an ITI)

offMazeEpochs2 = offMazeEpochs2(possibleITIs,:);

enterArmEnd3 = 

onMazeEpochs = [offMazeEpochs2(1:end-1,2) offMazeEpochs2(2:end,1)];

%Delete on meaze where skips the center


armEpochEntries = [enterArmEnd(1); offMazeEpochs(:,2)];
armEpochExits = [offMazeEpochs(:,1); leaveArmEnd(end)];

posOnMazeEpochs = [armEpochEntries armEpochExits];
passedThruCenter = zeros(size(posOnMazeEpochs,1),1);
for oaeI = 1:size(posOnMazeEpochs,1)
    centerNow = sum(behaviorMarker(posOnMazeEpochs(oaeI,1):posOnMazeEpochs(oaeI,2))==1); 
    passedThruCenter(oaeI) = (centerNow > 1);
end
possibleTrials = passedThruCenter == 1; %Epochs where tracking jumps from one arm end to another

onMazeEpochs



%}





%Here is where user decides how to correct things here on out

velThresh = 25;

skipDefGood = 1;
editChoice = input('How would you like to edit? >>','s');
switch editChoice
    
    case 'v'
        doneVel = 0;
        
        triedVel = zeros(length(veloc),1);
        while doneVel == 0
        
        veloc = hypot(diff(xAVI,1),diff(yAVI,1));
        

        if skipDefGood == 1
            veloc(definitelyGood(1:end-1)) = 0;
        end

        badVel = veloc > velThresh;
        badVelStarts = find(diff(badVel,1) == 1)+1;
        badVelStops = find(diff(badVel,1) == -1);

        yesBadPts = sum(badVel) > 0;
        while yesBadPts == 1
            thisBadStart = badVelStarts(1); 

            %plotFrame(obj,frameNum,xBoundary,yBoundary,xPt,yPt,ptColor)

            obj.CurrentTime = (thisBadStart-1)/aviSR;
            uFrame = readFrame(obj);
            imagesc(manCorrFig.Children,uFrame);
            title(['Frame # ' num2str(thisBadStart) ', high velocity corr'])
            hold(manCorrFig.Children,'on')
            plot(manCorrFig.Children,xAVI(thisBadStart),yAVI(thisBadStart),'+r')
            hold(manCorrFig.Children,'off') 

            %nextStops = badVelStops(badVelStops>thisBadStart);
            %thisBadStop = nextStops(1);

            problemFramesCheck = [thisBadStart thisBadStart+1];

            %haveColorData(problemFramesCheck)

            tryPts = 1;
            velHereGood = 0;

            XptsToTry{1} = subMultRedX;
            YptsToTry{1} = subMultRedY;
            for ddI = 1:length(dvtPos)
                XptsToTry{1 + ddI*2-1} = dvtPos{ddI}.redX;
                YptsToTry{1 + ddI*2-1} = dvtPos{ddI}.redY;

                XptsToTry{1 + ddI*2} = dvtPos{ddI}.greenX;
                YptsToTry{1 + ddI*2} = dvtPos{ddI}.greenY;
            end

            while velHereGood == 0
                xNew = XptsToTry{tryPts}; 
                yNew = YptsToTry{tryPts};

                [velNow,xRep,yRep] = TryNewPointVelocity(xAVI,yAVI,problemFramesCheck,xNew,yNew);

                velGood = velNow < velThresh;
                switch sum(velGood)
                    case 0
                        velHereGood = 0;
                        tryPts = tryPts+1;
                    case 1
                        velHereGood = 1;
                        xAVI(problemFramesCheck(velGood)) = xRep(velHereGood);
                        yAVI(problemFramesCheck(velGood)) = yRep(velHereGood);
                        foundColorPt = 1;

                        if find(velGood)==2
                            obj.CurrentTime = (problemFramesCheck(velGood)-1)/aviSR;
                            uFrame = readFrame(obj);
                            imagesc(manCorrFig.Children,uFrame);
                            title(['Frame # ' num2str(problemFramesCheck(velGood)) ', high velocity corr'])
                        end

                        hold(manCorrFig.Children,'on')
                        plot(manCorrFig.Children,xAVI(problemFramesCheck(velGood)),yAVI(problemFramesCheck(velGood)),'+g')
                        hold(manCorrFig.Children,'off') 
                    case 2
                        %Probably an error
                        velHereGood = 0;
                        tryPts = tryPts+1;
                        disp('2 good vel reps')
                end

                if tryPts > length(XptsToTry)
                    velHereGood = 1;
                    foundColorPt = 0;
                end
            end 

            triedVel(thisBadStart) = triedVel(thisBadStart)+1;

            if foundColorPt == 0
                if triedVel(thisBadStart) > 1
                    buttonPressed = 0;
                    while ButtonPressed == 0
                        %[xClick,yClick,buttonPressed] = ManualCorrectThisFrame(mcfHandle)
                        figure(manCorrFig);
                        imagesc(manCorrFig.Children,uFrame);
                        hold(manCorrFig.Children,'on')
                        plot(manCorrFig.Children,xAVI(thisBadStart),yAVI(thisBadStart),'+r')
                        hold(manCorrFig.Children,'off')
                        title('Click Here; right click marks to ignore')
                        [xClick,yClick,buttonPressed] = ginput(1);

                        switch buttonPressed
                            case 1
                                xAVI(thisBadStart) = xClick;
                                yAVI(thisBadStart) = yClick;
                                definitelyGood(thisBadStart) = true;
                                hold(manCorrFig.Children,'on')
                                plot(manCorrFig.Children,xAVI(thisBadStart),yAVI(thisBadStart),'+g')
                                hold(manCorrFig.Children,'off')
                            case 3
                                definitelyGood(thisBadStart) = true;
                        end
                    end
                end
            end

        end
        
        
        
        
        end
    case 's'
        save PosLED_temp.mat xAVI yAVI definitelyGood v0 subMultRedX subMultRedY...
            subMultGreenX subMultGreenY dvtPos Rbrightness Gbrightness calibrateFrames...
            howRed howGreen...
            nRed nGreen redPix greenPix
        disp('Saved!')
    case 't'
        threshEdit = questdlg(['Current is ' num2str(velThresh) '. How to edit velocity threshold?'], 'Edit vel thresh', ...
                              'ginput','number','ginput');
        switch threshEdit
            case 'ginput'
                tt = figure;
                veloc = hypot(diff(xAVI,1),diff(yAVI,1));
                veloc(definitelyGood(1:end-1)) = 0;
                plot(veloc); hold on; plot([1 length(veloc)],[velThresh velThresh],'r')
                [~,velThresh] = ginput(1);
                
            case 'number'
                velThresh = input('What is the new velThresh?  >>');
        end 
        disp(['New velThresh is ' num2str(velThresh)])   
    otherwise 
        disp('Not a recognized input')
end

end

function [rfRsub, rfGsub] =  GetSelfSubFrame(uFrame, v0r, v0g, onMazeMask)
    
%Strip down frames, find max green and red
uFrameR = double(uFrame(:,:,1) - uFrame(:,:,2));
uFrameG = double(uFrame(:,:,2));
    
%rfRsub = rFrameR - v0g;
rfRsub = uFrameR - v0r; rfRsub(rfRsub < 0) = 0;
rfGsub = uFrameG - v0g; rfGsub(rfGsub < 0) = 0;
   
rfGsub = uFrameG.*rfGsub;
rfRsub = uFrameR.*rfRsub;
    
if ~isempty(onMazeMask)
    rfRsub = rfRsub.*onMazeMask;
    rfGsub = rfGsub.*onMazeMask;
end
    
end

function [allIndX,colorX,colorY] = GetBrightBlobPixels(rfSubFrame,nBrightPoints)
frameSize = [size(rfSubFrame,1) size(rfSubFrame,2)];

%Find the 5 reddest/greenest points in the subtraction frame, see which is brightest 
[sortedSubVals, sortOrderSub] = sort(rfSubFrame(:),'descend');
allIndX = sortOrderSub(1:nBrightPoints);
%figure; imagesc(uFrame); hold on; [ploty, plotx] = ind2sub(frameSize,allIndR); plot(plotx,ploty,'*c')

%Eliminate pixels where the value is 0
allIndX( rfSubFrame(allIndX) == 0 ) = [];

%If there are 2 blobs, get the bigger one
xBlobs = zeros(frameSize); xBlobs(allIndX) = 1; 
xMaxBlobs = bwconncomp(xBlobs);
[~,biggerXblob] = max(cell2mat(cellfun(@length,xMaxBlobs.PixelIdxList,'UniformOutput',false)));

if any(biggerXblob)
    allIndX = xMaxBlobs.PixelIdxList{biggerXblob};

    %Convert to X/Y
    [xRowAll,xColAll] = ind2sub(frameSize,allIndX);
    colorY = mean(xRowAll); colorX = mean(xColAll);
else
    colorY = NaN; colorX = NaN;
end

end

function [velNow,xRep,yRep] = TryNewPointVelocity(xAVI,yAVI,problemFramesCheck,xNew,yNew)      
origX = xAVI(problemFramesCheck);
origY = yAVI(problemFramesCheck);
    
xRep = xNew(problemFramesCheck);
yRep = yNew(problemFramesCheck);
    
%Replace first point, try velocity
firstRepVel = hypot(diff([xRep(1) origX(2)]),diff([yRep(1) origY(2)]));
%Replace second point, try velocity
secondRepVel = hypot(diff([xRep(2) origX(1)]),diff([yRep(2) origY(1)]));
    
velNow = [firstRepVel; secondRepVel];
end

function FrameTrackingViewer(v0,obj,startFrame,xAVI,yAVI)





end


%{
dd = figure; imagesc(v0)
currFrame = 2650;
donePlotting = 0;
while donePlotting == 0
    plotNow = 0;
    ss = input('prev = a, next = d, changeScale = c, done = m >>','s');
    switch ss
        case 'd'
            currFrame = currFrame+1;
            plotNow = 1;
        case 'a'
            currFrame = currFrame - 1;
            plotNow = 1;
        case 'c'
            cc = input(['Current scale factor is: ' num2str(DVTtoAVIscale)', enter new scaling']);
            cc = double(cc);
            plotNow = 1;
        case 'm'
            donePlotting = 1;
            disp('done plotting')
        otherwise
            %Do nothing
            disp('Not a recognized input')
    end
    if plotNow == 1
        obj.CurrentTime = (currFrame-1)/aviSR;
        uFrame = readFrame(obj);
        imagesc(dd.Children,uFrame);
        title(['Frame# ' num2str(currFrame)])
        
        tg = pos_data{1}(currFrame,5:6);
        tgn = tg*DVTtoAVIscale;
        tgn(2) = frameSize(1) - tgn(2);
        
        tr = pos_data{1}(currFrame,3:4);
        trn = tr*DVTtoAVIscale;
        trn(2) = frameSize(1) - trn(2);
        
        hold(dd.Children,'on')
        plot(dd.Children,trn(1),trn(2),'or')
        plot(dd.Children,tgn(1),tgn(2),'og')
        hold(dd.Children,'off') 
    end
end
%}