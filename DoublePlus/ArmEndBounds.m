function [centerBound, armBound] = ArmEndBounds(dataBins,center,numAtEnd)

binMidsX = mean(dataBins.X,2);
binMidsY = mean(dataBins.Y,2);
centerDists = GetPtFromPtsDist(center,[binMidsX binMidsY]);
armTags = {'n','e','s','w'};

for armI = 1:length(armTags)
    theseBins = find(dataBins.labels == armTags{armI});
    [~,closestToMid] = min(centerDists(theseBins));
    nextToCenter(armI) = theseBins(closestToMid);
    
    %Top 2 farthest
    for ii = 1:numAtEnd
        [~,farFromMid] = max(centerDists(theseBins));
        farthestFromCenter(armI,ii) = theseBins(farFromMid);
        theseBins(farFromMid) = [];
    end
end


aa = round([dataBins.X(nextToCenter,:)],3);
bb = round([dataBins.Y(nextToCenter,:)],3);
cc = unique([aa(:) bb(:)],'rows');
k = convhull(cc(:,1),cc(:,2));
centerBound = cc(k,:);

for armI = 1:length(armTags)
    aa = round([dataBins.X(farthestFromCenter(armI,:),:)],3);
    bb = round([dataBins.Y(farthestFromCenter(armI,:),:)],3);
    cc = unique([aa(:) bb(:)],'rows');
    k = convhull(cc(:,1),cc(:,2));
    armBound{armI} = cc(k,:);
end

end