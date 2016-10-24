function DNMPparseGUI( ~,~ )
% Tool to facilitate parsing AVI for DNMP task into event time stamps (frame numbers),
% export those numbers in an excel sheet for using with Nat's DNMP
% functions. Select lap number, toggle between frames, click button to set
% that frame number as that type of event. Have to click away from button
% on figure for going between frames to work. If lap number button is red, click it to 
% start logging on that lap number

%%
global miscVar
global ParsedFrames
global videoFig
global video

miscVar.panelHeight = 480;
videoFig.videoPanel = figure('Position',[100,100,900,miscVar.panelHeight],'MenuBar','none','KeyPressFcn',@keyPress);
videoFig.plotted = subplot(1,2,1,'Position',[0.05,0.1,0.55,0.8]);
title('Frame 1/lots')

miscVar.upperLimit = miscVar.panelHeight - 120;
miscVar.buttonStepDown = 40;
miscVar.buttonLeftEdge = 560;
miscVar.buttonSecondCol = 705;
miscVar.buttonWidth = 130;
miscVar.Gray=[0.94,0.94,0.94];
miscVar.Red=[0.75,0,0];
miscVar.VideoLoadedFlag=0;


videoFig.LapNumberButton = uicontrol('Style','pushbutton','String','LAP NUMBER',...
                           'Position',[miscVar.buttonLeftEdge+60,miscVar.upperLimit+50,miscVar.buttonWidth,30],...
                           'Callback',{@fcnLapNumberButton},'BackgroundColor',miscVar.Gray);
miscVar.LapNumber=1;                       

videoFig.LapNumberBox = uicontrol('Style','edit','string','1',...
                           'Position',[miscVar.buttonLeftEdge+60+miscVar.buttonWidth+15,miscVar.upperLimit+50,...
                           50,30]);
                       
videoFig.LapNumberPlus = uicontrol('Style','pushbutton','String','+',...
                           'Position',[miscVar.buttonLeftEdge+60+miscVar.buttonWidth+15+52,miscVar.upperLimit+65,...
                           20,15],'Callback',{@fcnLapNumberPlus});
                       
videoFig.LapNumberMinus = uicontrol('Style','pushbutton','String','-',...
                           'Position',[miscVar.buttonLeftEdge+60+miscVar.buttonWidth+15+52,miscVar.upperLimit+50,...
                           20,15],'Callback',{@fcnLapNumberMinus});
                       

%%
videoFig.LapStartButton = uicontrol('Style','pushbutton','String','LAP START',...
                           'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit,miscVar.buttonWidth,30],...
                           'Callback',{@fcnLapStartButton});
                       
videoFig.EnterDelayButton = uicontrol('Style','pushbutton','String','ENTER DELAY',...
                             'Position',[miscVar.buttonSecondCol,miscVar.upperLimit, miscVar.buttonWidth,30],...
                             'Callback',{@fcnEnterDelayButton});
                         
videoFig.LiftBarrierButton = uicontrol('Style','pushbutton','String','LIFT BARRIER',...
                             'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit - miscVar.buttonStepDown*1,...
                             miscVar.buttonWidth,30], 'Callback',{@fcnLiftBarrierButton});
                         
videoFig.LeaveMazeButton = uicontrol('Style','pushbutton','String','LEAVE MAZE',...
                             'Position',[miscVar.buttonSecondCol,miscVar.upperLimit - miscVar.buttonStepDown*1,...
                             miscVar.buttonWidth,30], 'Callback',{@fcnLeaveMazeButton});

videoFig.StartHomecageButton = uicontrol('Style','pushbutton','String','START HOMECAGE',...
                             'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit - miscVar.buttonStepDown*2,...
                             miscVar.buttonWidth,30], 'Callback',{@fcnStartHomecageButton});

videoFig.LeaveHomecageButton = uicontrol('Style','pushbutton','String','LEAVE HOMECAGE',...
                             'Position',[miscVar.buttonSecondCol,miscVar.upperLimit - miscVar.buttonStepDown*2,...
                             miscVar.buttonWidth,30], 'Callback',{@fcnLeaveHomecageButton});

videoFig.ForcedTrialDirButton = uicontrol('Style','pushbutton','String','FORCED TRIAL DIR',...
                                'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit - miscVar.buttonStepDown*3,...
                                130,30], 'Callback',{@fcnForcedDirButton});

videoFig.PopForcedDir = uicontrol('Style','popup',... 
                             'Position',[miscVar.buttonLeftEdge+130+10,miscVar.upperLimit - miscVar.buttonStepDown*3-7,95,30],...
                             'string',{'          LEFT   ';'         RIGHT   '},...
                             'Value', 1);

videoFig.FreeTrialDirButton = uicontrol('Style','pushbutton','String','FREE TRIAL DIR',...
                             'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit - miscVar.buttonStepDown*4,130,30],...
                             'Callback',{@fcnFreeDirButton});

videoFig.PopFreeDir = uicontrol('Style','popup',... 
                             'Position',[miscVar.buttonLeftEdge+130+10,miscVar.upperLimit - miscVar.buttonStepDown*4-7,95,30],...
                             'string',{'          LEFT   ';'         RIGHT   '},...
                             'Value', 1); 
%%
                         
videoFig.LoadVideoButton = uicontrol('Style','pushbutton','String','LOAD VIDEO',...
                             'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit - miscVar.buttonStepDown*6,...
                             miscVar.buttonWidth,30],'Callback',{@fcnLoadVideo}); 
                         
videoFig.SaveSheetExcel = uicontrol('Style','pushbutton','String','SAVE SHEET',...                         
                             'Position',[miscVar.buttonSecondCol,miscVar.upperLimit - miscVar.buttonStepDown*6,...
                             miscVar.buttonWidth,30],'Callback',{@fcnSaveSheet});     
                         
videoFig.JumpFrameButton = uicontrol('Style','pushbutton','String','JUMP TO FRAME',...
                             'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit - miscVar.buttonStepDown*7,...
                             miscVar.buttonWidth,30], 'Callback',{@fcnJumpFrameButton});
                         
videoFig.fakePlay = uicontrol('Style','pushbutton','String','PLAY',...
                        'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit - miscVar.buttonStepDown*8,...
                        miscVar.buttonWidth,30], 'BackgroundColor',miscVar.Gray,'Callback',{@fcnFakePlayer});

videoFig.PopDurPunish = uicontrol('Style','popup',... 
                             'Position',[miscVar.buttonLeftEdge+130+10,miscVar.upperLimit - miscVar.buttonStepDown*8-7,95,30],...
                             'string',{'          1x   ';'         2x   ';'         4x   ';'        10x   '},...
                             'Value', 1,'Callback',{@fcnSetFakePlaySpeed}); 
                         
%%
%ParsedFrames.StartMaze, LiftBarrier, LeaveMaze, StartHomecage, LeaveHomecage, ForcedTrialLR, FreeTrialLR, EnterDelay



% green = [0.5 1 0.5], red = [1 0.5 0.5]
%avi_filepath = fullfile(pathname,filename);
%{

%}
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
%%
function fcnLapNumberButton(~,~)
global miscVar
global videoFig

disp('Lap number')
try 
    miscVar.hold=miscVar.LapNumber;
    miscVar.LapNumber=str2double(videoFig.LapNumberBox.String);
    if miscVar.LapNumber<1 || mod(str2double(videoFig.LapNumberBox.String),1)~=0
        msgbox('Lap number must be integer > zero.', 'Error','error');
        miscVar.LapNumber=miscVar.hold;
        videoFig.LapNumberBox.String=miscVar.LapNumber;
        videoFig.LapNumberBox.BackgroundColor=miscVar.Red;
        disp(num2str(miscVar.LapNumber))
    else    
        videoFig.LapNumberButton.BackgroundColor=miscVar.Gray;
        miscVar.LapNumber=str2double(videoFig.LapNumberBox.String);
        disp(['Lap number is ' num2str(miscVar.LapNumber)])
    end    
catch
    msgbox('Lap number must be an integer.', 'Error','error');
    videoFig.LapNumberBox.BackgroundColor=miscVar.Red;
end
videoFig;

end
function fcnLapNumberPlus(~,~)
global videoFig
global miscVar
disp('Lap number plus')
switch mod(str2double(videoFig.LapNumberBox.String),1)~=0
    case 0
    videoFig.LapNumberBox.String=num2str(str2double(videoFig.LapNumberBox.String)+1);
    videoFig.LapNumberButton.BackgroundColor=miscVar.Red;
    case 1
    msgbox('Lap number must be an integer.', 'Error','error');
end    
end
function fcnLapNumberMinus(~,~)
global videoFig
global miscVar
disp('Lap number minus')
if str2double(videoFig.LapNumberBox.String)-1>0
switch mod(str2double(videoFig.LapNumberBox.String),1)~=0
    case 0
    videoFig.LapNumberBox.String=num2str(str2double(videoFig.LapNumberBox.String)-1);
    videoFig.LapNumberButton.BackgroundColor=miscVar.Red;
    case 1
    msgbox('Lap number must be an integer.', 'Error','error');
end     
end
end
function fcnLapStartButton(~,~)
disp('Lap Start')
global miscVar
global ParsedFrames
if miscVar.VideoLoadedFlag==1
    ParsedFrames.LapStart(miscVar.LapNumber)=miscVar.frameNum;
    disp(num2str(ParsedFrames.LapStart(miscVar.LapNumber)))
end
end
function fcnEnterDelayButton(~,~)
disp('Enter Delay')
global miscVar
global ParsedFrames
if miscVar.VideoLoadedFlag==1
    ParsedFrames.EnterDelay(miscVar.LapNumber)=miscVar.frameNum;
    disp(num2str(ParsedFrames.EnterDelay(miscVar.LapNumber)))
end
end
function fcnLiftBarrierButton(~,~)
disp('Lift Barrier')
global miscVar
global ParsedFrames
if miscVar.VideoLoadedFlag==1
    ParsedFrames.LiftBarrier(miscVar.LapNumber)=miscVar.frameNum;
    disp(num2str(ParsedFrames.LiftBarrier(miscVar.LapNumber)))
end
end
function fcnLeaveMazeButton(~,~)
disp('Leave Maze')
global miscVar
global ParsedFrames
if miscVar.VideoLoadedFlag==1
    ParsedFrames.LeaveMaze(miscVar.LapNumber)=miscVar.frameNum;
    disp(num2str(ParsedFrames.LeaveMaze(miscVar.LapNumber)))
end
end
function fcnStartHomecageButton(~,~)
disp('Start Homecage')
global miscVar
global ParsedFrames
if miscVar.VideoLoadedFlag==1
    ParsedFrames.StartHomecage(miscVar.LapNumber)=miscVar.frameNum;
    disp(num2str(ParsedFrames.StartHomecage(miscVar.LapNumber)))
end
end
function fcnLeaveHomecageButton(~,~)
disp('Leave Homecage')
global miscVar
global ParsedFrames
if miscVar.VideoLoadedFlag==1
    ParsedFrames.LeaveHomecage(miscVar.LapNumber)=miscVar.frameNum;
    disp(num2str(ParsedFrames.LeaveHomecage(miscVar.LapNumber)))
end
end
function fcnForcedDirButton(~,~)
disp('Forced Direction')
global miscVar
global ParsedFrames
global videoFig
if miscVar.VideoLoadedFlag==1
    switch videoFig.PopForcedDir.Value
        case 1
            ParsedFrames.ForcedDir{miscVar.LapNumber,1}='L';
        case 2    
            ParsedFrames.ForcedDir{miscVar.LapNumber,1}='R';
    end        
    disp(ParsedFrames.ForcedDir{miscVar.LapNumber,1})
end
end
function fcnFreeDirButton(~,~)
disp('Free Direction')
global miscVar
global ParsedFrames
global videoFig
if miscVar.VideoLoadedFlag==1
    switch videoFig.PopFreeDir.Value
        case 1
            ParsedFrames.FreeDir{miscVar.LapNumber,1}='L';
        case 2    
            ParsedFrames.FreeDir{miscVar.LapNumber,1}='R';
    end        
    disp(ParsedFrames.FreeDir{miscVar.LapNumber,1})
end
end
function fcnJumpFrameButton(~,~)
disp('Jump frame')
global videoFig
global miscVar
global video

    try
        jumpFrame = inputdlg('Jump to what frame?');
        switch mod(str2double(jumpFrame),1)==0
            case 0
                msgbox('Frame number must be an integer','Error','error')
            case 1  
                if jumpFrame>0 && jumpFrame <=miscVar.totalFrames
                    miscVar.frameNum = jumpFrame-1;
                    video.CurrentTime = miscVar.frameNum/video.FrameRate;
                    miscVar.currentFrame = readFrame(video);
                    miscVar.frameNum = miscVar.frameNum + 1;
                    videoFig.plotted = imagesc(miscVar.currentFrame);
                    title(['frame ' num2str(miscVar.frameNum) '/' num2str(miscVar.totalFrames)])
                else   
                    msgbox('Fram number must in range','Error','error')
                end
        end
    catch
        msgbox('Why would you even?')
    end 
end
function fcnLoadVideo(~,~)
disp('Load video')
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
videoFig;
end
end
function fcnSaveSheet(~,~)
disp('Save sheet')
end
function fcnFakePlayer(~,~)
disp('fake player')
end
%%
function keyPress(src, e)

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
