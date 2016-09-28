function DNMPparseGUI( ~,~ )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
global miscVar
global Controller
global videoFig
global video

miscVar.panelHeight = 480;
videoFig.videoPanel = figure('Position',[100,100,800,miscVar.panelHeight],'MenuBar','none');
plotted = subplot(1,2,1,'Position',[0.05,0.1,0.6,0.8]);
title('Frame 1/lots')

miscVar.upperLimit = miscVar.panelHeight - 70;
miscVar.buttonStepDown = 40;
miscVar.buttonLeftEdge = 550;

videoFig.LapStartButton = uicontrol('Style','pushbutton','String','LAP START',...
                           'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit,230,30],...
                           'Callback',{@fcnLapStartButton});
                       
videoFig.EnterDelayButton = uicontrol('Style','pushbutton','String','ENTER DELAY',...
                             'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit - miscVar.buttonStepDown*1,230,30],...
                             'Callback',{@fcnEnterDelayButton});
                         
videoFig.LiftBarrierButton = uicontrol('Style','pushbutton','String','LIFT BARRIER',...
                             'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit - miscVar.buttonStepDown*2,230,30],...
                             'Callback',{@fcnLiftBarrierButton});
                         
videoFig.LeaveMazeButton = uicontrol('Style','pushbutton','String','LEAVE MAZE',...
                             'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit - miscVar.buttonStepDown*3,230,30],...
                             'Callback',{@fcnLeaveMazeButton});

videoFig.StartHomecageButton = uicontrol('Style','pushbutton','String','START HOMECAGE',...
                             'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit - miscVar.buttonStepDown*4,230,30],...
                             'Callback',{@fcnStartHomecageButton});

videoFig.LeaveHomecageButton = uicontrol('Style','pushbutton','String','LEAVE HOMECAGE',...
                             'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit - miscVar.buttonStepDown*5,230,30],...
                             'Callback',{@fcnLeaveHomecageButton});

videoFig.ForcedTrialDirButton = uicontrol('Style','pushbutton','String','FORCED TRIAL DIR',...
                                'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit - miscVar.buttonStepDown*6,130,30],...
                                'Callback',{@fcnForcedDirButton});

videoFig.PopForcedDir = uicontrol('Style','popup',... 
                             'Position',[miscVar.buttonLeftEdge+130+10,miscVar.upperLimit - miscVar.buttonStepDown*6-7,95,30],...
                             'string',{'          LEFT   ';'         RIGHT   '},...
                             'Value', 1);

videoFig.FreeTrialDirButton = uicontrol('Style','pushbutton','String','FORCED TRIAL DIR',...
                                'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit - miscVar.buttonStepDown*7,130,30],...
                                'Callback',{@fcnFreeDirButton});

videoFig.PopFreeDir = uicontrol('Style','popup',... 
                             'Position',[miscVar.buttonLeftEdge+130+10,miscVar.upperLimit - miscVar.buttonStepDown*7-7,95,30],...
                             'string',{'          LEFT   ';'         RIGHT   '},...
                             'Value', 1); 
                         
videoFig.JumpFrameButton = uicontrol('Style','pushbutton','String','JUMP TO FRAME',...
                             'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit - miscVar.buttonStepDown*9,230,30],...
                             'Callback',{@fcnJumpFrameButton});
                         
videoFig.fakePlay = uicontrol('Style','pushbutton','String','PLAY',...
                        'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit - miscVar.buttonStepDown*10,130,30],...
                        'BackgroundColor',[0.92 0.92 0.92],'Callback',{@fcnHFGNGv2_CycleOnOff});

videoFig.PopDurPunish = uicontrol('Style','popup',... 
                             'Position',[miscVar.buttonLeftEdge+130+10,miscVar.upperLimit - miscVar.buttonStepDown*10-7,95,30],...
                             'string',{'          1x   ';'         2x   ';'         4x   ';'        10x   '},...
                             'Value', 1,'Callback',{@fcnSetFakePlaySpeed}); 
                    
% green = [0.5 1 0.5], red = [1 0.5 0.5]
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
miscVar.totalFrames = 100000;
title(['Frame ' num2str(miscVar.frameNum) '/' num2str(miscVar.totalFrames)])

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
                
%}
%{
LiftBarrierButton

PlayVid button (spacebar hotkey), play rate drop down
%}
end

function task(src, e)
         disp('button press');
end
function fcnLapStartButton(~,~)
disp('Lap Start')
end
function fcnEnterDelayButton(~,~)
disp('Enter Delay')
end
function fcnLiftBarrierButton(~,~)
disp('Lift Barrier')
end
function fcnLeaveMazeButton(~,~)
disp('Leave Maze')
end
function fcnStartHomecageButton(~,~)
disp('Start Homecage')
end
function fcnLeaveHomecageButton(~,~)
disp('Leave Homecage')
end
function fcnForcedDirButton(~,~)
disp('Forced Direction')
end
function fcnFreeDirButton(~,~)
disp('Free Direction')
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
