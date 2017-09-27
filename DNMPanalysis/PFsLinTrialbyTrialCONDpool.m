function [OccMap, RunOccMap, xBin, TMap_unsmoothed, TCounts, TMap_gauss] =...
    PFsLinTrialbyTrialCONDpool(trialbytrial,xlims, cmperbin, minspeed, saveThis, base_path, Conds)
%aboveThresh, 
%Thia version does not pool data across sessions.
sessions = unique(trialbytrial(1).sessID);
numSess = length(sessions);
numCells = length(trialbytrial(1).trialPSAbool{1,1});
numConds = length(trialbytrial);
xmin = xlims(1);
xmax = xlims(2);

[Conds] = GetTBTconds(trialbytrial);

%sessionUse = false(size(aboveThresh{1,1}));
%for ss = 1:numConds
%    sessionUse = sessionUse + aboveThresh{ss,1}(:,:);
%end
%sessionUse = sessionUse > 0;

OccMap = cell(numCells, numConds, numSess);
RunOccMap = cell(numCells, numConds, numSess);
xBin = cell(numCells, numConds, numSess);
TMap_unsmoothed = cell(numCells, numConds, numSess);
TCounts = cell(numCells, numConds, numSess);
TMap_gauss = cell(numCells, numConds, numSess);

p = ProgressBar(100);
update_points = round(linspace(1,numCells,101));
update_points = update_points(2:end);

ss = fieldnames(Conds);
for cellI = 1:numCells
    for condType = 1:4
        for tSess = 1:numSess
            lapsUseA = logical(trialbytrial(Conds.(ss{condType})(1)).sessID == sessions(tSess));
            lapsUseB = logical(trialbytrial(Conds.(ss{condType})(2)).sessID == sessions(tSess));
        if any(lapsUseA) || any(lapsUseB)  
            
        posXA = [trialbytrial(Conds.(ss{condType})(1)).trialsX{lapsUseA,1}];
        %posYA = [trialbytrial(Conds.(ss{condType})(1)).trialsY{lapsUseA,1}];
        spikeTsA = [trialbytrial(Conds.(ss{condType})(1)).trialPSAbool{lapsUseA,1}];
        spikeTsA = spikeTsA(cellI,:);
        
        posXB = [trialbytrial(Conds.(ss{condType})(2)).trialsX{lapsUseB,1}];
        %posYB = [trialbytrial(Conds.(ss{condType})(2)).trialsY{lapsUseB,1}];
        spikeTsB = [trialbytrial(Conds.(ss{condType})(2)).trialPSAbool{lapsUseB,1}];
        spikeTsB = spikeTsB(cellI,:);
        
        posX = [posXA posXB];
        %posY = [posYA posYB];
        spikeTs = [spikeTsA spikeTsB];
        
        Xrange = xmax-xmin;
        nXBins = ceil(Xrange/cmperbin); 
        xEdges = (0:nXBins)*cmperbin+xmin;
        
        %This is to correct problems with jumping from one trial to another
        lapLengthsA = cell2mat(cellfun(@length, {trialbytrial(Conds.(ss{condType})(1)).trialsX{lapsUseA,1}},...
            'UniformOutput',false));
        lapLengthsB = cell2mat(cellfun(@length, {trialbytrial(Conds.(ss{condType})(2)).trialsX{lapsUseB,1}},...
            'UniformOutput',false));
        lapLengths = [lapLengthsA lapLengthsB];
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
    
        [OccMap{cellI,condType,tSess},RunOccMap{cellI,condType,tSess},xBin{cellI,condType,tSess}]...
            = MakeOccMapLin(posX,good,isrunning,xEdges);
        [TMap_unsmoothed{cellI,condType,tSess},TCounts{cellI,condType,tSess},TMap_gauss{cellI,condType,tSess}]...
            = MakePlacefieldLin(logical(spikeTs),posX,xEdges,RunOccMap{cellI,condType,tSess},...
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
    if sum(update_points == cellI)==1
        p.progress;
    end
end
p.stop;

if saveThis==1
    savePath = fullfile(base_path,'PFsLinPOOLED.mat'); 
save(savePath,'OccMap','RunOccMap', 'xBin', 'TMap_unsmoothed', 'TCounts', 'TMap_gauss') 
end
    
end