xls_file = dir('*BrainTime_Adjusted.xlsx');
[frames, txt] = xlsread(xls_file.name, 1);
load('Pos_align.mat')

figure; plot(x_adj_cm,y_adj_cm,'.k')
hold on
plot(x_adj_cm(frames(:,2)),y_adj_cm(frames(:,2)),'.m')
plot(x_adj_cm(frames(:,3)),y_adj_cm(frames(:,3)),'.y')
plot(x_adj_cm(frames(:,8)),y_adj_cm(frames(:,8)),'.r')
plot(x_adj_cm(frames(:,9)),y_adj_cm(frames(:,9)),'.g')
title('Block boundaries after adjustment')

xls_file = dir('*BrainTime.xlsx');
[frames2, txt2] = xlsread(xls_file.name, 1);
figure; plot(x_adj_cm,y_adj_cm,'.k')
hold on
plot(x_adj_cm(frames2(:,2)),y_adj_cm(frames2(:,2)),'.m')
plot(x_adj_cm(frames2(:,14)),y_adj_cm(frames2(:,14)),'.y')
plot(x_adj_cm(frames2(:,3)),y_adj_cm(frames2(:,3)),'.r')
plot(x_adj_cm(frames2(:,15)),y_adj_cm(frames2(:,15)),'.g')
title('Block boundaries before adjustment')

figure; histogram(LRdistancesExclusive(LRdistancesExclusive>0),20)
title('Distance between placefield centers, L > R')


figure; histogram(FoFrDistancesExclusive(FoFrDistancesExclusive>0),20)
title('Distance between placefield centers, Forced > Free')

blank = zeros(76,61);
field1 = blank; field1(Fopixels{13,1})=1;
field2 = blank; field2(Fopixels{13,2})=1;
field3 = blank; field3(Frpixels{13,1})=1;
field4 = blank; field4(Frpixels{13,2})=1;

field1to4 = field1;
field1to4(Frpixels{13,2}) = 0.5;
overlap = ismember(Fopixels{13,1},Frpixels{13,2});
field1to4(Fopixels{13,1}(overlap)) = 0.75;
figure; imagesc(field1to4)
hold on 
plot(FoLcentroids{13,1}(1),FoLcentroids{13,1}(2),'*r')
plot(FrLcentroids{13,2}(1),FrLcentroids{13,2}(2),'*r')
title('Cell 13, field 1 remapping, Forced > Free')

field2to3 = field2;
field2to3(Frpixels{13,1}) = 0.5;
overlap = ismember(Fopixels{13,2},Frpixels{13,1});
field2to3(Fopixels{13,2}(overlap)) = 0.75;
figure; imagesc(field2to3)
hold on 
plot(FoLcentroids{13,2}(1),FoLcentroids{13,2}(2),'*r')
plot(FrLcentroids{13,1}(1),FrLcentroids{13,1}(2),'*r')
title('Cell 13, field 2 remapping, Forced > Free')

[FoL.stats.PFpcthits, FoR.stats.PFpcthits, FrL.stats.PFpcthits, FrR.stats.PFpcthits]...
    =CellArrayEqualizer(FoL.stats.PFpcthits, FoR.stats.PFpcthits, FrL.stats.PFpcthits, FrR.stats.PFpcthits);
FoHits = [FoL.stats.PFpcthits; FoR.stats.PFpcthits];
FrHits = [FrL.stats.PFpcthits; FrR.stats.PFpcthits];

figure; histogram(abs(LRpct),20)
title('Percent change in remapping L/R')
figure; histogram(abs(FoFrpct),20)
title('Percent change in remapping Forced/Free')