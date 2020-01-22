function [TMap_unsmoothed,RunOccMap,OccMap,spikeCounts] =...
    PFsTBTarbitraryBins(trialbytrial,binVertices,minSpeed,saveName)

%This computes placefields from trialbytrial using pre-determinted bin
%vertices. Useful for environment where bins are not regularly spaced.
%binVertices a cell array with matrices for x and y points, each x/y array has a row for each bin
binsX = binVertices{1};
binsY = binVertices{2};

sessions = unique(trialbytrial(1).sessID);
numSess = length(sessions);
numCells = length(trialbytrial(1).trialPSAbool{1,1});
numConds = length(trialbytrial);
numBins = size(binsX,1);

for condI = 1:numConds %Epoch
    for sessI = 1:numSess
        
        lapsUse = logical(trialbytrial(condI).sessID == sessions(sessI));
        
        if any(lapsUse)
            posX = [trialbytrial(condI).trialsX{lapsUse,1}];
            posY = [trialbytrial(condI).trialsY{lapsUse,1}];
        
            %deal with veloity
            %Right now we dont
            good = true(1,length(posX));
            isRunning = good;   
            
            %Make an occupancy map
            [OccMap{condI,sessI}, ~] = ArbitraryHistcounts2(posX,posY,binsX,binsY);
            [RunOccMap{condI,sessI}, xBin{condI,sessI}] = ArbitraryHistcounts2(posX(isRunning),posY(isRunning),binsX,binsY);
    
            %Get spiking
            lapsSpiking = logical([trialbytrial(condI).trialPSAbool{lapsUse,1}]);
        
            cellSpiking = mat2cell(lapsSpiking,ones(numCells,1),size(lapsSpiking,2));
            cellSpikeBins = cellfun(@(x) xBin{condI,sessI}(x),cellSpiking,'UniformOutput',false);
            spikeCounts = cellfun(@(x) sum(x==([1:numBins]'),2),cellSpikeBins,'UniformOutput',false);
            TMap_unsmoothed(1:numCells,sessI,condI) = cellfun(@(x) (x./RunOccMap{condI,sessI})',spikeCounts,'UniformOutput',false); 
        end
    end
end

if ~isempty(saveName) 
    save(saveName,'OccMap','RunOccMap', 'spikeCounts', 'TMap_unsmoothed')
end

end