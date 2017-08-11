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

miscVar.upperLimit = miscVar.panelHeight - 100;
miscVar.buttonStepDown = 40;
miscVar.buttonLeftEdge = 560;
miscVar.buttonSecondCol = 705;
miscVar.buttonWidth = 130;
miscVar.buttonHeight = 30;
miscVar.Gray=[0.94,0.94,0.94];
miscVar.Red=[1,0.5,0.5];
miscVar.Green = [0.5 1 0.5];
miscVar.VideoLoadedFlag=0;
miscVar.LapsWorkedOn=[];
miscVar.currentEvent = 0;
miscVar.loadedBehavior = 0;
miscVar.markedFrames = [];

fcnLoadVideo;
fcnLoadPositions;
fcnLoadBehavior;

videoFig.PreviousButton = uicontrol('Style','pushbutton','String','PEVIOUS EVENT',...
                           'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit-45,...
                           miscVar.buttonWidth,miscVar.buttonHeight],...
                           'Callback',{@fcnPreviousButton});
                       
videoFig.NextButton = uicontrol('Style','pushbutton','String','NEXT EVENT',...
                           'Position',[miscVar.buttonSecondCol,miscVar.upperLimit-45,...
                           miscVar.buttonWidth,miscVar.buttonHeight],...
                           'Callback',{@fcnNextButton});   
                               
videoFig.MarkFrameButton = uicontrol('Style','pushbutton','String','MARK FRAME',...
                           'Position',[miscVar.buttonLeftEdge,miscVar.upperLimit-90,...
                           miscVar.buttonWidth,miscVar.buttonHeight],...
                           'Callback',{@fcnMarkFrame});
                       
videoFig.RandomFrameButton = uicontrol('Style','pushbutton','String','RANDOM FRAME',...
                           'Position',[miscVar.buttonSecondCol,miscVar.upperLimit-90,...
                           miscVar.buttonWidth,miscVar.buttonHeight],...
                           'Callback',{@fcnRandomFrame});                       

miscVar.controlButtonHeight=65;                         
videoFig.LoadVideoButton = uicontrol('Style','pushbutton','String','LOAD VIDEO',...
                             'Position',[miscVar.buttonLeftEdge,miscVar.controlButtonHeight,...
                             miscVar.buttonWidth,30],'Callback',{@fcnLoadVideo}); 
                         
videoFig.SaveFrames = uicontrol('Style','pushbutton','String','SAVE MARKED',...                         
                             'Position',[miscVar.buttonSecondCol,miscVar.controlButtonHeight,...
                             miscVar.buttonWidth,30],'Callback',{@fcnSaveFrames});     
                         
videoFig.JumpFrameButton = uicontrol('Style','pushbutton','String','JUMP TO FRAME',...
                             'Position',[miscVar.buttonLeftEdge,miscVar.controlButtonHeight - miscVar.buttonStepDown*1,...
                             miscVar.buttonWidth,30], 'Callback',{@fcnJumpFrameButton});


videoFig.LoadSheetExcel = uicontrol('Style','pushbutton','String','LOAD SHEET',...                         
                             'Position',[miscVar.buttonSecondCol,miscVar.controlButtonHeight - miscVar.buttonStepDown*1,...
                             miscVar.buttonWidth,30],'Callback',{@fcnLoadBehavior});     
%{                         
videoFig.fakePlay = uicontrol('Style','pushbutton','String','PLAY',...
                        'Position',[miscVar.buttonLeftEdge,miscVar.controlButtonHeight - miscVar.buttonStepDown*2,...
                        miscVar.buttonWidth,30], 'BackgroundColor',miscVar.Gray,'Callback',{@fcnFakePlayer});

videoFig.PopFakePlaySpeed = uicontrol('Style','popup',... 
                             'Position',[miscVar.buttonLeftEdge+130+10,miscVar.controlButtonHeight - miscVar.buttonStepDown*2-7,95,30],...
                             'string',{'          1x   ';'         2x   ';'         4x   ';'        10x   '},...
                             'Value', 1,'Callback',{@fcnSetFakePlaySpeed}); 
%}                         


end
%%
function fcnNextButton(~,~)
global miscVar

if miscVar.currentEvent < length(miscVar.sortedFrames)
    if ~isnan(miscVar.sortedFrames(miscVar.currentEvent + 1))
        miscVar.currentEvent = miscVar.currentEvent + 1;
        miscVar.frameWanted = miscVar.sortedFrames(miscVar.currentEvent);
        SetAndDisplay;
    end
else
    disp('Already at last event')
end

end

function fcnPreviousButton(~,~)
global miscVar

if miscVar.currentEvent > 1
    if ~isnan(miscVar.sortedFrames(miscVar.currentEvent - 1))
        miscVar.currentEvent = miscVar.currentEvent - 1;
        miscVar.frameWanted = miscVar.sortedFrames(miscVar.currentEvent); 
        SetAndDisplay;
    end
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
                    %miscVar.frameNum = jumpFrame-1;
                    %video.CurrentTime = miscVar.frameNum/video.FrameRate;
                    %miscVar.currentFrame = readFrame(video);
                    %miscVar.frameNum = miscVar.frameNum + 1;
                    %videoFig.plotted = imagesc(miscVar.currentFrame);
                    %title(['frame ' num2str(miscVar.frameNum) '/' num2str(miscVar.totalFrames)])
                    miscVar.frameWanted = jumpFrame;
                    SetAndDisplay
                else   
                    msgbox('Frame number must in range','Error','error')
                end
        end
    catch
        msgbox('nope')
    end 
end    
end
%%
function fcnMarkFrame(~,~)
global miscVar

miscVar.markedFrames = [miscVar.markedFrames, miscVar.frameNum];
end
%%
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
%%
function fcnLoadPositions(~,~)
global miscVar

[miscVar.PosName,miscVar.PosPath] = uigetfile('*.mat','Select the Pos file');
try
    load(fullfile(miscVar.PosPath,miscVar.PosName),'xAVI','yAVI')
    miscVar.xAVI = xAVI; 
    miscVar.yAVI = yAVI;
catch
    disp('sorry, cannot load xAVI/yAVI')
end

end
%%
function fcnLoadBehavior(~,~)
global miscVar

lbchoice = questdlg('Load a behavior spreadsheet?','Load behavior','Yes','No','Yes');

if strcmpi(lbchoice,'Yes')
    [filename, pathname] = uigetfile({'*.xlsx', 'Excel Files'; '*.xls', 'Excel Files'}, 'Select previously saved sheet: ');
    [frames,miscVar.txt] = xlsread(fullfile(pathname, filename));
    miscVar.framesSize = size(frames(:,2:end));
    miscVar.allFrames = frames(:,2:end);
    [miscVar.sortedFrames, miscVar.sortindex] = sort(miscVar.allFrames(:));
    miscVar.allFrames = miscVar.allFrames(:);
    miscVar.loadedBehavior = 1;
end

end
%%
function fcnSaveFrames(~,~)
global miscVar

MarkedFrames = miscVar.markedFrames;
save 'MarkedFrames.mat' MarkedFrames
disp('Saved!')
end
%%
function fcnFakePlayer(~,~)
disp('fake player')
end
%%
function fcnRandomFrame(~,~)
global miscVar

miscVar.frameWanted = randi(miscVar.totalFrames);
SetAndDisplay;

end
%%
function keyPress(~, e)%src

global miscVar

switch e.Key
    case 'q' %Step back 100
        %miscVar.frameChangeWanted = -100;
        miscVar.frameWanted = miscVar.frameNum - 100;
        SetAndDisplay;
    case 'a' %Step back 10
       % miscVar.frameChangeWanted = -10;
        miscVar.frameWanted = miscVar.frameNum - 10;
        SetAndDisplay;
    case 's'   %Step back
       %miscVar.frameChangeWanted = -1;
        miscVar.frameWanted = miscVar.frameNum - 1;
        SetAndDisplay;
    case 'd' %Step forward 1
        %miscVar.frameChangeWanted = 1;
        miscVar.frameWanted = miscVar.frameNum + 1;
        SetAndDisplay;
    case 'f' %Step forward 10  
        %miscVar.frameChangeWanted = 10;
        miscVar.frameWanted = miscVar.frameNum + 10;
        SetAndDisplay;
    case 'r' %Step forward 100
        %if video.currentTime+100 < miscVar.totalFrames
        %miscVar.frameChangeWanted = 100;
        miscVar.frameWanted = miscVar.frameNum + 100;
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

%{
if miscVar.frameNum + miscVar.frameChangeWanted <= miscVar.totalFrames...
        && miscVar.frameNum + miscVar.frameChangeWanted >= 1
    miscVar.frameNum = miscVar.frameNum + miscVar.frameChangeWanted - 1;
elseif miscVar.frameNum + miscVar.frameChangeWanted > miscVar.totalFrames
    miscVar.frameNum = miscVar.totalFrames - 1;
elseif miscVar.frameNum + miscVar.frameChangeWanted < 1    
    miscVar.frameNum = 0;
end
%}

if miscVar.frameWanted <= miscVar.totalFrames...
        && miscVar.frameWanted >= 1
    miscVar.frameNum = miscVar.frameWanted - 1;
elseif miscVar.frameWanted > miscVar.totalFrames
    miscVar.frameNum = miscVar.totalFrames - 1;
elseif miscVar.frameWanted < 1    
    miscVar.frameNum = 0;
end

video.CurrentTime = miscVar.frameNum/video.FrameRate;
miscVar.currentFrame = readFrame(video);
miscVar.frameNum = miscVar.frameNum + 1;
%videoFig.plotted = imagesc(miscVar.currentFrame);
%hold(videoFig.plotted,'on');  
videoFig.plotted;
imagesc(miscVar.currentFrame);
hold on
plot(videoFig.plotted,miscVar.xAVI(miscVar.frameNum),...
                      miscVar.panelHeight - miscVar.yAVI(miscVar.frameNum),...
                      'or','MarkerSize',4,'MarkerFaceColor','r')
hold off
%hold(videoFig.plotted,'off');  

switch miscVar.loadedBehavior
    case 0
        title(['Frame ' num2str(miscVar.frameNum) ' / ' num2str(miscVar.totalFrames)])
    case 1
        thisAnEvent = find(miscVar.sortedFrames==miscVar.frameNum);
        if length(thisAnEvent)==1
            [i,j]=ind2sub(miscVar.framesSize,miscVar.sortindex(thisAnEvent));
            miscVar.eventText = ['Lap ' num2str(i) ', ' miscVar.txt{1,j+1}];
            title(['Frame ' num2str(miscVar.frameNum) ' / ' num2str(miscVar.totalFrames) ', ' miscVar.eventText])
        else
            title(['Frame ' num2str(miscVar.frameNum) ' / ' num2str(miscVar.totalFrames)]) 
        end
end

end

