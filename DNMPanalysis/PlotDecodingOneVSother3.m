function [axHand,statsOut] = PlotDecodingOneVSother3(decodingResults,shuffledResults,decodedWell,...
    dayDiffsDecoding,dayDiffsShuffled,titles,lineType,transHere,mainColors,runPermTest,axHand)
statsOut = [];

global dayLagLimit
if any(dayLagLimit)
    badLagsDec = abs(dayDiffsDecoding) > dayLagLimit;
    badLagsShuff = abs(dayDiffsShuffled) > dayLagLimit;
    for dd = 1:length(decodingResults)
        decodingResults{dd}(badLagsDec,:,:) = [];
        shuffledResults{dd}(badLagsShuff,:,:) = [];
    end
    dayDiffsDecoding(badLagsDec) = [];
    dayDiffsShuffled(badLagsShuff) = [];
end

if isempty(mainColors)
    mainColors = [1 0 0; 0 0 1];
end

%FWDorREV = {'FWD','REV'};
if isempty(lineType)
lineType = {'-';'--'};
end
if isempty(transHere)
    transHere = [1 1];
end
samePlot = true;
%xOffset = [-0.1 0.1];

FWDorREV = {'all'};
xOffset = 0;

%axHand(1) = axes;
if samePlot==true
    dayDiffsShuffled = abs(dayDiffsShuffled);
    xlim([0.5 max(dayDiffsDecoding)+0.5])
end

for dirI = 1:length(FWDorREV)
    %axHand(dirI) = axHand(1); hold on
    axHandPlot = axHand(1);
    
    if strcmpi(FWDorREV{dirI},'all')
        dayDiffsDecoding = abs(dayDiffsDecoding);
        dayDiffsShuffled = abs(dayDiffsShuffled);
        FWDorREV{dirI} = 'FWD';
    end
    
    switch FWDorREV{dirI}
        case 'FWD'
            dayDiffsUse = dayDiffsDecoding>0;
            dayDiffsShuffUse = dayDiffsShuffled>0;
            xlimHere = [0.5 max(dayDiffsDecoding)+0.5];
        case 'REV'
            dayDiffsUse = dayDiffsDecoding<0;
            dayDiffsShuffUse = dayDiffsShuffled<0;
            xlimHere = [min(dayDiffsDecoding)-0.5 -0.5];
            if samePlot==true
                xlimHere = abs(fliplr(xlimHere));
            end
    end    
    
    if samePlot==false
        %axHand(dirI) = subplot(2,2,dirI*2-[1 0]);
        axHandPlot = axHand(dirI);
        xlim(xlimHere)
        
    end 
    
    %PlotShuffled 1 and 2 together
    if any(dayDiffsShuffUse)
        shuffPlot = [shuffledResults{1}(dayDiffsShuffUse); shuffledResults{2}(dayDiffsShuffUse)];
        shuffDays = [dayDiffsShuffled(dayDiffsShuffUse); dayDiffsShuffled(dayDiffsShuffUse)];
        [~] = PlotDecodingScatter([],shuffPlot,[],shuffDays,...
            [],false,'meanNoErr',0,0,[],'--',1,axHandPlot);
        %(decodingRes,shuffledRes,decodedWell,daysApart,fitWhich,false,fitType,xDotShift,...
        %xLineShift,useColors,lineType,transparency,axHand)
    end
    
    dayDiffsHere = dayDiffsDecoding;
    if samePlot==true
        dayDiffsHere = abs(dayDiffsDecoding);
    end
    %Plot real 1
    useColors = [mainColors(1,:); 0.4 0.4 0.4];
    [~] = PlotDecodingScatter(decodingResults{1}(dayDiffsUse,:,:),[],decodedWell{1}(dayDiffsUse),...
        dayDiffsHere(dayDiffsUse),'all',false,'meanNoErr',0,xOffset(dirI),useColors,lineType{1},transHere(1),axHandPlot);
    
    %Plot real 2
    useColors = [mainColors(2,:); 0.4 0.4 0.4];
    [~] = PlotDecodingScatter(decodingResults{2}(dayDiffsUse,:,:),[],decodedWell{2}(dayDiffsUse),...
        dayDiffsHere(dayDiffsUse),'all',false,'meanNoErr',0,xOffset(dirI),useColors,lineType{2},transHere(2),axHandPlot);
    
    ylim([0 1.05])
    xlabel('Days Apart') 
    ylabel('Pct. Decoded Correct')
    
    dayDiffs = dayDiffsHere(dayDiffsUse);
    if iscell(decodedWell{1})
        [dataOne,dayDiffsOne,dcWellOne] = LinearizeCell(decodingResults{1}(dayDiffsUse,:,:),dayDiffs,decodedWell{1}(dayDiffsUse));
    else
        dataOne = decodingResults{1}(dayDiffsUse);
        dcWellOne = decodedWell{1}(dayDiffsUse);
        dayDiffsOne = dayDiffs;
    end
    if iscell(decodedWell{2})
        [dataTwo,dayDiffsTwo,dcWellTwo] = LinearizeCell(decodingResults{2}(dayDiffsUse,:,:),dayDiffs,decodedWell{2}(dayDiffsUse));
    else
        dataTwo = decodingResults{2}(dayDiffsUse);
        dcWellTwo = decodedWell{2}(dayDiffsUse);
        dayDiffsTwo = dayDiffs;
    end
    
    %Each line's stuff
    [statsOut(dirI).slopeDiffZero.Fval(1), statsOut(dirI).slopeDiffZero.dfNum(1),...
        statsOut(dirI).slopeDiffZero.dfDen(1), statsOut(dirI).slopeDiffZero.pVal(1)] =...
        slopeDiffFromZeroFtest(dataOne,dayDiffsOne);
    [~, ~, ~, statsOut(dirI).slope.RR(1), statsOut(dirI).slope.pVal(1), ~] =...
        fitLinRegSL(dataOne,dayDiffsOne);
    
    [statsOut(dirI).slopeDiffZero.Fval(2), statsOut(dirI).slopeDiffZero.dfNum(2),...
        statsOut(dirI).slopeDiffZero.dfDen(2), statsOut(dirI).slopeDiffZero.pVal(2)] =...
        slopeDiffFromZeroFtest(dataTwo,dayDiffsTwo);
    [~, ~, ~, statsOut(dirI).slope.RR(2), statsOut(dirI).slope.pVal(2), ~] =...
        fitLinRegSL(dataTwo,dayDiffsTwo);
    
    if runPermTest==true
    statsOut(dirI).slopeDiffZeroPerm.pVal(1) = slopePermutationTest(dataOne,dayDiffsOne,1000);
    statsOut(dirI).slopeDiffZeroPerm.pVal(2) = slopePermutationTest(dataTwo,dayDiffsTwo,1000);
    else
        statsOut(dirI).slopeDiffZeroPerm.pVal(1:2) = [];
    end
    %Slopes different from each other?
    [statsOut(dirI).slopeDiffComp.Fval,statsOut(dirI).slopeDiffComp.dfNum,...
         statsOut(dirI).slopeDiffComp.dfDen,statsOut(dirI).slopeDiffComp.pVal] =...
         TwoSlopeFTest(dataOne,dataTwo,dayDiffsOne,dayDiffsTwo);
                  
    %Sign test each day
    if length(dataOne)==length(dataTwo)
    [statsOut(dirI).signtests.pVal, statsOut(dirI).signtests.hVal,...
     statsOut(dirI).signtests.whichWon, statsOut(dirI).signtests.eachDayPair] =...
        SignTestAllDayPairs(dataOne,dataTwo,dayDiffs);
    
    [statsOut(dirI).signRankTests.pVal,statsOut(dirI).signRankTests.hVal,...
        ~,statsOut(dirI).signRankTests.whichWon,statsOut(dirI).signRankTests.eachDayPair] =...
        SignRankTestAllDayPairs(dataOne,dataTwo,dayDiffs);
    end
        
    %Ranksum each day
    [statsOut(dirI).ranksums.pVal, statsOut(dirI).ranksums.hVal,...
     statsOut(dirI).ranksums.whichWon, statsOut(dirI).ranksums.eachDayPair] =...
        RankSumAllDaypairsX(dataOne,dataTwo,dayDiffsOne,dayDiffsTwo);
        
    %Ranksum
    [statsOut(dirI).rankSumAll.pVal, statsOut(dirI).rankSumAll.hVal] = ...
        ranksum(dataOne,dataTwo);
end

end