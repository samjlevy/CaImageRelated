function [assignmat] = matchCells(base_path, reg_paths)

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
    fullReg.orientation = baseOrientation;
    fullReg.Image = baseImage;
    fullReg.ROIavg = MakeAvgROI(NeuronImage,NeuronAvg);
    
    %save(fullfile(base_path,'fullReg.mat'),'fullReg')
end    

%for regsess = 1:length(reg_paths)
    reg_path = reg_paths{regsess};

load(fullfile(reg_path,'RegisteredImage.mat'))

numRegCells = length(regImage_shifted);
numBaseCells = length(fullReg.Image);

%Start assigning cells
[closestCell, distance] = findclosest2D ( fullReg.centers(:,1), fullReg.centers(:,2),...
                reg_shift_centers(:,1), reg_shift_centers(:,2));

cellsInRange = closestCell(distance < distanceThreshold);
rinds = 1:numRegCells;
inRangeIndices = rinds(distance < distanceThreshold);
binEdges = 0.5:1:numBaseCells+0.5;
[counts,~] = histcounts(cellsInRange,binEdges);
overlapped = find(counts > 1);
for repCell = 1:length(overlapped)
    matchedCells = inRangeIndices(cellsInRange==overlapped(repCell)); %indices in closestCell
    
    baseReg = regionprops(fullReg.ROIavg{1,overlapped(repCell)}, 'ConvexArea');
    regMatchedReg = cellfun(@(x) regionprops(x,'ConvexArea'), {regAvg_shifted{1,matchedCells}},'UniformOutput',false);
    
    areaCorrs = cellfun(@(x) corr(baseReg(:),x(:),'type','Spearman'), regMatchedReg, 'UniformOutput',false);
    %here probably need to approach with orientation
    closer = min(distance(matchedCells));
    if sum(distance(matchedCells)==closer)
        useCell = matchedCells(distance(matchedCells)==closer);
        closestCell(useCell) = NaN;
        distance(matchedCells(matchedCells~=useCell)) = NaN;
        
        %Check this part
        need to test that convex area works with possible bad shifting
        baseNeuronMeanReg = cellfun(@(x) regionprops(x,'ConvexArea'), baseImage,'UniformOutput',false);
        

        corr(sesh(1).NeuronMean_reg{same_ind(k)}(:),...
                    sesh(2).NeuronMean_reg{j}(:));
    else 
        %huh, both cells are the same distance away; probably won't happen?
    end
end
inRangeIndices = rinds(distance < distanceThreshold);

matchedBaseCells = closestCell(inRangeIndices);

unpairedRegCells = rinds(distance >= distanceThreshold | isnan(distance));
%are there sessions other than the base one? if so, check against those 








regOrientation = cellfun(@(x) regionprops(x,'Orientation'), regImage_shifted,'UniformOutput',false);
           
for pc = 1:length(inRangeIndices)
    baseAngle(pc) = baseOrientation{1,matchedBaseCells(pc)}.Orientation;
    regAngle(pc) = regOrientation{1,inRangeIndices(pc)}.Orientation;


end    
    
    
cellsOutofRange = closestCell(distance >= distanceThreshold | isnan(distance));



    







end



end