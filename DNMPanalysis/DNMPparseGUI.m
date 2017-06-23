function DNMPparseGUI( ~,~ )
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
                       
%% Set up
fcnLoadVideo;
sessionType = questdlg('What kind of session is this?', 'Session Type',...
                              'DNMP','ForcedUnforced','Other','DNMP');
switch sessionType
    case 'DNMP'
        miscVar.sessionClass=1;
    case 'ForcedUnforced'
        miscVar.sessionClass=2;
    case 'Other'
        disp('Not yet...')
        miscVar.sessionClass=3;
        %In theory this will be where you can load or enter 
        %What labels and order and it will generate appropriate buttons
end        

%% Layout for DNMP
%Generalize with multiselect layout, loop through buttons selected, at each
%go into next tiled slot. Need to figure out how to generalize excel
%spreadsheet saving too

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
%%
function fcnLapStartButton(~,~)
disp('Lap Start')
global miscVar
global ParsedFrames
global videoFig
if miscVar.VideoLoadedFlag==1
    ParsedFrames.LapStart{miscVar.LapNumber+1,1}=miscVar.frameNum;
    disp(num2str(ParsedFrames.LapStart{miscVar.LapNumber+1,1}))
    videoFig.LapStartButton.BackgroundColor=miscVar.Gray;
end
end
function fcnForcedChoiceEnterButton(~,~)
disp('Forced Choice Leave')
global miscVar
global ParsedFrames
global videoFig
if miscVar.VideoLoadedFlag==1
    ParsedFrames.ForcedChoiceEnter{miscVar.LapNumber+1,1}=miscVar.frameNum;
    disp(num2str(ParsedFrames.ForcedChoiceEnter{miscVar.LapNumber+1,1}))
    videoFig.ForcedChoiceEnterButton.BackgroundColor=miscVar.Gray;
end
end
function fcnForcedChoiceLeaveButton(~,~)
disp('Forced Choice Leave')
global miscVar
global ParsedFrames
global videoFig
if miscVar.VideoLoadedFlag==1
    ParsedFrames.ForcedChoiceLeave{miscVar.LapNumber+1,1}=miscVar.frameNum;
    disp(num2str(ParsedFrames.ForcedChoiceLeave{miscVar.LapNumber+1,1}))
    videoFig.ForcedChoiceLeaveButton.BackgroundColor=miscVar.Gray;
end
end

function fcnChoiceLeaveButton(~,~)
disp('Choice Leave')
global miscVar
global ParsedFrames
global videoFig
if miscVar.VideoLoadedFlag==1
    ParsedFrames.ChoiceLeave{miscVar.LapNumber+1,1}=miscVar.frameNum;
    disp(num2str(ParsedFrames.ChoiceLeave{miscVar.LapNumber+1,1}))
    videoFig.ChoiceLeaveButton.BackgroundColor=miscVar.Gray;
end
end
function fcnForcedRewardButton(~,~)
disp('Enter Delay')
global miscVar
global ParsedFrames
global videoFig
if miscVar.VideoLoadedFlag==1
    ParsedFrames.ForcedReward{miscVar.LapNumber+1,1}=miscVar.frameNum;
    disp(num2str(ParsedFrames.ForcedReward{miscVar.LapNumber+1,1}))
    videoFig.ForcedRewardButton.BackgroundColor=miscVar.Gray;
end
end
function fcnEnterDelayButton(~,~)
disp('Enter Delay')
global miscVar
global ParsedFrames
global videoFig
if miscVar.VideoLoadedFlag==1
    ParsedFrames.EnterDelay{miscVar.LapNumber+1,1}=miscVar.frameNum;
    disp(num2str(ParsedFrames.EnterDelay{miscVar.LapNumber+1,1}))
    videoFig.EnterDelayButton.BackgroundColor=miscVar.Gray;
end
end
function fcnLiftBarrierButton(~,~)
disp('Lift Barrier')
global miscVar
global ParsedFrames
global videoFig
if miscVar.VideoLoadedFlag==1
    ParsedFrames.LiftBarrier{miscVar.LapNumber+1,1}=miscVar.frameNum;
    disp(num2str(ParsedFrames.LiftBarrier{miscVar.LapNumber+1,1}))
    videoFig.LiftBarrierButton.BackgroundColor=miscVar.Gray;
end
end
function fcnFreeChoiceEnterButton(~,~)
disp('Free Choice Enter')
global miscVar
global ParsedFrames
global videoFig
if miscVar.VideoLoadedFlag==1
    ParsedFrames.FreeChoiceEnter{miscVar.LapNumber+1,1}=miscVar.frameNum;
    disp(num2str(ParsedFrames.FreeChoiceEnter{miscVar.LapNumber+1,1}))
    videoFig.FreeChoiceEnterButton.BackgroundColor=miscVar.Gray;
end
end
function fcnFreeChoiceLeaveButton(~,~)
disp('Free Choice Leave')
global miscVar
global ParsedFrames
global videoFig
if miscVar.VideoLoadedFlag==1
    ParsedFrames.FreeChoiceLeave{miscVar.LapNumber+1,1}=miscVar.frameNum;
    disp(num2str(ParsedFrames.FreeChoiceLeave{miscVar.LapNumber+1,1}))
    videoFig.FreeChoiceLeaveButton.BackgroundColor=miscVar.Gray;
end
end
function fcnFreeRewardButton(~,~)
disp('Free Reward')
global miscVar
global ParsedFrames
global videoFig
if miscVar.VideoLoadedFlag==1
    ParsedFrames.FreeReward{miscVar.LapNumber+1,1}=miscVar.frameNum;
    disp(num2str(ParsedFrames.FreeReward{miscVar.LapNumber+1,1}))
    videoFig.FreeRewardButton.BackgroundColor=miscVar.Gray;
end
end
function fcnRewardButton(~,~)
disp('Reward')
global miscVar
global ParsedFrames
global videoFig
if miscVar.VideoLoadedFlag==1
    ParsedFrames.Reward{miscVar.LapNumber+1,1}=miscVar.frameNum;
    disp(num2str(ParsedFrames.Reward{miscVar.LapNumber+1,1}))
    videoFig.RewardButton.BackgroundColor=miscVar.Gray;
end
end
function fcnLeaveMazeButton(~,~)
disp('Leave Maze')
global miscVar
global ParsedFrames
global videoFig
if miscVar.VideoLoadedFlag==1
    ParsedFrames.LeaveMaze{miscVar.LapNumber+1,1}=miscVar.frameNum;
    disp(num2str(ParsedFrames.LeaveMaze{miscVar.LapNumber+1,1}))
    videoFig.LeaveMazeButton.BackgroundColor=miscVar.Gray;
end
end
function fcnStartHomecageButton(~,~)
disp('Start Homecage')
global miscVar
global ParsedFrames
global videoFig
if miscVar.VideoLoadedFlag==1
    ParsedFrames.StartHomecage{miscVar.LapNumber+1,1}=miscVar.frameNum;
    disp(num2str(ParsedFrames.StartHomecage{miscVar.LapNumber+1,1}))
    videoFig.StartHomecageButton.BackgroundColor=miscVar.Gray;
end
end
function fcnLeaveHomecageButton(~,~)
disp('Leave Homecage')
global miscVar
global ParsedFrames
global videoFig
if miscVar.VideoLoadedFlag==1
    ParsedFrames.LeaveHomecage{miscVar.LapNumber+1,1}=miscVar.frameNum;
    disp(num2str(ParsedFrames.LeaveHomecage{miscVar.LapNumber+1,1}))
    videoFig.LeaveHomecageButton.BackgroundColor=miscVar.Gray;
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
            ParsedFrames.ForcedDir{miscVar.LapNumber+1,1}='L';
        case 2    
            ParsedFrames.ForcedDir{miscVar.LapNumber+1,1}='R';
    end        
    disp(ParsedFrames.ForcedDir{miscVar.LapNumber+1,1})
    videoFig.ForcedTrialDirButton.BackgroundColor=miscVar.Gray;
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
            ParsedFrames.FreeDir{miscVar.LapNumber+1,1}='L';
        case 2    
            ParsedFrames.FreeDir{miscVar.LapNumber+1,1}='R';
    end        
    disp(ParsedFrames.FreeDir{miscVar.LapNumber+1,1})
    videoFig.FreeTrialDirButton.BackgroundColor=miscVar.Gray;
end
end
function fcnTrialTypeButton(~,~)
disp('Trial type')
global miscVar
global ParsedFrames
global videoFig
if miscVar.VideoLoadedFlag==1
    switch videoFig.PopTrialType.Value
        case 1
            ParsedFrames.TrialType{miscVar.LapNumber+1,1}='FORCED';
        case 2    
            ParsedFrames.TrialType{miscVar.LapNumber+1,1}='FREE';
    end        
    disp(ParsedFrames.TrialType{miscVar.LapNumber+1,1})
    videoFig.TrialTypeButton.BackgroundColor=miscVar.Gray;
end
end
function fcnTrialDirButton(~,~)
disp('Trial Direction')
global miscVar
global ParsedFrames
global videoFig
if miscVar.VideoLoadedFlag==1
    switch videoFig.PopTrialDir.Value
        case 1
            ParsedFrames.TrialDir{miscVar.LapNumber+1,1}='L';
        case 2    
            ParsedFrames.TrialDir{miscVar.LapNumber+1,1}='R';
    end        
    disp(ParsedFrames.TrialDir{miscVar.LapNumber+1,1})
    videoFig.TrialDirButton.BackgroundColor=miscVar.Gray;
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

function fcnSaveSheet(~,~)
global ParsedFrames
global miscVar
disp('Save sheet')

for laps=1:(size(ParsedFrames.LapStart,1)-1)
    ParsedFrames.LapNumber{laps+1,1}=laps;
end  
save 'ParsedFramesTest.mat' 'ParsedFrames'

fields = fieldnames(ParsedFrames);
for i = 1:numel(fields)
    if length(ParsedFrames.(fields{i}))<=1 %fields get pre-loaded with their names
        ParsedFrames = rmfield(ParsedFrames,fields{i}); 
    end
end

%now can we just...?
realTable=struct2table(ParsedFrames);

%{
%and then save?
try 
switch miscVar.sessionClass
    case 1
realTable=table(ParsedFrames.LapNumber,...
                ParsedFrames.LapStart,...
                ParsedFrames.ForcedChoiceLeave,...
                ParsedFrames.ForcedReward,...
                ParsedFrames.EnterDelay,...
                ParsedFrames.LiftBarrier,...
                ParsedFrames.FreeChoiceLeave,...
                ParsedFrames.FreeReward,...
                ParsedFrames.LeaveMaze,...
                ParsedFrames.StartHomecage,...
                ParsedFrames.LeaveHomecage,...
                ParsedFrames.ForcedDir,...
                ParsedFrames.FreeDir);
    case 2
realTable=table(ParsedFrames.LapNumber,...
                ParsedFrames.LapStart,...
                ParsedFrames.LeaveMaze,...
                ParsedFrames.StartHomecage,...
                ParsedFrames.LeaveHomecage,...
                ParsedFrames.TrialType,...
                ParsedFrames.TrialDir);       
end        
%bonusTable=table(ParsedFrames.LapNumber,...
%              ParsedFrames.EnterDelay);
catch 
    save 'luckyYou.mat' 'ParsedFrames'
    disp('saved what you had')
    %Error handling!
end    
%}
             
undecided=0; saveNow=0;
while undecided==0
    saveName = inputdlg('Name to save as:','Save Name',[1 40],{'DNMPsheet.xlsx'});             
    if exist(fullfile(miscVar.PathName,saveName{1}),'file')==2
      filechoice = questdlg('File already exists!', 'File exists',...
                              'Replace','New name','Cancel','Replace');
        switch filechoice
            case 'Replace'
                undecided=1; saveNow=1;
            case 'New name'
                undecided=0;
            case 'Cancel'
                undecided=1; saveNow=1;
        end
    else 
        disp('File does not exist.  Writing new file')
        undecided = 1; saveNow = 1;
    end
end
if saveNow==1
    try
        xlswrite(fullfile(miscVar.PathName,saveName{1}),table2cell(realTable));
        if exist('bonusTable','var')
        xlswrite(fullfile(miscVar.PathName,[saveName{1}(1:end-5) '_bonus.xlsx']),table2cell(bonusTable));
        end
    catch
        disp('Some saving error')   
        save 'luckyYou.mat' 'ParsedFrames'
    end    
end
end


function fcnLoadSheet(~,~)
disp('Load sheet')
global ParsedFrames
global miscVar

disp('Not working right now, needs to be redone')
%{
[filename, pathname, ext] = uigetfile({'*.xlsx', 'Excel Files'; '*.xls', 'Excel Files'}, 'Select previously saved sheet: ');

[~, ~, raw] = xlsread(fullfile(pathname, filename));

switch miscVar.sessionClass
    case 1
        ParsedFrames.LapNumber = raw(:,1);
        ParsedFrames.LapStart = raw(:,2);
        ParsedFrames.LiftBarrier = raw(:,3);
        ParsedFrames.LeaveMaze = raw(:,4);
        ParsedFrames.StartHomecage = raw(:,5);
        ParsedFrames.LeaveHomecage = raw(:,6);
        ParsedFrames.ForcedDir = raw(:,7);
        ParsedFrames.FreeDir = raw(:,8);
    case 2
        ParsedFrames.LapNumber = raw(:,1);
        ParsedFrames.LapStart = raw(:,2);
        ParsedFrames.LeaveMaze = raw(:,3);
        ParsedFrames.StartHomecage = raw(:,4);
        ParsedFrames.LeaveHomecage = raw(:,5);
        ParsedFrames.TrialType = raw(:,6);
        ParsedFrames.TrialDir = raw(:,7);
end
bonus_sheet = fullfile(pathname, [filename(1:end-5) '_bonus.xlsx']);
[~,~,bonus_raw] = xlsread(bonus_sheet);
ParsedFrames.EnterDelay = bonus_raw(:,2);
%}
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
title(['Frame ' num2str(miscVar.frameNum) ' / ' num2str(miscVar.totalFrames)])

%Old logic
  %{
        if miscVar.frameNum+100 <= miscVar.totalFrames
if video.currentTime > 10/video.FrameRate
            miscVar.frameNum = miscVar.frameNum + 99;
            video.CurrentTime = miscVar.frameNum/video.FrameRate;
            miscVar.currentFrame = readFrame(video);
            miscVar.frameNum = miscVar.frameNum + 1;
            videoFig.plotted = imagesc(miscVar.currentFrame);
            title(['Frame ' num2str(miscVar.frameNum) ' / ' num2str(miscVar.totalFrames)])
            
        end   
 %}
end

