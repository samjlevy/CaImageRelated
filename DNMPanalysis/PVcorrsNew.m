%This is set up to only include cells in each comparison that fired in at
%least one of the compared conditions. Should limit the number of cells
%that end up included but have 0 firing rate 
%Right now all place maps are end to start, first to last bins

load('PFsLin.mat','TMap_gauss','RunOccMap')

[Conds] = GetTBTconds(trialbytrial);

useBins = 12;
maxBins = 14;
posThresh = 3;
numDays = size(TMap_gauss,3);
StudyCorrs = nan(numDays,maxBins); TestCorrs = nan(numDays,maxBins);
LeftCorrs = nan(numDays,maxBins); RightCorrs = nan(numDays,maxBins);
for tDay = 1:numDays
    %{
    cellsInclude = dayUse(:,tDay)>0;
    PFsA = cell2mat(TMap_gauss(cellsInclude,1,tDay)); PFsA(isnan(PFsA)) = 0;
    PFsB = cell2mat(TMap_gauss(cellsInclude,2,tDay)); PFsB(isnan(PFsB)) = 0;
    PFsC = cell2mat(TMap_gauss(cellsInclude,3,tDay)); PFsC(isnan(PFsC)) = 0;
    PFsD = cell2mat(TMap_gauss(cellsInclude,4,tDay)); PFsD(isnan(PFsD)) = 0;
    numCells = sum(cellsInclude);
    %}
    %useCells = dayUse(:,tDay)>0;
    useCells = dayAllUse(:,tDay)>0;
     
    for ct = 1:4
        binsUse(ct,:) = RunOccMap{1,ct,tDay} > posThresh;
    end

    for binNum = 1:maxBins
        %Study
        if sum(binsUse(Conds.Study,binNum)) == 2
            conds = Conds.Study;
            useCells = sum(threshAndConsec(:,tDay,conds),3)>0;
            studyCells(tDay) = sum(useCells);
            PFsA = cell2mat(TMap_gauss(useCells,conds(1),tDay)); PFsA(isnan(PFsA)) = 0;
            PFsB = cell2mat(TMap_gauss(useCells,conds(2),tDay)); PFsB(isnan(PFsB)) = 0;
            StudyCorrs(tDay,binNum) = corr(PFsA(:,binNum),PFsB(:,binNum));
        end
        %Test
        if sum(binsUse(Conds.Test,binNum)) == 2
            conds = Conds.Test;
            useCells = sum(threshAndConsec(:,tDay,conds),3)>0;
            testCells(tDay) = sum(useCells);
            PFsC = cell2mat(TMap_gauss(useCells,conds(1),tDay)); PFsC(isnan(PFsC)) = 0;
            PFsD = cell2mat(TMap_gauss(useCells,conds(2),tDay)); PFsD(isnan(PFsD)) = 0;
            TestCorrs(tDay,binNum) = corr(PFsC(:,binNum),PFsD(:,binNum));
        end
        %Left
        if sum(binsUse(Conds.Left,binNum)) == 2
            conds = Conds.Left;
            useCells = sum(threshAndConsec(:,tDay,conds),3)>0;
            leftCells(tDay) = sum(useCells);
            PFsA = cell2mat(TMap_gauss(useCells,conds(1),tDay)); PFsA(isnan(PFsA)) = 0;
            PFsC = cell2mat(TMap_gauss(useCells,conds(2),tDay)); PFsC(isnan(PFsC)) = 0;
            LeftCorrs(tDay,binNum) = corr(PFsA(:,binNum),PFsC(:,binNum));
        end
        %Right
        if sum(binsUse(Conds.Right,binNum)) == 2
            conds = Conds.Right;
            useCells = sum(threshAndConsec(:,tDay,conds),3)>0;
            rightCells(tDay) = sum(useCells);
            PFsB = cell2mat(TMap_gauss(useCells,conds(1),tDay)); PFsB(isnan(PFsB)) = 0;
            PFsD = cell2mat(TMap_gauss(useCells,conds(2),tDay)); PFsD(isnan(PFsD)) = 0;
            RightCorrs(tDay,binNum) = corr(PFsB(:,binNum),PFsD(:,binNum));
        end 
    end
end
h = figure;
jetTrips = colormap(jet);
close(h)
jetUse = round(linspace(1,64,numDays));
plotColors = jetTrips(jetUse,:);

StudyFig = figure; TestFig = figure; LeftFig = figure; RightFig = figure;
axes(StudyFig); hold(StudyFig.Children,'on'); title(StudyFig.Children,'Study Left vs Right')
axes(TestFig); hold(TestFig.Children,'on'); title(TestFig.Children,'Test Left vs Right')
axes(LeftFig); hold(LeftFig.Children,'on'); title(LeftFig.Children,'Left Study vs Test')
axes(RightFig); hold(RightFig.Children,'on'); title(RightFig.Children,'Right Study vs Test')
xlabel(StudyFig.Children,'Start                      Choice Point'); ylabel('Correlation')
xlabel(TestFig.Children,'Start                      Choice Point'); ylabel('Correlation')
xlabel(LeftFig.Children,'Start                      Choice Point'); ylabel('Correlation')
xlabel(RightFig.Children,'Start                      Choice Point'); ylabel('Correlation')
for uDay = 1:numDays
    plot(StudyFig.Children,fliplr(StudyCorrs(uDay,:)),'-o','Color',plotColors(uDay,:))
    plot(TestFig.Children,fliplr(TestCorrs(uDay,:)),'-o','Color',plotColors(uDay,:))
    plot(LeftFig.Children,fliplr(LeftCorrs(uDay,:)),'-o','Color',plotColors(uDay,:))
    plot(RightFig.Children,fliplr(RightCorrs(uDay,:)),'-o','Color',plotColors(uDay,:))
end
ylim(StudyFig.Children,[-1 1]); xlim(StudyFig.Children,[2 14]);
ylim(TestFig.Children,[-1 1]); xlim(TestFig.Children,[2 14]);
ylim(LeftFig.Children,[-1 1]); xlim(LeftFig.Children,[2 14]);
ylim(RightFig.Children,[-1 1]); xlim(RightFig.Children,[2 14]);


dayG = repmat([1:numDays]',useBins,1);
binG = repmat([1:useBins],1,numDays)';
allCorrs = StudyCorrs(:,1:useBins); allCorrs = allCorrs(:);
pStudy = anovan(allCorrs,{dayG,binG},'varnames',{'Day','Bin'},'display','off');
allCorrs = TestCorrs(:,1:useBins); allCorrs = allCorrs(:);
pTest = anovan(allCorrs,{dayG,binG},'varnames',{'Day','Bin'},'display','off');
allCorrs = LeftCorrs(:,1:useBins); allCorrs = allCorrs(:);
pLeft = anovan(allCorrs,{dayG,binG},'varnames',{'Day','Bin'},'display','off');
allCorrs = RightCorrs(:,1:useBins); allCorrs = allCorrs(:);
pRight = anovan(allCorrs,{dayG,binG},'varnames',{'Day','Bin'},'display','off');
title(StudyFig.Children,['Study Left vs Right, prob>F day= ' num2str(pStudy(1)) ', bin=' num2str(pStudy(2))])
title(TestFig.Children,['Test Left vs Right, prob>F day= ' num2str(pTest(1)) ', bin=' num2str(pTest(2))])
title(LeftFig.Children,['Left Study vs Test, prob>F day= ' num2str(pLeft(1)) ', bin=' num2str(pLeft(2))])
title(RightFig.Children,['Right Study vs Test, prob>F day= ' num2str(pRight(1)) ', bin=' num2str(pRight(2))])

for nBin = 1:useBins
    [~,order] = sort(LeftCorrs(:,nBin));
    [rrLeft(nBin), ppLeft(nBin)] = corr(flipud([1:numDays]'),order,'type','Spearman');
    [~,order] = sort(RightCorrs(:,nBin));
    [rrRight(nBin), ppRight(nBin)] = corr(flipud([1:numDays]'),order,'type','Spearman');
    [~,order] = sort(StudyCorrs(:,nBin));
    [rrStudy(nBin), ppStudy(nBin)] = corr([1:numDays]',order,'type','Spearman');
    [~,order] = sort(TestCorrs(:,nBin));
    [rrTest(nBin), ppTest(nBin)] = corr([1:numDays]',order,'type','Spearman');
end
binPlot = 1:useBins;
binLeft = binPlot(ppLeft<0.05); binRight = binPlot(ppRight<0.05);
binStudy = binPlot(ppStudy<0.05); binTest = binPlot(ppTest<0.05);
plot(StudyFig.Children,1:useBins,rrStudy,'-.k')
plot(TestFig.Children,1:useBins,rrTest,'-.k')
plot(LeftFig.Children,1:useBins,rrLeft,'-.k')
plot(RightFig.Children,1:useBins,rrRight,'-.k')

plot(StudyFig.Children,binStudy,rrStudy(binStudy),'*r')
plot(TestFig.Children,binTest,rrTest(binTest),'*r')
plot(LeftFig.Children,binLeft,rrLeft(binLeft),'*r')
plot(RightFig.Children,binRight,rrRight(binRight),'*r')


for nBin = 1:useBins
    [~, orders(:,nBin)] = sort(TestCorrs(:,nBin));
end
combos = combnk(1:11,2);
for cc = 1:size(combos,1)
    [p(cc),h(cc)] = ranksum(orders(combos(cc,1),:),orders(combos(cc,2),:));
end
diffes = combos(:,2) - combos(:,1);
wDiffs = unique(diffes);
for dd = 1:10
    passed(dd) = sum(h(diffes==dd)==1) / sum(diffes==dd);
    pval(dd) = mean(p(diffes==dd));
    hm(dd) = sum(diffes==dd);
        %how many at this diff passed the test / how many at this diff
        %this is a spot where actual day number would be helpful
end

maxes = max(TestCorrs,[],1);
diffes = TestCorrs - maxes;
figure; 
for nDay = 1:numDays
    plot(diffes(nDay,:),'-o','Color',plotColors(nDay,:))
    hold on
end




load(fullfile(base_path,'PFsLinPOOLED.mat'),'TMap_gauss','RunOccMap')
StudyTestCorrs = nan(numDays,maxBins); 
LeftRightCorrs = nan(numDays,maxBins);
for tDay = 1:numDays
    useCells = dayUse(:,tDay)>0;
    
    for ct = 1:4
        binsUse(ct,:) = RunOccMap{1,ct,tDay} > posThresh;
    end

    for binNum = 1:maxBins
        %StudyTest
        if sum(binsUse([1 2],binNum)) == 2
            PFsA = cell2mat(TMap_gauss(useCells,1,tDay)); PFsA(isnan(PFsA)) = 0;
            PFsB = cell2mat(TMap_gauss(useCells,2,tDay)); PFsB(isnan(PFsB)) = 0;
            StudyTestCorrs(tDay,binNum) = corr(PFsA(:,binNum),PFsB(:,binNum));
        end
        %LeftRight
        if sum(binsUse([3 4],binNum)) == 2
            PFsA = cell2mat(TMap_gauss(useCells,3,tDay)); PFsA(isnan(PFsA)) = 0;
            PFsB = cell2mat(TMap_gauss(useCells,4,tDay)); PFsB(isnan(PFsB)) = 0;
            LeftRightCorrs(tDay,binNum) = corr(PFsA(:,binNum),PFsB(:,binNum));
        end
    end
end
h = figure;
jetTrips = colormap(jet);
close(h)
jetUse = round(linspace(1,64,numDays));
plotColors = jetTrips(jetUse,:);

StudyTestFig = figure; LeftRightFig = figure;
axes(StudyTestFig); hold(StudyTestFig.Children,'on'); title(StudyTestFig.Children,'Study vs Test')
axes(LeftRightFig); hold(LeftRightFig.Children,'on'); title(LeftRightFig.Children,'Left vs Right')
xlabel(StudyTestFig.Children,'Start                      Choice Point'); ylabel('Correlation')
xlabel(LeftRightFig.Children,'Start                      Choice Point'); ylabel('Correlation')
for uDay = 1:numDays
    plot(StudyTestFig.Children,fliplr(StudyTestCorrs(uDay,:)),'-o','Color',plotColors(uDay,:))
    plot(LeftRightFig.Children,fliplr(LeftRightCorrs(uDay,:)),'-o','Color',plotColors(uDay,:))
end
ylim(StudyTestFig.Children,[-0.5 1]); xlim(StudyTestFig.Children,[2 14]);
ylim(LeftRightFig.Children,[-0.5 1]); xlim(LeftRightFig.Children,[2 14]);


dayG = repmat([1:numDays]',useBins,1);
binG = repmat([1:useBins],1,numDays)';
allCorrs = StudyTestCorrs(:,1:useBins); allCorrs = allCorrs(:);
pST = anovan(allCorrs,{dayG,binG},'varnames',{'Day','Bin'},'display','off');
title(StudyTestFig.Children,['Study vs Test, prob>F day= ' num2str(pST(1)) ', bin=' num2str(pST(2))])
allCorrs = LeftRightCorrs(:,1:useBins); allCorrs = allCorrs(:);
pLR = anovan(allCorrs,{dayG,binG},'varnames',{'Day','Bin'},'display','off');
title(LeftRightFig.Children,['Left vs Right, prob>F day= ' num2str(pLR(1)) ', bin=' num2str(pLR(2))])


for bb = 1:useBins
    [~,LRorder(:,bb)] = sort(LeftRightCorrs(:,bb));
    [~,STorder(:,bb)] = sort(StudyTestCorrs(:,bb));
end
LRorder = LRorder'; STorder=STorder';

LRrankSum = sum(LRorder,1);
LRrankMean = mean(LRorder,1);
STrankSum = sum(STorder,1);
STrankMean = mean(STorder,1);

[~, ~, rsq1] = LeastSquaresRegressionSL(1:numDays, LRrankMean);
title(['Left vs Right mean rank R^2=' num2str(rsq1)])
xlabel('Day');ylabel('Mean rank of correlation')
[~, ~, rsq2] = LeastSquaresRegressionSL(1:numDays, STrankMean);
title(['Study vs Test mean rank R^2=' num2str(rsq2)])
xlabel('Day');ylabel('Mean rank of correlation')



useBins = 12;
useCorrs = LeftRightCorrs;
allCorrs = useCorrs(:,1:useBins); allCorrs = allCorrs(:);
dayG = repmat([1:numDays]',useBins,1);
binG = repmat([1:useBins],numDays,1); binG = binG(:);
[p,t,stats] = anovan(allCorrs,{dayG,binG},'varnames',{'Day','Bin'});

for nBin = 1:useBins
    [~,order] = sort(useCorrs(:,nBin));
    [rr(nBin), pp(nBin)] = corr([1:numDays]',order,'type','Spearman');
end
