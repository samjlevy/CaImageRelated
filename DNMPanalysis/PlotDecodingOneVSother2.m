function [axH, statsOut] = PlotDecodingOneVSother2(decodingResults,shuffledResults,decodedWell,dayDiffsDecoding,dayDiffsShuffled,titles,figHand)

%shuffledResults = squeeze(shuffledResults);
numShuffles = size(shuffledResults,3);

%Reshape decoding data 
numDDs = size(dayDiffsDecoding,1);
if iscell(decodedWell{1}(1))
    resOrig = decodingResults;      decodingResults = [];
    wellOrig = decodedWell;         decodedWell = [];
    ddsOrig = dayDiffsDecoding;     dayDiffsDecoding = [];
    for dtI = 1:length(resOrig)
        dcRes = [];
        dcCorrect = [];
        dcResDays = [];
        
        for ddI = 1:numDDs
            switch class(resOrig{dtI})
                case 'cell'
                    dcRes = [dcRes; squeeze(resOrig{dtI}{ddI})];
                case 'double'
                    dcRes = [dcRes; squeeze(resOrig{dtI}(ddI,1,1:length(wellOrig{dtI}{ddI})))];
            end
            
            dcCorrect = [dcCorrect; wellOrig{dtI}{ddI}];
            dcResDays = [dcResDays; ddsOrig(ddI)*ones(length(wellOrig{dtI}{ddI}),1)];
        end
        
        decodingResults{dtI} = dcRes;
    	decodedWell{dtI} = dcCorrect;
    	dayDiffsDecoding = dcResDays;
    end
end

FWDorREV = {'FWD','REV'};
samePlot = 'yes';
lineType = {'-';'-'};

if strcmpi(samePlot,'yes')
    axH(1) = axes;
    lineType = {'-';'--'};
end

for plotI = 1:length(FWDorREV)
    axH(plotI) = axH(1); hold on
    if strcmpi(samePlot,'no')
        axH(plotI) = subplot(2,2,plotI*2-[1 0]);
    end 

    switch FWDorREV{plotI}
        case 'FWD'
            dayDiffsUse = dayDiffsDecoding>0;
            dayDiffsShuffUse = dayDiffsShuffled>0;
            xlimHere = [0.5 max(dayDiffsDecoding)+0.5];
        case 'REV'
            dayDiffsUse = dayDiffsDecoding<0;
            dayDiffsShuffUse = dayDiffsShuffled<0;
            xlimHere = [min(dayDiffsDecoding)-0.5 -0.5];
            if strcmpi(samePlot,'yes')
                xlimHere = abs(fliplr(xlimHere));
            end
    end
    shuffDayDiffs = repmat(dayDiffsShuffled(dayDiffsShuffUse),numShuffles,1);

    useColors = [1 0 0; 0.4 0.4 0.4];
    shuffResUse = shuffledResults{1}(dayDiffsShuffUse,:,:); shuffResUse = shuffResUse(:);
    [axH(plotI), ~] = PlotDecodingResults2(decodingResults{1}(dayDiffsUse),decodedWell{1}(dayDiffsUse),...
        shuffResUse,dayDiffsDecoding(dayDiffsUse),shuffDayDiffs,'mean',axH(plotI),useColors,-0.15,'all',true,lineType{plotI});

    [statsOut(plotI).slopeDiffZero.Fval(1), statsOut(plotI).slopeDiffZero.dfNum(1),...
        statsOut(plotI).slopeDiffZero.dfDen(1), statsOut(plotI).slopeDiffZero.pVal(1)] =...
        slopeDiffFromZeroFtest(decodingResults{1}(dayDiffsUse),dayDiffsDecoding(dayDiffsUse));
    [~, ~, ~, statsOut(plotI).slope.RR(1), statsOut(plotI).slope.pVal(1), ~] =...
        fitLinRegSL(decodingResults{1}(dayDiffsUse),dayDiffsDecoding(dayDiffsUse));
    
    useColors = [0 0 1; 0.4 0.4 0.4];
    shuffResUse = shuffledResults{2}(dayDiffsShuffUse,:,:); shuffResUse = shuffResUse(:);
    [axH(plotI), ~] = PlotDecodingResults2(decodingResults{2}(dayDiffsUse),decodedWell{2}(dayDiffsUse),...
        shuffResUse,dayDiffsDecoding(dayDiffsUse),shuffDayDiffs,'mean',axH(plotI),useColors,0.15,'all',true,lineType{plotI});

    [statsOut(plotI).slopeDiffZero.Fval(2),statsOut(plotI).slopeDiffZero.dfNum(2),...
        statsOut(plotI).slopeDiffZero.dfDen(2),statsOut(plotI).slopeDiffZero.pVal(2)] =...
        slopeDiffFromZeroFtest(decodingResults{2}(dayDiffsUse),dayDiffsDecoding(dayDiffsUse));
    [~, ~, ~, statsOut(plotI).slope.RR(2), statsOut(plotI).slope.pVal(2), ~] =...
        fitLinRegSL(decodingResults{2}(dayDiffsUse),dayDiffsDecoding(dayDiffsUse));
    
    title([FWDorREV{plotI} ' time ' titles{1} ' vs ' titles{2}])
    xlim(xlimHere)
    ylim([0 1.05])
    xlabel('Days Apart') 
    ylabel('Pct. Decoded Correct')

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
end


end