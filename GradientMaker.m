function newGradient = GradientMaker(colors,locations)
numColors = size(colors,1);

if sum(locations<=1) == numColors
    %Translate to indices
    rowInds = round(locations*64);
end

newGradient = zeros(64,3);

%Fill in beginning and end

rowsInsert = 1:rowInds(1)+1; 
newGradient(1:rowInds(1)+1,:) = repmat(colors(1,:),length(rowsInsert),1);
if rowInds(end) < 64
    rowsAdd = rowInds(end)+1:64; 
 newGradient(rowsAdd,:) = repmat(colors(end,:),length(rowsAdd),1);
end


for cpI = 1:numColors-1
    gradHere = zeros(64,3);
    for colI = 1:3
        gradHere(:,colI) = linspace(colors(cpI,colI),colors(cpI+1,colI),64);
    end
    gradInds = round(linspace(1,64,(rowInds(cpI+1)-rowInds(cpI)))); 
    
    newGradient(rowInds(cpI)+1:rowInds(cpI+1),:) = gradHere(gradInds,:);
end

end
