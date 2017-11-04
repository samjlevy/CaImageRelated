function [numCells] = sessionNumcells(allfiles)

numCells = zeros(length(allfiles),1);
for fileN = 1:length(allfiles)
    thisDir = allfiles{fileN};
    load(fullfile(thisDir,'Pos_align.mat'),'PSAbool')
    
    numCells(fileN) = size(PSAbool,1);
end

end


