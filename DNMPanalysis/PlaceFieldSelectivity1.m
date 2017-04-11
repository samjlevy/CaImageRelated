names = {'_forced_left1cmbins.mat', '_forced_right1cmbins.mat',...
        '_free_left1cmbins.mat', '_free_right1cmbins.mat'};

i=0;
i=i+1;
forcedLhits = load(['PlaceFieldStats',names{i}],'PFnHits');
FoLallhits = sum(forcedLhits.PFnHits,2);
i=i+1;
forcedRhits = load(['PlaceFieldStats',names{i}],'PFnHits');
FoRallhits = sum(forcedRhits.PFnHits,2);
i=i+1;
freeLhits = load(['PlaceFieldStats',names{i}],'PFnHits');
FrLallhits = sum(freeLhits.PFnHits,2);
i=i+1;
freeRhits = load(['PlaceFieldStats',names{i}],'PFnHits');
FrRallhits = sum(freeRhits.PFnHits,2);


totalHits = FoLallhits + FoRallhits + FrLallhits + FrRallhits;
firedThisSess = totalHits > 0;
LRselectivity = ((FoRallhits + FrRallhits) - (FoLallhits + FrLallhits))./totalHits;
LRhitDiff = ((FoRallhits + FrRallhits) - (FoLallhits + FrLallhits));

FoFrselectivity = ((FrLallhits+ FrRallhits) - (FoLallhits + FoRallhits ))./totalHits;
FoFrhitDiff = ((FrLallhits+ FrRallhits) - (FoLallhits + FoRallhits ));

blocksWithHits = [FoLallhits>0, FoRallhits>0, FrLallhits>0, FrRallhits>0];
blocksFiredIn = sum(blocksWithHits,2);

moreThan1 = blocksFiredIn>1;

thisUse = moreThan1 & ~placeRemap; %comes from spreadsheet


figure; histogram(blocksFiredIn,4)
title('Number of blocks a cell fired in')

figure; histogram(LRhitDiff(LRhitDiff~=0 & blocksFiredIn>0)); title('Raw L/R hit difference')
figure; histogram(FoFrhitDiff(FoFrhitDiff~=0 & blocksFiredIn>0)); title('Raw Fo/Fr hit difference')


figure; histogram(abs(LRselectivity(thisUse)),20)%& LRselectivity~=0
howManyHere = sum(moreThan1 & LRselectivity~=0);
title(['Left(-) / Right(+) selectivity distribution, ' num2str(thisUse) ' cells'])

figure; histogram(abs(FoFrselectivity(thisUse)),20)%& FoFrselectivity~=0
howManyThere = sum(moreThan1 & FoFrselectivity~=0);
title(['Forced(-) / Free(+) selectivity distribution, ' num2str(thisUse) ' cells'])

figure; plot(LRselectivity, FoFrselectivity, '.')
title('Relationship of left/right and forced/free?')

%Forced to free distances
%load placefield centroids
FoL.stats = load('PlaceFieldStats_forced_left1cmbins.mat'); 
FrL.stats = load('PlaceFieldStats_free_left1cmbins.mat'); 
FoR.stats = load('PlaceFieldStats_forced_right1cmbins.mat'); 
FrR.stats = load('PlaceFieldStats_free_right1cmbins.mat'); 
FoL.maps = load('PlaceMaps_forced_left1cmbins.mat'); 
FrL.maps = load('PlaceMaps_free_left1cmbins.mat'); 
FoR.maps = load('PlaceMaps_forced_right1cmbins.mat'); 
FrR.maps = load('PlaceMaps_free_right1cmbins.mat'); 
FoLcentroids = FoL.stats.PFcentroids; FrLcentroids = FrL.stats.PFcentroids;
FoRcentroids = FoR.stats.PFcentroids; FrRcentroids = FrR.stats.PFcentroids;
mostCells = max([size(FoLcentroids,2) size(FoRcentroids,2)...
                 size(FrLcentroids,2) size(FrRcentroids,2)]);
[FoLcentroids, FoRcentroids, FrLcentroids, FrRcentroids] =...
    CellArrayEqualizer (FoLcentroids, FoRcentroids, FrLcentroids, FrRcentroids);  

%Build out to function
numPlacefields = size(FoLcentroids,1);
LRmatches = cell(numPlacefields*2,1); FoFrmatches = cell(numPlacefields*2,1);
LRmatchesExclusive = cell(numPlacefields*2,1); FoFrmatchesExclusive = cell(numPlacefields*2,1);
for PFrow = 1:numPlacefields
    if any([FoLcentroids{PFrow,:}]) && any([FoRcentroids{PFrow,:}])
        [LRmatches{PFrow,1}, LRmatchesExclusive{PFrow,1}]...
            = MatchCentroids (FoLcentroids, PFrow, FoRcentroids, PFrow);
    end
    if any([FoLcentroids{PFrow,:}]) && any([FrLcentroids{PFrow,:}])
        [FoFrmatches{PFrow,1}, FoFrmatchesExclusive{PFrow,1}]...
            = MatchCentroids (FoLcentroids, PFrow, FrLcentroids, PFrow);
    end
end
for PFrow = 1:numPlacefields
    if any([FrLcentroids{PFrow,:}]) && any([FrRcentroids{PFrow,:}])
    [LRmatches{PFrow+numPlacefields,1}, LRmatchesExclusive{PFrow+numPlacefields,1}]...
        = MatchCentroids (FrLcentroids, PFrow, FrRcentroids, PFrow);
    end
    if any([FoRcentroids{PFrow,:}]) && any([FrRcentroids{PFrow,:}])
    [FoFrmatches{PFrow+numPlacefields,1}, FoFrmatchesExclusive{PFrow+numPlacefields,1}]...
        = MatchCentroids (FoRcentroids, PFrow, FrRcentroids, PFrow);
    end
end

%LRmatchesBest[CentroidsA, CentroidsB, matches] = MatchCentroidsBest...
%    (PFcentroidsA, bestPFA, PFcentroidsB, bestPFB)


FoCentroids = [FoLcentroids; FoRcentroids]; FrCentroids = [FrLcentroids; FrRcentroids];
Lcentroids = [FoLcentroids; FrLcentroids]; Rcentroids = [FoRcentroids; FrRcentroids];

LRdistances = CentroidDistances(Lcentroids, Rcentroids, LRmatches);
LRdistancesExclusive = CentroidDistances(Lcentroids, Rcentroids, LRmatchesExclusive);
FoFrDistances = CentroidDistances(FoCentroids, FrCentroids, FoFrmatches);
FoFrDistancesExclusive = CentroidDistances(FoCentroids, FrCentroids, FoFrmatchesExclusive);

LRexclusiveLoss = sum(sum(LRdistances>0)) - sum(sum(LRdistancesExclusive>0));
FoFrexclusiveLoss = sum(sum(FoFrDistances>0)) - sum(sum(FoFrDistancesExclusive>0));

figure; histogram(LRdistancesExclusive(LRdistancesExclusive~=0),15)
title('L/R remapping distances'); xlabel('cm change'); ylabel('count')
figure; histogram(FoFrDistancesExclusive(FoFrDistancesExclusive~=0),15)
title('Forced/Free remapping distances'); xlabel('cm change'); ylabel('count')

%This needs to be built out into a function
LROverlap=cell(numPlacefields*2,size(FoRcentroids,2));
for PFthis = 1:numPlaceFields
    theseMatches = [LRmatchesExclusive{PFthis,1}];
    if ~isempty(theseMatches)
        for match=1:length(theseMatches)
            if theseMatches(match)~=0
                FoLfield = FoL.maps.TMap_unsmoothed{1,theseMatches(match)};
                FoRfield = FoR.maps.TMap_unsmoothed{1,match};
                [LROverlap(PFthis,match), pctA(PFthis,match), pctB(PFthis,match)]...
                    = PlaceFieldOverlap(FoLfield, FoRfield);
            end
        end
    end
    FoFrMatch = [FoFrmatchesExclusive{PFthis,1}];
    if ~isempty(FoFrMatch)
        for matched=1:length(FoFrMatch)
            if FoFrMatch(match)~=0
                FoLfield = FoL.stats.PFpixels{1,FoFrMatch(match)};
                FrLfield = FrL.stats.PFpixels{1,match};
                [FoFrOverlap(PFthis), pctA(PFthis), pctB(PFthis)]...
                    = PlaceFieldOverlap(FoLfield, FrLfield);
            end
        end
    end
end
for PFthis = 1:numPlaceFields
    theseMatches = [LRmatchesExclusive{PFthis+numPlaceFields,1}];
    if ~isempty(theseMatches)
        for matched=1:length(theseMatches)
            if theseMatches(match)~=0
                FrLfield = FoL.stats.PFpixels{1,theseMatches(match)};
                FrRfield = FoL.stats.PFpixels{1,match};
                [FoFrOverlap(PFthis+numPlaceFields),...
                    pctA(PFthis+numPlaceFields), pctB(PFthis+numPlaceFields)]...
                    = PlaceFieldOverlap(FrLfield, FrRfield);
            end
        end
    end
    FoFrMatch = [FoFrmatchesExclusive{PFthis+numPlaceFields,1}];
    if ~isempty(FoFrMatch)
        for matched=1:length(FoFrMatch)
            if FoFrMatch(match)~=0
                FoRfield = FoR.stats.PFpixels{1,FoFrMatch(match)};
                FrRfield = FrR.stats.PFpixels{1,match};
                [FoFrOverlap(PFthis+numPlaceFields),...
                    pctA(PFthis+numPlaceFields), pctB(PFthis+numPlaceFields)]...
                    = PlaceFieldOverlap(FoRfield, FrRfield);
            end
        end
    end
end
    
    

    
    
    
    
    
    

