% should do this after PreProcessMousePosition auto, before
% AlignImagingToTracking
load('Pos.mat')
xAVI = Xpix*.6246;
yAVI = Ypix*.6246;
try
    h1 = implay('Raw.AVI');
    obj = VideoReader('Raw.AVI');
catch
    avi_filepath = ls('*.avi');
    h1 = implay(avi_filepath);
    disp(['Using ' avi_filepath ])
    obj = VideoReader(avi_filepath);
end
v0 = readFrame(obj);
MorePoints = 'y';
%length(time);

%Draw a mask for the maze.
figure;
imagesc(flipud(v0)); 

PosSR = 30; % native sampling rate in Hz of position data (used only in smoothing)
aviSR = 30.0003; % the framerate that the .avi thinks it's at
cluster_thresh = 40;

obj.currentTime = sFrame/aviSR; % sFrame is the correct frame #, but .avi reads are done according to time
v = readFrame(obj);




pointInd = 1:length(x);
Positions = figure;
Positions.Name = 'Positions';
subplot(2,1,1);
plot(pointInd,x)
subplot(2,1,2);
plot(pointInd,y)

%Define cage area
DotPlot=figure;
DotPlot.Name = 'Dot Plot';
plot(x,y,'.')
disp('Press enter to stop poly')
[polx,poly] = ginput;
hold on
plot([polx; polx(1)],[poly; poly(1)])
%Ask if it's good
figure(DotPlot);
plot(x(inCage),y(inCage),'.g')

%when is the mouse in the cage
figure(Positions);
subplot(2,1,1);
hold on
plot(pointInd(inCage),x(inCage),'.g','MarkerSize',1)
subplot(2,1,2);
hold on
plot(pointInd(inCage),y(inCage),'.g','MarkerSize',1)

cageIns = find(diff(inCage)==1)+1; 
cageOuts = find(diff(inCage)==-1)+1;
if cageOuts(1) < cageIns(1)
    disp('Found an orphan cage out, assuming session starts w/ mouse in cage')
    cageIns(2:length(cageIns)+1)=cageIns;
    cageIns(1)=1;
end

%check there aren't any brief out/in RIGHT NOW STUCK if first one is too
%short
cageEpochs = [cageIns' cageOuts'];
cagedDurs = cageEpochs(:,2)-cageEpochs(:,1);
cagedTooShort = cagedDurs < 30;
cageIns(cagedTooShort) = [];
cageOuts(logical([cagedTooShort(2:end); 0])) = [];
disp(['Trimmed out ' num2str(sum(cagedTooShort)) ' quick exit/entries'])
cageEpochs(2:end,1 cageOuts'];

inCageCheck=pointInd;
inCageCheck(:)=0;
for aa=1:length(cageEpochs)
    inCageCheck(cageEpochs(aa,1):cageEpochs(aa,2))=1;
end



figure(Positions);
subplot(2,1,1);
plot(pointInd(cageEpochs(:,1)),x(cageEpochs(:,1)),'og')
plot(pointInd(cageEpochs(:,2)),x(cageEpochs(:,2)),'ok')
subplot(2,1,2);
plot(pointInd(cageEpochs(:,1)),y(cageEpochs(:,1)),'og')
plot(pointInd(cageEpochs(:,2)),y(cageEpochs(:,2)),'ok')

%Get mouse place and pickup spots
title('Select where mouse gets placed')
[xstart,ystart]=ginput(1)
title('Select where mouse gets picked up')
[xend,yend]=ginput(1)

nearStart = sqrt((x-xstart).^2+(y-ystart).^2)<5;
nearEnd = sqrt((x-xend).^2+(y-yend).^2)<5;
figure(DotPlot);
title(' ')
hold on
plot(x(nearStart),y(nearStart),'.y')
plot(x(nearEnd),y(nearEnd),'.m')

nearEndInd=find(nearEnd);
nearStartInd=find(nearStart);
maybeLapStart=nan(length(cageEpochs),1);
maybeLapEnd=nan(length(cageEpochs),1);
for epoch=1:length(cageEpochs)
    try
        maybeLapStart(epoch)=nearStartInd(find(nearStartInd<cageEpochs(epoch,1),1,'last'));
    end
    try
        maybeLapEnd(epoch)=nearEndInd(find(nearEndInd>cageEpochs(epoch,2),1,'first'));
    end    
end
figure(DotPlot);
hold on
plot(x(maybeLapStart(~isnan(maybeLapStart))),y(maybeLapStart(~isnan(maybeLapStart))),'.r')
plot(x(maybeLapEnd(~isnan(maybeLapEnd))),y(maybeLapEnd(~isnan(maybeLapEnd))),'.r')

