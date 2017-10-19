function [OccMap, RunOccMap, xBin, TMap_unsmoothed, TCounts, TMap_gauss, LapIDs, Conditions] =...
    PFsLinTrialbyTrialSplit(trialbytrial,xlims, cmperbin, minspeed, saveThis, saveName, sortedSessionInds, randLaps)
%aboveThresh, 
%This version does not pool data across sessions.
%This version splits each condition (for each cell/day) into two halves for
%doing within condition comparisons. These are indicated by the 4th dimension
%Use randLaps to decide whether to just take even/odd or randomly pick which to use
sessions = unique(trialbytrial(1).sessID);
numSess = length(sessions);
numCells = length(trialbytrial(1).trialPSAbool{1,1});
numConds = length(trialbytrial);
xmin = xlims(1);
xmax = xlims(2);


%sessionUse = false(size(aboveThresh{1,1}));
%for ss = 1:numConds
%    sessionUse = sessionUse + aboveThresh{ss,1}(:,:);
%end
%sessionUse = sessionUse > 0;

OccMap = cell(numCells, numConds, numSess, 2);
RunOccMap = cell(numCells, numConds, numSess, 2);
xBin = cell(numCells, numConds, numSess, 2);
TMap_unsmoothed = cell(numCells, numConds, numSess, 2);
TCounts = cell(numCells, numConds, numSess, 2);
TMap_gauss = cell(numCells, numConds, numSess, 2);
LapIDs = cell(numCells, numConds, numSess);

p = ProgressBar(100);
update_points = round(linspace(1,numCells,101));
update_points = update_points(2:end);
for cellI = 1:numCells
    for condType = 1:4
        for tSess = 1:numSess
            
            if sortedSessionInds(cellI,tSess) > 0
                
            lapsUse = []; lapsSess = [];
            lapsSess = logical(trialbytrial(condType).sessID == sessions(tSess));
            lapsSess = find(lapsSess);
            
            if randLaps==1
                lapOrder = randperm(length(lapsSess));
                lapsSess = lapsSess(lapOrder);
            end
            
            lapsUse{1} = lapsSess(1:2:length(lapsSess));
            lapsUse{2} = lapsSess(2:2:length(lapsSess));
        
            LapIDs{cellI,condType,tSess} = lapsUse;
        for condHalf = 1:2
        if any(lapsUse{condHalf})
            
        
        posX = [trialbytrial(condType).trialsX{lapsUse{condHalf},1}];
        %posY = [trialbytrial(condType).trialsY{lapsUse{luI},1}];
        spikeTs = [trialbytrial(condType).trialPSAbool{lapsUse{condHalf},1}];
        spikeTs = spikeTs(cellI,:);
        
        Xrange = xmax-xmin;
        nXBins = ceil(Xrange/cmperbin); 
        xEdges = (0:nXBins)*cmperbin+xmin;
        
        %This is to correct problems with jumping from one trial to another
        lapLengths =...
            cell2mat(cellfun(@length, {trialbytrial(condType).trialsX{lapsUse{condHalf},1}},'UniformOutput',false));
        trialEdges = [];
        for ll = 1:length(lapLengths)-1
            trialEdges(ll) = sum(lapLengths(1:ll));
        end
        %trialEdges = trialEdges(1:end-1);
       
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
    
        [OccMap{cellI,condType,tSess,condHalf},RunOccMap{cellI,condType,tSess,condHalf},xBin{cellI,condType,tSess,condHalf}]...
            = MakeOccMapLin(posX,good,isrunning,xEdges);
        [TMap_unsmoothed{cellI,condType,tSess,condHalf},TCounts{cellI,condType,tSess,condHalf},...
            TMap_gauss{cellI,condType,tSess,condHalf}]...
            = MakePlacefieldLin(logical(spikeTs),posX,xEdges,RunOccMap{cellI,condType,tSess,condHalf},...
                'cmperbin',cmperbin,'smooth',true);
            
        %Spatial information
        
        end
        end %if any laps
        end %cond half
        end %tSess
        Conditions{condType} = trialbytrial(condType).name;
    end
    if sum(update_points == cellI)==1
        p.progress;
    end
end
p.stop;

if saveThis==1
    if ~exist('saveName','var')
        saveName = 'PFsLin.mat';
    end
    savePath = saveName; 
    try
    save(savePath,'OccMap','RunOccMap', 'xBin', 'TMap_unsmoothed', 'TCounts', 'TMap_gauss', 'LapIDs') 
    catch
        disp('not a valid savename. What now?')
        keyboard
    end
end
    
end