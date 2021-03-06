function [axHand, statsOut] = PlotDecodingResultsCellArr(decodingResults,decodedWell,shuffledResults,dayDiffs,fitType,axHand,useColors)
%This is intended to work the same as the original decoding results, 
%but instead of each entry in decoding results being a value its a cell array
%day diffs is the same as usual
%shuffled results same as usual, 
%decoded well needs to match the size of decoding results
if isempty(axHand)
    figure; axHand = axes;
end

numDayPairs = size(dayDiffs,1);
numShuffles = size(shuffledResults,3);

if size(dayDiffs,2)==2
dayDiffs = diff(dayDiffs,1,2);
end
eachDayDiffs = unique(dayDiffs);

daylabels = cellfun(@num2str,mat2cell(eachDayDiffs,ones(length(eachDayDiffs),1),1),'UniformOutput',false)';

if any(shuffledResults)
allShuffledData = [];
shuffledDataDays = [];
dcRes = [];
for ddI = 1:numDayPairs
    for eeI = 1:size(shuffledResults,2)
        allShuffledData = [allShuffledData; squeeze(shuffledResults(ddI,eeI,:))];
        shuffledDataDays = [shuffledDataDays; dayDiffs(ddI)*ones(numShuffles,1)];
    end
    
    dcRes = [dcRes; decodingResults{ddI}];
    dcCorrect = [dcCorrect; decodedWell{ddI}];
    dcResDays = [dcResDays; dayDiffs(ddI)*ones(length(decodingResults{ddI}),1)];
end
end

if isempty(useColors)
useColors = [0 0 1; 1 0 0];
end
plotColors = zeros(numDayPairs,3);
plotColors(dcCorrect==1,:) = repmat(useColors(1,:),sum(dcCorrect==1),1);
plotColors(dcCorrect==0,:) = repmat(useColors(2,:),sum(dcCorrect==0),1);

if any(shuffledResults)
scatterBoxSL(allShuffledData,shuffledDataDays,'xLabels',daylabels,'transparency',0.2,'plotBox',false,'plotHand',axHand)
hold on
end
scatterBoxSL(dcRes,dcResDays,'transparency',1,'plotBox',false,'circleColors',plotColors,'plotHand',axHand)

switch fitType
    case 'mean'
        for ddI = 1:length(eachDayDiffs)
            statsOut.meanLine(ddI) = mean(dcRes(dcResDays==eachDayDiffs(ddI)));
            statsOut.errorLine(ddI) = standarderrorSL(dcRes(dcResDays==eachDayDiffs(ddI)));
        end
        statsOut.eachDayDiffs = eachDayDiffs;
        
        errorbar(eachDayDiffs,statsOut.meanLine,statsOut.errorLine,'Color',useColors(1,:));
    case 'regress'
        [statsOut.plotRegFWD,statsOut.daysPlotFWD] = FitLineForPlotting(dcRes(dcResDays>-1),dcResDays(dcResDays>-1));
        
        [statsOut.plotRegREV,statsOut.daysPlotREV] = FitLineForPlotting(dcRes(dcResDays<1),dcResDays(dcResDays<1));
        
        if length(statsOut.daysPlotREV) > 1
           plot(statsOut.daysPlotREV,statsOut.plotRegREV,'Color',useColors(1,:))
        end
        if length(statsOut.daysPlotFWD) > 1
            plot(statsOut.daysPlotFWD,statsOut.plotRegFWD,'Color',useColors(1,:))
        end
end


end
