function [distances,withinRad] = GetAllPtToPtDistances(ptsX,ptsY,smoothRad)
% All to all distances 

%With more than a few hundred points this gets to big to calculate
%{
distances = zeros(length(ptsX),length(ptsX));
 for ptJ = 1:length(ptsX)
     distances(ptJ,:) = cell2mat(arrayfun(@(x,y) hypot(ptsX(ptJ)-x,ptsY(ptJ)-y),...
         ptsX,ptsY,'UniformOutput',false));
 end
%}

distances = squareform(pdist([ptsX(:) ptsY(:)]));

withinRad = [];
if any(smoothRad)
    inRad = distances<smoothRad;
    withinRad = sum(inRad,2)-1;
end

end