function [isInPF, PFxBin, PFyBin, sloppy]=CentroidInPlaceField(centroid, placeField,arenaSize)
%centroid x/y coordinate, placeField is PFpixels 
%bin1 = [0.5 1.5]
showplot=0;

PFxBin=[]; PFyBin=[];

xSize=arenaSize(1); ySize=arenaSize(2); 
thisField = zeros(xSize,ySize);
thisField(placeField) = 1;

xYes = any(thisField,1); 
yYes = any(thisField,2); 
xInds = find(xYes)-0.5; 
yInds = find(yYes)-0.5;
xYesEdges = [xInds xInds(end)+1];
yYesEdges = [yInds' yInds(end)+1];

%is the point even in the ballpark?
isInPF=0;
if (centroid(1) >= min(xYesEdges) && centroid(1) <= max(xYesEdges))... 
    && (centroid(2) >= min(yYesEdges) && centroid(2) <= max(yYesEdges))
    %disp('yea good')
    sloppy = 1;
else 
    %disp('sorry bro')
    sloppy = 0;
end

%This might do the same thing as above but more precisely
if sloppy == 1
    xLeftEdge = find(centroid(1) > xYesEdges,1,'Last');
    xRightEdge = find(centroid(1) <= xYesEdges,1,'First');
    if xLeftEdge + 1 == xRightEdge
        PFxBin = xYesEdges(xLeftEdge) + 0.5;
    else 
        %what?
    end
   
    yUpperEdge = find(centroid(2) > yYesEdges,1,'Last');
    yLowerEdge = find(centroid(2) <= yYesEdges,1,'First');
    if yUpperEdge + 1 == yLowerEdge
        PFyBin = yYesEdges(yUpperEdge) + 0.5;
    else 
        %what?
    end

    linearInd = sub2ind([xSize ySize], PFyBin, PFxBin);
    if sum(placeField==linearInd)==1
        isInPF=1;
    else
        isInPF=0;
    end
end

if showplot==1
figure; imagesc(thisField)
hold on
plot(centroid(1),centroid(2),'*r')
end

end