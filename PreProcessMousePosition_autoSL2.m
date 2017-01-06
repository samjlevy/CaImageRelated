function [xpos_interp,ypos_interp,start_time,MoMtime,time_interp,AVItime_interp] = PreProcessMousePosition_autoSL2(varargin)
% [xpos_interp,ypos_interp,start_time,MoMtime] = PreProcessMousePosition_auto(filepath, auto_thresh,...)
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

if fixedThisFrameFlag==1
    use the position we came up with

%}


if ~isempty(strfind(version,'R2016a'))
    disp('Sorry, 2016a not going to work; use 2015b or earlier')
    return
end
%% Need these for better organization
global obj
global aviSR
global auto_frames
global corrFrame
global xAVI
global yAVI
global Xpix
global Ypix
global definitelyGood
global fixedThisFrameFlag
global MarkerSize
global MarkerFace
global pass
global ManualCorrFig
global numPasses
global v
global v0
global maze
global lastManualFrame; lastManualFrame=[];
global grayThresh
global gaussThresh
global willThresh
global distLim2
global got
global skipped
global huh
global putativeMouseX
global putativeMouseY
global xm
global ym

%% Get varargin
    
update_pos_realtime = 0; % Default setting
epoch_length_lim = 200; % default
for j = 1:length(varargin)
    if strcmpi('filepath', varargin{j})
        filepath = varargin{j+1};
    end
    if strcmpi('update_pos_realtime', varargin{j})
        update_pos_realtime = varargin{j+1};
    end
    if strcmpi('epoch_length_lim', varargin{j})
        epoch_length_lim = varargin{j+1};
    end
    if strcmpi('auto_thresh', varargin{j})
        auto_thresh = varargin{j+1};
    end
    if strcmpi('max_pixel_jump', varargin{j})
        max_pixel_jump = varargin{j+1};
    end
end

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
    %f_s = max(regexp(filepath,'\'))+1;
    %mouse_name = filepath(f_s:f_s+2);
    %date = [filepath(f_s+3:f_s+4) '-' filepath(f_s+5:f_s+6) '-' filepath(f_s+7:f_s+10)];
    
    % Parse out into invididual variables
    frame = pos_data(:,1);
    time = pos_data(:,2); % time in seconds
    Xpix = pos_data(:,3); % x position in pixels (can be adjusted to cm)
    Ypix = pos_data(:,4); % y position in pixels (can be adjusted to cm)
catch
    % Video.txt is there instead of Video.DVT
    pos_data = importdata('Video.txt');
    Xpix = pos_data.data(:,6);
    Ypix = pos_data.data(:,7);
    time = pos_data.data(:,4);
end

xAVI = Xpix*.6246;
yAVI = Ypix*.6246;


PreCorrectedData=figure('name','Pre-Corrected Data');plot(Xpix,Ypix);title('pre-corrected data'); %#ok<NASGU>

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
        MoMtime %#ok<NODEF,NOPRT>
    else
        h1 = implay(avi_filepath);
        MouseOnMazeFrame = input('on what frame number does Mr. Mouse arrive on the maze??? --->');
        MoMtime = MouseOnMazeFrame*0.03+time(1) %#ok<NOPRT>
        close(h1);
    end
else
    h1 = implay(avi_filepath);
    MouseOnMazeFrame = input('on what frame number does Mr. Mouse arrive on the maze??? --->');
    MoMtime = MouseOnMazeFrame*0.03+time(1) %#ok<NOPRT>
    close(h1);
end


%% Cage mask
%Comes out flipped
dummy = readFrame(obj);
MaskFig=figure('name', 'Cage Mask'); imagesc(flipud(dummy));
maskSwitch= exist('maskx','var') && exist('masky','var') && exist('maze','var');
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
        close(h1);
        obj.CurrentTime = (bkgFrameNum-1)/obj.FrameRate;
        backgroundImage = readFrame(obj);
        backgroundFrame=figure('name','backgroundFrame'); imagesc(backgroundImage); title('Background Image')
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
        top=figure('name','top'); imagesc(topClearFrame); title(['Top Clear Frame ' num2str(topClearNum)])
        bot=figure('name','bot'); imagesc(bottomClearFrame); title(['Bottom Clear Frame ' num2str(bottomClearNum)])
        compositeBkg=uint8(zeros(480,640,3));
        compositeBkg(1:240,:,:)=topClearFrame(1:240,:,:);
        compositeBkg(241:480,:,:)=bottomClearFrame(241:480,:,:);
        close top; close bot;
        backgroundFrame=figure('name','backgroundFrame'); imagesc(compositeBkg); title('Composite Background Image')
end
elseif exist ('v0','var') 
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
            figure(backgroundFrame); title('Select area to swap out')
            [swapRegion, SwapX, SwapY] = roipoly;
            hold on 
            plot([SwapX; SwapX(1)],[SwapY; SwapY(1)],'r','LineWidth',2)
            %figure(h1); %msgbox('Enter frame number of image to swap in')
            swapInNum = input('Frame number to swap in area from ---->')%#ok<NOPRT> %might replace with 2 field dialog box
            try 
                close h1; 
            end
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

epoch_start=[]; epoch_end=[];

PosAndVel=figure('name','Position and Velocity');
hx0 = subplot(4,3,1:3);plot(time,Xpix);xlabel('time (sec)');ylabel('x position (cm)');yl = get(gca,'YLim');
    line([MoMtime MoMtime], [yl(1) yl(2)],'Color','r');axis tight;
hy0 = subplot(4,3,4:6);plot(time,Ypix);xlabel('time (sec)');ylabel('y position (cm)');yl = get(gca,'YLim');
    line([MoMtime MoMtime], [yl(1) yl(2)],'Color','r');axis tight;
linkaxes([hx0 hy0],'x');
hVel = subplot(4,3,7:12);plot(vel_init);xlabel('time (sec)');ylabel('velocity');axis tight;
hline=refline(0,auto_vel_thresh);hline.Color='r';hline.LineWidth=1.5;
%vel = hypot(diff(Xpix),diff(Ypix))/(time(2)-time(1));

%% All the rest...
if ~exist('Pos_temp.mat','file')
    save Pos_temp.mat Xpix Ypix xAVI yAVI MoMtime MouseOnMazeFrame maze v0 maskx masky 
end 

definitelyGood = Xpix*0;
willThresh=20;
grayThresh = 115; 
gaussThresh = 0.2;
max_pixel_jump = sqrt(50^2+50^2);
distLim = max_pixel_jump;
grayBlobArea = 60; %Could probably be raised
distLim2 = 45;
got=[];
skipped=[];

%Expected gray blobs to exclude
grayFrameThreshB=rgb2gray(flipud(v0)) < grayThresh; %flipud
expectedBlobs=logical(imgaussfilt(double(grayFrameThreshB),10) <= gaussThresh);

% First let's do frames out of bounds
zero_frames = Xpix == 0 | Ypix == 0 ;
%auto_zero = find(zero_frames);
[in,on] = inpolygon(xAVI, yAVI, maskx, masky);
inBounds = in | on;
outOfBounds=inBounds==0;
auto_logical = zero_frames | outOfBounds;
auto_frames = find(auto_logical);

%First pass go for automatic detection 
if any(auto_frames)
    auto_thresh_flag=1;
end

if auto_thresh_flag==1
numPasses=2;    
skipped=[];
for pass=1:numPasses
    disp(['Running auto assisted on ' num2str(length(auto_frames)) ' frames'])
    %pass 1 skip where bad, pass 2 run skipped, manual correct if still bad
    ManualCorrFig=figure('name','ManualCorrFig'); imagesc(flipud(v0)); title('Auto correcting, please wait')
    resol = 1; % Percent resolution for progress bar
    p = ProgressBar(100/resol);
    update_inc = round(length(auto_frames)/(100/resol));
    total=0;

    for corrFrame=1:length(auto_frames)
        fixedThisFrameFlag=0;
%  %  % % %if overwriteManualFlag==1 && definitelyGood(auto_frames(corrFrame))==0 %This probably isn't right
%Still need to do something with this line
        obj.CurrentTime=(auto_frames(corrFrame)-1)/aviSR;
        v = readFrame(obj);
            
        %Will's version, background image subtraction
        d = imgaussfilt(flipud(rgb2gray(v0-v)),10);
        stats = regionprops(d>willThresh & maze,'area','centroid','majoraxislength','minoraxislength');%flipped %'solidity'
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
                               [grayStats.MajorAxisLength] > 15 &...
                               [grayStats.MinorAxisLength] > 15);
        %{
          lengthStats=3;
          lengthGrayStats=5;
          statsTry=lengthStats+isempty(lengthStats);
          grayTry=lengthGrayStats+isempty(lengthGrayStats);

          possible=zeros(statsTry*grayTry,6);
          statsInds=1:lengthStats+isempty(lengthStats);%1:length(stats)+isempty(stats) 
          statsInds=repmat(statsInds,grayTry,1); 
          grayStatsInds=1:lengthGrayStats+isempty(grayTry);
          grayStatsInds=repmat(grayStatsInds,1,statsTry);

            
          possible=[statsInds(:) grayStatsInds' Centroids(1:2:end-1) Centroids(2:2:end)]
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
            possible( possible(:,3)>distLim2, :) = []; %#ok<AGROW>
            if size(possible,1)==1
                %Will and thresh agree on one blob
                xm=mean([stats(possible(1)).Centroid(1) grayStats(possible(2)).Centroid(1)]);
                ym=mean([stats(possible(1)).Centroid(2) grayStats(possible(2)).Centroid(2)]);
                fixedThisFrameFlag=1;
                got=[got; corrFrame];%#ok<AGROW>
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
                        skipped = [skipped; auto_frames(corrFrame)]; %#ok<AGROW>
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
                    skipped = [skipped; auto_frames(corrFrame)]; %#ok<AGROW>
                case 2
                    [xm,ym] = EnhancedManualCorrect;
            end
        end   
            
        % apply corrected position to current frame
        if fixedThisFrameFlag==1
            xAVI(corrFrame) = xm;
            yAVI(corrFrame) = ym;
            Xpix(corrFrame) = ceil(xm/0.6246);
            Ypix(corrFrame) = ceil(ym/0.6246);    
        end
        total=total+1;
        if round(total/update_inc) == (total/update_inc) % Update progress bar
                p.progress;
                %would like to have a 50% save spot...
        end

    end 
    close(ManualCorrFig);    
    save Pos_temp.mat Xpix Ypix xAVI yAVI MoMtime MouseOnMazeFrame maskx v0 maze masky definitelyGood expectedBlobs   
    p.stop;
    
    switch pass
        case 1
            disp(['Completed auto-pass ' num2str(pass) ' on ' num2str(total) ' out of bounds frames'])
            auto_frames=skipped; %and can't have any skipped in round 2
        case 2
            disp('something about the frames you helped correct, human')
    end        
end

end 
%%
%{
%% so many options
optionsText={'y - attempt auto, manual when missed';...
             'm - all manual';...
             'p - select points by position';...
             't - reset auto-velocity threshold';...
             'v - run auto on high velocity points';...
             'o - change AOM flag';...
             's - save work';...
             'q - save, finalize and quit';...
             ' ';...
             'AOM flag (auto-overwrites-manual)';...
             '    - when automatic processes are correcting';...
             '    frames, they will ignore frames that have';...
             '    been corrected manually.';...
             ' ';...
             'When manually correcting, you can right-mouse';...
             'to accept existing position. You can also';...
             'middle-mouse to go back to the last manually';...
             'corrected frame to re-do it.'};
msgbox(optionsText,'PreProcess Keys')
             
AOMflag=0;
stillEditingFlag=1;
pass=1;
while stillEditingFlag==1

switch pass <=2
case 0
    correctSomePoints=0;
    MorePoints = input('Is there a flaw that needs to be corrected?','s');
    switch MorePoints
    case 'y'
        disp('attempt auto')
        CorrectTheseFrames; 
    case 'm'
        disp('correcting manually')
        CorrectTheseFrames;
    case 'p'
        disp('correcting by position')
        posSelect=figure('name','posSelect','Position',[250 250 640*1.5 480*1.5]); imagesc(flipud(v0))
        title('Drag region around points to correct')
        hold on
        plot(xAVI,yAVI,'.')
        [~, pointBoxX, pointBoxY] = roipoly;
        [editLogical,~] = inpolygon(xAVI, yAVI, pointBoxX, pointBoxY);
        hold on
        plot(xAVI(editLogical),yAVI(editLogical),'.r')
        poschoice = questdlg('Edit these points?', 'Edit by position','Yes','No','Yes');
        switch poschoice
            case 'Yes'
                auto_frames=find(editLogical);
                correctSomePoints=1;
            case 'No'
        end
        close(posSelect);
        
    case 't'
        disp('reset high-velocity threshold')
    case 'v'
        disp('auto-correcting high velocity points')
    case 'o'
    switch AOMflag
        case 0
            AOMflag=1;
            disp('auto-overwrites-manual is now ENABLED')
        case 1
            AOMflag=0;
            disp('auto-overwrites-manual is now DISABLED')
    end
    case 's'
        save Pos_temp.mat Xpix Ypix xAVI yAVI MoMtime MouseOnMazeFrame maskx v0 maze masky definitelyGood
    case 'q'
        stillEditingFlag=0;    
    otherwise
        disp('Not a recognized input')
    end
case 1
    auto frames code
    correctSomePoints=1;
end

if correctSomePoints==1
    %Here goes to code to load frames and correct them
    CorrectTheseFrames( frames )
else    
 
end    

pass=pass+1;
end
%}
end
%% All the rest old 
%{
n = 1;
% Get initial velocity profile for auto-thresholding
%{
vel_init = hypot(diff(Xpix),diff(Ypix))/(time(2)-time(1));
vel_init = [vel_init; vel_init(end)];
% vel_init = [vel_init(1); vel_init];
[fv, xv] = ecdf(vel_init);
if exist('auto_thresh','var')
    auto_vel_thresh = min(xv(fv > (1-auto_thresh)));
else
    auto_vel_thresh = max(vel_init)+1;
    auto_thresh = nan; % Don't perform any autocorrection if not specified
end


% Determine if auto thresholding applies

if sum(auto_frames) > 0 && ~isnan(auto_thresh)
    auto_thresh_flag = 1;
    [ on, off ] = get_on_off( auto_frames );
    [ epoch_start, epoch_end ] = cluster_epochs( on, off, cluster_thresh );
    n_epochs = length(epoch_start);
    
    % Apply epoch length limits if applicable
    if ~isempty(epoch_length_lim)
        epoch_lengths = epoch_end - epoch_start;
        epoch_start = epoch_start(epoch_lengths < epoch_length_lim);
        epoch_end = epoch_end(epoch_lengths < epoch_length_lim);
        n_epochs = length(epoch_start);
    end
else %if sum(auto_frames) == 0
    auto_thresh_flag = 0;
end
%}
MorePoints = 'y';%first
while ~(strcmp(MorePoints,'n')) 
    if auto_thresh_flag == 0 || isempty(epoch_start)
        MorePoints = input('Is there a flaw that needs to be corrected?  [y/n/manual correct (m)] -->','s');
    else
        MorePoints = 'y'; pause(1)
    end
    
    
    
        
        
    if strcmp(MorePoints,'y') %%%switch, case, use otherwise (after cases) to handle miscellaneous letters
        if auto_thresh_flag == 0 || isempty(epoch_start)
            FrameSelOK = 0;
            while (FrameSelOK == 0)
                display('click on the good points around the flaw then hit enter');
                [DVTsec,~] = ginput(2); % DVTsec is start and end time in DVT seconds
                sFrame = findclosest(time,DVTsec(1)); % index of start frame
                eFrame = findclosest(time,DVTsec(2)); % index of end frame
                eFrame = max(eFrame,time(end));
                
                if sFrame>eFrame
                    holder=sFrame;
                    sFrame=eFrame;
                    eFrame=holder;
                end    
                
                if eFrame/aviSR > obj.Duration
                   eFrame=obj.Duration*aviSR; 
                end
                
                if sFrame/aviSR > obj.Duration 
                    error('What are you doing')
                    continue;
                end
                %               obj.currentTime = sFrame/aviSR; 
                % sFrame is the correct frame #, but .avi reads are done according to time
                %               v = readFrame(obj);
                FrameSelOK = 1;
                
            end
        %{    
        elseif auto_thresh_flag == 1 % Input times from auto_threholded vector
            sFrame = max([1 epoch_start(n)- 6]);
            eFrame = min([length(time) epoch_end(n) + 6]);
            
            % Turn on manual thresholding once you correct all epochs above
            % the velocity threshold
            if n == n_epochs
                auto_thresh_flag = 0;
            else
                n = n + 1;
            end
        %}    
        end
        obj.currentTime = (sFrame-1)/aviSR; 
        % sFrame is the correct frame #, but .avi reads are done according to time
        v = readFrame(obj);
        
        framesToCorrect = sFrame:eFrame;
        if eFrame >= max(time)
            framesToCorrect = sFrame:eFrame-2; % Fix case where last frame needs to be corrected
        end
        frame_use_index = 1:floor(length(framesToCorrect)/2);
        frame_use_num = length(frame_use_index);
        
        try
        edit_start_time = time(sFrame);
        edit_end_time = time(eFrame);
        
        % Set marker colors to be green for the first 1/3, yellow for the 2nd
        % 1/3, and red for the final 1/3
        marker = {'go' 'yo' 'ro'};
        marker_face = {'g' 'y' 'r'};
        marker_fr = ones(size(frame_use_index));
        num_markers = size(marker,2);
        for jj = 1:num_markers-1
            marker_fr(floor(jj*frame_use_num/num_markers)+1:...
                floor((jj+1)*frame_use_num/num_markers)) = ...
                (jj+1)*ones(size(floor(jj*frame_use_num/num_markers)+1:...
                floor((jj+1)*frame_use_num/num_markers)));
        end
        
        
        disp(['You are currently editing from ' num2str(edit_start_time) ...
            ' sec to ' num2str(edit_end_time) ' sec.'])
        
        for i = frame_use_index
            
            if update_pos_realtime == 1
                figure(555)
                % Plot updated coordinates and velocity
                % plot the current sub-trajectory
                subplot(4,3,11);
                imagesc(flipud(v));hold on;
                plot(xAVI(sFrame:eFrame),yAVI(sFrame:eFrame),'LineWidth',1.5);hold off;title('chosen segment');
                
                % plot the current total trajectory
                subplot(4,3,10);
                imagesc(flipud(v));hold on;
                plot(xAVI(MouseOnMazeFrame:end),yAVI(MouseOnMazeFrame:end),'LineWidth',1.5);
                hold off;title('overall trajectory (post mouse arrival)');
            end
            
            % plot the current video frame
            framesToCorrect(i*2);
            obj.currentTime = framesToCorrect(i*2)/aviSR;
            v = readFrame(obj);
            figure(1702);pause(0.01);
            gcf;
            imagesc(flipud(v));title('click here');
            % plot the existing position marker on top
            hold on;plot(xAVI(sFrame+i*2),yAVI(sFrame+i*2),marker{marker_fr(i)},'MarkerSize',4);
            %         display(['Time is ' num2str(time(sFrame+i*2)) ' seconds. Click the mouse''s back']);
            
            %Subtract current frame from reference, then flip and smooth. Next,
            %run regionprops.
            d = imgaussfilt(flipud(rgb2gray(v0-v)),10);
            stats = regionprops(d>20 & maze,'area','solidity','centroid','eccentricity','majoraxislength','minoraxislength');
            
            %Find the blob that corresponds to the mouse.
            MouseBlob = find(   [stats.Area] > 300 & ...
                [stats.MajorAxisLength] > 10 & ...
                [stats.MinorAxisLength] > 10);
            if length(MouseBlob)==1
                xm = stats(MouseBlob).Centroid(1);
                ym = stats(MouseBlob).Centroid(2);
            elseif length(MouseBlob)>1
                %Get mouse position on the previous frame.
                previousX = xAVI(framesToCorrect(i)-1);
                previousY = yAVI(framesToCorrect(i)-1);
                
                %Possible mouse blobs.
                putativeMouse = [stats(MouseBlob).Centroid];
                putativeMouseX = putativeMouse(1:2:end);
                putativeMouseY = putativeMouse(2:2:end);
                
                %Find which blob is closest to the mouse's location in the
                %previous frame.
                whichMouseX = findclosest(putativeMouseX,previousX);
                whichMouseY = findclosest(putativeMouseY,previousY);
                
                %If they agree, use that blob.
                if whichMouseX == whichMouseY
                    xm = stats(MouseBlob(whichMouseX)).Centroid(1);
                    ym = stats(MouseBlob(whichMouseY)).Centroid(2);
                else
                    %keyboard;
                    [xm,ym] = ginput(1);
                end
            else
                %keyboard;
                [xm,ym] = ginput(1);
            end
            
            % apply corrected position to current frame
            xAVI(sFrame+i*2) = xm;
            yAVI(sFrame+i*2) = ym;
            Xpix(sFrame+i*2) = ceil(xm/0.6246);
            Ypix(sFrame+i*2) = ceil(ym/0.6246);
            
            % interpolate and apply correct position for previous frame
            xAVI(sFrame+i*2-1) = xAVI(sFrame+i*2-2)+(xm-xAVI(sFrame+i*2-2))/2;
            yAVI(sFrame+i*2-1) = yAVI(sFrame+i*2-2)+(ym-yAVI(sFrame+i*2-2))/2;
            Xpix(sFrame+i*2-1) = ceil(xAVI(sFrame+i*2-1)/0.6246);
            Ypix(sFrame+i*2-1) = ceil(yAVI(sFrame+i*2-1)/0.6246);
            
            
            % plot marker
            plot(xm,ym,marker{marker_fr(i)},'MarkerSize',4,'MarkerFaceColor',marker_face{marker_fr(i)});hold off;
        end
        
        disp(['You just edited from ' num2str(edit_start_time) ...
            ' sec to ' num2str(edit_end_time) ' sec.']);
        
        close(1702);
        catch
        disp('unable to edit these frames, some error')
        end
        
        % plot updated velocity
        figure(555);
        subplot(4,3,7:9);
        vel = hypot(diff(Xpix),diff(Ypix))/(time(2)-time(1));
        vel = [vel; vel(end)]; % Make the vectors the same size
        plot(time(MouseOnMazeFrame:end),vel(MouseOnMazeFrame:end));
        hold on
        plot(time([sFrame eFrame]),vel([sFrame eFrame]),'ro'); % plot start and end points of last edit
        if auto_thresh_flag == 1
            % Get indices for all remaining times that fall above the auto
            % threshold that have not been corrected
            ind_red = auto_frames & time > time(eFrame);
            hold on
            plot(time(ind_red),vel(ind_red),'ro');
            hold off
        end
        hold off;axis tight;xlabel('time (sec)');ylabel('velocity (units/sec)');
        xlim_use = get(gca,'XLim'); hv = gca;
        
        % plot updated x and y values
        hx = subplot(4,3,1:3); plot(time,Xpix); hold on;
        plot(time([sFrame eFrame]),Xpix([sFrame eFrame]),'ro'); % plot start and end points of last edit
        xlabel('time (sec)'); ylabel('x position (cm)');
        hold on; yl = get(gca,'YLim'); line([MoMtime MoMtime], [yl(1) yl(2)],'Color','r');
        hold off; axis tight; % set(gca,'XLim',[sFrame/aviSR eFrame/aviSR]); hx = gca;
        
        hy = subplot(4,3,4:6); plot(time,Ypix); hold on;
        plot(time([sFrame eFrame]),Ypix([sFrame eFrame]),'ro'); % plot start and end points of last edit
        xlabel('time (sec)'); ylabel('y position (cm)');
        hold on; yl = get(gca,'YLim'); line([MoMtime MoMtime], [yl(1) yl(2)],'Color','r');
        hold off; axis tight; % set(gca,'XLim',[sFrame/aviSR eFrame/aviSR]); hy = gca;
        
        linkaxes([hx, hy, hv],'x'); % Link axes zooms along time dimension together
        
        drawnow % Make sure everything gets updated properly!
        
        % NRK edit
        save Pos_temp.mat Xpix Ypix xAVI yAVI MoMtime MouseOnMazeFrame maze v0 maskx masky definitely_good
        
        continue
    end
    
    if (strcmp(MorePoints,'g'))
        % generate a movie and show it
        for i = 1:length(time)
            obj.currentTime = i/aviSR; % sFrame is the correct frame #, but .avi reads are done according to time
            v = readFrame(obj);
            figure(6156);
            imagesc(flipud(v));hold on;
            plot(xAVI(i),yAVI(i),'or','MarkerSize',5,'MarkerFaceColor','r');hold off;
            F(i) = getframe(gcf);
        end
        save F.mat F;implay(F);pause;
    end
    
    if strcmp(MorePoints,'m')
        %Copied from above. Frame selection.
        FrameSelOK = 0;
        while (FrameSelOK == 0)
            display('click on the good points around the flaw then hit enter');
            [DVTsec,~] = ginput(2); % DVTsec is start and end time in DVT seconds
            sFrame = findclosest(time,DVTsec(1)); % index of start frame
            eFrame = findclosest(time,DVTsec(2)); % index of end frame
            aviSR*sFrame;
            
            if (sFrame/aviSR > obj.Duration || eFrame/aviSR > obj.Duration)
            UseEdge = input('are you trying to specify a time span that includes the last point in the file [y/n] ==>','s')
                    if UseEdge
                        eFrame = length(time);
                    else
                        continue
                    end;
            end
            %               obj.currentTime = sFrame/aviSR; 
            % sFrame is the correct frame #, but .avi reads are done according to time
            %               v = readFrame(obj);
            FrameSelOK = 1;
            
        end
        
        %Copied from above. Old way of correcting video.
        obj.currentTime = sFrame/aviSR; % sFrame is the correct frame #, but .avi reads are done according to time
        v = readFrame(obj);
        
        framesToCorrect = sFrame:eFrame;

        frame_use_index = 1:floor(length(framesToCorrect)/2);
        frame_use_num = length(frame_use_index);
        
        edit_start_time = time(sFrame);
        edit_end_time = time(eFrame);
        
        % Set marker colors to be green for the first 1/3, yellow for the 2nd
        % 1/3, and red for the final 1/3
        marker = {'go' 'yo' 'ro'};
        marker_face = {'g' 'y' 'r'};
        marker_fr = ones(size(frame_use_index));
        num_markers = size(marker,2);
        for jj = 1:num_markers-1
            marker_fr(floor(jj*frame_use_num/num_markers)+1:...
                floor((jj+1)*frame_use_num/num_markers)) = ...
                (jj+1)*ones(size(floor(jj*frame_use_num/num_markers)+1:...
                floor((jj+1)*frame_use_num/num_markers)));
        end
        
        
        disp(['You are currently editing from ' num2str(edit_start_time) ...
            ' sec to ' num2str(edit_end_time) ' sec.'])
        
        for i = frame_use_index
            
            if update_pos_realtime == 1
                figure(555)
                % Plot updated coordinates and velocity
                % plot the current sub-trajectory
                subplot(4,3,11);
                imagesc(flipud(v));hold on;
                plot(xAVI(sFrame:eFrame),yAVI(sFrame:eFrame),'LineWidth',1.5);hold off;title('chosen segment');
                
                % plot the current total trajectory
                subplot(4,3,10);
                imagesc(flipud(v));hold on;
                plot(xAVI(MouseOnMazeFrame:end),yAVI(MouseOnMazeFrame:end),'LineWidth',1.5);
                    hold off;title('overall trajectory (post mouse arrival)');
            end
            
            % plot the current video frame
            framesToCorrect(i*2);
            try
            obj.currentTime = framesToCorrect(i*2)/aviSR;
            catch
              obj.currentTime = framesToCorrect(end)/aviSR; 
            end
            v = readFrame(obj);
            figure(1702);pause(0.01);
            gcf;
            imagesc(flipud(v));title('click here');
            % plot the existing position marker on top
            hold on;plot(xAVI(sFrame+i*2),yAVI(sFrame+i*2),marker{marker_fr(i)},'MarkerSize',4);
            
            %Correct frames here!
            [xm,ym] = ginput(1);
            
            % apply corrected position to current frame
            xAVI(sFrame+i*2) = xm;
            yAVI(sFrame+i*2) = ym;
            Xpix(sFrame+i*2) = ceil(xm/0.6246);
            Ypix(sFrame+i*2) = ceil(ym/0.6246);
            
            % interpolate and apply correct position for previous frame
            xAVI(sFrame+i*2-1) = xAVI(sFrame+i*2-2)+(xm-xAVI(sFrame+i*2-2))/2;
            yAVI(sFrame+i*2-1) = yAVI(sFrame+i*2-2)+(ym-yAVI(sFrame+i*2-2))/2;
            Xpix(sFrame+i*2-1) = ceil(xAVI(sFrame+i*2-1)/0.6246);
            Ypix(sFrame+i*2-1) = ceil(yAVI(sFrame+i*2-1)/0.6246);
            
            
            % plot marker
            plot(xm,ym,marker{marker_fr(i)},'MarkerSize',4,'MarkerFaceColor',marker_face{marker_fr(i)});hold off;
        end
        disp(['You just edited from ' num2str(edit_start_time) ...
            ' sec to ' num2str(edit_end_time) ' sec.']);
        
        close(1702);
        
        % plot updated velocity
        figure(555);
        subplot(4,3,7:9);
        vel = sqrt(diff(Xpix).^2+diff(Ypix).^2)/(time(2)-time(1));
        vel = [vel; vel(end)]; % Make the vectors the same size
        plot(time(MouseOnMazeFrame:end),vel(MouseOnMazeFrame:end));
        hold on
        plot(time([sFrame eFrame]),vel([sFrame eFrame]),'ro'); % plot start and end points of last edit
        if auto_thresh_flag == 1
            % Get indices for all remaining times that fall above the auto
            % threshold that have not been corrected
            ind_red = auto_frames & time > time(eFrame);
            hold on
            plot(time(ind_red),vel(ind_red),'ro');
            hold off
        end
        hold off;axis tight;xlabel('time (sec)');ylabel('velocity (units/sec)');
        xlim_use = get(gca,'XLim'); hv = gca;
        
        % plot updated x and y values
        hx = subplot(4,3,1:3); plot(time,Xpix); hold on;
        plot(time([sFrame eFrame]),Xpix([sFrame eFrame]),'ro'); % plot start and end points of last edit
        xlabel('time (sec)'); ylabel('x position (cm)');
        hold on; yl = get(gca,'YLim'); line([MoMtime MoMtime], [yl(1) yl(2)],'Color','r');
        hold off; axis tight; % set(gca,'XLim',[sFrame/aviSR eFrame/aviSR]); hx = gca;
        
        hy = subplot(4,3,4:6); plot(time,Ypix); hold on;
        plot(time([sFrame eFrame]),Ypix([sFrame eFrame]),'ro'); % plot start and end points of last edit
        xlabel('time (sec)'); ylabel('y position (cm)');
        hold on; yl = get(gca,'YLim'); line([MoMtime MoMtime], [yl(1) yl(2)],'Color','r');
        hold off; axis tight; % set(gca,'XLim',[sFrame/aviSR eFrame/aviSR]); hy = gca;
        
        linkaxes([hx, hy, hv],'x'); % Link axes zooms along time dimension together
        
        drawnow % Make sure everything gets updated properly!
        
        % NRK edit
        save Pos_temp.mat Xpix Ypix xAVI yAVI MoMtime MouseOnMazeFrame maze v0 maskx masky definitely_good
        
        continue
       
    end
    if strcmp(MorePoints,'s')
        save Pos_temp.mat Xpix Ypix xAVI yAVI MoMtime MouseOnMazeFrame maze v0 maskx masky definitely_good
    end    
end

Xpix_filt = NP_QuickFilt(Xpix,0.0000001,1,PosSR);
Ypix_filt = NP_QuickFilt(Ypix,0.0000001,1,PosSR);

if size(pos_data,2) == 5
    motion = pos_data(:,5);
end

for i = 1:length(time)
    AVIobjTime(i) = i/aviSR;
end

frame_rate_emp = round(1/mean(diff(time))); % empirical frame rate (frames/sec)

% Generate times to match brain imaging data timestamps
fps_brainimage = 20; % frames/sec for brain image timestamps

start_time = ceil(min(time)*fps_brainimage)/fps_brainimage;
max_time = floor(max(time)*fps_brainimage)/fps_brainimage;
time_interp = start_time:1/fps_brainimage:max_time;

if (max(time_interp) >= max_time)
    time_interp = time_interp(1:end-1);
end

%% Do Linear Interpolation

% Get appropriate time points to interpolate for each timestamp
time_index = arrayfun(@(a) [max(find(a >= time)) min(find(a < time))],...
    time_interp,'UniformOutput',0);
time_test_cell = arrayfun(@(a) a,time_interp,'UniformOutput',0);

xpos_interp = cellfun(@(a,b) lin_interp(time(a), Xpix_filt(a),...
    b),time_index,time_test_cell);

ypos_interp = cellfun(@(a,b) lin_interp(time(a), Ypix_filt(a),...
    b),time_index,time_test_cell);

AVItime_interp = cellfun(@(a,b) lin_interp(time(a), AVIobjTime(a),...
    b),time_index,time_test_cell);

% Save all filtered data as well as raw data in case you want to go back
% and fix an error you discover later on
save Pos.mat xpos_interp ypos_interp time_interp start_time MoMtime Xpix Ypix xAVI yAVI MouseOnMazeFrame...
    AVItime_interp maze v0 maskx masky definitely_good
 
end
%} 
%%
%Functions for correcting stuff, for better organization
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TryAdjacentFrames(~,~)
                
global putativeMouseX; global putativeMouseY
global auto_frames; global corrFrame; global skipped; global pass;
global xAVI; global yAVI; global fixedThisFrameFlag; global huh; global got
global xm; global ym; 

skipThisStep=0;
if auto_frames(corrFrame) > 1 && any(skipped==auto_frames(corrFrame)-1)==0 %Look at adjacent frames
    %not the first frame and we didn't skip the last one
    adjacentX = xAVI(auto_frames(corrFrame)-1);
    adjacentY = yAVI(auto_frames(corrFrame)-1);
elseif auto_frames(corrFrame) > length(xAVI) && any(auto_frames(corr_frame+1)==auto_frames(corrFrame)+1)==0
    %&& any(skipped==auto_frames(corrFrame)+1)==0 ...
    %not the last frame and next frame doesn't need to be corrected
    adjacentX = xAVI(auto_frames(corrFrame)+1);
    adjacentY = yAVI(auto_frames(corrFrame)+1);
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
        xm=putativeMouseX(whichSharedMouseX);
        ym=putativeMouseY(whichSharedMouseY);
        fixedThisFrameFlag=1;
        got=[got; corrFrame]; 
    else    
        if pass==1
            skipped = [skipped; auto_frames(corrFrame)]; 
            fixedThisFrameFlag=0;
        elseif pass>=2 && corrFrame==1 %this shouldn't happen
            disp('this shouldn"t happen')
            [xm,ym]=ManualOnlyCorr;
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
global lastManualFrame; global pass; global aviSR

intendedFrame=v;
intendedFrameNum=auto_frames(corrFrame);
intendedFrameGood=0;
while intendedFrameGood==0
    figure(ManualCorrFig);
    imagesc(flipud(intendedFrame))
    title(['click here, frame ' num2str(auto_frames(corrFrame))])
    %if pass>2
        %plot existing point
        %hold on; plot(xAVI(intendedFrameNum),yAVI(intendedFrameNum),'og','MarkerSize',4,'MarkerFaceColor','g');hold off;
    %end
    [xm,ym,button] = ginput(1);
    fixedThisFrameFlag=0;
    switch button
        case 1 %left click
            %this point is good, use the xm ym
            hold on; plot(xm,ym,'og','MarkerSize',4,'MarkerFaceColor','g');hold off;
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
            hold on; plot(xm,ym,'og','MarkerSize',4,'MarkerFaceColor','g'); hold off
            xAVI(corrFrame) = xm;
            yAVI(corrFrame) = ym;
            Xpix(corrFrame) = ceil(xm/0.6246);
            Ypix(corrFrame) = ceil(ym/0.6246);
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
global fixedThisFrameFlag; global definitelyGood; global obj
global xAVI; global yAVI; global Xpix; global Ypix;
global lastManualFrame;

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
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CorrectTheseFrames(~,~)
%main frame correcting code here

end
%{
BoneYard

 = regionprops(grayGaussThreshB & maze,'centroid','area'); %flipped
for aa=1:length(expectedBlobs); blobCenters(aa,1:2)=expectedBlobs(aa).Centroid; end
[inBlob,onBlob] = inpolygon(blobCenters(:,1), blobCenters(:,2), maskx, masky);
inMaze= inBlob | onBlob; %probably going to yes all of them (maze above)
expectedBkgBlobs=expectedBlobs(inMaze);

%}