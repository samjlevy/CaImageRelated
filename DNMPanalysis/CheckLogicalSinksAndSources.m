function [pooledSourceChanges, pooledDailySources, pooledSinkChanges, pooledDailySinks, sourceDayDiffsPooled, sinkDayDiffsPooled] =...
    CheckLogicalSinksAndSources(targets,sources,sinks,cellRealDays)
%looks at what cells come from and what they change into

numMice = length(cellRealDays);

for tgI = 1:length(targets{1})
    pooledSourceChanges{tgI} = cell(length(sources{1}),1);
    pooledDailySources{tgI} = cell(length(sources{1}),1);
    pooledSinkChanges{tgI} = cell(length(sinks{1}),1);
    pooledDailySinks{tgI} = cell(length(sinks{1}),1);
end

sourceDayDiffsPooled = [];
sinkDayDiffsPooled = [];
for mouseI = 1:numMice
    sourceDayPairs = combnk(1:length(cellRealDays{mouseI})-1,2);
    abbrevRealDays = cellRealDays{mouseI}(2:end);
    sourceDayDiffs{mouseI} = diff(abbrevRealDays(sourceDayPairs),[],2);
    
    sinkDayPairs = combnk(1:length(cellRealDays{mouseI})-1,2);
    abbrevRealDaysJ = cellRealDays{mouseI}(1:end-1);
    sinkDayDiffs{mouseI} = diff(abbrevRealDaysJ(sinkDayPairs),[],2);
    
    sourceDayDiffsPooled = [sourceDayDiffsPooled; sourceDayDiffs{mouseI}];
    sinkDayDiffsPooled = [sinkDayDiffsPooled; sinkDayDiffs{mouseI}];
    
    for tgI = 1:length(targets{1})
    
        %Where do cells come from?
        if ~isempty(sources)
            for dayI = 2:length(cellRealDays{mouseI})
                cellsHere = targets{mouseI}{tgI}(:,dayI);

                for scI = 1:length(sources{mouseI})
                    sourceCells = sources{mouseI}{scI}(:,dayI-1);

                    thisSource{mouseI}{tgI}{scI} = cellsHere + sourceCells == 2; %Cells changed
                    thisSourceSum{mouseI}{tgI}{scI}(dayI-1) = sum(thisSource{mouseI}{tgI}{scI}); %Total number of cells changed
                    thisSourceSumNorm{mouseI}{tgI}{scI}(dayI-1) = thisSourceSum{mouseI}{tgI}{scI}(dayI-1) / sum(cellsHere); %pct of original cells
                end
            end

            for scI = 1:length(sources{mouseI})
                [sourceChange{tgI}{scI}{mouseI}, sourcePctChange{tgI}{scI}{mouseI}] =...
                    TraitChangeDayPairs(thisSourceSumNorm{mouseI}{tgI}{scI},sourceDayPairs);

                pooledDailySources{tgI}{scI} = [pooledDailySources{tgI}{scI}; thisSourceSumNorm{mouseI}{tgI}{scI}(:)];
                pooledSourceChanges{tgI}{scI} = [pooledSourceChanges{tgI}{scI}; sourceChange{tgI}{scI}{mouseI}(:)];
            end         
        end

        %Where are cells going
        if ~isempty(sinks)
            for dayJ = 1:length(cellRealDays{mouseI})-1
               cellsHereJ = targets{mouseI}{tgI}(:,dayJ);

               for scJ = 1:length(sinks{1})%Sinks first ind is mouseI
                   sinkCells = sinks{mouseI}{scJ}(:,dayJ+1);

                   thisSink{mouseI}{tgI}{scJ} = cellsHereJ + sinkCells == 2;
                   thisSinkSum{mouseI}{tgI}{scJ}(dayJ) = sum(thisSink{mouseI}{tgI}{scJ}); %Cells will change
                   thisSinkSumNorm{mouseI}{tgI}{scJ}(dayJ) = thisSinkSum{mouseI}{tgI}{scJ}(dayJ) / sum(cellsHereJ); %Total number of cells changed
               end    
            end

            for scJ = 1:length(sinks{1})
                [sinkChange{tgI}{scJ}{mouseI}, sinkPctChange{tgI}{scJ}{mouseI}] =...
                    TraitChangeDayPairs(thisSinkSumNorm{mouseI}{tgI}{scJ},sinkDayPairs);

                pooledDailySinks{tgI}{scJ} = [pooledDailySinks{tgI}{scJ}; thisSinkSumNorm{mouseI}{tgI}{scJ}(:)];
                pooledSinkChanges{tgI}{scJ} = [pooledSinkChanges{tgI}{scJ}; sinkChange{tgI}{scJ}{mouseI}(:)];
            end
        end
    end
end

end