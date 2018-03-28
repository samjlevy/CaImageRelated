function AlignPositions2_SL(anchor_path, align_paths, RoomStr)
%This function is to do a really good alignment of positions, both within
%and across animals
if strcmp(class(align_paths),'cell') == 0
    align_paths = {align_paths};
end

scaleFactor = 0.6246;
Pix2Cm = Pix2CMlist (RoomStr);
SR=20;
v0Scale = 1.75;
DNMPscale = (25 + 3/16) / (11 + 3/8); %inches
DNMPdims = [25+3/16 11+3/8]*2.54;



if exist(fullfile(anchor_path,'Pos_anchor_ideal.mat'),'file')~=2
    if exist(fullfile(anchor_path,'Pos_anchor.mat'),'file')~=2
        disp('No pos base anchor, making now')
        load(fullfile(anchor_path,'Pos.mat'),'v0')
        [floorCorners,barrierX,barrierY,flipX,flipY] = MakePosAnchor(anchor_path,v0Scale);
        floorCorners = double(floorCorners);
        
        save(fullfile(anchor_path,'Pos_anchor.mat'),'floorCorners','barrierX','barrierY','flipX','flipY')
    else
        disp('Found pos base anchor')
        load(fullfile(anchor_path,'Pos_anchor.mat'))
    end
    disp('Did not find pos_anchor_ideal, making now')
    [newCorners] = ArrangeBaseAnchors(v0,floorCorners, RoomStr, flipX, flipY, barrierX, barrierY, DNMPdims);
    %Left turn is positive, right turn is negative
    xAnchor = double(newCorners(:,1));
    yAnchor = double(newCorners(:,2));
    
    %{
    tform = fitgeotrans(floorCorners,[xAnchor yAnchor],'affine');
    [xADJ, yADJ] = transformPointsForward(tform,xAVI,yAVI);
    figure; plot(newCorners(:,1),newCorners(:,2),'og','MarkerFaceColor','g')
    hold on
    plot(newCorners(1,1),newCorners(1,2),'*r') %base left corner
    plot(xADJ,yADJ,'.')
    %}
    
    save(fullfile(anchor_path,'Pos_anchor_ideal.mat'),'xAnchor','yAnchor')
else
    load(fullfile(anchor_path,'Pos_anchor_ideal.mat'))
end


for pathI = 1:length(align_paths)
    if exist(fullfile(align_paths{pathI},'Pos_align.mat'),'file')~=2
        disp(['Working on alignment for ' align_paths{pathI}])
        if exist(fullfile(align_paths{pathI},'Pos_anchor.mat'),'file')~=2
            [floorCorners,barrierX,barrierY,flipX,flipY,v0Dims] = MakePosAnchor(align_paths{pathI},v0Scale);
            %floorCorners = double(floorCorners)
            save(fullfile(align_paths{pathI},'Pos_anchor.mat'),'floorCorners','barrierX',...
                'barrierY','flipX','flipY','v0Dims')
        else
            load(fullfile(align_paths{pathI},'Pos_anchor.mat'))
        end
        load(fullfile(align_paths{pathI},'Pos_brain.mat'))

        try
            tform = fitgeotrans(floorCorners,[xAnchor yAnchor],'affine');
        catch 
            keyboard
        end
        
        [x_adj_cm, y_adj_cm] = transformPointsForward(tform,xBrain,yBrain);

        PSAbool = PSAboolAdjusted;

        %Speed for each
        dx = diff(x_adj_cm);
        dy = diff(y_adj_cm);
        speed = hypot(dx,dy)*SR;

        %Holdover overhead (probably)
        xmax = max(x_adj_cm);
        xmin = min(x_adj_cm);
        ymax = max(y_adj_cm);
        ymin = min(y_adj_cm);

        save(fullfile(align_paths{pathI},'Pos_align.mat'),'x_adj_cm','y_adj_cm',...
            'PSAbool','xmin','xmax','ymin','ymax','speed','PSAbool')
        disp('done')
    else 
        disp(['file ' align_paths{pathI} ' already registered'])
    end
end
   
end
%%%%%%%%%%%%%%%%%%%%
function [floorCorners,barrierX,barrierY,flipX,flipY,v0Dims] = MakePosAnchor(sess_path,v0Scale)
isDone=0;
while isDone == 0
    %Orient positions
    [v0,xAVI,yAVI, flipX, flipY] = OrientBackgroundPos(sess_path);

    %Get relevant corners
    [floorCorners(1:4,1), floorCorners(1:4,2)] = GetCorners(v0,'floorOuter',[]);
    %floorCorners(1:4,1:2) = [cx cy];
    [floorCorners(5:8,1), floorCorners(5:8,2)]=GetCorners(v0,'floorMid',floorCorners(1:4,:));
    %floorCorners(5:8,1:2) = [cx cy];
    bkg = figure('Position',[100 50 size(v0,2)*v0Scale size(v0,1)*v0Scale]);
    imagesc(v0)
    title('Click middle of BARRIER at FLOOR')
    [barrierX,barrierY] = ginput(1);
    hold on
    title('Reference points right now')
    plot(floorCorners(:,1),floorCorners(:,2),'*g')
    plot(barrierX,barrierY,'.r')
    floorCorners = double(floorCorners);

    v0Dims = [size(v0,1) size(v0,2)];
    
    if flipX == 1; floorCorners(:,1) = v0Dims(2) - floorCorners(:,1); end
    if flipY == 1; floorCorners(:,2) = v0Dims(1) - floorCorners(:,2); end

    answer = questdlg('Are these anchors good?','Good anchors','Good','Redo','Good');
    if strcmp(answer,'Good'); isDone=1; elseif strcmp(answer,'Redo'); isDone=0; end
    close(bkg)
end

end
%%%%%%%%%%%%%%
function [v0,xAVI,yAVI, flipX, flipY] = OrientBackgroundPos(sessPath)
v0Scale = 1.75;
try
    load(fullfile(sessPath,'Pos.mat'),'v0')%,'xAVI','yAVI')
end
if ~exist('v0','var')
    cd(sessPath)
    [avi_filepath,~] = uigetfile('*.avi','Choose appropriate video:');
    obj = VideoReader(avi_filepath); aviSR = obj.FrameRate;
    h1 = implay(avi_filepath);
    bkgFrameNum = input('frame number of new v0 --->');
    close(h1)
    obj.CurrentTime = (bkgFrameNum-1)/obj.FrameRate;
    v0 = readFrame(obj);
end
load(fullfile(sessPath,'Pos.mat'),'xAVI','yAVI')

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
close(bkg)

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [cx, cy]=GetCorners(v0, ctype, inputcorners)
v0Scale = 1.75;
terminology = {'Base = Start/Delay end';...
               'Choice = Choice end';};


bkg = figure('Position',[100 50 size(v0,2)*v0Scale size(v0,1)*v0Scale]);
imagesc(v0)
switch ctype
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
    if strcmp(ctype,'floorMid')
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
%pointsX = inputcorners(corn:corn+1,1);
%pointsY = inputcorners(corn:corn+1,2);
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
function [newCorners] = ArrangeBaseAnchors(v0,floorCorners, RoomStr, flipX, flipY, barrierX, barrierY, envDims)
%order 'BASE LEFT' 'BASE RIGHT' 'CHOICE RIGHT' 'CHOICE LEFT' 
v0Scale = 1.75;
envScale = envDims(1)/envDims(2);
if strcmp(RoomStr,'201a - 2015')
    cx = floorCorners(:,1);
    cy = floorCorners(:,2);

    %vis = figure('Position',[100 50 size(v0,2)*v0Scale size(v0,1)*v0Scale]);
    %PlotCorners(vis,v0,cx,cy); title('Original Anchors')

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
    %PlotCorners(vis,v0New,cxNew,cy); title('LR adjusted')

    %if cy(1) > cy(2) && cy(4) > cy(3) %If right is above left
    if flipY == 1
        disp('Flipping maze so right turn is bottom, left turn is top')
        cyNew = size(v0,1) - cy;
        v0New = flipud(v0New);
    else
        cyNew = cy;
        %v0new = v0new;
    end
    %PlotCorners(vis,v0New,cxNew,cyNew);

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
    
    cxNew = cxNew - cxNew(1); %Shift so left edge is at x = 0
    
    %Old scaling to Pix2CM, arena size ratio
    %currentScale = (cxNew(3) - cxNew(2)) / (cyNew(1) - cyNew(2));
    %Scaling: should be current == envScale
    %cxNew([6 8]) = cxNew([6 8])*(envScale/currentScale); %Scale appropriate to real maze
    %cxNew([3 4 7]) = cxNew([3 4 7])*(envScale/currentScale);
    
    %New version, scale to env. cm limits (this version cheats, would need
    %to re-implement some stuff above to make it work better
    cxNew([6 8]) = envDims(1)/2;
    cxNew([3 4 7]) = envDims(1);
    cyNew([1 4 8]) = envDims(2)/2;
    cyNew([2 3 6]) = -envDims(2)/2;
    
    newCorners = [cxNew cyNew];
    tform = fitgeotrans(floorCorners,newCorners,'affine');
    [newBarX,newBarY] = transformPointsForward(tform,barrierX,barrierY);
    %newBarX = newBarX - cxNew(1);
    newBarY = cyNew(5); % 0
    
    cxNew = cxNew - newBarX; %Shift left to put barrier at x = 0
    newBarX = 0;
    
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