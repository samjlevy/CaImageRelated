function [bigCorrs, cells, dayPairs, condPairs ] =...
    PVcorrsAllCorrsAllCondsAllDays(TMap,RunOccMap,posThresh,threshAndConsec,sortedSessionInds,Conds)
%Use basic each condition TMap that would go into PVcorrAllCond
%Send outputs to processPVacacad to parseout by num days apart
%Set up to do each order of pairs of conditions, then each unique day pair
%off of that

numSess = size(TMap,3);
numConds = size(TMap,2);
dayPairs = combnk(1:numSess,2);
%dayPairs = flipud(dayPairs); %for checking against self
%numBins = length(TMap{1,1,1});
numBins = 10;
corrType = 'Spearman';

selfconds = repmat([1:numConds]',1,2);
condPairsTemp = flipud(combnk(1:numConds,2));
condPairs = [selfconds; condPairsTemp];% fliplr(condPairsTemp)]; %?????

%cpt1 = repmat(1:numConds,numConds,1); 
%cpt2 = repmat(1:numConds,1,numConds);
%condPairs = [cpt1(:), cpt2'];


ndp1 = repmat(1:numSess,numSess,1); 
ndp2 = repmat(1:numSess,1,numSess);
dayPairs = [ndp1(:), ndp2'];

bigCorrs = cell(length(condPairs),1);
for ddd = 1:length(condPairs)
    bigCorrs{ddd} = nan(length(dayPairs),numBins);
end
cells = nan(length(condPairs),length(dayPairs));

nanCount  = 0;
for cpI = 1:length(condPairs)
    conds = condPairs(cpI,:);
    for dpI = 1:length(dayPairs)
        
        days = dayPairs(dpI,:);
        
        day1Use = RunOccMap{1,conds(1),days(1)} > posThresh;
        day2Use = RunOccMap{1,conds(2),days(2)} > posThresh;
        binsUse = day1Use + day2Use;
        
        cpLogical = []; cellsPresent = []; useCells = []; studyCells = [];
        
        %Put dummy entries in 0s of sortedSessionInds to include silent cells
        cpLogical = sortedSessionInds(:,days) > 0;
        cellsPresent = sum(cpLogical,2)==2;
        
        %Make threshAndConsec all 1s to remove activity threshold
        useCells1 = threshAndConsec(:,day(1),cond(1));
        useCells2 = threshAndConsec(:,day(2),cond(2));
        useCells = ((useCells1 + useCells2) > 0) & cellsPresent;
        cells(cpI,dpI) = sum(useCells); %Number of cells, this condition this day
        PFsA = cell2mat(TMap(useCells,conds(1),days(1))); PFsA(isnan(PFsA)) = 0;
        PFsB = cell2mat(TMap(useCells,conds(2),days(2))); PFsB(isnan(PFsB)) = 0;
        for binNum = 1:numBins
        %if sum(binsUse(condI,binNum)) == 2
            bigCorrs{cpI}(dpI,binNum) = corr(PFsA(:,binNum),PFsB(:,binNum),'type',corrType);
            if any(isnan(bigCorrs{cpI}(dpI,binNum)))
                %disp('found some nans')
                nanCount = nanCount + 1;
                bigCorrs{cpI}(dpI,binNum) = 0;
                %keyboard
            end
        %end
        end
    end
    %disp(['finished cond pair ' num2str(cpI) '/' num2str(length(condPairs))])
end
disp(['found nans ' num2str(nanCount) 'times'])

end