function [pooledDailySources, pooledDailySinks, sourceDayDiffsPooled, sinkDayDiffsPooled] =...
    CheckLogicalSinksAndSources2(targets,sources,sinks,cellPresent,poolNewWith)
%looks at what cells come from and what they change into
%This is an overhaul and output is reformatted slightly compared to
%original. Will include all possible days, so both sources and sinks will
%now be one day too long
%poolNewWith means if a cell is labeled new, can instead pool that count
%with one of the other source/sink groups

numMice = length(cellPresent);
numTargets = length(targets{1});
numSources = length(sources{1});
numSinks = length(sinks{1});

for tgI = 1:length(targets{1})
    pooledDailySources{tgI} = cell(numSources+1,1);
    pooledDailySinks{tgI} = cell(numSinks+1,1);
end

sourceDayDiffsPooled = [];
sinkDayDiffsPooled = [];
for mouseI = 1:numMice
    numCells = size(sources{mouseI}{1},1);
    numDays = size(cellPresent{mouseI},2);
    
    for tgI = 1:numTargets
        daysUseSources = 2:numDays;
        daysUseSinks = 1:numDays-1;
        
        dailySource{mouseI}{tgI} = zeros(numCells,numDays);
        dailySink{mouseI}{tgI} = zeros(numCells,numDays);
        for cellI = 1:numCells
            
            %Get sources
            daysCheckSources = find(targets{mouseI}{tgI}(cellI,daysUseSources));
            if any(daysCheckSources)
                daysCellHereSource = find(cellPresent{mouseI}(cellI,:));
                for dcI = 1:length(daysCheckSources)
                    targetDay = daysCheckSources(dcI)+1;
                    
                    %Look at previous day the cell is present
                    previousDay = find(daysCellHereSource<targetDay,1,'last');
                    if any(previousDay)
                        %Check through sources to find it
                        for scI = 1:numSources
                            cellIsHere = sources{mouseI}{scI}(cellI,previousDay) == 1;
                            %thisSource{mouseI}{tgI}{scI}(cellI,targetDay-1) = targets{mouseI}{tgI}(cellI,targetDay-1);
                            if cellIsHere
                                dailySource{mouseI}{tgI}(cellI,targetDay) = scI;
                            end
                        end
                    else
                        if any(poolNewWith)
                            dailySource{mouseI}{tgI}(cellI,targetDay) = poolNewWith;
                            %If no previous days, it's a new cell
                        else
                            dailySource{mouseI}{tgI}(cellI,targetDay) = numSources+1;
                        end
                    end
                end                     
            end
            
            %Get sinks
            daysCheckSinks = find(targets{mouseI}{tgI}(cellI,daysUseSinks));
            if any(daysCheckSinks)
                daysCellHereSink = find(cellPresent{mouseI}(cellI,:));
                for dcJ = 1:length(daysCheckSinks)
                    targetDay = daysCheckSinks(dcJ);
                    
                    %Look at next day cell is present
                    nextDay = find(daysCellHereSink>targetDay,1,'first');
                    if any(nextDay)
                        for scJ = 1:numSinks
                            cellIsHere = sinks{mouseI}{scJ}(cellI,nextDay) == 1;
                            %thisSource{mouseI}{tgI}{scI}(cellI,targetDay-1) = targets{mouseI}{tgI}(cellI,targetDay-1);
                            if cellIsHere
                                dailySink{mouseI}{tgI}(cellI,targetDay) = scJ;
                            end
                        end
                    else
                        %if no next day, cell deactivates
                        dailySink{mouseI}{tgI}(cellI,targetDay) = numSinks+1;
                    end
                end
            end     
        end
         
        %Reorganize
        for scI = 1:numSources+1
            thisSourceSum{mouseI}{tgI}{scI} = sum(dailySource{mouseI}{tgI}==scI,1);
            thisSourceSumNorm{mouseI}{tgI}{scI} = thisSourceSum{mouseI}{tgI}{scI} ./ sum(targets{mouseI}{tgI},1);
            thisSourceSumNorm{mouseI}{tgI}{scI} = thisSourceSumNorm{mouseI}{tgI}{scI}(2:end);
            
            pooledDailySources{tgI}{scI} = [pooledDailySources{tgI}{scI}; thisSourceSumNorm{mouseI}{tgI}{scI}(:)];
        end
        
        for scJ = 1:numSinks+1
            thisSinkSum{mouseI}{tgI}{scJ} = sum(dailySink{mouseI}{tgI}==scJ,1);
            thisSinkSumNorm{mouseI}{tgI}{scJ} = thisSinkSum{mouseI}{tgI}{scJ} ./ sum(targets{mouseI}{tgI},1);
            thisSinkSumNorm{mouseI}{tgI}{scJ} = thisSinkSumNorm{mouseI}{tgI}{scJ}(1:end-1);
            
            pooledDailySinks{tgI}{scJ} = [pooledDailySinks{tgI}{scJ}; thisSinkSumNorm{mouseI}{tgI}{scJ}(:)];
        end
    end
end

end