function PositionChecker( ~,~ )
% Tool to facilitate parsing AVI for DNMP task into event time stamps (frame numbers),
% export those numbers in an excel sheet for using with Nat's DNMP
% functions. Select lap number, toggle between frames, click button to set
% that frame number as that type of event. Have to click away from button
% on figure for going between frames to work. If lap number button is red, click it to 
% start logging on that lap number

%Probably best to generalize button layout, button callbacks (with input to
%the return function)
%               for buttonCol=1:length(miscVar.buttonsInUse)
%                   eval(['videoFig.',miscVar.buttonsInUse{buttonCol},'.BackgroundColor=miscVar.Red;'])
%               end
%       this may work to put in buttons generalizedly, though even more
%       probably need to do a preferred order for events, or at least put
%       lap directions in odd positions so their drop down menu is on the
%       same line
%       eval stuff to get button properties...
%       loading needs to get generalized too
%%
global miscVar
global ParsedFrames
global videoFig
global video

msgbox({'Notes on use:';' Q/R - step back/forward 100';...
        ' A/F - step back/forward 10'; ' S/D  - step back/forward 1';' ';...
        'Click off of button for keyboard!'})

miscVar.panelHeight = 480;
videoFig.videoPanel = figure('Position',[100,100,900,miscVar.panelHeight],'MenuBar','none','KeyPressFcn',@keyPress);
videoFig.plotted = subplot(1,2,1,'Position',[0.05,0.1,0.55,0.8]);
title('Frame 1/lots')

fcnLoadVideo;
fcnLoadPositions;

miscVar.upperLimit = miscVar.panelHeight - 100;
miscVar.buttonStepDown = 40;
miscVar.buttonLeftEdge = 560;
miscVar.buttonSecondCol = 705;
miscVar.buttonWidth = 130;
miscVar.Gray=[0.94,0.94,0.94];
miscVar.Red=[1,0.5,0.5];
miscVar.Green = [0.5 1 0.5];
miscVar.VideoLoadedFlag=0;
miscVar.LapsWorkedOn=[];


videoFig.LapNumberButton = uicontrol('Style','pushbutton','String','LAP NUMBER',...
                           'Position',[miscVar.buttonLeftEdge+60,miscVar.upperLimit+50,miscVar.buttonWidth,30],...
                           'Callback',{@fcnLapNumberButton},'BackgroundColor',miscVar.Red);
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
   
videoFig.RandomFrameButton

videoFig.NextButton = uicontrol('Style','pushbutton','String','NEXT EVENT',...
                           'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit-45,...
                           miscVar.buttonWidth,miscVar.buttonHeight],...
                           'Callback',{@fcnNextButton});   
                       
videoFig.PreviousButton = uicontrol('Style','pushbutton','String','PEVIOUS EVENT',...
                           'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit-90,...
                           miscVar.buttonWidth,miscVar.buttonHeight],...
                           'Callback',{@fcnPreviousButton}); 
%% Layout for DNMP
switch miscVar.sessionClass
    case 1
        miscVar.buttonsInUse={'LapStartButton'; 'ForcedChoiceEnter';...
                              'ForcedChoiceLeaveButton'; 'ForcedChoiceEnterButton';...
                              'ForcedTrialDirButton'; 'ForcedRewardButton';...
                              'EnterDelayButton'; 'LiftBarrierButton';...
                              'FreeChoiceEnterButton';...
                              'FreeChoiceLeaveButton'; 'FreeTrialDirButton';
                              'FreeRewardButton'; 'LeaveMazeButton';...
                               'StartHomecageButton';'LeaveHomecageButton'};
bs=0;                       
%bs=-1; bt=1;
%if mod(bt,2)==1; left=miscVar.buttonLeftEdge; bs=bs+1; elseif mod(bt,2)==0; left=miscVar.buttonSecondCol; end
videoFig.LapStartButton = uicontrol('Style','pushbutton','String','LAP START',...
                           'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit - miscVar.buttonStepDown*bs,miscVar.buttonWidth,30],...
                           'Callback',{@fcnLapStartButton});
%bt=bt+1; 
videoFig.ForcedChoiceEnterButton = uicontrol('Style','pushbutton','String','FORCED CHOICE ENTER',...
                             'Position',[miscVar.buttonSecondCol,miscVar.upperLimit - miscVar.buttonStepDown*bs,miscVar.buttonWidth,30],...
                             'Callback',{@fcnForcedChoiceEnterButton});   

bs=bs+1;                         
videoFig.ForcedChoiceLeaveButton = uicontrol('Style','pushbutton','String','FORCED CHOICE LEAVE',...
                             'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit - miscVar.buttonStepDown*bs,miscVar.buttonWidth,30],...
                             'Callback',{@fcnForcedChoiceLeaveButton});  
                         
videoFig.ForcedRewardButton = uicontrol('Style','pushbutton','String','FORCED REWARD',...
                             'Position',[miscVar.buttonSecondCol,miscVar.upperLimit - miscVar.buttonStepDown*bs,miscVar.buttonWidth,30],...
                             'Callback',{@fcnForcedRewardButton}); 
                         
bs=bs+1;
videoFig.ForcedTrialDirButton = uicontrol('Style','pushbutton','String','FORCED TRIAL DIR',...
                                'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit - miscVar.buttonStepDown*bs,...
                                130,30], 'Callback',{@fcnForcedDirButton});

videoFig.PopForcedDir = uicontrol('Style','popup',... 
                             'Position',[miscVar.buttonLeftEdge+130+10,miscVar.upperLimit - miscVar.buttonStepDown*bs-7,95,30],...
                             'string',{'          LEFT   ';'         RIGHT   '},...
                             'Value', 1);
                         
bs=bs+1;
videoFig.EnterDelayButton = uicontrol('Style','pushbutton','String','ENTER DELAY',...
                             'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit - miscVar.buttonStepDown*bs, miscVar.buttonWidth,30],...
                             'Callback',{@fcnEnterDelayButton});
                       
videoFig.LiftBarrierButton = uicontrol('Style','pushbutton','String','LIFT BARRIER',...
                             'Position',[miscVar.buttonSecondCol,miscVar.upperLimit - miscVar.buttonStepDown*bs,...
                             miscVar.buttonWidth,30], 'Callback',{@fcnLiftBarrierButton});

bs=bs+1;                           
videoFig.FreeChoiceEnterButton = uicontrol('Style','pushbutton','String','FREE CHOICE ENTER',...
                             'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit - miscVar.buttonStepDown*bs,130,30],...
                             'Callback',{@fcnFreeChoiceEnterButton});

videoFig.FreeChoiceLeaveButton = uicontrol('Style','pushbutton','String','FREE CHOICE LEAVE',...
                             'Position',[miscVar.buttonSecondCol,miscVar.upperLimit - miscVar.buttonStepDown*bs,130,30],...
                             'Callback',{@fcnFreeChoiceLeaveButton}); 
                         
bs=bs+1;
videoFig.FreeTrialDirButton = uicontrol('Style','pushbutton','String','FREE TRIAL DIR',...
                             'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit - miscVar.buttonStepDown*bs,130,30],...
                             'Callback',{@fcnFreeDirButton});

videoFig.PopFreeDir = uicontrol('Style','popup',... 
                             'Position',[miscVar.buttonLeftEdge+130+10,miscVar.upperLimit - miscVar.buttonStepDown*bs-7,95,30],...
                             'string',{'          LEFT   ';'         RIGHT   '},...
                             'Value', 1);                          
                         
bs=bs+1; 
videoFig.FreeRewardButton = uicontrol('Style','pushbutton','String','FREE REWARD',...
                             'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit - miscVar.buttonStepDown*bs,miscVar.buttonWidth,30],...
                             'Callback',{@fcnFreeRewardButton}); 
                         
videoFig.LeaveMazeButton = uicontrol('Style','pushbutton','String','LEAVE MAZE',...
                             'Position',[miscVar.buttonSecondCol,miscVar.upperLimit - miscVar.buttonStepDown*bs,...
                             miscVar.buttonWidth,30], 'Callback',{@fcnLeaveMazeButton});
                         
bs=bs+1;
videoFig.StartHomecageButton = uicontrol('Style','pushbutton','String','START HOMECAGE',...
                             'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit - miscVar.buttonStepDown*bs,...
                             miscVar.buttonWidth,30], 'Callback',{@fcnStartHomecageButton});

videoFig.LeaveHomecageButton = uicontrol('Style','pushbutton','String','LEAVE HOMECAGE',...
                             'Position',[miscVar.buttonSecondCol,miscVar.upperLimit - miscVar.buttonStepDown*bs,...
                             miscVar.buttonWidth,30], 'Callback',{@fcnLeaveHomecageButton});
                        

headings={'Trial #'; 'Start on maze (start of Forced'; 'Forced Stem End'; 'Forced Choice';... 
                     'Forced Trial Type (L/R)'; 'Forced Reward'; 'Enter Delay';...
                     'Lift barrier (start of free choice)'; 'Free Stem End';...
                     'Free Choice'; 'Free Trial Choice (L/R)'; 'Free Reward';...
                     'Leave maze'; 'Start in homecage'; 'Leave homecage'};
               
d=1;        
ParsedFrames.LapNumber=headings(d); d=d+1;       
ParsedFrames.LapStart=headings(d); d=d+1;
ParsedFrames.ForcedChoiceEnter=headings(d); d=d+1;
ParsedFrames.ForcedChoiceLeave=headings(d); d=d+1;
ParsedFrames.ForcedDir=headings(d); d=d+1;
ParsedFrames.ForcedReward=headings(d); d=d+1;
ParsedFrames.EnterDelay=headings(d); d=d+1;
ParsedFrames.LiftBarrier=headings(d); d=d+1;
ParsedFrames.FreeChoiceEnter=headings(d); d=d+1;
ParsedFrames.FreeChoiceLeave=headings(d); d=d+1;
ParsedFrames.FreeDir=headings(d); d=d+1;
ParsedFrames.FreeReward=headings(d); d=d+1;
ParsedFrames.LeaveMaze=headings(d); d=d+1;
ParsedFrames.StartHomecage=headings(d); d=d+1;
ParsedFrames.LeaveHomecage=headings(d); 

%% Layout for ForcedUnforced
    case 2
        miscVar.buttonsInUse={'LapStartButton'; 'ChoiceLeaveButton';...
                              'TrialTypeButton';'TrialDirButton';...
                              'RewardButton';'EnterDelayButton';'LeaveMazeButton';...
                              'StartHomecageButton';'LeaveHomecageButton'};
bs=0;          
videoFig.LapStartButton = uicontrol('Style','pushbutton','String','LAP START',...
                           'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit,miscVar.buttonWidth,30],...
                           'Callback',{@fcnLapStartButton});

videoFig.ChoiceLeaveButton = uicontrol('Style','pushbutton','String','CHOICE LEAVE',...
                             'Position',[miscVar.buttonSecondCol,miscVar.upperLimit - miscVar.buttonStepDown*bs,miscVar.buttonWidth,30],...
                             'Callback',{@fcnChoiceLeaveButton});   

bs=bs+1;
videoFig.TrialTypeButton = uicontrol('Style','pushbutton','String','TRIAL TYPE',...
                                'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit - miscVar.buttonStepDown*bs,...
                                130,30], 'Callback',{@fcnTrialTypeButton});

videoFig.PopTrialType = uicontrol('Style','popup',... 
                             'Position',[miscVar.buttonLeftEdge+130+10,miscVar.upperLimit - miscVar.buttonStepDown*bs-7,110,30],...
                             'string',{'        FORCED   ';'         FREE   '},...
                             'Value', 1);
                         
bs=bs+1;
videoFig.TrialDirButton = uicontrol('Style','pushbutton','String','TRIAL DIR',...
                             'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit - miscVar.buttonStepDown*bs,130,30],...
                             'Callback',{@fcnTrialDirButton});

videoFig.PopTrialDir = uicontrol('Style','popup',... 
                             'Position',[miscVar.buttonLeftEdge+130+10,miscVar.upperLimit - miscVar.buttonStepDown*bs-7,110,30],...
                             'string',{'          LEFT   ';'         RIGHT   '},...
                             'Value', 1); 
                                          
bs=bs+1;
videoFig.RewardButton = uicontrol('Style','pushbutton','String','REWARD',...
                             'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit - miscVar.buttonStepDown*bs,miscVar.buttonWidth,30],...
                             'Callback',{@fcnRewardButton}); 

videoFig.EnterDelayButton = uicontrol('Style','pushbutton','String','ENTER DELAY',...
                             'Position',[miscVar.buttonSecondCol,miscVar.upperLimit - miscVar.buttonStepDown*bs, miscVar.buttonWidth,30],...
                             'Callback',{@fcnEnterDelayButton});
                         
bs=bs+1;
videoFig.LeaveMazeButton = uicontrol('Style','pushbutton','String','LEAVE MAZE',...
                             'Position',[miscVar.buttonSecondCol,miscVar.upperLimit - miscVar.buttonStepDown*bs,...
                             miscVar.buttonWidth,30], 'Callback',{@fcnLeaveMazeButton});
                         
bs=bs+1;
videoFig.StartHomecageButton = uicontrol('Style','pushbutton','String','START HOMECAGE',...
                             'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit - miscVar.buttonStepDown*bs,...
                             miscVar.buttonWidth,30], 'Callback',{@fcnStartHomecageButton});

videoFig.LeaveHomecageButton = uicontrol('Style','pushbutton','String','LEAVE HOMECAGE',...
                             'Position',[miscVar.buttonSecondCol,miscVar.upperLimit - miscVar.buttonStepDown*bs,...
                             miscVar.buttonWidth,30], 'Callback',{@fcnLeaveHomecageButton});  
                         



                         
headings={'Trial #'; 'Start on maze (start of Forced)'; 'Choice leave';...
            'Reward'; 'Leave maze'; 'Start in homecage'; 'Leave homecage'; 'Trial Type (FORCED/FREE)';...
            'Trial Dir (L/R)';'Enter delay'};

ParsedFrames.LapNumber=headings(1);        
ParsedFrames.LapStart=headings(2);
ParsedFrames.ChoiceLeave=headings(3);
ParsedFrames.Reward=headings(4);
ParsedFrames.LeaveMaze=headings(5);
ParsedFrames.StartHomecage=headings(6);
ParsedFrames.LeaveHomecage=headings(7);
ParsedFrames.TrialType=headings(8);
ParsedFrames.TrialDir=headings(9);
ParsedFrames.EnterDelay=headings(10);

    case 3
        disp('Sorry bro')
end
%%
miscVar.controlButtonHeight=65;                         
videoFig.LoadVideoButton = uicontrol('Style','pushbutton','String','LOAD VIDEO',...
                             'Position',[miscVar.buttonLeftEdge,miscVar.controlButtonHeight,...
                             miscVar.buttonWidth,30],'Callback',{@fcnLoadVideo}); 
                         
videoFig.SaveSheetExcel = uicontrol('Style','pushbutton','String','SAVE SHEET',...                         
                             'Position',[miscVar.buttonSecondCol,miscVar.controlButtonHeight,...
                             miscVar.buttonWidth,30],'Callback',{@fcnSaveSheet});     
                         
videoFig.JumpFrameButton = uicontrol('Style','pushbutton','String','JUMP TO FRAME',...
                             'Position',[miscVar.buttonLeftEdge,miscVar.controlButtonHeight - miscVar.buttonStepDown*1,...
                             miscVar.buttonWidth,30], 'Callback',{@fcnJumpFrameButton});


videoFig.LoadSheetExcel = uicontrol('Style','pushbutton','String','LOAD SHEET',...                         
                             'Position',[miscVar.buttonSecondCol,miscVar.controlButtonHeight - miscVar.buttonStepDown*1,...
                             miscVar.buttonWidth,30],'Callback',{@fcnLoadSheet});     
%{                         
videoFig.fakePlay = uicontrol('Style','pushbutton','String','PLAY',...
                        'Position',[miscVar.buttonLeftEdge,miscVar.controlButtonHeight - miscVar.buttonStepDown*2,...
                        miscVar.buttonWidth,30], 'BackgroundColor',miscVar.Gray,'Callback',{@fcnFakePlayer});

videoFig.PopFakePlaySpeed = uicontrol('Style','popup',... 
                             'Position',[miscVar.buttonLeftEdge+130+10,miscVar.controlButtonHeight - miscVar.buttonStepDown*2-7,95,30],...
                             'string',{'          1x   ';'         2x   ';'         4x   ';'        10x   '},...
                             'Value', 1,'Callback',{@fcnSetFakePlaySpeed}); 
%}                         
%%


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
        %miscVar.LapNumber=str2double(videoFig.LapNumberBox.String);
        switch any(miscVar.LapsWorkedOn==miscVar.LapNumber)
            case 0
                for buttonCol=1:length(miscVar.buttonsInUse)
                    eval(['videoFig.',miscVar.buttonsInUse{buttonCol},'.BackgroundColor=miscVar.Red;'])
                end
            case 1
                %message things will be overwritten
        end
        miscVar.LapsWorkedOn=[miscVar.LapsWorkedOn; miscVar.LapNumber];
        disp(['Lap number is ' num2str(miscVar.LapNumber)])
    end    
catch
    msgbox('Lap number must be an integer.', 'Error','error');
    videoFig.LapNumberBox.BackgroundColor=miscVar.Red;
end

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
function fcnNextButton(~,~)
global miscVar
global videoFig

if miscVar.currentEvent < length(miscVar.anchorFrames)
    miscVar.currentEvent = miscVar.currentEvent + 1;
    frameSet(miscVar.anchorFrames(miscVar.currentEvent) + miscVar.adjustment);
    videoFig.AddButton.BackgroundColor = miscVar.Red;
else
    disp('Already at last event')
end

end

function fcnPreviousButton(~,~)
global miscVar
global videoFig

if miscVar.currentEvent > 1
    miscVar.currentEvent = miscVar.currentEvent - 1;
    frameSet(miscVar.anchorFrames(miscVar.currentEvent) + miscVar.adjustment);
    videoFig.AddButton.BackgroundColor = miscVar.Red;
else
    disp('Already at event 1')   
end

end

%%
function fcnJumpFrameButton(~,~)
global videoFig
global miscVar
global video

if miscVar.VideoLoadedFlag==1
    try
        jumpFrame = inputdlg('Jump to what frame?');
        switch mod(str2double(jumpFrame{:}),1)==0
            case 0
                msgbox('Frame number must be an integer','Error','error')
            case 1  
                jumpFrame=str2double(jumpFrame{:});
                if jumpFrame>0 && jumpFrame <=miscVar.totalFrames
                    miscVar.frameNum = jumpFrame-1;
                    video.CurrentTime = miscVar.frameNum/video.FrameRate;
                    miscVar.currentFrame = readFrame(video);
                    miscVar.frameNum = miscVar.frameNum + 1;
                    videoFig.plotted = imagesc(miscVar.currentFrame);
                    title(['frame ' num2str(miscVar.frameNum) '/' num2str(miscVar.totalFrames)])
                else   
                    msgbox('Frame number must in range','Error','error')
                end
        end
    catch
        msgbox('Why would you even?')
    end 
end    
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
%miscVar.totalFrames = video.Duration/video.FrameRate^-1;
miscVar.totalFrames = video.Duration*video.FrameRate;
videoFig.plotted;
imagesc(miscVar.currentFrame);
title(['Frame ' num2str(miscVar.frameNum) '/' num2str(miscVar.totalFrames)])
miscVar.VideoLoadedFlag=1;
videoFig.Name=miscVar.FileName;
catch
    disp('Something went wrong')
end

end
function fcnPositions(~,~)
global miscVar

[miscVar.PosName,miscVar.PosPath] = uigetfile('*.mat','Select the Pos file');
load(fullfile(miscVar.PosPath,miscVar.PosName),'xAVI','yAVI')

miscVar.xAVI = xAVI; 
miscVar.yAVI = yAVI;

end
function fcnLoadBehavior(~,~)
[filename, pathname, ext] = uigetfile({'*.xlsx', 'Excel Files'; '*.xls', 'Excel Files'}, 'Select previously saved sheet: ');
[~, frames] = xlsread(fullfile(pathname, filename));

end


function fcnFakePlayer(~,~)
disp('fake player')
end
%%
function keyPress(~, e)%src

global miscVar
global videoFig
global video

%pause(0.001)
%e.Key

switch e.Key
    case 'q' %Step back 100
        miscVar.frameChangeWanted = -100;
        SetAndDisplay;
    case 'a' %Step back 10
        miscVar.frameChangeWanted = -10;
        SetAndDisplay;
    case 's'   %Step back
        miscVar.frameChangeWanted = -1;
        SetAndDisplay;
    case 'd' %Step forward 1
        miscVar.frameChangeWanted = 1;
        SetAndDisplay;
    case 'f' %Step forward 10  
        miscVar.frameChangeWanted = 10;
        SetAndDisplay;
    case 'r' %Step forward 100
        %if video.currentTime+100 < miscVar.totalFrames
        miscVar.frameChangeWanted = 100;
        SetAndDisplay;
    case 'space'    
        disp('Fake player start/stop')
    case 'j'
        fcnJumpFrameButton;
end
         
end
%%
function SetAndDisplay(~,~)
global miscVar
global videoFig
global video


if miscVar.frameNum + miscVar.frameChangeWanted <= miscVar.totalFrames...
        && miscVar.frameNum + miscVar.frameChangeWanted >= 1
    miscVar.frameNum = miscVar.frameNum + miscVar.frameChangeWanted - 1;
elseif miscVar.frameNum + miscVar.frameChangeWanted > miscVar.totalFrames
    miscVar.frameNum = miscVar.totalFrames - 1;
elseif miscVar.frameNum + miscVar.frameChangeWanted < 1    
    miscVar.frameNum = 0;
end

video.CurrentTime = miscVar.frameNum/video.FrameRate;
miscVar.currentFrame = readFrame(video);
miscVar.frameNum = miscVar.frameNum + 1;
videoFig.plotted = imagesc(miscVar.currentFrame);
hold(videoFig.plotted,'on');  
plot(miscVar.xAVI(miscVar.frameNum),miscVar.yAVI(miscVar.frameNum),'r',...
        'MarkerSize',4,'MarkerFaceColor','r')
hold(videoFig.plotted,'off');  
title(['Frame ' num2str(miscVar.frameNum) ' / ' num2str(miscVar.totalFrames)])

end

