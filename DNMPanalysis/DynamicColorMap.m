function [ptColors,ptsClose,outputClose] = DynamicColorMap(ptsX,ptsY,normX,normY,indexIntoNorm,radiusLimit,maxClose)
%Index into norm has to fit normX(indexIntoNorm) = ptsX
%Can leave normX and normY empty to not normlize by another occupancy vector

%Make them rows for easier
ptsX = ptsX(:)';
ptsY = ptsY(:)';

%Get distances: arrangement is row is anchor point, Y is to this pt
%{
for ptI = 1:length(ptsX)
    distances(ptI,:) = cell2mat(arrayfun(@(x,y) hypot(ptsX(ptI)-x,ptsY(ptI)-y),ptsX,ptsY,'UniformOutput',false));
end

maxDist = max(max(distances));
minDist = min(min(distances(distances>0)));
    
%radiusLimit = 1;
for ptI = 1:length(ptsX)
    ptsClose(ptI,1) = sum(distances(ptI,:) <= radiusLimit) - 1;
end
%}
[distances,ptsClose] = GetAllPtToPtDistances(ptsX,ptsY,radiusLimit);
if length(ptsX)==1 && isempty(distances)
    distances = 0;
    ptsClose = 1;
end

%Repeat for occupancy normalizing
if any(normX) && any(normY)
    %if any(indexIntoNorm)
    %    normX = normX(indexIntoNorm);
    %    normY = normY(indexIntoNorm);
    %end
    normX = normX(:)';
    normY = normY(:)';
    
    %{
    for ptJ = 1:length(normX)
        distancesNorm(ptJ,:) = cell2mat(arrayfun(@(x,y) hypot(normX(ptJ)-x,normY(ptJ)-y),normX,normY,'UniformOutput',false));
    end
    
    for ptJ = 1:length(normX)
        ptsCloseNorm(ptJ,1) = sum(distancesNorm(ptJ,:) <= radiusLimit,2) - 1;
    end
    %}
    
    [distancesNorm, ptsCloseNorm] = GetAllPtToPtDistances(normX,normY,radiusLimit);
    
    if any(indexIntoNorm)
        ptsCloseNorm = ptsCloseNorm(logical(indexIntoNorm));
    end
    
    
    %These should now be the same size
    ptsClose = ptsClose./ptsCloseNorm;
    
end

if isempty(maxClose)
    maxClose = max(ptsClose);
end
ptColors = rateColorMap(ptsClose,'jet',[0 maxClose]); % Was just max close...
outputClose = max(ptsClose);
%{
if isempty(maxClose)
    maxClose = max(ptsClose);
    %outputClose = maxClose;
end
minClose = min(ptsClose);

hh = figure;
cc = colormap(jet);
close(hh);

boundaries = linspace(minClose-0.00001,maxClose-0.00001,64);

ptColors = zeros(length(ptsX),3);
for bdStops = 1:64
    thesePts = ptsClose > boundaries(bdStops);
    ptColors(thesePts,:) = repmat(cc(bdStops,:),sum(thesePts),1);
end
%}
    
end
