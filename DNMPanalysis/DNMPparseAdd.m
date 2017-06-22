function DNMPparseAdd      
%Function for adding an event in the parser based on input array of times
%User dictates which type they're adding, then inputs an array of times 
%this function uses as the 'anchor', jumps to those points (+/- some amount
%of time, saves selected frame number as the new type.
%E.G., need to add timestamp for the choice point? Input array of time
%leaving the start area, then adjust frame estimate for say 2s worth of
%frames, parser will jump through video to input timestamps (leave start area),
%forward/backward 60 frames, leave it to user to find the exact frame and 
%save it.
%Saving to XLS formatting isn't quite right
%% 
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
miscVar.Gray=[0.94,0.94,0.94];
miscVar.Red=[1,0.5,0.5];
miscVar.Green = [0.5 1 0.5];                                            

fcnLoadVideo;

%Get which timestamp we're adding
sessionType = questdlg('What kind of session is this?', 'Session Type',...
                              'DNMP','ForcedUnforced','Other','DNMP');

switch sessionType
    case 'DNMP'
        addingStr = {'LapNumber', 'LapStart', 'LiftBarrier', 'LeaveMaze',...
       'StartHomecage', 'LeaveHomecage','Enter delay', 'ForcedDir',...
       'FreeDir', 'TrialDir', 'ForcedChoiceEnter',...
       'ForcedLeaveChoice', 'FreeChoiceEnter', 'FreeLeaveChoice',...
       'ForcedReward', 'FreeReward','Other...'};
    case 'ForcedUnforced'
       addingStr = {'LapNumber', 'LapStart', 'LeaveMaze',...
       'StartHomecage', 'LeaveHomecage','Trial Type (FORCED/FREE)',...
       'TrialDir', 'ChoiceEnter','Enter delay', 'Choice leave'...
       'Reward','Other...'};
end
   
[addingVal,~] = listdlg('PromptString','Which are we adding:',...
                'SelectionMode','single',...
                'ListString',addingStr);

miscVar.addingType=addingStr{1,addingVal};

if strcmpi(miscVar.addingType,'Other...')
    %name your own timestamp!
end

%Assume we're going on an excel sheet
[xlFile, xlPath, ~] = uigetfile({'*.xlsx', 'Excel Files'; '*.xls', 'Excel Files'}, 'Select previously saved sheet: ');
[frames, txt] = xlsread(fullfile(xlPath,xlFile), 1);
options = txt(1,1:end);
[anchorTypeVal,~] = listdlg('PromptString','Which does it follow?',...
                    'SelectionMode','single','ListString',options);
miscVar.anchorFrames = frames(:,anchorTypeVal);

                
adjustInt = 0;
while adjustInt==0
    miscVar.adjustment = inputdlg('Jump how many frames?','Adjustment');
    miscVar.adjustment = str2double(miscVar.adjustment{1,1});
    switch rem(miscVar.adjustment,1)==0
        case 1
            adjustInt=1;
        case 0
            adjustInt=0;
            disp('Whole number, please')
    end        
end
plusminus = questdlg('Forward or back?', 'Forward or back?', ...
	'Forward','Back','Forward');
switch plusminus
    case 'Forward'
        %do nothing
    case 'Back'
        miscVar.adjustment = miscVar.adjustment*-1;
end

% Figure buttons
figure(videoFig.videoPanel);
videoFig.AddButton = uicontrol('Style','pushbutton','String',miscVar.addingType,...
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
                       
miscVar.currentEvent=1;
frameSet(miscVar.anchorFrames(miscVar.currentEvent) + miscVar.adjustment);
videoFig.AddButton.BackgroundColor=miscVar.Red;

end
%%
%{
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
%}
%% Functions to run this ish
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fcnAddButton(~,~)
%set current frame as 
global ParsedFrames
global videoFig
global miscVar

ParsedFrames.AddingThis{miscVar.currentEvent,1} = miscVar.frameNum;
disp([' Entered event number ' num2str(miscVar.currentEvent) ' as frame# ' num2str(ParsedFrames.AddingThis{miscVar.currentEvent,1})])
videoFig.AddButton.BackgroundColor=miscVar.Gray;

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
    frameSet(miscVar.anchorFrames(miscVar.currentEvent + miscVar.adjustment));
    videoFig.AddButton.BackgroundColor = miscVar.Red;
else
    disp('Already at event 1')   
end

end

function fcnSaveQuitButton(~,~)
global ParsedFrames
global miscVar
global videoFig
disp('Save sheet')

realCell{1,1} = 'Lap number';
realCell{1,2} = miscVar.addingType;
for laps=1:size(ParsedFrames.AddingThis,1)
    realCell{laps+1,1}=laps;
    realCell{laps+1,2} = ParsedFrames.AddingThis{laps};
end
%realCell = {ParsedFrames.LapNumber, ParsedFrames.AddThing}

%try 
%    realTable=table(ParsedFrames.LapNumber,...
               % ParsedFrames.AddThing);
%catch 
    save 'luckyYou.mat' 'ParsedFrames'
    disp('saved what you had')
    %Error handling!
%end            
             
undecided=0; saveNow=0;
while undecided==0
    saveName = inputdlg('Name to save as:','Save Name',[1 40],{'DNMPadd1.xlsx'});             
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
        xlswrite(fullfile(miscVar.PathName,saveName{1}),realCell)
    catch
        disp('Some saving error')   
    end    
end

close(videoFig.videoPanel)
return

end

function frameSet(jumpToFrame)
global miscVar
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
global video

%pause(0.001)
%e.Key

switch e.Key
    case 'q' %Step back 100
        if video.currentTime > 100/video.FrameRate
           frameSet(miscVar.frameNum - 100);
            %{
            miscVar.frameNum = miscVar.frameNum - 101;
            video.CurrentTime = miscVar.frameNum/video.FrameRate;
            miscVar.currentFrame = readFrame(video);
            miscVar.frameNum = miscVar.frameNum + 1;
            videoFig.plotted = imagesc(miscVar.currentFrame);
            title(['Frame ' num2str(miscVar.frameNum) ' / ' num2str(miscVar.totalFrames)])
            %}
        end
    case 'a' %Step back 10
        if video.currentTime > 10/video.FrameRate
            frameSet(miscVar.frameNum - 10);
            %{
            miscVar.frameNum = miscVar.frameNum - 11;
            video.CurrentTime = miscVar.frameNum/video.FrameRate;
            miscVar.currentFrame = readFrame(video);
            miscVar.frameNum = miscVar.frameNum + 1;
            videoFig.plotted = imagesc(miscVar.currentFrame);
            title(['Frame ' num2str(miscVar.frameNum) ' / ' num2str(miscVar.totalFrames)])
            %}
        end
    case 's'   %Step back
        %can't do frame 0/1
        if video.currentTime > 1/video.FrameRate
            frameSet(miscVar.frameNum - 1);
            %{
            miscVar.frameNum = miscVar.frameNum - 2;
            video.CurrentTime = miscVar.frameNum/video.FrameRate;
            miscVar.currentFrame = readFrame(video);
            miscVar.frameNum = miscVar.frameNum + 1;
            videoFig.plotted = imagesc(miscVar.currentFrame);
            title(['Frame ' num2str(miscVar.frameNum) ' / ' num2str(miscVar.totalFrames)])
            %}
        end
    case 'd' %Step forward 1
        if video.currentTime+1 <= miscVar.totalFrames
            frameSet(miscVar.frameNum + 1);
            %{
            miscVar.currentFrame = readFrame(video);
            miscVar.frameNum = miscVar.frameNum+1;
            videoFig.plotted = imagesc(miscVar.currentFrame);
            title(['Frame ' num2str(miscVar.frameNum) ' / ' num2str(miscVar.totalFrames)])
            %}
        end
    case 'f' %Step forward 10  
        if video.currentTime+10 <= miscVar.totalFrames
            frameSet(miscVar.frameNum + 10);
            %{
            miscVar.frameNum = miscVar.frameNum + 9;
            video.CurrentTime = miscVar.frameNum/video.FrameRate;
            miscVar.currentFrame = readFrame(video);
            miscVar.frameNum = miscVar.frameNum + 1;
            videoFig.plotted = imagesc(miscVar.currentFrame);
            title(['Frame ' num2str(miscVar.frameNum) ' / ' num2str(miscVar.totalFrames)])
            %}
        end
    case 'r' %Step forward 100
        if video.currentTime+1 <= miscVar.totalFrames
            frameSet(miscVar.frameNum + 100)
            %{
            miscVar.frameNum = miscVar.frameNum + 99;
            video.CurrentTime = miscVar.frameNum/video.FrameRate;
            miscVar.currentFrame = readFrame(video);
            miscVar.frameNum = miscVar.frameNum + 1;
            videoFig.plotted = imagesc(miscVar.currentFrame);
            title(['Frame ' num2str(miscVar.frameNum) ' / ' num2str(miscVar.totalFrames)])
            %}
        end    
    case 'space'    
        disp('Fake player start/stop')
end
         
end