function CellCenters = getAllCellCenters(NeuronImage)

CellCenters = zeros(length(NeuronImage),2);
for thisCell = 1:length(NeuronImage)
    stats = [];
    stats = regionprops(NeuronImage{thisCell},'area','centroid');
    if length(stats)==1
        CellCenters(thisCell,1:2) = [stats.Centroid(1) stats.Centroid(2)];
    else
        disp(['error cell ' num2str(thisCell) ', found ' num2str(length(stats)) ' centers'])
    end
end
 
end