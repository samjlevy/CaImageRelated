function [mazeOneA,mazeOneB,mazeTwo] = DoublePlusDemoFig
[armBounds,~,~] = MakeDoublePlusBehaviorBounds;

mazeWidth = armBounds.north(2,1)*2; %abs(armBounds.north)==mazeWidth/2
mazeLength = armBounds.north(3,2)*2;

mazeOutline = [armBounds.north(1,:);... 
               armBounds.north(4,:);...
               armBounds.north(3,:);... 
               armBounds.north(2,:);...
               armBounds.east(4,:);...
               armBounds.east(3,:);...
               armBounds.east(2,:);...
               armBounds.south(3,:);...
               armBounds.south(4,:);...
               armBounds.south(1,:);...
               armBounds.west(3,:);...
               armBounds.west(4,:)];

%mazeOutline = round(mazeOutline);
           
figSize = [150, 150];

mazeBump = 75;
mazeOutline = mazeOutline+mazeBump;

%mazeWidth = max(mazeOutline(:,1)) - min(mazeOutline(:,1));

blankBkg = zeros(figSize);

inBound = poly2mask(mazeOutline(:,1),mazeOutline(:,2),figSize(1),figSize(2));
outBound = ~inBound;

%make striped background
rotBigSz = [250 250];
barBkg = zeros(rotBigSz(1),rotBigSz(2),3);
barWidth = 10;
numBars = rotBigSz(2)/barWidth;

%Arrange the colors
barColors = [1 0 1;0 1 1];
for cc = 1:2
    for dd = 1:3
        bar3d{cc}(1,1,dd) = barColors(cc,dd);
    end
end

%Plot the stripes
for bb = 1:numBars
    barBkg(1:rotBigSz(1),(1:barWidth)+barWidth*(bb-1),1:3) = repmat(bar3d{rem(bb,2)+1},rotBigSz(2),barWidth,1);
end

barBkg = imrotate(barBkg,-15);
barBkg = barBkg(76:76+figSize(1)-1,76:76+figSize(2)-1,:);

%Restrict to maze area
ptsZero = find(outBound);
for ee = 1:3
    imhere = barBkg(:,:,ee);
    imhere(ptsZero) = 1;
    barBkg(:,:,ee) = imhere;
end



%Make checker background
chSize = 8;
chColors = [0.8 0.8 0.8; 0.47 0.67 0.19];
for cc = 1:2; for dd = 1:3
        ch3d{cc}(1,1,dd) = chColors(cc,dd);
end; end

checkerBoard = zeros(figSize(1),figSize(2),3);
numChexX = ceil(figSize(1)/chSize);
numChexY = ceil(figSize(2)/chSize);
for chI = 1:numChexX
    for chJ = 1:numChexY
    	checkerBoard((1:chSize)+chSize*(chI-1),(1:chSize)+chSize*(chJ-1),1:3) = repmat(ch3d{rem(chI+chJ,2)+1},chSize,chSize,1);
    end
end
    
checkerBoard = checkerBoard(1:figSize(1),1:figSize(2),:);
%Restrict to maze area
ptsZero = find(outBound);
for ee = 1:3
    imhere = checkerBoard(:,:,ee);
    imhere(ptsZero) = 1;
    checkBkg(:,:,ee) = imhere;
end

arrowoffset = 5;
arrowedgeoffset = 5;
arrowends.sw = [mazeBump - mazeWidth/2 - arrowoffset, mazeBump + mazeLength/2 - arrowedgeoffset];
arrowends.se = [mazeBump + mazeWidth/2 + arrowoffset, mazeBump + mazeLength/2 - arrowedgeoffset];
arrowends.nw = [mazeBump - mazeWidth/2 - arrowoffset, mazeBump - mazeLength/2 + arrowedgeoffset];
arrowends.ne = [mazeBump + mazeWidth/2 + arrowoffset, mazeBump - mazeLength/2 + arrowedgeoffset];
arrowends.wn = [mazeBump - mazeLength/2 + arrowedgeoffset, mazeBump - mazeWidth/2 - arrowoffset];
arrowends.ws = [mazeBump - mazeLength/2 + arrowedgeoffset, mazeBump + mazeWidth/2 + arrowoffset];
arrowends.en = [mazeBump + mazeLength/2 - arrowedgeoffset, mazeBump - mazeWidth/2 - arrowoffset];
arrowends.es = [mazeBump + mazeLength/2 - arrowedgeoffset, mazeBump + mazeWidth/2 + arrowoffset];
arrowends.corner.nw = [mazeBump - mazeWidth/2 - arrowoffset, mazeBump - mazeWidth/2 - arrowoffset];
arrowends.corner.ne = [mazeBump + mazeWidth/2 + arrowoffset, mazeBump - mazeWidth/2 - arrowoffset];
arrowends.corner.sw = [mazeBump - mazeWidth/2 - arrowoffset, mazeBump + mazeWidth/2 + arrowoffset];
arrowends.corner.se = [mazeBump + mazeWidth/2 + arrowoffset, mazeBump + mazeWidth/2 + arrowoffset];

triangleHeight = 8;

mazeOneA = figure; imagesc(barBkg); hold on
plot([mazeOutline(:,1); mazeOutline(1,1)],[mazeOutline(:,2); mazeOutline(1,2)],'k','LineWidth',2)
%Turn Arrow N-W
plot([arrowends.nw(1) arrowends.corner.nw(1) arrowends.wn(1)],[arrowends.nw(2) arrowends.corner.nw(2) arrowends.wn(2)],'k','LineWidth',8)
patch([arrowends.wn(1) arrowends.wn(1) arrowends.wn(1)-triangleHeight],...
      [arrowends.wn(2)+triangleHeight/2 arrowends.wn(2)-triangleHeight/2 arrowends.wn(2)],'k')
%Turn Arrow S-E
plot([arrowends.se(1) arrowends.corner.se(1) arrowends.es(1)],[arrowends.se(2) arrowends.corner.se(2) arrowends.es(2)],'k','LineWidth',8)
patch([arrowends.es(1) arrowends.es(1) arrowends.es(1)+triangleHeight],...
      [arrowends.es(2)+triangleHeight/2 arrowends.es(2)-triangleHeight/2 arrowends.es(2)],'k')
axis equal
axis off
  
mazeOneB = figure; imagesc(barBkg); hold on
plot([mazeOutline(:,1); mazeOutline(1,1)],[mazeOutline(:,2); mazeOutline(1,2)],'k','LineWidth',2)
%Turn Arrow N-E
plot([arrowends.ne(1) arrowends.corner.ne(1) arrowends.en(1)],[arrowends.ne(2) arrowends.corner.ne(2) arrowends.en(2)],'k','LineWidth',8)
patch([arrowends.en(1) arrowends.en(1) arrowends.en(1)+triangleHeight],...
      [arrowends.en(2)+triangleHeight/2 arrowends.en(2)-triangleHeight/2 arrowends.en(2)],'k')
%Turn Arrow S-E
plot([arrowends.se(1) arrowends.corner.se(1) arrowends.es(1)],[arrowends.se(2) arrowends.corner.se(2) arrowends.es(2)],'k','LineWidth',8)
patch([arrowends.es(1) arrowends.es(1) arrowends.es(1)+triangleHeight],...
      [arrowends.es(2)+triangleHeight/2 arrowends.es(2)-triangleHeight/2 arrowends.es(2)],'k')
axis equal
axis off

mazeTwo = figure; imagesc(checkBkg); hold on
plot([mazeOutline(:,1); mazeOutline(1,1)],[mazeOutline(:,2); mazeOutline(1,2)],'k','LineWidth',2)
%Turn Arrow N-E
plot([arrowends.ne(1) arrowends.corner.ne(1) arrowends.en(1)],[arrowends.ne(2) arrowends.corner.ne(2) arrowends.en(2)],'k','LineWidth',8)
patch([arrowends.en(1) arrowends.en(1) arrowends.en(1)+triangleHeight],...
      [arrowends.en(2)+triangleHeight/2 arrowends.en(2)-triangleHeight/2 arrowends.en(2)],'k')
%Turn Arrow S-E
plot([arrowends.se(1) arrowends.corner.se(1) arrowends.es(1)],[arrowends.se(2) arrowends.corner.se(2) arrowends.es(2)],'k','LineWidth',8)
patch([arrowends.es(1) arrowends.es(1) arrowends.es(1)+triangleHeight],...
      [arrowends.es(2)+triangleHeight/2 arrowends.es(2)-triangleHeight/2 arrowends.es(2)],'k')
axis equal
axis off
  
end

