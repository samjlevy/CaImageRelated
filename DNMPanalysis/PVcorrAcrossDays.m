function [corrs, cells, dayPairs] = PVcorrAcrossDays(TMap,RunOccMap,posThresh,threshAndConsec,sortedSessionInds)
%Needs TMap from pooled; or not...

numSess = size(TMap,3);
numConds = size(TMap,2);
dayPairs = combnk(1:numSess,2);
%dayPairs = flipud(dayPairs); %for checking against self
numBins = length(TMap{1,1,1});

%StudyCorrs = cell(length(dayPairs,1));

%[X{1:4}] = deal(nan(1,)) %Use here to preallocate cell arrays
for pairI = 1:length(dayPairs)

    days = dayPairs(pairI,:);
    
    for ct = 1:4
        day1Use = RunOccMap{1,ct,days(1)} > posThresh;
        day2Use = RunOccMap{1,ct,days(2)} > posThresh;
        binsUse(ct,:) = day1Use + day2Use;
    end
    
    for condI = 1:numConds %one loop here?
        cpLogical = []; cellsPresent = []; useCells = []; studyCells = [];
        
        cpLogical = sortedSessionInds(:,days) > 0;
        cellsPresent = sum(cpLogical,2)==2;
        useCells = sum(threshAndConsec(:,days,condI),2)>0 & cellsPresent;
        studyCells = sum(useCells); %Number of cells, this condition this day
        
        for binNum = 1:numBins
        %Study
        if sum(binsUse(condI,binNum)) == 2
            PFsA = cell2mat(TMap(useCells,condI,days(1))); PFsA(isnan(PFsA)) = 0;
            PFsB = cell2mat(TMap(useCells,condI,days(2))); PFsB(isnan(PFsB)) = 0;
            StudyCorrs(binNum) = corr(PFsA(:,binNum),PFsB(:,binNum));
        end
        corrs(condI).corrs{pairI} = StudyCorrs;
        cells(condI).numCells{pairI} = studyCells;
        end
    end
end

end
