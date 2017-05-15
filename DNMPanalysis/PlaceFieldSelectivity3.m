cmperbin = 2;
posThresh = 3; 
hitThresh = 5;
numShuffles = 100;
excludeSilent = 1;
load('Pos_align.mat')

filesOut = FindPlaceFiles (cmperbin, 0);

%load things
numTypes = length(filesOut.type);
isForced = cellfun(@(x) any(strfind(x,'forced')),filesOut.type);
isLeft = cellfun(@(x) any(strfind(x,'_l')),filesOut.type);
for tt = 1:numTypes
    data.(filesOut.type{tt}).maps = load(filesOut.placeFiles{tt});
    data.(filesOut.type{tt}).stats = load(filesOut.statsFiles{tt});
end

data = StructEqualizerXL(data);

%Get condition hits
load('stem_bounds.mat') %This needs to get generalized
for types = 1:numTypes
    data.(filesOut.type{types}).epochs =...
        stem_frame_bounds.(filesOut.type{types});
end

%Make population vectors
for trialType = 1:numTypes
    data.(filesOut.type{trialType}).PopVectors = ...
        PopVectorsMake(data.(filesOut.type{trialType}).maps.TMap_gauss);
end

%forced = find(isForced); free = find(~isForced);
%left = find(isLeft);     right = find(~isLeft);

[PixCorrFoLR, pvalFoLR, ShuffleCorrsFo, goodCellsFo] =...
    PopVectorCorr2(data.forced_l, data.forced_r, posThresh, hitThresh,...
    excludeSilent, numShuffles, PSAbool);
[PixCorrFrLR, pvalFrLR, ShuffleCorrsFr, goodCellsFr] =...
    PopVectorCorr2(data.free_l, data.free_r, posThresh, hitThresh,...
    excludeSilent, numShuffles, PSAbool);
[PixCorrLFoFr, pvalLFoFr, ShuffleCorrsFo, goodCellsFo] =...
    PopVectorCorr2(data.forced_l, data.free_l, posThresh, hitThresh,...
    excludeSilent, numShuffles, PSAbool);
[PixCorrRFoFr, pvalRFoFr, ShuffleCorrsFr, goodCellsFr] =...
    PopVectorCorr2(data.forced_r, data.free_r, posThresh, hitThresh,...
    excludeSilent, numShuffles, PSAbool);


figure; histogram(PixCorrFrLR,-1:0.1:1)
title('Free')
hold on
plot([mean(PixCorrFrLR) mean(PixCorrFrLR)],[0 5],'r')
figure; histogram(PixCorrFoLR,-1:0.1:1)
title('Forced')
hold on
plot([mean(PixCorrFoLR) mean(PixCorrFoLR)],[0 5],'r')
figure; histogram(PixCorrLFoFr,-1:0.1:1)
title('Left')
hold on
plot([mean(PixCorrLFoFr) mean(PixCorrLFoFr)],[0 5],'r')
figure; histogram(PixCorrRFoFr,-1:0.1:1)
title('Right') 
hold on
plot([mean(PixCorrRFoFr) mean(PixCorrRFoFr)],[0 5],'r')

figure; histogram(ShuffleCorrsFo,-1:0.1:1)
title('Forced shuffled')
figure; histogram(ShuffleCorrsFr,-1:0.1:1)
title('Free shuffled')


std(PixCorrFrLR)
std(PixCorrFoLR)
std(PixCorrLFoFr)
std(PixCorrRFoFr)