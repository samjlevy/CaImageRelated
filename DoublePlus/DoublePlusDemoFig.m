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

mazeWidth = max(mazeOutline(:,1)) - min(mazeOutline(:,1));
           
figSize = [150, 150];


mazeOutline = mazeOutline+75;


blankBkg = zeros(figSize);

inBound = poly2mask(mazeOutline(:,2),mazeOutline(:,1),figSize(1),figSize(2));
outBound = ~inBound;

%make striped background
barBkg = zeros(figSize(1),figSize(2),3);
barWidth = 15;
numBars = figSize(2)/barWidth;
barColors = [1 0 0;0 0 1];

for cc = 1:2
    for dd = 1:3
        bar3d{cc}(1,1,dd) = barColors(cc,dd);
    end
end

for bb = 1:numBars
    barBkg(1:figSize(1),(1:barWidth)+barWidth*(bb-1),1:3) = repmat(bar3d{rem(bb,2)+1},figSize(2),barWidth,1);
end


barBkg(:,:,br) = 


