function DNMPparseAdd      
%Function for adding an event in the parser based on input array of times
%User dictates which type they're adding, then inputs an array of times 
%this function uses as the 'anchor', jumps to those points (+/- some amout
%of time, saves selected frame number as the new type.
%E.G., need to add timestamp for the choice point? Input array of time
%leaving the start area, then adjust frame estimate for say 2s worth of
%frames, parser will jump through video to input timestamps (leave start area),
%forward/backward 60 frames, leave it to user to find the exact frame and 
%save it.

%This function is very rough right now

%Get video we're working on
fcnLoadVideo;

%Get which timestamp we're adding
addingStr = {'LapNumber', 'LapStart', 'LiftBarrier', 'LeaveMaze',...
       'StartHomecage', 'LeaveHomecage', 'ForcedDir',...
       'FreeDir', 'TrialType', 'TrialDir', 'ForcedEnterChoice',...
       'ForcedLeaveChoice', 'FreeEnterChoice', 'FreeLeaveChoice', 'Other...'};
   
[addingVal,~] = listdlg('PromptString','Which are we adding:',...
                'SelectionMode','single',...
                'ListString',addingStr);
            
addingType=addingStr{1,addingVal};

%Get array of anchor timestamps and adjustment
[FileName,PathName] = uigetfile(FilterSpec)

adjustInt = 0;
while adjustInt==0
    adjustment = inputdlg('How many frames forward or back?','Adjustment');
    adjustment=str2double(adjustment{1,1});
    switch rem(adjustment,1)
        case 1
            adjustInt=1;
        case 0
            adjustInt=0;
            disp('Whole number, please')
    end        
end
%Build the gui here
global miscVar
global ParsedFrames
global videoFig
global video

msgbox({'Notes on use:';' Q/R - step back/forward 100';...
        ' A/F - step back/forward 10'; ' S/D  - step back/forward 1';' ';...
        'Click off of button for keyboard!'})

miscVar.panelHeight = 480;
videoFig.videoPanel = figure('Position',[100,100,740,miscVar.panelHeight],...
    'MenuBar','none','KeyPressFcn',@keyPress);
videoFig.plotted = subplot(1,2,1,'Position',[0.05,0.1,0.7,0.8]);
title('Frame 1/lots')

miscVar.buttonLeftEdge=570;
miscVar.upperLimit=miscVar.panelHeight-120;
miscVar.buttonWidth=150;
miscVar.buttonHeight=30;


videoFig.AddButton = uicontrol('Style','pushbutton','String',addingType,...
                           'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit,...
                           miscVar.buttonWidth,miscVar.buttonHeight],...
                           'Callback',{@fcnAddButton});
                       
videoFig.NextButton = uicontrol('Style','pushbutton','String','NEXT EVENT',...
                           'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit-45,...
                           miscVar.buttonWidth,miscVar.buttonHeight],...
                           'Callback',{@fcnNextButton});   
                       
videoFig.PreviousButton = uicontrol('Style','pushbutton','String','PEVIOUS EVENT',...
                           'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit-90,...
                           miscVar.buttonWidth,miscVar.buttonHeight],...
                           'Callback',{@fcnPreviousButton}); 
                       
videoFig.SaveQuitButton = uicontrol('Style','pushbutton','String','SAVE & QUIT',...
                           'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit-150,...
                           miscVar.buttonWidth,miscVar.buttonHeight],...
                           'Callback',{@fcnSaveQuitButton}); 
                                             

%Loop through all anchors, going to next when current frame selected 
doneFinding=0;
anchorNum=1;
while doneFinding==0 
    %set current frame number, don't forget step back, etc. 
    frameSet(anchorArr(anchorNum)+adjustment);
    %set button to 'unclicked'
        %if this button pressed, add the current frame to the array
        %and advance our tracker
        anchorNum=anchorNum+1;
         %if it's above length(anchorArr) then...?
    %other button for doneFinding=1;
end    
%save it



%What are we doing to integrate it with DNMPsheet.xls??
%maybe parse trials needs to be generalized to find string names for
%columns, ask for and add bonus columns regardless of format; 
%dealing with this all as a struct might be better
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fcnAddButton
%set current frame as 
end

function fcnNextButton

end

function fcnPreviousButton

end

function fcnSaveQuitButton

end

function frameSet(jumpToFrame)
global miscVar
global ParsedFrames
global videoFig
global video

miscVar.frameNum = jumpToFrame - 1;
video.CurrentTime = miscVar.frameNum/video.FrameRate;
miscVar.currentFrame = readFrame(video);
miscVar.frameNum = miscVar.frameNum + 1;
videoFig.plotted = imagesc(miscVar.currentFrame);
title(['Frame ' num2str(miscVar.frameNum) ' / ' num2str(miscVar.totalFrames)])

end

function fcnLoadVideo(~,~)
global videoFig
global miscVar
global video

try
[miscVar.FileName,miscVar.PathName] = uigetfile('*.AVI','Select the AVI file');
video = VideoReader(fullfile(miscVar.PathName,miscVar.FileName));
miscVar.currentTime = 0;
miscVar.currentFrame = readFrame(video);
miscVar.currentTime = miscVar.currentTime+video.FrameRate^-1;
miscVar.frameNum = 1;
miscVar.totalFrames = video.Duration/video.FrameRate^-1;
videoFig.plotted;
imagesc(miscVar.currentFrame);
title(['Frame ' num2str(miscVar.frameNum) '/' num2str(miscVar.totalFrames)])
miscVar.VideoLoadedFlag=1;
videoFig.Name=miscVar.FileName;
catch
    disp('Something went wrong')
end
end

function keyPress(~, e)%src

global miscVar
global videoFig
global video

%pause(0.001)
%e.Key

switch e.Key
    case 'q' %Step back 100
        if video.currentTime > 100/video.FrameRate
            miscVar.frameNum = miscVar.frameNum - 101;
            video.CurrentTime = miscVar.frameNum/video.FrameRate;
            miscVar.currentFrame = readFrame(video);
            miscVar.frameNum = miscVar.frameNum + 1;
            videoFig.plotted = imagesc(miscVar.currentFrame);
            title(['Frame ' num2str(miscVar.frameNum) ' / ' num2str(miscVar.totalFrames)])
        end
    case 'a' %Step back 10
        if video.currentTime > 10/video.FrameRate
            miscVar.frameNum = miscVar.frameNum - 11;
            video.CurrentTime = miscVar.frameNum/video.FrameRate;
            miscVar.currentFrame = readFrame(video);
            miscVar.frameNum = miscVar.frameNum + 1;
            videoFig.plotted = imagesc(miscVar.currentFrame);
            title(['Frame ' num2str(miscVar.frameNum) ' / ' num2str(miscVar.totalFrames)])
        end
    case 's'   %Step back
        %can't do frame 0/1
        if video.currentTime > 1/video.FrameRate
            miscVar.frameNum = miscVar.frameNum - 2;
            video.CurrentTime = miscVar.frameNum/video.FrameRate;
            miscVar.currentFrame = readFrame(video);
            miscVar.frameNum = miscVar.frameNum + 1;
            videoFig.plotted = imagesc(miscVar.currentFrame);
            title(['Frame ' num2str(miscVar.frameNum) ' / ' num2str(miscVar.totalFrames)])
        end
    case 'd' %Step forward 1
        if video.currentTime+1 <= miscVar.totalFrames
            miscVar.currentFrame = readFrame(video);
            miscVar.frameNum = miscVar.frameNum+1;
            videoFig.plotted = imagesc(miscVar.currentFrame);
            title(['Frame ' num2str(miscVar.frameNum) ' / ' num2str(miscVar.totalFrames)])
        end
    case 'f' %Step forward 10  
        if video.currentTime+10 <= miscVar.totalFrames
            miscVar.frameNum = miscVar.frameNum + 9;
            video.CurrentTime = miscVar.frameNum/video.FrameRate;
            miscVar.currentFrame = readFrame(video);
            miscVar.frameNum = miscVar.frameNum + 1;
            videoFig.plotted = imagesc(miscVar.currentFrame);
            title(['Frame ' num2str(miscVar.frameNum) ' / ' num2str(miscVar.totalFrames)])
        end
    case 'r' %Step forward 100
        if video.currentTime+1 <= miscVar.totalFrames
            miscVar.frameNum = miscVar.frameNum + 99;
            video.CurrentTime = miscVar.frameNum/video.FrameRate;
            miscVar.currentFrame = readFrame(video);
            miscVar.frameNum = miscVar.frameNum + 1;
            videoFig.plotted = imagesc(miscVar.currentFrame);
            title(['Frame ' num2str(miscVar.frameNum) ' / ' num2str(miscVar.totalFrames)])
        end    
    case 'space'    
        disp('Fake player start/stop')
end
         
end