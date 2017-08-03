PlaceTuningCurveLin2(numShuffles, correctBounds, all_x_adj_cm,all_y_adj_cm,all_PSAbool,sessionInds, aboveThresh);

%Base PFs
if basePFs exists
    load it
else
PlaceTuningCurveLin(trialbytrial, aboveThresh, nPerms, xlims, cmperbin, xEdges)
end

resol = 1;
p = ProgressBar(100/resol);
update_inc = round(numShuffles/(100/resol));
for ts = 1:numShuffles
    offset = randi(min(cellfun(@length, all_PSAbool)));
    for pb = 1:length(all_PSAbool)
        new_all_PSAbool{pb} = [all_PSAbool{pb}(:,offset:end) all_PSAbool{pb}(:,1:(offset-1))];
    end
    
    trialbytrialShuffle = PoolTrialsAcrossSessions(correctBounds,all_x_adj_cm,all_y_adj_cm,new_all_PSAbool,sessionInds);
    [~, ~, ~, TMap_unsmoothed{ts}, ~, TMap_gauss{ts}] = PFsLinTrialbyTrial(trialbytrialShuffle,aboveThresh,0);
    
    p.progress;
end
p.stop;
%Sanity check: plot some rasters for this new trialbytrialShuffle

%For each cell get its tuning curves, separated by condition
tuning curves are in TMap_gauss{numShuffle,1}{cell,condition}
    probably there's a better way to organize this

%mean across those tuning curves for average
%sort, then 95% confidence intervals
%plot







sessionUse = false(size(aboveThresh{1,1}));
for ss = 1:4
    sessionUse = sessionUse + aboveThresh{1,ss}(:,:);
end
sessionUse = sessionUse > 0;