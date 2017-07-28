function [sortedReliability, aboveThresh] = TrialReliability(trialbytrial,thresh)

for condType = 1:length(trialbytrial)
   for sess = 1:max(trialbytrial(condType).sessID)
       hitsThisCond = [];
       thisLaps = find(trialbytrial(condType).sessID == sess);
       for lap = 1:length(thisLaps)
           thisLap = thisLaps(lap);
           hitsThisCond = [hitsThisCond,...
               any(trialbytrial(condType).trialPSAbool{thisLap},2)];
       end
       reliability = sum(hitsThisCond,2)/length(thisLaps);
       sortedReliability{condType}(:,sess) = reliability;
       aboveThresh{condType}(:,sess) = reliability >= thresh;
   end
end


end