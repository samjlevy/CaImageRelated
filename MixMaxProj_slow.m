
h5here = ls('*.h5');
fi = h5info(h5here);
fiSize = fi.Datasets.ChunkSize([1 2]);
nframes = fi.Datasets.Dataspace.Size(3);
            
maxFrame = nan(fiSize(1),fiSize(2),2);
minFrame = nan(fiSize(1),fiSize(2),2);

frameBlocks = [1:5000:nframes nframes];

for fii = 2:length(frameBlocks)-1
    fLoad = frameBlocks([fii fii+1]);
    fLoad(2) = fLoad(2)-1;
    data = h5read(h5here,'/Object',[1 1 fLoad(1) 1],[fiSize(1) fiSize(2) diff(fLoad) 1]);
    
    minHere = min(data,[],3);
    maxHere = max(data,[],3);
    %stdHere = 
    
    minFrame(:,:,2) = minHere;
    maxFrame(:,:,2) = maxHere;
    
    minFrame(:,:,1) = min(minFrame,[],3);
    maxFrame(:,:,1) = max(maxFrame,[],3);
end

outMin = min(minFrame,[],3);
outMax = max(maxFrame,[],3);

