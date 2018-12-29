function binHits = GenerateBinHitsTBT(trialbytrial,stemBinEdges)
numConds = length(trialbytrial);
numCells = size(trialbytrial(1).trialPSAbool{1},1);
numBins = length(stemBinEdges)-1;
for condI = 1:numConds
    lapsHere = length(trialbytrial(condI).trialsX);

    indX = cellfun(@(x) discretize(x,stemBinEdges),trialbytrial(condI).trialsX,'UniformOutput',false);
    
    spikeLoc = cellfun(@(x,y) x.*y,trialbytrial(condI).trialPSAbool,indX,'UniformOutput',false);

    spikeLocEach = cellfun(@(x) mat2cell(x,ones(numCells,1),size(x,2)),spikeLoc','UniformOutput',false);
    spikeLocEach = [spikeLocEach{:}]; 
    binHitsEachLap = cellfun(@(x) sum(x==[1:numBins]',2)'>0,spikeLocEach,'UniformOutput',false);
    
    binHitsAll = cell2mat(binHitsEachLap);
    
    binHitsMat = mat2cell(binHitsAll,numCells,numBins*ones(1,lapsHere))';
    
    %binHitsMat = [];
    %for cellI = 1:numCells(1)
    %    binHitsMat{cellI,1} = cell2mat(binHitsEachLap(cellI,:));
    %end

    binHits{condI} = binHitsMat;
end



end