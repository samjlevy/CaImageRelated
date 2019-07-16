function gridCenters = GenerateHexagonalGrid(centerSpacing,width,height,gridCenter,numEndExtra)
if isempty(gridCenter)
    gridCenter = true;
elseif gridCenter==false
    gridCenter = [0 0];
end
if isempty(numEndExtra)
    numEndExtra = [0 0];
end

horizOffset = centerSpacing/2;
heightSpacing = sqrt(centerSpacing^2-(horizOffset/2)^2);

exampleRow = 0:centerSpacing:width;
exampleRow = [exampleRow(1:end-1), exampleRow(end):centerSpacing:exampleRow(end)+centerSpacing*numEndExtra(1)];
exampleCol = 0:heightSpacing:height;
exampleCol = [exampleCol(1:end-1), exampleCol(end):heightSpacing:exampleCol(end)+heightSpacing*numEndExtra(2)];
rowInt = repmat(exampleRow,length(exampleCol),1);
rowInt(2:2:size(rowInt,1),:) = rowInt(2:2:size(rowInt,1),:)+horizOffset;
colInt = repmat(exampleCol(:),length(exampleRow),1);

gridCenters = [rowInt(:), colInt];
switch class(gridCenter)
    case 'logical'

    case 'double'
        %Ideally this would generate points outware from (0,0), but now
        %sure how to do that right now
        rowMidInd = round(length(exampleRow)/2);
        colMidInd = round(length(exampleCol)/2);
        
        switch rem(colMidInd,2)
            case 1 
                %Middle row starts at 0
                rowInt = rowInt - exampleRow(rowMidInd);
            case 0
                %Middle row starts offset
                rowInt = rowInt - exampleRow(rowMidInd) - horizOffset;
        end
        rowInt = rowInt + gridCenter(1);
        
        colInt = colInt - exampleCol(colMidInd);
        colInt = colInt+gridCenter(2);
end
gridCenters = [rowInt(:), colInt];
                
end
                
            