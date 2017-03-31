function [ idx ] = findclosest2D ( x_points, y_points, qx, qy)
%x_points and y_points are the data you're looking for points in, qx and qy
%are your query points, idx is index in x_/y_points

for queryPoint = 1:length(qx)
    for checkThis=1:length(x_points)
        dist(checkThis) =...
            sqrt( (qx(queryPoint)-x_points(checkThis))^2 ...
                + (qy(queryPoint)-y_points(checkThis))^2 );
    end
    [~, idx(queryPoint)] = min(dist);
end    

end