function [xpos_interp,ypos_interp,time_interp,AVItime_interp] = PreProcessMousePosition_autoSL3(varargin);
% Open issues: 1/11/17
%   
%   - Logic for possible: could be generalized better
%   - Check for an adjacent definitelyGood frame, use that to limit
%   possible blobs
%   - Video of results
%   - Blob restrictions for will and gray
%   - contrast adjustment
%   - select points by midpoint between frames to help catch not high
%   velocity wrong things
%   - marker style/color in velocity thing   
%   - could add a generous 'Will's blobs have to be in a grayish region'
%   to prevent using dividers, etc. as blobs
%   - bring back cluster thresh to allow for more frequent saving
%   - velocity threshold may not be working right
%   - something wrong with ManualCorrFig being created multiple times - get(0,'children') 
%   - high velocity detect getting stuck at points
%   - how similar is blob to blob correlating to good position on an
%   adjacent frame?
%   - reject blobs found near current location
%   - other exclude regions (known bad locations)
%
%[xpos_interp,ypos_interp,start_time,MoMtime] = PreProcessMousePosition_auto(filepath, auto_thresh,...)
% Function to correct errors in mouse tracking.  Runs once through the
% entire sessions automatically having you edit any events above a velocity
% threshold (set by 'auto_thresh', suggest setting this to 0.01 or 0.02).
%
% INPUTS
%   filepath: pathname to DVT file. Must reside in the same directory as
%   the AVI file it matches, and there must be only ONE DVT and ONE AVI
%   file in this directory
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
    
if there are elements in both, find how far apart all graystats and
stats are from each other
    
    if there's only one close enough (distLim2), use that one
    if there are none close enough
        if there's only one stats, use that
        if theres only one graystats, use that
        if we're on frame 1 or pass 2
            MANUAL CORRECT
        elseif we're on pass 1, skip this frame
    if there's more than one that are close enough
        if it's not the first frame and we didn't skip the last frame
            get position from the frame before
        if it's not the last frame and the next frame wasn't skipped or
        doesn't need to be corrected
            get position from the next frame
        if we're on frame 1 or pass 2
            MANUAL CORRECT
        elseif we're on pass 1, skip this frame
        
            if we got the position from an adjecent frame, find the shared
            stats/graystats blob that is closest to the adjacent position
                if we can't do that
                    if it's pass 1, skip
                    if it's pass 2
                        MANUAL CORRECT
                            skip/accept functions

else: if either graystats or stats is empty
    if it's not the first frame and we didn't skip the last frame
            get position from the frame before
    if it's not the last frame and the next frame wasn't skipped or
    doesn't need to be corrected
        get position from the next frame
    if we're on frame 1 or pass 2
        MANUAL CORRECT
            skip/accept functions on pass 2
    elseif we're on pass 1, skip this frame

            if we got the position from an adjecent frame, find the shared
            stats/graystats blob that is closest to the adjacent position
                if we can't do that
                    if it's pass 1, skip
                    if it's pass 2
                       MANUAL CORRECT
                        with functions to jump backwards or
                        skip the frame and accept an existing position
                            %can this be used at any other manual correct?
                            %to make this global we need...
                                obj, aviSR
                                auto_frames, corrFrame
                                xAVI,yAVI,Xpix,Ypix
                                definitelyGood, fixedThisFrameFlag
                                MarkerSize, MarkerFace
                                lastManualFrame
                                pass
end

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
global obj; global aviSR; global auto_frames; global corrFrame;
global xAVI; global yAVI; global Xpix; global Ypix; global definitelyGood;
global fixedThisFrameFlag; global numPasses; global v; global maskx;
global masky; global v0; global maze; global lastManualFrame; lastManualFrame=[];
global grayThresh; global gaussThresh; global willThresh; global distLim2;
global got; global skipped; global xm; global ym; global bounds;
global expectedBlobs; global time; global grayBlobArea;
global ManualCorrFig; global overwriteManualFlag; global velCount; global sFrame;
global eFrame; global MoMtime; global vel_init; global auto_vel_thresh;
global velchoice; global AMchoice; global corrDefGoodFlag; global elChoiceFlag;
global elVector; global mazeEl; global bstr; global allTxt; global bframes;
global update_pos_realtime; global blankVector; global isGrayThresh;


%% Get varargin
    
%epoch_length_lim = 200; % default
update_pos_realtime = 1;
max_pixel_jump = 45;
corrDefGoodFlag = 0;
overwriteManualFlag=0;
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
if ~exist('v0','var') || any(v0(:))==0 %need the any since declaring as global
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
        backgroundFrame=figure('name','backgroundFrame'); imagesc(compositeBkg); title('Composite Background Image')
    end
elseif ~isempty(v0) 
    backgroundImage=v0; 
    backgroundFrame=figure('name','backgroundFrame'); imagesc(backgroundImage); title('Background Image')
    %should have checker for is it right orientation
    bkgNotFlipped=0;
    while bkgNotFlipped==0
    bkgNormal = questdlg('Is the background image right-side up?', 'Background Image', ...
                              'Yes','No','No');               
        switch bkgNormal
            case 'Yes'
                bkgNotFlipped=1;
            case 'No'
                backgroundImage=flipud(backgroundImage);
        end
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
            compositeBkg(rows,cols,:)=swapClearFrame(rows,cols,:);
            figure(backgroundFrame);imagesc(compositeBkg)
            compGood=0;
            backgroundImage = compositeBkg;

    end
end
v0 = backgroundImage; %Comes out rightside up
close(backgroundFrame);

%% Position and velocity
vel_init = hypot(diff(Xpix),diff(Ypix))/(time(2)-time(1));
[fv, xv] = ecdf(vel_init);
if exist('auto_thresh','var')
    auto_vel_thresh = min(xv(fv > (1-auto_thresh)));
else
    velthreshing=figure; plot(vel_init)
    auto_vel_thresh = 1500;
    title(['suggested velocity threshold: ' num2str(auto_vel_thresh)])
    hline=refline(0,auto_vel_thresh);
    hline.Color='r';
    hline.LineWidth=1.5;
    
    choice = questdlg('Is this velocity threshold good?', ...
	'Velocity Threshold', ...
	'Yes','No > ginput','Yes');
    % Handle response
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

UpdatePosAndVel;
%% Expected location
elChoice = questdlg('Expected locations?', 'Expected locations', ...
	'Yes','No','Yes');
switch elChoice
    case 'Yes'
        elChoiceFlag=1;
        if length(mazeEl)>0
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

willThresh=20;
grayThresh = 115; 
gaussThresh = 0.2;
isGrayThresh = 0.04;
distLim2 = max_pixel_jump;
grayBlobArea = 60; %Could probably be raised
got=[];
skipped=[];
blankVector = zeros(size(xAVI));

BlackBlobContrastAdjuster;

SaveTemp;
%% Expected gray blobs to exclude
grayFrameThreshB=rgb2gray(flipud(v0)) < grayThresh; %flipud
expectedBlobs=logical(imgaussfilt(double(grayFrameThreshB),10) <= gaussThresh);

SaveTemp;

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

%redo this to do out of bounds by each submask (if they exist)

[in,on] = inpolygon(xAVI, yAVI, maskx, masky);
inBounds = in | on;
outOfBounds=inBounds==0;
outOfBounds(zero_frames) = 0;
alreadyGood = outOfBounds & definitelyGood;
outOfBounds=outOfBounds & (definitelyGood==0);

if any(outOfBounds)
    badPoints = figure; plot(xAVI, yAVI, '.')
    hold on
    plot(xAVI(alreadyGood), yAVI(alreadyGood), '.g')
    plot(xAVI(outOfBounds), yAVI(outOfBounds), '.r')
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
    end
end

if any(auto_frames)
    close(badPoints);
    numPasses=2;
    CorrectTheseFrames;
end
    
%% so many options
optionsText={'y - attempt auto, manual when missed';...
             'm - all manual';...
             'p - select points by position';...
             't - reset auto-velocity threshold';...
             'v - run auto on high velocity points';...
             'o - change AOM flag';...
             'l - edit expected locations';...
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
             
stillEditingFlag=1;
while stillEditingFlag==1
MorePoints = input('Is there a flaw that needs to be corrected?','s');
try 
    figure(ManualCorrFig);
catch
    ManualCorrFig=figure('name','ManualCorrFig'); 
    imagesc(flipud(v0)); title('Auto correcting, please wait')
end 

UpdatePosAndVel;

switch MorePoints
    case 'y'
        disp('attempt auto')
        [sFrame,eFrame] = SelectFrameNumbers;
        auto_frames=sFrame:eFrame;
        numPasses=2;
        CorrectTheseFrames; 
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
        plot(xAVI,yAVI,'.')
        [~, pointBoxX, pointBoxY] = roipoly;
        [editLogical,~] = inpolygon(xAVI, yAVI, pointBoxX, pointBoxY);
        auto_frames=find(editLogical);
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
        close(posSelect);
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
        velthreshing=figure; plot(vel_init)
        auto_vel_thresh = 1500;
        title(['suggested velocity threshold: ' num2str(auto_vel_thresh)])
        hline=refline(0,auto_vel_thresh);
        hline.Color='r';
        hline.LineWidth=1.5;
    
        choice = questdlg('Is this velocity threshold good?', ...
        'Velocity Threshold', ...
        'Yes','No > ginput','Yes');
        % Handle response
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
    case 'v'
        disp('auto-correcting high velocity points')
        % Find indices of all points above auto_vel_thresh
        % After doing the first, recalculate all and go to earliest
        % Following this to work towards end
        
        velchoice = questdlg('How do you want to do velocity?', 'Correct high velocity',...
            'Whole session','First 100','Select Window','Select Window');
        switch velchoice
            case 'Whole session'
                disp(['right now found ' num2str(sum(vel_init>auto_vel_thresh)) ' high velocity frames; expect more'])
            case 'First 100'
                bounds(1:33)=1; bounds(34:66)=2; bounds(67:101)=3;
                velCount=0;
            case 'Select Window'
                [sFrame,eFrame] = SelectFrameNumbers;
            
        end
        
            AMchoice = questdlg('Manual only or auto-assist?', 'Auto or manual',...
                'Auto-assist','Manual','Cancel','Auto-assist');
            switch AMchoice
                case 'Auto-assist'
                    HighVelocityCorrect;
                case 'Manual'
                    HighVelocityCorrect;
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
    case 'l'
        editELvectors;
    case 's'
        SaveTemp;
    case 'x'
        SaveTemp;
        return
    case 'q'
        SaveTemp;
        stillEditingFlag=0;    
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
save Pos.mat Xpix_filt Ypix_filt xpos_interp ypos_interp time_interp start_time MoMtime Xpix Ypix xAVI yAVI MouseOnMazeFrame...
    AVItime_interp maze v0 maskx masky definitelyGood expectedBlobs mazeEl elVector bstr allTxt bframes DVTtime
    
close all 
end
%%
%Functions
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function HighVelocityCorrect(~,~)
global sFrame; global eFrame; global vel_init; global auto_vel_thresh;
global velCount; global time; global Xpix; global Ypix; global corrFrame;
global auto_frames; global velchoice; global AMchoice; global pass;
global xAVI; global yAVI; global definitelyGood; global fixedThisFrameFlag
global bounds; global skipped; global ManualCorrFig; global MoMtime;
global v; global obj; global xm; global ym; global aviSR; global markWith

marker = {'go' 'yo' 'ro'};
marker_face = {'g' 'y' 'r'};
markWith = 3; %needs to be updated...

veldFrames=[];
doneVel=0;
skipped=[];
skipThese=[];
manChoice = questdlg('Redo definitely good frames?','Redo DefGood',...
                    'Yes','No','No');
while doneVel==0

correctThis=1;
auto_frames=[];
%velInds=1:length(vel_init);
vel_init = hypot(diff(Xpix),diff(Ypix))./diff(time);%(time(2)-time(1));
vel_init = [vel_init(1); vel_init];
highVelFrames = find(vel_init>auto_vel_thresh);
[~,~,inHV] = intersect(skipThese,highVelFrames);
highVelFrames(inHV)=[];

switch manChoice
    case 'Yes'                
        %corrDefGoodFlag=1;
    case 'No'
        %corrDefGoodFlag=0;
        theseAreOk = find(definitelyGood);
        [~,~,inHighVel] = intersect(theseAreOk,highVelFrames);
        highVelFrames(inHighVel) = [];
end


%look at overwriteManualFlag?

switch velchoice
    case 'Whole session'
        if any(highVelFrames)
            auto_frames=highVelFrames(1);
            corrFrame=1;
        else 
            doneVel=1;
        end
    case 'First 100'
        velCount=velCount+1;
        markWith=bounds(velCount);
        if velCount>=101
            doneVel=1;
        else
            if any(highVelFrames)
                auto_frames=highVelFrames(1);
                corrFrame=1;
            end    
        end
        
    case 'Select Window'
        theseFrames=highVelFrames>=sFrame & highVelFrames<=eFrame;
        auto_frames=highVelFrames(find(theseFrames,1,'first'));
        corrFrame=1;
        if isempty(auto_frames)
            doneVel=1;
        end
end

veldFrames=[veldFrames auto_frames]; %#ok<AGROW>
if doneVel==0 && any(auto_frames)
    
    switch AMchoice
    case 'Auto-assist'
        if sum(veldFrames==auto_frames)==1
            %expected, it's fine
        elseif sum(veldFrames==auto_frames)==2
            auto_frames=auto_frames+1;
            %veldFrames=[veldFrames auto_frames]; 
        elseif sum(veldFrames==auto_frames)==3
            disp(['Uh oh, already did this frame, ' num2str(auto_frames) ', '...
            num2str(sum(veldFrames==auto_frames)-1) ' times'])
            contchoice =  questdlg('Try it again or skip it?', 'SkipTry',...
                            'End','PrevNext','Save','End');
            switch contchoice
            case 'End'
                correctThis=0;
                doneVel=1;
            case 'PrevNext'
                intendedFrame=auto_frames;
                auto_frames=[intendedFrame-1 intendedFrame+1];
                for corrFrame=1:2
                    if definitelyGood(auto_frames(corrFrame))==0
                    obj.CurrentTime=(auto_frames(corrFrame)-1)/aviSR;
                    v = readFrame(obj);
                    fixedThisFrameFlag=0;
                    [xm,ym]=EnhancedManualCorrect;
                    if fixedThisFrameFlag==1
                        FixFrame(xm,ym)
                    end
                    end
                end
                correctThis=0;
            case 'Save'    
                SaveTemp;
            end
        elseif sum(veldFrames==auto_frames)>=4
            skipThese=[skipThese auto_frames]; %#ok<AGROW>
            correctThis=0;    
        end
        if correctThis==1
            pass=1;
            skipped=[];
            CorrectThisFrame;  
            if any(skipped)
                [xm,ym]=EnhancedManualCorrect; 
        
                if fixedThisFrameFlag==1
                    FixFrame(xm,ym)
                end   
            end
        end    
    case 'Manual'
        if sum(veldFrames==auto_frames)==1
       %expected
        end
    if sum(veldFrames==auto_frames)==2
        %disp(['Uh oh, already did this frame, ' num2str(auto_frames) ', '...
        %    num2str(sum(veldFrames==auto_frames))-1 ' times'])
        
        auto_frames=auto_frames+1;
        veldFrames=[veldFrames auto_frames]; %#ok<AGROW>
        %{
            
            %}
    end
    if sum(veldFrames==auto_frames)>=3
            disp(['Uh oh, already did this frame, ' num2str(auto_frames) ', '...
            num2str(sum(veldFrames==auto_frames)-1) ' times'])
        contchoice =  questdlg('Try it again or skip it?', 'SkipTry',...
                            'End','PrevNext','Save','End');
            switch contchoice
            case 'End'
                correctThis=0;
                doneVel=1;
            case 'PrevNext'
                intendedFrame=auto_frames;
                auto_frames=[intendedFrame-1 intendedFrame+1];
                for corrFrame=1:2
                    obj.CurrentTime=(auto_frames(corrFrame)-1)/aviSR;
                    v = readFrame(obj);
                    fixedThisFrameFlag=0;
                    [xm,ym]=EnhancedManualCorrect;
                    if fixedThisFrameFlag==1
                        FixFrame(xm,ym);
                    end
                end
                correctThis=0;
            case 'Save'    
                SaveTemp;
            end
        %veldFrames=[veldFrames auto_frames]; %#ok<AGROW>    
    end
        if correctThis==1
        obj.CurrentTime=(auto_frames(corrFrame)-1)/aviSR;
        v = readFrame(obj);
        fixedThisFrameFlag=0;
        [xm,ym]=EnhancedManualCorrect; 
        
        if fixedThisFrameFlag==1
            FixFrame(xm,ym)
            
            %figure(ManualCorrFig); 
            %hold on;
            %plot(xm,ym,marker{markWith},'MarkerSize',4,...
            %    'MarkerFaceColor',marker_face{markWith})
            %hold off;
        end
        end
    end

end
end

UpdatePosAndVel;

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
                
global putativeMouseX; global putativeMouseY; global definitelyGood
global auto_frames; global corrFrame; global skipped; global pass;
global xAVI; global yAVI; global fixedThisFrameFlag; global huh; %global got
global xm; global ym; 

%Is there an adjacent definitelyGood frame to use?
tryFrame = auto_frames(corrFrame);
testDG = [0; definitelyGood; 0]; %so we can index w/o conditionals
testDGtry = tryFrame+1;
adjFrames = [(testDGtry-1) (testDGtry+1)]';
useAdjFrames = testDG(adjFrames);%tryFrame = 1 or end always returns 0
adjFrames(useAdjFrames==0) = [];

defAdjXs = xAVI(adjFrames);
defAdjYs = yAVI(adjFrames);


%For one isn't hard, for both not sure. Maybe just radius that's within
%both?
1/sqrt(length(defAdjXs) %scaling factor for radius by how many adj frames

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
global xAVI; global yAVI; global Xpix; global Ypix;
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
    imagesc(flipud(intendedFrame))
    title(['click here, frame ' num2str(auto_frames(corrFrame))])
    if Xpix(intendedFrameNum) ~= 0 && Ypix(intendedFrameNum) ~= 0
        figure(ManualCorrFig);
        hold on   
        plot(xAVI(intendedFrameNum),yAVI(intendedFrameNum),marker{markWith},'MarkerSize',4);
        hold off
    end
    [xm,ym,button] = ginput(1);
    fixedThisFrameFlag=0;
    switch button
        case 1 %left click
            %this point is good, use the xm ym
            hold on; plot(xm,ym,marker{markWith},'MarkerSize',4,'MarkerFaceColor',marker_face{markWith});hold off;
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
            imagesc(flipud(pastFrame))
            title(['click here, backed up to ' num2str(lastManualFrame) ' from ' num2str(intendedFrameNum)])
            [xm,ym] = ginput(1);
            hold on; plot(xm,ym,'oy','MarkerSize',4,'MarkerFaceColor','g'); hold off
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
            intendedFrameGood=1;
    end
end

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xm,ym]=ManualOnlyCorr(~,~)
global auto_frames; global corrFrame; global v; global ManualCorrFig
global fixedThisFrameFlag; global definitelyGood; global lastManualFrame;

figure(ManualCorrFig); 
imagesc(flipud(v))
hold on
title(['click here, frame ' num2str(auto_frames(corrFrame))])
[xm,ym] = ginput(1);
plot(xm,ym,'og','MarkerSize',4,'MarkerFaceColor','g');hold off;
title('Auto correcting, please wait')
definitelyGood(auto_frames(corrFrame)) = 1;
fixedThisFrameFlag=1;
lastManualFrame=auto_frames(corrFrame);

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sFrame, eFrame]=SelectFrameNumbers(~,~)
global PosAndVel; global time; 

display('click on the good points around the flaw then hit enter');
        
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
global overwriteManualFlag; global definitelyGood;

skipped=[];
ManualCorrFig=figure('name','ManualCorrFig'); imagesc(flipud(v0)); title('Auto correcting, please wait')
for pass=1:numPasses
    disp(['Running auto assisted on ' num2str(length(auto_frames)) ' frames'])
    %pass 1 skip where bad, pass 2 run skipped, manual correct if still bad
    resol = 1; % Percent resolution for progress bar
    p = ProgressBar(100/resol);
    update_inc = round(length(auto_frames)/(100/resol));
    total=0;
    bounds=[0 floor(length(auto_frames)/3) 2*floor(length(auto_frames)/3)];
    
    for corrFrame=1:length(auto_frames)   
        if overwriteManualFlag==1 || definitelyGood(auto_frames(corrFrame))==0
            markWith=sum(corrFrame>bounds);
            CorrectThisFrame;
        end 

        total=total+1;
        if round(total/update_inc) == (total/update_inc) % Update progress bar
            p.progress;
        end
    end
    
    try
    close(ManualCorrFig);    
    end
    SaveTemp;
    p.stop;

    UpdatePosAndVel
    
    switch pass
        case 1
            disp(['Completed auto-pass ' num2str(pass) ' on ' num2str(total) ' out of bounds frames'])
            auto_frames=skipped; %and can't have any skipped in round 2
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
global maskx; global masky;  global isGrayThresh;

xm=[]; ym=[];
marker = {'go' 'yo' 'ro'};
marker_face = {'g' 'y' 'r'};

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
    try
        figure(ManualCorrFig);
    catch
        ManualCorrFig=figure('name','ManualCorrFig'); imagesc(flipud(v0)); title('Auto correcting, please wait')
    end    
    hold off; imagesc(flipud(v)); hold on
    title(['Auto correcting frame ' num2str(auto_frames(corrFrame)) ', please wait'])
    if Xpix(auto_frames(corrFrame)) ~= 0 && Ypix(auto_frames(corrFrame)) ~= 0
        plot(xAVI(auto_frames(corrFrame)),yAVI(auto_frames(corrFrame)),marker{markWith},'MarkerSize',4);
    end    

    hold on; plot([mazex; mazex(1)],[mazey; mazey(1)],'r','LineWidth',1); hold off   
end
            
%Will's version, background image subtraction
d = imgaussfilt(flipud(rgb2gray(v0-v)),10);
stats = regionprops(d>willThresh & mazeMask,'area','centroid','majoraxislength','minoraxislength');%flipped %'solidity'
MouseBlob = [stats.Area] > 250 & ... %[stats.Area] < 3500...
            [stats.MajorAxisLength] > 10 & ...
            [stats.MinorAxisLength] > 10;
stats=stats(MouseBlob);
        
%Sam's gray version
grayFrameThresh = rgb2gray(flipud(v)) < grayThresh; %flipud
grayGauss = imgaussfilt(double(grayFrameThresh),10);
grayGaussThresh = grayGauss  > gaussThresh;
maybeMouseGray = grayGaussThresh & expectedBlobs; %To handle background gray maze & 
grayStats = regionprops(maybeMouseGray,'centroid','area','majoraxislength','minoraxislength'); %flipped
grayStats = grayStats( [grayStats.Area] > grayBlobArea &...
                       [grayStats.MajorAxisLength] > 15 &...
                       [grayStats.MinorAxisLength] > 15);
                   
%Centers in mask
statsCenters = reshape([stats.Centroid],2,length(stats))';
[inmask, onmask] = inpolygon(statsCenters(:,1),statsCenters(:,2),mazex,mazey);
inMask = inmask | onmask;

%Centers on black
generousGray = (grayGauss > isGrayThresh); & mazeMask;
grayOutlines = bwboundaries(generousGray);%cell2mat(
grayIn = zeros(length(statsCenters),1); grayOn = grayIn;
for thisGray = 1:length(grayOutlines)
    [thisIn, thisOn] = inpolygon(statsCenters(:,1),statsCenters(:,2),...
        grayOutlines{thisGray,1}(:,2),grayOutlines{thisGray,1}(:,1));
    grayIn = grayIn | thisIn;
    grayOn = grayOn | thisOn;
end
inGray = grayIn | grayOn;




        %{
          lengthStats=3;
          lengthGrayStats=5;
          statsTry=lengthStats+isempty(lengthStats); %if length(stats)==0, returns 1
          grayTry=lengthGrayStats+isempty(lengthGrayStats);

          possible=zeros(statsTry*grayTry,6);
          statsInds=1:lengthStats+isempty(lengthStats);%1:length(stats)+isempty(stats) 
          statsInds=repmat(statsInds,grayTry,1); 
          grayStatsInds=1:lengthGrayStats+isempty(grayTry);
          grayStatsInds=repmat(grayStatsInds,1,statsTry);

            
          possible=[statsInds(:) grayStatsInds']; Centroids(1:2:end-1) Centroids(2:2:end)];
          or it could be possible=[Centroids(1) Centroids(2) grayCentroids(1) grayCentroids(2)]
          any(length(stats))                     
          Centroids=[stats.Centroid]
          Centroids(1:2:end-1) Centroids(2:2:end) %then need to do the same
          stuff as earlier to align with proper index
                                or not? just use the mean centroid of the one we pick... 
                                Centroids use = index we pick in possible
                                CentroidsUse(CentroidsUse==0)=NaN;
                               mean CentroidsUse
          possible
        %}
                       
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
            
    % apply corrected position to current frame
    if fixedThisFrameFlag==1
        FixFrame(xm,ym) 
            
        figure(ManualCorrFig); 
        hold on;
        plot(xm,ym,marker{markWith},'MarkerSize',4,...
            'MarkerFaceColor',marker_face{markWith})
        hold off;
        if update_pos_realtime==1
           % pause(0.10)
        end
    end
 

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CorrectManualFrames(~,~)
global obj; global aviSR; global v; global ManualCorrFig; global markWith;
global xAVI; global yAVI; global Xpix; global Ypix; global fixedThisFrameFlag;
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
                
        figure(ManualCorrFig); 
        hold on;
        plot(xm,ym,marker{markWith},'MarkerSize',4,...
            'MarkerFaceColor',marker_face{markWith})
        hold off;
    end    
end
 
UpdatePosAndVel;

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdatePosAndVel(~,~)
global PosAndVel; global vel_init; global time; global Xpix; global Ypix;
global MoMtime; global auto_vel_thresh;
    
try
    figure(PosAndVel);
catch
    PosAndVel=figure('name','Position and Velocity');
end
vel_init = hypot(diff(Xpix),diff(Ypix))/(time(2)-time(1));
velInds=1:length(vel_init);
hx0 = subplot(4,3,1:3);plot(time,Xpix);xlabel('time (sec)');ylabel('x position (cm)');yl = get(gca,'YLim');
    line([MoMtime MoMtime], [yl(1) yl(2)],'Color','r');axis tight;
hy0 = subplot(4,3,4:6);plot(time,Ypix);xlabel('time (sec)');ylabel('y position (cm)');yl = get(gca,'YLim');
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
global bstr; global allTxt; global bframes;

save Pos_temp.mat Xpix Ypix xAVI yAVI MoMtime MouseOnMazeFrame maskx v0 maze masky definitelyGood expectedBlobs mazeEl elVector bstr allTxt bframes 
disp('Saved!')
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function getELvector(~,~)
global elVector; global elChoiceFlag; global xAVI; global v0; global mazeEl;
global maze; global maskx; global masky; global bstr; global allTxt; global bframes;
global mazeElInd; global mazeUp

doneLoading=0; 
loaded=1;
while doneLoading==0
    [xlsFile, xlsPath] = uigetfile('*.xlsx', 'Select file with behavior times');
    [frameses(loaded).frames, txt(loaded).txt] = xlsread(fullfile(xlsPath,xlsFile), 1);
    

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
    bstr = [bstr txt(lvl).txt(1,2:end)];
    allTxt = [allTxt txt(lvl).txt(:,:)];
    bframes = [bframes frameses(lvl).frames(:,2:end)];
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
end
    
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function editELvectors(~,~)
global elVector; global elChoiceFlag; global xAVI; global v0; global mazeEl;
global maze; global maskx; global masky; global mazeElInd

doneWithEl=0;
while doneWithEl==0
    for figg = 1:length(mazeEl)
        figure; imagesc(flipud(v0)); 
        hold on; plot([mazeEl(figg).maskx; mazeEl(figg).maskx(1)],...
            [mazeEl(figg).masky; mazeEl(figg).masky(1)],'r','LineWidth',1); hold off 
        switch figg==1
            case 1
                title('mazeEl index #1 original maze mask')
            case 0
                title(['mazeEl index # ' num2str(figg)])    
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
                disp(['deleted expected location ' num2str(deleteThis) ', those points reset to original mask'])
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
    
end

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function addAnElMask(~,~)
 global elVector; global elChoiceFlag; global xAVI; global v0; global mazeEl;
global maze; global maskx; global masky; global bstr; global allTxt; global bframes;  
global mazeElInd; global mazeUp; 

    selectedTwo=0;
    while selectedTwo==0
        [s,~] = listdlg('PromptString','A pair of timestamps:',...
                    'SelectionMode','multiple',...
                    'ListString',bstr);
        if length(s)==2; selectedTwo=1; end
    end
    
    [ss,~] = listdlg('PromptString','Which comes first:',...
                    'SelectionMode','single',...
                    'ListString',[bstr(s(1)) bstr(s(2))]);
    if ss==2; holder=s(1); s(1)=s(2); s(2)=holder; end
    %Could be generalized for other markers, right now needs to read strings
    dirChoice = questdlg('Restrict to left/right trials?','LR mod?',...
                    'Yes','No','Yes');
    switch dirChoice
        case 'Yes'
            [t,~] = listdlg('PromptString','Choose column with behavior:',...
                    'SelectionMode','single','ListString',bstr);
            
            bChoices = unique(allTxt(2:end,t+1));
            [flug,~] = listdlg('PromptString','Which flag:',...
                    'SelectionMode','single','ListString',bChoices);    
            LRmod = strcmpi(allTxt(2:end,t+1),bChoices(flug));
            
            beOptions = length(bChoices) - 1;
        case 'No'
            LRmod = ones(size(bframes,1));
            beOptions = 0;
    end    
    
    while beOptions >= 0
    
    starts = bframes(:,s(1)); starts(LRmod==0)=[];
    stops = bframes(:,s(2)); stops(LRmod==0)=[];
    
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
    
    if length(beOptions) > 0
        flugChoice = questdlg('Found more behavior flags. Do them, same bounds?', 'More flags', ...
                              'Yes','No','Yes');  
        switch flugChoice
            case 'Yes'
                bChoices(flug) = [];
                [flug,~] = listdlg('PromptString',':',...
                           'SelectionMode','single','ListString',bChoices);    
                LRmod = strcmpi(allTxt(2:end,t+1),bChoices(flug));
           
                if length(bChoices) > 1
                    mazeUp=mazeUp+1;
                    mazeElInd=mazeUp+1;
                end
            case 'No'
            beOptions = 0;
        end
    end
    
    beOptions = beOptions - 1;
    
    end
end
%%




%{
BoneYard

 = regionprops(grayGaussThreshB & maze,'centroid','area'); %flipped
for aa=1:length(expectedBlobs); blobCenters(aa,1:2)=expectedBlobs(aa).Centroid; end
[inBlob,onBlob] = inpolygon(blobCenters(:,1), blobCenters(:,2), maskx, masky);
inMaze= inBlob | onBlob; %probably going to yes all of them (maze above)
expectedBkgBlobs=expectedBlobs(inMaze);

%}