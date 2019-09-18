function [TMap_unsmoothed, TMap_firesAtAll, TMap_zRates, OccMap, RunOccMap, xBin, TCounts] =...
    PFsLinTBTdnmp(trialbytrial, binEdges, minspeed, saveName, smth,condPairs)
%This is specialized to run with the double plus data format. 
%All TMaps get return in bins arranged from center outwards

    %p = inputParser;

    %p.addParameter('smth',false,@(x) islogical(x)); 
    %p.addParameter('trialReli',[]);  
    %p.addParameter('condPairs',[1:length(trialbytrial)]');
    %p.addParameter('dispProgress',true,@(x) islogical(x));
    %p.addParameter('getZscore',true,@(x) islogical(x));

    %p.parse(varargin{:})
    
    %smth = p.Results.smth;
    %condPairs = p.Results.condPairs;
    %trialReli = p.Results.trialReli;
    %dispProgress = p.Results.dispProgress;
    %getZscore = p.Results.getZscore;
    
  
armAlignment = GetDoublePlusArmAlignment;

sessions = unique(trialbytrial(1).sessID);
numSess = length(sessions);
numCells = length(trialbytrial(1).trialPSAbool{1,1});

if isempty(condPairs)
    condPairs = [1:length(trialbytrial)]';
end
numConds = size(condPairs,1);

%if isempty(trialReli)
%    trialReli = ones(numCells,numSess,length(trialbytrial));
%end
%if size(trialReli,3) < length(trialbytrial)
%    trialReli(:,:,2:numConds) = trialReli;
%end

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
TMap_firesAtAll = cell(numCells, numSess, numConds);

if strcmpi(minspeed,'numFrames')
    %doing bin edges by number of frames, use those as time bins
    binsBy = 'numFrames';
    binEdges = sort(binEdges,'ascend');
    numBins = length(binEdges)-1;
    TMap_blank = zeros(1,numBins);
    framesperbin = mean(abs(diff(binEdges)));
    % Generate alternative x pos for binning
    for condI = 1:numConds
        newTrialsX = cellfun(@(x) ceil([1:length(x)]/framesperbin),trialbytrial(condI).trialsX,'UniformOutput',false);
        trialbytrial(condI).trialsX = newTrialsX;
    end
    binEdges = binEdges(2)/framesperbin-0.5:1:binEdges(end)/framesperbin+0.5; 
else
    binsBy = 'spatialBins';
    binEdges = sort(binEdges,'ascend');
    binEdges(end) = [];
    numBins = length(binEdges)-1;
    TMap_blank = zeros(1,numBins);
    cmperbin = mean(abs(diff(binEdges)));
end

%if dispProgress
%p = ProgressBar(numCells*numConds*numSess);
%end 
%binHits = GenerateBinHitsTBT(trialbytrial,binEdges);

for condPairI = 1:numConds
    for sessI = 1:numSess
        condsHere = condPairs(condPairI,:);
        numCondsHere = length(condsHere);
        %lapsUse = [];
        for chI = 1:numCondsHere
            lapsUse{chI} = [logical(trialbytrial(condsHere(chI)).sessID == sessions(sessI))];
        end
        numLaps = cell2mat(cellfun(@sum,lapsUse,'UniformOutput',false));
        
        anyLaps = cell2mat(cellfun(@any,lapsUse,'UniformOutput',false));
        if any(anyLaps)
        
        posX = [];
        posY = [];
        for chJ  = 1:numCondsHere
            pxHere = [trialbytrial(condsHere(chJ)).trialsX{lapsUse{chJ},1}];
            pyHere = [trialbytrial(condsHere(chJ)).trialsY{lapsUse{chJ},1}];
            posX = [posX pxHere];
            posY = [posY pyHere];
        end 
        
        posUse = posX;  
        
        %deal with velocity
        good = true(1,length(posX));
        isrunning = good;                         %Running frames that were not excluded.
        %isrunning(velocity < minspeed) = false;
         
        linearEdges = binEdges;
        linearEdges = sort(linearEdges,'ascend');
        
        %Get spiking
        lapsSpiking = [];
        trialLengths = [];
        for chK  = 1:numCondsHere
            lapsSpikingHere = logical([trialbytrial(condsHere(chK)).trialPSAbool{lapsUse{chK},1}]);
            lapsSpiking = [lapsSpiking lapsSpikingHere];
            %trialLengths = [trialLengths; cell2mat(cellfun(@length,trialbytrial(chK).trialsX(lapsUse{1}),'UniformOutput',false))]; 
        end
        lapsSpiking = logical(lapsSpiking);  
        
        %Make an occupancy map
        %Get spiking by that occupancy map
        %switch binsBy 
        %    case 'spatialBins'
                [OccMap{condPairI,sessI},RunOccMap{condPairI,sessI},xBin{condPairI,sessI}]...
                    = MakeOccMapLin(posUse,good,isrunning,linearEdges);
            
                cellSpiking = mat2cell(lapsSpiking,ones(numCells,1),size(lapsSpiking,2)); %Indiv cellArr slot per cell
                spikePos = cellfun(@(x) posUse(x),cellSpiking,'UniformOutput',false); %only positions by logical cell activity
                spikeCounts = cellfun(@(x) histcounts(x,linearEdges),spikePos,'UniformOutput',false); %counts of positions in bins
                TMap_unsmoothed(1:numCells,sessI,condPairI) = cellfun(@(x) x./RunOccMap{condPairI,sessI},spikeCounts,'UniformOutput',false); %normalize by occupancy
         %   case 'numFrames'
%{
                
                onesBlank = ones(1,numBins);
                OccMap{condPairI,sessI} = framesperbin*onesBlank;
                RunOccMap{condPairI,sessI} = framesperbin*onesBlank;
                xBinTemp = repmat(1:numBins,framesperbin,1);
                xBin{condPairI,sessI} = xBinTemp(:);
                
                %Laps spiking doesn't work, lines them all up in a row
                %But could make a fake spike pos that assigns each to a
                %bin...
                spikeCountsMat = cell2mat(arrayfun(@(x) sum(lapsSpiking(:,x+1:x+framesperbin),2),linearEdges,'UniformOutput',false));
                TMap_frames = spikeCountsMat/framesperbin;
                TMap_frames_cell = mat2cell(TMap_frames,ones(numCells,1),length(linearEdges));
                
                
        end
 %}           
         
        
        
        
        TCounts(1:numCells,sessI,condPairI) = spikeCounts;
        
        %Version that just asks 'did the cell fire at all in this bin
        %{
        allBinHits = [];
        for chK = 1:numCondsHere
            allBinHits = [allBinHits; binHits{condsHere(chK)}(lapsUse{chK})]; 
        end
        binHitsAll = [];
        for lapI = 1:sum(numLaps)
            binHitsAll(:,:,lapI) = allBinHits{lapI};
        end
        cellBinHits = sum(binHitsAll,3)/sum(numLaps);
        TMap_firesAtAll(:,sessI,condPairI) = mat2cell(cellBinHits,ones(numCells,1),numBins);
        %}
        
        %{
        lapX = cell(1,sum(numLaps));
        spks = cell(numCells,sum(numLaps));
        numLapsPlus = [0 numLaps];
        for chK = 1:numCondsHere
            lapX((1:numLaps(chK))+numLapsPlus(chK)) = trialbytrial(condsHere(chK)).trialsX(lapsUse{chK});
            for lapI = 1:numLaps(chK) 
                spks(:,lapI+numLapsPlus(chK)) = mat2cell(trialbytrial(condsHere(chK)).trialPSAbool{lapI},ones(numCells,1),size(trialbytrial(condsHere(chK)).trialPSAbool{lapI},2));
            end
        end
        
        spikeLapPos = cell(numCells,sum(numLaps));
        %spikeLapsBinned = cell(numCells,sum(numLaps));
        %spikeLapsBinnedAny = cell(numCells,sum(numLaps));
        for lapI = 1:sum(numLaps)
            spikeLapPos(:,lapI) = cellfun(@(x) lapX{lapI}(x),spks(:,lapI),'UniformOutput',false);
            %spikeLapsBinned(:,lapI) = cellfun(@(x) histcounts(x,linearEdges),spikeLapPos(:,lapI),'UniformOutput',false);
            %spikeLapsBinnedAny(:,lapI) = cellfun(@(x) x>0,spikeLapsBinned(:,lapI),'UniformOutput',false);
        end 
        spikeLapsBinnedAny = cellfun(@(x) histcounts(x,linearEdges)>0,spikeLapPos,'UniformOutput',false);
        
        cellSpikesBinary = [];
        for cellI = 1:numCells
            cellSpikesBinary{cellI,1} = sum(cell2mat(spikeLapsBinnedAny(cellI,:)'),1);
        end
        TMap_firesAtAll(1:numCells,sessI,condPairI) = cellfun(@(x) x/sum(numLaps),cellSpikesBinary,'UniformOutput',false);
        %}
        if smth
            Tsum = cellfun(@sum,spikeCounts,'UniformOutput',false);

            %Make smoothing kernel.
            gauss_std = 2.5;
            gauss_std = gauss_std/cmperbin; 
            sm = fspecial('gaussian',round(8*gauss_std),gauss_std);
            sm = sm(round(size(sm,1)/2),:);

            %Smooth. 
            TMap_gauss(1:numCells,sessI,condPairI) = cellfun(@(x) imfilter(x,sm),...
                        [TMap_unsmoothed(:,sessI,condPairI)],'UniformOutput',false);
            TMap_gaussSum = cellfun(@sum,[TMap_gauss(:,sessI,condPairI)],'UniformOutput',false);
            TMap_gauss(1:numCells,sessI,condPairI) = cellfun(@(x,y,z) x.*y./z,[TMap_gauss(:,sessI,condPairI)],Tsum,TMap_gaussSum,'UniformOutput',false);


            %Dump into varargout.
            TMap_gauss(RunOccMap==0) = nan;
        end
        
        %{
        for cellI = 1:numCells
            if sum(trialReli(cellI, sessI, condPairI)) > 0
                cellSpiking = lapsSpiking(cellI,:);
                
                [TMap_unsmoothed{cellI,sessI,condPairI},TCounts{cellI,sessI,condPairI}]...%TMap_gauss{cellI,condType,tSess}
                        = MakePlacefieldLin(cellSpiking,posUse,linearEdges,RunOccMap{condPairI,sessI},[],cmperbin,smth); %false
                    
                if any(TMap_unsmoothed{cellI,sessI,condPairI} > 1)
                    keyboard
                end
               
                %Spatial information
                
            else
                TMap_unsmoothed{cellI,sessI,condPairI} = TMap_blank;
                TCounts{cellI,sessI,condPairI} = TMap_blank;
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
%if getZscore
for cellI = 1:numCells
    for tSess = 1:numSess
        allRates = reshape([TMap_unsmoothed{cellI,sessI,:}]',numBins,numConds)';
        zRates = zscore(allRates);
        TMap_zRates(cellI,tSess,1:numConds) = num2cell(zRates,2)';       
    end
end
%end

if saveThis==1
    if ~exist('saveName','var')
        saveName = 'PFsLin.mat';
    end
    savePath = saveName; 
    save(savePath,'OccMap','RunOccMap', 'xBin', 'TMap_unsmoothed', 'TMap_firesAtAll','TMap_gauss', 'TCounts', 'TMap_zRates') %, 'TMap_gauss'
end

%if dispProgress
%    p.stop;
%end

end