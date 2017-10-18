function [StudyLCorrs, StudyRCorrs, TestLCorrs, TestRCorrs, numCells] = PVcorrAllCondSelf(TMap_gaussSplit, RunOccMap, posThresh, threshAndConsec)
%This is to make the correlations for placefields where trials were split
%in to two batches to get a correlation against self. Uses the original
%RunOccMap, not the split one, to make sure we compare the same bins. 
%posThresh = 3;
%some indices here assume hardcoded test condition orders

numDays = size(TMap_gaussSplit,3);
hasStuff = ~cellfun(@isempty,{TMap_gaussSplit{:,1,1}});
firstHas = find(hasStuff,1,'first');
maxBins = length(TMap_gaussSplit{firstHas,1,1,1});

StudyLCorrs = nan(numDays,maxBins); StudyRCorrs = nan(numDays,maxBins);
TestLCorrs = nan(numDays,maxBins); TestRCorrs = nan(numDays,maxBins);
for tDay = 1:numDays
    
    for ct = 1:4
        binsUse(ct,:) = RunOccMap{1,ct,tDay} > posThresh;
    end

    for binNum = 1:maxBins
        %Study Left
        conds = 1;
        if sum(binsUse(conds,binNum)) == 1
            useCells = sum(threshAndConsec(:,tDay,conds),3)>0;
            studyLCells(tDay) = sum(useCells); %Number of cells, this condition this day
            PFsA = cell2mat(TMap_gaussSplit(useCells,conds,tDay,1)); PFsA(isnan(PFsA)) = 0;
            PFsB = cell2mat(TMap_gaussSplit(useCells,conds,tDay,2)); PFsB(isnan(PFsB)) = 0;
            StudyLCorrs(tDay,binNum) = corr(PFsA(:,binNum),PFsB(:,binNum));
        end
        %Study Right
        conds = 2;
        if sum(binsUse(conds,binNum)) == 1
            useCells = sum(threshAndConsec(:,tDay,conds),3)>0;
            studyRCells(tDay) = sum(useCells);
            PFsC = cell2mat(TMap_gaussSplit(useCells,conds,tDay,1)); PFsC(isnan(PFsC)) = 0;
            PFsD = cell2mat(TMap_gaussSplit(useCells,conds,tDay,2)); PFsD(isnan(PFsD)) = 0;
            StudyRCorrs(tDay,binNum) = corr(PFsC(:,binNum),PFsD(:,binNum));
        end
        %Test Left
        conds = 3;
        if sum(binsUse(conds,binNum)) == 1
            useCells = sum(threshAndConsec(:,tDay,conds),3)>0;
            testLCells(tDay) = sum(useCells);
            PFsA = cell2mat(TMap_gaussSplit(useCells,conds,tDay,1)); PFsA(isnan(PFsA)) = 0;
            PFsC = cell2mat(TMap_gaussSplit(useCells,conds,tDay,2)); PFsC(isnan(PFsC)) = 0;
            TestLCorrs(tDay,binNum) = corr(PFsA(:,binNum),PFsC(:,binNum));
        end
        %Test Right
        conds = 4;
        if sum(binsUse(conds,binNum)) == 1
            useCells = sum(threshAndConsec(:,tDay,conds),3)>0;
            testRCells(tDay) = sum(useCells);
            PFsB = cell2mat(TMap_gaussSplit(useCells,conds,tDay,1)); PFsB(isnan(PFsB)) = 0;
            PFsD = cell2mat(TMap_gaussSplit(useCells,conds,tDay,2)); PFsD(isnan(PFsD)) = 0;
            TestRCorrs(tDay,binNum) = corr(PFsB(:,binNum),PFsD(:,binNum));
        end 
    end
end

numCells.studyLCells = studyLCells;
numCells.studyRCells = studyRCells;
numCells.testLCells = testLCells;
numCells.testRCells = testRCells;

%disp('done')
%dayG = repmat([1:numDays]',useBins,1);
%binG = repmat([1:useBins],1,numDays)';
%allCorrs = StudyTestCorrs(:,1:useBins); allCorrs = allCorrs(:);
%pST = anovan(allCorrs,{dayG,binG},'varnames',{'Day','Bin'},'display','off');
%title(StudyTestFig.Children,['Study vs Test, prob>F day= ' num2str(pST(1)) ', bin=' num2str(pST(2))])
%allCorrs = LeftRightCorrs(:,1:useBins); allCorrs = allCorrs(:);
%pLR = anovan(allCorrs,{dayG,binG},'varnames',{'Day','Bin'},'display','off');
%title(LeftRightFig.Children,['Left vs Right, prob>F day= ' num2str(pLR(1)) ', bin=' num2str(pLR(2))])

end
