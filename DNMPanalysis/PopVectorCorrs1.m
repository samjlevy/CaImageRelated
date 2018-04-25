function [Corrs, numCellsUsed, dayPairs, condPairs] = PopVectorCorrs1(TMap, traitLogical, cellsUseOption, corrType, condPairs, dayPairs)
%This function uses the variable 'cellsUseOption' to decide which cells to use.
%Options are:
%   - 'activeEither' - cells had to be traitLogical on either day
%   - 'activeBoth' - cells had to be traitLogical on both days
%   - 'includeSilent' - takes the ALL cells activity both days (whole column of TMap)
% to do present both, input sortedSortedSessionInds as a logical for traitLogical

if isempty('corrType')
    corrType = 'Spearman';  
    disp('Using Spearman corr')
end
numCells = size(TMap, 1);
numDays = size(TMap, 3);
numConds = size(TMap, 2);

if isempty('dayPairs') || any(dayPairs)==0
    dayTemp = combnk(1:numDays,2);
    %dayPairs = [repmat([1:numDays]',1,2); dayTemp; fliplr(dayTemp)];
    dayPairs = [repmat([1:numDays]',1,2); dayTemp];
    disp('Running all day pairs')
end

if isempty('condPairs') || any(condPairs)==0
    %condPairs = flipud(combnk(1:numConds,2));
    cpTemp = flipud(combnk(1:numConds,2));
    %condPairs = [repmat([1:numConds]',1,2); cpTemp];
    condPairs = [repmat([1:numConds]',1,2); cpTemp; fliplr(cpTemp)];
    disp('Running all condition pairs')
end

%if length(size(traitLogical)) ~= length(size(TMap))
if length(size(traitLogical)) == 2
    %traitLogical(:,:,1:numConds) = traitLogical;
    traitLogical = repmat(traitLogical,1,1,numConds);
end        

numCondPairs = size(condPairs, 1);
numDayPairs = size(dayPairs, 1);
numBins = length(TMap{1,1,1});

numCorrsToRun = numCondPairs*numDayPairs;
numCellsUsed = nan(numDayPairs, numCondPairs);
%Corrs = cell(numCondPairs,1); [Corrs{:}] = deal(nan(numDayPairs, numBins));
Corrs = nan(numDayPairs,numCondPairs,numBins);
numNans = 0;
for dpI = 1:numDayPairs
    for cpI = 1:numCondPairs
        %Pull out the cells to use
        switch cellsUseOption
            case 'activeEither'
                cellsUse = traitLogical(:,dayPairs(dpI,1),condPairs(cpI,1))+...
                           traitLogical(:,dayPairs(dpI,2),condPairs(cpI,2))...
                           >0;
            case 'activeBoth'
                cellsUse = traitLogical(:,dayPairs(dpI,1),condPairs(cpI,1))+...
                           traitLogical(:,dayPairs(dpI,2),condPairs(cpI,2))...
                           ==2;
            case 'includeSilent'
                cellsUse = true(numCells,1);
        end
        
        numCellsUsed(dpI,cpI) = sum(cellsUse);
        
        %Get all the firing rates of these cells, this cond and day combination
        if sum(cellsUse) > 1
        TRatesA = cell2mat(TMap(cellsUse,condPairs(cpI,1),dayPairs(dpI,1)));
        TRatesB = cell2mat(TMap(cellsUse,condPairs(cpI,2),dayPairs(dpI,2)));
        for binI = 1:numBins
            Corrs(dpI,cpI,binI) = corr(TRatesA(:,binI),TRatesB(:,binI),'type',corrType);%Corrs{cpI}(dpI, binI)
            if any(isnan(Corrs(dpI,cpI,binI)))%any(isnan(Corrs{cpI}(dpI, binI)))
                %keyboard
                numNans = numNans + 1;
            end
        end
        end
    end
    %disp(['finished day pair ' num2str(dpI) ])
end

disp([num2str(numNans) ' nans happened'])
end
            
            
            
            
            
            
            
            
            
            
            