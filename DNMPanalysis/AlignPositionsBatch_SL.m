function AlignPositionsBatch_SL(base_path, align_paths, RoomStr)
%This function is to do a really good alignment of positions, both within
%and across animals

scaleFactor = 0.6246;
Pix2Cm = Pix2CMlist (RoomStr);
SR=20;
v0Scale = 1.5;

if exist(fullfile(base_path,'Pos_anchor.mat','file'))~=2
    load(fullfile(base_path,'Pos.mat'),'v0')
    [floorCorners,barrierX,barrierY,flipX,flipY] = MakePosAnchor(base_path,v0Scale);
    
    save(fullfile(base_path,'Pos_anchor.mat'),'floorCorners','barrierX','barrierY','flipX','flipY')
else
    load(fullfile(base_path,'Pos_anchor.mat'))
end

if exist(fullfile(base_path,'Pos_anchor_ideal.mat'),'file')~=2
    disp('Did not find pos_anchor_ideal, making now')
    [newCorners] = ArrangeBaseAnchors(v0,floorCorners, RoomStr, flipX, flipY, barrierX, barrierY);
    %Left turn is positive, right turn is negative
    xAnchor = newCorners(:,1);
    yAnchor = newCorners(:,2);
    
    %{
    tform = fitgeotrans(floorCorners,[xAnchor yAnchor],'affine');
    [xADJ, yADJ] = transformPointsForward(tform,xAVI,yAVI);
    figure; plot(newCorners(:,1),newCorners(:,2),'og','MarkerFaceColor','g')
    hold on
    plot(newCorners(1,1),newCorners(1,2),'*r') %base left corner
    plot(xADJ,yADJ,'.')
    %}
    
    save(fullfile(base_path,'Pos_anchor_ideal.mat'),'xAnchor','yAnchor')
else
    load(fullfile(base_path),'Pos_anchor_ideal.mat')
end

tform = fitgeotrans(floorCorners,[xAnchor yAnchor],'affine');
[xADJ, yADJ] = transformPointsForward(tform,xAVI,yAVI);
allPaths = {base_path, align_paths{:}};

for thisPath = 1:length(allPaths)
   
    if ~exist(fullfile(allPaths{thisPath},'Pos_final.mat'),'file')
    sessPath = allPaths{thisPath};
    [cx, cy]=GetCorners(sessPath);
    
    load(fullfile(sessPath,'Pos_brain.mat'))%x and y come from here
    
    tform = fitgeotrans([cx' cy'],[xAnchor yAnchor],'affine');
    [xt, yt] = transformPointsForward(tform,x*scaleFactor,y*scaleFactor);

    %Convert to CM
    Pix2Cm = Pix2CMlist (RoomStr);
    x_adj_cm = xt*Pix2Cm;
    y_adj_cm = yt.*Pix2Cm;

    %Speed for each
    dx = diff(x_adj_cm);
    dy = diff(y_adj_cm);
    speed = hypot(dx,dy)*SR;

    %Holdover overhead (probably)
    xmax = max(x_adj_cm);
    xmin = min(x_adj_cm);
    ymax = max(y_adj_cm);
    ymin = min(y_adj_cm);    

    PSAbool = PSAboolAdjusted;
    save('Pos_final.mat','x_adj_cm','y_adj_cm','xmin','xmax','ymin','ymax',...
                    'speed', 'PSAbool');
    end

end

end
%%%%%%%%%%%%%%%%%%%%
function [v0,floorCorners,barrierX,barrierY,flipX,flipY] = MakePosAnchor(base_path,v0Scale)
%Orient positions
[v0,xAVI,yAVI, flipX, flipY] = OrientBackgroundPos(base_path);

%Get relevant corners
[floorCorners(1:4,1), floorCorners(1:4,2)] = GetCorners(v0,'floorOuter',[]);
%[floorCorners(5:8,1), floorCorners(5:8,2)] = GetCorners(base_path,'floorStem',[]);
[floorCorners(5:8,1), floorCorners(5:8,2)]=GetCorners(v0,'floorMids',floorCorners(1:4,:));

bkg = figure('Position',[100 50 size(v0,2)*v0Scale size(v0,1)*v0Scale]);
imagesc(v0)
title('Click middle of BARRIER at FLOOR')
[barrierX,barrierY] = ginput(1);
close(bkg)
end
%%%%%%%%%%%%%%
function [v0,xAVI,yAVI, flipX, flipY] = OrientBackgroundPos(sessPath)
load(fullfile(sessPath,'Pos.mat'),'v0','xAVI','yAVI')
v0Scale = 1.5;

flipX = 0; flipY = 0;
bkg = figure('Position',[100 50 size(v0,2)*v0Scale size(v0,1)*v0Scale]);
doneFlip = 0;
while doneFlip==0
    figure(bkg); imagesc(v0); title('Correct position orientation')
    hold on; plot(bkg.Children,xAVI,yAVI,'.'); hold off
    isFlipped = questdlg('Is this right?','PosOrientation','Flip X','Flip Y','Correct','Correct');
    switch isFlipped
        case 'Flip X'
            xAVI = size(v0,2) - xAVI;
            flipX = 1;
        case 'Flip Y'
            yAVI = size(v0,1) - yAVI;
            flipY = 1;
        case 'Correct'
            doneFlip = 1;
    end
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [cx, cy]=GetCorners(v0, type, inputcorners)
v0Scale = 1.5;
terminology = {'Base = Start/Delay end';...
               'Choice = Choice end';};


bkg = figure('Position',[100 50 size(v0,2)*v0Scale size(v0,1)*v0Scale]);
imagesc(v0)
switch type
    case 'floorOuter'
        titleLabel = 'floor outer corner';
        strs = {'BASE LEFT' 'BASE RIGHT' 'CHOICE RIGHT' 'CHOICE LEFT' };
    case 'floorStem'
        titleLabel = 'floor stem corner';
        strs = {'BASE LEFT' 'BASE RIGHT' 'CHOICE RIGHT' 'CHOICE LEFT' };
    case 'floorMid'
        titleLabel = 'floor outer MIDPOINT';
        strs = {'BASE LEFT' 'BASE RIGHT' 'CHOICE RIGHT' 'CHOICE LEFT' };
        inputcorners = [inputcorners; inputcorners(1,:)];
end
for corn = 1:4
    title(['Click mase ' titleLabel ' for: ' strs{corn}])
    if strcmp(type,'floorMid')
        hold on; plot(inputcorners(1:4,1),inputcorners(1:4,2),'or','MarkerFaceColor','r')
        [Xnew, Ynew] = GetPerpendicular(inputcorners(corn:corn+1,1),inputcorners(corn:corn+1,2));
        hold on; plot(Xnew,Ynew,'-w')
    end
    [cx(corn), cy(corn)] = ginput(1);
    figure(bkg); imagesc(v0);
    hold on; plot(cx, cy, 'og','MarkerFaceColor','g')
end

%{
if flipX == 1
    cx = size(v0,2)-cx;
end
if flipY == 1
    cy = size(v0,1)-cy;
end
%}

close(bkg)
end
%%%%%%%%%%%%%%%%
function [Xnew, Ynew] = GetPerpendicular(pointsX, pointsY)
halfX = mean(pointsX);
halfY = mean(pointsY);
Xnew = halfX + (halfY-min(pointsY))*[-1 1];
Ynew = halfY + (halfX-min(pointsX))*[-1 1];
%slopeO = (pointsY(1) - pointsY(2)) / (pointsX(1) - pointsX(2));
%slopeNew = -1/slopeO;
%Xnew = halfY - min(pointsY); Xnew = Xnew*[1 -1] + halfX;
%Ynew = halfX - min(pointsX); Ynew = Ynew*[1 -1] + halfY;
end
%%%%%%%%%%%%%%%%
function [newCorners] = ArrangeBaseAnchors(v0,floorCorners, RoomStr, flipX, flipY, barrierX, barrierY)
%order 'BASE LEFT' 'BASE RIGHT' 'CHOICE RIGHT' 'CHOICE LEFT' 
v0Scale = 1.5;
if strcmp(RoomStr,'201a - 2015')
    cx = floorCorners(:,1);
    cy = floorCorners(:,2);

    vis = figure('Position',[100 50 size(v0,2)*v0Scale size(v0,1)*v0Scale]);
    PlotCorners(vis,v0,cx,cy); title('Original Anchors')

    %Reorient image and anchor points
    %if cx(3) < cx(2) && cx(4) < cx(1)
    if flipX==1
        disp('Flipping maze so that Start > Choice goes L > R')
        cxNew = size(v0,2) - cx;
        v0New = fliplr(v0);
    else
        cxNew = cx;
        v0New = v0;
    end
    PlotCorners(vis,v0New,cxNew,cy); title('LR adjusted')

    %if cy(1) > cy(2) && cy(4) > cy(3) %If right is above left
    if flipY == 1
        disp('Flipping maze so right turn is bottom, left turn is top')
        cyNew = size(v0,1) - cy;
        v0New = flipud(v0New);
    else
        cyNew = cy;
        %v0new = v0new;
    end
    PlotCorners(vis,v0New,cxNew,cyNew);

    %Find closest to real scale
    %imMidX = size(v0,2)/2; imMidY = size(v0,1)/2;
    %redge = mean([cyNew(2) cyNew(3)]); ledge = mean([cyNew(1) cyNew(4)]);
    %bedge = mean([cxNew(1) cxNew(2)]); tedge = mean([cxNew(3) cxNew(4)]);
    %longmiddle = mean([mean([cyNew(1) cyNew(2)]) mean([cyNew(3) cyNew(4)])]);
    %shortmiddle = mean([mean([cxNew(2) cxNew(3)]) mean([cxNew(1) cxNew(4)])]);
    %min([abs([ledge redge longmiddle] - imMidY) abs([bedge tedge shortmiddle] - imMidX)]);

    %Calling left edge real scale
    %Adjust all left edge to straight
    pos = [1 4 8];
    [~,idx] = min([cyNew(pos)]-imMidY);
    cyNew(pos(pos~=pos(idx))) = cyNew(pos(idx)); %Straighten left edge

    cxNew([2 5]) = cxNew(1);  %Straighten bottom edge
    cxNew([3 7]) = cxNew(4); %Straighen top edge
    cxNew(6) = cxNew(8);    %Straighten right edge
    cyNew([2 3]) = cyNew(6); %Straighten right edge
    cyNew([5 7]) = mean(cyNew([6 8]));

    cyNew([2 3 6]) = cyNew(5) + (cyNew(5) - cyNew(1));
    %plot(cxNew(posp),cyNew(posp),'om','MarkerFaceColor','m')
    %patch(cxNew(1:4),cyNew(1:4),'o','FaceAlpha',0.4)

    cyNew = cyNew - cyNew(5); %Shift to y = 0;
    
    cyNew = -1*cyNew; %Left turn is positive, right turn is negative

    newCorners = [cxNew cyNew];
    
    tform = fitgeotrans(floorCorners,newCorners,'affine');
    [newBarX,newBarY] = transformPointsForward(tform,barrierX,barrierY);
    
    cxNew = cxNew - newBarX; %Shift left to put barrier at x = 0
    
    newCorners = [cxNew cyNew];
else
    disp('Sorry, only built out for DNMP imaging for now')
    newCorners = [];
end

end
%%%%%%%%
function PlotCorners(handle,v0,cx,cy)
figure(handle)
imagesc(v0); hold on
plot(cx(1:4),cy(1:4),'og','MarkerFaceColor','g')
%plot(cx(5:8),cy(5:8),'ob','MarkerFaceColor','b')
plot(cx(9:12),cy(9:12),'or','MarkerFaceColor','r')
hold off
end