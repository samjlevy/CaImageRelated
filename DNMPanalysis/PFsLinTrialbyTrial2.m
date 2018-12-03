                function [TMap_unsmoothed, TMap_zRates, OccMap, RunOccMap, xBin, TCounts] =...
    PFsLinTrialbyTrial2(trialbytrial, xlims, cmperbin, minspeed, saveName, varargin)
%, TMap_gauss
%aboveThresh, 
    p = inputParser;
    %{
    p.addRequired('trialbytrial');
    p.addRequired('xlims');
    p.addRequired('cmperbin');
    p.addRequired('minspeed');
    %}
    p.addParameter('smooth',false,@(x) islogical(x)); 
    p.addParameter('trialReli',[]);  
    p.addParameter('condPairs',[1:length(trialbytrial)]');
    p.addParameter('dispProgress',true,@(x) islogical(x));
    p.addParameter('getZscore',true,@(x) islogical(x));
    %p.addParameter('saveName',[],@(x) ischar(x));
    %}
    %addRequired(p,'trialbytrial');
    %addRequired(p,'xlims');
    %addRequired(p,'cmperbin');
    %addRequired(p,'minspeed');
    %addParameter(p,'smooth',true,@(x) islogical(x)); 
    %addParameter(p,'trialReli',[]);  
    %addParameter(p,'condPairs',[1:length(trialbytrial)]');

    p.parse(varargin{:})
    
    smooth = p.Results.smooth;
    condPairs = p.Results.condPairs;
    trialReli = p.Results.trialReli;
    dispProgress = p.Results.dispProgress;
    getZscore = p.Results.getZscore;
    %saveName = p.Results.saveName;
    
sessions = unique(trialbytrial(1).sessID);
numSess = length(sessions);
numCells = length(trialbytrial(1).trialPSAbool{1,1});
%numConds = length(trialbytrial);
numConds = size(condPairs,1);
condsPerPair = size(condPairs,2);
xmin = xlims(1);
xmax = xlims(2);

if isempty(trialReli)
    trialReli = ones(numCells,numSess,length(trialbytrial));
end
if isempty(condPairs)
    condPairs = [1:length(trialbytrial)]';
end
if size(trialReli,3) < length(trialbytrial)
    trialReli(:,:,2:numConds) = trialReli;
end
saveThis = 1;
if isempty(saveName)
    saveThis = 0;
end
%sessionUse = false(size(aboveThresh{1,1}));
%for ss = 1:numConds
%    sessionUse = sessionUse + aboveThresh{ss,1}(:,:);
%end
%sessionUse = sessionUse > 0;

OccMap = cell(numConds, numSess);
RunOccMap = cell(numConds, numSess);
xBin = cell(numConds, numSess);
TMap_unsmoothed = cell(numCells, numSess, numConds);
TCounts = cell(numCells, numSess, numConds);
TMap_gauss = cell(numCells, numSess, numConds);
TMap_zRates = cell(numCells, numSess, numConds);

Xrange = xmax-xmin;
nXBins = ceil(Xrange/cmperbin); 
xEdges = (0:nXBins)*cmperbin+xmin;
TMap_blank = zeros(1,nXBins);

if dispProgress
p = ProgressBar(100);
end
update_points = round(linspace(1,numCells*numConds*numSess,101));
update_points = update_points(2:end);
updateInd = 0;

%To use condpairs, will have to gather all data for each entry in that
%pair. For example, all left trials would be a combination of conds 1 and
%3, all right of 2 and 4 ([1 3; 2 4]); leaving conds alone would be using the default,
%where condPairs is just [1; 2; 3; 4]
for condPairI = 1:size(condPairs,1) %condType = 1:4
    for tSess = 1:numSess
        condType = []; lapsUse = [];
        for cpCol = 1:condsPerPair
            condType{cpCol} = condPairs(condPairI,cpCol);
            lapsUse{cpCol} = logical(trialbytrial(condType{cpCol}).sessID == sessions(tSess));
        end
        goodLaps = cell2mat(cellfun(@any, lapsUse, 'UniformOutput', false));
        
        posX = []; posY = [];
        if any(goodLaps) %any(lapsUse)
        for cpcI = 1:condsPerPair
            %Get positions
            posX{cpcI} = [trialbytrial(condType{cpcI}).trialsX{lapsUse{cpcI},1}];
            posY{cpcI} = [trialbytrial(condType{cpcI}).trialsY{lapsUse{cpcI},1}];
            
            %Get speed
            %This is to correct problems with jumping from one trial to another when calculating velocity
            %{
            lapLengths = cell2mat(cellfun(@length, {trialbytrial(condType{cpcI}).trialsX{lapsUse{cpCol},1}},'UniformOutput',false));
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
            dx = abs(diff(posX{cpcI}));
            dx(trialEdges) = dx(trialEdges-1);
            %dy = diff(posY);
            %speed = hypot(dx,dy)*SR;

            %speed = dx*SR;
            %velocity = convtrim(speed,ones(1,2*20))./(2*20);
            %}
            good{cpcI} = true(1,length(posX{cpcI}));
            isrunning{cpcI} = good{cpcI};                         %Running frames that were not excluded.
            %isrunning(velocity < minspeed) = false;

         end %cond pair column I
            
            allX = [posX{:}];
            allY = [posY{:}];
            allGood = [good{:}];
            allIsrunning = [isrunning{:}];
         
            %Make an occupancy map
            [OccMap{condPairI,tSess},RunOccMap{condPairI,tSess},xBin{condPairI,tSess}]...
                        = MakeOccMapLin(allX,allGood,allIsrunning,xEdges);
                    
            for cellI = 1:numCells
                
                %if cellI == 37
                %    keyboard
                %end
                
                spikeTs = [];
                if sum(trialReli(cellI, tSess, [condType{:}])) > 0
                    %Get spike time indices
                    for cpcJ = 1:condsPerPair
                        spikeTs{cpcJ} = [trialbytrial(condType{cpcJ}).trialPSAbool{lapsUse{cpcJ},1}];
                        spikeTs{cpcJ} = spikeTs{cpcJ}(cellI,:);
                    end
                    allSpikeTs = logical([spikeTs{:}]);
                    
                    [TMap_unsmoothed{cellI,tSess,condPairI},TCounts{cellI,tSess,condPairI}]...%TMap_gauss{cellI,condType,tSess}
                        = MakePlacefieldLin(allSpikeTs,allX,xEdges,RunOccMap{condPairI,tSess},[],cmperbin,smooth); %false
                    
                    if any(TMap_unsmoothed{cellI,tSess,condPairI} > 1)
                        keyboard
                    end
               
                    %make tuning curves
                    %PlaceTuningCurveLin(trialbytrial, aboveThresh, nPerms, [xmin xmax], xEdges);

                    %Spatial information
                else
                    TMap_unsmoothed{cellI,tSess,condPairI} = TMap_blank; 
                    TCounts{cellI,tSess,condPairI} = TMap_blank;
                    %TMap_gauss{cellI,tSess,condType} = TMap_blank;

                end %any activity
                
                updateInd = updateInd + 1;
                if sum(update_points == updateInd)==1
                    if dispProgress
                        p.progress;
                    end
                end
            end %cellI
        end %any laps
    end %sess
end %condPair 
if dispProgress
p.stop;
end
%SpatialInformationSL(RunOccMap,TCounts)

%Get z-scores of firing rates across conditions
if getZscore
for cellI = 1:numCells
    for tSess = 1:numSess
        allRates = reshape([TMap_unsmoothed{cellI,tSess,:}]',nXBins,numConds)';
        zRates = zscore(allRates);
        TMap_zRates(cellI,tSess,1:numConds) = num2cell(zRates,2)';       
    end
end
end

if saveThis==1
    if ~exist('saveName','var')
        saveName = 'PFsLin.mat';
    end
    savePath = saveName; 
    save(savePath,'OccMap','RunOccMap', 'xBin', 'TMap_unsmoothed', 'TMap_gauss', 'TCounts', 'TMap_zRates', 'condPairs') %, 'TMap_gauss'
end
    
end