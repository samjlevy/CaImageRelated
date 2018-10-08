function GetDoublePlusPosAnchor

realArmLength = 24; %inches
realArmWidth = 2.25; %inches
pixPerInch = 10;

% Get the avi File
avi_filepath = ls('*.avi');
if size(avi_filepath,1)~=1
    [avi_filepath,~] = uigetfile('*.avi','Choose appropriate video:');
end
disp(['Using ' avi_filepath ])
obj = VideoReader(avi_filepath);
aviSR = obj.FrameRate;
%nFrames = round(obj.Duration*aviSR);  
frameSize = [obj.Height obj.Width];

%Get frames for calibration
h1 = implay(avi_filepath);
calNames = {'WEST','EAST','SOUTH','NORTH'};
for cnI = 1:length(calNames)
    calFrameN(cnI) = str2double(input(['Enter frame number for ' calNames{cnI} ' arm calibration >> '],'s'));
    obj.CurrentTime = (calFrameN(cnI)-1)/aviSR;
    calFrame{cnI} = readFrame(obj);
end
close(h1);

%Get scaling calibration points
scalingX = cell(length(calNames),1); scalingY = cell(length(calNames),1);
for cnJ = 1:length(calNames)
    hh = figure('Position',[500,100,560*2,420*2]);
    imagesc(calFrame{cnJ})
    hold on
    title(['Click along calibration inputs from center to end for ' calNames{cnJ}])
    disp('Right click to end finding points')
    buttonPressed = 1;
    bg = 0;
    while buttonPressed == 1
        bg = bg + 1;
        [xi,yi,buttonPressed] = ginput(1);
        if buttonPressed==1
            scalingX{cnJ}(bg)=xi; scalingY{cnJ}(bg)=yi;
            plot(scalingX{cnJ}(bg),scalingY{cnJ}(bg),'.m','MarkerSize',6)
        end
    end
    close(hh)
    
    [scalingX{cnJ},scalingY{cnJ}]=fixPts(calFrame{cnJ},scalingX{cnJ},scalingY{cnJ},[]);
    
end

%Get maze calibration points
load('PosLED_temp.mat','v0','xAVI','yAVI','onMaze','DVTtime')
onMaze = logical(onMaze);    

v0Anchors={'Center SW','Center NW','Center SE','Center NE',...
           'West N','West S','East N','East S',...
           'South W','South E','North W','North E'};
       
hh=figure('Position',[500,100,560*2,420*2]);
imagesc(v0); hold on
for vI = 1:length(v0Anchors)
    title(['Please click at: ' v0Anchors{vI} ' corner'])
    [v0anchorX(vI),v0anchorY(vI)] = ginput(1);
    plot(v0anchorX(vI),v0anchorY(vI),'.m','MarkerSize',6)
end
close(hh)

[v0anchorX,v0anchorY]=fixPts(v0,v0anchorX,v0anchorY,[0 1 0]);

[anchorX,anchorY,bounds] = MakeDoublePlusPosAnchor([]);

%transform all points
v0anchor = [v0anchorX' v0anchorY'];
realAnchor = [anchorX' anchorY'];
allPtsTform = fitgeotrans(v0anchor,realAnchor,'affine');
[step1X,step1Y] = transformPointsForward(allPtsTform,xAVI,yAVI);

% Bounds to get points for arm scaling
scaleBoundsX{1} = [anchorX(bounds{1}(1:2)) -100  anchorX(bounds{1}(3:4))-50 -100];
scaleBoundsY{1} = [anchorY(bounds{1}(1:2)) 100  anchorY(bounds{1}(3))+50 anchorY(bounds{1}(4))-50 -100];
scaleBoundsX{2} = [anchorX(bounds{2}(1:2)) 100  anchorX(bounds{2}(3:4))+50 100];
scaleBoundsY{2} = [anchorY(bounds{2}(1:2)) 100  anchorY(bounds{2}(3))+50 anchorY(bounds{1}(4))-50 -100];
scaleBoundsX{3} = [anchorX(bounds{3}(1:2)) 100  anchorX(bounds{3}(4))+50 anchorX(bounds{4}(3))-50 -100];
scaleBoundsY{3} = [anchorY(bounds{3}(1:2)) -100  anchorY(bounds{3}(3:4))-50 -100];
scaleBoundsX{4} = [anchorX(bounds{4}(1:2)) 100  anchorX(bounds{4}(3))+50 anchorX(bounds{4}(4))-50 -100];
scaleBoundsY{4} = [anchorY(bounds{4}(1:2)) 100  anchorY(bounds{4}(3:4))+50 100];

%This is going to be nasty, leaving it alone for now
%{
%Transform points along appropriate axis to calibration scaling
%This going to have to hard code each piece individually
armMid{1} = min(inputX{1}(inputX{1} > mean(v0anchorX(bounds{1}(1:2)))));
armEnd{1} = max(inputX{1}(inputX{1} < mean(v0anchorX(bounds{1}(3:4)))));
inpolygon of each scale bounds
e.g., for west: transform only the x coordinates of these points

%}

xAlign = step1X; 
yAlign = step1Y;

save PosScaled.mat xAlign yAlign onMaze DVTtime v0anchor scalingX scalingY calFrameN

disp('done, saved')
end

function [ptsX,ptsY]=fixPts(bkgImage,ptsX,ptsY,editOptions)

if isempty(editOptions)
    editOptions = ones(1,3);
end

hh=figure('Position',[500,100,560*2,420*2]);
imagesc(bkgImage); hold on
plot(ptsX,ptsY,'.m','MarkerSize',6)
title('Are these good?')
allGood = 0;
while allGood==0
    edChoice = input('Edit these? a=add, r=replace, x=delete, d=done >>','s');
    switch edChoice
        case 'a'
            if editOptions(1)==1
            newInd = length(ptsX)+1;
            [ptsX(newInd),ptsY(newInd)] = ginput(1);
            plot(ptsX(newInd),ptsY(newInd),'.m','MarkerSize',6)
            else
                disp('Nope')
            end
        case 'r'
            if editOptions(2)==1
            [qx,qy] = ginput(1);
            idx = findclosest2D(ptsX,ptsY,qx,qy);
            plot(ptsX(idx),ptsY(idx),'or')
            tw = questdlg('This one?','this one','Yes','No','Yes');
            if strcmpi(tw,'Yes')
                ptsX(idx) = NaN; ptsY(idx) = NaN;
                hold off; imagesc(bkgImage); hold on
                plot(ptsX,ptsY,'.m','MarkerSize',6)
                %newInd = length(ptsX)+1;
                [ptsX(idx),ptsY(idx)] = ginput(1);
                plot(ptsX(idx),ptsY(idx),'.m','MarkerSize',6)
            end
            else
                disp('Nope')
            end
        case 'x'
            if editOptions(3)==1
            [qx,qy] = ginput(1);
            idx = findclosest2D(ptsX,ptsY,qx,qy);
            plot(ptsX(idx),ptsY(idx),'or')
            tw = questdlg('This one?','this one','Yes','No','Yes');
            if strcmpi(tw,'Yes')
                ptsX(idx) = []; ptsY(idx) = [];
                hold off; imagesc(bkgImage); hold on
                plot(ptsX,ptsY,'.m','MarkerSize',6)
            end
            else
                disp('Nope')
            end
        case 'd'
            allGood = 1;
        otherwise
            disp('not a recognized input')
    end
end
close(hh)

end