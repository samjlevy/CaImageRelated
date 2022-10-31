% SImulated data: xAVI and yAVI in a circle that does several laps; place
% field always in the same location

circleRadius = 10; %cm
behavFPS = 30; % frames per second for tracking
brainFPS = 20;
mouseSpeed = 10; %cm/s
mouseSpeed = 60; % degrees / s
timePerLap = 360/mouseSpeed; % 6s

nLapsTotal = 20;
totalTime = timePerLap*nLapsTotal;

placeFieldRegion = [80 115];

startPos = 0; % angle

% While we go around, we need to sample at behavior tracking rate and brain
% imaging rate for both data streams as sanity checks
% Then we can align them to each other
timeAVI = 0:(1/behavFPS):totalTime;
timeBrain = (1/brainFPS):(1/brainFPS):totalTime;
timeBrain = timeBrain(1:end-5);

angleAVI = timeAVI*mouseSpeed;
angleBrain = timeBrain*mouseSpeed;

[xAVI,yAVI]=pol2cart(deg2rad(angleAVI),circleRadius*ones(size(angleAVI)));
[xBrain,yBrain]=pol2cart(deg2rad(angleBrain),circleRadius*ones(size(angleBrain)));

%{
figure;
plotScalar = linspace(1,3,numel(angleAVI));
subplot(1,2,1); plot(xAVI.*plotScalar,yAVI.*plotScalar,'.')
plotScalar = linspace(1,3,numel(angleBrain));
subplot(1,2,2); plot(xBrain.*plotScalar,yBrain.*plotScalar,'.')
%}

% Make fake spiking
inFieldAVI = (mod(angleAVI,360) > min(placeFieldRegion)) & (mod(angleAVI,360) < max(placeFieldRegion));
inFieldBrain = (mod(angleBrain,360) > min(placeFieldRegion)) & (mod(angleBrain,360) < max(placeFieldRegion));
inFieldAVI(inFieldAVI==0) = NaN;
inFieldAVI(inFieldAVI==0) = NaN;

%{
figure;
plotScalar = linspace(1,3,numel(angleAVI));
subplot(1,2,1); plot(xAVI.*plotScalar,yAVI.*plotScalar,'.k')
hold on; plot(xAVI.*plotScalar.*inFieldAVI,yAVI.*plotScalar.*inFieldAVI,'.r')
title('Behavior time positions')
plotScalar = linspace(1,3,numel(angleBrain));
subplot(1,2,2); plot(xBrain.*plotScalar,yBrain.*plotScalar,'.k')
hold on; plot(xBrain.*plotScalar.*inFieldBrain,yBrain.*plotScalar.*inFieldBrain,'.r')
title('brain time positions')
%}

FT = inFieldBrain;
% FToffsetStuff
which_ends_first = 'imaging';
LastUsable = find(time >= timeBrain(end), 1, 'first');
FTlength = numel(inFieldBrain);
brainTime = timeBrain; 
time = timeAVI;
FToffset = 1;
imaging_start_frame = 1;

% AlignImagingToTracking
actualFTlength = FTlength;

switch whichEndsFirst
    case 'imaging'
        %LastUsable is a frame in tracking 
        FTuse = [FToffset actualFTlength];
        TrackingUse = [1 LastUsable];
    case 'tracking'
        %LastUsable is a frame for FT (i.e., FToffsetRear)
        FTuse = [FToffset LastUsable];
        TrackingUse = [1 TrackingLength];
end
brainTimeUse = FTuse;
if imaging_start_frame~=1
    brainTimeUse = brainTimeUse - (imaging_start_frame-1);
end 

xBrain = interp1( time(TrackingUse(1):TrackingUse(2)),...
                  xAVI(TrackingUse(1):TrackingUse(2)),...
                  brainTime(brainTimeUse(1):brainTimeUse(2)));
yBrain = interp1( time(TrackingUse(1):TrackingUse(2)),...
                  yAVI(TrackingUse(1):TrackingUse(2)),...
                  brainTime(brainTimeUse(1):brainTimeUse(2)));
              
brain_time = brainTime(brainTimeUse(1):brainTimeUse(2));
              
PSAboolUseIndices = FTuse(1):FTuse(2);
PSAboolAdjusted = FT(:,PSAboolUseIndices);

figure;
plotScalar = linspace(1,3,numel(angleBrain));
plot(xBrain.*plotScalar,yBrain.*plotScalar,'.k')
hold on
plot(xBrain.*plotScalar.*FT,yBrain.*plotScalar.*FT,'.r')
title('Pos interpolated to brain time')

%% Nat's original alignment method
% https://github.com/wmau/ImageCamp/blob/master/GCamp/AlignImagingToTracking_NK.m
% function [t_interp_valid, x_interp_valid, y_interp_valid, index_scopix_valid] = AlignImagingToTracking_NK(ICmovie_path, SR, xpos_interp, ypos_interp, t_interp, MoMtime)
folderUse = 'C:\Users\Sam\Desktop\doublePlusTest';

cd(folderUse)
load('FinalOutput.mat','PSAbool')

%time = pos_data(:,2); % time in seconds
load('PosLED_temp.mat','DVTtime','xAVI','yAVI')
time = DVTtime;

% This all comes from the end of PreProcessMousePosition_auto
aviSR = 30.0003; % the framerate that the .avi thinks it's at
PosSR = 30;

Xpix = xAVI;
Ypix = yAVI;
Xpix_filt = NP_QuickFilt(Xpix,0.0000001,1,PosSR);
Ypix_filt = NP_QuickFilt(Ypix,0.0000001,1,PosSR);

AVIobjTime = zeros(1,length(time)); 
for i = 1:length(time)
    AVIobjTime(i) = i/aviSR;
end

frame_rate_emp = round(1/mean(diff(time))); % empirical frame rate (frames/sec)

% Generate times to match brain imaging data timestamps
fps_brainimage = 20; % frames/sec for brain image timestamps

start_time = ceil(min(time)*fps_brainimage)/fps_brainimage;
max_time = floor(max(time)*fps_brainimage)/fps_brainimage;
time_interp = start_time:1/fps_brainimage:max_time;                         %20 Hz timer starts when you hit record.

if (max(time_interp) >= max_time)
    time_interp = time_interp(1:end-1);
end

% Do Linear Interpolation

% Get appropriate time points to interpolate for each timestamp
time_index = arrayfun(@(a) [max(find(a >= time)) min(find(a < time))],...
    time_interp,'UniformOutput',0);

time_test_cell = arrayfun(@(a) a,time_interp,'UniformOutput',0);

xpos_interp = cellfun(@(a,b) lin_interp(time(a), Xpix_filt(a),...           %20 Hz timer starts when you hit record.
    b),time_index,time_test_cell);

ypos_interp = cellfun(@(a,b) lin_interp(time(a), Ypix_filt(a),...           %20 Hz timer starts when you hit record.
    b),time_index,time_test_cell);  

AVItime_interp = cellfun(@(a,b) lin_interp(time(a), AVIobjTime(a),...       %20 Hz timer starts when you hit record.
    b),time_index,time_test_cell);

t_interp = AVItime_interp;
%}

% And here we're back to AlignImaging to Tracking

% Step 0: If SR is left blank, set it to 20
SR = 20; % braing imaging frame rate

% Step 1: Chop interp variables to match length of ICmovie - start at MoMtime,
%ICmovieLength = info.Dataspace.Size(3);
ICmovieLength = size(PSAbool,2);

% Scopix index and time setup
%MoMtime = 1; % S, actually arbitrary
MoMtime = t_interp(1);
t_scopix = (1:ICmovieLength)/SR;
%index_scopix_start = findclosest(MoMtime,t_scopix);

%function [ idx] = findclosest(val,array)
%function [ idx] = findclosest(val,array)
%[~,idx] = min(abs(array-val));
[~,index_scopix_start] = min(abs(t_scopix-MoMtime));

t_scopix_valid = t_scopix(index_scopix_start:end); % This now goes from MoMtime and ends at the finish of the movie
index_scopix_valid = index_scopix_start:ICmovieLength;

% Step 1.5: Fix annoying matlab problem where values that are off by 1e-13 due
% to some weird rounding error are not considered equal
round_pos = 3; % decimal point to round t_interp and t_scopix to
t_scopix = round(t_scopix, round_pos);
t_scopix_valid = round(t_scopix_valid, round_pos);
t_interp = round(t_interp, round_pos);
 
% Step 1.75: Continue with Step 1

% Get valid indices in t_interp, e.g. those that match a timestamp in
% t_scopix_valid
disp('Sam note: this seems to really not work, the majority of these points are not aligned at all...')
n = 1; nn = 1;
for j = 1:length(t_scopix_valid)
    if sum(t_scopix_valid(j) == t_interp) == 0 % Catch cases where there is no matching timestamp in t_interp
        index_scopix_invalid(n) = j;
        n = n + 1;
    else
        index_interp_valid(nn) = find(t_scopix_valid(j) == t_interp);
        nn = nn + 1;
    end
end

t_interp_valid = t_interp(index_interp_valid); % Get t_interp to match timestamps in t_scopix_valid
x_interp_valid = xpos_interp(index_interp_valid);
y_interp_valid = ypos_interp(index_interp_valid);
% Your interp variables should now match the length and times of
% t_scopix_valid

% Step 2: Step through each timestamp in t_scopix, and check to see if it 
% is in t_interp.  Create a filter of valid indices, index_scopix_valid, that 
% is 0 if the timestamp is not in t_interp, and 1 if it is.  Then, we 
% should not need an index_interp_valid at all, just an index_scopix_valid 
% that matches each value in the interp dataset!!

for j = 1:length(t_scopix)
    if j < index_scopix_start
        index_scopix_valid(j) = 0; % set anything before MoMtime to 0
    elseif j >= index_scopix_start
        if sum(t_scopix(j) == t_interp_valid) == 1
            index_scopix_valid(j) = 1; % Set anything that matches a time in t_interp to 1
            index_scopix_to_interp(j) = find(t_scopix(j) == t_interp_valid); % Get index that frame j in inscopix maps to in t_interp
        elseif sum(t_scopix(j) == t_interp_valid) == 0
            index_scopix_valid(j) = 0; % Set any time values in t_scopix that are missing in t_interp to 0
            index_scopix_to_interp(j) = 0;
        end
    end
end

index_scopix_valid = logical(index_scopix_valid);
index_scopix_valid = find(index_scopix_valid);


valid_length = length(t_scopix_valid);

%% trying to work with nat's version...

xxx = xpos_interp(index_scopix_valid);
yyy = ypos_interp(index_scopix_valid);
ppp = PSAbool(:,index_scopix_valid);

armPoly = [265 293; 531 282; 520 240; 376 252];
[inP,~] = inpolygon(xxx,yyy,armPoly(:,1),armPoly(:,2));

pppIn = sum(ppp(:,inP),2);
pppOut = sum(ppp(:,~inP),2);

armDiff = pppIn - pppOut;
cellPlot = 284;
%{
figure;
plot(xxx,yyy,'.k')
hold on
plot(xxx(ppp(cellPlot,:)),yyy(ppp(cellPlot,:)),'.r')
%}
figure;
plotScalar = (([0:sum(inP)-1]/(sum(inP)-1))*10)+1;
xpp = xxx(inP);
ypp = yyy(inP).*plotScalar;
plot(xpp,ypp,'|k')
hold on
plot(xpp(ppp(cellPlot,inP)),ypp(ppp(cellPlot,inP)),'|r')

%% What if inscopix is drifting?

%<attr name="frames">71531</attr>
%<attr name="record_start">Mar 23, 2018 01:03:09.367000 PM</attr>
%<attr name="record_end">Mar 23, 2018 02:02:46.753000 PM</attr>
tDir = 'C:\Users\Sam\Desktop\doublePlusTest';

nbFrames = 71531;
secondEnd = secondsFromTime(2,2,46.753);
secondStart = secondsFromTime(1,3,9.367);

tDir = 'C:\Users\Sam\Desktop\doublePlusTest\2';
nbFrames = 57464;
%<attr name="record_start">Mar 29, 2018 03:39:58.969000 PM</attr>
%<attr name="record_end">Mar 29, 2018 04:27:52.869000 PM</attr>
secondEnd = secondsFromTime(4,27,52.659);
secondStart = secondsFromTime(3,39,58.969);

load(ls('*PosLED_temp.mat'),'DVTtime','xAVI','yAVI')
time = DVTtime;
totalAviTime = time(end);

totalBrainTime = secondEnd - secondStart; % Amount reported by nVista
brainTimeAt20 = nbFrames / 20;

totalBrainTime = totalAviTime;

adjustedBrainTime = linspace(0,totalBrainTime,nbFrames);

TrackingLength = numel(time);

if totalBrainTime > totalAviTime
    whichEndsFirst = 'tracking';
    brainTimeUse = [1 LastUsable];
    TrackingUse = [1 TrackingLength];
elseif totalAviTime > totalBrainTime
    whichEndsFirst = 'imaging';
    LastUsable = find(time >= adjustedBrainTime(end), 1, 'first');
    brainTimeUse = [1 nbFrames];
    TrackingUse = [1 LastUsable];
elseif totalBrainTime == totalAviTime
    whichEndsFirst = 'same';
    brainTimeUse = [1 nbFrames];
    TrackingUse = [1 TrackingLength];
end

brainTime = adjustedBrainTime;

xBrain = interp1( time(TrackingUse(1):TrackingUse(2)),...
                  xAVI(TrackingUse(1):TrackingUse(2)),...
                  brainTime(brainTimeUse(1):brainTimeUse(2)));
yBrain = interp1( time(TrackingUse(1):TrackingUse(2)),...
                  yAVI(TrackingUse(1):TrackingUse(2)),...
                  brainTime(brainTimeUse(1):brainTimeUse(2)));
              
brain_time = brainTime(brainTimeUse(1):brainTimeUse(2));
              
PSAboolUseIndices = brainTimeUse(1):brainTimeUse(2);

load('FinalOutput.mat','PSAbool')

PSAboolAdjusted = PSAbool(:,PSAboolUseIndices);

figure;
plot(xBrain,yBrain,'.')
armPoly = zeros(4,2);
[armPoly(:,1),armPoly(:,2)] = ginput(4);
%armPoly = [360 277; 526 277; 526 250; 360 250];
[inP,~] = inpolygon(xBrain,yBrain,armPoly(:,1),armPoly(:,2));

[onsets,offsets] = GetBinaryWindows(inP);
durs = offsets - onsets;
ons = onsets(durs > 20);
offs = offsets(durs > 20);

cellPlot = 40;
originalCellHere = sortedSessionInds(cellPlot,9);
figure;
plot(xBrain,yBrain,'.')
hold on
plot(xBrain(PSAboolAdjusted(originalCellHere,:)),yBrain(PSAboolAdjusted(originalCellHere,:)),'.m')

figure;
for ii = 1:numel(ons)
    indH = ons(ii):offs(ii);
    xHere = xBrain(indH);
    psaHere = PSAboolAdjusted(originalCellHere,indH);
    plot(xHere,ii*ones(size(xHere)),'|','MarkerEdgeColor',0.6*[1 1 1])
    hold on
    plot(xHere(psaHere),ii*ones(size(xHere(psaHere))),'|','MarkerEdgeColor','m')
end



