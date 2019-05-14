function [statsOut] = PlotDecodingScatter(decodingRes,shuffledRes,decodedWell,daysApart,fitWhich,plotDots,fitType,xDotShift,...
    xLineShift,useColors,lineType,transparency,axHand)

if isempty(transparency)
    transparency = 1;
end
statsOut = [];
numDayPairs = size(daysApart,1);

eachDayDiffs = unique(daysApart);
daylabels = cellfun(@num2str,mat2cell(eachDayDiffs,ones(length(eachDayDiffs),1),1),'UniformOutput',false)';

%Check if it's regular data
if ~isempty(decodingRes)
    if iscell(decodedWell)
        dcRes = [];
        dcCorrect = [];
        dcResDays = [];

        for dpI = 1:length(decodedWell)
            dcResDays = [dcResDays; daysApart(dpI)*ones(length(decodedWell{dpI}),1)];
            dcCorrect = [dcCorrect; decodedWell{dpI}(:)];
            if iscell(decodingRes(1))
                dcRes = [dcRes; decodingRes{dpI}(:)];
            elseif isnumeric(decodingRes(1))
                rTemp = decodingRes(dpI,1:length(decodedWell{dpI}));
                dcRes = [dcRes; rTemp(:)];
            end
        end
    else
        dcRes = decodingRes;
        dcCorrect = decodedWell;
        dcResDays = daysApart;
    end
    
    plotColors = zeros(numDayPairs,3);
    plotColors(dcCorrect==1,:) = repmat(useColors(1,:),sum(dcCorrect==1),1);
    plotColors(dcCorrect==0,:) = repmat(useColors(2,:),sum(dcCorrect==0),1);

    dotTrans = 1;
    if plotDots==false
        dotTrans = 0;
    end
    scatterBoxSL(dcRes,dcResDays+xDotShift,'transparency',dotTrans,'plotBox',false,'circleColors',plotColors,'plotHand',axHand)

    fitMod = true(length(dcRes),1);
    if strcmpi(fitWhich,'goodOnly')
        fitMod = logical(dcCorrect);
    elseif strcmpi(fitWhich,'all')%really anything else
        %do nothing
    end
    
    for ddI = 1:length(eachDayDiffs)
        dataWork = dcRes(dcResDays==eachDayDiffs(ddI) & fitMod);
        statsOut.meanLine(ddI) = mean(dataWork);
        statsOut.errorLine(ddI) = standarderrorSL(dataWork);
        dataWorkSorted = sort(dataWork,'ascend');
        statsOut.CIupper(ddI) = dataWorkSorted(round(length(dataWorkSorted)*0.975));
        statsOut.CIlower(ddI) = dataWorkSorted(max([round(length(dataWorkSorted)*0.025) 1]));
    end
    statsOut.eachDayDiffs = eachDayDiffs;
    if any(dcResDays>0)
        [statsOut.plotRegFWD,statsOut.daysPlotFWD] = FitLineForPlotting(dcRes(dcResDays>0 & fitMod),dcResDays(dcResDays>0 & fitMod));
    end
    if any(dcResDays<0)
        [statsOut.plotRegREV,statsOut.daysPlotREV] = FitLineForPlotting(dcRes(dcResDays<0 & fitMod),dcResDays(dcResDays<0 & fitMod));
    end   

    if isempty(lineType)
        lineType = '-';
    end

    switch fitType
        case 'mean'    
            aa = errorbar(eachDayDiffs+xLineShift,statsOut.meanLine,statsOut.errorLine,lineType,'Color',[useColors(1,:) transparency],'LineWidth',2);
        case 'meanNoErr'
            aa = plot(eachDayDiffs+xLineShift,statsOut.meanLine,lineType,'Color',[useColors(1,:) transparency],'LineWidth',2);
        case 'meanErrPatch' 
            xCorners = [eachDayDiffs(:); flipud(eachDayDiffs(:))];
            yCorners = [statsOut.meanLine(:) + statsOut.errorLine(:);...
                        flipud(statsOut.meanLine(:) - statsOut.errorLine(:))];
            patch(xCorners,yCorners,useColors(1,:),'FaceAlpha',transparency-0.15,'EdgeColor','none')
                    
            aa = plot(eachDayDiffs+xLineShift,statsOut.meanLine,lineType,'Color',[useColors(1,:) transparency],'LineWidth',2);
        case 'meanCI'
            xCorners = [eachDayDiffs(:); flipud(eachDayDiffs(:))];%; eachDayDiffs(1)
            yCorners = [statsOut.CIupper(:); flipud(statsOut.CIlower(:))];%; CIupperLine(1)
            patch(xCorners,yCorners,useColors(1,:),'FaceAlpha',transparency-0.15,'EdgeColor','none')
            
            aa = plot(eachDayDiffs+xLineShift,statsOut.meanLine,lineType,'Color',[useColors(1,:) transparency],'LineWidth',2);
        case 'regress'
            if any(dcResDays>0)
                aa = plot(statsOut.daysPlotFWD+xLineShift,statsOut.plotRegFWD,lineType,'Color',[useColors(1,:) transparency],'LineWidth',2);
            end

            if any(dcResDays<0)
                aa = plot(statsOut.daysPlotREV+xLineShift,statsOut.plotRegREV,lineType,'Color',[useColors(1,:) transparency],'LineWidth',2);
            end
        case 'none'
            %do nothing
    end
    
       
%Check if it's shuffled data
elseif ~isempty(shuffledRes)
    numShuffles = size(shuffledRes,3);
    
    allShuffledData = [];
    shuffledDataDays = [];
    for ddI = 1:numDayPairs
        for eeI = 1:size(shuffledRes,2)
                allShuffledData = [allShuffledData; squeeze(shuffledRes(ddI,eeI,:))];
                shuffledDataDays = [shuffledDataDays; daysApart(ddI)*ones(numShuffles,1)];
        end
    end 
    
    dotTrans = 0.2;
    if plotDots==false
        dotTrans = 0;
        for ddI = 1:length(eachDayDiffs)
            dataHere = allShuffledData(shuffledDataDays==eachDayDiffs(ddI));
            meanLine(ddI) = mean(dataHere);
            
            dataHereSorted = sort(dataHere,'ascend');
            CIupperLine(ddI) = dataHereSorted(round(length(dataHereSorted)*0.975));
            CIlowerLine(ddI) = dataHereSorted(round(length(dataHereSorted)*0.025));
        end
        
        switch fitType
            case 'meanNoErr'
                plot(eachDayDiffs+xLineShift,meanLine,'LineStyle','--','Color',[0.6 0.6 0.6],'LineWidth',2)
            case 'meanCI'
                plot(eachDayDiffs+xLineShift,meanLine,'LineStyle','--','Color',[0.6 0.6 0.6],'LineWidth',2)
                xCorners = [eachDayDiffs(:); flipud(eachDayDiffs(:))];%; eachDayDiffs(1)
                yCorners = [CIupperLine(:); flipud(CIlowerLine(:))];%; CIupperLine(1)
                patch(xCorners,yCorners,[0.6 0.6 0.6],'FaceAlpha',0.5,'EdgeColor','none')
        end
    end
    scatterBoxSL(allShuffledData,shuffledDataDays+xDotShift,'xLabels',daylabels,'transparency',dotTrans,'plotBox',false,'plotHand',axHand)
end    



end
