filesUse = {'Titan180531', 'Titan180604', 'Titan180605'}
rootFolder = 'G:\DoublePlus'

for ii = 1:3
clear NeuronImage
cd(fullfile(rootFolder,filesUse{ii}))
load('FinalOutput.mat','NeuronImage')

numCells = length(NeuronImage);
numRows = size(NeuronImage{1},1);
numCols = size(NeuronImage{1},2);


NeuronFootprint = single(zeros(numCells,numRows,numCols));

p = ProgressBar(numCells);
for cellI = 1:numCells
    NeuronFootprint(cellI,:,:) = single(NeuronImage{cellI});
    p.progress;
end
p.stop;

save( fullfile(rootFolder,'\TitanFootprints\',[filesUse{ii} 'NeuronFootprint.mat']),'NeuronFootprint','-v7.3')
end