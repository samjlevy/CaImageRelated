%This script is to test the effectiveness of various approaches
%to auto-finding the mouse's position from the image data. Idea is to run
%each of these on the same set of unprocessed points (unassisted) and see
%both how many it can fix and how many is messes up (number of high velocity
%jumps, etc)
% Background subtraction, followed by:
%   1. Will's version: background image subtraction, get blob that is
%       closest to the last position
%   2. Raw-thresh + background: is there ONE blob in the raw thresholded
%       image (by brightness) that agrees with the background image
%       subtraction
%   3. Raw-thresh + last: is there a blob in the raw threshold image (by
%       brightness) that is within minimum jump distance from the last
%       known good position?
%   4. Small blobs, blob similarity by last good frame
%   5. Kalman type

%data to work
obj = VideoReader('E:\Polaris\Polaris_160901\160901_Polaris.AVI');
load('C:\Users\Sam\Desktop\effectiveTestStuff.mat')
xPixRaw=Xpix;yPixRaw=Ypix;
xAVIraw=xAVI;yAVIraw=yAVI;

%frames to test

zero_frames = Xpix == 0 | Ypix == 0 ;
%auto_zero = find(zero_frames);
[in,on] = inpolygon(xAVI, yAVI, maskx, masky);
inBounds = in | on;
outOfBounds=inBounds==0;
auto_logical = zero_frames | outOfBounds;
auto_frames = find(auto_logical);

%setup vars
aviSR = 30.0003;
fixedHere=Xpix*0;
grayThresh=100; gaussThresh=0.2;
max_pixel_jump=sqrt(50^2+50^2);
distLim=max_pixel_jump;
distLim2=45;
centersAgreeDist=50;
v0=flipud(v0);


methods={'will';...
         'willBack';...
         'thresh';...
         'threshBack';...
         'threshNwill';...
         'threshNwill2';...
         'threshNwillBack';}; 


for method=2:length(methods)
Xpix=xPixRaw; Ypix=yPixRaw;
xAVI=xAVIraw; yAVI=yAVIraw;
%for pointType=1:2
    %auto_frames, then high vel
disp(['Running effectiveness check for method: ' methods{method}])
resol = 1; % Percent resolution for progress bar
p = ProgressBar(100/resol);

update_inc = round(length(auto_frames)/(100/resol));
howWell(method).missed=[];
howWell(method).got=[];
total=0;

for corrFrame=1:length(auto_frames)
    fixedThisFrameFlag=0;
    obj.CurrentTime=(auto_frames(corrFrame)-1)/aviSR;
    v = readFrame(obj);
    
    switch method
        case 1 %will only
            d = imgaussfilt(flipud(rgb2gray(v0-v)),10);
            stats = regionprops(d>20 & maze,'area','centroid','majoraxislength','minoraxislength');%'solidity','eccentricity',
            MouseBlob = find(   [stats.Area] > 300 & ...
                [stats.MajorAxisLength] > 10 & ...
                [stats.MinorAxisLength] > 10);
            if length(MouseBlob)==1
                xm = stats(MouseBlob).Centroid(1);
                ym = stats(MouseBlob).Centroid(2);
                fixedThisFrameFlag=1;
                howWell(method).got=[howWell(method).got corrFrame];
            else
                fixedThisFrameFlag=0;
                howWell(method).missed=[howWell(method).missed corrFrame];
            end
        case 2 %will plus look back a frame
            d = imgaussfilt(flipud(rgb2gray(v0-v)),10);
            stats = regionprops(d>20 & maze,'area','centroid','majoraxislength','minoraxislength');%'solidity','eccentricity',
            MouseBlob = find(   [stats.Area] > 300 & ...
                [stats.MajorAxisLength] > 10 & ...
                [stats.MinorAxisLength] > 10);
            if length(MouseBlob)==1
                xm = stats(MouseBlob).Centroid(1);
                ym = stats(MouseBlob).Centroid(2);
                fixedThisFrameFlag=1;
                howWell(method).got=[howWell(method).got corrFrame];
            elseif length(MouseBlob)>1 && auto_frames(corrFrame)>1 ...
                && any(howWell(method).missed == (auto_frames(corrFrame)-1))==0
                %Get mouse position on the previous frame.
                previousX = xAVI(auto_frames(corrFrame)-1);
                previousY = yAVI(auto_frames(corrFrame)-1);
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
                    fixedThisFrameFlag=1;
                    howWell(method).got=[howWell(method).got corrFrame];
                else
                    fixedThisFrameFlag=0;
                    howWell(method).missed=[howWell(method).missed corrFrame];
                end
            else
                fixedThisFrameFlag=0;
                howWell(method).missed=[howWell(method).missed corrFrame];
            end
        case 3 %thresh only
            %area, major/minor axis, etc?
            grayFrame=rgb2gray(v);
            grayFrameThresh=grayFrame<grayThresh;
            grayGauss=imgaussfilt(double(grayFrameThresh),10);
            grayGaussThresh=grayGauss>gaussThresh;
            grayStats = regionprops(flipud(grayGaussThresh) & maze,'centroid','area');
            possible=[];
            if length(grayStats)==1
                xm = grayStats.Centroid(1);
                ym = grayStats.Centroid(2);
                fixedThisFrameFlag=1;
                howWell(method).got=[howWell(method).got corrFrame];
            else
                fixedThisFrameFlag=0;
                howWell(method).missed=[howWell(method).missed corrFrame];
            end    
        case 4 %thresh plus look back a frame 
            grayFrame=rgb2gray(v);
            grayFrameThresh=grayFrame<grayThresh;
            grayGauss=imgaussfilt(double(grayFrameThresh),10);
            grayGaussThresh=grayGauss>gaussThresh;
            grayStats = regionprops(grayGaussThresh & maze,'centroid','area');
            possible=[];
            if size(grayStats,1)==1
                xm = grayStats.Centroid(1);
                ym = grayStats.Centroid(2);
                fixedThisFrameFlag=1;
                howWell(method).got=[howWell(method).got corrFrame];
            elseif any(howWell(method).missed == (auto_frames(corrFrame)-1))==0 ...
                && auto_frames(corrFrame)>1
                previousX = xAVI(auto_frames(corrFrame)-1);
                previousY = yAVI(auto_frames(corrFrame)-1);
            %{
            GrayMouseBlob = find(   [grayStats.Area] > 50 & ...
                [stats.MajorAxisLength] > 10 & ...
                [stats.MinorAxisLength] > 10);
            %}
                for aa=1:size(grayStats,1)
                %putativeGrayMouse(aa) = grayStats(:).Centroid;
                    putativeGrayMouseX(aa) = grayStats(aa).Centroid(1);
                    putativeGrayMouseY(aa) = grayStats(aa).Centroid(2);
                end    
                whichGrayMouseX = findclosest(putativeGrayMouseX,previousX);
                whichGrayMouseY = findclosest(putativeGrayMouseY,previousY);
                if whichMouseX == whichMouseY
                    xm = grayStats(whichGrayMouseX).Centroid(1);
                    ym = grayStats(whichGrayMouseY).Centroid(2);
                    fixedThisFrameFlag=1;
                    howWell(method).got=[howWell(method).got corrFrame];
                else
                    fixedThisFrameFlag=0;
                    howWell(method).missed=[howWell(method).missed corrFrame];
                end  
            else 
                fixedThisFrameFlag=0;
                howWell(method).missed=[howWell(method).missed corrFrame];
            end
        case 5 %thresh and will agree
            %will
            d = imgaussfilt(flipud(rgb2gray(v0-v)),10);
            stats = regionprops(d>20 & maze,'area','centroid','majoraxislength','minoraxislength');%'solidity','eccentricity',
            MouseBlob = find(   [stats.Area] > 300 & ...
            [stats.MajorAxisLength] > 10 & ...
            [stats.MinorAxisLength] > 10);
            putativeMouse = [stats(MouseBlob).Centroid];
            putativeMouseX = putativeMouse(1:2:end);
            putativeMouseY = putativeMouse(2:2:end);
            %thresh
            grayFrame=rgb2gray(v);
            grayFrameThresh=grayFrame<grayThresh;
            grayGauss=imgaussfilt(double(grayFrameThresh),10);
            grayGaussThresh=grayGauss>gaussThresh;
            grayStats = regionprops(grayGaussThresh & maze,'centroid');
            possible=[];
            if ~isempty(grayStats) && ~isempty(stats)
            for statses=1:length(stats)
                for grats=1:size(grayStats,1)
                    poRow=size(possible,1)+1;     
                    possible(poRow,1:3)=[statses grats...
                    hypot(stats(statses).Centroid(1)-grayStats(grats).Centroid(1),...
                    stats(statses).Centroid(2)-grayStats(grats).Centroid(2))];
                end 
            end
            posDel=possible(:,3)>distLim; possible(posDel,:)=[];
            if size(possible,1)==1
                xm=mean([stats(possible(1)).Centroid(1) grayStats(possible(2)).Centroid(1)]);
                ym=mean([stats(possible(1)).Centroid(2) grayStats(possible(2)).Centroid(2)]);
                fixedThisFrameFlag=1;
                howWell(method).got=[howWell(method).got corrFrame];
            else
                fixedThisFrameFlag=0;
                howWell(method).missed=[howWell(method).missed corrFrame];
            end
            else
                fixedThisFrameFlag=0;
                howWell(method).missed=[howWell(method).missed corrFrame];
            end
        case 6 %thresh and will agree, distLim2 (smaller)
            d = imgaussfilt(flipud(rgb2gray(v0-v)),10);   %flipud
            stats = regionprops(d>20 & maze,'area','centroid','majoraxislength','minoraxislength');%'solidity','eccentricity',
            MouseBlob = find(   [stats.Area] > 300 & ...
            [stats.MajorAxisLength] > 10 & ...
            [stats.MinorAxisLength] > 10);
            putativeMouse = [stats(MouseBlob).Centroid];
            putativeMouseX = putativeMouse(1:2:end);
            putativeMouseY = putativeMouse(2:2:end);
            %thresh
            grayFrame=rgb2gray(flipud(v));   %flipud
            grayFrameThresh=grayFrame<grayThresh;
            grayGauss=imgaussfilt(double(grayFrameThresh),10);
            grayGaussThresh=grayGauss>gaussThresh;
            grayStats = regionprops(grayGaussThresh & maze,'centroid','area');
            possible=[]; 
            if ~isempty(grayStats) && ~isempty(stats)
            for statses=1:length(stats)
                for grats=1:size(grayStats,1)
                    poRow=size(possible,1)+1; 
                    %possible is [stats_index, graystats_index, distance]
                    possible(poRow,1:3)=[statses grats...
                    hypot(stats(statses).Centroid(1)-grayStats(grats).Centroid(1),...
                    stats(statses).Centroid(2)-grayStats(grats).Centroid(2))];
                end 
            end
            posDel=possible(:,3)>distLim2; possible(posDel,:)=[];%HERE WHERE IT'S DIFFERENT
            if size(possible,1)==1
                xm=mean([stats(possible(1)).Centroid(1) grayStats(possible(2)).Centroid(1)]);
                ym=mean([stats(possible(1)).Centroid(2) grayStats(possible(2)).Centroid(2)]);
                fixedThisFrameFlag=1;
                howWell(method).got=[howWell(method).got corrFrame];
            else
                fixedThisFrameFlag=0;
                howWell(method).missed=[howWell(method).missed corrFrame];
            end
            else
                fixedThisFrameFlag=0;
                howWell(method).missed=[howWell(method).missed corrFrame];
            end
        case 7 %thresh plus will's plus back %seems to be working best
            %Will
            d = imgaussfilt(flipud(rgb2gray(v0-v)),10); %flipud
            stats = regionprops(d>20 & maze,'area','centroid','majoraxislength','minoraxislength');%'solidity','eccentricity',
            MouseDel= find ([stats.Area] < 300); stats(MouseDel)=[];
            %{
            MouseBlob = find(   [stats.Area] > 300 & ...
            [stats.MajorAxisLength] > 10 & ...
            [stats.MinorAxisLength] > 10);
            putativeMouse = [stats(MouseBlob).Centroid];
            putativeMouseX = putativeMouse(1:2:end);
            putativeMouseY = putativeMouse(2:2:end);
            %}
            %thresh
            grayFrameThresh=rgb2gray(flipud(v)) < grayThresh; %flipud
            grayGaussThresh=imgaussfilt(double(grayFrameThresh),10) > gaussThresh;
            grayStats = regionprops(grayGaussThresh & maze,'centroid');
            possible=[];
            if ~isempty(grayStats) && ~isempty(stats) %what if one is empty?
            for statsInd=1:length(stats)
                for grayStatsInd=1:length(grayStats)
                    poRow=size(possible,1)+1;  
                    %possible is [stats_index, graystats_index, distance]
                    possible(poRow,1:3)=[statsInd grayStatsInd...
                    hypot(stats(statsInd).Centroid(1)-grayStats(grayStatsInd).Centroid(1),...
                    stats(statsInd).Centroid(2)-grayStats(grayStatsInd).Centroid(2))];
                end 
            end
            posDel=possible(:,3)>distLim2; possible(posDel,:)=[];
            %not sure all this works yet...
            if size(possible,1)==0
                %No agreement using distance limit
                fixedThisFrameFlag=0;
                howWell(method).missed=[howWell(method).missed corrFrame];
            elseif size(possible,1)==1
                %Will and thresh agree on one blob
                xm=mean([stats(possible(1)).Centroid(1) grayStats(possible(2)).Centroid(1)]);
                ym=mean([stats(possible(1)).Centroid(2) grayStats(possible(2)).Centroid(2)]);
                fixedThisFrameFlag=1;
                howWell(method).got=[howWell(method).got corrFrame];
            elseif any(howWell(method).missed == (auto_frames(corrFrame)-1))==0 ...
                    && auto_frames(corrFrame)>1
                %more than one blob will and thresh agree on
                previousX = xAVI(auto_frames(corrFrame)-1);
                previousY = yAVI(auto_frames(corrFrame)-1);
                for posNum=1:size(possible,1)
                    putativeMouseX(posNum)=mean([stats(possible(posNum,1)).Centroid(1) grayStats(possible(posNum,2)).Centroid(1)]);
                    putativeMouseY(posNum)=mean([stats(possible(posNum,1)).Centroid(2) grayStats(possible(posNum,2)).Centroid(2)]);
                end
                whichSharedMouseX = findclosest( previousX, putativeMouseX);
                whichSharedMouseY = findclosest( previousY, putativeMouseY);
                if whichSharedMouseX  == whichSharedMouseY
                    xm=putativeMouseX(whichSharedMouseX);
                    ym=putativeMouseY(whichSharedMouseY);
                    fixedThisFrameFlag=1;
                    howWell(method).got=[howWell(method).got corrFrame];
                else    
                    %%%?????
                end
            end
            else 
                %What to do if either will or thresh is empty
                %A: whichever is not, use blob closest to last known good
                fixedThisFrameFlag=0;
                howWell(method).missed=[howWell(method).missed corrFrame];
            end
    end
    if fixedThisFrameFlag==1
        xAVI(corrFrame) = xm; yAVI(corrFrame) = ym;
        Xpix(corrFrame) = ceil(xm/0.6246); Ypix(corrFrame) = ceil(ym/0.6246);
    end    
    total=total+1;
    if round(total/update_inc) == (total/update_inc) % Update progress bar
        p.progress;
    end
end
howWell(method).Xpix=Xpix; howWell(method).Ypix=Ypix;
howWell(method).xAVI=xAVI; howWell(method).yAVI=yAVI;
howWell(method).vel_init = hypot(diff(Xpix),diff(Ypix))/(time(2)-time(1));
howWell(method).highVel = howWell(method).vel_init>1500;
howWell(method).stillTooFast=sum(howWell(method).highVel);
howWell(method).method=methods{method};

p.stop;
disp(['Completed auto-pass on ' methods{method}])
            
end 
%{
howWell(length(methods)+1).Xpix=xPixRaw;
howWell(length(methods)+1).Ypix=yPixRaw;
howWell(length(methods)+1).xAVI=xAVIraw;
howWell(length(methods)+1).yAVI=yAVIraw;
howWell(length(methods)+1).vel_init = hypot(diff(xPixRaw),diff(yPixRaw))/(time(2)-time(1));
howWell(length(methods)+1).highVel = howWell(length(methods)+1).vel_init>1500;
howWell(length(methods)+1).stillTooFast = sum(howWell(length(methods)+1).highVel);
howWell(length(methods)+1).stillTooFast=sum(howWell(length(methods)+1).highVel);
howWell(length(methods)+1).method='original data';
 %}
 
