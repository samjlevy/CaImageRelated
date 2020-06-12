function [ Hue, Saturation, Value] = HSVcolorRanger(videoFile,backgroundImage,possibleFrames)
%% Build figure
global fig
fig.f = figure('Position',[334 133 1269 818]);
fig.UserData.cFrame = [];
fig.UserData.Hue = [0.25 0.75];
fig.UserData.Saturation = [0.25 0.75];
fig.UserData.Value = [0.25 0.75];
fig.UserData.bkgFrame = [];
edgeBuffer = 0.02;
imX = (1-edgeBuffer*4)/3;
imY = imX*(480/640)*1.35;
row1 = 1-edgeBuffer*2-imY;
row2 = 1-edgeBuffer*4-imY*2;
row3 = 1-edgeBuffer*6-imY*4;

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
    if any(backgroundImage)
        imagesc(fig.spot(rr).axx,backgroundImage);
    end
end

c = hsv(256); c = reshape(c,1,256,3); 
fig.spot(7).axx = axes('Parent',fig.f,'position',[0.375 0.05 0.25 0.05]);
imagesc(fig.spot(7).axx,c)
fig.spot(7).axx.XTick = linspace(1,256,6);
fig.spot(7).axx.XTickLabel = 0:0.2:1;
fig.spot(7).axx.YTick = [];
%fig.spot(7).axx.Visible = 'off';

fig.hueValueText = uicontrol('style','text','String',...
    ['Hue: ' num2str(fig.UserData.Hue)],...
    'Position',[110,200,150,25],'FontSize',12,'Parent',fig.f);

fig.HlowSlider = uicontrol('Style','slider','Position',...
    [100,160,200,25],...
    'Value',0.25, 'min',0, 'max',1,...
    'Callback',{@setHue},'SliderStep',[1/100 1/100],'Parent',fig.f);
fig.HlowLabel = uicontrol('style','text','String',...
    'Hue Min',...
    'Position',[20,157,70,25],'FontSize',12,'Parent',fig.f);

fig.HhighSlider = uicontrol('Style','slider','Position',...
    [100,120,200,25],...
    'Value',0.75, 'min',0, 'max',1,...
    'Callback',{@setHue},'SliderStep',[1/100 1/100],'Parent',fig.f);
fig.HhighLabel = uicontrol('style','text','String',...
    'Hue Max',...
    'Position',[20,117,70,25],'FontSize',12,'Parent',fig.f);


fig.satValueText = uicontrol('style','text','String',...
    ['Saturation: ' num2str(fig.UserData.Saturation)],...
    'Position',[500,200,200,25],'FontSize',12,'Parent',fig.f);

fig.SlowSlider = uicontrol('Style','slider','Position',...
    [500,160,200,25],...
    'Value',0.25, 'min',0, 'max',1,...
    'Callback',{@setSat},'SliderStep',[1/100 1/100],'Parent',fig.f);
fig.SlowLabel = uicontrol('style','text','String',...
    'Sat. Min',...
    'Position',[420,157,70,25],'FontSize',12,'Parent',fig.f);

fig.ShighSlider = uicontrol('Style','slider','Position',...
    [500,120,200,25],...
    'Value',0.75, 'min',0, 'max',1,...
    'Callback',{@setSat},'SliderStep',[1/100 1/100],'Parent',fig.f);
fig.ShighLabel = uicontrol('style','text','String',...
    'Sat. Max',...
    'Position',[420,117,70,25],'FontSize',12,'Parent',fig.f);

fig.valValueText = uicontrol('style','text','String',...
    ['Value: ' num2str(fig.UserData.Value)],...
    'Position',[900,200,150,25],'FontSize',12,'Parent',fig.f);

fig.VlowSlider = uicontrol('Style','slider','Position',...
    [900,160,200,25],...
    'Value',0.25, 'min',0, 'max',1,...
    'Callback',{@setVal},'SliderStep',[1/100 1/100],'Parent',fig.f);
fig.VlowLabel = uicontrol('style','text','String',...
    'Val. Min',...
    'Position',[820,157,70,25],'FontSize',12,'Parent',fig.f);

fig.VhighSlider = uicontrol('Style','slider','Position',...
    [900,120,200,25],...
    'Value',0.75, 'min',0, 'max',1,...
    'Callback',{@setVal},'SliderStep',[1/100 1/100],'Parent',fig.f);
fig.VhighLabel = uicontrol('style','text','String',...
    'Val. Max',...
    'Position',[820,117,70,25],'FontSize',12,'Parent',fig.f);

fig.plotSelect = uicontrol('Style','popup','Position',[100,80,200,20],...
                             'string',{'Raw frame';'Hue';'Saturation';...
                             'Value';'Blobs'},...
                             'Value', 1,'FontSize',10,'Callback',{@PlotFrames},'Parent',fig.f);
fig.plotLabel = uicontrol('style','text','String','Plot this:',...
                          'Position',[10,77,90,25],'FontSize',12,'Parent',fig.f);

%Subtract background frame
fig.subBkg = uicontrol('Style','checkbox','Position',[500,80,25,25],...
                             'Value', 0,'Parent',fig.f);
fig.subBkgLabel = uicontrol('style','text','String','Subtract bkg:',...
                          'Position',[400,77,100,25],'FontSize',12,'Parent',fig.f);
%Show thresholded button
fig.useThresh = uicontrol('Style','checkbox','Position',[500,50,25,25],...
                             'Value', 0,'Parent',fig.f);
fig.useTreshLabel = uicontrol('style','text','String','Use HSV lims:',...
                          'Position',[390,47,110,25],'FontSize',12,'Parent',fig.f);
%Label Mouse button
fig.LabelsButton = uicontrol('style','pushbutton','String','Label mouse',...
                          'Position',[1050,70,125,35],...
                          'Callback',{@LabelMice},'Parent',fig.f);
%New frame button
fig.FramesButton = uicontrol('style','pushbutton','String','New frames',...
                          'Position',[900,70,125,35],...
                          'Callback',{@PickFrames},'Parent',fig.f);
%Save button
fig.FramesButton = uicontrol('style','pushbutton','String','Save',...
                          'Position',[900,30,125,35],...
                          'Callback',{@savequit},'Parent',fig.f);
                      
fig.UserData.centers = [];
         

disp(['Using ' videoFile ])
obj = VideoReader(videoFile); 
frameSize = [obj.Height obj.Width];
clear obj
if isempty(backgroundImage)
    bkgg = questdlg('Found no background image.','No bkg','Load','Make','None','Load');
    switch bkgg
        case 'Load'
            disp('Nope, not here yet')
        case 'Make'
            [backgroundImage] = AdjustWithBackgroundImage(videoFile, obj, backgroundImage);
        case 'None'
            backgroundImage = zeros(frameSize(1),frameSize(2),3);
    end
end
fig.UserData.bkgFrame = backgroundImage;
fig.UserData.bkgFrameHSV = rgb2hsv(fig.UserData.bkgFrame);


PickFrames(videoFile);
PlotFrames;
figure(fig.f);


end
function [Hue,Saturation,Value] = savequit(~,~)
global fig

close(fig.f)
return

[Hue,Saturation,Value] = GetFinalVals;
end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Hue,Saturation,Value] = GetFinalVals(~,~)
global fig

Hue = fig.UserData.Hue;
Saturation = fig.UserData.Saturation;
Value = fig.UserData.Value;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PickFrames(videoFile)
global fig

obj = VideoReader(videoFile); 
h1 = implay(videoFile);
           
for ii = 1:6
    checkFrames(ii) = str2double(input(['Enter frame number for test ' num2str(ii) '/6 >>'],'s'));
end

for ii = 1:6
    obj.CurrentTime = (checkFrames(ii)-1)/obj.FrameRate;
    fig.UserData.cFrame{ii} = readFrame(obj);
    fig.UserData.frames(ii).HSV = rgb2hsv(fig.UserData.cFrame{ii});
end

try
    close(h1); 
end
clear obj

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LabelMice(~,~)
global fig

if any(fig.UserData.cFrame{1})

if any(fig.UserData.centers)
    disp('Had old centers, clearing them')
    fig.centers=[];
end

disp('Need to click in order:')
disp(' ')
disp('      [1] [2] [3] ')
disp('      [4] [5] [6] ')


for qq = 1:6
    [fig.UserData.centers(qq,1), fig.UserData.centers(qq,2)] = ginput(1);
end

PlotFrames;
else
    disp('Please get some frames first')
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PlotFrames(~,~)
global fig

% Re-threshold things
for pp = 1:6
    hhh = fig.UserData.frames(pp).HSV;
    fig.UserData.frames(pp).HSVthreshed(:,:,1) = hhh(:,:,1)>=fig.UserData.Hue(1) & hhh(:,:,1)<fig.UserData.Hue(2);
    fig.UserData.frames(pp).HSVthreshed(:,:,2) = hhh(:,:,2)>=fig.UserData.Saturation(1) & hhh(:,:,2)<fig.UserData.Saturation(2);
    fig.UserData.frames(pp).HSVthreshed(:,:,3) = hhh(:,:,3)>=fig.UserData.Value(1) & hhh(:,:,3)<fig.UserData.Value(2);
    
    fig.UserData.frames(pp).HSVbin = sum(fig.UserData.frames(pp).HSVthreshed,3) == 3;

    if any(fig.UserData.bkgFrame)
        bkg = fig.UserData.bkgFrameHSV;  
        fig.UserData.bkgFrameThreshed(:,:,1) = bkg(:,:,1)>=fig.UserData.Hue(1) & bkg(:,:,1)<fig.UserData.Hue(2);
        fig.UserData.bkgFrameThreshed(:,:,2) = bkg(:,:,2)>=fig.UserData.Saturation(1) & bkg(:,:,2)<fig.UserData.Saturation(2);
        fig.UserData.bkgFrameThreshed(:,:,3) = bkg(:,:,3)>=fig.UserData.Value(1) & bkg(:,:,3)<fig.UserData.Value(2);

        if fig.useThresh.Value == 1
            tt = fig.UserData.frames(pp).HSVthreshed(:,:,1); tt(fig.UserData.bkgFrameThreshed(:,:,1) == 1) = false;
            fig.UserData.frames(pp).HSVsub(:,:,1) = tt;
            tt = fig.UserData.frames(pp).HSVthreshed(:,:,2); tt(fig.UserData.bkgFrameThreshed(:,:,2) == 1) = false;
            fig.UserData.frames(pp).HSVsub(:,:,2) = tt;
            tt = fig.UserData.frames(pp).HSVthreshed(:,:,3); tt(fig.UserData.bkgFrameThreshed(:,:,3) == 1) = false;
            fig.UserData.frames(pp).HSVsub(:,:,3) = tt;
        end
    end
end


for pp = 1:6
hold(fig.spot(pp).axx,'off')
switch fig.plotSelect.Value
    case 1 % 'Raw frame'
        imagesc(fig.spot(pp).axx,fig.UserData.cFrame{pp})
    case 2 % 'Hue'
        if fig.useThresh.Value
            if fig.subBkg.Value
                imagesc(fig.spot(pp).axx,fig.UserData.frames(pp).HSVsub(:,:,1))
            else
                imagesc(fig.spot(pp).axx,fig.UserData.frames(pp).HSVthreshed(:,:,1))
            end
        else
            imagesc(fig.spot(pp).axx,fig.UserData.frames(pp).HSV(:,:,1))
        end
    case 3 % 'Saturation'
        if fig.useThresh.Value
            if fig.subBkg.Value
                imagesc(fig.spot(pp).axx,fig.UserData.frames(pp).HSVsub(:,:,2))
            else
                imagesc(fig.spot(pp).axx,fig.UserData.frames(pp).HSVthreshed(:,:,2))
            end
        else
            imagesc(fig.spot(pp).axx,fig.UserData.frames(pp).HSV(:,:,2))
        end
    case 4 % 'Value'
        if fig.useThresh.Value
            if fig.subBkg.Value
                imagesc(fig.spot(pp).axx,fig.UserData.frames(pp).HSVsub(:,:,3))
            else
                imagesc(fig.spot(pp).axx,fig.UserData.frames(pp).HSVthreshed(:,:,3))
            end
        else
            imagesc(fig.spot(pp).axx,fig.UserData.frames(pp).HSV(:,:,3))
        end
    case 5 % 'Blobs'
        %if fig.useThresh.Value && ~isempty(fig.UserData.bkgFrame)
            
        %else
            imagesc(fig.spot(pp).axx,fig.UserData.frames(pp).HSVbin)
        %end
    case 6 % Smoothed blobs
     
end
hold(fig.spot(pp).axx,'on')
fig.spot(pp).axx.Visible = 'off';
end

disp(' ')
%{
for pp = 1:6
    stats=[];
            d = imgaussfilt(double(fig.UserData.frames(pp).HSVbin),2);
            stats = regionprops(d>willThresh & mazeMask,'area','centroid',...
                'majoraxislength','minoraxislength');%flipped %'solidity'
            MouseBlob = [stats.Area] > 10 & ... %[stats.Area] < 3500...
                        [stats.MajorAxisLength] > 10 & ...
                        [stats.MinorAxisLength] > 10;
            stats=stats(MouseBlob);
end
    %}
%{
if fig.plotBlobs.Value == 1
    PlotBlobs;
end
%}
if any(fig.UserData.centers)
    for ee = 1:6
        hold(fig.spot(ee).axx,'on')
        plot(fig.spot(ee).axx,fig.UserData.centers(ee,1),fig.UserData.centers(ee,2),'go')
        hold(fig.spot(ee).axx,'off')
        fig.spot(pp).axx.Visible = 'off';
    end
end
   

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setHue(~,~)
global fig

fig.HlowSlider.Value = round(fig.HlowSlider.Value,2);
fig.HhighSlider.Value = round(fig.HhighSlider.Value,2);

if fig.HlowSlider.Value >= fig.HhighSlider.Value
    fig.HlowSlider.Value = fig.HlowSlider.Value - 0.01;
end

fig.UserData.Hue = [fig.HlowSlider.Value fig.HhighSlider.Value];

fig.hueValueText.String = ['Hue: ' num2str(fig.UserData.Hue)];
PlotFrames;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setSat(~,~)
global fig

fig.VlowSlider.Value = round(fig.VlowSlider.Value,2);
fig.VhighSlider.Value = round(fig.VhighSlider.Value,2);

if fig.SlowSlider.Value >= fig.ShighSlider.Value
    fig.SlowSlider.Value = fig.SlowSlider.Value - 0.01;
end

fig.UserData.Saturation = [fig.SlowSlider.Value fig.ShighSlider.Value];

fig.satValueText.String = ['Saturation: ' num2str(fig.UserData.Saturation)];
PlotFrames;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setVal(~,~)
global fig

fig.VlowSlider.Value = round(fig.VlowSlider.Value,2);
fig.VhighSlider.Value = round(fig.VhighSlider.Value,2);

if fig.VlowSlider.Value >= fig.VhighSlider.Value
    fig.VlowSlider.Value = fig.VlowSlider.Value - 0.01;
end

fig.UserData.Value = [fig.VlowSlider.Value fig.VhighSlider.Value];

fig.valValueText.String = ['Value: ' num2str(fig.UserData.Value)];
PlotFrames;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateAxisSize(~,~)
global fig
global grayLength

fig.sizeSlider.Value = round(fig.sizeSlider.Value);
grayLength = fig.sizeSlider.Value;
fig.sizeLabel.String = ['Axis Length: ' num2str(grayLength)];
%fig.expectedBlobs=logical(imgaussfilt(double(fig.v0thresh),10) <= grayLength);
%imagesc(fig.expected.axx,fig.expectedBlobs)
PlotFrames;
PlotExpectedBlobs;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PlotBlobs(~,~)
global fig
global frames
global grayBlobArea
global grayLength
global grayLengthUpper
global pp


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
                       [grayStats.MinorAxisLength] > grayLength &...
                       [grayStats.MajorAxisLength] < grayLengthUpper &...
                       [grayStats.MinorAxisLength] < grayLengthUpper);
    
    if fig.useMask.Value==1; LimitCenters; end
    
    if ~isempty(frames(pp).grayStats)
        for gg=1:length(frames(pp).grayStats)
            plot(fig.spot(pp).axx,frames(pp).grayStats(gg).Centroid(1),...
                frames(pp).grayStats(gg).Centroid(2),'r*')
            rectangle(fig.spot(pp).axx,'Position',[50 50 grayLength grayLength],...
                'Curvature',[1 1],'EdgeColor','c')
        end
    end
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LimitCenters(~,~)
global frames
global pp
global mazex
global mazey

if ~isempty(mazex) && ~isempty(mazeY)
stats =frames(pp).grayStats;
statsCenters = reshape([stats.Centroid],2,length(stats))';
[inmask, onmask] = inpolygon(statsCenters(:,1),statsCenters(:,2),mazex,mazey);
inMask = inmask | onmask;
frames(pp).grayStats = stats(inMask);
else
    disp('no maze mask found')
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function WhichFrames(~,~)
global obj
global frames
global avi_filepath

prompt = {'Frame 1:','Frame 2:','Frame 3:','Frame 4:','Frame 5:','Frame 6:'};
defaultans = {'','','','','',''};
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
function WhichFramesNew(~,~)

WhichFrames;
PlotFrames;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




