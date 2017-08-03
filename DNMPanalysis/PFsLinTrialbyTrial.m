function [OccMap, RunOccMap, xBin, TMap_unsmoothed, TCounts, TMap_gauss] = PFsLinTrialbyTrial(trialbytrial,aboveThresh,saveThis)

numSess = size(aboveThresh{1,1},2);
numCells = length(trialbytrial(1).trialPSAbool{1,1});
numConds = length(trialbytrial);
xmin = 25;
xmax = 60;
nPerms = 1000;
minspeed = 0;
cmperbin = 1;

sessionUse = false(size(aboveThresh{1,1}));
for ss = 1:numConds
    sessionUse = sessionUse + aboveThresh{1,ss}(:,:);
end
sessionUse = sessionUse > 0;

for cellI = 1:numCells
    for condType = 1:4    
        lapsUse = logical(sum(trialbytrial(condType).sessID == find(sessionUse(cellI,:)),2));
        
        if any(lapsUse)
        posX = [trialbytrial(condType).trialsX{lapsUse,1}];
        posY = [trialbytrial(condType).trialsY{lapsUse,1}];
        spikeTs = [trialbytrial(condType).trialPSAbool{lapsUse,1}];
        spikeTs = spikeTs(cellI,:);
        
        Xrange = xmax-xmin;
        nXBins = ceil(Xrange/cmperbin); 
        xEdges = (0:nXBins)*cmperbin+xmin;
    
        SR=20;
        dx = diff(posX);
        %dy = diff(posY);
        %speed = hypot(dx,dy)*SR;
        speed = dx*SR;
        velocity = convtrim(speed,ones(1,2*20))./(2*20);
        good = true(1,length(posX));
        isrunning = good;                                   %Running frames that were not excluded. 
        isrunning(velocity < minspeed) = false;
    
        [OccMap{cellI,condType},RunOccMap{cellI,condType},xBin{cellI,condType}] = MakeOccMapLin(posX,good,isrunning,xEdges);
        [TMap_unsmoothed{cellI,condType},TCounts{cellI,condType},TMap_gauss{cellI,condType}] = ...
                MakePlacefieldLin(logical(spikeTs),posX,xEdges,RunOccMap{cellI,condType},...
                'cmperbin',cmperbin,'smooth',true);

        %make tuning curves
        %PlaceTuningCurveLin(trialbytrial, aboveThresh, nPerms, [xmin xmax], xEdges);
        
        %Spatial information
        end
    end
end

if saveThis==1
save PFsLin.mat OccMap RunOccMap xBin TMap_unsmoothed TCounts TMap_gauss 
end
    
end