function [OccMap, RunOccMap, xBin, TMap_unsmoothed, TCounts, TMap_gauss] =...
    PFsLinTrialbyTrialPooled(trialbytrial,aboveThresh, xlims, cmperbin, minspeed, saveThis, base_path)

numSess = size(aboveThresh{1,1},2);
numCells = length(trialbytrial(1).trialPSAbool{1,1});
numConds = length(trialbytrial);
xmin = xlims(1);
xmax = xlims(2);


sessionUse = false(size(aboveThresh{1,1}));
for ss = 1:numConds
    sessionUse = sessionUse + aboveThresh{ss,1}(:,:);
end
sessionUse = sessionUse > 0;

OccMap = cell(numCells, numConds);
RunOccMap = cell(numCells, numConds);
xBin = cell(numCells, numConds);
TMap_unsmoothed = cell(numCells, numConds);
TCounts = cell(numCells, numConds);
TMap_gauss = cell(numCells, numConds);
for cellI = 1:numCells
    for condType = 1:4    
        lapsUse = logical(sum(trialbytrial(condType).sessID == find(sessionUse(cellI,:)),2));
        
        if any(lapsUse)
        posX = [trialbytrial(condType).trialsX{lapsUse,1}];
        %posY = [trialbytrial(condType).trialsY{lapsUse,1}];
        spikeTs = [trialbytrial(condType).trialPSAbool{lapsUse,1}];
        spikeTs = spikeTs(cellI,:);
        
        Xrange = xmax-xmin;
        nXBins = ceil(Xrange/cmperbin); 
        xEdges = (0:nXBins)*cmperbin+xmin;
        
        %This is to correct problems with jumping from one trial to another
        lapLengths = cell2mat(cellfun(@length, {trialbytrial(condType).trialsX{lapsUse,1}},'UniformOutput',false));
        for ll = 1:length(lapLengths)
            trialEdges(ll) = sum(lapLengths(1:ll));
        end
        trialEdges = trialEdges(1:end-1);
       
        SR=20;
        dx = abs(diff(posX));
        dx(trialEdges) = dx(trialEdges-1);
        %dy = diff(posY);
        %speed = hypot(dx,dy)*SR;
        %{
        speed = dx*SR;
        velocity = convtrim(speed,ones(1,2*20))./(2*20);
        %} 
        good = true(1,length(posX));
        isrunning = good;                         %Running frames that were not excluded. 
        %isrunning(velocity < minspeed) = false;
    
        [OccMap{cellI,condType},RunOccMap{cellI,condType},xBin{cellI,condType}] = MakeOccMapLin(posX,good,isrunning,xEdges);
        [TMap_unsmoothed{cellI,condType},TCounts{cellI,condType},TMap_gauss{cellI,condType}] = ...
                MakePlacefieldLin(logical(spikeTs),posX,xEdges,RunOccMap{cellI,condType},...
                'cmperbin',cmperbin,'smooth',true);
            
            
            %{
            [OccMap,RunOccMap,xBin] = MakeOccMapLin(posX,good,isrunning,xEdges);
             [TMap_unsmoothed,TCounts,TMap_gauss] = ...
                MakePlacefieldLin(logical(spikeTs),posX,xEdges,RunOccMap,...
                'cmperbin',cmperbin,'smooth',true);

            %}
            
        %make tuning curves
        %PlaceTuningCurveLin(trialbytrial, aboveThresh, nPerms, [xmin xmax], xEdges);
        
        %Spatial information
        end
    end
end

if saveThis==1
    savePath = fullfile(base_path,'PFsLin.mat'); 
save(savePath,'OccMap','RunOccMap', 'xBin', 'TMap_unsmoothed', 'TCounts', 'TMap_gauss') 
end
    
end