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



orders = {'forced before free, left before right'};

files.stats.FoL = 'PlaceStats_forced_left_1cm.mat';
files.stats.FoR = 'PlaceStats_forced_right_1cm.mat';
files.stats.FrL = 'PlaceStats_free_left_1cm.mat';
files.stats.FrR = 'PlaceStats_free_right_1cm.mat';
files.maps.FoL = 'PlaceMaps_forced_left_1cm.mat';
files.maps.FoR = 'PlaceMaps_forced_right_1cm.mat'; 
files.maps.FrL = 'PlaceMaps_free_left_1cm.mat';
files.maps.FrR = 'PlaceMaps_free_right_1cm.mat';
FoL.stats = load(files.stats.FoL);  FrL.stats = load(files.stats.FrL); 
FoR.stats = load(files.stats.FoR);  FrR.stats = load(files.stats.FrR); 
FoL.maps = load(files.maps.FoL);    FrL.maps = load(files.maps.FrL); 
FoR.maps = load(files.maps.FoR);    FrR.maps = load(files.maps.FrR); 
FoLcentroids = FoL.stats.PFcentroids; FrLcentroids = FrL.stats.PFcentroids;
FoRcentroids = FoR.stats.PFcentroids; FrRcentroids = FrR.stats.PFcentroids;
mostCells = max([size(FoLcentroids,2) size(FoRcentroids,2)...
                 size(FrLcentroids,2) size(FrRcentroids,2)]);
[FoLcentroids, FoRcentroids, FrLcentroids, FrRcentroids] =...
    CellArrayEqualizer (FoLcentroids, FoRcentroids, FrLcentroids, FrRcentroids);  


FoCentroids = [FoLcentroids; FoRcentroids]; FrCentroids = [FrLcentroids; FrRcentroids];
Lcentroids = [FoLcentroids; FrLcentroids]; Rcentroids = [FoRcentroids; FrRcentroids];

numPlacefields = size(FoLcentroids,1);

[LRmatches, LRmatchesExclusive]=MatchCentroidsBatch(Lcentroids, Rcentroids);
[FoFrmatches, FoFrmatchesExclusive]=MatchCentroidsBatch(FoCentroids, FrCentroids);

thereWasRemapping = ~cellfun(@isempty,LRmatches);
%LRmatchesBest[CentroidsA, CentroidsB, matches] = MatchCentroidsBest...
%    (PFcentroidsA, bestPFA, PFcentroidsB, bestPFB)

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

[FoL.stats.PFpixels,FrL.stats.PFpixels,FoR.stats.PFpixels,FrR.stats.PFpixels ]...
    = CellArrayEqualizer...
    (FoL.stats.PFpixels,FrL.stats.PFpixels,FoR.stats.PFpixels,FrR.stats.PFpixels);
Lpixels = [FoL.stats.PFpixels; FrL.stats.PFpixels];
Rpixels = [FoR.stats.PFpixels; FrR.stats.PFpixels];
Fopixels = [FoL.stats.PFpixels; FoR.stats.PFpixels];
Frpixels = [FrL.stats.PFpixels; FrR.stats.PFpixels];
[LRoverlaps, pctsL, pctsR]=PFoverLapBatch(Lpixels, Rpixels, LRmatches);
[LRoverlapsE, pctsLE, pctsRE]=PFoverLapBatch(Lpixels, Rpixels, LRmatchesExclusive);
[FoFroverlaps, pctsFo, pctsFr]=PFoverLapBatch(Fopixels, Frpixels, FoFrmatches);
[FoFroverlapsE, pctsFoE, pctsFrE]=PFoverLapBatch(Fopixels, Frpixels, FoFrmatchesExclusive);
    
%Rate remapping
[PFepochPSA] = PFepochToPSAtime ( place_stats_file, isRunningInds, pos_file )
allPFtime = AllTimeInField (place_maps_file, place_stats_file)


%Need to do
% - check PF time things (PFepochToPSAtime, AllTimeInField) worked
% - adapt hit rate, duration, etc. for PF time
% - validate PFoverlaps, make some figures
% - dist of PF overlaps against centroid distance
    
    
    
%Boneyard
%{
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
%}

