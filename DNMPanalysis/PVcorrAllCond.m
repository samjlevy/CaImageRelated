function [StudyCorrs, TestCorrs, LeftCorrs, RightCorrs, numCells] = PVcorrAllCond(TMap_gauss, RunOccMap, posThresh, threshAndConsec, Conds)

%posThresh = 3;

numDays = size(TMap_gauss,3);
maxBins = length(TMap_gauss{1,1,1});

StudyCorrs = nan(numDays,maxBins); TestCorrs = nan(numDays,maxBins);
LeftCorrs = nan(numDays,maxBins); RightCorrs = nan(numDays,maxBins);
for tDay = 1:numDays
    
    for ct = 1:4
        binsUse(ct,:) = RunOccMap{1,ct,tDay} > posThresh;
    end

    for binNum = 1:maxBins
        %Study
        if sum(binsUse(Conds.Study,binNum)) == 2%sum(binsUse([1 2],binNum)) == 2
            conds = Conds.Study;
            useCells = sum(threshAndConsec(:,tDay,conds),3)>0;
            studyCells(tDay) = sum(useCells); %Number of cells, this condition this day
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

numCells.studyCells = studyCells;
numCells.testCells = testCells;
numCells.leftCells = leftCells;
numCells.rightCells = rightCells;
%dayG = repmat([1:numDays]',useBins,1);
%binG = repmat([1:useBins],1,numDays)';
%allCorrs = StudyTestCorrs(:,1:useBins); allCorrs = allCorrs(:);
%pST = anovan(allCorrs,{dayG,binG},'varnames',{'Day','Bin'},'display','off');
%title(StudyTestFig.Children,['Study vs Test, prob>F day= ' num2str(pST(1)) ', bin=' num2str(pST(2))])
%allCorrs = LeftRightCorrs(:,1:useBins); allCorrs = allCorrs(:);
%pLR = anovan(allCorrs,{dayG,binG},'varnames',{'Day','Bin'},'display','off');
%title(LeftRightFig.Children,['Left vs Right, prob>F day= ' num2str(pLR(1)) ', bin=' num2str(pLR(2))])

end
