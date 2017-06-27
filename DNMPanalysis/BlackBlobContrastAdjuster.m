function BlackBlobContrastAdjuster
%This is to get some new contrast values for use in
%PreProcessMousePosition_autoSL3. Doesn't yet do contrast proper, just
%thresholding
global fig
global grayThresh %inherited
global frames
global gaussThresh %inherited
global obj %inherited
global findingContrast %inherited
global v0
global grayLength
global grayBlobArea


%{
    J = imadjust(I,[LOW_IN; HIGH_IN],[LOW_OUT; HIGH_OUT],GAMMA) maps the
    values of I to new values in J as described in the previous syntax.
    GAMMA specifies the shape of the curve describing the relationship
    between the values in I and J. If GAMMA is less than 1, the mapping is
    weighted toward higher (brighter) output values. If GAMMA is greater
    than 1, the mapping is weighted toward lower (darker) output values. If
    you omit the argument, GAMMA defaults to 1 (linear mapping).     
%}

%megaFrame = [frames(1).v frames(2).v frames(3).v; frames(4).v frames(5).v frames(6).v];

%grayThresh = 115;
%gaussThresh = 0.2;

WhichFrames;

if any(v0)
    foundBG = questdlg('Found a v0. Use it?', 'Background image', 'Yes','No','Yes');
switch foundBG
    case 'Yes'
        fig.v0 = v0;
        fig.v0thresh = [];
        fig.v0thresh = double(rgb2gray(fig.v0)) < grayThresh;
        PlotExpectedBlobs;
    case 'No'
end
else
bkgChoice = questdlg('Load a background image?', 'Background image', 'Yes','No','Yes');
switch bkgChoice
    case 'Yes'
        try
        [file, folder]=uigetfile('*.mat','Choose containing file:');
        pieces =whos( '-file', fullfile(folder,file));
        [s,~] = listdlg('PromptString','Select background image:',...
                        'SelectionMode','single','ListString',{pieces(:).name});
        v0 = load(fullfile(folder,file),char(pieces(s).name));
        fig.v0 = v0.v0;
        fig.v0thresh = double(rgb2gray(fig.v0)) < grayThresh;
        PlotExpectedBlobs;
        catch
            disp('Could not load. Weird')
            fig.v0 = zeros(size(frames(1).v));
            fig.expectedBlobs = true(size(frames(1).v));
        end
    case 'No'
        fig.v0 = zeros(size(frames(1).v));
        fig.expectedBlobs = ones(size(frames(1).v));
end
end
figure; imagesc(fig.v0)

figWidth = 1400;
edgeBuffer = 0.02;
imX = (1-edgeBuffer*4)/3;
imY = imX*(480/640)*1.35;
row1 = 1-edgeBuffer*2-imY;
row2 = 1-edgeBuffer*4-imY*2;
row3 = 1-edgeBuffer*6-imY*4;

fig.f = figure('Position',[100,100,figWidth,800],'Name','Gray thresholding',...
    'Color',[0.7 0.7 0.7]);


pos(1).pos = [edgeBuffer row1 imX imY];
pos(2).pos =[edgeBuffer*2+imX row1 imX imY];
pos(3).pos=[edgeBuffer*3+imX*2 row1 imX imY];
pos(4).pos= [edgeBuffer row2 imX imY];
pos(5).pos=[edgeBuffer*2+imX row2 imX imY];
pos(6).pos=[edgeBuffer*3+imX*2 row2 imX imY];
fig.centers=[];

%for bb = 1:6
%    pos(1).bounds = pos(bb).pos(1).

for rr = 1:6
    fig.spot(rr).axx = axes('Parent',fig.f,'position',pos(rr).pos);
    fig.spot(rr).axx.Visible = 'off'; hold on
end


fig.graySlider = uicontrol('Style','slider','Position',...
    [figWidth/2-300,(row2-edgeBuffer*4)*800+20,600,25],...
    'Value',grayThresh, 'min',1, 'max',255,...
    'Callback',{@updateThresh},'SliderStep',[1/254 1/254],'Parent',fig.f);
fig.grayLabel = uicontrol('style','text','String',...
    ['Gray Threshold: ' num2str(fig.graySlider.Value)],...
    'Position',[600,(row2-edgeBuffer*4)*800-12,220,25],'FontSize',12,'Parent',fig.f);

fig.gaussSlider = uicontrol('Style','slider','Position',...
    [figWidth/2-300,(row2-edgeBuffer*4)*800-52,600,25],...
    'Value',gaussThresh*100, 'min',1, 'max',99,...
    'Callback',{@updateGauss},'SliderStep',[0.01 0.01],'Parent',fig.f);
fig.gaussLabel = uicontrol('style','text','String',...
    ['Gauss Threshold: ' num2str(gaussThresh)],...
    'Position',[600,(row2-edgeBuffer*4)*800-84,220,25],'FontSize',12,'Parent',fig.f);

fig.sizeSlider = uicontrol('Style','slider','Position',...
    [figWidth/2-300,(row2-edgeBuffer*4)*800-124,280,25],...
    'Value',grayLength, 'min',0.1, 'max',50,...
    'Callback',{@updateAxisSize},'SliderStep',[0.01 0.01],'Parent',fig.f);
fig.sizeLabel = uicontrol('style','text','String',...
    ['Axis Length: ' num2str(grayLength)],...
    'Position',[420,(row2-edgeBuffer*4)*800-156,220,25],'FontSize',12,'Parent',fig.f);


fig.plotSelect = uicontrol('Style','popup','Position',[150,200,200,20],...
                             'string',{'Raw frame';'Gray Threshold';'Gauss smoothed';...
                             'Gauss smth thresh';'G.smth.thr - expect'},...
                             'Value', 1,'FontSize',10,'Callback',{@PlotFrames},'Parent',fig.f);
fig.plotLabel = uicontrol('style','text','String','Plot this:',...
                          'Position',[48,195,100,25],'FontSize',12,'Parent',fig.f);

fig.defSelect = uicontrol('Style','popup','Position',[150,170,200,20],...
                             'string',{'Mouse defaults';'Rat defaults';'none'},...
                             'Value', 1,'FontSize',10,'Callback',{@SetDefaults},'Parent',fig.f);
fig.defLabel = uicontrol('style','text','String','Default vals:',...
                          'Position',[48,165,100,25],'FontSize',12,'Parent',fig.f);  
                      
fig.plotBlobs = uicontrol('Style','checkbox','Position',[205,135,25,25],...
                             'Value', 0,'Parent',fig.f);
fig.plotLabel = uicontrol('style','text','String','Plot blob centers:',...
                          'Position',[48,135,150,25],'FontSize',12,'Parent',fig.f);
                      
fig.useExpected = uicontrol('Style','checkbox','Position',[205,105,25,25],...
                             'Value', 0,'Parent',fig.f);
fig.useLabel = uicontrol('style','text','String','Use expected:',...
                          'Position',[48,105,150,25],'FontSize',12,'Parent',fig.f);
                      
fig.QuitButton = uicontrol('style','pushbutton','String','Save & Quit',...
                          'Position',[figWidth-200,20,125,35],...
                          'Callback',{@savequit},'Parent',fig.f);
                      
fig.FramesButton = uicontrol('style','pushbutton','String','New frames',...
                          'Position',[figWidth-200,60,125,35],...
                          'Callback',{@WhichFrames},'Parent',fig.f);
                      
fig.InquireButton = uicontrol('style','pushbutton','String','Value ??',...
                          'Position',[figWidth-200,100,125,35],...
                          'Callback',{@InquireValue},'Parent',fig.f);    
                      
fig.LabelButton = uicontrol('style','pushbutton','String','Label mouse',...
                          'Position',[figWidth-200,140,125,35],...
                          'Callback',{@LabelMice},'Parent',fig.f);

PlotFrames;                         
%{
contrastSlider = uicontrol('Parent',f,'Style','slider','Position',...
    [figWidth/2-300,(row2-edgeBuffer*11)*800,600,50],...
    'value',grayThresh, 'min',1, 'max',255);%'BackgroundColor',[0.7 0.7 0.7]
contrastLabel = uicontrol('style','text','String','Contrast',...
    'Position',[600,25,200,30],'FontSize',15);
%}
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateThresh(~,~)
global fig
global grayThresh
global gaussThresh

fig.graySlider.Value = round(fig.graySlider.Value);
grayThresh = fig.graySlider.Value;
fig.grayLabel.String = ['Gray Threshold: ' num2str(grayThresh)];
fig.v0thresh = double(rgb2gray(fig.v0)) < grayThresh;
fig.expectedBlobs=logical(imgaussfilt(double(fig.v0thresh),10) <= gaussThresh);
imagesc(fig.expected.axx,fig.expectedBlobs)
PlotFrames;
PlotExpectedBlobs;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateGauss(~,~)
global fig
global gaussThresh

fig.gaussSlider.Value = round(fig.gaussSlider.Value);
gaussThresh = fig.gaussSlider.Value/100;
fig.gaussLabel.String = ['Gauss Threshold: ' num2str(gaussThresh)];
fig.expectedBlobs=logical(imgaussfilt(double(fig.v0thresh),10) <= gaussThresh);
imagesc(fig.expected.axx,fig.expectedBlobs)
PlotFrames;
PlotExpectedBlobs;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PlotFrames(~,~)
global fig
global grayThresh
global frames
global gaussThresh

for pp = 1:length(fig.spot)
    frames(pp).grayThreshed = frames(pp).grayFrame < grayThresh;
    frames(pp).grayGauss = imgaussfilt(double(frames(pp).grayThreshed),10);
    frames(pp).grayGaussThresh = frames(pp).grayGauss > gaussThresh; 
    frames(pp).grayGaussExpect = frames(pp).grayGaussThresh & fig.expectedBlobs;
    
    %{
    stats=[];
            d = imgaussfilt(flipud(rgb2gray(v0-v)),10);
            stats = regionprops(d>willThresh & mazeMask,'area','centroid',...
                'majoraxislength','minoraxislength');%flipped %'solidity'
            MouseBlob = [stats.Area] > 250 & ... %[stats.Area] < 3500...
                        [stats.MajorAxisLength] > 10 & ...
                        [stats.MinorAxisLength] > 10;
            stats=stats(MouseBlob);
    %}
    %rest of stuff
    hold(fig.spot(pp).axx,'off')
    switch fig.plotSelect.Value
        case 1
            imagesc(fig.spot(pp).axx,frames(pp).grayFrame)
        case 2
            imagesc(fig.spot(pp).axx,frames(pp).grayThreshed) 
        case 3
            imagesc(fig.spot(pp).axx,frames(pp).grayGauss)
        case 4
            imagesc(fig.spot(pp).axx,frames(pp).grayGaussThresh)
        case 5
            imagesc(fig.spot(pp).axx,frames(pp).grayGaussExpect)
    end
    hold(fig.spot(pp).axx,'on')
    fig.spot(pp).axx.Visible = 'off';
end

if fig.plotBlobs.Value == 1
    PlotBlobs;
end

if any(fig.centers)
    for ee = 1:6
        hold(fig.spot(ee).axx,'on')
        plot(fig.spot(ee).axx,fig.centers(ee,1),fig.centers(ee,2),'g*')
        hold(fig.spot(ee).axx,'off')
        fig.spot(pp).axx.Visible = 'off';
    end
end
   

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PlotBlobs(~,~)
global fig
global frames
global grayBlobArea
global grayLength


for pp = 1:length(fig.spot)
    frames(pp).grayStats = [];
    switch fig.useExpected.Value 
        case 0
            grayStats = regionprops(frames(pp).grayGaussThresh,...
            'centroid','area','majoraxislength','minoraxislength'); 
        case 1
            grayStats = regionprops(frames(pp).grayGaussExpect,...
            'centroid','area','majoraxislength','minoraxislength'); 
    end
    
    frames(pp).grayStats = grayStats( [grayStats.Area] > grayBlobArea &...
                       [grayStats.MajorAxisLength] > grayLength &...
                       [grayStats.MinorAxisLength] > grayLength);
    if ~isempty(frames(pp).grayStats)
        for gg=1:length(frames(pp).grayStats)
            plot(fig.spot(pp).axx,frames(pp).grayStats(gg).Centroid(1),...
                frames(pp).grayStats(gg).Centroid(2),'r*')
        end
    end
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function WhichFrames(~,~)
global obj
global frames

prompt = {'Frame 1:','Frame 2:','Frame 3:','Frame 4:','Frame 5:','Frame 6:'};
defaultans = {'971','','','','',''};
answer = inputdlg(prompt,'Frames to test',1,defaultans);

avi_filepath = ls('*.avi');
disp(['Using ' avi_filepath ])
obj = VideoReader(avi_filepath);
for ff = 1:6
    if any(answer{ff})
        frames(ff).wanted = str2double(answer{ff});
    else
        frames(ff).wanted = randi(floor( obj.Duration*obj.FrameRate));
    end

    obj.CurrentTime=(frames(ff).wanted-1)/obj.FrameRate;
    frames(ff).v = readFrame(obj);
    frames(ff).grayFrame = rgb2gray(frames(ff).v);
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function savequit(~,~)
global fig
global findingContrast

disp('wew dub')
close(fig.f)
try %#ok<TRYNC>
    close(fig.expect)
end
findingContrast=0;
return

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InquireValue(~,~)
disp('sorry not yet implemented')
%{
global fig
global frames

[x,y]=ginput(1);

switch fig.plotSelect.Value
        case 1
            imagesc(fig.spot(pp).axx,frames(pp).grayFrame)
        case 2
            imagesc(fig.spot(pp).axx,frames(pp).grayThreshed) 
        case 3
            imagesc(fig.spot(pp).axx,frames(pp).grayGauss)
        case 4
            imagesc(fig.spot(pp).axx,frames(pp).grayGaussThresh)
        case 5
            imagesc(fig.spot(pp).axx,frames(pp).grayGaussExpect)
    end
valueHere = 
disp(
%}
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LabelMice(~,~)
disp('sorry not yet implemented')
global fig

if any(fig.centers)
    disp('Had old centers, clearing them')
    fig.centers=[];
end

disp('Need to click in order:')
disp(' ')
disp('      [1] [2] [3] ')
disp('      [4] [5] [6] ')


for qq = 1:6
    [fig.centers(qq,1), fig.centers(qq,2)] = ginput(1);
end

PlotFrames;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SetDefaults(~,~)
global fig
global grayLength
global gaussThresh
global grayThresh

switch fig.defSelect.Value
    case 1
        grayLength = 15;
        fig.graySlider.Value = 95;
        fig.gaussSlider.Value = 0.21;
    case 2
        grayLength = 15;
        fig.graySlider.Value = 95;
        fig.gaussSlider.Value = 0.21;
    case 3
        %grayLength = 15;
        %grayThresh = 100;
        %gaussThresh = 0.20;
end

updateGauss;
updateThresh;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PlotExpectedBlobs(~,~)
global fig
global gaussThresh

figsOpen = findall(0,'type','figure');
isManCorr = strcmp({figsOpen.Name},'expectedblobs');
if sum(isManCorr)==1
    %We're good
elseif sum(isManCorr)==0
    fig.expect = figure('Name','expectedblobs');
    fig.expected.axx = axes('Parent',fig.expect);
elseif sum(isManCorr) > 1
    manCorrInds = find(isManCorr);
    close(figsOpen(manCorrInds(2:end)))
end

fig.expectedBlobs=logical(imgaussfilt(double(fig.v0thresh),10) <= gaussThresh);
imagesc(fig.expected.axx,fig.expectedBlobs)

end











