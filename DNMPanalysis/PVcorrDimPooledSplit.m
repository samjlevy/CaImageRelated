function [StudyTestCorrs, LeftRightCorrs] = PVcorrDimPooledSplit(TMap_gauss, RunOccMap, posThresh, dayUse)
%posThresh = 3;

numDays = size(TMap_gauss,3);
maxBins = length(TMap_gauss{1,1,1});

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

%dayG = repmat([1:numDays]',useBins,1);
%binG = repmat([1:useBins],1,numDays)';
%allCorrs = StudyTestCorrs(:,1:useBins); allCorrs = allCorrs(:);
%pST = anovan(allCorrs,{dayG,binG},'varnames',{'Day','Bin'},'display','off');
%title(StudyTestFig.Children,['Study vs Test, prob>F day= ' num2str(pST(1)) ', bin=' num2str(pST(2))])
%allCorrs = LeftRightCorrs(:,1:useBins); allCorrs = allCorrs(:);
%pLR = anovan(allCorrs,{dayG,binG},'varnames',{'Day','Bin'},'display','off');
%title(LeftRightFig.Children,['Left vs Right, prob>F day= ' num2str(pLR(1)) ', bin=' num2str(pLR(2))])

end
