function newGradient = GradientMaker(colors,locations)
numColors = size(colors,1);
nColorChannels = size(colors,2);
nSteps = 256;

if sum(locations<=1) == numColors
    %Translate to indices
    rowInds = round(locations*nSteps);
end

newGradient = zeros(nSteps,nColorChannels);

%Fill in beginning and end

rowsInsert = 1:rowInds(1)+1; 
newGradient(1:rowInds(1)+1,:) = repmat(colors(1,:),length(rowsInsert),1);
if rowInds(end) < nSteps
    rowsAdd = rowInds(end)+1:nSteps; 
 newGradient(rowsAdd,:) = repmat(colors(end,:),length(rowsAdd),1);
end


for cpI = 1:numColors-1
    gradHere = zeros(nSteps,nColorChannels);
    for colI = 1:nColorChannels
        gradHere(:,colI) = linspace(colors(cpI,colI),colors(cpI+1,colI),nSteps);
    end
    gradInds = round(linspace(1,nSteps,(rowInds(cpI+1)-rowInds(cpI)))); 
    
    newGradient(rowInds(cpI)+1:rowInds(cpI+1),:) = gradHere(gradInds,:);
end

end
