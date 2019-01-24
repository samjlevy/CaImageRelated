function [axHand, statsOut] = PlotDecodingResults2(decodingResults,decodedWell,...
    shuffledResults,dayDiffsDecoding,dayDiffsShuffled,fitType,axHand,useColors,xShift,fitWhich)

statsOut = [];

if iscell(decodedWell)
    dcRes = [];
    dcCorrect = [];
    dcResDays = [];
    
    for dpI = 1:length(decodedWell)
        dcResDays = [dcResDays; dayDiffsDecoding(dpI)*ones(length(decodedWell{dpI}),1)];
        dcCorrect = [dcCorrect; decodedWell{dpI}(:)];
        if iscell(decodingResults(1))
            dcRes = [dcRes; decodingResults{dpI}(:)];
        elseif isnumeric(decodingResults(1))
            rTemp = decodingResults(dpI,1:length(decodedWell{dpI}));
            dcRes = [dcRes; rTemp(:)];
        end
    end
else 
    dcRes = decodingResults;
    dcCorrect = decodedWell;
    dcResDays = dayDiffsDecoding;
end
   

eachDayDiffs = unique([dayDiffsDecoding; dayDiffsShuffled]);
daylabels = cellfun(@num2str,mat2cell(eachDayDiffs,ones(length(eachDayDiffs),1),1),'UniformOutput',false)';

allShuffledData = [];
shuffledDataDays = [];
numDayPairs = size(dayDiffsShuffled,1);
numShuffles = size(shuffledResults,3);
for ddI = 1:numDayPairs
    if any(shuffledResults)
        for eeI = 1:size(shuffledResults,2)
            allShuffledData = [allShuffledData; squeeze(shuffledResults(ddI,eeI,:))];
            shuffledDataDays = [shuffledDataDays; dayDiffsShuffled(ddI)*ones(numShuffles,1)];
        end
    end
end

if isempty(useColors)
    useColors = [0 0 1; 1 0 0];
end
plotColors = zeros(numDayPairs,3);
plotColors(dcCorrect==1,:) = repmat(useColors(1,:),sum(dcCorrect==1),1);
plotColors(dcCorrect==0,:) = repmat(useColors(2,:),sum(dcCorrect==0),1);

if isempty(axHand)
    figure; axHand = axes;
end

if any(shuffledResults)
scatterBoxSL(allShuffledData,shuffledDataDays+xShift,'xLabels',daylabels,'transparency',0.2,'plotBox',false,'plotHand',axHand)
hold on
end
scatterBoxSL(dcRes,dcResDays+xShift,'transparency',1,'plotBox',false,'circleColors',plotColors,'plotHand',axHand)

fitMod = true(length(dcRes),1);
if strcmpi(fitWhich,'goodOnly')
    fitMod = logical(dcCorrect);
end

for ddI = 1:length(eachDayDiffs)
    statsOut.meanLine(ddI) = mean(dcRes(dcResDays==eachDayDiffs(ddI) & fitMod));
    statsOut.errorLine(ddI) = standarderrorSL(dcRes(dcResDays==eachDayDiffs(ddI) & fitMod));
end
statsOut.eachDayDiffs = eachDayDiffs;
if any(dcResDays>0)
    [statsOut.plotRegFWD,statsOut.daysPlotFWD] = FitLineForPlotting(dcRes(dcResDays>0 & fitMod),dcResDays(dcResDays>0 & fitMod));
end
if any(dcResDays<0)
    [statsOut.plotRegREV,statsOut.daysPlotREV] = FitLineForPlotting(dcRes(dcResDays<0 & fitMod),dcResDays(dcResDays<0 & fitMod));
end   

switch fitType
    case 'mean'    
        errorbar(eachDayDiffs,statsOut.meanLine,statsOut.errorLine,'Color',useColors(1,:));
    case 'regress'
        if any(dcResDays>0)
            plot(statsOut.daysPlotFWD,statsOut.plotRegFWD,'Color',useColors(1,:),'LineWidth',2)
        end
        
        if any(dcResDays<0)
            plot(statsOut.daysPlotREV,statsOut.plotRegREV,'Color',useColors(1,:),'LineWidth',2)
        end
    case 'none'
        %do nothing
        
end


end
