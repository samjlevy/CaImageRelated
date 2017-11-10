function [StudyCorrs, TestCorrs, LeftCorrs, RightCorrs, numCells] = PVcorrAllCondConfusion(TMap_gauss, RunOccMap, posThresh, threshAndConsec, Conds)

%posThresh = 3;
hasStuff = ~cellfun(@isempty,{TMap_gauss{:,1,1}});
firstHas = find(hasStuff,1,'first');
maxBins = length(TMap_gauss{firstHas,1,1});
numDays = size(TMap_gauss,3);
corrType = 'Spearman';

StudyCorrs = nan(maxBins,maxBins,numDays); TestCorrs = nan(maxBins,maxBins,numDays);
LeftCorrs = nan(maxBins,maxBins,numDays); RightCorrs = nan(maxBins,maxBins,numDays);
for tDay = 1:numDays
    
    goodRows = ~cellfun(@isempty,{RunOccMap{:,1,tDay}});
    useRow = find(goodRows,1,'first');
    %for ct = 1:4
    %    binsUse(ct,:) = RunOccMap{useRow,ct,tDay} > posThresh;
    %end
    binsUse = ones(4,maxBins);
    
    binPairs = nchoosek(1:size(binsUse,2),2);
    
    ff=repmat(1:10,10,1);
    binPairs = [ff(:) repmat(1:10,1,10)'];
    
    for binNum = 1:length(binPairs)
        %Study LvR
        %if sum(binsUse(Conds.Study,binNum)) == 2%sum(binsUse([1 2],binNum)) == 2
            conds = Conds.Study;
            useCells = sum(threshAndConsec(:,tDay,conds),3)>0;
            studyCells(tDay) = sum(useCells); %Number of cells, this condition this day
            PFsA = cell2mat(TMap_gauss(useCells,conds(1),tDay)); PFsA(isnan(PFsA)) = 0;
            PFsB = cell2mat(TMap_gauss(useCells,conds(2),tDay)); PFsB(isnan(PFsB)) = 0;
            if any(PFsA) & any(PFsB)
            StudyCorrs(binPairs(binNum,1),binPairs(binNum,2),tDay) = corr(PFsA(:,binPairs(binNum,1)),PFsB(:,binPairs(binNum,2)),'type',corrType);
            end
        %end
         %Test LvR
        %if sum(binsUse(Conds.Test,binNum)) == 2
            conds = Conds.Test;
            useCells = sum(threshAndConsec(:,tDay,conds),3)>0;
            testCells(tDay) = sum(useCells);
            PFsC = cell2mat(TMap_gauss(useCells,conds(1),tDay)); PFsC(isnan(PFsC)) = 0;
            PFsD = cell2mat(TMap_gauss(useCells,conds(2),tDay)); PFsD(isnan(PFsD)) = 0;
            if any(PFsC) & any(PFsD)
            TestCorrs(binPairs(binNum,1),binPairs(binNum,2),tDay) = corr(PFsC(:,binPairs(binNum,1)),PFsD(:,binPairs(binNum,2)),'type',corrType);
            end
       % end
        %Left SvT
        %if sum(binsUse(Conds.Left,binNum)) == 2
            conds = Conds.Left;
            useCells = sum(threshAndConsec(:,tDay,conds),3)>0;
            leftCells(tDay) = sum(useCells);
            PFsA = cell2mat(TMap_gauss(useCells,conds(1),tDay)); PFsA(isnan(PFsA)) = 0;
            PFsC = cell2mat(TMap_gauss(useCells,conds(2),tDay)); PFsC(isnan(PFsC)) = 0;
            if any(PFsA) & any(PFsC)
            LeftCorrs(binPairs(binNum,1),binPairs(binNum,2),tDay) = corr(PFsA(:,binPairs(binNum,1)),PFsC(:,binPairs(binNum,2)),'type',corrType);
            end
        %end
        %Right SvT
        %if sum(binsUse(Conds.Right,binNum)) == 2
            conds = Conds.Right;
            useCells = sum(threshAndConsec(:,tDay,conds),3)>0;
            rightCells(tDay) = sum(useCells);
            PFsB = cell2mat(TMap_gauss(useCells,conds(1),tDay)); PFsB(isnan(PFsB)) = 0;
            PFsD = cell2mat(TMap_gauss(useCells,conds(2),tDay)); PFsD(isnan(PFsD)) = 0;
            if any(PFsB) & any(PFsD)
            RightCorrs(binPairs(binNum,1),binPairs(binNum,2),tDay) = corr(PFsB(:,binPairs(binNum,1)),PFsD(:,binPairs(binNum,2)),'type',corrType);
            end
        %end 
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
