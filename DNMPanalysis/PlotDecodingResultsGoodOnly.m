function [axHand, statsOut] = PlotDecodingResultsGoodOnly(decodingResults,decodedWell,...
    shuffledResults,dayDiffsDecoding,dayDiffsShuffled,fitType,axHand,useColors,xShift)

dealCell = 1;
dealDouble = 1;
if iscell(decodingResults(1))
    dealCell = 1;
    dealDouble = 0;
elseif isnumeric(decodingResults(1))
    if iscell(decodedWell)
        dealCell = 1;
        dealDouble = 1;
    else
        dealCell = 0;
        dealDouble = 0;
    end
end


if isempty(axHand)
    figure; axHand = axes;
end

numDayPairs = size(dayDiffsDecoding,1);
numShuffles = size(shuffledResults,3);

%if size(dayDiffs,2)==2
%dayDiffs = diff(dayDiffs,1,2);
%end
eachDayDiffs = unique([dayDiffsDecoding; dayDiffsShuffled]);

daylabels = cellfun(@num2str,mat2cell(eachDayDiffs,ones(length(eachDayDiffs),1),1),'UniformOutput',false)';

allShuffledData = [];
shuffledDataDays = [];
dcRes = [];
dcCorrect = [];
dcResDays = [];
for ddI = 1:numDayPairs
    if any(shuffledResults)
        for eeI = 1:size(shuffledResults,2)
            allShuffledData = [allShuffledData; squeeze(shuffledResults(ddI,eeI,:))];
            shuffledDataDays = [shuffledDataDays; dayDiffsShuffled(ddI)*ones(numShuffles,1)];
        end
    end
    
    if dealCell==1
        if dealDouble==1
            dcRes = [dcRes; squeeze(decodingResults(ddI,1,1:length(decodedWell{ddI})))];
        else
            dcRes = [dcRes; decodingResults{ddI}]; 
        end
            
        dcCorrect = [dcCorrect; decodedWell{ddI}];
        dcResDays = [dcResDays; dayDiffsDecoding(ddI)*ones(length(decodedWell{ddI}),1)];
    end
end


if dealCell==0
    dcRes = decodingResults(:);
    dcResDays = repmat(dayDiffsDecoding,size(decodingResults,2),1);
    dcCorrect = decodedWell(:);
end

if isempty(useColors)
useColors = [0 0 1; 1 0 0];
end
plotColors = zeros(numDayPairs,3);
plotColors(dcCorrect==1,:) = repmat(useColors(1,:),sum(dcCorrect==1),1);
plotColors(dcCorrect==0,:) = repmat(useColors(2,:),sum(dcCorrect==0),1);

if any(shuffledResults)
scatterBoxSL(allShuffledData,shuffledDataDays+xShift,'xLabels',daylabels,'transparency',0.2,'plotBox',false,'plotHand',axHand)
hold on
end
scatterBoxSL(dcRes,dcResDays+xShift,'transparency',1,'plotBox',false,'circleColors',plotColors,'plotHand',axHand)

switch fitType
    case 'mean'
        for ddI = 1:length(eachDayDiffs)
            statsOut.meanLine(ddI) = mean(dcRes(dcResDays==eachDayDiffs(ddI) & dcCorrect));
            statsOut.errorLine(ddI) = standarderrorSL(dcRes(dcResDays==eachDayDiffs(ddI) & dcCorrect));
        end
        statsOut.eachDayDiffs = eachDayDiffs;
        
        errorbar(eachDayDiffs,statsOut.meanLine,statsOut.errorLine,'Color',useColors(1,:));
    case 'regress'
        if any(dcResDays>0)
            [statsOut.plotRegFWD,statsOut.daysPlotFWD] = FitLineForPlotting(dcRes(dcResDays>0 & dcCorrect),dcResDays(dcResDays>0 & dcCorrect));
            plot(statsOut.daysPlotFWD,statsOut.plotRegFWD,'Color',useColors(1,:),'LineWidth',2)
        end
        
        if any(dcResDays<0)
            [statsOut.plotRegREV,statsOut.daysPlotREV] = FitLineForPlotting(dcRes(dcResDays<0 & dcCorrect),dcResDays(dcResDays<0 & dcCorrect));
            plot(statsOut.daysPlotREV,statsOut.plotRegREV,'Color',useColors(1,:),'LineWidth',2)
        end
    case 'none'
        %do nothing
        statsOut.line = [];
        %disp('here')
end

%disp(' ')
end
