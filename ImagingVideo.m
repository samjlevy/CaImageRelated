%make demo movie of calcium imaging

hdFfileGet = 'D:\Nix\Nix180503\motCorrMovie-Objects\Obj_2 - motCorrMovie.h5';
hdFfileGetFiltered = 'D:\Nix\Nix180503\BPDFF.h5';
workingDir = 'C:\Users\Sam\Desktop\ImagingDemo';
framesWorking = 'C:\Users\Sam\Desktop\ImagingDemo\Frames';
fps = 20;
frameStart = 301;
playbackSpeed = 1;
timeRaw = 25; %seconds of imaging
timeFiltered = 25;
timeTransientOverlay = 25; %seconds of imaging
timeTransientOverlayFiltered = 25; %seconds of imaging
transientFile = 'D:\Nix\Nix180503\FinalOutput.mat';
activityPlayback = false;

hdFfileGet = 'I:\Calisto\Calisto_161102\motCorrTemp_fixed-Objects\Obj_1 - motCorrTemp_fixed.h5';
hdFfileGetFiltered = 'I:\Calisto\Calisto_161102\BPDFF.h5';
transientFile = 'I:\Calisto\Calisto_161102\FinalOutput.mat';

hdFfileGet = 'D:\DoublePlus\Marble07\Marble07_180625\motCorrMovie-Objects\Obj_2 - motCorrMovie.h5';
hdFfileGetFiltered = 'D:\DoublePlus\Marble07\Marble07_180625\BPDFF.h5';
transientFile = 'D:\DoublePlus\Marble07\Marble07_180625\FinalOutput.mat';
workingDir = 'C:\Users\Sam\Desktop\ImagingDemo\two';
framesWorking = 'C:\Users\Sam\Desktop\ImagingDemo\two\Frames';
fps = 25;
frameStart = 301;
playbackSpeed = 1;
timeRaw = 25; %seconds of imaging
timeFiltered = 25;
timeTransientOverlay = 25; %seconds of imaging
timeTransientOverlayFiltered = 25; %seconds of imaging
activityPlayback = false;


getFrames = (timeRaw+timeFiltered)*fps*playbackSpeed;
%Load the h5
info = h5info(hdFfileGet);
infoFilt = h5info(hdFfileGetFiltered);
counts = [info.Datasets.Dataspace.Size(1), info.Datasets.Dataspace.Size(2), getFrames, 1];
countsFilt = [infoFilt.Datasets.Dataspace.Size(1), infoFilt.Datasets.Dataspace.Size(2), getFrames, 1];
disp('Loading h5')
hFile = h5read(hdFfileGet,['/' info.Datasets.Name],[1 1 frameStart 1],counts);
hFileFilt = h5read(hdFfileGetFiltered,['/' infoFilt.Datasets.Name],[1 1 frameStart 1],countsFilt);
disp('Done loading h5')

colorLims = [min(min(min(hFile(:,:,:)))) max(max(max(hFile(:,:,:))))];
colorLimsFilt = [min(min(min(hFileFilt(:,:,:)))) max(max(max(hFileFilt(:,:,:))))];

framesPlot = 1:playbackSpeed:getFrames;
realFrames = framesPlot+(frameStart-1);
framesOverlay = zeros(length(framesPlot),1);
if timeTransientOverlay > 0
    disp('Loading transient activity')
    transientActivity = load(transientFile,'PSAbool','NeuronImage','NeuronTraces');
    transientActivity.Outlines = cellfun(@bwboundaries,transientActivity.NeuronImage,'UniformOutput',false);
    disp('Done loading transient activity')
    
    numCells = size(transientActivity.PSAbool,1);
    possibleColors = {'b';'c';'g';'r';[0.9294    0.6902    0.1294];'m'};
    cellColors = repmat(possibleColors,ceil(numCells/length(possibleColors)),1);
    framesOverlay(timeRaw*fps+1:length(framesPlot)) = 1;
end

videoname = fullfile(workingDir,'imaging5.avi');
v = VideoWriter(videoname);
v.FrameRate = fps;
v.Quality = 100;
open(v);

gg = figure('Position', [312 337 560 420]); hh = axis; axis equal; axis off

if activityPlayback == true
    ii = figure('Position',[1031 379 560 420]); hh = axis;
    numCellsPlot = 8;
    activityHere = transientActivity.PSAbool(:,realFrames(1):realFrames(end));
    framesLookBack = fps*1;
    framesLookAhead = fps*3;
    rawTraceHere = transientActivity.NeuronTraces.RawTrace(:,realFrames(1)-framesLookBack:realFrames(end)+framesLookAhead);
    for cellI = 1:numCells
        minHere = min(rawTraceHere(cellI,:));
        maxHere = max(rawTraceHere(cellI,:));
        rangeHere = maxHere - minHere;
        rawTraceHere(cellI,:) = (rawTraceHere(cellI,:) - minHere)/rangeHere;
    end
    %activityCheck = sum(,2); %total frames transients
    activityCheck = std(rawTraceHere,0,2); %variability?
    [~,cellsMostActive] = sort(activityCheck,'descend');
    cellsActivePlot = cellsMostActive(1:numCellsPlot);
        
    cellActivity = rawTraceHere(cellsActivePlot,:);
    activityPlot = logical([framesOverlay(1)*ones(framesLookBack,1); framesOverlay; framesOverlay(end)*ones(framesLookAhead,1)]);
end

disp('Writing video...')
for frameI = 1:getFrames
    fI = framesPlot(frameI);
    if framesOverlay(frameI)==0
        imagesc(gg.Children,hFile(:,:,fI));
        colormap(gg.Children,'gray');
    elseif framesOverlay(frameI)==1
        imagesc(gg.Children,hFileFilt(:,:,fI));
        colormap(gg.Children,'gray');
        clims = colorLimsFilt;
    end
    
    cellsActiveNow = find(transientActivity.PSAbool(:,realFrames(frameI)));
    if framesOverlay(frameI)==1
        hold(gg.Children,'on')
        for cellI = 1:length(cellsActiveNow)
            plot(gg.Children,transientActivity.Outlines{cellsActiveNow(cellI)}{1}(:,2),...
                 transientActivity.Outlines{cellsActiveNow(cellI)}{1}(:,1),...
                 'Color',cellColors{cellsActiveNow(cellI)},'LineWidth',1)
        end
        hold(gg.Children,'off')
    end
    
    if activityPlayback == true 
        plot((framesLookBack+1)*[1 1],[0 numCellsPlot],'k')
        hold(ii.Children,'on')
        tracePlot = (1:(framesLookBack+framesLookAhead))+(frameI-1);
        xPts = 1:length(tracePlot);
        activityUseHere = activityPlot(tracePlot);
        tracePlotUse = tracePlot(activityUseHere);
        xPtsUse = xPts(activityUseHere);
        
        for cellI = 1:numCellsPlot
            plot(ii.Children,xPtsUse,cellActivity(cellI,tracePlotUse)+cellI-1,'Color',cellColors{cellsActivePlot(cellI)},'LineWidth',1)
            if framesOverlay(frameI)==1
                hold(gg.Children,'on')
                plot(gg.Children,mean(transientActivity.Outlines{cellsActivePlot(cellI)}{1}(:,2))-20,...
                 mean(transientActivity.Outlines{cellsActivePlot(cellI)}{1}(:,1)),...
                 '>','Color',cellColors{cellsActivePlot(cellI)},'MarkerFaceColor',cellColors{cellsActivePlot(cellI)},'MarkerSize',6)
                hold(gg.Children,'off')
            end
        end
        ii.Children.XLim = [0 framesLookBack+framesLookAhead];
        ii.Children.YLim = [-0.01 numCellsPlot+0.01];
        hold(ii.Children,'off')
        
        imageFrame = getframe(gg.Children);
        activityFrame = getframe(ii.Children);
        
        frame.cdata = [imageFrame.cdata, activityFrame.cdata];
        frame.colormap = [];
    else
    %Write the video file
    frame = getframe(gg.Children);
    end
    
    writeVideo(v,frame);
end
    
close(v);
close(gg);
disp('Done making video')


%% Same but for demo of mouse running in maze
vidFileUse = 'G:\SLIDE\Processed Data\Nix\Nix_180428\Nix042818001.AVI';
framesUse = 901:2541;
workingDir = 'C:\Users\Sam\Desktop\ImagingDemo\two';
framesWorking = 'C:\Users\Sam\Desktop\ImagingDemo\two\Frames';

video = VideoReader(vidFileUse);

videoname = fullfile(workingDir,'DNMPbehavior.avi');
v = VideoWriter(videoname);
v.FrameRate = video.FrameRate;
v.Quality = 100;
open(v);

gg = figure('Position', [312 337 560 420]); hh = axis; axis equal; axis off

frameNum = 1;
for frameI = 1:length(framesUse)
    video.CurrentTime = (framesUse(frameI)-1)/video.FrameRate;
    frame = readFrame(video);
    writeVideo(v,frame);
end

close(v);
%imagesc(gg.Children,hFile(:,:,fI));
%hold(gg.Children,'off')

