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
p = ProgressBar(nFrames);
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
    
    p.progress;
end
p.stop;

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

%Find epochs of missing points
ff = figure;
imagesc(v0);
[centerMask,centerX,centerY,] = roipoly;
inCenter = inpolygon(xAVI,yAVI,centerX,centerY);

enterCenter = find(diff(inCenter) == 1);
leaveCenter = find(diff(inCenter) == -1);

outEpochs = [leaveCenter(1:end-1) enterCenter(2:end)];
outDurations = diff(outEpochs,1,2);

badEpochs = outDurations < 100; %unlikely to be real

enterCenter(logical([0; badEpochs])) = [];
leaveCenter(logical([badEpochs; 0])) = [];





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
        disp(['New velThresh is ' num2str(velThresh])   
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