function [distances,withinRad] = GetAllPtToPtDistances2(ptsXa,ptsYa,ptsXb,ptsYb,smoothRad)
%This is a version which lets you get all the distances between pts in two vectors
%With more than a few hundred points this gets to big to calculate
%{
distances = zeros(length(ptsX),length(ptsX));
 for ptJ = 1:length(ptsX)
     distances(ptJ,:) = cell2mat(arrayfun(@(x,y) hypot(ptsX(ptJ)-x,ptsY(ptJ)-y),...
         ptsX,ptsY,'UniformOutput',false));
 end
%}

ptsX = [ptsXa(:); ptsXb(:)];
ptsY = [ptsYa(:); ptsYb(:)];

distTemp = squareform(pdist([ptsX(:) ptsY(:)]));

colsGet = [length(ptsXa)+1 length(ptsXa)+length(ptsXb)];
distances = distTemp(1:length(ptsXa),colsGet(1):colsGet(2));

withinRad = [];
if any(smoothRad)
    inRad = distances<smoothRad;
    withinRad = sum(inRad,2)-1;
end

end