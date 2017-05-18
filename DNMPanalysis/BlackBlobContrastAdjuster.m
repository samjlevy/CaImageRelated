function [ contrast] = BlackBlobContrastAdjuster%(obj,grayThresh)
global fig
global grayThresh
global frames

Add: drop down menu control for plotting raw gray thresh, gaussian smoothed, etc.
     option to plot gray thresholded blobs

grayThresh = 115;
aviSR = 30.0003;

frames(1).wanted = 971;
frames(2).wanted = 971;
frames(3).wanted = 971;
frames(4).wanted = 971;
frames(5).wanted = 971;
frames(6).wanted = 971;
obj = VideoReader('161013_Europa_DNMP.AVI');
for ff=1:length(frames)
    obj.CurrentTime=(frames(ff).wanted-1)/aviSR;
    frames(ff).v = readFrame(obj);
    frames(ff).grayFrame = rgb2gray(frames(ff).v);
end

figWidth = 1400;
edgeBuffer = 0.02;
imX = (1-edgeBuffer*4)/3;
imY = imX*(480/640)*1.35;
row1 = 1-edgeBuffer*2-imY;
row2 = 1-edgeBuffer*4-imY*2;

fig.f = figure('Position',[100,100,figWidth,800],'Name','Gray thresholding',...
    'Color',[0.7 0.7 0.7]);

pos1 = [edgeBuffer row1 imX imY];
fig.spot(1).axx = axes('Parent',fig.f,'position',pos1);
fig.spot(1).axx.Visible = 'off';
pos2 =[edgeBuffer*2+imX row1 imX imY];
fig.spot(2).axx = axes('Parent',fig.f,'position',pos2);
fig.spot(2).axx.Visible = 'off';
pos3 =[edgeBuffer*3+imX*2 row1 imX imY];
fig.spot(3).axx = axes('Parent',fig.f,'position',pos3);
fig.spot(3).axx.Visible = 'off';

pos4 = [edgeBuffer row2 imX imY];
fig.spot(4).axx = axes('Parent',fig.f,'position',pos4);
fig.spot(4).axx.Visible = 'off';
pos5 =[edgeBuffer*2+imX row2 imX imY];
fig.spot(5).axx = axes('Parent',fig.f,'position',pos5); 
fig.spot(5).axx.Visible = 'off';
pos6 =[edgeBuffer*3+imX*2 row2 imX imY];
fig.spot(6).axx = axes('Parent',fig.f,'position',pos6);
fig.spot(6).axx.Visible = 'off';

PlotFrames;

fig.graySlider = uicontrol('Style','slider','Position',...
    [figWidth/2-300,(row2-edgeBuffer*4)*800,600,50],...
    'Value',grayThresh, 'min',1, 'max',255,...
    'Callback',{@updateThresh},'SliderStep',[1/254 1/254]);
fig.grayLabel = uicontrol('style','text','String',...
    ['Gray Threshold: ' num2str(fig.graySlider.Value)],...
    'Position',[600,135,220,30],'FontSize',15);
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
fig.graySlider.Value = round(fig.graySlider.Value);
grayThresh = fig.graySlider.Value;
fig.grayLabel.String = ['Gray Threshold: ' num2str(grayThresh)];
PlotFrames;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PlotFrames(~,~)
global fig
global grayThresh
global frames

for pp = 1:length(fig.spot)
    frames(pp).grayThreshed = frames(pp).grayFrame < grayThresh;
    imagesc(fig.spot(pp).axx,frames(pp).grayThreshed) 
    fig.spot(pp).axx.Visible = 'off';
end


end





















