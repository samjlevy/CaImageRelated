SlidingPlaceField(posX, spikeTs, cmperbin, step)

posMin = 5;
gauss_std = 2.5;

if rem(Xrange/step,1) == 0 
    %Should be fine
end

edges = [xmin:step:(xmax-cmperbin); (xmin+cmperbin):step:xmax]';

%for edgePair = 1:size(edges,1)
%    OccMap(edgePair) = sum(posX>=edges(edgePair,1) & posX<=edges(edgePair,2));
%    NumSpikes(edgePair) = sum(posX(spikeTs)>=edges(edgePair,1) & posX(spikeTs)<=edges(edgePair,2));
%end

OccMap = sum( posX>=edges(:,1) & posX<=edges(:,2) ,2);
NumSpikes = sum( posX(spikeTs)>=edges(:,1) & posX(spikeTs)<=edges(:,2) ,2);

Tsum = sum(OccMap);

Tnew = NumSpikes./OccMap;

binsOver = cmperbin/step

gauss_std = (gauss_std/cmperbin)*binsOver; 
sm = fspecial('gaussian',round(8*gauss_std),gauss_std);
sm = sm(round(size(sm,1)/2),:);
        
%Smooth. 
Tnew_gauss = imfilter(Tnew,sm);
Tnew_gauss = Tnew_gauss.*Tsum./nansum(Tnew_gauss(:)); 
Tnew_gauss(OccMap<posMin) = NaN;        
