function [spikePosX,spikePosY,bins] = placeFieldPolys1(trialbytrial,cellPlot,sessPlot,correctOnly,allowedFix,boundingTier,distRadius)

nCondsHere = length(trialbytrial);
for condI = 1:nCondsHere
    sessLapsHere = trialbytrial(condI).sessID == sessPlot;
    correctLapsUse = trialbytrial(condI).isCorrect == correctOnly;
    try
        fixedLapsUse = trialbytrial(condI).allowedFix == allowedFix;
    catch
        fixedLapsUse = true(size(correctLapsUse));
    end
    
    lapsUse = sessLapsHere & correctLapsUse & fixedLapsUse;
    lapsUseInds = find(lapsUse);
    
    lapNums = 1:length(lapsUseInds);
    %lapNums = trialbytrial(condI).lapNumber(lapsUse);
    lapNumsCell = mat2cell(lapNums(:),ones(length(lapNums),1),1);
    
    xPos = [trialbytrial(condI).trialsX{lapsUse}];
    yPos = [trialbytrial(condI).trialsY{lapsUse}];
    PSAhere = [trialbytrial(condI).trialPSAbool{lapsUse(:)'}];
    PSAhere = PSAhere(cellPlot,:);
    
    lapLengthsAll = cellfun(@length,trialbytrial(condI).trialsX);
    lapLengths = lapLengthsAll(lapsUse);
    lapLengthsCell = mat2cell(lapLengths(:),ones(length(lapLengths),1),1);
    lapsMarks = cellfun(@(x,y) y*ones(1,x),lapLengthsCell,lapNumsCell,'UniformOutput',false);
    
    lapMarker = [lapsMarks{:}];
        
    spikePosX{condI} = xPos(PSAhere);
    spikePosY{condI} = yPos(PSAhere);
    
    % This only works once we have individual fields...
    %{
    boundSpikesX = spikePosX;
    boundSpikesY = spikePosY;
    ptsIncluded = [];
    for btI = 1:boundingTier
        boundSpikesX(ptsIncluded) = [];
        boundSpikesY(ptsIncluded) = [];
        [ptsIncluded,area] = convhull(spikePosX,spikePosY);
    end
    %}
    
    %{
    markerColor = [0.4 0.4 0.4];
    figure; plot(xPos,yPos,'.','MarkerEdgeColor',markerColor,'MarkerFaceColor',markerColor)
    hold on
    plot(spikePosX,spikePosY,'.r')
    plot(spikePosX(ptsIncluded),spikePosY(ptsIncluded),'.g')
    plot(boundSpikesX,boundSpikesY,'.m')
    %}
    
    [distances,~] = GetAllPtToPtDistances(spikePosX{condI},spikePosY{condI},distRadius);
    withinRad = distances < distRadius;
    bins{condI} = conncomp(graph(withinRad));
    
    %{
    for ii = 1:length(unique(bins))
        plot(spikePosX(bins==ii),spikePosY(bins==ii),'.')
    end
    %}
    
end

end