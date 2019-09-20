function allAngles = GetAllPtToPtAngles(pts)

nPts = size(pts,1);
for ptI = 1:size(pts,1)
    y0 = pts(ptI,2); x0 = pts(ptI,1);
    for ptJ = 1:nPts
        xx = pts(ptJ,:);
        allAngles(ptI,ptJ) = atan((xx(2)-y0)/(xx(1)-x0));
    end
    %bb=arrayfun(@(xx,yy) atan((yy-y0)/(xx-x0)),pts(:,1),pts(:,2),'UniformOutput',false);
end

end