function axisLengths = getAllCellMajorAxis(NeuronImage,suppressError)
if isempty(suppressError)
    suppressError = false;
end

axisLengths = zeros(length(NeuronImage),1);
for thisCell = 1:length(NeuronImage)
    stats = [];
    stats = regionprops(NeuronImage{thisCell},'MajorAxisLength');
    if length(stats)==1
        axisLengths(thisCell,1) = [stats.MajorAxisLength];
    else
        if suppressError==false
            disp(['error cell ' num2str(thisCell) ', found ' num2str(length(stats)) ' Major Axes lengths?'])
        end
    end
end
 
end