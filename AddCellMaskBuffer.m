function bufferedNeuronImage = AddCellMaskBuffer(NeuronImage, bufferWidth)

numCells = length(NeuronImage);
maskSize = size(NeuronImage{1});

horizBuffer = zeros(bufferWidth, bufferWidth*2 + maskSize(2));
vertBuffer = zeros(maskSize(1), bufferWidth);

%Buffer these things
bufferedNeuronImage = cell(1,numCells);
for cellI = 1:numCells
    bufferedNeuronImage{cellI} =...
        [horizBuffer; vertBuffer NeuronImage{cellI}, vertBuffer; horizBuffer]; 
end

end