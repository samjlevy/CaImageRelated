FoL.statsFile = 'Placefields_forced_l_2p5cm.mat';
FoR.statsFile = 'Placefields_forced_r_2p5cm.mat';
FoL.mapsFile = 'Placefields_forced_l_2p5cm.mat';
FoR.mapsFile = 'Placefields_forced_r_2p5cm.mat';
FoR.statsFile = 'PlaceStats_forced_r_2p5cm.mat';
FoL.statsFile = 'PlaceStats_forced_l_2p5cm.mat';
FoL.stats = load(FoL.statsFile);
FoR.stats = load(FoR.statsFile);
FoL.maps = load(FoL.mapsFile);
FoR.maps = load(FoR.mapsFile);

FrL.statsFile = 'Placefields_free_l_2p5cm.mat';
FrR.statsFile = 'Placefields_free_r_2p5cm.mat';
FrL.mapsFile = 'Placefields_free_l_2p5cm.mat';
FrR.mapsFile = 'Placefields_free_r_2p5cm.mat';
FrR.statsFile = 'PlaceStats_free_r_2p5cm.mat';
FrL.statsFile = 'PlaceStats_free_l_2p5cm.mat';
FrL.stats = load(FrL.statsFile);
FrR.stats = load(FrR.statsFile);
FrL.maps = load(FrL.mapsFile);
FrR.maps = load(FrR.mapsFile);

[PixCorrFoLR, pvalFoLR, ShuffleCorrsFo, goodCellsFo] =...
    PopVectorCorr(FoL1, FoR1, posThresh, excludeSilent, numShuffles);

[PixCorrFrLR, pvalFrLR, ShuffleCorrsFr, goodCellsFr] =...
    PopVectorCorr(FrL, FrR, posThresh, excludeSilent, numShuffles);


figure; histogram(PixCorrFrLR,-1:0.1:1)
title('Free')
figure; histogram(ShuffleCorrsFr,-1:0.1:1)
title('Free shuffled')
figure; histogram(PixCorrFoLR,-1:0.1:1)
title('Forced')
figure; histogram(ShuffleCorrsFo,-1:0.1:1)
title('Forced shuffled')