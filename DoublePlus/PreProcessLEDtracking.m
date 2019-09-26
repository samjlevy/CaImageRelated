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
%nFrames = round(obj.Duration*aviSR);  
frameSize = [obj.Height obj.Width];
DVTtime = [];
nFrames = [];
mcfScaleFactor = 1;
mcfOriginalSize = [680 558 560 420];
DVTtoAVIscale = 0.6246;
dvtPos = []; 
%Pre-allocate stuff
velThresh = 25;
calFrameN = [];
lapParsed = []; scalingX = []; v0anchor = [];
numOffmaze = []; scalingY = []; xAlign = []; yAlign = [];

startFresh = 0;
posFiles = ls('*PosLED_temp.mat');
%posFile =fullfile(cd,'*PosLED_temp.mat');
if size(posFiles,1)==1
    posFile = posFiles;
    if exist(posFile,'file')==2
        loadedFilepath = load(posFile,'avi_filepath');
        usePos = questdlg(['Found a PosLED_temp.mat, - ' posFile '-, associated AVI is - ' loadedFilepath.avi_filepath...
            '-; want to use it?'],'Use found pos',...
                        'Yes','No, start over','Yes');
        if strcmp(usePos,'Yes')
            load(posFile) %#ok<LOAD>
        else 
            startFresh = 1;
        end
    else
        disp('Did not find existing xxxxxx_PosLED_temp.mat, starting fresh')
        filePrefix = input('Enter a name (prefix) for this file (animal, date): ','s');
        posFile = [filePrefix '_PosLED_temp.mat'];
        startFresh = 1;
    end
elseif length(posFiles)==0
    disp('Did not find existing xxxxxx_PosLED_temp.mat, starting fresh')
    filePrefix = input('Enter a name (prefix) for this file (animal, date): ','s');
    posFile = [filePrefix '_PosLED_temp.mat'];
    startFresh = 1;
elseif size(posFiles,1)>1
    disp('found more than one pos file?')
    dbstop
end

if isempty(dvtPos)
doneDVTs = 0; dd = 1;
while doneDVTs == 0
    [DVTfile, DVTpath] = uigetfile('*.DVT', 'Select DVT file');
    filepath = fullfile(DVTpath, DVTfile);

    pos_data{dd} = importdata(filepath); %#ok<AGROW>
    
    dvtPos{dd}.redX = pos_data{dd}(:,5)*DVTtoAVIscale; %#ok<AGROW>
    dvtPos{dd}.redY = pos_data{dd}(:,6)*DVTtoAVIscale; %#ok<AGROW>
    dvtPos{dd}.redY = frameSize(1) - dvtPos{dd}.redY; %#ok<AGROW>
    dvtPos{dd}.greenX = pos_data{dd}(:,3)*DVTtoAVIscale; %#ok<AGROW>
    dvtPos{dd}.greenY = pos_data{dd}(:,4)*DVTtoAVIscale; %#ok<AGROW>
    dvtPos{dd}.greenY = frameSize(1) - dvtPos{dd}.greenY; %#ok<AGROW>

    dvtPos{dd}.redX( dvtPos{dd}.redX==0 & dvtPos{dd}.redY==0 ) = NaN; %#ok<AGROW>
    dvtPos{dd}.redY( dvtPos{dd}.redX==0 & dvtPos{dd}.redY==0 ) = NaN; %#ok<AGROW>
    if dd == 1
        DVTtime = pos_data{dd}(:,2);
        nFrames = length(DVTtime);
    end
    
    ss = questdlg('Load another DVT?','Load DVT','Yes','No','Yes');
    if strcmpi(ss,'No')
        doneDVTs = 1;
    else
        dd = dd+1;
    end 
end
end

%Check this file might be ok
if abs(obj.Duration*obj.FrameRate - length(dvtPos{1}.redX)) > 10
    disp('More than 10 frames difference between video length and steps in DVT')
    disp('Please check that these files go together')
    dbstop
end

if startFresh == 1
    xAVI = zeros(nFrames,1);
    yAVI = zeros(nFrames,1);
    definitelyGood = false(size(xAVI,1),size(xAVI,2));
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
    howRed = []; howGreen = []; redPix = []; greenPix = []; brightnessCalibrated = [];
    howRedThresh = 175; howGreenThresh = 210;
    anyRpix = []; anyGpix = [];
    onMaze = ones(size(xAVI,1),size(xAVI,2)); behTable = [];
    calibrateFrames = [];
end
            
[v0] = AdjustWithBackgroundImage(avi_filepath, obj, v0);

SaveTemp;

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
    reca = questdlg(['Brightness is calibrated, r = ' num2str(howRedThresh), 'g = ' num2str(howGreenThresh) '. Use or recalibrate?'],'Recal','Use','Recalibrate','Use');
    if strcmpi(reca,'Recalibrate')
        brightnessCalibrated = 0;
    end
end

if brightnessCalibrated == 0
    [howRedThresh,howGreenThresh,calibrateFrames] = CelibrateLEDbrightness(nFrames,obj,aviSR,avi_filepath,xAVI,v0r, v0g, onMazeMask,frameSize,nBrightPoints);
    brightnessCalibrated = 1;
end

%if howRedThresh < 175
    chR = input(['Red thresh now is ' num2str(howRedThresh) ', default is 175. Change now? (y/n)>>'],'s');
    if strcmpi(chR,'y')
        howRedThresh = str2double(input('Enter new RED thresh value:','s'));
    end
%end

%if howGreenThresh < 210
    chG = input(['Green thresh now is ' num2str(howGreenThresh) ', default is 210. Change now? (y/n)>>'],'s');
    if strcmpi(chG,'y')
        howGreenThresh = str2double(input('Enter new GREEN thresh value:','s'));
    end
%end
        


mcfCurrentSize = mcfOriginalSize;
mcfCurrentSize(3:4) = mcfCurrentSize(3:4)*mcfScaleFactor;
manCorrFig = figure('Position',mcfCurrentSize,'name','manCorrFig');
imagesc(v0); 
SaveTemp;
%{
firstPass = questdlg('Want to do auto tracking by LEDs?','Auto track?','Yes','No','Yes');
if strcmpi(firstPass,'Yes')

SaveTemp;
end
%}
optionsText = {'m - mark off maze time';...
    'z - fix (0,0) frames';...
    'b - parse onMaze time';...
    'r - scale mancorrfig';...
    'p - correct by position';...
    'v - correct by velocity';...
    't - reset velocity threshold';...
    'n - edit by frame number';...
    'f - make new background frame';...
    'a - correct frames auto';...
    'g - reset brightness thresholds';...
    'w - open video player';...
    'd - sub in DVT frames';...
    ' ';...
    's - save';...
    'q - save and quit';...
    };
hb = msgbox(optionsText,'PreProcess Keys');

%Here is where user decides how to correct things here on out
[posAndVelFig] = PreProcUpdatePosAndVel(xAVI,yAVI,onMaze,definitelyGood,velThresh,[]);
stillEditing = 1;
while stillEditing == 1
    posAndVelFig = PreProcUpdatePosAndVel(xAVI,yAVI,onMaze,definitelyGood, velThresh,posAndVelFig);
    manCorrFig = CheckManCorrFig(mcfCurrentSize,manCorrFig,v0);
    mcfCurrentSize = manCorrFig.Position;
    editChoice = input('How would you like to edit? >>','s');
    switch editChoice
        case 'd'
            windowUse = input('Which frames to sub in for? enter w (whole session), s (select window), or 2 numbers for frame range >> ','s')
            if strcmpi(windowUse,'w')
                subLimits = [1 length(xAVI)];
            elseif strcmpi(windowUse,'s')
                figure(posAndVelFig);
                [answerX,~] = ginput(2);
                subLimits(1) = max([0 min(round(answerX))]);
                subLimits(2) = min([length(xAVI) max(round(answerX))]);
            elseif length(str2num(windowUse))==2
                subLimits = str2num(windowUse);
            end
            subLimLog = false(length(xAVI),1);
            subLimLog(subLimits(1):subLimits(2)) = true;
            
            doneSubbing = 0;
            while doneSubbing == 0
                colFilt = questdlg('Which channel points use?','DVT color','Green','Red','MeanWhereBoth','Green');
                
                dvtUse = 1;
                if length(dvtPos)>1
                    dvtUse = str2num(input(['Found ' num2str(length(dvtUse)) ' DVT files, enter number of which to use >> '],'s'))
                end
                otherLogical = ones(length(dvtPos{dvtUse}.greenX),1);
                switch colFilt
                    case 'Green'
                        subInX = dvtPos{dvtUse}.greenX;
                        subInY = dvtPos{dvtUse}.greenY;
                        otherLogical = (dvtPos{dvtUse}.greenX~=0);
                    case 'Red'
                        subInX = dvtPos{dvtUse}.redX;
                        subInY = dvtPos{dvtUse}.redY; 
                        otherLogical = (dvtPos{dvtUse}.redX~=0);
                    case 'MeanWhereBoth'
                        subInX = mean([dvtPos{dvtUse}.greenX(:) dvtPos{dvtUse}.redX(:)],2);
                        subInY = mean([dvtPos{dvtUse}.greenY(:) dvtPos{dvtUse}.redY(:)],2);
                        otherLogical = (dvtPos{dvtUse}.greenX~=0) & (dvtPos{dvtUse}.redX~=0);
                end
                
                %donePosFilt = 0;
                %while donePosFilt == 0
                    posFilt = input('Filter these points by position? (y/n) >> ','s')
                    if strcmpi(posFilt,'y')
                        aa = figure; imagesc(v0);
                        hold on
                        plot(subInX(subLimLog & otherLogical),subInY(subLimLog & otherLogical),'.')
                    end
                    [~,pfX,pfY] = roipoly([]);
                    
                    [inPF,~] = inpolygon(subInX,subInY,pfX,pfY);
                    inPFall = inPF & otherLogical & subLimLog;
                    plot(subInX(subLimLog & otherLogical & inPF),subInY(subLimLog & otherLogical & inPF),'.g')
                    inEx = questdlg('Inlucde or exclude these points?','In or out','Include','Exclude','Include');
                    
                    switch inEx
                        case 'Include'
                            inPolyUse = inPFall;
                        case 'Exclude'
                            inPolyUse = ~inPF & otherLogical & subLimLog;
                    end
                    
                    subAll = input('Sub in these points for all frames (a) or just zeros (z) >> ','s')
                    if strcmpi(subAll,'z')
                        onlyzeros = (xAVI==0) & (yAVI==0);
                        inPolyUse = inPolyUse & onlyzeros;
                    end
                    
                    xAVI(inPolyUse) = subInX(inPolyUse);
                    yAVI(inPolyUse) = subInY(inPolyUse);
                    
                %    doneHere = input('Done filtering by position (d) or do another round (r) >> ','s')
                     
                %    if strcmpi(doneHere,'d')
                %        donePosFilt = 1;
                %    end
                %end
                
                doneSubCheck = input('Done subbing in DVT positions (d) or do it again (a) >> ','s')
                if strcmpi(doneSubCheck,'d')
                    doneSubbing = 1;
                end
            end
            
        case 'w'
            h1 = implay(avi_filepath);
            ddd = input('Input y when done with video: ','s');
            while ~strcmpi(ddd,'y')
                ddd = input('Input y when done with video: ','s');
            end
            if strcmpi(ddd,'y')
                try
                    close(h1);
                end
            end
        case 'a' 
            [manCorrFig, obj, xAVI, yAVI, nRed,nGreen,redPix,greenPix,...
                subMultRedX,subMultRedY,subMultGreenX,subMultGreenY,anyRpix,anyGpix]...
                = AutoCorrByLEDWrapper(...
                posAndVelFig,manCorrFig, mcfCurrentSize, obj, onMazeX, onMazeY, onMazeMask, v0r, v0g, v0,...
                howRedThresh, howGreenThresh, nBrightPoints, xAVI, yAVI, nFrames,...
                nRed,nGreen,redPix,greenPix,subMultRedX,subMultRedY,subMultGreenX,subMultGreenY,anyRpix,anyGpix);
        case 'f'
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
        case 'g'
            [howRedThresh,howGreenThresh,calibrateFrames] = CelibrateLEDbrightness(nFrames,obj,aviSR,avi_filepath,xAVI,v0r, v0g, onMazeMask,frameSize,nBrightPoints);
            brightnessCalibrated = 1;
        case 'z'
            zero_frames = xAVI==0 & yAVI==0;
            disp(['Found ' num2str(sum(zero_frames)) ' zero frames'])
            refOM = questdlg('Only edit onMaze?','rom','Yes','No','Yes');
            if strcmpi(refOM,'Yes') 
                zero_frames(onMaze==0) = 0;
                disp(['Now have ' num2str(sum(zero_frames)) ' zero frames'])
            end
            redDG = questdlg('Re-do definitely good?','rdg','Yes','No','Yes');
            if strcmpi(redDG,'No')
                zero_frames(definitelyGood) = 0;
                disp(['Now have ' num2str(sum(zero_frames)) ' zero frames'])
            end
            
            framesFix = find(zero_frames);
            [xAVI,yAVI,definitelyGood] = CorrectManualFrames(obj,xAVI,yAVI,v0,...
                definitelyGood,manCorrFig,framesFix,velThresh);
            
            disp('Done zero frames correction')
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
                        
            %howEdit = questdlg(['Edit these ' num2str(length(framesFix)) ' frames?'],'Edit',...
            %           'Auto','Manual','Cancel','Auto'); 
            
            [xAVI,yAVI,definitelyGood] = CorrectManualFrames(obj,xAVI,yAVI,v0,...
                definitelyGood,manCorrFig,framesFix,velThresh);
            
        case 'm'
            onoroff = questdlg('Mark on-maze or off-maze?','Oh, Hi Mark','ON','OFF','OFF');
            omStart = str2double(input(['Mark ' onoroff '-maze start frame: '],'s'));
            omEnd = str2double(input(['Mark ' onoroff '-maze stop frame: '],'s'));
            doIt = input(['Marking ' num2str(omStart) ' through ' num2str(omEnd) ' as ' onoroff ', yes? (y/n)'],'s');
            if strcmpi(doIt,'y')
            switch onoroff
                case 'ON'
                    onMaze(omStart:omEnd) = 1;
                case 'OFF'
                    onMaze(omStart:omEnd) = 0;
            end
            end
        case 'b'
            lop = questdlg('Load behTable or parse positions?','Load or parse','Load','Parse','Parse');
            switch lop
                case 'Parse'
                    [onMazeFinal,behTable] = PreProcParseOnMazeBehavior(xAVI,yAVI,v0,obj);
                case 'Load'
                    [fileN, folderN] = uigetfile('*.mat','Choose the behTable file');
                    load(fullfile(folderN,fileN),'onMazeFinal')
            end
            
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
                 howFix = questdlg('How do you want to fix these?','How fix','Auto','Manual','Auto');
                 switch howFix
                     case 'Auto'
                         [manCorrFig, obj, xAVI, yAVI, nRed,nGreen,redPix,greenPix,...
                            subMultRedX,subMultRedY,subMultGreenX,subMultGreenY,anyRpix,anyGpix]...
                            = ReallyAutoCorrByLEDWrapper(framesFix,...
                            manCorrFig, mcfCurrentSize, obj, onMazeX, onMazeY, onMazeMask, v0r, v0g, v0,...
                            howRedThresh, howGreenThresh, nBrightPoints, xAVI, yAVI, nFrames,...
                            nRed,nGreen,redPix,greenPix,subMultRedX,subMultRedY,subMultGreenX,subMultGreenY,anyRpix,anyGpix);
                     case 'Manual'
                         [xAVI,yAVI,definitelyGood] = CorrectManualFrames(...
                             obj,xAVI,yAVI,v0,definitelyGood,manCorrFig,framesFix,velThresh);
                 end
            end
            
        case 'v'
            [xAVI,yAVI, definitelyGood] = PreProcCorrectByVelocity...
                (xAVI,yAVI,onMaze,definitelyGood,velThresh,v0,obj,manCorrFig,posAndVelFig);
        case 's'
            SaveTemp;
        case 't'
            threshEdit = questdlg(...
                ['Current is ' num2str(velThresh) '. How to edit velocity threshold?'],...
                'Edit vel thresh', 'ginput','number','ginput');
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
            [posAndVelFig] = PreProcUpdatePosAndVel(xAVI,yAVI,onMaze,definitelyGood,velThresh,posAndVelFig);
        case 'r'
            disp('Set manCorrFig scaling')
            mcfScaleFactor = strdouble(input('Enter scale factor >> ','s'));
            mcfCurrentSize = mcfOriginalSize;
            mcfCurrentSize(3:4) = mcfCurrentSize(3:4)*mcfScaleFactor;
            manCorrFig = CheckManCorrFig(mcfCurrentSize,manCorrFig,v0);       
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
            pbs = ls('progressbar_*.txt');
            pbd = [];
            for pp = 1:size(pbs,1)
                pbd{pp} = pbs(pp,1:end);
                delete(fullfile(cd,pbd{pp}))
            end
            
            stillEditing = 0;
        otherwise 
            disp('Not a recognized input')
    end
end

    function SaveTemp
        save(posFile, 'xAVI', 'yAVI', 'definitelyGood', 'v0', 'dvtPos',... 
            'subMultRedX','subMultRedY','subMultGreenX','subMultGreenY',...
            'Rbrightness','Gbrightness','calibrateFrames','howRed','howGreen',...
            'howRedThresh','howGreenThresh','anyRpix','anyGpix',...
            'nRed','nGreen','redPix','greenPix','brightnessCalibrated',...
            'onMazeMask','onMazeX','onMazeY',...
            'onMaze','behTable','velThresh','DVTtime','nFrames','avi_filepath')
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
function [xAVI,yAVI,definitelyGood] = CorrectManualFrames(obj,xAVI,yAVI,v0,...
    definitelyGood,manCorrFig,zeroFramesN,velThresh)
p = ProgressBar(length(zeroFramesN));
aviSR = obj.FrameRate;
zfI = 1;
while zfI < length(zeroFramesN)+1
    corrFrame = zeroFramesN(zfI);
    
    [obj,manCorrFig,xAVI,yAVI,definitelyGood,buttonClicked,zfI] = PreProcCorrectFrameManual(...
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
function [redX, redY, greenX, greenY, allIndR, allIndG, anyRpix, anyGpix] = AutoCorrByLED(...
    manCorrFig, obj, corrFrame, onMazeX, onMazeY, onMazeMask, v0r, v0g, rawColorThresh,...
    howRedThresh, howGreenThresh, nBrightPoints)

%Get the frame to correct
aviSR = obj.FrameRate;
obj.CurrentTime = (corrFrame-1)/aviSR;
uFrame = readFrame(obj);

%Do some friendly UI stuff

imagesc(manCorrFig.Children,uFrame);
title(manCorrFig.Children,['Frame# ' num2str(corrFrame)])

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
function [howRedThresh,howGreenThresh,calibrateFrames] = CelibrateLEDbrightness(nFrames,obj,aviSR,avi_filepath,xAVI,v0r, v0g, onMazeMask,frameSize,nBrightPoints)

%Get frames with mouse on the maze, ideally throughout the session
nTestFrames = 8;
framesUseForCalibrate = [1 nFrames];
frameIn = input(['Current frames for calibration are ' num2str(framesUseForCalibrate) ', enter y to use or enter 2 numbers to set new: '],'s')
if strcmpi(frameIn,'y') || isempty(frameIn)
    fStart = framesUseForCalibrate(1);
    fStop = framesUseForCalibrate(end);
elseif length(str2num(frameIn))==2
    ffs = str2num(frameIn);
    fStart = ffs(1);
    fStop = ffs(end);
end

tfEdges = linspace(fStart,fStop,nTestFrames+1);
%Look at the brightness value for red and green leds
for tfI = 1:nTestFrames
    %Get the random frame
    mouseInFrame = 0;
    while mouseInFrame == 0
        rFrameNum = randi(round(tfEdges(tfI+1) - (tfEdges(tfI)-1))) + tfEdges(tfI);
        obj.CurrentTime = (rFrameNum-1)/aviSR;
        uFrame = readFrame(obj);
        gg = figure; imagesc(uFrame)
        ss = input('Is the mouse somewhere good in this frame? (y/n, m movie) >>','s') %#ok<NOPRT>
        switch ss
            case 'y'
                mouseInFrame=1;
            case 'm'
                h1 = implay(avi_filepath);
                rFrameNum = 0;
                while rFrameNum > length(xAVI) || rFrameNum < 1
                    rFrameNum = round(str2double(input(['Please give a frame number between ' num2str(tfEdges(tfI)) ' and '...
                        num2str(tfEdges(tfI+1)) '. >>'],'s')));
                end
                mouseInFrame = 1;
                close(h1);
                obj.CurrentTime = (rFrameNum-1)/aviSR;
                uFrame = readFrame(obj);
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

rMeans = cell2mat(cellfun(@mean,howRed,'UniformOutput',false));
gMeans = cell2mat(cellfun(@mean,howGreen,'UniformOutput',false));

howRedThresh =  mean(rMeans) - 1.5*std(rMeans); %Use in raw frame
howGreenThresh = mean(gMeans) - 2*std(gMeans); %Use in raw frame

end

%%
function [manCorrFig, obj, xAVI, yAVI, nRed,nGreen,redPix,greenPix,...
    subMultRedX,subMultRedY,subMultGreenX,subMultGreenY,anyRpix,anyGpix]...
    = AutoCorrByLEDWrapper(...
    posAndVelFig,manCorrFig, mcfCurrentSize, obj, onMazeX, onMazeY, onMazeMask, v0r, v0g, v0,...
    howRedThresh, howGreenThresh, nBrightPoints, xAVI, yAVI, nFrames,...
    nRed,nGreen,redPix,greenPix,subMultRedX,subMultRedY,subMultGreenX,subMultGreenY,anyRpix,anyGpix)
    
manCorrFig = CheckManCorrFig(mcfCurrentSize,manCorrFig,v0);

framesUseForAuto = [1 nFrames];
frameIn = input(['Current frames for auto correction are ' num2str(framesUseForAuto) ', enter y to use, w for window select, or enter 2 numbers to set new: '],'s')
if strcmpi(frameIn,'y')
    fStart = framesUseForAuto(1);
    fStop = framesUseForAuto(end);
elseif strcmpi(frameIn,'w')
    figure(posAndVelFig);
    [windowLims,~] = ginput(2);
    windowLims = round(windowLims);
    winStart = max([min(windowLims) 1]);
    winStop = min([max(windowLims) length(xAVI)]);
elseif length(str2num(frameIn))==2
    ffs = str2num(frameIn);
    fStart = ffs(1);
    fStop = ffs(end);
end

fixTheseFrames = fStart:fStop;

[manCorrFig, obj, xAVI, yAVI, nRed,nGreen,redPix,greenPix,...
    subMultRedX,subMultRedY,subMultGreenX,subMultGreenY,anyRpix,anyGpix]...
    = ReallyAutoCorrByLEDWrapper(fixTheseFrames,...
    manCorrFig, mcfCurrentSize, obj, onMazeX, onMazeY, onMazeMask, v0r, v0g, v0,...
    howRedThresh, howGreenThresh, nBrightPoints, xAVI, yAVI, nFrames,...
    nRed,nGreen,redPix,greenPix,subMultRedX,subMultRedY,subMultGreenX,subMultGreenY,anyRpix,anyGpix);
end

%%
function [manCorrFig, obj, xAVI, yAVI, nRed,nGreen,redPix,greenPix,...
    subMultRedX,subMultRedY,subMultGreenX,subMultGreenY,anyRpix,anyGpix]...
    = ReallyAutoCorrByLEDWrapper(fixTheseFrames,...
    manCorrFig, mcfCurrentSize, obj, onMazeX, onMazeY, onMazeMask, v0r, v0g, v0,...
    howRedThresh, howGreenThresh, nBrightPoints, xAVI, yAVI, nFrames,...
    nRed,nGreen,redPix,greenPix,subMultRedX,subMultRedY,subMultGreenX,subMultGreenY,anyRpix,anyGpix)

%imagesc(v0)
rawColorThresh = 1;
%First pass just correct all the frames
p = ProgressBar(length(fixTheseFrames));
for corrFrameI = 1:length(fixTheseFrames)
    corrFrame = fixTheseFrames(corrFrameI);
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

haveRedX = ~isnan(subMultRedX(fixTheseFrames));
haveRedY = ~isnan(subMultRedY(fixTheseFrames));
haveRedBoth = (haveRedX+haveRedY)==2;

haveGreenX = ~isnan(subMultGreenX(fixTheseFrames));
haveGreenY = ~isnan(subMultGreenY(fixTheseFrames));
haveGreenBoth = (haveGreenX+haveGreenY)==2;

haveBothColors = (haveRedBoth + haveGreenBoth) == 2;

%Check dist between red and green isn't too high
rgDistMax = 20;
bothColorDist = hypot(diff([subMultRedX(fixTheseFrames) subMultGreenX(fixTheseFrames)],1,2),diff([subMultRedY(fixTheseFrames) subMultGreenY(fixTheseFrames)],1,2));
badDist = bothColorDist > rgDistMax;
haveBothColors(badDist) = 0;
subInGreen = badDist & haveGreenBoth;

haveRedOnly = ((haveRedBoth + haveGreenBoth) == 1) & haveRedBoth;
haveGreenOnly = ((haveRedBoth + haveGreenBoth) == 1) & haveGreenBoth;

haveColorData = haveRedBoth | haveGreenBoth;
missingPoints = haveColorData == 0; %#ok<NASGU>
%sum([sum(haveBothColors) sum(haveRedOnly) sum(haveGreenOnly)]) == sum((haveRedBoth + haveGreenBoth) > 0)

velRed = hypot(diff(subMultRedX,1),diff(subMultRedY,1)); %#ok<NASGU>
velGreen = hypot(diff(subMultGreenX,1),diff(subMultGreenY,1)); %#ok<NASGU>

%Fill in where we have color information
xAVI(fixTheseFrames(haveBothColors)) = mean([subMultRedX(fixTheseFrames(haveBothColors)) subMultGreenX(fixTheseFrames(haveBothColors))],2);
yAVI(fixTheseFrames(haveBothColors)) = mean([subMultRedY(fixTheseFrames(haveBothColors)) subMultGreenY(fixTheseFrames(haveBothColors))],2);
xAVI(fixTheseFrames(subInGreen)) = subMultGreenX(fixTheseFrames(subInGreen));
yAVI(fixTheseFrames(subInGreen)) = subMultGreenY(fixTheseFrames(subInGreen));

%Check points aren't off maze
goodPts = inpolygon(xAVI(fixTheseFrames),yAVI(fixTheseFrames),[onMazeX; onMazeX(1)],[onMazeY; onMazeY(1)]);
badPts = goodPts==0;
badPts(xAVI(fixTheseFrames)==0 & yAVI(fixTheseFrames)==0) = 0;
xAVI(fixTheseFrames(badPts & haveGreenBoth)) = subMultGreenX(fixTheseFrames(badPts & haveGreenBoth));
yAVI(fixTheseFrames(badPts & haveGreenBoth)) = subMultGreenY(fixTheseFrames(badPts & haveGreenBoth));

%Fill in the rest
goodRed = inpolygon(subMultRedX(fixTheseFrames),subMultRedY(fixTheseFrames),[onMazeX; onMazeX(1)],[onMazeY; onMazeY(1)]);
xAVI(fixTheseFrames(haveRedOnly & goodRed)) = subMultRedX(fixTheseFrames(haveRedOnly & goodRed));
yAVI(fixTheseFrames(haveRedOnly & goodRed)) = subMultRedY(fixTheseFrames(haveRedOnly & goodRed));
goodGreen = inpolygon(subMultGreenX(fixTheseFrames),subMultGreenY(fixTheseFrames),[onMazeX; onMazeX(1)],[onMazeY; onMazeY(1)]);
xAVI(fixTheseFrames(haveGreenOnly & goodGreen)) = subMultGreenX(fixTheseFrames(haveGreenOnly & goodGreen));
yAVI(fixTheseFrames(haveGreenOnly & goodGreen)) = subMultGreenY(fixTheseFrames(haveGreenOnly & goodGreen));

end