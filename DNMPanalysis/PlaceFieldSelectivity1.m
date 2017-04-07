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
title('Forced(-) / Free(+) selectivity distribution, ' num2str(thisUse) ' cells'])

figure; plot(LRselectivity, FoFrselectivity, '.')
title('Relationship of left/right and forced/free?')



