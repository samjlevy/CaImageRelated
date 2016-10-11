function ButtonLogger(~,~)

global captureFig
global buttonLog

buttonLog = cell(0);
captureFig.startLoggingFlag=0;
captureFig.panelHeight = 450;
captureFig.panelWidth = 350;
%p = uipanel
captureFig.panel = figure('Name','Button Logger',...
                    'Position',[100,100,captureFig.panelWidth,captureFig.panelHeight],...
                    'KeyPressFcn',@keyPress);
%title('Button Logger')

captureFig.upperLimit = captureFig.panelHeight - 70;
captureFig.buttonStepDown = 40;
captureFig.buttonLeftEdge = 50;

captureFig.lastLabel = uicontrol('style','text','String','LAST BUTTON:',...
                          'Position',[20,345,80,30]);%,'FontSize',10
captureFig.keyPressed = annotation('textbox','string','none',...
                          'units','pixels','Position',[110,350,65,30],...
                          'BackgroundColor','white','HorizontalAlignment','center');
captureFig.thatTime = annotation('textbox','string','none',...
                          'units','pixels','Position',[185,350,150,30],...
                          'BackgroundColor','white','HorizontalAlignment','center');              
                      

captureFig.StartLoggingButton = uicontrol('Style','pushbutton','String','START LOGGING',...
                           'Position',[75,300,200,30],...
                           'Callback',{@fcnStartLoggingButton});
                       
captureFig.LoadExistingButton = uicontrol('Style','pushbutton','String','LOAD LOG',...
                           'Position',[75,250,200,30],...
                           'Callback',{@fcnLoadExistingButton});
                       
captureFig.SaveLogButton = uicontrol('Style','pushbutton','String','SAVE CURRENT LOG',...
                           'Position',[75,200,200,30],...
                           'Callback',{@fcnSaveLogButton});                       
                                     

%buttons
%Start Logging
%Load Existing log
%Save current Log
end
function keyPress(~, e)
%e.Key
global buttonLog
global captureFig

if captureFig.startLoggingFlag == 1

[r,~] = size(buttonLog);
buttonLog{r+1,1} = e.Key;
buttonLog{r+1,2} = now;
captureFig.keyPressed.String = buttonLog{r+1,1};
captureFig.thatTime.String = char(datetime('now'));

end

end
function fcnStartLoggingButton(~,~)

global captureFig

switch captureFig.startLoggingFlag
    case 0
        captureFig.startedLogging=char(datetime('now'));
        captureFig.startLoggingFlag=1;
        captureFig.StartLoggingButton.BackgroundColor = [0, 1, 0];
    case 1
        captureFig.startLoggingFlag=0;
        captureFig.StartLoggingButton.BackgroundColor = [0.94,0.94,0.94];
end
%get focus off of button?

end
function fcnLoadExistingButton(~,~)

global buttonLog


[filename, pathname] = uigetfile('Choose existing log to append to');
msgbox('INCOMPLETE CALLBACK!','Nothing') 

%{
try
    load fullfile(pathname,filename) 'buttonLog'
catch
    trying = whos('-file',fullfile(pathname,filename))
    for aa=1:length(trying) 
        options{aa} = trying(aa).name; 
    end
    uicontrol('Style','popup',...
                             'Position',[miscVar.buttonLeftEdge+130+10,miscVar.upperLimit - miscVar.buttonStepDown*6-7,95,30],...
                             'string',options,...
                             'Value', 1);
    load fullfile(pathname,filename)
    %Some how pick which is the log file
end
buttonLog = buttonLog;
%}

end

function fcnSaveLogButton(~,~)

global buttonLog
global captureFig

[r,~] = size(buttonLog);
switchHere = r>0;
switch switchHere
    case 0
       msgbox('No button log to save!','Nothing') 
    case 1
       sampleStr = {['<animal>_',captureFig.startedLogging(1:11)]}; 
       saveName = inputdlg('Enter file name','Save Button Log',...
                            1,sampleStr);
       saveDir = uigetdir('Choose directory to save in');
       saveNameMat = char(fullfile(saveDir,strcat(saveName, '.mat')));
       startTime = captureFig.startedLogging;
       save(saveNameMat,'buttonLog','startTime')
end

   
end