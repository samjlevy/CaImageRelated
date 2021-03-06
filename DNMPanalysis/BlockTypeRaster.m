Pix2Cm = 0.0874;
RoomStr = '201a - 2015';

load('Pos_align.mat')
xls_file = dir('*BrainTime_Adjusted.xlsx');
[frames, txt] = xlsread(xls_file.name, 1);
%% Stem Only:
%Get Trial timestamps
forced_starts = CondExcelParseout(frames, txt, 'Start on maze (start of Forced', 0);
free_starts = CondExcelParseout(frames, txt, 'Lift barrier (start of free choice)', 0);

forced_stem_ends = CondExcelParseout(frames, txt, 'ForcedChoiceEnter', 0);
if sum(forced_stem_ends)==0
    forced_stem_ends = CondExcelParseout(frames, txt, 'Forced Stem End', 0);
end
free_stem_ends = CondExcelParseout(frames, txt, 'FreeChoiceEnter', 0);
if sum(free_stem_ends)==0
    free_stem_ends = CondExcelParseout(frames, txt, 'Free Stem End', 0);
end

%Trial directions
[right_forced, left_forced, right_free, left_free] = DNMPtrialDirections(frames, txt);

%Good lap timestamps (video too short, FT too short, etc.)
tooLong = frames >= length(speed);%FTuseIndices(end)
GoodLaps = any(tooLong,2) == 0;

[C,ia,ic] = unique(frames,'rows');
for ur = 1:size(frames,1)
    [~,ia,~] = unique(frames(ur,:));
    MessedUp(ur,1) = length(ia) < size(frames,2); %#ok<SAGROW>
end
if any(MessedUp); disp('deleting some laps, overlap frames'); end
correct_trials = right_forced & left_free | ...
    left_forced & right_free;
allGood = GoodLaps & correct_trials;

%% get block of FT sorted by stem trial type
forced_r_stem = [forced_starts(allGood & right_forced), forced_stem_ends(allGood & right_forced)];
forced_l_stem = [forced_starts(allGood & left_forced), forced_stem_ends(allGood & left_forced)];
free_r_stem = [free_starts(allGood & right_free), free_stem_ends(allGood & right_free)];
free_l_stem = [free_starts(allGood & left_free), free_stem_ends(allGood & left_free)];
[ FoRindices, FoRedges ] = BlockOfFTindices( forced_r_stem(:,1), forced_r_stem(:,2));
[ FoLindices, FoLedges ] = BlockOfFTindices( forced_l_stem(:,1), forced_l_stem(:,2));
[ FrRindices, FrRedges ] = BlockOfFTindices( free_r_stem(:,1), free_r_stem(:,2));
[ FrLindices, FrLedges ] = BlockOfFTindices( free_l_stem(:,1), free_l_stem(:,2));

blockedFTstem = PSAbool(:,[FoRindices, FrRindices, FoLindices, FrLindices]);  

%% Get hit probability per trial type
[hitsForcedRight, totalHitsFoR ] = HitsThisBlock (forced_r_stem(:,1), forced_r_stem(:,2), PSAbool);
forcedRightHitProb = totalHitsFoR/size(forced_r_stem,1);
[hitsFreeRight, totalHitsFrR ] = HitsThisBlock (free_r_stem(:,1), free_r_stem(:,2), PSAbool);
freeRightHitProb = totalHitsFrR/size(free_r_stem,1);
[hitsForcedLeft, totalHitsFoL ] = HitsThisBlock (forced_l_stem(:,1), forced_l_stem(:,2), PSAbool);
forcedLeftHitProb = totalHitsFoL/size(forced_l_stem,1);
[hitsFreeLeft, totalHitsFrL ] = HitsThisBlock (free_l_stem(:,1), free_l_stem(:,2), PSAbool);
freeLeftHitProb = totalHitsFrL/size(free_l_stem,1);

totalHits = totalHitsFoR + totalHitsFrR +...
            totalHitsFoL + totalHitsFrL;
LRhitSelectivity = ((totalHitsFoR + totalHitsFrR) - ...
                    (totalHitsFoL + totalHitsFrL)) ./ totalHits;
ForcedFreeHITselectivity = ((totalHitsFrR + totalHitsFrL) -...
                        (totalHitsFoR + totalHitsFoL)) ./ totalHits;

%Get transient durations per trial type
[durFoR, totalDurFoR] = DurationsThisBlock(forced_r_stem(:,1), forced_r_stem(:,2), PSAbool);
[durFrR, totalDurFrR] = DurationsThisBlock(free_r_stem(:,1), free_r_stem(:,2), PSAbool);
[durFoL, totalDurFoL] = DurationsThisBlock(forced_l_stem(:,1), forced_l_stem(:,2), PSAbool);
[durFrL, totalDurFrL] = DurationsThisBlock(free_l_stem(:,1), free_l_stem(:,2), PSAbool);

totalDurAll = totalDurFoR + totalDurFrR + totalDurFoL + totalDurFrL;
LRdurSelectivity = ((totalDurFoR + totalDurFrR) - (totalDurFoL + totalDurFrL)) ./ totalDurAll;
ForcedFreeDurSelectivity = ((totalDurFrR + totalDurFrL) - (totalDurFoR + totalDurFoL)) ./ totalDurAll;

FoLselectiveCells = find(LRdurSelectivity < -0.1 & ForcedFreeDurSelectivity < -0.1);
FrLselectiveCells = find(LRdurSelectivity < -0.1 & ForcedFreeDurSelectivity > 0.1);
FoRselectiveCells = find(LRdurSelectivity > 0.1 & ForcedFreeDurSelectivity < -0.1);
FrRselectiveCells = find(LRdurSelectivity > 0.1 & ForcedFreeDurSelectivity > 0.1);

otherLogical = ones(size(PSAbool,1),1);
otherLogical([FoLselectiveCells; FrLselectiveCells; FoRselectiveCells; FrRselectiveCells]) = 0;
NonselectiveCells = find(otherLogical);

SortedInd = [FoRselectiveCells; FrRselectiveCells; FoLselectiveCells; FrLselectiveCells; NonselectiveCells];
SortedEdges = [0 length(FoRselectiveCells)];
SortedEdges = [SortedEdges SortedEdges(end)+length(FrRselectiveCells)];
SortedEdges = [SortedEdges SortedEdges(end)+length(FoLselectiveCells)];
SortedEdges = [SortedEdges SortedEdges(end)+length(FrLselectiveCells)];
SortedEdges = [SortedEdges SortedEdges(end)+length(NonselectiveCells)];

blockedFTstemEdges = [1 FoRedges(end)];
blockedFTstemEdges = [blockedFTstemEdges blockedFTstemEdges(end)+FrRedges(end)];
blockedFTstemEdges = [blockedFTstemEdges blockedFTstemEdges(end)+FoLedges(end)]; 
blockedFTstemEdges = [blockedFTstemEdges blockedFTstemEdges(end)+FrLedges(end)];

blockedSortedPSAstem = blockedFTstem(SortedInd,:);
%Duration-based correlation coefficients
%Rows are observations, columns are cells; but running in corrcoef transposed?
totalDurationVector = [totalDurFoR'; totalDurFrR'; totalDurFoL'; totalDurFrL'];
[totalDurCorrs, totalDurPs] = corrcoef(totalDurationVector');

trialDurationVector = [durFoR'; durFrR'; durFoL'; durFrL']; 
[trialDurCorrs2, trialDurPs2] = corrcoef(trialDurationVector');
trialBounds = [1 size(durFoR,2)];
trialBounds = [trialBounds trialBounds(end)+1 trialBounds(end)+size(durFrR,2)];
trialBounds = [trialBounds trialBounds(end)+1 trialBounds(end)+size(durFoL,2)];
trialBounds = [trialBounds trialBounds(end)+1 trialBounds(end)+size(durFrL,2)];
%% Stem Raster

stemFig=figure; imagesc(blockedSortedPSAstem); title('Stem Data, Europa 161020')
stemFig.Children.XTick = ceil(diff(blockedFTstemEdges,1)/2) + blockedFTstemEdges(1:4); 
stemFig.Children.XTickLabel = {'Forced Right', 'Free Right', 'Forced Left', 'Free Left'};
stemFig.Children.YTick = ceil(diff(SortedEdges,1)/2) + SortedEdges(1:5); 
stemFig.Children.YTickLabel = {'FoR', 'FrR', 'FoL', 'FrL', 'Other'};
xlabel('Time')
ylabel('Cell')
for edge=2:4
    hold on    
    plot([blockedFTstemEdges(edge) blockedFTstemEdges(edge)], [0 size(PSAbool,1)],'g')
end
for cellEdge = 2:5 
    hold on
    plot([0 size(PSAbool,2)], [SortedEdges(cellEdge) SortedEdges(cellEdge)],'r')
end


%% Better stem raster
[FoLtotalHits, FoLactiveLaps, FoLreliability] = CellsInConditions2(PSAbool, forced_l_stem(:,1), forced_l_stem(:,2));
[FoRtotalHits, FoRactiveLaps, FoRreliability] = CellsInConditions2(PSAbool, forced_r_stem(:,1), forced_r_stem(:,2));
[FrLtotalHits, FrLactiveLaps, FrLreliability] = CellsInConditions2(PSAbool, free_l_stem(:,1), free_l_stem(:,2));
[FrRtotalHits, FrRactiveLaps, FrRreliability] = CellsInConditions2(PSAbool, free_r_stem(:,1), free_r_stem(:,2));

allReliability = [FoLreliability, FoRreliability, FrLreliability,  FrRreliability];
useCells = find(sum(allReliability >= 0.5, 2)); 

epochs(1).starts = forced_l_stem(:,1);
epochs(1).stops = forced_l_stem(:,2);
epochs(2).starts = forced_r_stem(:,1);
epochs(2).stops = forced_r_stem(:,2);
epochs(3).starts = free_l_stem(:,1);
epochs(3).stops = free_l_stem(:,2);
epochs(4).starts = free_r_stem(:,1);
epochs(4).stops = free_r_stem(:,2);

plot_file = 'Cells Stem Rasters';
for plotCell = 1:length(useCells)
    thisCell = useCells(plotCell);
    rastPlot = PlotRaster1(x_adj_cm,epochs,PSAbool,thisCell);
    export_fig(plot_file,'-pdf','-append')
    close rastPlot
end
%% Demo figs
figure; imagesc(PSAbool); title('Raw Data, with stem time indicated')
for trial = find(allGood)
    hold on
    plot( [forced_starts(trial) forced_starts(trial)], [0 size(PSAbool,1)],'g' )
    plot( [forced_stem_ends(trial) forced_stem_ends(trial)], [0 size(PSAbool,1)],'r' )
    plot( [free_starts(trial) free_starts(trial)], [0 size(PSAbool,1)],'m' )
    plot( [free_stem_ends(trial) free_stem_ends(trial)], [0 size(PSAbool,1)],'y' )
end    
brainX = x_adj_cm; brainY = y_adj_cm;

%X/Y with stem points highlighted
figure;
plot (brainX, brainY, '.k','MarkerSize',3)
hold on
plot( brainX(forced_starts(allGood)), brainY(forced_starts(allGood)), '.g','MarkerSize',15)
plot( brainX(forced_stem_ends(allGood)), brainY(forced_stem_ends(allGood)), '.r','MarkerSize',15)
plot( brainX(free_starts(allGood)), brainY(free_starts(allGood)), '.m','MarkerSize',15)
plot( brainX(free_stem_ends(allGood)), brainY(free_stem_ends(allGood)), '.y','MarkerSize',15)
title('X/Y positions, with stem time indicated')



%lap blocks explanation
lapEdges = FoRedges(2:end);
lapEdges = [lapEdges FrRedges(2:end)+lapEdges(end)];
lapEdges = [lapEdges FoLedges(2:end)+lapEdges(end)];
lapEdges = [lapEdges FrLedges(2:end)+lapEdges(end)];
%for lapEdge=lapEdges
%    hold on
%    plot([lapEdges(lapEdge), lapEdges(lapEdge)], [0 size(PSAbool,1)],'r')
%end

%hit selectivity
figure; histogram(LRhitSelectivity,20); title('Left/Right hit selectivity')
figure; histogram(ForcedFreeHITselectivity,20); title('Forced/Free hit selectivity')
figure; plot(LRhitSelectivity, ForcedFreeHITselectivity,'.'); title('X: LR, Y: FoFr')

%firing duration selectivity
figure; histogram(LRdurSelectivity,20); title('Left/Right duration selectivity')
figure; histogram(ForcedFreeDurSelectivity,20); title('Forced/Free duration selectivity')
figure; plot(LRdurSelectivity, ForcedFreeDurSelectivity,'.','MarkerSize',12); title('X: LR, Y: FoFr')

%To do statistical significance: shuffle trial labels and redo correlation
%matrices, see how existing correlation compares do those:
%effectiveness: rate how much shuffled correlation looks like original (how
%many trials of one type are in each new block)


