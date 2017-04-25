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

%Load stuff
load('Pos_align.mat','PSAbool'); 
binsize=2;
%FoL.statsFile...
%FoL.mapsFile...
files.stats.FoL = ['PlaceStats_forced_left_' num2str(binsize) 'cm.mat'];
files.stats.FoR = ['PlaceStats_forced_right_' num2str(binsize) 'cm.mat'];
files.stats.FrL = ['PlaceStats_free_left_' num2str(binsize) 'cm.mat'];
files.stats.FrR = ['PlaceStats_free_right_' num2str(binsize) 'cm.mat'];
files.maps.FoL = ['PlaceMaps_forced_left_' num2str(binsize) 'cm.mat'];
files.maps.FoR = ['PlaceMaps_forced_right_' num2str(binsize) 'cm.mat']; 
files.maps.FrL = ['PlaceMaps_free_left_' num2str(binsize) 'cm.mat'];
files.maps.FrR = ['PlaceMaps_free_right_' num2str(binsize) 'cm.mat'];
FoL.stats = load(files.stats.FoL);  FrL.stats = load(files.stats.FrL); 
FoR.stats = load(files.stats.FoR);  FrR.stats = load(files.stats.FrR); 
FoL.maps = load(files.maps.FoL);    FrL.maps = load(files.maps.FrL); 
FoR.maps = load(files.maps.FoR);    FrR.maps = load(files.maps.FrR); 
[FoL.stats,FoR.stats,FrL.stats,FrR.stats] = StructEqualizer(FoL.stats,FoR.stats,FrL.stats,FrR.stats);

numPFs = size(FoL.stats.PFcentroids,1);

%Cell activity per condition?
[conditionHits, isActive] = CellsInConditions(PSAbool, FoL, FoR, FrL, FrR);
figure; histogram(conditionHits(conditionHits<100 & conditionHits > 0),0:5:90)
hold on; mn = mean(conditionHits(conditionHits>0));
plot([mn mn],[0 80],'r','LineWidth',2)
title('Hits in a condition, all cells by all conditions')
xlabel('Number of hits')
activeConds = sum(isActive,2);
figure; h=histogram(activeConds,-0.5:1:4.5);
h.Parent.XTick=0:1:4;
title('Cells with >0 hits/condition')
xlabel('Conditions with a hit')
ylabel('Number of cells')
aboveThresh = conditionHits > 5;
condAboveThresh = sum(aboveThresh,2);
figure; h2 = histogram(activeConds,-0.5:1:4.5);
h2.Parent.XTick=0:1:4;
title('Cells with >5 hits/condition')
xlabel('Conditions above thresh')
ylabel('Number of cells')

%Bin centroids by type
FoCentroids = [FoL.stats.PFcentroids; FoR.stats.PFcentroids]; 
FrCentroids = [FrL.stats.PFcentroids; FrR.stats.PFcentroids];
Lcentroids = [FoL.stats.PFcentroids; FrL.stats.PFcentroids]; 
Rcentroids = [FoR.stats.PFcentroids; FrR.stats.PFcentroids];

fieldDims=size(FoL.maps.TotalRunOccMap);
%Match placefields across conditions by proximity
[LRmatches, LRmatchesExclusive]=MatchCentroidsBatch(Lcentroids, Rcentroids);
[FoFrmatches, FoFrmatchesExclusive]=MatchCentroidsBatch(FoCentroids, FrCentroids);

thereWasRemapping = ~cellfun(@isempty,LRmatches);
%LRmatchesBest[CentroidsA, CentroidsB, matches] = MatchCentroidsBest...
%    (PFcentroidsA, bestPFA, PFcentroidsB, bestPFB)

%Centroid distances
LRdistances = CentroidDistances(Lcentroids, Rcentroids, LRmatches);
LRdistancesExclusive = CentroidDistances(Lcentroids, Rcentroids, LRmatchesExclusive);
FoFrDistances = CentroidDistances(FoCentroids, FrCentroids, FoFrmatches);
FoFrDistancesExclusive = CentroidDistances(FoCentroids, FrCentroids, FoFrmatchesExclusive);
    %Attrition?
LRexclusiveLoss = sum(sum(LRdistances>0)) - sum(sum(LRdistancesExclusive>0));
FoFrexclusiveLoss = sum(sum(FoFrDistances>0)) - sum(sum(FoFrDistancesExclusive>0));

figure; histogram(LRdistancesExclusive(LRdistancesExclusive~=0),15)
title('L/R remapping distances'); xlabel('cm change'); ylabel('count')
figure; histogram(FoFrDistancesExclusive(FoFrDistancesExclusive~=0),15)
title('Forced/Free remapping distances'); xlabel('cm change'); ylabel('count')

%Place field overlap
[FoL.stats.PFpixels,FrL.stats.PFpixels,FoR.stats.PFpixels,FrR.stats.PFpixels ]...
    = CellArrayEqualizer...
    (FoL.stats.PFpixels,FrL.stats.PFpixels,FoR.stats.PFpixels,FrR.stats.PFpixels);
Lpixels = [FoL.stats.PFpixels; FrL.stats.PFpixels];
Rpixels = [FoR.stats.PFpixels; FrR.stats.PFpixels];
Fopixels = [FoL.stats.PFpixels; FoR.stats.PFpixels];
Frpixels = [FrL.stats.PFpixels; FrR.stats.PFpixels];
[LRoverlaps, pctLR]=PFoverLapBatch(Lpixels, Rpixels, LRmatches);
[LRoverlapsE, pctsLRE]=PFoverLapBatch(Lpixels, Rpixels, LRmatchesExclusive);
[FoFroverlaps, pctsFoFr]=PFoverLapBatch(Fopixels, Frpixels, FoFrmatches);
[FoFroverlapsE, pctsFoFrE]=PFoverLapBatch(Fopixels, Frpixels, FoFrmatchesExclusive);

%Centroid in other field
[LinR, RinL, LRinBoth, LReither]=CentroidinPFbatch...
    (Lcentroids, Rcentroids, Lpixels, Rpixels, LRmatches,fieldDims);
[LinRE, RinLE, LRinBothE, LReitherE]=CentroidinPFbatch...
    (Lcentroids, Rcentroids, Lpixels, Rpixels, LRmatchesExclusive,fieldDims);
[FoinFr, FrinFo, FoFrinBoth,FoFreither]=CentroidinPFbatch...
    (FoCentroids, FrCentroids, Fopixels, Frpixels, FoFrmatches,fieldDims);
[FoinFrE, FrinFoE, FoFrinBothE,FoFreitherE]=CentroidinPFbatch...
    (FoCentroids, FrCentroids, Fopixels, Frpixels, FoFrmatchesExclusive,fieldDims);

%Plot something:
LRplace = CentroidOverlapPlot(LRdistances, LRoverlaps, LReither);
LRplaceE = CentroidOverlapPlot(LRdistancesExclusive, LRoverlapsE, LReitherE);
title('Left > Right place remapping')
FoFrplace = CentroidOverlapPlot(FoFrDistances, FoFroverlaps, FoFreither);
FoFrplaceE = CentroidOverlapPlot(FoFrDistancesExclusive, FoFroverlapsE, FoFreitherE);
title('Forced > Free place remapping')

%Rate remapping
posThresh = 3; hitThresh=3;

rateDiffLR = PFrateChangeBatch(FoL, FoR, hitThresh, posThresh);
rateDiffLR = [rateDiffLR; PFrateChangeBatch(FrL, FrR, hitThresh, posThresh)];
rateDiffFoFr = PFrateChangeBatch(FoL, FrL, hitThresh, posThresh);
rateDiffFoFr = [rateDiffFoFr; PFrateChangeBatch(FoR, FrR, hitThresh, posThresh)];

figure; histogram(abs(rateDiffFoFr),0:0.05:1); title('Forced/Free rate changes')
xlabel('Difference / Sum'); ylabel('Frequency')
figure; histogram(abs(rateDiffLR),0:0.05:1); title('Left/Right rate changes')
xlabel('Difference / Sum'); ylabel('Frequency')

% Population Vectors
[PixCorrFoLR, pvalFoLR] = PopVectorCorr(FoL, FoR, posThresh);
[PixCorrFrLR, pvalFrLR] = PopVectorCorr(FrL, FrR, posThresh);

[PixCorrLFoFr, pvalLFoFr] = PopVectorCorr(FoL, FrL, posThresh);
[PixCorrRFoFr, pvalRFoFr] = PopVectorCorr(FoR, FrR, posThresh);

[PixCorrLFoRFr, pvalLFoRFr] = PopVectorCorr(FoL, FrR, posThresh);
[PixCorrRFoLFr, pvalRFoLFr] = PopVectorCorr(FoR, FrL, posThresh);


figure;
subplot(2,2,1)
histogram(PixCorrFoLR, 0:0.05:1); title('PV corr, Forced L>R')
ylabel('Frequency')
subplot(2,2,2)
histogram(PixCorrFrLR, 0:0.05:1); title('PV corr, Free L>R')
subplot(2,2,3)
histogram(PixCorrLFoFr, 0:0.05:1); title('PV corr, Left Forced>Free')
ylabel('Frequency')
xlabel('Corr coeff')
subplot(2,2,4)
histogram(PixCorrRFoFr, 0:0.05:1); title('PV corr, Right Forced>Free')
xlabel('Corr coeff')

figure; 
subplot(2,2,[1 2])
histogram([PixCorrFoLR; PixCorrFrLR],0:0.05:1)
title('PV correlation Left to Right')
ylabel('Frequency')
subplot(2,2,[3 4])
histogram([PixCorrLFoFr; PixCorrRFoFr],0:0.05:1)  
title('PV correlation Forced to Free')
ylabel('Frequency')
xlabel('Corr coeff')
    
%Boneyard
%{
%Fluoresence rate mapping
load('FinalOutput.mat','NeuronTraces');
LPtraces = NeuronTraces.LPtrace;

fluorDiffLR(1:numPFs,:) = PFfluorDiffBatch...
    (FoL, FoR, LPtraces, LRmatchesExclusive(1:numPFs,:), hitThresh, posThresh);
fluorDiffLR((1:numPFs)+numPFs,:) = PFfluorDiffBatch...
    (FrL, FrR, LPtraces, LRmatchesExclusive((1:numPFs)+numPFs,:), hitThresh, posThresh);
fluorDiffFoFr(1:numPFs,:) = PFfluorDiffBatch...
    (FoL, FrL, LPtraces, FoFrmatchesExclusive(1:numPFs,:), hitThresh, posThresh);
fluorDiffFoFr((1:numPFs)+numPFs,:) = PFfluorDiffBatch...
    (FoR, FrR, LPtraces, FoFrmatchesExclusive((1:numPFs)+numPFs,:), hitThresh, posThresh);

figure; histogram(abs(rateDiffFoFr),0:0.05:1); title('Forced/Free fluoresence changes')
xlabel('Difference / Sum'); ylabel('Frequency')
figure; histogram(abs(rateDiffLR),0:0.05:1); title('Left/Right fluoresence changes')
xlabel('Difference / Sum'); ylabel('Frequency')
%}
%{
LRmatches = cell(numPFs*2,1); FoFrmatches = cell(numPFs*2,1);
LRmatchesExclusive = cell(numPFs*2,1); FoFrmatchesExclusive = cell(numPFs*2,1);
for PFrow = 1:numPFs
    if any([FoLcentroids{PFrow,:}]) && any([FoRcentroids{PFrow,:}])
        [LRmatches{PFrow,1}, LRmatchesExclusive{PFrow,1}]...
            = MatchCentroids (FoLcentroids, PFrow, FoRcentroids, PFrow);
    end
    if any([FoLcentroids{PFrow,:}]) && any([FrLcentroids{PFrow,:}])
        [FoFrmatches{PFrow,1}, FoFrmatchesExclusive{PFrow,1}]...
            = MatchCentroids (FoLcentroids, PFrow, FrLcentroids, PFrow);
    end
end
for PFrow = 1:numPFs
    if any([FrLcentroids{PFrow,:}]) && any([FrRcentroids{PFrow,:}])
    [LRmatches{PFrow+numPFs,1}, LRmatchesExclusive{PFrow+numPFs,1}]...
        = MatchCentroids (FrLcentroids, PFrow, FrRcentroids, PFrow);
    end
    if any([FoRcentroids{PFrow,:}]) && any([FrRcentroids{PFrow,:}])
    [FoFrmatches{PFrow+numPFs,1}, FoFrmatchesExclusive{PFrow+numPFs,1}]...
        = MatchCentroids (FoRcentroids, PFrow, FrRcentroids, PFrow);
    end
end
%}

%[PFepochPSA] = PFepochToPSAtime ( place_stats_file, isRunningInds, pos_file )
%allPFtime = AllTimeInField (place_maps_file, place_stats_file)
%{
[LRdiff, LRpct] = dumbRateRemapping([FoL.stats.PFpcthits; FrL.stats.PFpcthits],...
                        [FoR.stats.PFpcthits; FrR.stats.PFpcthits], LRmatchesExclusive);
[FoFrdiff, FoFrpct] = dumbRateRemapping([FoL.stats.PFpcthits; FoR.stats.PFpcthits],...
                        [FrL.stats.PFpcthits; FrR.stats.PFpcthits],FoFrmatchesExclusive);
                    
[LRdiff, LRpct]=dumbMoreRateRemapping([FoL.stats.PFpcthits; FrL.stats.PFpcthits],...
                        [FoR.stats.PFpcthits; FrR.stats.PFpcthits], matches)                    

[LRdiff, LRpct] = dumbRateRemapping([FoL.stats.PFactivePSA; FrL.stats.PFactivePSA],...
                        [FoR.stats.PFactivePSA; FrR.stats.PFactivePSA], LRmatchesExclusive);
[FoFrdiff, FoFrpct] = dumbRateRemapping([FoL.stats.PFactivePSA; FoR.stats.PFactivePSA],...
                        [FrL.stats.PFactivePSA; FrR.stats.PFactivePSA],FoFrmatchesExclusive);


[FoL.stats.allActivity, FoL.stats.meanActivity]=dumbRates(FoL.stats.PFactivePSA);
[FoR.stats.allActivity, FoR.stats.meanActivity]=dumbRates(FoR.stats.PFactivePSA);
[FrL.stats.allActivity, FrL.stats.meanActivity]=dumbRates(FrL.stats.PFactivePSA);
[FrR.stats.allActivity, FrR.stats.meanActivity]=dumbRates(FrR.stats.PFactivePSA);

[LRdiff, LRpct] = dumbRateRemapping([FoL.stats.allActivity; FrL.stats.allActivity],...
                        [FoR.stats.allActivity; FrR.stats.allActivity], LRmatchesExclusive);
[FoFrdiff, FoFrpct] = dumbRateRemapping([FoL.stats.allActivity; FoR.stats.allActivity],...
                        [FrL.stats.allActivity; FrR.stats.allActivity],FoFrmatchesExclusive);
%}    

%Need to do
