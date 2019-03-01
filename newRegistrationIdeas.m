baseImagePath = 'G:\SLIDE\Processed Data\Bellatrix\Bellatrix_160831';
regImagePath = 'G:\SLIDE\Processed Data\Bellatrix\Bellatrix_160830';

load(fullfile(baseImagePath,'FinalOutput.mat'),'NeuronImage');
baseROIs =  NeuronImage;
load(fullfile(regImagePath,'FinalOutput.mat'),'NeuronImage');
regROIs = NeuronImage;

baseStatsTemp = cellfun(@(x)... 
    regionprops(x,'area','centroid','majoraxislength','minoraxislength','orientation'),...
    baseROIs,'UniformOutput',false);
for cellI = 1:length(baseROIs)
    baseCenters(cellI,:) = baseStatsTemp{cellI}.Centroid; %column row
end

regStatsTemp = cellfun(@(x)...
    regionprops(x,'area','centroid','majoraxislength','minoraxislength','orientation'),...
    regROIs,'UniformOutput',false);
for cellI = 1:length(regROIs)
    regCenters(cellI,:) = regStatsTemp{cellI}.Centroid; %column row
end

numMatch = 10;

baseAll = create_AllICmask(baseROIs);
regAll = create_AllICmask(regROIs); 
regRange = size(regAll);
for cellI = 1:length(regROIs)
    cellCent = regCenters(cellI,:);
    
    %Get Distances
    regDistances = hypot(regCenters(:,1)-cellCent(1),regCenters(:,2)-cellCent(2)); 
    
    %Get Angles
    angles = atan2(regCenters(:,1)-cellCent(1),regCenters(:,2)-cellCent(2));
    
    
    %Get new centers relative to cellCent
    
    %Select the closest however many
    
    %Then have to do this for every point in the base image, only keep
    %points which minimize that relative distance, this could be really
    %problematic for when there's a big clouded cluster in the middle
    
    
    
    matchRange = ceil(sortedDistances(numMatch)+5);
    
    roundCent = round(regCenters(cellI,:));
    
    
    
    
    %{
    %Corr doesn't seem to work, to easy to get error. Could instead try
    each point myself, then get sum over number of 1s in the original block
    instead of corr (weighted towards actual cell bodies...)
    blockRows = [max([1 roundCent(2)-matchRange]) min([regRange(1) roundCent(2)+matchRange])];
    blockCols = [max([1 roundCent(1)-matchRange]) min([regRange(2) roundCent(1)+matchRange])];
    
    blockSubs = GetAllCombs(blockRows(1):blockRows(2), blockCols(1):blockCols(2));
    blockInds = sub2ind(regRange,blockSubs(:,1),blockSubs(:,2));
    
    thisBlockTemp = regAll(blockInds);
    thisBlock = reshape(thisBlockTemp,[diff(blockRows)+1,diff(blockCols)+1])'; 
    
    crr = xcorr2(regAll,thisBlock);
    [~,maxInd] = max(crr(:));
    [newCentCol,newCentRow] = ind2sub(regRange,maxInd);
    
    rowDiff(cellI) = newCentRow - regCenters(cellI,2);
    colDiff(cellI) = newCentCol - regCenters(cellI,1);
    hypotDiff(cellI) = hypot(abs(rowDiff(cellI)),abs(colDiff(cellI)));
    %}
    
end






baseAll = create_AllICmask(baseROIs);





%{
cellI = 1
sin(deg2rad(baseStats{cellI}.Orientation))*(baseStats{cellI}.MajorAxisLength/2)
cos(deg2rad(baseStats{cellI}.Orientation))*(baseStats{cellI}.MajorAxisLength/2)

boxCent = [5.5 5.5];
maxDist = hypot(boxCent(1)-1,boxCent(2)-1);
for boxX = 1:10
    for boxY = 1:10
        boxRad(boxX,boxY) = maxDist - hypot(boxCent(1)-boxX,boxCent(2)-boxY);
    end
end
%}
    
    
