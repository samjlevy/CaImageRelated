% should do this after PreProcessMousePosition_auto, before
% AlignImagingToTracking
% This is mean to auto-parse laps
cd(C:\Users\samwi_000\Documents\Lab\bits160831)

[AVIfile, AVIpath] = uigetfile('*.avi');
%h1=implay(fullfile(AVIpath,AVIfile));
obj = VideoReader(fullfile(AVIpath,AVIfile));
v0 = readFrame(obj);

load('Pos.mat')
xAVI = Xpix*.6246;
yAVI = Ypix*.6246;
[tall,~,~]=size(v0);
yAVIflip = tall - yAVI;

PosSR = 30; % native sampling rate in Hz of position data (used only in smoothing)
aviSR = 30.0003; % the framerate that the .avi thinks it's at
%cluster_thresh = 40;

%obj.currentTime = sFrame/aviSR; % sFrame is the correct frame #, but .avi reads are done according to time
%v = readFrame(obj);



%{
pointInd = 1:length(xAVI);
Positions = figure;
Positions.Name = 'Positions';
subplot(2,1,1);
plot(pointInd,xAVI)
ylabel('X pos')
title('Position by time')
subplot(2,1,2);
plot(pointInd,yAVIflip)
ylabel('Y pos')

%when is the mouse in the cage
figure(Positions);
subplot(2,1,1);
hold on
plot(pointInd(inCage),xAVI(inCage),'.g','MarkerSize',1)
subplot(2,1,2);
hold on
plot(pointInd(inCage),yAVIflip(inCage),'.g','MarkerSize',1)

%cage epochs
figure(Positions);
subplot(2,1,1);
hold on
plot(pointInd(cageEpochs(:,1)),xAVI(cageEpochs(:,1)),'og')
plot(pointInd(cageEpochs(:,2)),xAVI(cageEpochs(:,2)),'ok')
subplot(2,1,2);
hold on
plot(pointInd(cageEpochs(:,1)),yAVIflip(cageEpochs(:,1)),'og')
plot(pointInd(cageEpochs(:,2)),yAVIflip(cageEpochs(:,2)),'ok')

%}

%Define bounds
DotPlot=figure;
DotPlot.Name = 'Dot Plot';
imagesc(v0)
hold on
plot(xAVI,yAVIflip,'.','MarkerSize',0.5)
title('Draw cage boundary (press enter to stop)')
[polx,poly] = ginput;
hold on
title(' ')
plot([polx; polx(1)],[poly; poly(1)],'r','LineWidth',2)
%Ask if it's good

inCage = inpolygon(xAVI,yAVIflip,polx,poly);
plot(xAVI(inCage),yAVIflip(inCage),'.y')

cageIns = find(diff(inCage)==1)+1; 
cageOuts = find(diff(inCage)==-1)+1;
if cageOuts(1) < cageIns(1)
    disp('Found an orphan cage out, assuming session starts w/ mouse in cage')
    cageIns(2:length(cageIns)+1)=cageIns;
    cageIns(1)=1;
end

%check there aren't any brief out/in BREAKS if first one is too short
cageEpochs = [cageIns' cageOuts'];
cagedDurs = cageEpochs(:,2)-cageEpochs(:,1);
cagedTooShort = cagedDurs < 30;
cageIns(cagedTooShort) = [];
cageOuts(find(cagedTooShort)-1) = [];
disp(['Trimmed out ' num2str(sum(cagedTooShort)) ' quick exit/entries'])
cageEpochs = [cageIns, cageOuts];
inCageCheck=pointInd;
inCageCheck(:)=0;
for aa=1:length(cageEpochs)
    inCageCheck(cageEpochs(aa,1):cageEpochs(aa,2))=1;
end

%Get mouse place and pickup spots
figure(DotPlot);
title('Select where mouse gets put in')
[xstart,ystart]=ginput(1);
title('Select where mouse gets picked up')
[xend,yend]=ginput(1);
nearStart = sqrt((xAVI-xstart).^2+(yAVIflip-ystart).^2)<30;
nearEnd = sqrt((xAVI-xend).^2+(yAVIflip-yend).^2)<30;
figure(DotPlot);
title(' ')
hold on
plot(xAVI(nearStart),yAVIflip(nearStart),'.y')
plot(xAVI(nearEnd),yAVIflip(nearEnd),'.m')

nearEndInd=find(nearEnd);
nearStartInd=find(nearStart);
maybeLapStart=nan(length(cageEpochs),1);
maybeLapEnd=nan(length(cageEpochs),1);
for epoch=1:length(cageEpochs)
    try %if it doesn't work, leave index a nan, keep indexes aligned to other code
        maybeLapStart(epoch) = nearStartInd(find(nearStartInd>cageEpochs(epoch,2),1,'first'));
    end
    try
        maybeLapEnd(epoch) = nearEndInd(find(nearEndInd<cageEpochs(epoch,1),1,'last')); 
    catch %if we get a start, guess an end
        if ~isnan(maybeLapStart(epoch)
            maybeLapEnd(epoch) = cageEpochs(epoch,1) - 100;
        end    
    end  
end

figure(DotPlot);
hold on
plot(xAVI(maybeLapStart(~isnan(maybeLapStart))),yAVIflip(maybeLapStart(~isnan(maybeLapStart))),'.r')
plot(xAVI(maybeLapEnd(~isnan(maybeLapEnd))),yAVIflip(maybeLapEnd(~isnan(maybeLapEnd))),'.r')

figure(Positions);
subplot(2,1,1);
hold on
plot(pointInd(maybeLapStart(~isnan(maybeLapStart))),xAVI(maybeLapStart(~isnan(maybeLapStart))),'*m')
plot(pointInd(maybeLapEnd(~isnan(maybeLapEnd))),xAVI(maybeLapEnd(~isnan(maybeLapEnd))),'xr')
subplot(2,1,2);
hold on
plot(pointInd(maybeLapStart(~isnan(maybeLapStart))),yAVIflip(maybeLapStart(~isnan(maybeLapStart))),'*m')
plot(pointInd(maybeLapEnd(~isnan(maybeLapEnd))),yAVIflip(maybeLapEnd(~isnan(maybeLapEnd))),'xr')

%Enter delay - auto with yAVIflip histogram?
%Lift barrier - get halfway between start and end, last one in this lap
%Lap dir - get timepoint halfway between start and enterdelay, y coordinate
%Forced vs free - is it before or after lift barrier? if that works...
%How to handle experimenter fuckups???

%Output struct to save/use in parseGUI