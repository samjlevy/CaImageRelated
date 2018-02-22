function [PlaceFieldData] =...
    PFsLinTrialbyTrial2(trialbytrial, xlims, cmperbin, minspeed, saveThis, saveName, trialReli, sameOccMap, doSmoothing)
%, TMap_gauss
%aboveThresh, 
    p = inputParser;
    p.addRequired('trialbytrial');
    p.addRequired('xlims');
    p.addRequired('cmperbin');
    p.addParameter('doSmoothing',true,@(x) islogical(x)); 
    p.addParameter('trialReli', , ); 
    p.addParameter('sameOccMap',true,@(x) islogical(x)); 
    p.addParameter('smooth',);
    p.addParameter('condPairs',1:length(trialbytrial));

sessions = unique(trialbytrial(1).sessID);
numSess = length(sessions);
numCells = length(trialbytrial(1).trialPSAbool{1,1});
numConds = length(trialbytrial);
xmin = xlims(1);
xmax = xlims(2);

if isempty(trialReli)
    trialReli = ones(numCells,numSess,numConds);
end
if size(trialReli,3) < 3
    trialReli(:,:,2:numConds) = trialReli;
end
%sessionUse = false(size(aboveThresh{1,1}));
%for ss = 1:numConds
%    sessionUse = sessionUse + aboveThresh{ss,1}(:,:);
%end
%sessionUse = sessionUse > 0;

OccMap = cell(numConds, numSess);
RunOccMap = cell(numConds, numSess);
xBin = cell(numConds, numSess);
TMap_unsmoothed = cell(numCells, numConds, numSess);
TCounts = cell(numCells, numConds, numSess);
TMap_gauss = cell(numCells, numConds, numSess);
TMap_zRates = cell(numCells, numConds, numSess);

Xrange = xmax-xmin;
nXBins = ceil(Xrange/cmperbin); 
xEdges = (0:nXBins)*cmperbin+xmin;
TMap_blank = zeros(1,nXBins);

p = ProgressBar(100);
update_points = round(linspace(1,numCells*numConds*numSess,101));
update_points = update_points(2:end);
updateInd = 0;

%To use condpairs, will have to gather all data for each entry in that
%pair. For example, all left trials would be a combination of conds 1 and
%3, all right of 2 and 4 ([1 3; 2 4]); leaving conds alone would be using the default,
%where condPairs is just [1; 2; 3; 4]
for condType = 1:4 %condPairI = 1:size(condPairs,1)
    for tSess = 1:numSess
        lapsUse = logical(trialbytrial(condType).sessID == sessions(tSess));
        
        if any(lapsUse)
            posX = [trialbytrial(condType).trialsX{lapsUse,1}];
            %posY = [trialbytrial(condType).trialsY{lapsUse,1}];

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

            %speed = dx*SR;
            %velocity = convtrim(speed,ones(1,2*20))./(2*20);

            good = true(1,length(posX));
            isrunning = good;                         %Running frames that were not excluded.
            %isrunning(velocity < minspeed) = false;

            [OccMap{condType,tSess},RunOccMap{condType,tSess},xBin{condType,tSess}]...
                        = MakeOccMapLin(posX,good,isrunning,xEdges);
        
            for cellI = 1:numCells
                if trialReli(cellI, tSess, condType) > 0
                    
                    spikeTs = [trialbytrial(condType).trialPSAbool{lapsUse,1}];
                    spikeTs = spikeTs(cellI,:);
                    
                    [TMap_unsmoothed{cellI,condType,tSess},TCounts{cellI,condType,tSess}]...%TMap_gauss{cellI,condType,tSess}
                        = MakePlacefieldLin(logical(spikeTs),posX,xEdges,RunOccMap{condType,tSess},...
                        'cmperbin',cmperbin,'smooth',doSmoothing); %false
               
                    %make tuning curves
                    %PlaceTuningCurveLin(trialbytrial, aboveThresh, nPerms, [xmin xmax], xEdges);

                    %Spatial information
                else
                    TMap_unsmoothed{cellI,condType,tSess} = TMap_blank; 
                    TCounts{cellI,condType,tSess} = 0;
                    %TMap_gauss{cellI,condType,tSess} = TMap_blank;

                end %any activity
            end %cellI
        end %any laps
    end %sess
    updateInd = updateInd + 1;
    if sum(update_points == updateInd)==1
        p.progress;
    end
end    
p.stop;

for cellI = 1:numCells
    for tSess = 1:numSess
        %Get z-scores of firing rates across conditions
        allRates = reshape([TMap_unsmoothed{cellI,:,tSess}]',nXBins,numConds)';
        zRates = zscore(allRates);
        TMap_zRates(cellI,1:numConds,tSess) = num2cell(zRates,2)';
        
        
        %meanRate = mean(allRates(:));
        %informationContent = sum(allOccMap.*(allRates(:)/meanRate).*log2(allRates(:)/meanRate))
       
        %Spatial information (Will's version)
        allOccMap = [RunOccMap{:,tSess}]';
        P_x = allOccMap/sum(allOccMap); %P_xi
         allCounts = [TCounts{cellI,:,tSess}]';
        P_k1 = sum(allCounts)/sum(allOccMap);
        P_k0 = 1 - P_k1;
        
        P_1x = allRates(:);
        P_0x = 1 - P_1x;
        
        I_k1 = P_1x.*log(P_1x./P_k1);
        I_k0 = P_0x.*log(P_0x./P_k0);
        
        Ipos = I_k1 + I_k0;
        
        MI = nansum(P_x.*Ipos);
    end
end



if saveThis==1
    if ~exist('saveName','var')
        saveName = 'PFsLin.mat';
    end
    savePath = saveName; 
    save(savePath,'OccMap','RunOccMap', 'xBin', 'TMap_unsmoothed', 'TCounts', 'TMap_zRates') %, 'TMap_gauss'
end
    
end