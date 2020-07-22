function allAngles = GetAllPtToPtAngles(pts)

nPts = size(pts,1);
allAngles = zeros(nPts,nPts);
%{
tic
for ptI = 1:size(pts,1)
    y0 = pts(ptI,2); 
    x0 = pts(ptI,1);
    %for ptJ = 1:nPts
    %    xx = pts(ptJ,:);
    %    allAngles(ptI,ptJ) = atan((xx(2)-y0)/(xx(1)-x0));
    %end
    allAngles(ptI,:) = cell2mat(arrayfun(@(xx,yy) atan2((yy-y0),(xx-x0)),pts(:,1),pts(:,2),'UniformOutput',false))';
    
    %aaa = atan2SL(pts(:,2)-y0,pts(:,1)-x0);
end
toc

aaa = zeros(nPts,nPts);
%}

xDiffs = pts(:,1) - pts(:,1)';
yDiffs = pts(:,2) - pts(:,2)';
[allAngles,~] = cart2pol(xDiffs,yDiffs);
allAngles = allAngles';

end