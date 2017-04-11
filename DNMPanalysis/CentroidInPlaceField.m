function [isInPF, PFxBin, PFyBin, sloppy]=CentroidInPlaceField(centroid, placeField)

xYes = any(placeField,1); xMids = find(xYes);
yYes = any(placeField,1); yMids = find(yYes);
xYesEdges = xMids - 0.5;
xYesEdges = [xYesEdges xYesEdges(end)+1];
yYesEdges = yMids - 0.5;
yYesEdges = [yYesEdges yYesEdges(end)+1];

%is the point even in the ballpark?
if (centroid(1) >= min(xYesEdges) && centroid(1) <= max(xYesEdges))... 
    && (centroid(2) >= min(yYesEdges) && centroid(2) <= max(yYesEdges))
    disp('yea good')
    sloppy = 1;
else 
    disp('sorry bro')
    sloppy = 0;
end

if sloppy == 1
xLeftEdge = find(centroid(1) > xYesEdges,1,'Last');
xRightEdge = find(centroid(1) < xYesEdges,1,'First');
if xLeftEdge + 1 == xRightEdge
    PFxBin = xYesEdges(xLeftEdge) + 0.5;
else 
    %what?
end
   
yLeftEdge = find(centroid(2) > yYesEdges,1,'Last');
yRightEdge = find(centroid(2) < yYesEdges,1,'First');
if yLeftEdge + 1 == yRightEdge
    PFyBin = yYesEdges(yLeftEdge) + 0.5;
else 
    %what?
end

end

end