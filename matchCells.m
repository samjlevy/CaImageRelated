function matchCells(base_path, reg_paths)

distanceThreshold = 3;

if exist(fullfile(base_path,'fullReg.mat'),'file')
    load(fullfile(base_path,'fullReg.mat'))
else
    load(fullfile(base_path,'FinalOutput.mat'),'NeuronImage','NeuronAvg')
    baseImage = NeuronImage;
    
    base_cellCenters = getAllCellCenters(baseImage);
    baseOrientation = cellfun(@(x) regionprops(x,'Orientation'), baseImage,'UniformOutput',false);
    
    fullReg.sessionInds = [1:length(baseImage)]'; %#ok<NBRAK>
    fullReg.BaseSession = base_path;
    fullReg.RegSessions = reg_paths;
    fullReg.centers = base_cellCenters; 
    fullReg.orientation = cell2mat(cellfun(@(x) x.Orientation, baseOrientation, 'UniformOutput',false))';
    fullReg.Image = baseImage;
    fullReg.ROIavg = MakeAvgROI(NeuronImage,NeuronAvg);
    
    save(fullfile(base_path,'fullReg.mat'),'fullReg')
    disp('no fullReg found, making and saving')
end    

for regsess = 1:length(reg_paths)
    reg_path = reg_paths{regsess};

load(fullfile(reg_path,'RegisteredImage.mat'))

numRegCells = length(regImage_shifted);
numBaseCells = length(fullReg.Image);

%Start assigning cells
[closestCell, distance] = findclosest2D ( fullReg.centers(:,1), fullReg.centers(:,2),...
                reg_shift_centers(:,1), reg_shift_centers(:,2));

cellsInRange = closestCell(distance < distanceThreshold);
rinds = 1:numRegCells;
inRangeIndices = rinds(distance < distanceThreshold); %indices of regCells
binEdges = 0.5:1:numBaseCells+0.5;
[counts,~] = histcounts(cellsInRange,binEdges);
overlapped = find(counts > 1);
for repCell = 1:length(overlapped)
    matchedCells = inRangeIndices(cellsInRange==overlapped(repCell)); 
        %indices in closestCell, full length regCells
    
    baseReg = fullReg.ROIavg{1,overlapped(repCell)};
    regMatchedReg = {regAvg_shifted{1,matchedCells}};
      
    areaCorrs = cellfun(@(x) corr(baseReg(:),x(:),'type','Spearman'), regMatchedReg, 'UniformOutput',false);
    areaCorrs = cell2mat(areaCorrs);
    
    useCell = areaCorrs==max(areaCorrs);
    if sum(useCell)==1
        %good
        closestCell(matchedCells(~useCell)) = NaN;
        distance(matchedCells(~useCell)) = NaN;
    else
        %either both or none, problem; mostly shouldn't happen?
        disp('something up here, found 2 matches for this cell; probably need a fallback')
    end 
end

inRangeIndicesCells = rinds(distance < distanceThreshold);
unpairedRegCells = rinds((distance >= distanceThreshold) | isnan(distance));

matchedBaseCells = closestCell(inRangeIndicesCells);

foundTwice = intersect(inRangeIndicesCells,unpairedRegCells);
assigned = length(inRangeIndicesCells) + length(unpairedRegCells);
if isempty(foundTwice) && assigned == numRegCells && max(matchedBaseCells) <= numBaseCells
    newCol = size(fullReg.sessionInds,2) + 1;
    fullReg.sessionInds(matchedBaseCells, newCol) = inRangeIndicesCells;
    
    newInds = size(fullReg.sessionInds,1)+1;
    newInds = newInds:newInds+length(unpairedRegCells)-1;
    
    fullReg.sessionInds(newInds, newCol) = unpairedRegCells;
    
    fullReg.centers(newInds, 1:2) = reg_shift_centers(unpairedRegCells,:);
    
    regOrientation = cellfun(@(x) regionprops(x,'Orientation'),...
        {regImage_shifted{1,unpairedRegCells}},'UniformOutput',false);
    fullReg.orientation(newInds,1) =...
        cell2mat(cellfun(@(x) x.Orientation, regOrientation, 'UniformOutput',false))';
    
    fullReg.Image(1,newInds) = {regImage_shifted{1,unpairedRegCells}};
    fullReg.ROIavg(1,newInds) = {regAvg_shifted{1,unpairedRegCells}};
    
    save(fullfile(base_path,'fullReg.mat'),'fullReg')
else
    disp('Something wrong with indexing, some kind of overlap')
    keyboard
end

end

end