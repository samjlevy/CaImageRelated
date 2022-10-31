function AlignImagingToTrackingForcedEqual(totalAviTime,DVTtime,xAVI,yAVI,brainData,destinationFile)
% This function is built to assume that the recording durations for nVista
% and CinePlex should have been equal, in spite of what their resulting
% data files actually say. We're grabbing the duration and timestamps from
% the AVI behavior recording

% brainData = PSAbool; assumed to be neurons x timee

nbFrames = size(brainData,2);

totalBrainTime = totalAviTime;

adjustedBrainTime = linspace(0,totalBrainTime,nbFrames);

TrackingLength = numel(DVTtime);

%{
if totalBrainTime > totalAviTime
    whichEndsFirst = 'tracking';
    brainTimeUse = [1 LastUsable];
    TrackingUse = [1 TrackingLength];
elseif totalAviTime > totalBrainTime
    whichEndsFirst = 'imaging';
    LastUsable = find(time >= adjustedBrainTime(end), 1, 'first');
    brainTimeUse = [1 nbFrames];
    TrackingUse = [1 LastUsable];
elseif totalBrainTime == totalAviTime
%}
    whichEndsFirst = 'same';
    brainTimeUse = [1 nbFrames];
    TrackingUse = [1 TrackingLength];
%end

brainTime = adjustedBrainTime;

xBrain = interp1( DVTtime(TrackingUse(1):TrackingUse(2)),...
                  xAVI(TrackingUse(1):TrackingUse(2)),...
                  brainTime(brainTimeUse(1):brainTimeUse(2)));
yBrain = interp1( DVTtime(TrackingUse(1):TrackingUse(2)),...
                  yAVI(TrackingUse(1):TrackingUse(2)),...
                  brainTime(brainTimeUse(1):brainTimeUse(2)));
              
brain_time = brainTime(brainTimeUse(1):brainTimeUse(2));

trackingTimeUse = DVTtime(TrackingUse(1):TrackingUse(2));
              
PSAboolUseIndices = brainTimeUse(1):brainTimeUse(2);
if ~isempty(brainData)
    PSAboolAdjusted = brainData(:,PSAboolUseIndices);
    save(destinationFile,'xBrain','yBrain','brain_time','brainTimeUse','TrackingUse','trackingTimeUse','whichEndsFirst','PSAboolUseIndices','PSAboolAdjusted','-v7.3')
else
    save(destinationFile,'xBrain','yBrain','brain_time','brainTimeUse','TrackingUse','trackingTimeUse','whichEndsFirst','PSAboolUseIndices','-v7.3')
end

end