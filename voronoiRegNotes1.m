load('FinalOutput.mat', 'NeuronImage')
allMask = create_AllICmask(NeuronImage);
numCells = length(NeuronImage);
maskSize = size(allMask);
allCenters = getAllCellCenters(NeuronImage);
[distances,withinRad] = GetAllPtToPtDistances(allCenters(:,1),allCenters(:,2),[]);
figure; hh = histogram(distances);
[mm,ii] = max(hh.Values);
peakDist = mean(hh.BinEdges(ii:ii+1));

figure; voronoi(allCenters(:,1),allCenters(:,2))
[vorVertices,vorIndices] = voronoin(allCenters);
%Each cell of C is coordinates of the corners for that polygon

%Try local grid dissimilarity by downsampling cells

%Exclude cells that have polygons out of the image edge
xOutRange = cell2mat(cellfun(@(x)...
    any(vorVertices(x,1)<min(allCenters(:,1))) | any(vorVertices(x,1)>max(allCenters(:,1))),...
    vorIndices,'UniformOutput',false));
yOutRange = cell2mat(cellfun(@(x)...
    any(vorVertices(x,2)<min(allCenters(:,2))) | any(vorVertices(x,2)>max(allCenters(:,2))),...
    vorIndices,'UniformOutput',false));
edgePolys = xOutRange | yOutRange;

figure; voronoi(allCenters(:,1),allCenters(:,2))
hold on
for cellI = 1:numCells
    if edgePolys(cellI)==0
        plot(vorVertices(vorIndices{cellI},1),vorVertices(vorIndices{cellI},2),'.r','MarkerSize',6)
    end
end

%Get Voronoi adjacency
voronoiAdj = false(numCells,numCells);
for cellI = 1:numCells
    if edgePolys(cellI)==0
    for cellJ = 1:numCells
        if cellI ~= cellJ
            voronoiAdj(cellI,cellJ) = any(ismember(vorIndices{cellI},vorIndices{cellJ}));
        end
    end
    end
end

%Distances between voronoi adjacent polygons
gg = logical(triu(ones(numCells),1));
figure; hh=histogram(distances(voronoiAdj & gg));
[mm,ii] = max(hh.Values);
vCentDist = mean(hh.BinEdges(ii:ii+1));
title('Distances between adjacent polygon centers')

%Make a grid 
%Rectangular
gSpacing = vCentDist; %dist between points 
gOffset = 0; %offset every other row 
row = 0:gSpacing:maskSize(2);
col = 0:gSpacing:maskSize(1);

rowInt = repmat(row,length(col),1);
colInt = repmat(col(:),length(row),1);

grid = [rowInt(:), colInt];

%Hexagonal grid
horizOffset = gSpacing/2;
heightSpacing = sqrt(gSpacing^2-(horizOffset/2)^2);

exampleRow = 0:gSpacing:maskSize(2);
exampleCol = 0:gSpacing:maskSize(1);
rowInt = repmat(exampleRow,length(exampleCol),1);
rowInt(2:2:size(rowInt,1),:) = rowInt(2:2:size(rowInt,1),:)+horizOffset;
colInt = repmat(exampleCol(:),length(exampleRow),1);

grid = [rowInt(:), colInt];

gridCenters = GenerateHexagonalGrid(gSpacing,100,200,true,0);
figure; voronoi(grid(:,1),grid(:,2))


%How to define region worth testing? Maybe need to expand different size
%boxes and test what size box gives sufficient variation around each point

%Test region
cellI = 1;
thisCenter = allCenters(cellI,:);
alignRange = 40;



%Set up unchanging background image
 gridCenters = GenerateHexagonalGrid(centerSpacing,width,height,positiveOnly,numEndExtra);
 

%Test on neuronImage: how well can we reg neuron image to itself
%Polygon areas
polyAreas = cell2mat(cellfun(@(x) polyarea(vorVertices(x,1),vorVertices(x,2)),vorIndices,'UniformOutput',false));
adjVerts = [];
for cellI = 1:numCells
if edgePolys(cellI)==0
    %First get farthest out points on adjacent polys: do this for every
    %point, then use largest to set limits for local grid size
    
    %Get the vertices of adjacent polys
    adjVerts{cellI} = GetAdjacentPolyVertices(vorVertices,vorIndices,voronoiAdj,cellI);
   
    Get distances from each of those to cellI center and width and height
    Filter max y, and max Y 
    adjVlimsX(cellI,:) = [min(adjVerts{cellI}(:,1)), max(adjVerts{cellI}(:,1))];
    adjVlimsXdiff(cellI,:) = adjVlimsX(cellI,:) - cell center
    adjVlimsY(cellI,:) = [min(adjVerts{cellI}(:,2)), max(adjVerts{cellI}(:,2))];
    adjVlimsYdiff(cellI,:) = adjVlimsY(cellI,:) - cell center
    
end
end

%Reg non-uniformity v1
%For each cell
how is it's local voronoi different from voronoi centerd on cell center
how is it different from specific voronois of one that covers the whole regimage


%Test on same downsampled neuron image
%Generate downsampled sets
dsPct = 0.85;
dsA = randperm(numCells);
dsAcells = dsA(1:round(numCells*dsPct));
dsImA = NeuronImage(dsAcells);
dsB = randperm(numCells);
dsBcells = dsB(1:round(numCells*dsPct));
dsImB = NeuronImage(dsBcells);


%Get all pt to pt distances
%Get all pt to pt angles
%Matrix of 1st tier voronoi neighbors
%Matrix of 2nd tier voronoi neighbors
% xcorr of 1st and 2nd tier angles/lengths to find best alignment
%   finding angle: could just step in 1 degree increments
%   could slide to next matched pair
%   determine best fit by local mins of angle/length pt to pt distances,
%      use circular mean approximation to get these pt distances.
%   Could add optional limit at this step