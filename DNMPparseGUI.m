function DNMPparseGUI( ~,~ )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
global miscVar
global Controller
global videoFig
global video

%[filename, pathname] = uigetfile('*.avi', 'Select AVI file to scroll through: ');
%avi_filepath = fullfile(pathname,filename);

avi_filepath = fullfile('D:\Polaris_160831','0021.avi'); 

%h1 = implay(avi_filepath);
disp(['Using ' avi_filepath ])
video = VideoReader(avi_filepath);
miscVar.currentTime = 0;
miscVar.currentFrame = readFrame(video);
miscVar.currentTime = miscVar.currentTime+video.FrameRate^-1;
miscVar.frameNum = 1;
%close(h1);
videoFig = figure('Name',avi_filepath,...
                  'KeyPressFcn',@keyPress);
imagesc(miscVar.currentFrame);
title(['Frame ' num2str(miscVar.frameNum)])

%MyButton = uicontrol('Style', 'pushbutton','Callback',@task);
%      function task(src, e)
 %        disp('button press');
  %    end
%}  
%{
Controller = figure('Position',[50,180,295,480],...
                    'KeyPressFcn', @keyPress,...
                    'Name','Video Buttons',...
                    'MenuBar','none');
                
TrialNumButton = uicontrol('Style', 'pushbutton','Callback',@task);
%}
%{
StartMazeButton
EnterDelayButton %bonus sheet
LiftBarrierButton
LeaveMazeButton
StartHomecageButton
LeaveHomecageButton
ForcedTrialDirButton
FreeTrialDirButton
%}
end

function task(src, e)
         disp('button press');
end

function keyPress(src, e)
global miscVar
%global Controller
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
            videoFig = imagesc(miscVar.currentFrame);
            title(['Frame ' num2str(miscVar.frameNum)])
        end
    case 'a' %Step back 10
        if video.currentTime > 10/video.FrameRate
            miscVar.frameNum = miscVar.frameNum - 11;
            video.CurrentTime = miscVar.frameNum/video.FrameRate;
            miscVar.currentFrame = readFrame(video);
            miscVar.frameNum = miscVar.frameNum + 1;
            videoFig = imagesc(miscVar.currentFrame);
            title(['Frame ' num2str(miscVar.frameNum)])
        end
    case 's'   %Step back
        %can't do frame 0/1
        if video.currentTime > 1/video.FrameRate
            miscVar.frameNum = miscVar.frameNum - 2;
            video.CurrentTime = miscVar.frameNum/video.FrameRate;
            miscVar.currentFrame = readFrame(video);
            miscVar.frameNum = miscVar.frameNum + 1;
            videoFig = imagesc(miscVar.currentFrame);
            title(['Frame ' num2str(miscVar.frameNum)])
        end
    case 'd' %Step forward
        
        miscVar.currentFrame = readFrame(video);
        miscVar.frameNum = miscVar.frameNum+1;
        videoFig = imagesc(miscVar.currentFrame);
        title(['Frame ' num2str(miscVar.frameNum)])
    case 'f' %Step forward 10  
        miscVar.frameNum = miscVar.frameNum + 9;
        video.CurrentTime = miscVar.frameNum/video.FrameRate;
        miscVar.currentFrame = readFrame(video);
        miscVar.frameNum = miscVar.frameNum + 1;
        videoFig = imagesc(miscVar.currentFrame);
        title(['Frame ' num2str(miscVar.frameNum)])
    case 'r' %Step forward 100
        miscVar.frameNum = miscVar.frameNum + 99;
        video.CurrentTime = miscVar.frameNum/video.FrameRate;
        miscVar.currentFrame = readFrame(video);
        miscVar.frameNum = miscVar.frameNum + 1;
        videoFig = imagesc(miscVar.currentFrame);
        title(['Frame ' num2str(miscVar.frameNum)])
    case 'space'    
        
end
         
end
