cd('E:\Marble11_180721')
load('FinalOutput.mat', 'NeuronImage')
allMask = create_AllICmask(NeuronImage);
numCells = length(NeuronImage);
maskSize = size(allMask);
allCenters = getAllCellCenters(NeuronImage);
[allDistances,withinRad] = GetAllPtToPtDistances(allCenters(:,1),allCenters(:,2),[]);
allAngles = GetAllPtToPtAngles(allCenters);
figure; hh = histogram(allDistances); title('All center-to-center distances')
[mm,ii] = max(hh.Values);
peakDist = mean(hh.BinEdges(ii:ii+1));

figure; voronoi(allCenters(:,1),allCenters(:,2))
[vorVertices,vorIndices] = voronoin(allCenters);
title('Voronoi of all cells')
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
title('Voronoi with all non-inf vertices labeled')

%Get Voronoi adjacency
%{
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
%}
voronoiAdj = GetVoronoiAdjacency(vorIndices);

%Distances between voronoi adjacent polygons
gg = logical(triu(ones(numCells),1));
figure; hh=histogram(allDistances(voronoiAdj & gg));
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
%{
allSideLength = max([max(allCellCenters(:,1))-min(allCellCenters(:,1)) max(allCellCenters(:,2))-min(allCellCenters(:,2))]);
allSpacing = [];
allCenter = [];
allCenters = GenerateHexagonalGrid2(allCenter,allSpacing,allSideLength);
%}
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
    %Need to figure out some structure for uniform hex grid
    %Could probably just do clockwise order in concentric rings
    figure; voronoi(xReg,yReg)
    
[vorVertsReg,vorIndsReg] = voronoin([xReg,yReg]);
vorVertsReg(vorVertsReg==Inf)=rangeCheck*5;
vorRegAdj = GetVoronoiAdjacency(vorIndsReg);
regTiersAdj = GetAllTierAdjacency(vorRegAdj);
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
    %title(['2 voronoi layers for cell ' num2str(cellI)]); xlim([-60 60]); ylim([-60 60])
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

%% Local regularly-spaced hexagonal grid distribution
%cd('E:\Marble11_180721')
cd('C:\Users\samwi_000\Desktop')
load('FinalOutput.mat', 'NeuronImage')
allCenters = getAllCellCenters(NeuronImage);
[allDistances,withinRad] = GetAllPtToPtDistances(allCenters(:,1),allCenters(:,2),[]);
allAngles = GetAllPtToPtAngles(allCenters);

[vorVertices,vorIndices] = voronoin(allCenters);
figure; voronoi(allCenters(:,1),allCenters(:,2))
allAreas = cell2mat(cellfun(@(x) polyarea(vorVertices(x,1),vorVertices(x,2)),vorIndices,'UniformOutput',false));
title('Voronoi of all cells')
vorAdjacency = GetVoronoiAdjacency(vorIndices);
vorAdjTiers = GetAllTierAdjacency(vorAdjacency,10);

%{
cellI = 1
plot(allCenters(cellI,1),allCenters(cellI,2),'r*')
theseC = find(vorAdjTiers(cellI,:)==1)
plot(allCenters(cellI,1),allCenters(cellI,2),'g*')
theseC = find(vorAdjTiers(cellI,:)==2)
plot(allCenters(cellI,1),allCenters(cellI,2),'r*')
%}

%Exclude cells that have polygons out of the image edge
edgePolys = GetVoronoiEdges(vorVertices,allCenters,vorIndices);

rangeCheck = 100;
spacing = 10;
%local uniform hex grid
[xReg,yReg] = GenerateHexagonalGrid2([0,0],spacing,rangeCheck);
regCenters = [xReg(:), yReg(:)];
%figure; voronoi(xReg,yReg)    
[vorVertsReg,vorIndsReg] = voronoin([xReg,yReg]);
regEdgePolys = GetVoronoiEdges(vorVertsReg,regCenters,vorIndsReg);
%vorVertsReg(vorVertsReg==Inf)=rangeCheck*5;
xReg(regEdgePolys) = []; yReg(regEdgePolys) = []; vorIndsReg(regEdgePolys) = [];
vorRegAdj = GetVoronoiAdjacency(vorIndsReg);
regTiersAdj = GetAllTierAdjacency(vorRegAdj,[]);
regMidCell = find(xReg==0 & yReg==0);
maxAdj = max(regTiersAdj(regMidCell,:));
regTiersCells{1} = regMidCell;
for maI = 1:maxAdj
    regTiersCells{maI+1} = find(regTiersAdj(regMidCell,:)==maI);
end
polysReg = cellfun(@(x) polyshape(vorVertsReg(x,1),vorVertsReg(x,2)),vorIndsReg,'UniformOutput',false);

tic
localHexOverlap = [];
localHexAreaTotal = [];
localHexAreaTierTotal = [];
localHexAreaTierNorm = [];
numTiersCheck = 2; %Max levels from cellI to look at 
for cellI = 1:numCells
    
if edgePolys(cellI)==0 && (sum(edgePolys(vorAdjTiers(cellI,:)==numTiersCheck))==0)
    thisCenter = allCenters(cellI,:);
    
    %Gather adjacent cells
    adjTierCells{1} = cellI;
    adjTierAreas{cellI}{1} = allAreas(cellI);
    adjTierAreasTotal{cellI}(1,1) = adjTierAreas{cellI}{1};
    for tcI = 1:numTiersCheck
        adjTierCells{tcI+1} = find(vorAdjTiers(cellI,:)==tcI);
        adjTierCenters{tcI+1} = allCenters(adjTierCells{tcI+1},:);
        adjTierAreas{cellI}{tcI+1} = allAreas(adjTierCells{tcI+1});
        adjTierAreasTotal{cellI}(1,tcI+1) = sum(adjTierAreas{cellI}{tcI+1}); 
    end
    adjCellsHere = [adjTierCells{:}];
    
    %Shift all vor vertices, make polygons
    vorVertsShift = [vorVertices(:,1)-thisCenter(1) vorVertices(:,2)-thisCenter(2)]; %Shift all vertices around this center (0,0)
    vorCentersShift = [allCenters(:,1)-thisCenter(1), allCenters(:,2)-thisCenter(2)];
    polysShift(edgePolys==0) = cellfun(@(x) polyshape(vorVertsShift(x,1),vorVertsShift(x,2)),vorIndices(edgePolys==0),'UniformOutput',false); %Polyshape format for adj cells
    
    %Deviation from local tiered hex
    %what percent of each poly is in each of the local-centered hexagons
    for tcI = 1:numTiersCheck+1
        adjHere = adjTierCells{tcI};
        for vlI = 1:length(adjHere)
            thisCell = adjTierCells{tcI}(vlI);
            %patch(vorVertices(vorIndices{adjHere(vlI)},1),vorVertices(vorIndices{adjHere(vlI)},2),'g','FaceColor','g','FaceAlpha',0.5)
            
            %Get intersection of each reg cell with locally adjacent cell, organized by adjacency tier
            for maI = 1:length(regTiersCells)
                for regI = 1:length(regTiersCells{maI})
                    %patch(vorVertsReg(vorIndsReg{regI},1),vorVertsReg(vorIndsReg{regI},2),'g','FaceColor','g','FaceAlpha',0.5)
                    intersectPoly = intersect(polysShift{thisCell},polysReg{regTiersCells{maI}(regI)});
                    localHexOverlap{cellI}{tcI,vlI}(maI,regI) = polyarea(intersectPoly.Vertices(:,1),intersectPoly.Vertices(:,2));
                end
            end
            localHexAreaTotal{cellI}{tcI}(:,vlI) = sum(localHexOverlap{cellI}{tcI,vlI},2); %Each column is each locally adjacent cell to cellI
        end
        localHexAreaTierTotal{cellI}(:,tcI) = sum(localHexAreaTotal{cellI}{tcI},2);
        localHexAreaTierNorm{cellI}(:,tcI) = localHexAreaTierTotal{cellI}(:,tcI)/adjTierAreasTotal{cellI}(1,tcI);
    end
   
end
end
toc

%% Vector to adjacent cells comparison
cd('E:\Marble11_180721')
load('FinalOutput.mat', 'NeuronImage')
allCenters = getAllCellCenters(NeuronImage);
[allDistances,withinRad] = GetAllPtToPtDistances(allCenters(:,1),allCenters(:,2),[]);
allAngles = GetAllPtToPtAngles(allCenters);
allAreas = cell2mat(cellfun(@(x) polyarea(vorVertices(x,1),vorVertices(x,2)),vorIndices,'UniformOutput',false));

figure; voronoi(allCenters(:,1),allCenters(:,2))
[vorVertices,vorIndices] = voronoin(allCenters);
title('Voronoi of all cells')
vorAdjacency = GetVoronoiAdjacency(vorIndices);
vorAdjTiers = GetAllTierAdjacency(vorAdjacency,10);

edgePolys = GetVoronoiEdges(vorVertices,allCenters,vorIndices);

% xcorr of 1st and 2nd tier angles/lengths to find best alignment
%   finding angle: could just step in 1 degree increments
%   could slide to next matched pair
%   determine best fit by local mins of angle/length pt to pt distances,
%      use circular mean approximation to get these pt distances.
%   Could add optional limit at this step
tiersCheck = 2;
cellsCheck = vorAdjTiers > 0 & vorAdjTiers<=tiersCheck;

rotationsTry = 0:1:359;
for cellI = 1:numCells
    theseCells= cellsCheck(cellI,:);
    theseDist = allDistances(cellI,theseCells);
    theseAngles = allAngles(cellI,theseCells);
    
    thisCenter = allCenters(cellI,:);
    vorCentersShift = [allCenters(:,1)-thisCenter(1), allCenters(:,2)-thisCenter(2)];
    
    theseCenters = vorCentersShift(theseCells,:);
    theseDistSelf = allDistances(theseCells,theseCells);
    theseDistSelf(theseDistSelf==0)=NaN;
    
    for cellJ = 1:numCells%but would be another session
    %How to xcorr when have different numbers of points 
        cellsJ = cellsCheck(cellJ,:); %but actually this needs to be from vorAdjTiers for session B
        distJ = allDistances(cellJ,cellsJ);
        anglesJ = allAngles(cellJ,cellsJ);
        
        centerJ = allCenters(cellJ,:);
        vorCentersShiftJ = [allCenters(:,1)-centerJ(1), allCenters(:,2)-centerJ(2)];
        centersJ = vorCentersShiftJ(cellsJ,:);
        theseDistSelfJ = allDistances(cellsJ,cellsJ);
        theseDistSelfJ(theseDistSelfJ==0)=NaN;
        
        [pairedDistances,~] = GetAllPtToPtDistances2(theseCenters(:,1),theseCenters(:,2),centersJ(:,1),centersJ(:,2),[]);
        
        %Refine paired distances by less than pt-to-pt distances for each voronoi local set of cells
        pdRefA = pairedDistances < min(theseDistSelf,[],2);
        pdRefB = pairedDistances < min(theseDistSelfJ,[],1);
        
        %for ties, just pick one of each; this works for multiway ties too
        
        FindConstellationAlignments(theseAngles,theseDist,anglesJ,distJ)
        [pairsHave, distHere, ranks] = FindLowestRankPairs(pairedDistances);
        %{
        figure; hold on;
        for cc = 1:length(theseCenters)
            plot([0 theseCenters(cc,1)],[0 theseCenters(cc,2)],'b')
            plot(theseCenters(cc,1),theseCenters(cc,2),'ob')
        end
        for cc = 1:length(cellsJ)
            plot([0 centersJ(cc,1)],[0 centersJ(cc,2)],'r')
            plot(centersJ(cc,1),centersJ(cc,2),'or')
        end
        
        for pp = 1:size(pairsHave,1)
            plot([theseCenters(pairsHave(pp,1),1) centersJ(pairsHave(pp,2),1)],...
                 [theseCenters(pairsHave(pp,1),2) centersJ(pairsHave(pp,2),2)],'m')
        end
        %}
        
        %Compare all rotations:
        %figure; plot(theseCenters(1,1),theseCenters(1,2),'*r'); hold on
        xRotated = [];
        yRotated = [];
        pairsHave = [];
        distHere = [];
        for rsI = 1:length(rotationsTry)
            %Rotate pts
            [xRotated{rsI},yRotated{rsI}] = RotatePts(theseCenters(:,1),theseCenters(:,2),rotationsTry(rsI));
            %Get pt to pt distances
            [pairedDistances3,~] = GetAllPtToPtDistances2(xRotated{rsI},yRotated{rsI},centersJ(:,1),centersJ(:,2),[]);
            %Find alignment distance
            [pairsHave{rsI}, distHere{rsI}, ~] = FindLowestRankPairs(pairedDistances3);
            
            %if rsI > 1
            %plot([xRotated{rsI-1}(1) xRotated{rsI}(1)],[yRotated{rsI-1}(1) yRotated{rsI}(1)],'k')
            %axis equal
            %end
        end
    end
end
            
            
%% Vector to adjacent cells comparison2: testing it out against self
cd('E:\Marble11_180721')
load('FinalOutput.mat', 'NeuronImage')
allCentersA = getAllCellCenters(NeuronImage);
allCentersB = allCentersA;
numCells = size(allCentersA,1);

[vorVertices,vorIndices] = voronoin(allCentersA);
vorAdjacency = GetVoronoiAdjacency(vorIndices);
vorAdjTiers = GetAllTierAdjacency(vorAdjacency,10);

edgePolys = GetVoronoiEdges(vorVertices,allCentersA,vorIndices);

tiersCheck = 2;
cellsCheck = vorAdjTiers > 0 & vorAdjTiers<=tiersCheck;

rotationsTry = 0:5:359;

%Pre-allocate
pairsHave = cell(numCells,1);
distHere = cell(numCells,1);

%Try it out
tic
f = waitbar(0,'Please wait...');
for cellI = 1:numCells
    theseCells= cellsCheck(cellI,:);
    
    thisCenter = allCentersA(cellI,:);
    vorCentersShift = [allCentersA(:,1)-thisCenter(1), allCentersA(:,2)-thisCenter(2)];
    
    theseCenters = vorCentersShift(theseCells,:);
    
    %if ~(sum(edgePolys & theseCells) > 0 || edgePolys(cellI)==1)
    pairsHave{cellI} = cell(numCells,1);
    distHere{cellI} = cell(numCells,1);
    xRotated = [];
    yRotated = [];
    for rsJ = 1:length(rotationsTry)
       %Rotate pts
       [xRotated{rsJ},yRotated{rsJ}] = RotatePts(theseCenters(:,1),theseCenters(:,2),rotationsTry(rsJ));
    end
    for cellJ = 1:numCells%but would be another session
        cellsJ = cellsCheck(cellJ,:); %but actually this needs to be from vorAdjTiers for session B
       
        centerJ = allCentersB(cellJ,:);
        vorCentersShiftJ = [allCentersB(:,1)-centerJ(1), allCentersB(:,2)-centerJ(2)];
        theseCentersJ = vorCentersShiftJ(cellsJ,:);
        
        tic
        pds = cellfun(@(x,y) GetAllPtToPtDistances2(x,y,theseCentersJ(:,1),theseCentersJ(:,2),[]),xRotated,yRotated,'UniformOutput',false);
        [ph,dh] = cellfun(@FindLowestRankPairs,pds,'UniformOutput',false);
        toc
        
        tic
        for rsI = 1:length(rotationsTry)
            %%Rotate pts
            %[xRotated{rsI},yRotated{rsI}] = RotatePts(theseCenters(:,1),theseCenters(:,2),rotationsTry(rsI));
            %Get pt to pt distances
            [pairedDistances,~] = GetAllPtToPtDistances2(xRotated{rsI},yRotated{rsI},theseCentersJ(:,1),theseCentersJ(:,2),[]);
            %Find alignment distance
            [pairsHave{cellI}{cellJ}{rsI}, distHere{cellI}{cellJ}(:,rsI), ~] = FindLowestRankPairs(pairedDistances);
        end
        toc
        waitbar((cellJ+numCells*(cellI-1))/(numCells*numCells),f,['Testing Local Rotations ' num2str((cellJ+numCells*(cellI-1))) '/' num2str(numCells*numCells)]);
    end
end 
close(f)
toc

%% Trying to do differences of distances...
load('FinalOutput.mat', 'NeuronImage')
allCenters = getAllCellCenters(NeuronImage);
%{
limitedCells = sum(allCenters<250,2)==2;
NeuronImage = NeuronImage(limitedCells);
allCenters = getAllCellCenters(NeuronImage);
%}
[allDistances,withinRad] = GetAllPtToPtDistances(allCenters(:,1),allCenters(:,2),[]);
allAngles = GetAllPtToPtAngles(allCenters);
[vorVertices,vorIndices] = voronoin(allCenters);
allAreas = cell2mat(cellfun(@(x) polyarea(vorVertices(x,1),vorVertices(x,2)),vorIndices,'UniformOutput',false));
figure; voronoi(allCenters(:,1),allCenters(:,2))
title('Voronoi of all cells')
vorAdjacency = GetVoronoiAdjacency(vorIndices);
vorAdjTiers = GetAllTierAdjacency(vorAdjacency,10);
edgePolys = GetVoronoiEdges(vorVertices,allCenters,vorIndices);
vorAdjTiers(vorAdjTiers==0) = NaN;
vorAdjTiers(edgePolys,:) = NaN;
%Get up to 2nd tier voronoi adjacency
vorTwo = vorAdjTiers<=2; %logical
distTwo = allDistances(vorTwo);
anglesTwo = allAngles(vorTwo);
%Get differences of all angles and distances from each other
distanceDiffs = abs(distTwo - distTwo');
angleDiffs = anglesTwo - anglesTwo';
%Refine distances by typical roi width
rps=cellfun(@(x) regionprops(x,'majoraxis'),NeuronImage);
roiWidths = sort([rps.MajorAxisLength],'ascend');
%maxRoiWidth = roiWidths(round(0.95*length(roiWidths)))
maxRoiWidth = max(roiWidths);
distanceDiffs(distanceDiffs>maxRoiWidth) = NaN;
angleDiffs(distanceDiffs>maxRoiWidth) = NaN;
%angleDiffs = rectifyCircDistances(angleDiffs);
aBins = linspace(-2*pi,2*pi,30);
dBins = linspace(0,maxRoiWidth,100);
[hcs,~,~] = histcounts2(angleDiffs,distanceDiffs,aBins,dBins);
normHist = hcs/max(max(hcs));
histThresh = 0.9;
histPeaks = normHist > histThresh;
[ii,jj] = ind2sub([length(dBins) length(aBins)],find(histPeaks));
BW = bwboundaries(histPeaks);
%if any in B are more than 1 pixel, have to get all the pixels in that blob

% need to start using this refined to start doing an assignment...
%start a new thread of computation generated by angles found in hcs peak
cellI = 1;
cellIv2 = vorTwo(cellI,:);
cellIang = allAngles(cellI,cellIv2);
cellIdist = allDistance(cellI,cellIv2);
for cellJ = 1:numCells
   
   %Akaike thing... 
end

%%


[vorVertices,vorIndices] = voronoin(allCenters);
title('Voronoi of all cells')
vorAdjacency = GetVoronoiAdjacency(vorIndices);
vorAdjTiers = GetAllTierAdjacency(vorAdjacency,10);
edgePolys = GetVoronoiEdges(vorVertices,allCenters,vorIndices);
vorAdjTiers(vorAdjTiers==0) = NaN;
vorAdjTiers(edgePolys,:) = NaN;
find(edgePolys,1,'first')
vorTwo = vorAdjTiers<=2;
find(vorAdjTiers==1,1,'first')
distTwo = allDistances(vorTwo);
anglesTwo = allAngles(vorTwo);
dd = distTwo - distTwo';
aa = anglesTwo - anglesTwo';
edgePolys = GetVoronoiEdges(vorVertices,allCenters,vorIndices);
vorAdjTiers(vorAdjTiers==0) = NaN;
vorAdjTiers(edgePolys,:) = NaN;
find(edgePolys,1,'first')
vorTwo = vorAdjTiers<=2;
find(vorAdjTiers==1,1,'first')
distTwo = allDistances(vorTwo);
anglesTwo = allAngles(vorTwo);
