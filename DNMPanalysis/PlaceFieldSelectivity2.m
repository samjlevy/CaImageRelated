%PlaceFieldSelectivity2
orders = {'forced before free, left before right'};
cmperbin=2;

%File discovery
load SessionHalvesEpochs.mat
files = dir('Placefields*');
rightcm = cellfun(@any, (strfind({files.name},[num2str(cmperbin) 'cm'])));
rightcm = cellfun(@any, (strfind({files.name},'2p5cm')));
pfs = cellfun(@any, (strfind({files.name},'Placefields')));
pfFiles = find(pfs & rightcm & ([files.isdir]==0));
placeFiles = {files(pfFiles).name};

suffices = cellfun(@(x) x(13:end),placeFiles,'UniformOutput',false);
for pf = 1:length(placeFiles)
    thesePts = strsplit(suffices{1},'_');
    type{pf} = 



pieces = strsplit(placeFiles{1},'_');

isHalf = cellfun(@any, (strfind({files.name},'PT')));

binsize = 2;
posThresh = 3; 
hitThresh = 5;
numShuffles = 100;
part = 1;
FoL1.statsFile = ['PlaceStats_forced_l_' num2str(binsize) 'cmPT' num2str(part) '.mat'];
FrL1.statsFile = ['PlaceStats_free_l_' num2str(binsize) 'cmPT' num2str(part) '.mat'];
FoR1.statsFile = ['PlaceStats_forced_r_' num2str(binsize) 'cmPT' num2str(part) '.mat'];
FrR1.statsFile = ['PlaceStats_free_r_' num2str(binsize) 'cmPT' num2str(part) '.mat'];
FoL1.mapsFile = ['Placefields_forced_l_' num2str(binsize) 'cmPT' num2str(part) '.mat'];
FrL1.mapsFile = ['Placefields_free_l_' num2str(binsize) 'cmPT' num2str(part) '.mat'];
FoR1.mapsFile = ['Placefields_forced_r_' num2str(binsize) 'cmPT' num2str(part) '.mat'];
FrR1.mapsFile = ['Placefields_free_r_' num2str(binsize) 'cmPT' num2str(part) '.mat'];

FoL1.stats = load(FoL1.statsFile);  FrL1.stats = load(FrL1.statsFile); 
FoR1.stats = load(FoR1.statsFile);  FrR1.stats = load(FrR1.statsFile); 
FoL1.maps = load(FoL1.mapsFile);    FrL1.maps = load(FrL1.mapsFile); 
FoR1.maps = load(FoR1.mapsFile);    FrR1.maps = load(FrR1.mapsFile); 
FoL1.epochs = split1.forced_l;  FrL1.epochs = split1.free_l;
FoR1.epochs = split1.forced_r;  FrR1.epochs = split1.free_r;

part = 2;
FoL2.statsFile = ['PlaceStats_forced_l_' num2str(binsize) 'cmPT' num2str(part) '.mat'];
FrL2.statsFile = ['PlaceStats_free_l_' num2str(binsize) 'cmPT' num2str(part) '.mat'];
FoR2.statsFile = ['PlaceStats_forced_r_' num2str(binsize) 'cmPT' num2str(part) '.mat'];
FrR2.statsFile = ['PlaceStats_free_r_' num2str(binsize) 'cmPT' num2str(part) '.mat'];
FoL2.mapsFile = ['Placefields_forced_l_' num2str(binsize) 'cmPT' num2str(part) '.mat'];
FrL2.mapsFile = ['Placefields_free_l_' num2str(binsize) 'cmPT' num2str(part) '.mat'];
FoR2.mapsFile = ['Placefields_forced_r_' num2str(binsize) 'cmPT' num2str(part) '.mat'];
FrR2.mapsFile = ['Placefields_free_r_' num2str(binsize) 'cmPT' num2str(part) '.mat'];

FoL2.stats = load(FoL2.statsFile);  FrL2.stats = load(FrL2.statsFile); 
FoR2.stats = load(FoR2.statsFile);  FrR2.stats = load(FrR2.statsFile); 
FoL2.maps = load(FoL2.mapsFile);    FrL2.maps = load(FrL2.mapsFile); 
FoR2.maps = load(FoR2.mapsFile);    FrR2.maps = load(FrR2.mapsFile);
FoL2.epochs = split2.forced_l;  FrL2.epochs = split1.free_l;
FoR2.epochs = split2.forced_r;  FrR2.epochs = split1.free_r;

[FoL1.stats,FoR1.stats,FrL1.stats,FrR1.stats,FoL2.stats,FoR2.stats,FrL2.stats,FrR2.stats] =...
    StructEqualizer(FoL1.stats,FoR1.stats,FrL1.stats,FrR1.stats,FoL2.stats,FoR2.stats,FrL2.stats,FrR2.stats);

load('Pos_align.mat')


%PVcorr sefl correlations
[PixCorrFoL, pvalFoL] = PopVectorCorr(FoL1, FoL2, posThresh, numShuffles);
[PixCorrFoR, pvalFoR] = PopVectorCorr(FoR1, FoR2, posThresh);
[PixCorrFrL, pvalFrL] = PopVectorCorr(FrL1, FrL2, posThresh);
[PixCorrFrR, pvalFrR] = PopVectorCorr(FrR1, FrR2, posThresh);

figure;
subplot(2,2,1)
histogram(abs(PixCorrFoL), 0:0.05:1); title('PV corr, Forced L vs self')
ylabel('Frequency')
subplot(2,2,2)
histogram(abs(PixCorrFrL), 0:0.05:1); title('PV corr, Free L vs self')
subplot(2,2,3)
histogram(abs(PixCorrFoR), 0:0.05:1); title('PV corr, Forced R vs self')
ylabel('Frequency')
xlabel('Corr coeff')
subplot(2,2,4)
histogram(abs(PixCorrFrR), 0:0.05:1); title('PV corr, Free R vs self')
xlabel('Corr coeff')

figure;
subplot(2,2,1)
histogram(abs([PixCorrFoL; PixCorrFoR]), 0:0.05:1); title('PV corr, Forced vs self')
ylabel('Frequency')
subplot(2,2,2)
histogram(abs([PixCorrFrL; PixCorrFrR]), 0:0.05:1); title('PV corr, Free vs self')
subplot(2,2,3)
histogram(abs([PixCorrFoL; PixCorrFrL]), 0:0.05:1); title('PV corr, Left vs self')
ylabel('Frequency')
xlabel('Corr coeff')
subplot(2,2,4)
histogram(abs([PixCorrFoR; PixCorrFrR]), 0:0.05:1); title('PV corr, Right vs self')
xlabel('Corr coeff')

figure; 
subplot(2,2,[1 2])
histogram(abs([PixCorrFoL; PixCorrFoR]),0:0.05:1)
title('PV correlation Forced vs self')
ylabel('Frequency')
subplot(2,2,[3 4])
histogram(abs([PixCorrFrL; PixCorrFrR]),0:0.05:1)  
title('160831 PV correlation Forced to Free')
ylabel('Frequency')
xlabel('Corr coeff')