%make demo movie of calcium imaging

hdFfileGet = 'D:\Nix\Nix180503\motCorrMovie-Objects\Obj_2 - motCorrMovie.h5';
hdFfileGet = 'D:\Nix\Nix180503\BPDFF.h5';
workingDir = 'C:\Users\Sam\Desktop\ImagingDemo';
framesWorking = 'C:\Users\Sam\Desktop\ImagingDemo\Frames';
fps = 20;
frameStart = 301;
playbackSpeed = 1;
timeRaw = 10; %seconds of imaging
timeTransientOverlay = 10; %seconds of imaging
transientFile = 'D:\Nix\Nix180503\FinalOutput.mat';
activityPlayback = true;


getFrames = (timeRaw+timeTransientOverlay)*fps*playbackSpeed;
%Load the h5
info = h5info(hdFfileGet);
counts = [info.Datasets.Dataspace.Size(1), info.Datasets.Dataspace.Size(2), getFrames, 1];
disp('Loading h5')
hFile = h5read(hdFfileGet,['/' info.Datasets.Name],[1 1 frameStart 1],counts);
disp('Done loading h5')

colorLims = [min(min(min(hFile(:,:,:)))) max(max(max(hFile(:,:,:))))];

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

videoname = 'C:\Users\Sam\Desktop\ImagingDemo\imaging.avi';
v = VideoWriter(videoname);
open(v);

gg = figure; hh = axis;
if activityPlayback == true
    ii = figure; hh = axis;
    numCellsPlot = 8;
    [~,cellsMostActive] = sort(sum(transientActivity.PSAbool(:,realFrames(1):realFrames(end)),2),'descend');
    cellsActivePlot = cellsMostActive(1:numCellsPlot);
    framesLookBack = fps*2;
    framesLookAhead = fps*5;
    cellActivity = transientActivity.NeuronTraces.RawTrace(cellsActivePlot,realFrames(1)-framesLookBack:realFrames(end)+framesLookAhead);
    for cellI = 1:numCellsPlot
        minHere = min(cellActivity(cellI,:));
        maxHere = max(cellActivity(cellI,:));
        rangeHere = maxHere - minHere;
        cellActivity(cellI,:) = (cellActivity(cellI,:) - minHere)/rangeHere;
    end
end

for frameI = 1:length(framesPlot)
    fI = framesPlot(frameI);
    imagesc(gg.Children,hFile(:,:,fI));
    colormap gray
    %clims = colorLims;
    
    
    if framesOverlay(frameI)==1
        hold(gg.Children,'on')
        cellsActiveNow = find(transientActivity.PSAbool(:,realFrames(frameI)));
        for cellI = 1:length(cellsActiveNow)
            plot(gg.Children,transientActivity.Outlines{cellsActiveNow(cellI)}{1}(:,2),...
                 transientActivity.Outlines{cellsActiveNow(cellI)}{1}(:,1),...
                 'Color',cellColors{cellsActiveNow(cellI)},'LineWidth',1)
        end
        hold(gg.Children,'off')
    end
    
    if activityPlayback == true
        imageFrame = getFrame(gg.Children);
        
        hold(ii.Children,'on')
        for cellI = 1:length(numCellsPlot)
            framesPlot = 1:(framesLookBack+framesLookAhead)+(frameI-1);
            plot(cellActivity(cellI,framesPlot)+cellI-1,'Color',cellColors{cellsActiveNow(cellI)},'LineWidth',1)
        end
        hold(ii.Children,'off')
        
        activityFrame = getFrame(ii.Children);
        
        frame.cdata = [imageFrame.cdata, activityFrame.cdata];
        frame.colormap = [];
    else
    %Write the video file
    frame = getframe(gg.Children);
    end
    writeVideo(v,frame);
end
    
close(v);


%Calcium activity playback
%Plot the fluorescence traces for several cells, maybe those most active in
FinalOutput.NeuronTraces
%framestart through timeRaw+timeOverlay*playbackSpeed
    %normalize to fit the window
%grab frame numbers current frame - some amount THROUGH current frame plus more than that
%plot a black line to show now

%putting this in the same video frame as the raw video might be rough


