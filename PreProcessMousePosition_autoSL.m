function [xpos_interp,ypos_interp,start_time,MoMtime,time_interp,AVItime_interp] = PreProcessMousePosition_autoSL( varargin)
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
%   OUTPUTS (all saved in Pos.mat, along with some others)
%   xpos_interp, ypos_interp: smoothed, corrected position data
%   interpolated to match the frame rate of the imaging data (hardcoded at
%   20 fps)
%
%   start_time: start of DVT file
%
%   MoMtime: the time that the mouse starts running on the maze

close all;
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

%%

% Script to take position data at given timestamps and output and interpolate
% to any given timestamps.

PosSR = 30; % native sampling rate in Hz of position data (used only in smoothing)
aviSR = 30.0003; % the framerate that the .avi thinks it's at
cluster_thresh = 40; % For auto thresholding - any time there are events above
% the velocity threshold specified by auto_thresh that are less than this
% number of frames apart they will be grouped together

if ~exist('filepath','var')
    [DVTfile, DVTpath] = uigetfile('*.DVT', 'Select DVT file');
    filepath = fullfile(DVTpath, DVTfile);
else
    [DVTpath,name,ext] = fileparts(filepath);
    DVTfile=fullfile(name,ext);
end    
cd(DVTpath);


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

PreCorrectedData=figure('name','Pre-Corrected Data');plot(Xpix,Ypix);title('pre-corrected data');

try
    h1 = implay('Raw.AVI');
    obj = VideoReader('Raw.AVI');
catch
    avi_filepath = ls('*.avi');
    h1 = implay(avi_filepath);
    disp(['Using ' avi_filepath ])
    obj = VideoReader(avi_filepath);
end

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
        load(load_file,'Xpix', 'Ypix', 'xAVI', 'yAVI', 'MoMtime', 'MouseOnMazeFrame');
        MoMtime
    else
        MouseOnMazeFrame = input('on what frame number does Mr. Mouse arrive on the maze??? --->');
        MoMtime = MouseOnMazeFrame*0.03+time(1)
    end
else
    MouseOnMazeFrame = input('on what frame number does Mr. Mouse arrive on the maze??? --->');
    MoMtime = MouseOnMazeFrame*0.03+time(1)
end
close(h1); % Close Video Player

% Get initial velocity profile for auto-thresholding
vel_init = hypot(diff(Xpix),diff(Ypix))/(time(2)-time(1));
%vel_init = [vel_init; vel_init(end)];
% vel_init = [vel_init(1); vel_init];
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
    
    auto_thresh = nan; % Don't perform any autocorrection if not specified
end

% start auto-correction of anything above threshold
MorePoints = 'y';

%{
% Determine if auto thresholding applies
if sum(auto_frames) > 0 && ~isnan(auto_thresh)
    flags.auto_thresh_flag = 1;
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
    flags.auto_thresh_flag = 0;
end
%}

%Positions and velocity trajectory figure
PosAndVel=figure('name','Position and Velocity');
hx0 = subplot(4,3,1:3);plot(time,Xpix);xlabel('time (sec)');ylabel('x position (cm)');yl = get(gca,'YLim');line([MoMtime MoMtime], [yl(1) yl(2)],'Color','r');axis tight;
hy0 = subplot(4,3,4:6);plot(time,Ypix);xlabel('time (sec)');ylabel('y position (cm)');yl = get(gca,'YLim');line([MoMtime MoMtime], [yl(1) yl(2)],'Color','r');axis tight;
linkaxes([hx0 hy0],'x');
hVel = subplot(4,3,7:12);plot(vel_init);xlabel('time (sec)');ylabel('velocity');axis tight;
hline=refline(0,auto_vel_thresh);hline.Color='r';hline.LineWidth=1.5;
vel = hypot(diff(Xpix),diff(Ypix))/(time(2)-time(1));

%% Draw a mask for the maze.

v0 = readFrame(obj);
MaskFig=figure('name', 'Cage Mask'); imagesc(v0);
maskSwitch= exist('maskx','var') && exist('masky','var');
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
            figure(MaskFig); imagesc(v0);
            title('Draw position mask');
            [maze, maskx, masky] = roipoly;
            hold on; plot([maskx; maskx(1)],[masky; masky(1)],'r','LineWidth',2)
            cageMaskGood=0;       
    end
end
close(MaskFig)


%% Get background image:
if ~exist('backgroundImage','var')
bkgChoice = questdlg('Supply/Load background image or composite?', ...
	'Background Image', ...
	'Load','Frame #','Composite','Composite');
else
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
        backgroundFrame=figure; imagesc(backgroundImage); title('Background Image')
        %could break here to allow fixing a piece of this one
    case 'Composite'
        try
            h1 = implay(avi_filepath);
        catch
            avi_filepath = ls('*.avi');
            h1 = implay(avi_filepath);
        end    
        msgbox({'Find images: ' '   -frame 1: top half has no mouse' '   -frame 2: bottom half has no mouse'})
        topClearNum = input('Frame number with no mouse on top: ')
        bottomClearNum = input('Frame number with no mouse on bottom: ')
        
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
        backgroundFrame=figure; imagesc(compositeBkg); title('Composite Background Image')
        %fix a hole: ginput to get a hole, manually find frame number where
        %that's clear, insert those pixels.
        compGood=0;
        while compGood==0
        holdChoice = questdlg('Good or fix a piece?', ...
                              'Background Image', ...
                              'Good','Fix area','Good');               
        switch holdChoice
            case 'Good'
                close(h1);
                compGood=1;
            case 'Fix area'
                figure(backgroundFrame); title('Select area to swap out')
                [swapRegion, SwapX, SwapY] = roipoly;
                hold on 
                plot([SwapX; SwapX(1)],[SwapY; SwapY(1)],'r','LineWidth',2)
                h1; msgbox('Enter frame number of image to swap in')
                swapInNum = input('Frame number to swap in area from ---->')
                try; close h1; end
                obj.CurrentTime = (swapInNum-1)/obj.FrameRate;
                swapClearFrame = readFrame(obj);
                [rows,cols]=ind2sub([480,640],find(swapRegion));
                compositeBkg(rows,cols,:)=swapClearFrame(rows,cols,:);
                figure(backgroundFrame);imagesc(compositeBkg)
                compGood=0;
        end
        end
        backgroundImage = compositeBkg;
end
end
%%    

%plot(xAVI(inCage),yAVIflip(inCage),'.y')
[height,~,~]=size(v0);
yAVI=height-yAVI; flags.yAVIflippedFlag=1;
inBounds = inpolygon(xAVI,yAVI,maskx,masky);

%auto_frames = (Xpix == 0 | Ypix == 0 ) & time > MoMtime;
auto_frames = inBounds==0;
highVel_frames = vel_init > auto_vel_thresh;
msgbox(['Frames out of bounds first: n=' num2str(sum(auto_frames))])

n = 1; %first_time = 1;
%% Thresholding
%threshFrameInds=randi(length(xAVI),3,1);
%{
play=figure('name','PlayFrame'); imagesc(playFrame)
playGray=rgb2gray(playFrame);
grayFrane=figure('name','GrayFrame'); imagesc(playGray)
colormap(gray)
[colSamp,rowSamp]=ginput(3);
for tsam=1:length(xsamp)
    thresh(tsam)=playGray(round(rowSamp(tsam)),round(colSamp(tsam)));

end
grayFrame=rgb2gray(playFrame); colormap(gray)
threshFrame=grayFrame<100;
gaussThresh=imgaussfilt(double(threshFrame),10);
g0thresh=gaussThresh>0.2;
stats = regionprops(g0thresh & maze,'area','centroid','majoraxislength','minoraxislength');
B = bwboundaries(BW);
%}
%% Sam's full auto sequence
%Wrap into callable function at the end? Probably need to use globals.
missed=[];
max_pixel_jump=sqrt(50^2+50^2);
distLim=max_pixel_jump;
grayThresh=100; gaussThresh=0.2;
flags.full_auto_done=0;
frame_is_good=xAVI*0;%only use when user-confirmed positions
%while flags.full_auto_done==0
    offInds=diff(auto_frames);
    ends=find(offInds==-1);
    ons=find(offInds==1)+1;
    if auto_frames(1)==1
        ons=[1; ons];
    end
    if auto_frames(end)==1
        ends=[ends; time(end)];
    end    
    if length(ends)~=length(ons)
       %????
       disp('Unequal number ends and ons')
    else 
        offMazeEpochs=[ons ends];
    end
    
    %Or just this part as callable function?
    numOffEpochs=length(ons);
    offMazeEpochs(1,1) = min(Ons(1), MouseOnMazeFrame);
    
    resol = 1; % Percent resolution for progress bar
    p = ProgressBar(100/resol);
    update_inc = round(sum(auto_frames)/(100/resol));
    total=0;
    for offEpoch=1:numOffEpochs
        for corrFrame = offMazeEpochs(offEpoch,1):offMazeEpochs(offEpoch,2)
            %If there's only one bad frame interpolate position
            if offMazeEpochs(offEpoch,2)-offMazeEpochs(offEpoch,1)==0 && offEpoch(1,1)~=1
                xm=(xAVI(offMazeEpochs(offEpoch,2)+1) + xAVI(offMazeEpochs(offEpoch,2)-1))/2;
                ym=(yAVI(offMazeEpochs(offEpoch,2)+1) + yAVI(offMazeEpochs(offEpoch,2)-1))/2;
            else %THIS PART ISN"T DONE YET %Can it handle frame on?
                %Run will's thing on the sequence
                %or maybe just this part?
                %Subtract current frame from reference, then smooth. Next,
                %run regionprops.
                obj.CurrentTime = (corrFrame-1)/aviSR;
                currentFrame = readFrame(obj);
                d = imgaussfilt(rgb2gray(backgroundImage-currentFrame),10);
                %shading? probably can't get it from diff
                stats = regionprops(d>20 & maze,'centroid');%'area','solidity','eccentricity','majoraxislength','minoraxislength'
            
                %Find the blob that corresponds to the mouse.
                MouseBlob = find(   [stats.Area] > 300 & ...
                    [stats.MajorAxisLength] > 10 & ...
                    [stats.MinorAxisLength] > 10);
                    %use more restrictions to better identify mouse
                    
                if length(MouseBlob)==1
                    xm = stats(MouseBlob).Centroid(1);
                    ym = stats(MouseBlob).Centroid(2);
                elseif length(MouseBlob)>1
                    %Get mouse position on the previous frame.
                    %Assumes previous frame is good: if previous frame is
                    %bad b/c high velocity jump, will shift all to that new
                    %area, 
                    switch corrFrame==1
                        case 1 %No previous, manual fix
                            ManualCorrect=figure; title('click here')
                            imagesc(currentFrame)
                            [xm, ym]=ginput(1);
                            close ManualCorrect;
                        case 0 %Run as normal
                            %UPDATE: last one not tagged to fix 
                            previousX = xAVI(corrFrame-1);
                            previousY = yAVI(corrFrame-1);
                            
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
                                %compile to single blog by distance, doesn't exceed
                                %velocity of known good points around it in time
                            else
                                %blob that agrees with raw thresholding
                                %(any?)
                                 %colormap(gray)
                                grayGaussThresh=imgaussfilt(double(rgb2gray(currentFrame)<grayThresh),10)>gaussThresh;
                                grayStats = regionprops(grayGaussThresh & maze,'centroid');
                                possible=[];
                                for statses=1:length(stats)
                                for grats=1:length(grayStats)
                                poRow=size(possible,1)+1;    
                                possible(poRow,1:3)=[statses grats...
                                    hypot(stats(statses).Centroid(1)-grayStats(grats).Centroid(1),...
                                    stats(statses).Centroid(2)-grayStats(grats).Centroid(2))];
                                end; end
                                posDel=possible(:,3)>distLim;
                                possible(posDel,:)=[];
                                if size(possible,1)==1
                                    xm=mean([stats(possible(1)).Centroid(1) grayStats(possible(2)).Centroid(1)]);
                                    ym=mean([stats(possible(1)).Centroid(2) grayStats(possible(2)).Centroid(2)]);
                                else
                                    %if they don't, get the overall closest check
                                    %distance limit  max_pixel_jump, could
                                    %scale by how near in time good frame is
                                    missed=[missed; corrFrame]; %disp(['Frame ' num2str(corrFrame) ' not fixed'])
                                end
                            end
                    end        
                    
                end
                
                %double check its not outside the maze?
                xAVI(corrFrame)=xm; yAVI(corrFrame)=ym;
                Xpix(corrFrame) = ceil(xm/0.6246);
                Ypix(corrFrame) = ceil((height-ym)/0.6246);           
            end
            
            total=total+1;
            if round(total/update_inc) == (total/update_inc) % Update progress bar
                p.progress;
            end
        end %each frame
        
        %Update position and velocity figure
        %{
        figure(PosAndVel)
        hx0 = subplot(4,3,1:3);plot(time,Xpix);xlabel('time (sec)');ylabel('x position (cm)');yl = get(gca,'YLim');line([MoMtime MoMtime], [yl(1) yl(2)],'Color','r');axis tight;
        hy0 = subplot(4,3,4:6);plot(time,Ypix);xlabel('time (sec)');ylabel('y position (cm)');yl = get(gca,'YLim');line([MoMtime MoMtime], [yl(1) yl(2)],'Color','r');axis tight;
        linkaxes([hx0 hy0],'x');
        vel = hypot(diff(Xpix),diff(Ypix))/(time(2)-time(1));
        hVel = subplot(4,3,7:12);plot(vel);xlabel('time (sec)');ylabel('velocity');axis tight;
        hline=refline(0,auto_vel_thresh);hline.Color='r';hline.LineWidth=1.5;
          %}  
        %save Pos_temp.mat Xpix Ypix xAVI yAVI MoMtime MouseOnMazeFrame
    end %each epoch
    p.stop;
    save Pos_temp.mat Xpix Ypix xAVI yAVI MoMtime MouseOnMazeFrame maze maskx masky backgroundImage
%end
%run again for too fast points, need to get fancier...
flags.full_auto_done=1;
%%

%Maybe run this first before new stuff...
    
while (strcmp(MorePoints,'y')) || strcmp(MorePoints,'m') || isempty(MorePoints)
    %     if first_time == 1
    %         hx0 = subplot(4,3,1:3); plot(time,Xpix); xlabel('time (sec)'); ylabel('x position (cm)');
    %         hold on;yl = get(gca,'YLim');line([MoMtime MoMtime], [yl(1) yl(2)],'Color','r');hold off;axis tight;
    %         hy0 = subplot(4,3,4:6); plot(time,Ypix); xlabel('time (sec)'); ylabel('y position (cm)');
    %         hold on;yl = get(gca,'YLim');line([MoMtime MoMtime], [yl(1) yl(2)],'Color','r');hold off;axis tight;
    %         first_time = 0;
    %         linkaxes([hx0 hy0],'x');
    %     end
    if flags.auto_thresh_flag == 0 || isempty(epoch_start)
        MorePoints = input('Is there a flaw that needs to be corrected?  [y/n/manual correct (m)] -->','s');
    else
        MorePoints = 'y'; pause(1)
    end
    
    
    if strcmp(MorePoints,'y')
        if flags.auto_thresh_flag == 0 || isempty(epoch_start)
            FrameSelOK = 0;
            while (FrameSelOK == 0)
                display('click on the good points around the flaw then hit enter');
                [DVTsec,~] = ginput(2); % DVTsec is start and end time in DVT seconds
                sFrame = findclosest(time,DVTsec(1)); % index of start frame
                eFrame = findclosest(time,DVTsec(2)); % index of end frame
                eFrame = max(eFrame,time(end));
                aviSR*sFrame;
                
                if (sFrame/aviSR > obj.Duration || eFrame/aviSR > obj.Duration)
                   continue;
                end
                %               obj.currentTime = sFrame/aviSR; % sFrame is the correct frame #, but .avi reads are done according to time
                %               v = readFrame(obj);
                FrameSelOK = 1;
                
            end
            
        elseif flags.auto_thresh_flag == 1 && full_auto_done==1% Input times from auto_threholded vector
            sFrame = max([1 epoch_start(n)- 6]);
            eFrame = min([length(time) epoch_end(n) + 6]);
            
            % Turn on manual thresholding once you correct all epochs above
            % the velocity threshold
            if n == n_epochs
                flags.auto_thresh_flag = 0;
            else
                n = n + 1;
            end
        end
        obj.currentTime = sFrame/aviSR; % sFrame is the correct frame #, but .avi reads are done according to time
        v = readFrame(obj);
        
        framesToCorrect = sFrame:eFrame;
        if eFrame >= max(time)
            framesToCorrect = sFrame:eFrame-2; % Fix case where last frame needs to be corrected
        end
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
                plot(xAVI(MouseOnMazeFrame:end),yAVI(MouseOnMazeFrame:end),'LineWidth',1.5);hold off;title('overall trajectory (post mouse arrival)');
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
                    %compile to single blog by distance, doesn't exceed
                    %velocity of known good points around it in time
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
        
        % plot updated velocity
        figure(555);
        subplot(4,3,7:9);
        vel = hypot(diff(Xpix),diff(Ypix))/(time(2)-time(1));
        vel = [vel; vel(end)]; % Make the vectors the same size
        plot(time(MouseOnMazeFrame:end),vel(MouseOnMazeFrame:end));
        hold on
        plot(time([sFrame eFrame]),vel([sFrame eFrame]),'ro'); % plot start and end points of last edit
        if flags.auto_thresh_flag == 1
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
        save Pos_temp.mat Xpix Ypix xAVI yAVI MoMtime MouseOnMazeFrame
        
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
            %               obj.currentTime = sFrame/aviSR; % sFrame is the correct frame #, but .avi reads are done according to time
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
                plot(xAVI(MouseOnMazeFrame:end),yAVI(MouseOnMazeFrame:end),'LineWidth',1.5);hold off;title('overall trajectory (post mouse arrival)');
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
        if flags.auto_thresh_flag == 1
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
        save Pos_temp.mat Xpix Ypix xAVI yAVI MoMtime MouseOnMazeFrame
        
        continue
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
save Pos.mat xpos_interp ypos_interp time_interp start_time MoMtime Xpix Ypix xAVI yAVI MouseOnMazeFrame AVItime_interp

end