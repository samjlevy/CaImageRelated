cd('E:\Marble11_180721')
load('FinalOutput.mat', 'NeuronImage')
allMask = create_AllICmask(NeuronImage);
numCells = length(NeuronImage);
maskSize = size(allMask);
allCenters = getAllCellCenters(NeuronImage);
[distances,withinRad] = GetAllPtToPtDistances(allCenters(:,1),allCenters(:,2),[]);
allAngles = GetAllPtToPtAngles(allCenters);
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
    %if edgePolys(cellI)==0
    for cellJ = 1:numCells
        if cellI ~= cellJ
            voronoiAdj(cellI,cellJ) = any(ismember(vorIndices{cellI},vorIndices{cellJ}));
        end
    end
    %end
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
[xPts,yPts] = GenerateHexagonalGrid2(center,spacing,side)

%How to define region worth testing? Maybe need to expand different size
%boxes and test what size box gives sufficient variation around each point

%Test region
cellI = 1;
thisCenter = allCenters(cellI,:);
alignRange = 40;

%Set up unchanging background image
allSideLength = max([max(allCellCenters(:,1))-min(allCellCenters(:,1)) max(allCellCenters(:,2))-min(allCellCenters(:,2))]);
allSpacing = ;
allCenter = ;
allCenters = GenerateHexagonalGrid2(allCenter,allSpacing,allSideLength);
%Voronoi background image


%Test on neuronImage: how well can we reg neuron image to itself
%Polygon areas
polyAreas = cell2mat(cellfun(@(x) polyarea(vorVertices(x,1),vorVertices(x,2)),vorIndices,'UniformOutput',false));
%2nd level voronoi Adjacency
voronoiAdjTwo = GetTierNAdjacency(voronoiAdj,1);
voronoiAdjTwoEx = voronoiAdjTwo .* ~voronoiAdj;

for cellI = 1:numCells
if edgePoly(cellI)==0 && sum(voronoiAdj(cellI) & edgePoly)==0
    
end
end

adjVerts = [];
for cellI = 1:numCells
if edgePolys(cellI)==0
    %First get farthest out points on adjacent polys: do this for every
    %point, then use largest to set limits for local grid size
    
    %Get the vertices of adjacent polys
    adjVerts{cellI} = GetAdjacentPolyVertices(vorVertices,vorIndices,voronoiAdj,cellI);
   
    %Get distances from each of those to cellI center and width and height
    %Filter max y, and max Y 
    adjVlimsX(cellI,:) = [min(adjVerts{cellI}(:,1)), max(adjVerts{cellI}(:,1))];
    adjVlimsXdiff(cellI,:) = abs(adjVlimsX(cellI,:) - allCenters(cellI,1));
    adjVlimsY(cellI,:) = [min(adjVerts{cellI}(:,2)), max(adjVerts{cellI}(:,2))];
    adjVlimsYdiff(cellI,:) = abs(adjVlimsY(cellI,:) - allCenters(cellI,2));
    %Right now this is still including polys with extreme (Inf) pts
end
end

%Reg non-uniformity v1

rangeCheck = 100;
spacing = 10;
%local uniform hex grid
[xReg,yReg] = GenerateHexagonalGrid2([0,0],spacing,rangeCheck);
[vorVertsReg,vorIndsReg] = voronoin([xReg,yReg]);
vorVertsReg(vorVertsReg==Inf)=rangeCheck*5;
polysReg = cellfun(@(x) polyshape(vorVertsReg(x,1),vorVertsReg(x,2)),vorIndsReg,'UniformOutput',false);
localHexOverlap = [];
for cellI = 1:numCells
if edgePolys(cellI)==0 && (sum(voronoiAdjTwo(cellI) & edgePolys)==0)
    %Gather local cells
    thisCenter = allCenters(cellI,:);
    adjCells = find(voronoiAdj(cellI,:));
    adjCellsTwo = find(voronoiAdjTwoEx(cellI,:));
    adjCenters = [allCenters(adjCells,1)-thisCenter(1) allCenters(adjCells,2)-thisCenter(2)];
    adjCentersTwo = [allCenters(adjCellsTwo,1)-thisCenter(1) allCenters(adjCellsTwo,2)-thisCenter(2)];
    cellsHere = [cellI,adjCells,adjCellsTwo];
    %figure; plot(0,0,'.k'); hold on; plot(adjCenters(:,1),adjCenters(:,2),'.r'); plot(adjCentersTwo(:,1),adjCentersTwo(:,2),'.g')

    vorVertsHere = [vorVertices(:,1)-thisCenter(1) vorVertices(:,2)-thisCenter(2)];
    %for vlI = 1:length(cellsHere); vHere = vorIndices{cellsHere(vlI)}; plot(vorVertsHere([vHere, vHere(1)],1),vorVertsHere([vHere, vHere(1)],2),'b'); end
    vorIndsHere = vorIndices(cellsHere);
    polysHere = cellfun(@(x) polyshape(vorVertsHere(x,1),vorVertsHere(x,2)),vorIndsHere,'UniformOutput',false);    
    
    %Deviation from local-centered regular hex: 
    %what percent of each poly is in each of the local-centered hexagons
    for vlI = 1:length(cellsHere)
        cellArea = polyarea(vorVertsHere(vorIndsHere{vlI},1),vorVertsHere(vorIndsHere{vlI},2));
        areas(vlI) = cellArea;
        %patch(vorVertsHere(vorIndsHere{vlI},1),vorVertsHere(vorIndsHere{vlI},2),'g','FaceColor','g','FaceAlpha',0.5)
        for regI = 1:length(xReg)
            %patch(vorVertsReg(vorIndsReg{regI},1),vorVertsReg(vorIndsReg{regI},2),'g','FaceColor','g','FaceAlpha',0.5)
            intersectPoly{vlI}{regI} = intersect(polysHere{vlI},polysReg{regI});
            localHexOverlap{cellI}{vlI}(regI) = polyarea(intersectPoly{vlI}{regI}.Vertices(:,1),intersectPoly{vlI}{regI}.Vertices(:,2));
        end
    end
    
    %Maybe sum together heterogeneity of 1st and 2nd tier adjacent, then have one measure for each plus one for original cell...
    tieredAreaOverlap{cellI} = [localHexOverlap{cellI}{1}/cellArea(1),... %original cell
                                sum(localHexOverlap{cellI}{2:(2+length(adjCells)-1)},2)/sum(areas(2:(2+length(adjCells)-1))),... %tier 1 adjacents
                                sum(localHexOverlap{cellI}{length(adjCells)+2:end},2)/sum(areas(length(adjCells)+2:end))];   %tier 2 adjacents
                                                        %indexing here needs to be checked
end   
end
%Then what? Somehow need the pattern of non-locally hexagonal, how similar
%is it to others?
    


% xcorr of 1st and 2nd tier angles/lengths to find best alignment
%   finding angle: could just step in 1 degree increments
%   could slide to next matched pair
%   determine best fit by local mins of angle/length pt to pt distances,
%      use circular mean approximation to get these pt distances.
%   Could add optional limit at this step
for cellI = 1:numCells
    theseDist2 = distances(cellI,voronoiAdjTwo(cellI,:));
    theseAngles2 = allAngles(cellI,voronoiAdjTwo(cellI,:));
    
    for cellJ = 1:numCells%but would be another session
    %How to xcorr when have different numbers of points 
    
    




%For each cell

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
allAngles = GetAllPtToPtAngles(pts)
%Matrix of 1st tier voronoi neighbors
%Matrix of 2nd tier voronoi neighbors
% xcorr of 1st and 2nd tier angles/lengths to find best alignment
%   finding angle: could just step in 1 degree increments
%   could slide to next matched pair
%   determine best fit by local mins of angle/length pt to pt distances,
%      use circular mean approximation to get these pt distances.
%   Could add optional limit at this step