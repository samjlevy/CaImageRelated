function PreProcessLEDtracking
%issues:
% - make brightness/led calibrayion something that can be done again
% - GUI version (see evernote)
% - Need to add pedestal epochs to behavior parsing
% - Delete progress bar text files

%testDir = 'G:\DoublePlus\Marble11_180721';
if contains(version,'R2016a')
    disp('Sorry, 2016a not going to work; use 2016b')
    return
end

avi_filepath = ls('*.avi');
if size(avi_filepath,1)~=1
    [avi_filepath,~] = uigetfile('*.avi','Choose appropriate video:');
end
disp(['Using ' avi_filepath ])
obj = VideoReader(avi_filepath);
aviSR = obj.FrameRate;
nFrames = obj.Duration*aviSR;  
frameSize = [obj.Height obj.Width];

%Pre-allocate stuff
velThresh = 25;
xAVI = zeros(nFrames,1);
yAVI = zeros(nFrames,1);
mcfScaleFactor = 1;
mcfOriginalSize = [680 558 560 420];
DVTtoAVIscale = 0.6246;
definitelyGood = false(size(xAVI,1),size(xAVI,2));
dvtPos = [];
brightnessCalibrated = 0;
v0 = [];
subMultRedX = nan(nFrames,1);
subMultRedY = nan(nFrames,1);
subMultGreenX = nan(nFrames,1);
subMultGreenY = nan(nFrames,1);
nRed = nan(nFrames,1);
nGreen = nan(nFrames,1);
redPix = cell(nFrames,1);
greenPix = cell(nFrames,1);
onMazeX = []; onMazeY = []; onMazeMask = [];
Rbrightness = []; Gbrightness = [];
howRed = []; howGreen = [];
anyRpix = []; anyGpix = [];
onMaze = ones(size(xAVI,1),size(xAVI,2)); behTable = [];

posFile =fullfile(cd,'PosLED_temp.mat');
if exist(posFile,'file')==2
    usePos = questdlg('Found a PosLED_temp.mat, want to use it?','Use found pos',...
                    'Yes','No, start over','Yes');
    if strcmp(usePos,'Yes')
        load('PosLED_temp.mat') %#ok<LOAD>
    end
else
    disp('Did not find existing PosLED_temp.mat, starting fresh')
end


if isempty(dvtPos)
doneDVTs = 0; dd = 1;
while doneDVTs == 0
    [DVTfile, DVTpath] = uigetfile('*.DVT', 'Select DVT file');
    filepath = fullfile(DVTpath, DVTfile);

    pos_data{dd} = importdata(filepath); %#ok<AGROW>
    
    ss = input('Done loading DVTs? (y/n) >> ','s');
    if strcmpi(ss,'y')
        doneDVTs = 1;
    else
        dd = dd+1;
    end

    dvtPos{dd}.redX = pos_data{dd}(:,5)*DVTtoAVIscale; %#ok<AGROW>
    dvtPos{dd}.redY = pos_data{dd}(:,6)*DVTtoAVIscale; %#ok<AGROW>
    dvtPos{dd}.redY = frameSize(1) - dvtPos{dd}.redY; %#ok<AGROW>
    dvtPos{dd}.greenX = pos_data{dd}(:,3)*DVTtoAVIscale; %#ok<AGROW>
    dvtPos{dd}.greenY = pos_data{dd}(:,4)*DVTtoAVIscale; %#ok<AGROW>
    dvtPos{dd}.greenY = frameSize(1) - dvtPos{dd}.greenY; %#ok<AGROW>

    dvtPos{dd}.redX( dvtPos{dd}.redX==0 & dvtPos{dd}.redY==0 ) = NaN; %#ok<AGROW>
    dvtPos{dd}.redY( dvtPos{dd}.redX==0 & dvtPos{dd}.redY==0 ) = NaN; %#ok<AGROW>
end

end


[v0] = AdjustWithBackgroundImage(avi_filepath, obj, v0);

v0r = double(v0(:,:,1) - v0(:,:,3));
v0g = double(v0(:,:,2));  

%Find the onmaze area
bb = figure; imagesc(v0); hold on
drawOMB = 0;
if any(onMazeX)
    plot([onMazeX; onMazeX(1)],[onMazeY; onMazeY(1)],'r')
    usomb = questdlg('Found on maze mask, redraw?','Redraw onmaze','Keep','Redraw','Keep');
    if strcmpi(usomb,'Redraw')
        drawOMB = 1;
    end
else
    drawOMB = 1;
end
if drawOMB == 1
    figure(bb); imagesc(v0)
    title('Draw onMaze boundary')
    [onMazeMask,onMazeX,onMazeY] = roipoly;
end
close(bb);

v0g = v0g.*onMazeMask;
v0r = v0r.*onMazeMask;

nBrightPoints = 5;
if brightnessCalibrated==1
    reca = questdlg('Brightness is calibrated. Use or recalibrate?','Recal','Use','Recalibrate','Use');
    if strcmpi(reca,'Recalibrate')
        brightnessCalibrated = 0;
    end
end

if brightnessCalibrated == 0

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
        ss = input('Is the mouse somewhere good in this frame? (y/n) >>','s') %#ok<NOPRT>
        if strcmpi(ss,'y')
            mouseInFrame=1;
        end
        close(gg);
    end
    gg = figure; imagesc(uFrame)
    
    [rfRsub, rfGsub] =  GetSelfSubFrame(uFrame, v0r, v0g, onMazeMask);
    
    [allIndR,redX,redY] = GetBrightBlobPixels(rfRsub,nBrightPoints); %#ok<ASGLU>
    [allIndG,greenX,greenY] = GetBrightBlobPixels(rfGsub,nBrightPoints); %#ok<ASGLU>
    
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
            doneZoom = input('type Y when done zooming in for manual at pixel level','s');  %#ok<NASGU>
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
            doneZoom = input('type Y when done zooming in for manual at pixel level','s'); %#ok<NASGU>
            for pnG = 1:nBrightPoints
                [xx,yy] = ginput(1);
                Gcind(pnG) = round(xx); Grind(pnG) = round(yy);
                plot(Gcind(pnG),Rrind(pnG),'or');plot(Gcind(pnG),Grind(pnG),'.r')
            end
        end
        close(greenF);
    end             
    
    close(gg);
    
    Rbrightness{tfI,1} = rfRsub(allIndR);  %#ok<AGROW>
    Gbrightness{tfI,1} = rfGsub(allIndG);  %#ok<AGROW>
    
    calibrateFrames(tfI,1) = rFrameNum;  %#ok<AGROW>
    
    for uh = 1:length(Rrind)
        howRed{tfI,1}(uh,1) = double(uFrame(Rrind(uh),Rcind(uh),1));  %#ok<AGROW>
    end
    for rg = 1:length(Grind)
        howGreen{tfI,1}(rg,1) = double(uFrame(Grind(rg),Gcind(rg),2));  %#ok<AGROW>
    end

    brightnessCalibrated = 1;
end
end

rMeans = cell2mat(cellfun(@mean,howRed,'UniformOutput',false));
gMeans = cell2mat(cellfun(@mean,howGreen,'UniformOutput',false));

howRedThresh =  mean(rMeans) - 1.5*std(rMeans); %Use in raw frame
howGreenThresh = mean(gMeans) - 2*std(gMeans); %Use in raw frame

mcfCurrentSize = mcfOriginalSize;
mcfCurrentSize(3:4) = mcfCurrentSize(3:4)*mcfScaleFactor;
manCorrFig = figure('Position',mcfCurrentSize,'name','manCorrFig');
imagesc(v0); 
SaveTemp;
firstPass = questdlg('Want to do auto tracking by LEDs?','Auto track?','Yes','No','Yes');
if strcmpi(firstPass,'Yes')
manCorrFig = CheckManCorrFig(mcfCurrentSize,manCorrFig,v0);
%imagesc(v0)
rawColorThresh = 1;
%First pass just correct all the frames
p = ProgressBar(nFrames);
for corrFrame = 1:nFrames
    [redX, redY, greenX, greenY, allIndR, allIndG, anyRpix, anyGpix] = AutoCorrByLED(...
    manCorrFig, obj, corrFrame, onMazeX, onMazeY, onMazeMask, v0r, v0g, rawColorThresh,...
    howRedThresh, howGreenThresh, nBrightPoints);

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
missingPoints = haveColorData == 0; %#ok<NASGU>
%sum([sum(haveBothColors) sum(haveRedOnly) sum(haveGreenOnly)]) == sum((haveRedBoth + haveGreenBoth) > 0)

velRed = hypot(diff(subMultRedX,1),diff(subMultRedY,1)); %#ok<NASGU>
velGreen = hypot(diff(subMultGreenX,1),diff(subMultGreenY,1)); %#ok<NASGU>

%Fill in where we have color information
xAVI(haveBothColors) = mean([subMultRedX(haveBothColors) subMultGreenX(haveBothColors)],2);
yAVI(haveBothColors) = mean([subMultRedY(haveBothColors) subMultGreenY(haveBothColors)],2);

xAVI(haveRedOnly) = subMultRedX(haveRedOnly);
yAVI(haveRedOnly) = subMultRedY(haveRedOnly);
xAVI(haveGreenOnly) = subMultGreenX(haveGreenOnly);
yAVI(haveGreenOnly) = subMultGreenY(haveGreenOnly);
end
SaveTemp;



optionsText = {'m - mark off maze time';...
    'z - fix (0,0) frames';...
    'b - parse onMaze time';...
    'r - scale mancorrfig';...
    'p - correct by position';...
    'v - correct by velocity';...
    't - reset velocity threshold';...
    'n - edit by frame number';...
    ' ';...
    's - save';...
    'q - save and quit';...
    };
hb = msgbox(optionsText,'PreProcess Keys');

%Here is where user decides how to correct things here on out
[posAndVelFig] = UpdatePosAndVel(xAVI,yAVI,onMaze,definitelyGood,velThresh,[]);
stillEditing = 1;
while stillEditing == 1
    posAndVelFig = UpdatePosAndVel(xAVI,yAVI,onMaze,definitelyGood, velThresh,posAndVelFig);
    manCorrFig = CheckManCorrFig(mcfCurrentSize,manCorrFig,v0);
    mcfCurrentSize = manCorrFig.Position;
    editChoice = input('How would you like to edit? >>','s');
    switch editChoice
        case 'n'
            enHow = questdlg('How find numbers?','Enter number','Select window','Enter number','Select window');
            switch enHow
                case 'Enter number'                    
                    prompt = {'Edit start:','Edit end:'};
                    defaultans = {'1','2'};
                    answer = inputdlg(prompt,'Edit by frame numbers',1,defaultans);
                    answer = cell2mat(cellfun(@str2num,answer,'UniformOutput',false));
                case 'Select window'
                    figure(posAndVelFig);
                    [answerX,~] = ginput(2);
                    
                    answer(1) = max([0 min(round(answerX))]);
                    answer(2) = min([length(xAVI) max(round(answerX))]);
            end
            
            framesFix = min(answer):max(answer);
                        
            %howEdit = questdlg(['Edit these ' num2str(length(framesFix)) ' frames?'],'Edit','Auto','Manual','Cancel','Auto'); 
            
            [xAVI,yAVI,definitelyGood] = CorrectManualFrames(obj,xAVI,yAVI,v0,definitelyGood,manCorrFig,framesFix,velThresh);
        
        case 'm'
            onoroff = questdlg('Mark on-maze or off-maze?','Oh, Hi Mark','on','off','off');
            omStart = str2double(input(['Mark ' onoroff '-maze start frame: '],'s'));
            omEnd = str2double(input(['Mark ' onoroff '-maze stop frame: '],'s'));
            doIt = input(['Marking ' num2str(omStart) ' through ' num2str(omEnd) ', yes? (y/n)'],'s');
            if strcmpi(doIt,'y')
            switch onoroff
                case 'on'
                    onMaze(omStart:omEnd) = 1;
                case 'off'
                    onMaze(omStart:omEnd) = 0;
            end
            end
        case 'z'
            %Correct zero frames
            zeroFrames = xAVI==0 & yAVI==0;
            %exclude off maze?
            if strcmpi(eom,'Yes')
                zeroFrames = zeroFrames.*onMaze;
            end
            %Redo def good?
            if strcmpi(exDG,'No')
                zeroFrames(definitelyGood) = 0;
            end

            zeroFramesN = find(zeroFrames);
            disp(['Now correcting ' num2str(length(zeroFramesN)) ' (0,0) frames'])
            
            [xAVI,yAVI,definitelyGood] = CorrectManualFrames(obj,xAVI,yAVI,v0,definitelyGood,manCorrFig,framesFix,velThresh);
            
            disp('Done zero frames correction')
        case 'b'
            [onMazeFinal,behTable] = parseOnMazeBehavior(xAVI,yAVI,v0,obj);
            onMaze = zeros(size(xAVI,1),size(xAVI,2));
            for omII = 1:size(onMazeFinal,1)
                onMaze(onMazeFinal(omII,1):onMazeFinal(omII,2)) = 1;
            end
        case 'p'
            %Correct by position

            posInclude = true(size(xAVI,1),size(xAVI,2));
            pomp = questdlg('Plot off maze pos?','pomp','Yes','No','No');
            if strcmpi(pomp,'No')
                posInclude(onMaze==0) = 0;
            end
            pdgp = questdlg('plot def good pos?','pdgp','Yes','No','No');
            if strcmpi(pdgp,'No')
                posInclude(definitelyGood) = 0;
            end

            posFig = figure; imagesc(v0);
            hold on
            plot(xAVI(posInclude),yAVI(posInclude),'.b')
            [~,lassoX,lassoY]=roipoly;

            posIncInds = find(posInclude);
            inLasso = inpolygon(xAVI(posInclude),yAVI(posInclude),lassoX,lassoY);

            plot(xAVI(posIncInds(inLasso)),yAVI(posIncInds(inLasso)),'.r')

            fixp = input(['Found ' num2str(sum(inLasso)) ' points here, fix them? (y/n)>>'],'s');
            
            close(posFig);
            if strcmpi(fixp,'y')
                 framesFix = posIncInds(inLasso);
                 [xAVI,yAVI,definitelyGood] = CorrectManualFrames(obj,xAVI,yAVI,v0,definitelyGood,manCorrFig,framesFix,velThresh);
            end
            
        case 'v'
            [xAVI,yAVI, definitelyGood] = CorrectByVelocity...
                (xAVI,yAVI,onMaze,definitelyGood,velThresh,v0,obj,manCorrFig,posAndVelFig);
        case 's'
            SaveTemp;
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
                    close(tt);
                case 'number'
                    velThresh = input('What is the new velThresh?  >>');
            end 
            disp(['New velThresh is ' num2str(velThresh)])
            [posAndVelFig] = UpdatePosAndVel(xAVI,yAVI,onMaze,definitelyGood,velThresh,posAndVelFig);
        case 'r'
            disp('Set manCorrFig scaling')
            mcfScaleFactor = strdouble(input('Enter scale factor >> ','s'));
            mcfCurrentSize = mcfOriginalSize;
            mcfCurrentSize(3:4) = mcfCurrentSize(3:4)*mcfScaleFactor;
            manCorrFig = CheckManCorrFig(mcfCurrentSize,manCorrFig,v0);         %#ok<NASGU>
        case 'q'
            SaveTemp
            try %#ok<TRYNC>
                close(manCorrFig);
            end
            try %#ok<TRYNC>
                close(posAndVelFig);
            end 
            try %#ok<TRYNC>
                close(hb);
            end
            stillEditing = 0;
        otherwise 
            disp('Not a recognized input')
    end
end

    function SaveTemp
        save PosLED_temp.mat xAVI yAVI definitelyGood v0 dvtPos... 
            subMultRedX subMultRedY subMultGreenX subMultGreenY...
            Rbrightness Gbrightness calibrateFrames howRed howGreen...
            howRedThresh howGreenThresh anyRpix anyGpix...
            nRed nGreen redPix greenPix brightnessCalibrated...
            onMazeMask onMazeX onMazeY...
            onMaze behTable velThresh
        disp('Saved!')
    end

end
%%
function manCorrFig = CheckManCorrFig(mcfCurrentSize,manCorrFig,v0)
figsOpen = findall(0,'type','figure');
if length(figsOpen)~=0
isManCorr = strcmp({figsOpen.Name},'manCorrFig');
elseif length(figsOpen)==0
    isManCorr=0;
end

if sum(isManCorr)==1
    %We're good
elseif sum(isManCorr)==0
    manCorrFig = figure('Position',mcfCurrentSize,'name','manCorrFig');
    imagesc(v0); 
elseif sum(isManCorr) > 1
    manCorrInds = find(isManCorr);
    close(figsOpen(manCorrInds(2:end)))
    try
        clear(figsOpen(manCorrInds(2:end)))
    catch 
        disp('delete mancorrfigs did not work')
    end
end

end
%%
function [xAVI,yAVI,definitelyGood] = CorrectManualFrames(obj,xAVI,yAVI,v0,definitelyGood,manCorrFig,zeroFramesN,velThresh)
p = ProgressBar(length(zeroFramesN));
aviSR = obj.FrameRate;
zfI = 1;
while zfI < length(zeroFramesN)+1
    corrFrame = zeroFramesN(zfI);
    
    [obj,manCorrFig,xAVI,yAVI,definitelyGood,buttonClicked,zfI] = CorrectFrameManual(...
        corrFrame,obj,manCorrFig,xAVI,yAVI,definitelyGood,velThresh,zfI);
    
    if zfI == -5
        zfI = length(zeroFramesN)+1;
    end
    zfI = zfI + 1;
    
    p.progress;
end
p.stop;

end
%%
function [obj,manCorrFig,xAVI,yAVI,definitelyGood,buttonClicked,zfI] = CorrectFrameManual(...
            corrFrame,obj,manCorrFig,xAVI,yAVI,definitelyGood,velThresh,zfI)
aviSR = obj.FrameRate;

obj.CurrentTime = (corrFrame-1)/aviSR;
uFrame = readFrame(obj);
imagesc(manCorrFig.Children,uFrame);
title(manCorrFig.Children,['Frame # ' num2str(corrFrame) ', click here, right to accept current'])
hold(manCorrFig.Children,'on')
plot(manCorrFig.Children,xAVI(corrFrame),yAVI(corrFrame),'+r')
if (xAVI(corrFrame)==0) && (yAVI(corrFrame)==0)
    plot(manCorrFig.Children,20,20,'^r')
end
hold(manCorrFig.Children,'off')
    
figure(manCorrFig);
[xclick,yclick,buttonClicked] = ginput(1);
switch buttonClicked
    case 1
        xAVI(corrFrame) = xclick;
        yAVI(corrFrame) = yclick;
        definitelyGood(corrFrame) = 1;
        imagesc(manCorrFig.Children,uFrame);
        hold(manCorrFig.Children,'on')
        plot(manCorrFig.Children,xAVI(corrFrame),yAVI(corrFrame),'+g')
        hold(manCorrFig.Children,'off')
    case 3
        hold(manCorrFig.Children,'on')
        plot(manCorrFig.Children,xAVI(corrFrame),yAVI(corrFrame),'+g')
        hold(manCorrFig.Children,'off')
        definitelyGood(corrFrame) = 1;
    case 2
        midBut = questdlg('What do you want?','What','Go back','Stop','Jump to frame','Stop');
        switch midBut
            case 'Jump to frame'
                corrFrame = str2double(input('Which frame do you want? >> ','s'));
                
                obj.CurrentTime = (corrFrame-1)/aviSR;
                uFrame = readFrame(obj);
                imagesc(manCorrFig.Children,uFrame);
                title(['Frame # ' num2str(corrFrame) ', click here, right to accept current'])
                hold(manCorrFig.Children,'on')
                plot(manCorrFig.Children,xAVI(corrFrame),yAVI(corrFrame),'+r')
                plot(manCorrFig.Children,[30 30+velThresh],[50 50],'r')
                if (xAVI(corrFrame)==0) && (yAVI(corrFrame)==0)
                    plot(manCorrFig.Children,20,20,'^r')
                end
                hold(manCorrFig.Children,'off')
                
                figure(manCorrFig);
                [xclick,yclick,~] = ginput(1);
                xAVI(corrFrame) = xclick;
                yAVI(corrFrame) = yclick;
                definitelyGood(corrFrame) = 1;
                imagesc(manCorrFig.Children,uFrame);
                hold(manCorrFig.Children,'on')
                plot(manCorrFig.Children,xAVI(corrFrame),yAVI(corrFrame),'+g')
                hold(manCorrFig.Children,'off')
            case 'Go back'
                zfI = zfI - 1;
            case 'Stop'
                zfI = -5;
        end
end

end   
%%
function [redX, redY, greenX, greenY, allIndR, allIndG, anyRpix, anyGpix] = AutoCorrByLED(...
    manCorrFig, obj, corrFrame, onMazeX, onMazeY, onMazeMask, v0r, v0g, rawColorThresh,...
    howRedThresh, howGreenThresh, nBrightPoints)

%Get the frame to correct
aviSR = obj.FrameRate;
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
    
    rPixFrame = ufRthreshed.*onMazeMask;
    gPixFrame = ufGthreshed.*onMazeMask;
    
    anyRpix(corrFrame) = sum(sum(rPixFrame));
    anyGpix(corrFrame) = sum(sum(gPixFrame));
end

%Find the red and green LEDs
[allIndR,redX,redY] = GetBrightBlobPixels(rfRsub,nBrightPoints);
[allIndG,greenX,greenY] = GetBrightBlobPixels(rfGsub,nBrightPoints);

hold(manCorrFig.Children,'on')
plot(manCorrFig.Children,redX,redY,'or')
plot(manCorrFig.Children,greenX,greenY,'og')
hold(manCorrFig.Children,'off')

end
%%
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
%%
function [allIndX,colorX,colorY] = GetBrightBlobPixels(rfSubFrame,nBrightPoints)
frameSize = [size(rfSubFrame,1) size(rfSubFrame,2)];

%Find the 5 reddest/greenest points in the subtraction frame, see which is brightest 
[sortedSubVals, sortOrderSub] = sort(rfSubFrame(:),'descend'); %#ok<ASGLU>
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
%%
function [onMazeFinal,behTable] = parseOnMazeBehavior(xAVI,yAVI,v0,obj)
disp('parsing on mazeBehavior')
aviSR = obj.FrameRate;
%Find epochs of missing points based on expected plus maze behavior
ff = figure;
imagesc(v0);
title('Draw boundary for maze center')
figure(ff);
[~,centerX,centerY,] = roipoly;
inCenter = inpolygon(xAVI,yAVI,centerX,centerY);
close(ff);
%inCenter = inCenter';

nStartLocs = 2;
for slI = 1:nStartLocs
    ff = figure; imagesc(v0); title(['Draw boundary for start area ' num2str(slI)])
    [~,startX{slI},startY{slI}] = roipoly; %#ok<AGROW>
    close(ff);
end

nEndLocs = 2;
for elI = 1:nEndLocs
    ff = figure; imagesc(v0); title(['Draw boundary for end area ' num2str(elI)])
    [~,endX{elI},endY{elI}] = roipoly; %#ok<AGROW>
    close(ff);
end

disp('Now parsing maze center - arm end epochs')
minCenterDur = 2;

enterCenter = find(diff(inCenter) == 1);
leaveCenter = find(diff(inCenter) == -1)+1;

if size(enterCenter,1) == 1
    enterCenter = enterCenter';
end
if size(leaveCenter,1) == 1
    leaveCenter = leaveCenter';
end

outEpochs = [leaveCenter(1:end-1) enterCenter(2:end)];
outDurations = diff(outEpochs,1,2);

badEpochs = outDurations < minCenterDur; %unlikely to be real

enterCenter(logical([0; badEpochs])) = [];
leaveCenter(logical([badEpochs; 0])) = [];

offMazeMin = 10; %Minimum number of frames an entrance is separated from an exit to be considered real
%onMazeMin = 20;

behaviorMarker = inCenter;
behBoundsX = [startX, endX];
behBoundsY = [startY, endY];
bbsStartsEnds = [1*ones(1,nStartLocs) 2*ones(1,nEndLocs)];

for bbxI = 1:length(bbsStartsEnds)
    inHere = inpolygon(xAVI,yAVI,behBoundsX{bbxI},behBoundsY{bbxI});
    behaviorMarker = behaviorMarker+(1+bbxI)*inHere;
end
%behaviorMarker = behaviorMarker';

%Get entries/exits of maze arm ends, refine by duration
leaveArmEnd = find(diff([0; behaviorMarker]>1) == -1); %laeHold = leaveArmEnd;
enterArmEnd = find(diff([0; behaviorMarker]>1) == 1);  %  eaeHold = enterArmEnd;    

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

%{
realOnMazeDur = 0;
for ii = 1:size(handCoded,1)
    realOnMazeDur = realOnMazeDur + handCoded(ii,2) - handCoded(ii,1) + 1;
end
%}

%Check for leaveCenter - enterCenter where there's only one arm entry and
%exit
disp('Building behavior table')
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
                whichArmEnds(aeI) = mode(behaviorMarker(armEntries(aeI):armLeavings(aeI))); %#ok<AGROW>
            end
            
            sameAsFirst = whichArmEnds(2:end-1) == whichArmEnds(1);
            sameAsLast = whichArmEnds(2:end-1) == whichArmEnds(end);
            
            sharedFirstLast =  sum([sameAsFirst; sameAsLast],1)==2; %#ok<NASGU>
            
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
%Fill in last row
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

disp('Getting user input to refine off-maze time')
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
             usrApp = figure;%('Position',mcfOriginalSize);
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

disp('Final refinement of behavior')
%parse this all out into onmaze time
onMazeTable = behTable(:,[1 6]);
onMazeTableEditor = behTable(:,[2 6]);
%if theres a nan, delete the lap
%if there are still repeats but no nans, it's an ongoing lap, 
%    can delete for onmaze and just get the first enter through last leave
nanRows = isnan(onMazeTableEditor(:,1)) | isnan(onMazeTableEditor(:,2)); 
onMazeTable(nanRows,:) = [];
onMazeTableEditor(nanRows,:) = [];

%Find instances where there are shared entries across a lap (ongoing on maze)
lookmatches = [onMazeTableEditor(1:end-1,2) onMazeTableEditor(2:end,1)];
matchedInd = lookmatches(:,1) == lookmatches(:,2);

lookmatches(matchedInd,:) = []; %#ok<NASGU>

onMazeReArr = [onMazeTable(1:end-1,2) onMazeTable(2:end,1)];
onMazeReArr(matchedInd,:) = [];

onMazeFinal = [[onMazeTable(1,1); onMazeReArr(:,2)], [onMazeReArr(:,1); onMazeTable(end,2)]];

end
%%
function [posAndVelFig] = UpdatePosAndVel(xAVI,yAVI,onMaze,definitelyGood,velThresh,posAndVelFig)
border = 0.05;
boxHeight = (1-border*4) / 3;
boxWidth = 1-border*2;
plotOnMaze = onMaze; 
plotOnMaze(plotOnMaze==0) = NaN;
%defGoodWork = definitelyGood==0;

veloc = GetVelocity(xAVI,yAVI,[],onMaze);
%veloc = hypot(diff(xAVI.*plotOnMaze,1),diff(yAVI.*plotOnMaze,1));

figsOpen = findall(0,'type','figure');
if length(figsOpen)~=0
isPosVel = strcmp({figsOpen.Name},'posAndVelFig');
elseif length(figsOpen)==0
    isPosVel=0;
end

if sum(isPosVel)==1
    %We're good
    posAndVelFig = figsOpen(isPosVel);
elseif sum(isPosVel)==0
    posAndVelFig = figure('Position',[267 152 1582 758],'Name','posAndVelFig'); 
elseif sum(isPosVel) > 1
    manCorrInds = find(isPosVel);
    close(figsOpen(manCorrInds(2:end)))
    try
        clear(figsOpen(manCorrInds(2:end)))
    catch 
        disp('delete posvelfigs did not work')
    end
end

figure(posAndVelFig);
subplot('Position',[border border*3+boxHeight*2 boxWidth boxHeight])
plot(xAVI.*plotOnMaze)
title('X position'); %xlabel('Frame Number')
subplot('Position',[border border*2+boxHeight*1 boxWidth boxHeight])
plot(yAVI.*plotOnMaze)
title('Y position'); %xlabel('Frame Number')
subplot('Position',[border border*1+boxHeight*0 boxWidth boxHeight])
plot(veloc)
hold on
plot([1 length(veloc)],[velThresh velThresh],'r')
badVel = veloc > velThresh;
fn = 1:length(badVel);
plot(fn(badVel),veloc(badVel),'or')
title('Velocity'); xlabel('Frame Number')
hold off

end
%%
function veloc = GetVelocity(xAVI,yAVI,windowSearch,onMaze)
if isempty(onMaze)
    onMaze = ones(size(xAVI,1),size(xAVI,2));
end
if isempty(windowSearch)
    windowSearch = ones(size(xAVI,1),size(xAVI,2));
end
onMazeWork = onMaze(1:end-1) | onMaze(2:end);
windowWork = windowSearch(1:end-1) | windowSearch(2:end);

%onMazeWork(onMazeWork==0) = NaN;

veloc = hypot(diff(xAVI),diff(yAVI)).*onMazeWork.*windowWork;
    

end
%%
function [xAVI,yAVI, definitelyGood] = CorrectByVelocity(xAVI,yAVI,onMaze,definitelyGood,velThresh,v0,obj,manCorrFig,posAndVelFig)
aviSR = obj.FrameRate;


posAndVelFig = UpdatePosAndVel(xAVI,yAVI,onMaze,definitelyGood, velThresh,posAndVelFig);

velChoice = questdlg('How to pick high velocity frames?','Pick High Vel',...
                        'Whole Session','Select Window','First 100','Whole Session');
windowSearch = false(size(xAVI,1),size(xAVI,2));
framesManVeled = 0;
switch velChoice
    case 'Whole Session'
        windowSearch(:) = true;
        limitToHundredClicks = 0;
    case 'Select Window'
        [posAndVelFig] = UpdatePosAndVel(xAVI,yAVI,onMaze,definitelyGood,velThresh,posAndVelFig); 
        figure(posAndVelFig);
        [windowLims,~] = ginput(2);
        windowLims = round(windowLims);
        winStart = max([min(windowLims) 1]);
        winStop = min([max(windowLims) length(xAVI)]);
        
        windowSearch(winStart:winStop) = true;
        
        limitToHundredClicks = 0;
        
        disp(['Now editing from ' num2str(winStart) ' to ' num2str(winStop)])
    case 'First 100'
        windowSearch(:) = true;
        limitToHundredClicks = 1;
end

doneVel = 0;
%Ask about range to look for bad points
manChoice = questdlg('Redo definitely good frames?','Redo DefGood',...
                    'Yes','No','Cancel','Yes');
switch manChoice; case 'Yes'; skipDefGood = 0; case 'No'; skipDefGood = 1; case 'Cancel'; doneVel = 1; end



while doneVel == 0
    veloc = GetVelocity(xAVI,yAVI,windowSearch,onMaze);
    
    badVel = veloc > velThresh;
    if skipDefGood==1
        skdg = definitelyGood(1:end-1) & definitelyGood(2:end);
        badVel(skdg) = 0;
    end
            
    triedVel = zeros(length(xAVI),1);
    
    if sum(badVel)==0
        doneVel = 1;
        disp('Found no more high velocity points')
    elseif sum(badVel) > 0
        disp(['Found ' num2str(sum(badVel)) ' points above velocity threshold'])
        %Try to find a frame to correct
        
        %defGoodWork = definitelyGood==0;
        anyBadVel = 1;
        while anyBadVel == 1
            skipCorr = 0;
            
            frameTry = find(badVel,1,'first');
            
            %Check how much we've tried to do this, figure out frames to try
            if triedVel(frameTry)==1
                disp(['tried ' num2str(frameTry) ' once'])
                if triedVel(frameTry+1) < 1
                    frameTry = frameTry + 1;
                else
                    disp(['tried one after ' num2str(frameTry) ' once'])
                    if triedVel(frameTry-1) < 1
                    frameTry = frameTry - 1;
                    else
                        disp(['tried one before ' num2str(frameTry) ' once'])
                        if triedVel(frameTry+1) >= 1 && triedVel(frameTry-1) >= 1
                            frameTry = (frameTry-1):(frameTry+1); 
                        end
                    end
                end
            elseif triedVel(frameTry)==2    
                disp('tried twice, trying prev/next')
                triedVel(frameTry) = triedVel(frameTry)+1;
                frameTry = [frameTry-1 frameTry frameTry+1];
            elseif triedVel(frameTry)>2
                disp(['tried this frame ' num2str(triedVel(frameTry)) ' times'])
                tooManyCorrs = questdlg(['Tried this frame ' num2str(triedVel(frameTry)) ' times, what now?'],...
                    'what now?','Try again','+/- nFrames','StopV','Try again');
                switch tooManyCorrs
                    case 'Try again'
                        %Do nothing
                    case '+/- nFrames'
                        framesCheck = str2double(input('How many frames forward and back?','s'));
                        frameTry = (frameTry-framesCheck):(frameTry+framesCheck);
                    case 'StopV'
                        skipCorr = 1;
                        anyBadVel = 0;
                end
            end

            if skipCorr == 0
                ftI = 1;
                while ftI < length(frameTry)+1
                    corrFrame = frameTry(ftI);

                    [obj,manCorrFig,xAVI,yAVI,definitelyGood,buttonClicked,zfI] = CorrectFrameManual(...
                        corrFrame,obj,manCorrFig,xAVI,yAVI,definitelyGood,velThresh,[]);         
                    
                    skipRest = 0;
                    if zfI == -5
                        anyBadVel = 0;
                        skipCorr = 1;
                        skipRest = 1;
                        doneVel=1;
                    end

                    triedVel(corrFrame) = triedVel(corrFrame)+1;
                    
                    if skipRest == 0
                        if buttonClicked==1 || buttonClicked==3
                            framesManVeled = framesManVeled + 1;
                        end

                        %Re-check velocity
                        %veloc = hypot(diff(xAVI.*onMazeWork.*windowSearch,1),diff(yAVI.*onMazeWork.*windowSearch,1));
                        veloc = GetVelocity(xAVI,yAVI,windowSearch,onMaze);
                        badVel = veloc > velThresh;
                        if skipDefGood==1
                            skdg = definitelyGood(1:end-1) & definitelyGood(2:end);
                            badVel(skdg) = 0;
                        end
                        if sum(badVel) == 0
                            anyBadVel = 0;
                            doneVel = 1;
                        elseif sum(badVel) > 0
                            anyBadVel = 1;
                        end

                        if limitToHundredClicks==1
                            if framesManVeled>=100
                                anyBadVel = 0;
                                badVel = 0;
                                doneVel = 1;
                            end
                        end
                    end 
                    ftI = ftI + 1;
                end
            elseif skipCorr == 1
                anyBadVel = 0;
                badVel = 0;
                doneVel = 1;
            end
        end
    end        
end
        
end
%% 
 %This is an attempt at automatically solving high velocity frames
        %using data from the dvt files or individual color channels
        %{
        
        triedVel = zeros(length(veloc),1);
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
        %}
%%
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
  %%      
function FrameTrackingViewer(v0,obj,startFrame,xAVI,yAVI)





end
%%

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