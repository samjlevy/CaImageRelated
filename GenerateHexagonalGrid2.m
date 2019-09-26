function [xPts,yPts] = GenerateHexagonalGrid2(center,spacing,sideLength)

% Get how high a point is vertically by half an equilateral triangle
horizOffset = spacing/2;
heightSpacing = sqrt(spacing^2-(horizOffset/2)^2);

%Get vertical spacing
upLim = ceil((sideLength/2)/heightSpacing);
vertPtsUp = center(2):heightSpacing:(heightSpacing*upLim);
downLim = -1*upLim;
vertPtsDown = (heightSpacing*downLim):heightSpacing:(center(2)-heightSpacing);

vertPts = sort([vertPtsDown(:); vertPtsUp(:)]);

%Get horizontal spacing
rightLim = ceil((sideLength/2)/spacing);
horizPtsRight = center(1):spacing:(rightLim*spacing);
leftLim = -1*rightLim;
horizPtsLeft = (leftLim*spacing):spacing:(center(1)-spacing);

horizPts = sort([horizPtsLeft(:); horizPtsRight(:)]);

%Make a grid
[X,Y] = meshgrid(horizPts,vertPts);

if rem(length(horizPts),2)~=1
    disp('Made a bad assumption')
end

%Offset alternate rows
horizRowsOffset = 2:2:length(vertPts)-1;
X(horizRowsOffset,:) = X(horizRowsOffset,:)+spacing/2;

%Set of pts to add
yVertAdd = vertPts(horizRowsOffset);
xHorizAdd = (horizPts(1)-spacing/2)*ones(length(horizRowsOffset),1);

xPts = [X(:); xHorizAdd];
yPts = [Y(:); yVertAdd];

end