function AlignPositionsBatch_SL(base_path, align_paths, RoomStr)
%This function is to do a really good alignment of positions, both within
%days and across
scaleFactor = 0.6246;
SR=20;

if ~exist(fullfile(base_path,'Pos_anchor.mat','file')
    [cx, cy]=GetCorners(base_path);
    [xAnchor, yAnchor] = ArrangeBaseAnchors(cx, cy);
else
    load(fullfile(base_path,'Pos_anchor.mat'))
end

allPaths = {base_path, align_paths{:}};

for thisPath = 1:length(allPaths)
   
    if ~exist(fullfile(allPaths{thisPath},'Pos_final.mat'),'file')
    sessPath = allPaths{thisPath};
    [cx, cy]=GetCorners(sessPath);
    
    load(fullfile(sessPath,'Pos_brain.mat'))%x and y come from here
    
    tform = fitgeotrans([cx' cy'],[xAnchor' yAnchor'],'affine');
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [cx, cy]=GetCorners(sessPath)
load(fullfile(sessPath,'Pos.mat'),'v0','xAVI','yAVI')

flipX = 0; flipY = 0;
bkg = figure('Position',[100 50 size(v0,2)*1.5 size(v0,1)*1.5]);
doneFlip = 0;
while doneFlip==0
figure(bkg); imagesc(v0)
hold on; plot(bkg.Children,xAVI,yAVI,'.'); hold off
isFlipped = questdlg('Is this right?','PosOrientation','Flip X','Flip Y','Fine','Fine');
switch isFlipped
    case 'Flip X'
        xAVI = size(v0,2) - xAVI;
        flipX = 1;
    case 'Flip Y'
        yAVI = size(v0,1) - yAVI;
        flipY = 1;
    case 'Fine'
        doneFlip = 1;
end
end

strs = {'Start Left' 'Start Right' 'Choice Left' 'Choice Right'};
for corn = 1:4
    bkg; title(['Click mase floor corner for: ' strs{corn}])
    [cx(corn), cy(corn)] = ginput(1);
    hold on
    plot(cx(corn), cy(corn), 'og','MarkerFaceColor','g')
end

if flipX == 1
    cx = size(v0,2)-cx;
end
if flipY == 1
    cy = size(v0,1)-cy;
end

end
%%%%%%%%%%%%%%%%
function [xAnchor, yAnchor] = ArrangeBaseAnchors(cx, cy)

if cx(3) < cx(1) || cx(4) < cx(2)
    disp('Flipping maze for Start > Choice goes L > R')
    %Xnew = size(v0,2) - xAVI;
    cxNew = size(v0,2) - cx;
    %v0new = fliplr(v0);
else
    %Xnew = xAVI;
    cxNew = cx;
    %v0new = v0;
end
%figure; imagesc(v0new); hold on; plot(Xnew,yAVI,'.'); plot(cxNew,cy,'og','MarkerFaceColor','g')

if cy(1) > cy(2) || cy(3) > cy(4) %If right is above left
    disp('Flipping maze so right is bottom, left is top')
    %Ynew = size(v0,1) - yAVI;
    cyNew = size(v0,1) - cy;
    %v0new = flipud(v0new);
else
    %Ynew = yAVI;
    cyNew = cy;
    %v0new = v0new;
end
%figure; imagesc(v0new); hold on; plot(Xnew,Ynew,'.'); plot(cxNew,cyNew,'og','MarkerFaceColor','g')

yAnchor([2 4]) = mean(cyNew([2 4]));
yAnchor([1 3]) = mean(cyNew([1 3]));
xAnchor([1 2]) = mean(cxNew([1 2]));
xAnchor([3 4]) = mean(cxNew([3 4]));

%To fix fisheyeing stuff
%{
%figure out arrangement 
if abs(xAnchor(1) - xAnchor(3)) > abs(yAnchor(1) - yAnchor(3))
    draw a dotted line orthogonal to their orientation, get a 5th and 6th
    anchor points along that line at the appropriate point at the maze
    bottom

%}
if ~exist(fullfile(base_path,'Pos_anchor.mat'),'file')
    disp('Did not find Pos_anchor.mat, saving now')
    save(fullfile(base_path,'Pos_anchor.mat'),'xAnchor','yAnchor')
end

end