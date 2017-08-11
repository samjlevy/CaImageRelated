function PreProcessMousePosition_autoSL3(varargin)
% [xpos_interp,ypos_interp,time_interp,AVItime_interp] = 
% Open issues: 6/15/17
%   
%   PRIORITY   
%   - Video of results, viewer to drop back in at a bad frame. Show a
%   slider over velocity plot?
%   - blackblobscontrastadjuster done before continue
%
%   OTHER
%   - high velocity for auto
%   - elMask for other behavior flags
%   - Logic for possible: could be generalized better
%   - Blob restrictions for will and gray
%   - contrast adjustment
%   - select points by midpoint between frames to help catch not high
%   velocity wrong things  
%   - bring back cluster thresh to allow for more frequent saving 
%   - how similar is blob to blob correlating to good position on an
%   adjacent frame?
%   - reject blobs found near current location
%   - kalman filter?
%   - maybe throw out expected location for blob finding, but keep for bad
%   frame finding
%
%[xpos_interp,ypos_interp,start_time,MoMtime] = PreProcessMousePosition_auto(filepath, auto_thresh,...)
% Function to correct errors in mouse tracking.  Runs once through the
% entire sessions automatically having you edit any events above a velocity
% threshold (set by 'auto_thresh', suggest setting this to 0.01 or 0.02).
%
% INPUTS
%   filepath: pathname to DVT file. Must reside in the same directory as
%   the AVI file it matches, and there must be only ONE DVT and ONE AVI
%   file in this directory; optional
%
% OPTIONAL
%   auto_thresh: proportion of timestamps you wish to edit - 0.01 will have
%   you edit all timestamps where the velocity of the mouse is in the top
%   1% of the distribution of all velocities - suggest starting at 0.01 or
%   0.02 for a typical session, but stepping down to 0.001 or smaller if
%   you do a second pass.
%
%   'update_pos_realtime' (optional): Default is 0. Set to 1 if you want to watch the
%   position getting updated with each click of the mouse, but I don't
%   suggest it because it tends to cause weird crashes when MATLAB can't
%   figure out which figure it should actually be plotting to.
%
%   'epoch_length_lim': will not auto-correct any epochs over this length
%   where the mouse is at 0,0 or above the velocity threhold - suggest
%   using if the mouse is off the maze for a long time.
%
% OUTPUTS (all saved in Pos.mat, along with some others)
%   xpos_interp, ypos_interp: smoothed, corrected position data
%   interpolated to match the frame rate of the imaging data (hardcoded at
%   20 fps)
%
%   start_time: start of DVT file
%
%   MoMtime: the time that the mouse starts running on the maze

%{
PreProcessMousePosition_autoSL2 logic

    v is the frame we're working with
    d is background image subtraction, gaussian filtered
        stats is blobs from that
    graygaussthresh is BW brightness thresholded
        grayStats is blobs from that
    
alt logic: more generous black area as graygaussthresh as additional position mask
first get brightness, gauss thresholds from blackblobcontrastadjuster, 

 v is the frame we're working with
    d is background image subtraction, gaussian filtered
        stats is blobs from that
    graygaussthresh is BW brightness thresholded

if there's a single stats within black area, use that
if there's more than one, check for:
    adjacent definitely good frames: 
        get the one closest (and within distlim2) to mean (if more than
        one)
    adjacent frames that haven't been skipped or don't need to be corrected

if there's none here, if there's one stats and it's near a position that's
not 0 even if not definitely good, use that

if more than one, maybe now drop into old logic with black blobs and gray
blobs

if fixedThisFrameFlag==1
    use the position we came up with

%}

if ~isempty(strfind(version,'R2016a'))
    disp('Sorry, 2016a not going to work; use 2016b')
    return
end
%% Need these for better organization
clear global

global obj aviSR auto_frames corrFrame xAVI yAVI Xpix Ypix definitelyGood
global fixedThisFrameFlag; global numPasses; global v; global maskx;
global masky; global v0; global maze; global lastManualFrame; lastManualFrame=[];
global grayThresh; global gaussThresh; global willThresh; global distLim2;
global got; global skipped; global xm; global ym; global bounds;
global expectedBlobs; global time; global grayBlobArea; global auto_vel_thresh;
global ManualCorrFig; global overwriteManualFlag; global velCount; global sFrame;
global eFrame; global MoMtime; global MouseOnMazeFrame; global vel_init; 
global velchoice; global AMchoice; global corrDefGoodFlag; global elChoiceFlag;
global elVector; global mazeEl; global bstr; global allTxt; global bframes;
global update_pos_realtime; global blankVector; global isGrayThresh;
global findingContrast; global excludeFromVel; global grayLength; global avi_filepath;
global bl; global drawnowEnable


%% Get varargin
    
%epoch_length_lim = 200; % default
update_pos_realtime = 1;
max_pixel_jump = 45;
corrDefGoodFlag = 0;
overwriteManualFlag=0;
drawnowEnable=1;
for j = 1:length(varargin)
    if strcmpi('filepath', varargin{j})
        filepath = varargin{j+1};
    end
    %if strcmpi('epoch_length_lim', varargin{j})
    %    epoch_length_lim = varargin{j+1};
    %end
    if strcmpi('auto_thresh', varargin{j})
        auto_thresh = varargin{j+1};
    end
    if strcmpi('max_pixel_jump', varargin{j})
        max_pixel_jump = varargin{j+1};
    end
end
%%
if ~exist('filepath','var')
    [DVTfile, DVTpath] = uigetfile('*.DVT', 'Select DVT file');
    filepath = fullfile(DVTpath, DVTfile);
else
    [DVTpath,~,~] = fileparts(filepath);%name,ext
    %DVTfile=fullfile(name,ext);
end    
cd(DVTpath);

%%
findingContrast=0;
bl = 10000;
PosSR = 30; % native sampling rate in Hz of position data (used only in smoothing)
aviSR = 30.0003; % the framerate that the .avi thinks it's at
cluster_thresh = 40; % For auto thresholding - any time there are events above
% the velocity threshold specified by auto_thresh that are less than this
% number of frames apart they will be grouped together

% Import position data from DVT file
try
    pos_data = importdata(filepath);
       
    %frame = pos_data(:,1);
    time = pos_data(:,2); % time in seconds
    Xpix = pos_data(:,3); 
    Ypix = pos_data(:,4); 
catch
    % Video.txt is there instead of Video.DVT
    pos_data = importdata('Video.txt');
    Xpix = pos_data.data(:,6);
    Ypix = pos_data.data(:,7);
    time = pos_data.data(:,4);
end

avi_filepath = ls('*.avi');
if size(avi_filepath,1)~=1
    [avi_filepath,~] = uigetfile('*.avi','Choose appropriate video:');
end
disp(['Using ' avi_filepath ])
obj = VideoReader(avi_filepath);

if exist('Pos_temp.mat','file') || exist('Pos.mat','file')
    % Determine if either Pos_temp or Pos file already exists in the
    % directory, and prompt user to load it up if they want to continue
    % editing it.
    if exist('Pos_temp.mat','file') && ~exist('Pos.mat','file')
        use_temp = input('Pos_temp.mat detected.  Enter "y" to use or "n" to start from scratch: ','s');
        load_file = 'Pos_temp.mat';
    elseif exist('Pos.mat','file')
        use_temp = input('Previous Pos.mat detected.  Enter "y" to use or "n" to start from scratch: ','s');
        load_file = 'Pos.mat';
    end
    if strcmpi(use_temp,'y')
        load(load_file);%,'Xpix', 'Ypix', 'xAVI', 'yAVI', 'MoMtime', 'MouseOnMazeFrame');
        MoMtime %#ok<NOPRT>
    else
        xAVI = Xpix*.6246;
        yAVI = Ypix*.6246;
        h1 = implay(avi_filepath);
        MouseOnMazeFrame = input('on what frame number does Mr. Mouse arrive on the maze??? --->');
        MoMtime = MouseOnMazeFrame*0.03+time(1) %#ok<NOPRT>
        close(h1);
    end
else
    xAVI = Xpix*.6246;
    yAVI = Ypix*.6246;
    h1 = implay(avi_filepath);
    MouseOnMazeFrame = input('on what frame number does Mr. Mouse arrive on the maze??? --->');
    MoMtime = MouseOnMazeFrame*0.03+time(1) %#ok<NOPRT>
    close(h1);
end

PreCorrectedData=figure('name','Pre-Corrected Data');plot(Xpix,Ypix);title('pre-corrected data'); %#ok<NASGU>

if ~any(definitelyGood)
    definitelyGood = Xpix*0;
end
if ~any(excludeFromVel)
    excludeFromVel = Xpix*0;
end

%% Cage mask
%Comes out flipped
dummy = readFrame(obj);
MaskFig=figure('name', 'Cage Mask'); imagesc(flipud(dummy));
maskSwitch = exist('maskx','var') && exist('masky','var') && exist('maze','var')...
    && any(maskx) && any(masky) && any(maze(:)); 
switch maskSwitch  
    case 1
        title('Found cage mask')
    case 0 
        title('Draw position mask');
        [maze, maskx, masky] = roipoly;        
end
hold on; plot([maskx; maskx(1)],[masky; masky(1)],'r','LineWidth',2)

cageMaskGood=0;
while cageMaskGood==0
    figure(MaskFig); title('Cage Mask')
    choice = questdlg('Is this cage mask good?', ...
	'Cage Mask', ...
	'Yes','No redraw','Yes');
    switch choice
        case 'Yes'
            disp('Proceeding with this cage mask')
            cageMaskGood=1;
        case 'No redraw'
            figure(MaskFig); imagesc(flipud(dummy));
            title('Draw position mask');
            [maze, maskx, masky] = roipoly;
            hold on; plot([maskx; maskx(1)],[masky; masky(1)],'r','LineWidth',2)
            cageMaskGood=0;       
    end
end 
close(MaskFig)

%% Background Image
DealWithBackgroundImage;
%% Position and velocity
vel_init = hypot(diff(Xpix),diff(Ypix))/(time(2)-time(1));
vel_init = [vel_init(1); vel_init];
%[fv, xv] = ecdf(vel_init);
%if exist('auto_thresh','var')
%    auto_vel_thresh = min(xv(fv > (1-auto_thresh)));
if isempty(auto_vel_thresh)
    auto_vel_thresh = 1500;
end

SetVelocityThresh;

UpdatePosAndVel;

SaveTemp;
%% Expected location
elChoice = questdlg('Expected locations?', 'Expected locations', ...
	'Yes','No','Yes');
switch elChoice
    case 'Yes'
        elChoiceFlag=1;
        if length(mazeEl)>0 %#ok<ISMT>
            echoice = questdlg('Found expected maze locations; use?', 'Expected locations', ...
                               'Yes','No','Yes');
            switch echoice
                case 'Yes'
                    
                case 'No'
                    mazeEl=[];
                    getELvector;
            end
        else
            getELvector;
        end    
    case 'No'
        elChoiceFlag=0;
end

%% All the rest...
%if ~exist('Pos_temp.mat','file')
    
%end 
if isempty(willThresh)
    willThresh=20;
end
if isempty(grayThresh)
    grayThresh = 95; %0.95
end
if isempty(gaussThresh)
    gaussThresh = 0.21;
end
 
isGrayThresh = 0.04;
distLim2 = max_pixel_jump;
grayBlobArea = 60; %Could probably be raised
got=[];
skipped=[];
blankVector = zeros(size(xAVI));
grayLength = 15;

constr = {'Find thresholds manually?';
          ['grayThresh = ' num2str(grayThresh)];
          ['gaussThresh = ' num2str(gaussThresh)];};
            
conChoice = questdlg(constr,'Manual thresholding',...
                    'Yes','No','No');
switch conChoice
    case 'Yes'
        BlackBlobContrastAdjuster;
    case 'No'
        %Do nothing
end

disp('made it here')
%Expected gray blobs to exclude
grayFrameThreshB=rgb2gray(flipud(v0)) < grayThresh; %flipud
expectedBlobs=logical(imgaussfilt(double(grayFrameThreshB),10) <= gaussThresh);

SaveTemp;
    
%% so many options
optionsText={%'h - full explanations';...
             %' ';...
             'b - frames by behavior';...
             'z - (0,0) and out-of-bounds frames';...
             'y - attempt auto, manual when missed';...
             'm - all manual';...
             'n - frame number range';...
             'a - frame number array';...
             'p - select points by position';...
             't - reset auto-velocity threshold';...
             'v - run auto on high velocity points';...
             'g - mark frames as good and exclude';...
             'f - undo good and excluded frames';...
             'c - change editing block length';...
             'o - change AOM flag';...
             'l - edit expected locations';...
             'i - edit background image';...
             'd - change whether draw now is used';...
             's - save work';...
             'x - quit without finalizing';...
             'q - save, finalize and quit';...
             ' ';...
             'AOM flag (auto-overwrites-manual)';...
             '    - when this is set to 1 automatic processes will overwrite';...
             '    manually corrected frames; when set to 0, automatic processes';...
             '    will skip frames that have been corrected manually.';...
             ' ';...
             'When manually correcting, you can right-mouse';...
             'to accept existing position. You can also';...
             'middle-mouse to go back to the last manually';...
             'corrected frame to re-do it.'};
msgbox(optionsText,'PreProcess Keys')

disp('Highly recommended to do behavior flag (b), then (0,0) and OOB (z)')
             
stillEditingFlag=1;
while stillEditingFlag==1
UpdatePosAndVel;
%figsOpen=get(0,'children');
CheckManCorrFig;

MorePoints = input('Is there a flaw that needs to be corrected?','s');
%try 
%    figure(ManualCorrFig);
%catch
%    ManualCorrFig=figure('name','ManualCorrFig'); 
%    imagesc(flipud(v0)); title('Auto correcting, please wait')
%end 

switch MorePoints
    case 'z'
        ZeroBounds;
    case 'b'
        BehaviorFrames
    case 'y'
        disp('attempt auto')
        [sFrame,eFrame] = SelectFrameNumbers;
        auto_frames=sFrame:eFrame;
        numPasses=2;
        CorrectTheseFrames; 
    case 'n'
        prompt = {'Edit start:','Edit end:'};
        defaultans = {'25325','57870'};
        answer = inputdlg(prompt,'Edit by frame numbers',1,defaultans);
        answer=cell2mat(cellfun(@str2num,answer,'UniformOutput',false));
        
        if length(answer)==1
            auto_frames = answer;
        elseif length(answer)==2
            if answer(1)==answer(2)
                auto_frames = answer(1);
            else 
                auto_frames = answer(1):answer(2);
            end
        end       
        mchoice = questdlg(['Edit these ' num2str(length(auto_frames)) ' frames'],...
            'Edit by frame number','Auto-assist','Manual','Cancel','Manual');
        switch mchoice
            case 'Auto-assist'
                numPasses=2;
                CorrectTheseFrames;
            case 'Manual'
                        manChoice = questdlg('Redo definitely good frames?','Redo DefGood',...
                    'Yes','No','No');
                switch manChoice
                    case 'Yes'
                        corrDefGoodFlag=1;
                    case 'No'
                        corrDefGoodFlag=0;
                end  
                CorrectManualFrames
            case 'Cancel'
                %do nothing
        end
    case 'a'
        prompt = 'Edit frames:';
        %defaultans = ' ';
        numbch = questdlg('Number or load?','Frames by number','Number','Load','Number');
        switch numbch
            case 'Number'
        answer = inputdlg(prompt,'Edit by frame numbers',1);
        auto_frames = cell2mat(cellfun(@str2num,strsplit(answer{1},' '),'UniformOutput',false)');
            case 'Load'
                [file,pathloc] = uigetfile('Choose file with vector only');
                loadedFrames = load(fullfile(pathloc,file));
                names = fieldnames(loadedFrames);
                eval(['auto_frames = loadedFrames.' names{1} ';'])
        end
        corrFrame = 1;
            
        mchoice = questdlg(['Edit these ' num2str(length(auto_frames)) ' frames'],...
            'Edit by frame number','Auto-assist','Manual','Cancel','Manual');
        switch mchoice
            case 'Auto-assist'
                numPasses=2;
                CorrectTheseFrames;
            case 'Manual'
                        manChoice = questdlg('Redo definitely good frames?','Redo DefGood',...
                    'Yes','No','No');
                switch manChoice
                    case 'Yes'
                        corrDefGoodFlag=1;
                    case 'No'
                        corrDefGoodFlag=0;
                end  
                CorrectManualFrames
            case 'Cancel'
                %do nothing
        end       
    case 'm'
        %select a bunch of frames and manual correct all of them       
        disp('correcting manually')
        
        [sFrame,eFrame] = SelectFrameNumbers;
        auto_frames=sFrame:eFrame;
        
        disp(['You are currently editing from ' num2str(sFrame/aviSR) ...
            ' sec to ' num2str(eFrame/aviSR) ' sec, ' num2str(length(auto_frames)) ' frames'])
        manChoice = questdlg('Redo definitely good frames?','Redo DefGood',...
                    'Yes','No','No');
        switch manChoice
            case 'Yes'
                corrDefGoodFlag=1;
            case 'No'
                corrDefGoodFlag=0;
        end
        CorrectManualFrames;
    case 'p'
        disp('correcting by position')
        posSelect=figure('name','posSelect','Position',[250 250 640*1.5 480*1.5]); imagesc(flipud(v0))
        title('Drag region around points to correct')
        hold on
        plot(xAVI(excludeFromVel==0),yAVI(excludeFromVel==0),'.')
        [~, pointBoxX, pointBoxY] = roipoly;
        [editLogical,~] = inpolygon(xAVI, yAVI, pointBoxX, pointBoxY);
        auto_frames = find(editLogical & (excludeFromVel==0)); %find(editLogical);
        hold on
        plot(xAVI(editLogical),yAVI(editLogical),'.r')
        poschoice = questdlg(['Edit these ' num2str(length(auto_frames)) ' points?'],...
            'Edit by position','Auto-assist','Manual','No','Manual');
        switch poschoice
            case 'Auto-assist'
                numPasses=2;
                CorrectTheseFrames;
            case 'Manual'
                manChoice = questdlg('Redo definitely good frames?','Redo DefGood',...
                    'Yes','No','No');
                switch manChoice
                    case 'Yes'
                        corrDefGoodFlag=1;
                    case 'No'
                        corrDefGoodFlag=0;
                end        
                CorrectManualFrames;
            case 'No'
                %Do nothing
        end
        try
        close(posSelect);
        end
    %{    
    case 'g'
        % generate a movie and show it
        for i = 1:length(time)
            obj.currentTime = i/aviSR; % sFrame is the correct frame #, but .avi reads are done according to time
            v = readFrame(obj);
            figure(6156);
            imagesc(flipud(v));hold on;
            plot(xAVI(i),yAVI(i),'or','MarkerSize',5,'MarkerFaceColor','r');hold off;
            F(i) = getframe(gcf);
        end
        save F.mat 
        implay(F);pause;
    %}
    case 't'
        disp('reset high-velocity threshold')
        SetVelocityThresh
    case 'v'
        disp('auto-correcting high velocity points')
        % Find indices of all points above auto_vel_thresh
        % After doing the first, recalculate all and go to earliest
        % Following this to work towards end
        
        velchoice = questdlg('How do you want to do velocity?', 'Correct high velocity',...
            'Whole session','Select Window','First 100','Select Window');
        bounds=[];
        switch velchoice
            case 'Whole session'
                disp(['right now found ' num2str(sum(vel_init>auto_vel_thresh))...
                    ' high velocity frames; expect more'])
                bounds(1:round(length(xAVI)/3))=1;
                bounds(round(length(xAVI)/3)+1:2*round(length(xAVI)/3))=2;
                bounds(2*round(length(xAVI)/3)+1:length(xAVI)+1)=3;
                sFrame = 1;
                eFrame = length(xAVI)-1;
            case 'First 100'
                bounds(1:33)=1; bounds(34:66)=2; bounds(67:100)=3;
                sFrame = 1;
                eFrame = length(xAVI)-1;
            case 'Select Window'
                [sFrame,eFrame] = SelectFrameNumbers;
                frameRange = eFrame-sFrame+1;
                bounds(1:round(frameRange/3))=1;
                bounds(round(frameRange/3)+1:2*round(frameRange/3))=2;
                bounds(2*round(frameRange/3):frameRange)=3;
                bounds = [ones(1,sFrame-1), bounds, ones(1,length(xAVI)-eFrame+1)*3]; %#ok<AGROW>
        end
        
        AMchoice = questdlg('Manual only or auto-assist?', 'Auto or manual',...
                'Auto-assist','Manual','Cancel','Manual');
        switch AMchoice
            case 'Manual'
                HighVelocityCorrect;
            case 'Auto-assist'
                disp('Sorry, not working right now')
                %HighVelocityCorrect;
            case 'Cancel'
                %Do nothing
        end
        
    case 'o'
    switch overwriteManualFlag
        case 0
            overwriteManualFlag=1 %#ok<NOPRT>
            disp('auto-overwrites-manual is now ENABLED')
        case 1
            overwriteManualFlag=0 %#ok<NOPRT>
            disp('auto-overwrites-manual is now DISABLED')
    end
    case 'd'
    switch drawnowEnable
        case 0
            drawnowEnable=1 %#ok<NOPRT>
            disp('drawnow for plotting is now ENABLED')
        case 1
            drawnowEnable=0 %#ok<NOPRT>
            disp('drawnow for plotting is now DISABLED')
    end
    case 'l'
        editELvectors;
    case 'g'
        MarkForExclude;
    case 's'
        SaveTemp;
    case 'x'
        figsOpen = findall(0,'type','figure');
        isPreKeys = strcmp({figsOpen.Name},'PreProcess Keys');
        close(figsOpen(isPreKeys));
        SaveTemp;
        ClearStuff;
        return
    case 'q'
        SaveTemp;
        stillEditingFlag=0; 
    case 'i'
        DealWithBackgroundImage;
    case 'c'
        prompt = {'BL:'};
        defaultans = {num2str(bl)};
        answer = inputdlg(prompt,'Change block length:',1,defaultans);
        bl=cell2mat(cellfun(@str2num,answer,'UniformOutput',false));
    otherwise
        disp('Not a recognized input')
end

end

%% Final stuff

Xpix_filt = NP_QuickFilt(Xpix,0.0000001,1,PosSR);
Ypix_filt = NP_QuickFilt(Ypix,0.0000001,1,PosSR);

%if size(pos_data,2) == 5
%    motion = pos_data(:,5);
%end

timet=1:length(time);
AVIobjTime = timet./aviSR;

%frame_rate_emp = round(1/mean(diff(time))); % empirical frame rate (frames/sec)

% Generate times to match brain imaging data timestamps
fps_brainimage = 20; % frames/sec for brain image timestamps

start_time = ceil(min(time)*fps_brainimage)/fps_brainimage;
max_time = floor(max(time)*fps_brainimage)/fps_brainimage;
time_interp = start_time:1/fps_brainimage:max_time;

if (max(time_interp) >= max_time)
    lt=length(time_interp)-1;
    time_interp = time_interp(1:lt);
end

%Do Linear Interpolation

% Get appropriate time points to interpolate for each timestamp
time_index = arrayfun(@(a) [max(find(a >= time)) min(find(a < time))],...
    time_interp,'UniformOutput',0); %#ok<MXFND>
time_test_cell = arrayfun(@(a) a,time_interp,'UniformOutput',0);

xpos_interp = cellfun(@(a,b) lin_interp(time(a), Xpix_filt(a),...
    b),time_index,time_test_cell);

ypos_interp = cellfun(@(a,b) lin_interp(time(a), Ypix_filt(a),...
    b),time_index,time_test_cell);

AVItime_interp = cellfun(@(a,b) lin_interp(time(a), AVIobjTime(a),...
    b),time_index,time_test_cell);

DVTtime=time;
% Save all filtered data as well as raw data in case you want to go back
% and fix an error you discover later on
%Final save
save Pos.mat Xpix_filt Ypix_filt xpos_interp ypos_interp time_interp start_time...
    MoMtime Xpix Ypix xAVI yAVI MouseOnMazeFrame...
    AVItime_interp maze v0 maskx masky definitelyGood expectedBlobs mazeEl...
    elVector bstr allTxt bframes DVTtime willThresh grayThresh gaussThresh time...
    auto_vel_thresh excludeFromVel

ClearStuff;

close all 
end
%%
%Functions
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CheckManCorrFig(~,~)
global ManualCorrFig; global v0; global PosAndVel; 

figsOpen = findall(0,'type','figure');
isManCorr = strcmp({figsOpen.Name},'ManualCorrFig');
if sum(isManCorr)==1
    %We're good
elseif sum(isManCorr)==0
    ManualCorrFig=figure('name','ManualCorrFig'); imagesc(flipud(v0)); %title('Auto correcting, please wait')
elseif sum(isManCorr) > 1
    manCorrInds = find(isManCorr);
    close(figsOpen(manCorrInds(2:end)))
end

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function HighVelocityCorrect(~,~)
global sFrame; global eFrame; global vel_init; global auto_vel_thresh;
global velCount; global time; global Xpix; global Ypix; global corrFrame;
global auto_frames; global velchoice; global AMchoice; global pass;
global xAVI; global yAVI; global definitelyGood; global fixedThisFrameFlag
global bounds; global skipped; global ManualCorrFig;
global v; global obj; global xm; global ym; global aviSR; global markWith;
global excludeFromVel;

marker = {'go' 'yo' 'ro'};
marker_face = {'g' 'y' 'r'};

manChoice = questdlg('Redo definitely good frames?','Redo DefGood',...
                    'Yes','No','Yes');
                
switch AMchoice
    case 'Manual'
        hvTriedFrames=[];
        skipForNow=[];
        doneVel=0;
        velCount=0;
        triedOnce=[];
        goneOnce = 0;
        while doneVel==0
        
        correctThis=1;
        vel_init = hypot(diff(Xpix),diff(Ypix))./diff(time);
        
        %This comes from last function
        vel_init(logical(excludeFromVel(1:length(vel_init)))) = min(vel_init);
        
        main_restrict = zeros(length(vel_init),1);
        stopHere = min([eFrame length(vel_init)]);
        main_restrict(sFrame:stopHere)=1;
        highVelLogical = vel_init>auto_vel_thresh;
        highVelLogical = highVelLogical &  main_restrict;
        skipPass = unique(skipForNow);
        highVelLogical(skipPass) = 0;
                
        highVelFrames = find(highVelLogical);
        
        if goneOnce==0
            disp(['found ' num2str(length(highVelFrames)) ' frames, expect more'])
            goneOnce=1;
        end
        
        if any(highVelFrames)
            auto_frames=highVelFrames(1);
            corrFrame=1;
            if strcmp(manChoice,'No') && definitelyGood(auto_frames(corrFrame))==1
                auto_frames = auto_frames + 1;
                if definitelyGood(auto_frames(corrFrame))==1
                    %somehow we've still for a high velocity frame though both are good
                    disp('Something wrong here, 2 def good frames but still high vel')
                    disp('This bit still needs fixing')
                end
            end
            
            switch velchoice
                case {'Whole session','Select Window'}
                    markWith=bounds(auto_frames(corrFrame));
                case 'First 100'
                    markWith=bounds(velCount);
            end
        else 
            doneVel=1;
        end
        
        if doneVel==0 && any(auto_frames) %in this case auto_frames should never be empty
            if sum(hvTriedFrames==auto_frames)==1
                disp(['Tried ' num2str(auto_frames) ' once, trying next frame'])
                triedOnce = [triedOnce, auto_frames]; %#ok<AGROW>
                if sum(triedOnce==auto_frames)>10
                    stuckDone=0;
                    while stuckDone==0
                    stuckchoice =  questdlg('I see you are stuck. Near frames (+/-3) or debug?', 'Stuck',...
                            'Near frames','debug','Save','Near frames');
                    switch stuckchoice
                        case 'Near frames'
                            tryF = auto_frames;
                            auto_frames = tryF-3:tryF+3;
                            for corrFrame=1:length(auto_frames)
                                if definitelyGood(auto_frames(corrFrame))==0 || strcmp(manChoice,'Yes')
                                    obj.CurrentTime=(auto_frames(corrFrame)-1)/aviSR;
                                    v = readFrame(obj);
                                    fixedThisFrameFlag=0;
                                    [xm,ym]=EnhancedManualCorrect;
                                    if fixedThisFrameFlag==1
                                        FixFrame(xm,ym)
                                    end
                                    hvTriedFrames = [hvTriedFrames, auto_frames]; %#ok<AGROW>
                                end
                            end
                            correctThis=0;
                            stuckDone=1;
                        case 'debug'
                            keyboard 
                        case 'Save'
                            SaveTemp;
                            stuckDone=0;
                    end
                    end
                end
                auto_frames = auto_frames + 1;
            elseif sum(hvTriedFrames==auto_frames)==2
                %maybe just let it go?
                disp(['2x on frame ' num2str(auto_frames)])
            elseif sum(hvTriedFrames==auto_frames)==3 || sum(hvTriedFrames==auto_frames)==4
                disp(['Tried this frame ' num2str(sum(hvTriedFrames==auto_frames)) ' times'])
                doneCont = 0;
                while doneCont==0
                contchoice =  questdlg('Try it again or skip it?', 'SkipTry',...
                            'End','PrevNext','Save','PrevNext');
                switch contchoice
                    case 'End'
                        correctThis=0;
                        doneVel=1;
                        doneCont=1;
                    case 'PrevNext'
                        intendedFrame=auto_frames;
                        auto_frames=[intendedFrame-1 intendedFrame+1];
                        for corrFrame=1:length(auto_frames)
                            if definitelyGood(auto_frames(corrFrame))==0 || strcmp(manChoice,'Yes')
                                obj.CurrentTime=(auto_frames(corrFrame)-1)/aviSR;
                                v = readFrame(obj);
                                fixedThisFrameFlag=0;
                                [xm,ym]=EnhancedManualCorrect;
                                if fixedThisFrameFlag==1
                                    FixFrame(xm,ym)
                                end
                                hvTriedFrames = [hvTriedFrames, auto_frames]; %#ok<AGROW>
                            end
                        end
                        correctThis=0;
                        doneCont=1;
                    case 'Save'    
                        SaveTemp;
                        doneCont=0;
                end
                end
            elseif sum(hvTriedFrames==auto_frames)>=5
                disp(['skipping ' num2str(auto_frames)])
                skipForNow = [skipForNow, auto_frames]; %#ok<AGROW>
                correctThis=0;
            end
            
            hvTriedFrames = [hvTriedFrames, auto_frames];  %#ok<AGROW>
            if correctThis==1
                obj.CurrentTime=(auto_frames(corrFrame)-1)/aviSR;
                v = readFrame(obj);
                [xm,ym]=EnhancedManualCorrect;

                if fixedThisFrameFlag==1
                    FixFrame(xm,ym)

                    hold(ManualCorrFig.Children,'on')  
                    plot(ManualCorrFig.Children,xm,ym,marker{markWith},'MarkerSize',4,...
                        'MarkerFaceColor',marker_face{markWith})
                    hold(ManualCorrFig.Children,'off')
                end
                %hvTriedFrames = [hvTriedFrames, auto_frames];  %#ok<AGROW>
            end
        end
        
        if strcmp(velchoice,'First 100')
            velCount = velCount+1;
            if velCount > 99
                doneVel=1;
            end
        end
        
        end
        
        if any(skipForNow)
            SaveTemp;
            auto_frames = sort(unique(skipForNow));
            disp(['Continuing with ' num2str(length(auto_frames)) ' skipped frames'])
            for corrFrame = 1:length(auto_frames)
                obj.CurrentTime=(auto_frames(corrFrame)-1)/aviSR;
                v = readFrame(obj);
                [xm,ym]=EnhancedManualCorrect;

                if fixedThisFrameFlag==1
                    FixFrame(xm,ym)

                    hold(ManualCorrFig.Children,'on')  
                    plot(ManualCorrFig.Children,xm,ym,marker{markWith},'MarkerSize',4,...
                        'MarkerFaceColor',marker_face{markWith})
                    hold(ManualCorrFig.Children,'off')
                end 
            end
        end
        disp('No more high velocity frames')
        UpdatePosAndVel;
        
    case 'Auto-assist'
        disp('Nope, not yet')
        
        for fakePass=1:2

        hvTriedFrames=[];
        skipForNow=[];
        doneVel=0;
        velCount=1;
        
        while doneVel==0
        
            correctThis=1;
            vel_init = hypot(diff(Xpix),diff(Ypix))./diff(time);

            %This comes from last function
            vel_init(logical(excludeFromVel(1:length(vel_init)))) = min(vel_init);

            main_restrict = zeros(length(vel_init),1);
            stopHere = min([eFrame length(vel_init)]);
            main_restrict(sFrame:stopHere)=1;
            highVelLogical = vel_init>auto_vel_thresh;
            highVelLogical = highVelLogical &  main_restrict;
            skipPass = unique(skipForNow);
            highVelLogical(skipPass) = 0;

            highVelFrames = find(highVelLogical);
            if any(highVelFrames)
                auto_frames=highVelFrames(1);
                corrFrame=1;
                if strcmp(manChoice,'No') && definitelyGood(auto_frames(corrFrame))==1
                    auto_frames = auto_frames + 1;
                    if definitelyGood(auto_frames(corrFrame))==1
                        %somehow we've still for a high velocity frame though both are good
                        disp('Something wrong here, 2 def good frames but still high vel')
                        disp('This bit still needs fixing')
                    end
                end

                switch velchoice
                    case {'Whole session','Select Window'}
                        markWith=bounds(auto_frames(corrFrame));
                    case 'First 100'
                        markWith=bounds(velCount);
                end
            else 
                doneVel=1;
            end
        
            if sum(hvTriedFrames==auto_frames)==1
                disp(['Tried ' num2str(auto_frames) ' once, trying next frame'])
                auto_frames = auto_frames+1;
            elseif sum(hvTriedFrames==auto_frames)==2
                %Maybe we came back to it
                disp(['2x on frame ' num2str(auto_frames)])
            elseif sum(hvTriedFrames==auto_frames)>=3
                switch fakePass
                    case 1
                        skipForNow = [skipForNow, auto_frames]; %#ok<AGROW>
                        correctThis = 0;
                    case 2
                        disp(['Tried this frame ' num2str(sum(hvTriedFrames==auto_frames)) ' times'])
                        doneCont = 0;
                        while doneCont==0
                        contchoice =  questdlg('Try it again or skip it?', 'SkipTry',...
                                    'End','PrevNext','Save','PrevNext');
                        switch contchoice
                            case 'End'
                                correctThis=0;
                                doneVel=1;
                                doneCont=1;
                            case 'PrevNext'
                                intendedFrame=auto_frames;
                                auto_frames=[intendedFrame-1 intendedFrame+1];
                                for corrFrame=1:length(auto_frames)
                                    if definitelyGood(auto_frames(corrFrame))==0 || strcmp(manChoice,'Yes')
                                        obj.CurrentTime=(auto_frames(corrFrame)-1)/aviSR;
                                        v = readFrame(obj);
                                        fixedThisFrameFlag=0;
                                        [xm,ym]=EnhancedManualCorrect;
                                        if fixedThisFrameFlag==1
                                            FixFrame(xm,ym)
                                            hold(ManualCorrFig.Children,'on')  
                                            plot(ManualCorrFig.Children,xm,ym,marker{markWith},'MarkerSize',4,...
                                                'MarkerFaceColor',marker_face{markWith})
                                            hold(ManualCorrFig.Children,'off')
                                            velCount = velCount+1;
                                        end
                                        hvTriedFrames = [hvTriedFrames, auto_frames]; %#ok<AGROW>
                                    end
                                end
                                correctThis=0;
                                doneCont=1;
                            case 'Save'    
                                SaveTemp;
                                doneCont=0;
                        end
                        end
                end
            end
            
            hvTriedFrames = [hvTriedFrames, auto_frames];     %#ok<AGROW>
            if correctThis==1
                obj.CurrentTime=(auto_frames(corrFrame)-1)/aviSR;
                v = readFrame(obj);
                pass=fakePass;
                
                CorrectThisFrame;

                if fixedThisFrameFlag==1
                    FixFrame(xm,ym)
                    hold(ManualCorrFig.Children,'on')  
                    plot(ManualCorrFig.Children,xm,ym,marker{markWith},'MarkerSize',4,...
                        'MarkerFaceColor',marker_face{markWith})
                    hold(ManualCorrFig.Children,'off')
                    velCount = velCount+1;
                elseif fixedThisFrameFlag==0
                    skipForNow = [skipForNow, auto_frames]; %#ok<AGROW>
                end
            end
        
            if velCount > 100
                doneVel = 1;
            end
        end
        end
end
   
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function FixFrame(xm,ym)
global xAVI; global yAVI; global Xpix, global Ypix; global auto_frames;
global corrFrame;

xAVI(auto_frames(corrFrame)) = xm;
yAVI(auto_frames(corrFrame)) = ym;
Xpix(auto_frames(corrFrame)) = ceil(xm/0.6246);
Ypix(auto_frames(corrFrame)) = ceil(ym/0.6246);
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TryAdjacentFrames(~,~)
                
global putativeMouseX; global putativeMouseY;
global auto_frames; global corrFrame; global skipped; global pass;
global xAVI; global yAVI; global fixedThisFrameFlag; global huh; %global got
global xm; global ym; 

%1/sqrt(length(defAdjXs) %scaling factor for radius by how many adj frames

skipThisStep=0;
if auto_frames(corrFrame) > 1 && any(skipped==auto_frames(corrFrame)-1)==0 %Look at adjacent frames
    %not the first frame and we didn't skip the last one
    adjacentX = xAVI(auto_frames(corrFrame)-1);
    adjacentY = yAVI(auto_frames(corrFrame)-1);
elseif auto_frames(corrFrame)~=auto_frames(end)
    if auto_frames(corrFrame) < length(xAVI) && any(auto_frames(corrFrame+1)==auto_frames(corrFrame)+1)==0
        %&& any(skipped==auto_frames(corrFrame)+1)==0 ... %doesn't work w/ more than one skipped
        %not the last frame and next frame doesn't need to be corrected
        %this check could fail if we're on the last auto_frame
    adjacentX = xAVI(auto_frames(corrFrame)+1);
    adjacentY = yAVI(auto_frames(corrFrame)+1);
    else
        skipThisStep=1;
        switch pass
            case 1
                fixedThisFrameFlag=0;
                skipped = [skipped; auto_frames(corrFrame)];
            case 2
                [xm, ym] = EnhancedManualCorrect;
        end
    end    
else
    if auto_frames(corrFrame)==1
        [xm,ym]=ManualOnlyCorr;
        skipThisStep=1;
    elseif pass==1 %no usable frames
        skipped = [skipped; auto_frames(corrFrame)];
        skipThisStep=1;
        fixedThisFrameFlag=0;
    elseif pass==2 && auto_frames(corrFrame)~=1
        [xm,ym] = EnhancedManualCorrect;
        skipThisStep=1;
    else 
        disp('missed something somewhere...')
        huh=[huh; auto_frames(corrFrame)];
        skipThisStep=1;
    end
end

%maybe this should be a separate function
if skipThisStep==0
    whichSharedMouseX = findclosest( adjacentX, putativeMouseX);
    whichSharedMouseY = findclosest( adjacentY, putativeMouseY);
    if whichSharedMouseX  == whichSharedMouseY
        xm = putativeMouseX(whichSharedMouseX);
        ym = putativeMouseY(whichSharedMouseY);
        fixedThisFrameFlag = 1;
        %got = [got; corrFrame]; 
    else    
        if pass==1
            skipped = [skipped; auto_frames(corrFrame)]; 
            fixedThisFrameFlag=0;
        elseif pass>=2 && auto_frames(corrFrame)==1 %this shouldn't happen
            disp('this shouldn"t happen')
            [xm, ym] = ManualOnlyCorr;
        elseif pass>=2 && corrFrame~=1
            [xm,ym] = EnhancedManualCorrect; 
        end    
    end
end
                
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xm,ym]=EnhancedManualCorrect(~,~)
global auto_frames; global corrFrame; global v; global ManualCorrFig
global fixedThisFrameFlag; global definitelyGood; global obj
global xAVI; global yAVI; global Xpix; global Ypix; global v0;
global lastManualFrame; global aviSR; global markWith

marker = {'go' 'yo' 'ro'};
marker_face = {'g' 'y' 'r'};

intendedFrame=v;
intendedFrameNum=auto_frames(corrFrame);
intendedFrameGood=0;
while intendedFrameGood == 0
    try
        figure(ManualCorrFig);
    catch
        ManualCorrFig=figure('name','ManualCorrFig'); imagesc(flipud(v0)); %title('Auto correcting, please wait')
    end
    imagesc(ManualCorrFig.Children,flipud(intendedFrame))
    PlotVelLine;
    title(ManualCorrFig.Children,['click here, frame ' num2str(auto_frames(corrFrame))])
    if Xpix(intendedFrameNum) ~= 0 && Ypix(intendedFrameNum) ~= 0
        hold(ManualCorrFig.Children,'on');   
        plot(ManualCorrFig.Children,xAVI(intendedFrameNum),yAVI(intendedFrameNum),marker{markWith},'MarkerSize',4);
        hold(ManualCorrFig.Children,'off');
    end
    [xm,ym,button] = ginput(1);
    fixedThisFrameFlag=0;
    switch button
        case 1 %left click
            %this point is good, use the xm ym
            hold(ManualCorrFig.Children,'on');
            plot(ManualCorrFig.Children,xm,ym,marker{markWith},'MarkerSize',4,...
                'MarkerFaceColor',marker_face{markWith});hold off;
            hold(ManualCorrFig.Children,'off');
            title('Auto correcting, please wait')
            definitelyGood(auto_frames(corrFrame)) = 1;
            fixedThisFrameFlag=1;
            lastManualFrame=auto_frames(corrFrame);
            intendedFrameGood=1;
        case 2 %middle click
            switch any(lastManualFrame)
                case 1
            %go back and fix the last frame we corrected manually 
            obj.CurrentTime=(lastManualFrame-1)/aviSR;
            pastFrame = readFrame(obj);
            imagesc(ManualCorrFig.Children,flipud(pastFrame))
            PlotVelLine;
            title(['click here, backed up to ' num2str(lastManualFrame) ' from ' num2str(intendedFrameNum)])
            [xm,ym] = ginput(1);
            hold(ManualCorrFig.Children,'on');
            plot(ManualCorrFig.Children,xm,ym,'oy','MarkerSize',4,'MarkerFaceColor','g'); 
            hold(ManualCorrFig.Children,'off');
            FixFrame(xm,ym)
            definitelyGood(lastManualFrame) = 1; %just in case
            obj.CurrentTime = (intendedFrameNum-1)/aviSR;
            intendedFrame = readFrame(obj);
            intendedFrameGood=0;
                case 0
            title(['click here frame ' num2str(intendedFrameNum) '; no manual to back up to'])
            intendedFrameGood=0;        
            end        
        case 3 %right click 
            %skip
            fixedThisFrameFlag=0;
            definitelyGood(auto_frames(corrFrame)) = 1;
            lastManualFrame=auto_frames(corrFrame);
            intendedFrameGood=1;
    end
end

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xm,ym]=ManualOnlyCorr(~,~)
global auto_frames; global corrFrame; global v; global ManualCorrFig
global fixedThisFrameFlag; global definitelyGood; global lastManualFrame;


imagesc(ManualCorrFig.Children,flipud(v))
PlotVelLine;
hold(ManualCorrFig.Children,'on')
title(ManualCorrFig.Children,['click here, frame ' num2str(auto_frames(corrFrame))])
figure(ManualCorrFig); 
[xm,ym] = ginput(1);
plot(ManualCorrFig.Children,xm,ym,'og','MarkerSize',4,'MarkerFaceColor','g');
hold(ManualCorrFig.Children,'off')
title(ManualCorrFig.Children,'Auto correcting, please wait')
definitelyGood(auto_frames(corrFrame)) = 1;
fixedThisFrameFlag=1;
lastManualFrame=auto_frames(corrFrame);

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sFrame, eFrame]=SelectFrameNumbers(~,~)
global PosAndVel; global time; 

disp('click on the good points around the flaw then hit enter');
        
figure(PosAndVel);
[DVTsec,~] = ginput(2); % DVTsec is start and end time in DVT seconds
sFrame = round(min(DVTsec));
eFrame = round(max(DVTsec));

eFrame = min([length(time), eFrame]); %make sure we're not to far
sFrame = max([1, sFrame]); %makesure we're not too early
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CorrectTheseFrames(~,~)
%main frame-correcting code here
global auto_frames; global corrFrame; global ManualCorrFig; global skipped;
global markWith; global v0; global pass; global numPasses;
global overwriteManualFlag; global definitelyGood; global bl;

skipped=[];
%ManualCorrFig=figure('name','ManualCorrFig'); 
imagesc(ManualCorrFig.Children,flipud(v0)); 
title(ManualCorrFig.Children,'Auto correcting, please wait')
for pass=1:numPasses
    disp(['Running auto assisted on ' num2str(length(auto_frames)) ' frames'])
    %pass 1 skip where bad, pass 2 run skipped, manual correct if still bad
    resol = 1; % Percent resolution for progress bar
    p = ProgressBar(100/resol);
    update_inc = round(length(auto_frames)/(100/resol));
    total=0;
    bounds=[0 floor(length(auto_frames)/3) 2*floor(length(auto_frames)/3)];
    
    %Chunking to allow for altering things
    %Maybe this can be replaced with a figure with a checkbox that can be
    %read every thousand frames
    %{ 
        global ab
    ab.AutoBadFigure = figure('name','AutoBadFigure','position',[500 500 200 70],...
                                'MenuBar','none','ToolBar','none');
    ab.stopBox = uicontrol('Style','checkbox','Position',[160,11,25,25],...
                                'Value', 0,'Parent',ab.AutoBadFigure);
    ab.boxLabel = uicontrol('style','text','String','Stop at next chunk:',...
                              'Position',[5,10,140,25],'FontSize',12,'Parent',ab.AutoBadFigure);
    %}
    
    %if length(auto_frames) > bl
    %hold_auto_frames = auto_frames;
    blocks = floor(length(auto_frames)/bl);
    %rem(length(auto_frames),500)
    auto_chunks = cell(blocks+1,1);
    for bb = 1:blocks
        auto_chunks{bb} = auto_frames((1:bl)+bl*(bb-1));
    end
    auto_chunks{blocks+1} = auto_frames(bl*blocks+1:end);
    
    chunk = 1;
    
    breakchoice = questdlg(['About to do ' num2str(length(auto_frames))...
        ' frames, pass ' num2str(pass),'; do it?'],...
        'go ahead','Do it','No stop','Do it');
        switch breakchoice
            case 'Do it'
                proceedCorrect=1;
            case 'No stop'
                proceedCorrect=0;
                total = length(auto_frames);
                p.progress;
        end
    
    if proceedCorrect==1    
        while chunk <= size(auto_chunks,1)
            auto_frames = auto_chunks{chunk};
            for corrFrame=1:length(auto_frames)   
                if overwriteManualFlag==1 || definitelyGood(auto_frames(corrFrame))==0
                    markWith=sum((corrFrame+bl*(chunk-1))>bounds);
                    CorrectThisFrame;
                end 

                total=total+1;
                if round(total/update_inc) == (total/update_inc) % Update progress bar
                    p.progress;
                end
            end
            
            
            chunk = chunk+1;
            if chunk <= size(auto_chunks,1)
                doneWchunk=0;
                while doneWchunk==0
                    doingChoice = questdlg('Continue or stop?','How are we doing?',...
                        'Continue','Stop','Save','Continue');
                    switch doingChoice
                        case 'Continue'
                            doneWchunk=1;
                        case 'Stop'
                            chunk = size(auto_chunks,1)+1;
                            skipped = [];
                            doneWchunk=1;
                        case 'Save'
                            SaveTemp;
                    end
                end
            end
            
        end
    end
    %try
    %close(ManualCorrFig);    
    %end
    SaveTemp;
    p.stop;

    UpdatePosAndVel
    
    switch pass
        case 1
            disp(['Completed auto-pass ' num2str(pass) ' on ' num2str(total) ' out of bounds frames'])
            auto_frames=skipped; %and can't have any skipped in round 2
            skipped = [];
        case 2
            disp('something about the frames you helped correct, human')
    end 

end

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CorrectThisFrame(~,~)
global auto_frames; global corrFrame; global v; global ManualCorrFig;
global fixedThisFrameFlag; global obj; global markWith; global v0;
global xAVI; global yAVI; global Xpix; global Ypix; global maze; global got;
global pass; global aviSR; global expectedBlobs; global update_pos_realtime;
global grayBlobArea; global skipped; global putativeMouseX; global putativeMouseY;
global willThresh; global grayThresh; global gaussThresh; global distLim2;
global xm; global ym; global elChoiceFlag; global elVector; global mazeEl;
global maskx; global masky;  global isGrayThresh; global auto_vel_thresh;
global definitelyGood; global grayLength; global drawnowEnable

xm=[]; ym=[];
marker = {'go' 'yo' 'ro'};
marker_face = {'g' 'y' 'r'};

%Get appropriate maze boundaries
if elChoiceFlag==1
    whichMaze = elVector( auto_frames(corrFrame) );
    mazeMask = mazeEl(whichMaze).maze;
    mazex = mazeEl(whichMaze).maskx;
    mazey = mazeEl(whichMaze).masky;
else
    mazeMask = maze;
    mazex = maskx;
    mazey = masky; 
end
fixedThisFrameFlag=0;
    
obj.CurrentTime=(auto_frames(corrFrame)-1)/aviSR;
v = readFrame(obj);
if update_pos_realtime==1   
    CheckManCorrFig;
    hold(ManualCorrFig.Children,'off')
    imagesc(ManualCorrFig.Children,flipud(v)); 
    hold(ManualCorrFig.Children,'on')
    title(ManualCorrFig.Children,['Auto correcting frame ' num2str(auto_frames(corrFrame)) ', please wait'])
    if Xpix(auto_frames(corrFrame)) ~= 0 && Ypix(auto_frames(corrFrame)) ~= 0
        plot(ManualCorrFig.Children,xAVI(auto_frames(corrFrame)),yAVI(auto_frames(corrFrame)),...
            marker{markWith},'MarkerSize',4);
    end    
    
    plot(ManualCorrFig.Children,[mazex; mazex(1)],[mazey; mazey(1)],'r','LineWidth',1);
    hold(ManualCorrFig.Children,'off')
    
    if drawnowEnable==1
    drawnow
    end
    %disp('working')
    PlotVelLine;
end
            
%Will's version, background image subtraction
stats=[]; %#ok<NASGU>
d = imgaussfilt(flipud(rgb2gray(v0-v)),10);
stats = regionprops(d>willThresh & mazeMask,'area','centroid','majoraxislength','minoraxislength');%flipped %'solidity'
MouseBlob = [stats.Area] > 250 & ... %[stats.Area] < 3500...
            [stats.MajorAxisLength] > 10 & ...
            [stats.MinorAxisLength] > 10;
stats=stats(MouseBlob);
        
%Sam's gray version
grayFrameThresh = rgb2gray(flipud(v)) < grayThresh; %flipud
grayGauss = imgaussfilt(double(grayFrameThresh),10);
                   
%Centers in mask (should pretty much always be all ones)
statsCenters = reshape([stats.Centroid],2,length(stats))';
[inmask, onmask] = inpolygon(statsCenters(:,1),statsCenters(:,2),mazex,mazey);
inMask = inmask | onmask;
stats = stats(inMask); 

%Centers on black
statsCenters = reshape([stats.Centroid],2,length(stats))';
generousGray = (grayGauss > isGrayThresh) & mazeMask & expectedBlobs; %seems ok
grayOutlines = bwboundaries(generousGray);%cell2mat(
grayIn = zeros(size(statsCenters,1),1); grayOn = grayIn;
for thisGray = 1:length(grayOutlines)
    [thisIn, thisOn] = inpolygon(statsCenters(:,1),statsCenters(:,2),...
        grayOutlines{thisGray,1}(:,2),grayOutlines{thisGray,1}(:,1));
    grayIn = grayIn | thisIn;
    grayOn = grayOn | thisOn;
end
inGray = grayIn | grayOn;
stats = stats(inGray);

if length(stats) == 1
    xm = stats.Centroid(1);
    ym = stats.Centroid(2);
    fixedThisFrameFlag=1;
elseif isempty(stats)
    if auto_frames(corrFrame)==1
        [xm,ym]=ManualOnlyCorr;
    elseif auto_frames(corrFrame)~=1
        switch pass
            case 2
                %Should it be try gray?
                [xm,ym] = EnhancedManualCorrect;
            case 1
                %Should it be try gray?
                skipped = [skipped; auto_frames(corrFrame)]; 
                fixedThisFrameFlag=0;
        end
    end 
elseif length(stats) > 1
    %First check adjacent for definitelyGood frames
    
    %Does any of this fail is both defGood frames are 0?
    tryFrame = auto_frames(corrFrame);
    testDG = [0; definitelyGood; 0]; %so we can index w/o conditionals
    testDGtry = tryFrame+1; %same
    adjFrames = [(testDGtry-1) (testDGtry+1)]';
    useAdjFrames = testDG(adjFrames);%tryFrame = 1 or end always returns 0
    adjFrames(useAdjFrames==0) = [];

    defAdjXs = xAVI(adjFrames-1);
    defAdjYs = yAVI(adjFrames-1);
        
    %if there's anything here, see if there's one stats that is minimum
    %distance from both and within distlim2 of both
    statsCenters = reshape([stats.Centroid],2,length(stats))';
    defDist = zeros(length(stats),length(defAdjXs));
    for defAdjInd = 1:length(defAdjXs)
        defDist(:,defAdjInd) = ...
            hypot(statsCenters(:,1)-defAdjXs(defAdjInd), statsCenters(:,2)-defAdjYs(defAdjInd));
    end
    
    DefGoodDist = defDist <= distLim2;
    NearBothDG = sum(DefGoodDist,2)==length(defAdjXs);
    
    if sum(NearBothDG)==1 %If there's one, use it
        xm = stats(NearBothDG).Centroid(1);
        ym = stats(NearBothDG).Centroid(2);
        fixedThisFrameFlag = 1;
        got=[got; corrFrame];
        %{
    elseif sum(NearBothDG)==0
        %Probably something is fuxed somewhere
        %maybe need to redo that definitely good frame?
        %or image subtraction sucked
        switch pass
            case 2
                disp('Something off in definitelyGood; please fix now')
                hold_auto_frames = auto_frames;
                hold_corrFrame = corrFrame;
                auto_frames = adjFrames-1;
                for fixDG = 1:length(auto_frames)
                    corrFrame = fixDG;
                    [xm,ym] = EnhancedManualCorrect;
                end
                auto_frames = hold_auto_frames;
                corrFrame = hold_corrFrame;
                [xm,ym] = EnhancedManualCorrect;
            case 1
                skipped = [skipped; auto_frames(corrFrame)]; 
                fixedThisFrameFlag=0;
        end
        %}
    else %if sum(NearBothDG)>1
        %One of these cases is where it splits the mouse in two around a
        %corner or something
        
        %Alt adjacent frames
        %Then check adjacent at all, use this to build a radius of acceptable
        %centers to further filter stats; if only 1, then good
        adjToCheck = [auto_frames(corrFrame)-1 auto_frames(corrFrame)+1];
        autoQueued = auto_frames(corrFrame:end);
        
        wasSkipped = [any(skipped==adjToCheck(1)) any(skipped==adjToCheck(2))];
        isFirst = adjToCheck==1;
        isLast = adjToCheck==length(Xpix);
        inQueue = [any(autoQueued==adjToCheck(1)) any(autoQueued==adjToCheck(2))];
        isZero = [xAVI(adjToCheck(1))==0 & yAVI(adjToCheck(1))==0,...
                    xAVI(adjToCheck(2))==0 & yAVI(adjToCheck(2))==0];
        
        passedChecks = wasSkipped + isFirst + isLast + inQueue + isZero;
        passedChecks = passedChecks==0; %only points that don't fail any checks
        adjUse = adjToCheck(passedChecks);
        
        tryAdjXs = xAVI(adjUse);
        tryAdjYs = yAVI(adjUse);
        
        %NearOneDG = stats(find(sum(DefGoodDist,2)>=1);
        %stats = stats(NearOneDG);
        tryCenters = reshape([stats.Centroid],2,length(stats))';
        tryDist = zeros(length(stats),length(tryAdjXs)+isempty(tryAdjXs));
        if any(adjUse)
        for tryAdjInd = 1:length(tryAdjXs)
            tryDist(:,tryAdjInd) = ...
                hypot(tryCenters(:,1)-tryAdjXs(tryAdjInd), tryCenters(:,2)-tryAdjYs(tryAdjInd));
        end
        end
        
        tryGoodDist = tryDist <= distLim2;
        %tryNearBoth = find(sum(tryGoodDist,2)==length(tryAdjXs));
        tryNearBoth = sum(tryGoodDist,2)==length(tryAdjXs);
        if sum(tryNearBoth)==1
            xm = stats(tryNearBoth).Centroid(1);
            ym = stats(tryNearBoth).Centroid(2);
            fixedThisFrameFlag = 1;
            got=[got; corrFrame];
        elseif sum(NearBothDG & tryNearBoth)==1
            xm = stats(NearBothDG & tryNearBoth).Centroid(1);
            ym = stats(NearBothDG & tryNearBoth).Centroid(2);
            fixedThisFrameFlag = 1;
            got=[got; corrFrame];
        end
        
        
        %If all above fails, drop back into old logic (now in PPMP2,
        if fixedThisFrameFlag==0
            stats=[];
            d = imgaussfilt(flipud(rgb2gray(v0-v)),10);
            stats = regionprops(d>willThresh & mazeMask,'area','centroid',...
                'majoraxislength','minoraxislength');%flipped %'solidity'
            MouseBlob = [stats.Area] > 250 & ... %[stats.Area] < 3500...
                        [stats.MajorAxisLength] > 10 & ...
                        [stats.MinorAxisLength] > 10;
            stats=stats(MouseBlob);
        
            %Sam's gray version
            grayFrameThresh = rgb2gray(flipud(v)) < grayThresh; %flipud
            grayGaussThresh = imgaussfilt(double(grayFrameThresh),10) > gaussThresh;
            maybeMouseGray = grayGaussThresh & maze & expectedBlobs; %To handle background gray
            grayStats = regionprops(maybeMouseGray,'centroid','area','majoraxislength','minoraxislength'); %flipped
            grayStats = grayStats( [grayStats.Area] > grayBlobArea &...
                       [grayStats.MajorAxisLength] > grayLength &...
                       [grayStats.MinorAxisLength] > grayLength);

                       
            possible=[];
            switch ~isempty(grayStats) + ~isempty(stats) 
                case 2 %both have stuff
                    for statsInd=1:length(stats)
                        for grayStatsInd=1:length(grayStats)
                            poRow=size(possible,1)+1;  
                            %possible is [stats_index, graystats_index, distance]
                            %probably some way to do this more elegantly
                            possible(poRow,1:3)=[statsInd grayStatsInd...
                            hypot(stats(statsInd).Centroid(1)-grayStats(grayStatsInd).Centroid(1),...
                            stats(statsInd).Centroid(2)-grayStats(grayStatsInd).Centroid(2))]; %#ok<AGROW>
                        end 
                    end
                    possible( possible(:,3)>distLim2, :) = []; 
                    if size(possible,1)==1
                        %Will and thresh agree on one blob
                        xm=mean([stats(possible(1)).Centroid(1) grayStats(possible(2)).Centroid(1)]);
                        ym=mean([stats(possible(1)).Centroid(2) grayStats(possible(2)).Centroid(2)]);
                        fixedThisFrameFlag=1;
                        got=[got; corrFrame];
                    elseif size(possible,1)==0 %If logic here may not be right...
                        if length(stats)==1 && length(grayStats)>1 %DON'T LIKE THIS
                                xm = stats.Centroid(1);
                                ym = stats.Centroid(2);
                                fixedThisFrameFlag=1;
                        elseif length(stats)>1 && length(grayStats)==1 %DON'T LIKE THIS
                                xm = grayStats.Centroid(1);
                                ym = grayStats.Centroid(2);
                                fixedThisFrameFlag=1;
                        else
                            if auto_frames(corrFrame)==1
                                    [xm,ym]=ManualOnlyCorr;
                            elseif pass==2 && auto_frames(corrFrame)~=1
                                    %Should it be do a last frame check and see which
                                    %is really close? Or try will, if that fails try gray
                                    [xm,ym] = EnhancedManualCorrect;
                            elseif pass==1 && auto_frames(corrFrame)~=1
                                    %Here too?
                                    skipped = [skipped; auto_frames(corrFrame)]; 
                                    fixedThisFrameFlag=0;
                            end    
                        end
                    elseif size(possible,1)>1 
                        %more than one blob will and thresh agree on
                        for posNum=1:size(possible,1)
                            putativeMouseX(posNum) = mean([stats(possible(posNum,1)).Centroid(1)...
                                grayStats(possible(posNum,2)).Centroid(1)]); 
                            putativeMouseY(posNum) = mean([stats(possible(posNum,1)).Centroid(2)...
                                grayStats(possible(posNum,2)).Centroid(2)]); 
                        end

                        TryAdjacentFrames;
                    end

                case 1  %only one is empty
                    %either grayStats or will stats is empty
                    %A: whichever is not, use blob closest to last known good
                    if ~isempty(grayStats) && isempty(stats)
                        blobStats=grayStats;
                    elseif isempty(grayStats) && ~isempty(stats)    
                        blobStats=stats;
                    end

                        for posNum=1:size(blobStats,1)
                            putativeMouseX(posNum) = blobStats(posNum).Centroid(1); 
                            putativeMouseY(posNum) = blobStats(posNum).Centroid(2); 
                        end

                        TryAdjacentFrames;
                case 0 %isempty(grayStats) && isempty(stats)
                    switch pass
                        case 1
                            skipped = [skipped; auto_frames(corrFrame)]; 
                        case 2
                            [xm,ym] = EnhancedManualCorrect;
                    end
            end    
        end
        %starting to be generalized here
        
        %Fix this later, get moving now
        %{
        %if still more than 1, check gray ones
    grayGaussThresh = grayGauss  > gaussThresh;
    maybeMouseGray = grayGaussThresh & expectedBlobs & mazeMask; %To handle background gray maze & 
    grayStats = regionprops(maybeMouseGray,'centroid','area','majoraxislength','minoraxislength'); %flipped
    grayStats = grayStats( [grayStats.Area] > grayBlobArea &...
                       [grayStats.MajorAxisLength] > 15 &...
                       [grayStats.MinorAxisLength] > 15);
    
    if ~isempty(grayStats)
        statsTry=length(stats);%+double(length(stats)==0); %this was for generalizing...
        grayTry=length(grayStats);%+double(length(grayStats)==0);
        possible=zeros(statsTry*grayTry, 3);
        statsInds = repmat([1:statsTry],grayTry,1);
        grayInds = repmat([1:grayTry],1,statsTry);
        
    else
        %????????
    end
        %}
    if fixedThisFrameFlag==0
        if pass==1
            skipped = [skipped; auto_frames(corrFrame)];
        else
            [xm,ym] = EnhancedManualCorrect;
        end
    end
    end
end

if fixedThisFrameFlag==1
    FixFrame(xm,ym) 
            
    hold(ManualCorrFig.Children,'on')  
    plot(ManualCorrFig.Children,xm,ym,marker{markWith},'MarkerSize',4,...
        'MarkerFaceColor',marker_face{markWith})
    hold(ManualCorrFig.Children,'off')  
    
    if drawnowEnable==1
    drawnow
    end
    if update_pos_realtime==1
        % pause(0.10)
    end
end

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CorrectManualFrames(~,~)
global obj; global aviSR; global v; global ManualCorrFig; global markWith;
global fixedThisFrameFlag;
global auto_frames; global corrFrame; global corrDefGoodFlag; global definitelyGood

marker = {'go' 'yo' 'ro'};
marker_face = {'g' 'y' 'r'};
bounds=[0 floor(length(auto_frames)/3) 2*floor(length(auto_frames)/3)];
       
for corrFrame=1:length(auto_frames)
    obj.CurrentTime=(auto_frames(corrFrame)-1)/aviSR;
    v = readFrame(obj); 
    
    markWith=sum(corrFrame>bounds);
    %if Xpix(auto_frames(corrFrame)) ~= 0 && Ypix(auto_frames(corrFrame)) ~= 0
    %       plot(xAVI(auto_frames(corrFrame)),yAVI(auto_frames(corrFrame)),marker{markWith},'MarkerSize',4);
    %end  
    fixedThisFrameFlag=0;
    if corrDefGoodFlag==1 || definitelyGood(auto_frames(corrFrame))==0        
        [xm,ym]=EnhancedManualCorrect;   
    end        
    
    if fixedThisFrameFlag==1
        FixFrame(xm,ym)
        
        hold(ManualCorrFig.Children,'on')  
        plot(ManualCorrFig.Children,xm,ym,marker{markWith},'MarkerSize',4,...
            'MarkerFaceColor',marker_face{markWith})
        hold(ManualCorrFig.Children,'off')
    end    
end
 
UpdatePosAndVel;

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdatePosAndVel(~,~)
global PosAndVel; global vel_init; global time; global Xpix; global Ypix;
global MoMtime; global auto_vel_thresh; global excludeFromVel;
    
try
    figure(PosAndVel);
catch
    PosAndVel=figure('name','Position and Velocity');
end
vel_init = hypot(diff(Xpix),diff(Ypix))./diff(time);%(time(2)-time(1));

forcedExclude = find(excludeFromVel(1:length(vel_init)));
vel_init(forcedExclude) = min(vel_init);

velInds=1:length(vel_init);
hx0 = subplot(4,3,1:3);plot([1:length(Xpix)],Xpix);xlabel('time (sec)');ylabel('x position (cm)');yl = get(gca,'YLim');
    line([MoMtime MoMtime], [yl(1) yl(2)],'Color','r');axis tight;
hy0 = subplot(4,3,4:6);plot([1:length(Ypix)],Ypix);xlabel('time (sec)');ylabel('y position (cm)');yl = get(gca,'YLim');
    line([MoMtime MoMtime], [yl(1) yl(2)],'Color','r');axis tight;
hVel = subplot(4,3,7:12);plot(velInds,vel_init);xlabel('time (sec)');ylabel('velocity');axis tight; %#ok<NASGU>

hold on 
plot(velInds(vel_init>auto_vel_thresh),vel_init(vel_init>auto_vel_thresh),'or'); hold off
linkaxes([hx0 hy0],'x');
hline=refline(0,auto_vel_thresh);hline.Color='r';hline.LineWidth=1.5;
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SaveTemp(~,~)
global MoMtime; global MouseOnMazeFrame; global maskx; global masky
global definitelyGood; global xAVI; global yAVI; global Xpix; global Ypix;
global maze; global expectedBlobs; global v0; global mazeEl; global elVector;
global bstr; global allTxt; global bframes; global willThresh; global grayThresh;
global gaussThresh; global time; global auto_vel_thresh; global excludeFromVel

save Pos_temp.mat Xpix Ypix xAVI yAVI MoMtime MouseOnMazeFrame maskx v0 maze masky...
    definitelyGood expectedBlobs mazeEl elVector bstr allTxt bframes willThresh...
    grayThresh gaussThresh time auto_vel_thresh excludeFromVel

disp('Saved!')
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ClearStuff(~,~)
global MoMtime; global MouseOnMazeFrame; global maskx; global masky
global definitelyGood; global xAVI; global yAVI; global Xpix; global Ypix;
global maze; global expectedBlobs; global v0; global mazeEl; global elVector;
global bstr; global allTxt; global bframes; global willThresh; global grayThresh;
global gaussThresh; global time; global auto_vel_thresh; global excludeFromVel;

clear Xpix Ypix xAVI yAVI MoMtime MouseOnMazeFrame maskx v0 maze masky...
    definitelyGood expectedBlobs mazeEl elVector bstr allTxt bframes willThresh...
    grayThresh gaussThresh time auto_vel_thresh excludeFromVel
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function getELvector(~,~)
global elVector; global elChoiceFlag; global xAVI; global v0; global mazeEl;
global maze; global maskx; global masky; global bstr; global allTxt; global bframes;
global mazeElInd; global mazeUp

if isempty(bstr)
    LoadBehavior;
end

elVector=ones(length(xAVI),1);
mazeEl(1).maze=maze; mazeEl(1).maskx=maskx; mazeEl(1).masky=masky;

doneGettingEls=0;
mazeUp=1;
while doneGettingEls==0
    mazeElInd=mazeUp+1;

    addAnElMask;
    
    doneChoice = questdlg('Done with expected locations or another?','Done predicting?',...
                    'Done','Another!','Done');
    switch doneChoice
        case 'Done'
            doneGettingEls=1;
        case 'Another!'
            mazeUp=mazeUp+1;
            doneGettingEls=0;
    end
    SaveTemp;
end
    
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function editELvectors(~,~)
global elVector; global elChoiceFlag; global v0; global mazeEl;
global maze; global maskx; global masky; global mazeElInd; global bstr

doneWithEl=0;
while doneWithEl==0
    for figg = 1:length(mazeEl)
        MazesFigs(figg).figg=figure; imagesc(flipud(v0)); 
        hold on; plot([mazeEl(figg).maskx; mazeEl(figg).maskx(1)],...
            [mazeEl(figg).masky; mazeEl(figg).masky(1)],'r','LineWidth',1); hold off 
        switch figg==1
            case 1
                title('mazeEl index #1 original maze mask')
            case 0
                %title(['mazeEl index # ' num2str(figg)])
                title(['mazeEl index # ' num2str(figg) ', '...
                    bstr(mazeEl(figg).choices(1)) ' - ' bstr(mazeEl(figg).choices(2))]);
        end
    end
    
    disp('d, delete; e, edit; a, enable/disable; r, redraw original maze mask; h, add a mask; n, done')
    disp('also, close expected figures before making a choice')
    editEl = input('How to edit expected location vectors?','s');
    switch editEl
        case 'e' %edit one of them
            editThis = input('enter num of expected location to redraw') %#ok<NOPRT>
            if strcmpi(class(editThis),'double')
            if editThis > 1 && editThis <= length(mazeEl)
                mazeMaskGood=0;
                while mazeMaskGood==0
                    MazeFig=figure('name', 'Expected Location Mask'); imagesc(flipud(v0));
                    title(['Draw position mask for ' num2str(editThis)]);
                    [mazeEl(editThis).maze, mazeEl(editThis).maskx, mazeEl(editThis).masky] = roipoly;
                        hold on; plot([mazeEl(editThis).maskx; mazeEl(editThis).maskx(1)],...
                        [mazeEl(editThis).masky; mazeEl(editThis).masky(1)],'r','LineWidth',1); hold off 

                    mchoice = questdlg('Is this boundary good?', 'Maze Mask', 'Yes','No redraw','Yes');
                    switch mchoice
                        case 'Yes'
                            disp('Proceeding with this mask')
                            mazeMaskGood=1;
                        case 'No redraw'
                            mazeMaskGood=0;
                    end
                end 
                close(MazeFig)
            end
            end
        case 'd' %delete one of them
            deleteThis = input('enter num of expected location to delete') %#ok<NOPRT>
            if strcmpi(class(deleteThis),'double')
            if deleteThis > 1 && deleteThis <= length(mazeEl)
                mazeEl(deleteThis)=[];
                elVector(elVector==deleteThis)=1;
                elVector(elVector>deleteThis)=elVector(elVector>deleteThis)-1;
                disp(['deleted expected location ' num2str(deleteThis)...
                    ', those points reset to original mask'])
            elseif deleteThis == 1
                disp('Nope, that is the original maze mask')
            end
            end
        case 'a' %enable/disable using maze expected locations
            switch elChoiceFlag
                case 1
                    elChoiceFlag=0; disp('expected locations disabled')
                case 0
                    elChoiceFlag=1; disp('expected locations enabled')
            end
        case 'r' %redraw original maze mask
            MaskFig=figure('name', 'Cage Mask'); imagesc(flipud(v0));
            title('Draw position mask');
            [maze, maskx, masky] = roipoly;
            hold on; plot([maskx; maskx(1)],[masky; masky(1)],'r','LineWidth',2)

            cageMaskGood=0;
            while cageMaskGood==0
                figure(MaskFig); title('Cage Mask')
                choice = questdlg('Is this cage mask good?', ...
                'Cage Mask', ...
                'Yes','No redraw','Yes');
                switch choice
                    case 'Yes'
                    disp('Proceeding with this cage mask')
                    cageMaskGood=1;
                    case 'No redraw'
                        figure(MaskFig); imagesc(flipud(v0));
                        title('Draw position mask');
                        [maze, maskx, masky] = roipoly;
                        hold on; plot([maskx; maskx(1)],[masky; masky(1)],'r','LineWidth',2)
                        cageMaskGood=0;       
                end
            end 
            close(MaskFig)
            mazeEl(1).maze=maze; mazeEl(1).maskx=maskx; mazeEl(1).masky=masky;
            disp('Redid original maze mask')
        case 'h' %add a mask
            mazeElInd=length(mazeEl)+1;
            addAnElMask;
        case 'n'
            doneWithEl=1; 
    end
    close(MazesFigs.figg)
    clear MazesFigs
end

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function addAnElMask(~,~)
global elVector; global elChoiceFlag; global xAVI; global v0; global mazeEl;
global maze; global maskx; global masky; global bstr; global allTxt; global bframes;  
global mazeElInd; global mazeUp; global chooseStrs; global starts; global stops;
global beOptions; global allstarts; global allstops; global choices

chooseStrs = bstr;
ChooseStartsStops;
s=choices; %grrrrr

if sum(starts)==0 || sum(stops)==0
    disp('problem, returned 0s')
    keyboard
end

mazeEl(mazeElInd).choices = choices;

%while beOptions >= 0
    
mazeMaskGood=0;
while mazeMaskGood==0
    MazeFig=figure('name', 'Expected Location Mask'); imagesc(flipud(v0));
    title(['Draw position mask for ' bstr(s(1)) ' - ' bstr(s(2))]);
    [mazeEl(mazeElInd).maze, mazeEl(mazeElInd).maskx, mazeEl(mazeElInd).masky] = roipoly;
    hold on; plot([mazeEl(mazeElInd).maskx; mazeEl(mazeElInd).maskx(1)],...
        [mazeEl(mazeElInd).masky; mazeEl(mazeElInd).masky(1)],'r','LineWidth',1); hold off 

        mchoice = questdlg('Is this boundary good?', 'Maze Mask', 'Yes','No redraw','Yes');
    switch mchoice
        case 'Yes'
            disp('Proceeding with this mask')
            mazeMaskGood=1;
        case 'No redraw'
            mazeMaskGood=0;
    end
end 
close(MazeFig)
    
    %set vector at these frames to ref the appropriate mask
    for tri=1:numel(starts)
        elVector(starts(tri):stops(tri)) = mazeElInd;
    end
    %{
    if length(beOptions) > 0 %#ok<ISMT>
        flugChoice = questdlg('Found more behavior flags. Do them, same bounds?', 'More flags', ...
                              'Yes','No','Yes');  
        switch flugChoice
            case 'Yes'
                bChoices(flug) = [];
                [flug,~] = listdlg('PromptString',':',...
                           'SelectionMode','single','ListString',bChoices);    
                LRmod = strcmpi(allTxt(2:end,t+1),bChoices(flug));
                
                starts = allstarts; starts(LRmod==0)=[];
                stops = allstops; stops(LRmod==0)=[];
           
                if length(bChoices) > 1
                    mazeUp=mazeUp+1;
                    mazeElInd=mazeUp+1;
                end
            case 'No'
            beOptions = 0;
        end
    end
    
    beOptions = beOptions - 1;
    %}
%end

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ChooseStartsStops(~,~)
global chooseStrs; global starts; global stops; global beOptions;
global bChoices; global allTxt; global bframes; global allstarts;
global allstops; global choices; global xAVI

if size(chooseStrs,1)==1 && sum(cellfun(@ischar, chooseStrs))/size(chooseStrs,2)==1

selectedTwo=0;
for tt = 1:2
    [choices(tt),~] = listdlg('PromptString',['Select timestamps #' num2str(tt) ':'],...
                'SelectionMode','single',...
                'ListString',chooseStrs);
end
   % if length(choices)==2; selectedTwo=1; end

    
[ss,~] = listdlg('PromptString','Which comes first:',...
                    'SelectionMode','single',...
                    'ListString',[chooseStrs(choices(1)) chooseStrs(choices(2))]);
if ss==2; holder=choices(1); choices(1)=choices(2); choices(2)=holder; end

allstarts = bframes(:,choices(1));
allstops = bframes(:,choices(2));

%Could be generalized for other markers, right now needs to read strings
dirChoice = questdlg('Restrict to left/right trials?','LR mod?',...
                    'Yes','No','Yes');
switch dirChoice
    case 'Yes'
        choiceGood=0;
        while choiceGood==0
        [t,~] = listdlg('PromptString','Choose column with behavior:',...
                    'SelectionMode','single','ListString',chooseStrs);
            
        bChoices = unique(allTxt(2:end,t));
        if sum(cellfun(@isempty,bChoices))==length(bChoices)
            mc = questdlg('Misclick?','Bad markers','Misclick','debug','Misclick');    
            switch mc
                case 'Misclick'
                    choiceGood = 0;
                case 'debug'
                    keyboard
            end
        else
            choiceGood = 1;
        end
        
        end
        [flug,~] = listdlg('PromptString','Which flag:',...
                    'SelectionMode','single','ListString',bChoices);    
        LRmod = strcmpi(allTxt(2:end,t),bChoices(flug));
            
        beOptions = length(bChoices) - 1;    
    case 'No'
        LRmod = ones(size(bframes,1),1);
        beOptions = 0;
end
    
starts=allstarts; starts(LRmod==0)=[];
stops=allstops; stops(LRmod==0)=[];

if sum(starts)==0 || sum(stops)==0
    disp('problem, returned 0s')
    keyboard
end

for aa = 1:2
    bumpFr = questdlg(['Bump ' chooseStrs{choices(aa)} ' forward or back?'],'bump frames',...
        'Forward','Back','No','No');
    bump = 0;
    if strcmpi(bumpFr,'Forward') || strcmpi(bumpFr,'Back')
        bump = str2double(cell2mat(inputdlg('How many frames?')));
        if strcmpi(bumpFr,'Back')
            bump = bump*-1;
        end
    end
    switch aa
        case 1
            starts = starts + bump;
        case 2
            stops = stops + bump;
    end
end

if any(starts>length(xAVI)) || any(stops>length(xAVI))
    disp('Look out, some frames in the spreadsheet are longer than the video')
    starts(starts>length(xAVI)) = length(xAVI);
    stops(stops>length(xAVI)) = length(xAVI);
end
if any(starts<1) || any(stops<1)
    disp('Look out, some frames in the spreadsheet are less than 1??')
    starts(starts<1) = 1;
    stops(stops<1) = 1;
end
    
else
    disp('sorry, input strs needs to be 1 x n cell of strs')
end

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function ZeroBounds(~,~)
global auto_frames; global Xpix; global Ypix; global elChoiceFlag; global mazeEl;
global xAVI; global yAVI; global maskx; global masky; global elInds; global definitelyGood;
global numPasses; global elVector; global excludeFromVel

auto_frames=[];
zero_frames = Xpix == 0 | Ypix == 0 ;
if any(zero_frames)
reported = {['Found ' num2str(sum(zero_frames)) ' points at (0, 0)']};
    zerochoice = questdlg(reported,'Fix bad points',...
                           'FixEm','Skip','FixEm');
    switch zerochoice
        case 'FixEm'
            auto_frames = [auto_frames; find(zero_frames)];
        case 'Skip'
            %do nothing
    end
end      

%out of bounds for each submask

switch elChoiceFlag
    case 0
        [in,on] = inpolygon(xAVI, yAVI, maskx, masky);
        inBounds = in | on;
    case 1
        inBounds = zeros(length(xAVI),1);
        for ml=1:length(mazeEl)
            elInds = find(elVector==ml);
            [inHere, onHere] = inpolygon(xAVI(elInds), yAVI(elInds), mazeEl(ml).maskx, mazeEl(ml).masky);
            fixTheseEl = inHere | onHere;
            fixx=elInds(fixTheseEl);
            inBounds(fixx) = 1;
        end
end
outOfBounds = inBounds==0;
outOfBounds(zero_frames) = 0;
alreadyGood = outOfBounds & definitelyGood;
outOfBounds = outOfBounds & (definitelyGood==0);

if any(outOfBounds)
    badPoints = figure; plot(xAVI, yAVI, '.')
    hold on
    plot(xAVI(alreadyGood), yAVI(alreadyGood), '.g')
    plot(xAVI(outOfBounds), yAVI(outOfBounds), '.r')
    hold off
    sum(zero_frames & definitelyGood)
    reported = {['Found ' num2str(sum(outOfBounds)) ' points out of bounds, '...
                num2str(sum(alreadyGood)) ' are already def good']};
    oochoice = questdlg(reported,'Fix bad points',...
                           'FixEm','Skip','FixEm');
                       
    %add case: label all definitely good
    switch oochoice
        case 'FixEm'
            auto_frames = [auto_frames; find(outOfBounds)];
        case 'Skip'
            %do nothing
            close(badPoints);
    end
end

if any(auto_frames)
    auto_frames = sort(auto_frames);
    if any(excludeFromVel)
        disp('There are points here marked to be excluded.')
        [~,ia,~] = intersect(auto_frames,excludeFromVel); %returns index vectors ia and ib.
        auto_frames(ia) = [];
    end
    try
    close(badPoints);
    end
    numPasses=2;
    %if length(auto_frames) > 500
    %    auto_chunks = 
    
    CorrectTheseFrames;
end

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function BehaviorFrames(~,~)
global chooseStrs; global starts; global stops;
global bstr; global auto_frames; global numPasses;
global corrDefGoodFlag; global choices;

chooseStrs = bstr;
ChooseStartsStops;

crossLap = questdlg('Are these across a lap? If so, will shift second col down one','Cross lap',...
                    'Across','No','No');
switch crossLap
    case 'No'
        %do nothing
    case 'Across'
        starts = starts(1:end-1);
        stops = stops(2:end);
end

auto_frames = [];
skipB = [];
for nStarts = 1:length(starts)
    auto_frames = starts(nStarts):stops(nStarts); 
    
    fixem = questdlg([num2str(length(auto_frames)) ' frames ' num2str(auto_frames(1))...
        ' to ' num2str(auto_frames(end)) '. Do it?'], 'Behavior Pass',...
        'FixEm', 'Skip', 'FixEm');
    switch fixem
        case 'FixEm'
            doIt=1;
        case 'Skip'
            skipB = [skipB; starts(nStarts) stops(nStarts)]; %#ok<AGROW>
            doIt=0;
    end
    
    if doIt==1
        manCho = questdlg('Fix these points manually or auto-assist?','Fix bad points',...
                                   'Manual','Auto','Cancel','Manual');
        switch manCho
            case 'Manual'
                disp(['You are currently editing ' num2str(length(auto_frames)) ' frames'])
                manChoice = questdlg('Redo definitely good frames?','Redo DefGood',...
                            'Yes','No','No');
                switch manChoice
                    case 'Yes'
                        corrDefGoodFlag=1;
                    case 'No'
                        corrDefGoodFlag=0;
                end
                CorrectManualFrames;
            case 'Auto'
                numPasses = 2;
                CorrectTheseFrames;
            case 'Cancel'
            %do nothing
        end
    end
end

if any(skipB)
    skipB %#ok<NOPRT>
end
%Could re-add the code to auto flag and use other behaviors from addAnElMask

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LoadBehavior(~,~)
global bstr; global allTxt; global bframes

doneLoading=0; 
loaded=1;
while doneLoading==0
    [xlsFile, xlsPath] = uigetfile('*.xlsx', 'Select file with behavior times');
    [frameses(loaded).frames, txt(loaded).txt] = xlsread(fullfile(xlsPath,xlsFile), 1); %#ok<AGROW>
    
    loadChoice = questdlg('Done loading sheets or another?','Done loading?',...
                    'Done','Another!','Done');
    switch loadChoice
        case 'Done'
            doneLoading=1;
        case 'Another!'
            loaded=loaded+1;
            doneLoading=0;
    end
end 

%doesn't give lap number column
bstr = {}; allTxt = {}; bframes = [];
for lvl=1:loaded
    bstr = [bstr txt(lvl).txt(1,1:end)]; %#ok<AGROW>
    allTxt = [allTxt txt(lvl).txt(:,:)]; %#ok<AGROW>
    bframes = [bframes frameses(lvl).frames(:,1:end)]; %#ok<AGROW>
end

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SetVelocityThresh(~,~)
global vel_init; global auto_vel_thresh; 

velthreshing=figure; plot(vel_init)
title(['suggested velocity threshold: ' num2str(auto_vel_thresh)])
hline=refline(0,auto_vel_thresh);
hline.Color='r';
hline.LineWidth=1.5;
    
choice = questdlg('Is this velocity threshold good?', ...
'Velocity Threshold', ...
'Yes','No > ginput','Yes');

velLineGood=0;
while velLineGood==0
    switch choice
        case 'Yes'
            disp(['Proceeding with velocity threshold ' num2str(auto_vel_thresh)])
            velLineGood=1;
        case 'No > ginput'
            figure(velthreshing);
            [~,user_vel_thresh] = ginput(1);
            plot(vel_init)
            hline = refline(0,user_vel_thresh); hline.Color='r'; hline.LineWidth=1.5;
            choice2 = questdlg('Is this velocity threshold good?', ...
                                'Velocity Threshold', ...
                                'Yes','No > ginput','Yes');
            switch choice2
                case 'Yes'
                    velLineGood=1;
                    auto_vel_thresh=user_vel_thresh;
                case 'No > ginput'
                    velLineGood=0;
            end        
    end
end
close(velthreshing) 
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MarkForExclude(~,~)
global definitelyGood; global excludeFromVel; global starts; global stops;
global bstr; global allTxt; global bframes; global chooseStrs;

goodFrames = [];
exMethod = questdlg('How do you want to label frames?', 'Exclude frames', ...
'Number','Behavior flags','Cancel','Behavior flags');
switch exMethod
    case 'Number'
        prompt = {'Exclude start:','Exclude end:'};
        defaultans = {'25325','57870'};
        answer = inputdlg(prompt,'Mark by frame numbers',1,defaultans);
        answer=cell2mat(cellfun(@str2num,answer,'UniformOutput',false));
        
        if length(answer)==1
            goodFrames = answer;
        elseif length(answer)==2
            if answer(1)==answer(2)
                goodFrames = answer(1);
            else 
                goodFrames = answer(1):answer(2);
            end
        end
    case 'Behavior flags'
        chooseStrs = bstr;
        ChooseStartsStops;
        crossLap = questdlg('Are these across a lap? If so, will shift second col down one','Cross lap',...
                    'Across','No','No');
        switch crossLap
            case 'No'
                %do nothing
            case 'Across'
                starts = starts(1:end-1);
                stops = stops(2:end);
        end
        for nn = 1:length(starts)
            goodFrames = [goodFrames, starts(nn):stops(nn)]; %#ok<AGROW>
        end
    case 'Cancel'
        %Do nothing
end

if any(goodFrames)
     areyousure = questdlg(['This will label ' num2str(length(goodFrames))...
         ' frames to exclude from correction. Continue?'], 'Exclude frames', ...
         'Yes','No','Yes');
    switch areyousure
        case 'Yes'
            definitelyGood(goodFrames) = 1;
            excludeFromVel(goodFrames) = 1;
            %{
            switch exMethod
            %disp(['Excluded ' num2str(length(goodFrames)) ' as good,' from
            flag to flag
            %}
            %Question here is whether next frame needs to be excluded too
        case 'No'
            %Do nothing
    end
end

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PlotVelLine(~,~)
global ManualCorrFig; global auto_vel_thresh; global aviSR;

hold(ManualCorrFig.Children,'on')
plot(ManualCorrFig.Children,[50 50+auto_vel_thresh/aviSR], [60 60],'r','LineWidth',1)
plot(ManualCorrFig.Children,[50 50],[55 65],'r','LineWidth',1)
plot(ManualCorrFig.Children,[50+auto_vel_thresh/aviSR 50+auto_vel_thresh/aviSR],[55 65],'r','LineWidth',1)
hold(ManualCorrFig.Children,'off')  
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DealWithBackgroundImage(~,~)
global v0; global avi_filepath; global obj;

if exist('v0','var') 
    if ~isempty(v0) 
        backgroundImage=v0; 
        backgroundFrame=figure('name','backgroundFrame'); imagesc(backgroundImage); title('Background Image')
        makeChoice = questdlg('Found a background image; use or make a new one?','bkg',...
            'Use','Remake','Use');
            switch makeChoice
                case 'Use'
                    makebackground=0;
                case 'Remake'
                    makebackground=1;
            end
        close backgroundFrame
    else
        makebackground=1;
    end
elseif ~exist('v0','var') || any(v0(:))==0 %need the any since declaring as global
    makebackground=1;
end

if makebackground==1
bkgChoice = questdlg('Supply/Load background image or composite?', ...
	'Background Image', ...
	'Load','Frame #','Composite','Composite');
    switch bkgChoice
    case 'Load'    
        [backgroundImage,bkgpath]=uigetfile('Select background image');
        load(fullfile(bkgpath,backgroundImage))
    case 'Frame #'
        try
            h1 = implay(avi_filepath);
        catch
            avi_filepath = ls('*.avi');
            h1 = implay(avi_filepath);
        end
        bkgFrameNum = input('frame number of mouse-free background frame??? --->');
        obj.CurrentTime = (bkgFrameNum-1)/obj.FrameRate;
        backgroundImage = readFrame(obj);
        backgroundFrame=figure('name','backgroundFrame'); imagesc(backgroundImage); title('Background Image')
        compositeBkg = backgroundImage;
        %could break here to allow fixing a piece of this one
    case 'Composite'
        try
            h1 = implay(avi_filepath);
        catch
            avi_filepath = ls('*.avi');
            h1 = implay(avi_filepath);
        end    
        msgbox({'Find images: ' '   -frame 1: top half has no mouse' '   -frame 2: bottom half has no mouse'})
        %prompt = {'No mouse on top frame:','No mouse on bottom frame:'};
        %dlg_title = 'Clear frames';
        %num_lines = 1;
        %clearFrames = inputdlg(prompt,dlg_title,num_lines);
        
        topClearNum = input('Frame number with no mouse on top: ') %#ok<NOPRT>
        bottomClearNum = input('Frame number with no mouse on bottom: ') %#ok<NOPRT>
        
        obj.CurrentTime = (topClearNum-1)/obj.FrameRate;
        topClearFrame = readFrame(obj);
        obj.CurrentTime = (bottomClearNum-1)/obj.FrameRate;
        bottomClearFrame = readFrame(obj);
        Top=figure('name','Top'); imagesc(topClearFrame); %#ok<NASGU>
            title(['Top Clear Frame ' num2str(topClearNum)]) 
        Bot=figure('name','Bot'); imagesc(bottomClearFrame); %#ok<NASGU>
            title(['Bottom Clear Frame ' num2str(bottomClearNum)]) 
        compositeBkg=uint8(zeros(480,640,3));
        compositeBkg(1:240,:,:)=topClearFrame(1:240,:,:);
        compositeBkg(241:480,:,:)=bottomClearFrame(241:480,:,:);
        close Top; close Bot;
        %backgroundFrame=figure('name','backgroundFrame'); imagesc(compositeBkg); title('Composite Background Image')
        backgroundImage=compositeBkg;
    end
end

bkgNotFlipped=0;
while bkgNotFlipped==0
    backgroundFrame=figure('name','backgroundFrame'); imagesc(backgroundImage); title('Background Image')
    bkgNormal = questdlg('Is the background image right-side up?', 'Background Image', ...
                              'Yes','No','Yes');               
        switch bkgNormal
            case 'Yes'
                bkgNotFlipped=1;
            case 'No'
                backgroundImage=flipud(backgroundImage);
        end
end     

try %#ok<*TRYNC>
    close(h1);
end

compGood=0;
while compGood==0
    holdChoice = questdlg('Good or fix a piece?', 'Background Image', ...
                              'Good','Fix area','Good');               
    switch holdChoice
        case 'Good'
            try %#ok<*TRYNC>
                close(h1);
            end
            compGood=1;
        case 'Fix area'
            try %#ok<*TRYNC>
                close(h1);
            end
            figure(backgroundFrame); title('Select area to swap out')
            [swapRegion, SwapX, SwapY] = roipoly;
            hold on 
            plot([SwapX; SwapX(1)],[SwapY; SwapY(1)],'r','LineWidth',2)
            h1 = implay(avi_filepath);
            swapInNum = input('Frame number to swap in area from ---->')%#ok<NOPRT> 
            %might replace with 2 field dialog box
            obj.CurrentTime = (swapInNum-1)/obj.FrameRate;
            swapClearFrame = readFrame(obj);
            [rows,cols]=ind2sub([480,640],find(swapRegion));
            backgroundImage(rows,cols,:)=swapClearFrame(rows,cols,:);
            figure(backgroundFrame);imagesc(backgroundImage)
            compGood=0;
    end
end
v0 = backgroundImage; %Comes out rightside up
close(backgroundFrame);

end
%%

%{
BoneYard

%}