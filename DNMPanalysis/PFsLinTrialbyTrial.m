function [OccMap, RunOccMap, xBin, TMap_unsmoothed, TCounts, TMap_gauss] =...
    PFsLinTrialbyTrial(trialbytrial,xlims, cmperbin, minspeed, saveThis, saveName, sortedSessionInds)
%aboveThresh, 
%Thia version does not pool data across sessions.
sessions = unique(trialbytrial(1).sessID);
numSess = length(sessions);
numCells = length(trialbytrial(1).trialPSAbool{1,1});
numConds = length(trialbytrial);
xmin = xlims(1);
xmax = xlims(2);

if isempty(sortedSessionInds)
    sortedSessionInds = ones(numCells,numSess);
end
%sessionUse = false(size(aboveThresh{1,1}));
%for ss = 1:numConds
%    sessionUse = sessionUse + aboveThresh{ss,1}(:,:);
%end
%sessionUse = sessionUse > 0;

OccMap = cell(numCells, numConds);
RunOccMap = cell(numCells, numConds);
xBin = cell(numCells, numConds);
TMap_unsmoothed = cell(numCells, numConds);
TCounts = cell(numCells, numConds);
TMap_gauss = cell(numCells, numConds);

Xrange = xmax-xmin;
nXBins = ceil(Xrange/cmperbin); 
xEdges = (0:nXBins)*cmperbin+xmin;
TMap_blank = zeros(1,nXBins);

p = ProgressBar(100);
update_points = round(linspace(1,numCells,101));
update_points = update_points(2:end);
%update_inc = ceil(numCells/100);
%update_points = update_inc:update_inc:numCells;
%if length(update_points)==99; update_points(100) = numCells; end
for cellI = 1:numCells
    for condType = 1:4
        for tSess = 1:numSess
        
        if sortedSessionInds(cellI,tSess) > 0
            lapsUse = logical(trialbytrial(condType).sessID == sessions(tSess));
        
            if any(lapsUse)
            posX = [trialbytrial(condType).trialsX{lapsUse,1}];
            %posY = [trialbytrial(condType).trialsY{lapsUse,1}];
            spikeTs = [trialbytrial(condType).trialPSAbool{lapsUse,1}];
            spikeTs = spikeTs(cellI,:);



            %This is to correct problems with jumping from one trial to another
            lapLengths = cell2mat(cellfun(@length, {trialbytrial(condType).trialsX{lapsUse,1}},'UniformOutput',false));
            trialEdges = [];
            for ll = 1:length(lapLengths)-1
                trialEdges(ll) = sum(lapLengths(1:ll));
            end
            %trialEdges = trialEdges(1:end-1);
            if any(trialEdges==0)
                disp(['found a bad trial, condition:' num2str(condType) ', sess ' num2str(tSess)])
            end
            trialEdges(trialEdges==0) = [];

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

            [OccMap{cellI,condType,tSess},RunOccMap{cellI,condType,tSess},xBin{cellI,condType,tSess}]...
                = MakeOccMapLin(posX,good,isrunning,xEdges);
            [TMap_unsmoothed{cellI,condType,tSess},TCounts{cellI,condType,tSess},TMap_gauss{cellI,condType,tSess}]...
                = MakePlacefieldLin(logical(spikeTs),posX,xEdges,RunOccMap{cellI,condType,tSess},...
                    'cmperbin',cmperbin,'smooth',true);
            %{
                %Test    
                [OccMap,RunOccMap,xBin]...
                = MakeOccMapLin(posX,good,isrunning,xEdges);
            [unsmoothed,Counts,gauss]...
                = MakePlacefieldLin(logical(spikeTs),posX,xEdges,RunOccMap,...
                    'cmperbin',cmperbin,'smooth',true);
            %}

                %{
                [OccMap,RunOccMap,xBin] = MakeOccMapLin(posX,good,isrunning,xEdges);
                 [TMap_unsmoothed,TCounts,TMap_gauss] = ...
                    MakePlacefieldLin(logical(spikeTs),posX,xEdges,RunOccMap,...
                    'cmperbin',cmperbin,'smooth',true);

                %}

            %make tuning curves
            %PlaceTuningCurveLin(trialbytrial, aboveThresh, nPerms, [xmin xmax], xEdges);

            %Spatial information
            else
                TMap_unsmoothed{cellI,condType,tSess} = TMap_blank; 
                TCounts{cellI,condType,tSess} = 0;
                TMap_gauss{cellI,condType,tSess} = TMap_blank;

            end %any laps
        else
            TMap_unsmoothed{cellI,condType,tSess} = TMap_blank; 
            TCounts{cellI,condType,tSess} = 0;
            TMap_gauss{cellI,condType,tSess} = TMap_blank;
        end %use this sess
        end
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
    save(savePath,'OccMap','RunOccMap', 'xBin', 'TMap_unsmoothed', 'TCounts', 'TMap_gauss') 
end
    
end