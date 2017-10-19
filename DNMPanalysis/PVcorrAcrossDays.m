function [daysStudyLCorrs, daysStudyRCorrs, daysTestLCorrs, daysTestRCorrs, cells, dayPairs] =...
    PVcorrAcrossDays(TMap,RunOccMap,posThresh,threshAndConsec,sortedSessionInds)
%Use basic each condition TMap that would go into PVcorrAllCond
%Send outputs to processPVcorrsSelfAcrossDays to parseout by num days apart

numSess = size(TMap,3);
numConds = size(TMap,2);
dayPairs = combnk(1:numSess,2);
%dayPairs = flipud(dayPairs); %for checking against self
numBins = length(TMap{1,1,1});

daysStudyLCorrs = nan(length(dayPairs),numBins); 
daysStudyRCorrs = nan(length(dayPairs),numBins);
daysTestLCorrs = nan(length(dayPairs),numBins);
daysTestRCorrs = nan(length(dayPairs),numBins);
for pairI = 1:length(dayPairs)

    days = dayPairs(pairI,:);
    
    for ct = 1:4
        day1Use = RunOccMap{1,ct,days(1)} > posThresh;
        day2Use = RunOccMap{1,ct,days(2)} > posThresh;
        binsUse(ct,:) = day1Use + day2Use;
    end
    
    cpLogical = []; cellsPresent = []; useCells = []; studyCells = [];
        
    cpLogical = sortedSessionInds(:,days) > 0;
    cellsPresent = sum(cpLogical,2)==2;
    
    %Study Left
    condI = 1;
    useCells = sum(threshAndConsec(:,days,condI),2)>0 & cellsPresent;
    cells.studyLCells(pairI) = sum(useCells); %Number of cells, this condition this day
    for binNum = 1:numBins
        if sum(binsUse(condI,binNum)) == 2
            PFsA = cell2mat(TMap(useCells,condI,days(1))); PFsA(isnan(PFsA)) = 0;
            PFsB = cell2mat(TMap(useCells,condI,days(2))); PFsB(isnan(PFsB)) = 0;
            daysStudyLCorrs(pairI,binNum) = corr(PFsA(:,binNum),PFsB(:,binNum));
        end
    end
    %Study Right
    condI = 2;
    useCells = sum(threshAndConsec(:,days,condI),2)>0 & cellsPresent;
    cells.studyRCells(pairI) = sum(useCells); %Number of cells, this condition this day
    for binNum = 1:numBins
        if sum(binsUse(condI,binNum)) == 2
            PFsA = cell2mat(TMap(useCells,condI,days(1))); PFsA(isnan(PFsA)) = 0;
            PFsB = cell2mat(TMap(useCells,condI,days(2))); PFsB(isnan(PFsB)) = 0;
            daysStudyRCorrs(pairI,binNum) = corr(PFsA(:,binNum),PFsB(:,binNum));
        end
    end
    
    %Test Left    
    condI = 3;
    useCells = sum(threshAndConsec(:,days,condI),2)>0 & cellsPresent;
    cells.testLCells(pairI) = sum(useCells); %Number of cells, this condition this day
    for binNum = 1:numBins
        if sum(binsUse(condI,binNum)) == 2
            PFsA = cell2mat(TMap(useCells,condI,days(1))); PFsA(isnan(PFsA)) = 0;
            PFsB = cell2mat(TMap(useCells,condI,days(2))); PFsB(isnan(PFsB)) = 0;
            daysTestLCorrs(pairI,binNum) = corr(PFsA(:,binNum),PFsB(:,binNum));
        end
    end
        
    %Test Right
    condI = 4;
    useCells = sum(threshAndConsec(:,days,condI),2)>0 & cellsPresent;
    cells.testRCells(pairI) = sum(useCells); %Number of cells, this condition this day
    for binNum = 1:numBins
        if sum(binsUse(condI,binNum)) == 2
            PFsA = cell2mat(TMap(useCells,condI,days(1))); PFsA(isnan(PFsA)) = 0;
            PFsB = cell2mat(TMap(useCells,condI,days(2))); PFsB(isnan(PFsB)) = 0;
            daysTestRCorrs(pairI,binNum) = corr(PFsA(:,binNum),PFsB(:,binNum));
        end
    end
    
    
    %{
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
        corrs.(dynC{condI}).corrs{pairI} = StudyCorrs;
        cells.(dynC{condI}).numCells{pairI} = studyCells;
        end
    end
    %}
end

end
