function [corrs] = PVcorrAcrossDays(TMap,dayAllUse)
%Needs TMap from pooled

numSess = size(TMap,3);
numConds = size(TMap,2);
dayPairs = combnk(numSess,2)

StudyCorrs = cell(length(dayPairs,1));
for pairI = 1:length(dayPairs)
    for condI = 1:numConds
        
        days = dayPairs(pairI,:)
        for ct = 1:4
            binsUse(ct,:) = RunOccMap{1,ct,tDay} > posThresh;
        end

        for binNum = 1:maxBins
        %Study
        if sum(binsUse(Conds.Study,binNum)) == 2%sum(binsUse([1 2],binNum)) == 2
            useCells = sum(threshAndConsec(:,days,condI),3)>0;
            studyCells(tDay) = sum(useCells); %Number of cells, this condition this day
            PFsA = cell2mat(TMap(useCells,condI,days(1))); PFsA(isnan(PFsA)) = 0;
            PFsB = cell2mat(TMap(useCells,condI,days(2))); PFsB(isnan(PFsB)) = 0;
            StudyCorrs{pairI}(binNum) = corr(PFsA(:,binNum),PFsB(:,binNum));
        end
        
        end
    end
end
