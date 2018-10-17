function [TMap_unsmoothed, TMap_gauss, TMap_zRates, OccMap, RunOccMap, xBin, TCounts] =...
    PFsLinTBTdoublePlus(trialbytrial, binEdges, minspeed, saveName, varargin)
%This is specialized to run with the double plus data format. 
%All TMaps get return in bins arranged from center outwards

    p = inputParser;

    p.addParameter('smth',false,@(x) islogical(x)); 
    p.addParameter('trialReli',[]);  
    %p.addParameter('condPairs',[1:length(trialbytrial)]');
    p.addParameter('dispProgress',true,@(x) islogical(x));
    p.addParameter('getZscore',true,@(x) islogical(x));

    p.parse(varargin{:})
    
    smth = p.Results.smth;
    %condPairs = p.Results.condPairs;
    trialReli = p.Results.trialReli;
    dispProgress = p.Results.dispProgress;
    getZscore = p.Results.getZscore;
    
  
armAlignment = GetDoublePlusArmAlignment;

sessions = unique(trialbytrial(1).sessID);
numSess = length(sessions);
numCells = length(trialbytrial(1).trialPSAbool{1,1});
numConds = 4;

if isempty(trialReli)
    trialReli = ones(numCells,numSess,length(trialbytrial));
end
if size(trialReli,3) < length(trialbytrial)
    trialReli(:,:,2:numConds) = trialReli;
end

saveThis = 1;
if isempty(saveName)
    saveThis = 0;
end

OccMap = cell(numConds, numSess);
RunOccMap = cell(numConds, numSess);
xBin = cell(numConds, numSess);
TMap_unsmoothed = cell(numCells, numSess, numConds);
TCounts = cell(numCells, numSess, numConds);
TMap_gauss = cell(numCells, numSess, numConds);
TMap_zRates = cell(numCells, numSess, numConds);

binEdges = sort(binEdges,'ascend');
numBins = length(binEdges)-1;
TMap_blank = zeros(1,numBins);
cmperbin = mean(abs(diff(binEdges)));

%if dispProgress
%p = ProgressBar(numCells*numConds*numSess);
%end

for condI = 1:numConds
    for sessI = 1:numSess
        lapsUse = logical(trialbytrial(condI).sessID == sessions(sessI));
    
        if any(lapsUse)
        
        posX = [trialbytrial(condI).trialsX{lapsUse,1}];
        posY = [trialbytrial(condI).trialsY{lapsUse,1}];
        
        %allX = [posX{:}];
        %allY = [posY{:}];
        switch armAlignment.(trialbytrial(condI).name){1}
            case 'Y'
                posUse = posY;
            case 'X'
                posUse = posX;
        end
          
        
        %deal with veloity
        good = true(1,length(posX));
        isrunning = good;                         %Running frames that were not excluded.
        %isrunning(velocity < minspeed) = false;
         
        linearEdges = binEdges*armAlignment.(trialbytrial(condI).name){2};
        linearEdges =  sort(linearEdges,'ascend');
        
        %Make an occupancy map
        [OccMap{condI,sessI},RunOccMap{condI,sessI},xBin{condI,sessI}]...
            = MakeOccMapLin(posUse,good,isrunning,linearEdges);
            
        %Get spiking
        lapsSpiking = logical([trialbytrial(condI).trialPSAbool{lapsUse,1}]);
        
        cellSpiking = mat2cell(lapsSpiking,ones(numCells,1),size(lapsSpiking,2));
        spikePos = cellfun(@(x) posUse(x),cellSpiking,'UniformOutput',false);
        spikeCounts = cellfun(@(x) histcounts(x,linearEdges),spikePos,'UniformOutput',false);
        TMap_unsmoothed(1:numCells,sessI,condI) = cellfun(@(x) x./RunOccMap{condI,sessI},spikeCounts,'UniformOutput',false);
        
        
        if smth
            Tsum = cellfun(@sum,spikeCounts,'UniformOutput',false);


            %Make smoothing kernel.
            gauss_std = 2.5;
            gauss_std = gauss_std/cmperbin; 
            sm = fspecial('gaussian',round(8*gauss_std),gauss_std);
            sm = sm(round(size(sm,1)/2),:);

            %Smooth. 
            TMap_gauss(1:numCells,sessI,condI) = cellfun(@(x) imfilter(x,sm),...
                        [TMap_unsmoothed(:,sessI,condI)],'UniformOutput',false);
            TMap_gaussSum = cellfun(@sum,[TMap_gauss(:,sessI,condI)],'UniformOutput',false);
            TMap_gauss(1:numCells,sessI,condI) = cellfun(@(x,y,z) x.*y./z,[TMap_gauss(:,sessI,condI)],Tsum,TMap_gaussSum,'UniformOutput',false);


            %Dump into varargout.
            TMap_gauss(RunOccMap==0) = nan;
        end
        
        %{
        for cellI = 1:numCells
            if sum(trialReli(cellI, sessI, condI)) > 0
                cellSpiking = lapsSpiking(cellI,:);
                
                [TMap_unsmoothed{cellI,sessI,condI},TCounts{cellI,sessI,condI}]...%TMap_gauss{cellI,condType,tSess}
                        = MakePlacefieldLin(cellSpiking,posUse,linearEdges,RunOccMap{condI,sessI},[],cmperbin,smth); %false
                    
                if any(TMap_unsmoothed{cellI,sessI,condI} > 1)
                    keyboard
                end
               
                %Spatial information
                
            else
                TMap_unsmoothed{cellI,sessI,condI} = TMap_blank;
                TCounts{cellI,sessI,condI} = TMap_blank;
                %TMap_gauss{cellI,tSess,condType} = TMap_blank;
            end 
            
            
            if dispProgress
                p.progress;
            end
        end
        %}
        
        end %any laps use
    end
end

%Get z-scores of firing rates across conditions
if getZscore
for cellI = 1:numCells
    for tSess = 1:numSess
        allRates = reshape([TMap_unsmoothed{cellI,sessI,:}]',numBins,numConds)';
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
    save(savePath,'OccMap','RunOccMap', 'xBin', 'TMap_unsmoothed', 'TMap_gauss', 'TCounts', 'TMap_zRates') %, 'TMap_gauss'
end

%if dispProgress
%    p.stop;
%end

end