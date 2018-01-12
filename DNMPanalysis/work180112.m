%New work, prep figures for paper writing

load('PFsLin8bin.mat')
load('trialbytrial.mat')
[rates, normrates, rateDiff, rateDIall, rateDI] = LookAtSplitters2(TMap_unsmoothed);
lapPctThresh = 0.25;
consecLapThresh = 3;
[dayUse,threshAndConsec] = GetUseCells(trialbytrial, lapPctThresh, consecLapThresh);
figure; 
subplot(2,2,1); histogram(rateDI.StudyLvR(logical(dayUse)),[-1.05:0.1:1.05])
title('Study LvR'); xlabel('L   R'); xlim([-1 1])
subplot(2,2,2); histogram(rateDI.TestLvR(logical(dayUse)),[-1.05:0.1:1.05])
title('Test LvR'); xlabel('L   R'); xlim([-1 1])
subplot(2,2,3);histogram(rateDI.LeftSvT(logical(dayUse)),[-1.05:0.1:1.05])
title('Left SvT'); xlabel('S   T'); xlim([-1 1])
subplot(2,2,4);histogram(rateDI.RightSvT(logical(dayUse)),[-1.05:0.1:1.05])
title('Right SvT'); xlabel('S   T'); xlim([-1 1])
suptitle('Splitting DIs, mean of rate bins with activity, active cells') 


figure; 
subplot(2,2,1); histogram(rateDI.StudyLvR(logical(dayUse)),[-1.05:0.1:1.05])
hold on; histogram(rateDI.StudyLvR(logical(dayUse.*thisCellSplitsLR.StudyLvR)),[-1.05:0.1:1.05])
title('Study LvR'); xlabel('L   R'); xlim([-1 1])
subplot(2,2,2); histogram(rateDI.TestLvR(logical(dayUse)),[-1.05:0.1:1.05])
hold on; histogram(rateDI.TestLvR(logical(dayUse.*thisCellSplitsLR.TestLvR)),[-1.05:0.1:1.05])
title('Test LvR'); xlabel('L   R'); xlim([-1 1])
subplot(2,2,3);histogram(rateDI.LeftSvT(logical(dayUse)),[-1.05:0.1:1.05])
hold on; histogram(rateDI.LeftSvT(logical(dayUse.*thisCellSplitsST.LeftSvT)),[-1.05:0.1:1.05])
title('Left SvT'); xlabel('S   T'); xlim([-1 1])
subplot(2,2,4);histogram(rateDI.RightSvT(logical(dayUse)),[-1.05:0.1:1.05])
hold on; histogram(rateDI.RightSvT(logical(dayUse.*thisCellSplitsST.RightSvT)),[-1.05:0.1:1.05])
title('Right SvT'); xlabel('S   T'); xlim([-1 1])
suptitle('Splitting DIs, mean of rate bins with activity, active cells, splitters overlaid') 