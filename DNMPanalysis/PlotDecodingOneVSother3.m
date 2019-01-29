function [axHand,statsOut] = PlotDecodingOneVSother3(decodingResults,shuffledResults,decodedWell,dayDiffsDecoding,dayDiffsShuffled,titles,figHand)
statsOut = [];

FWDorREV = {'FWD','REV'};
lineType = {'-';'--'};
samePlot = true;
xOffset = [-0.1 0.1];

axHand(1) = axes;
if samePlot==true
    dayDiffsShuffled = abs(dayDiffsShuffled);
    xlim([0.5 max(dayDiffsDecoding)+0.5])
end

for dirI = 1:length(FWDorREV)
    axHand(dirI) = axHand(1); hold on
    
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
        axHand(dirI) = subplot(2,2,plotI*2-[1 0]);
        xlim(xlimHere)
    end 
    
    %PlotShuffled 1 and 2 together
    if any(dayDiffsShuffUse)
        shuffPlot = [shuffledResults{1}(dayDiffsShuffUse); shuffledResults{2}(dayDiffsShuffUse)];
        shuffDays = [dayDiffsShuffled(dayDiffsShuffUse); dayDiffsShuffled(dayDiffsShuffUse)];
        [~] = PlotDecodingScatter([],shuffPlot,[],shuffDays,...
            [],false,'meanNoErr',0,0,[],lineType{dirI},axHand(dirI));
    end
    
    dayDiffsHere = dayDiffsDecoding;
    if samePlot==true
        dayDiffsHere = abs(dayDiffsDecoding);
    end
    %Plot real 1
    useColors = [1 0 0; 0.4 0.4 0.4];
    [~] = PlotDecodingScatter(decodingResults{1}(dayDiffsUse),[],decodedWell{1}(dayDiffsUse),...
        dayDiffsHere(dayDiffsUse),'all',false,'mean',0,xOffset(dirI),useColors,lineType{dirI},axHand(dirI));
    
    %Plot real 2
    useColors = [0 0 1; 0.4 0.4 0.4];
    [~] = PlotDecodingScatter(decodingResults{2}(dayDiffsUse),[],decodedWell{2}(dayDiffsUse),...
        dayDiffsHere(dayDiffsUse),'all',false,'mean',0,xOffset(dirI),useColors,lineType{dirI},axHand(dirI));
    
    ylim([0 1.05])
    xlabel('Days Apart') 
    ylabel('Pct. Decoded Correct')
    
    %{
    [statsOut(plotI).slopeDiffZero.Fval(1), statsOut(plotI).slopeDiffZero.dfNum(1),...
        statsOut(plotI).slopeDiffZero.dfDen(1), statsOut(plotI).slopeDiffZero.pVal(1)] =...
        slopeDiffFromZeroFtest(decodingResults{1}(dayDiffsUse),dayDiffsDecoding(dayDiffsUse));
    [~, ~, ~, statsOut(plotI).slope.RR(1), statsOut(plotI).slope.pVal(1), ~] =...
        fitLinRegSL(decodingResults{1}(dayDiffsUse),dayDiffsDecoding(dayDiffsUse));
    
    %Slopes different from each other?
    [statsOut(plotI).slopeDiffComp.Fval,statsOut(plotI).slopeDiffComp.dfNum,...
         statsOut(plotI).slopeDiffComp.dfDen,statsOut(plotI).slopeDiffComp.pVal] =...
         TwoSlopeFTest(decodingResults{1}(dayDiffsUse),decodingResults{2}(dayDiffsUse),...
                          dayDiffsDecoding(dayDiffsUse),dayDiffsDecoding(dayDiffsUse));
                  
    %Sign test each day
    [statsOut(plotI).signtests.pVal, statsOut(plotI).signtests.hVal,...
     statsOut(plotI).signtests.whichWon, statsOut(plotI).signtests.eachDayPair] =...
        SignTestAllDayPairs(decodingResults{1}(dayDiffsUse),...
        	decodingResults{2}(dayDiffsUse),dayDiffsDecoding(dayDiffsUse));
        
    %Ranksum each day
    [statsOut(plotI).ranksums.pVal, statsOut(plotI).ranksums.hVal,...
     statsOut(plotI).ranksums.whichWon, statsOut(plotI).ranksums.eachDayPair] =...
        RankSumAllDaypairs(decodingResults{1}(dayDiffsUse),...
        	decodingResults{2}(dayDiffsUse),dayDiffsDecoding(dayDiffsUse));
        
    %Ranksum
    [statsOut(plotI).rankSumAll.pVal, statsOut(plotI).rankSumAll.hVal] = ...
        ranksum(decodingResults{1}(dayDiffsUse),decodingResults{2}(dayDiffsUse));
    %}
end

end