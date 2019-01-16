function [axH, statsOut] = PlotDecodingDECvsDS(decodingResults,shuffledResults,decodedWell,dayDiffsDecoding,dayDiffsShuffled,titles,figHand)

Maybe this should compare the lines for performance over shuffle (decodingresults(decodedWell)) vs. 
                                        performance over downsampled (decodingresults(decodedAboveDS))

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

FWDorREV = {'REV','FWD'};
numPlots = length(decodingResults);

for plotI = 1:numPlots
    for fwd = 1:length(FWDorREV)
        axH(plotI) = subplot(numPlots,2,plotI*2-rem(fwd,2));

        switch FWDorREV{fwd}
            case 'FWD'
                dayDiffsUse = dayDiffsDecoding>0;
                dayDiffsShuffUse = dayDiffsShuffled>0;
                xlimHere = [0.5 max(dayDiffsDecoding)+0.5];
            case 'REV'
                dayDiffsUse = dayDiffsDecoding<0;
                dayDiffsShuffUse = dayDiffsShuffled<0;
                xlimHere = [min(dayDiffsDecoding)-0.5 -0.5];
        end
        shuffDayDiffs = repmat(dayDiffsShuffled(dayDiffsShuffUse),numShuffles,1);

        useColors = [1 0 0; 0.4 0.4 0.4];
        shuffResUse = shuffledResults{plotI}(dayDiffsShuffUse,:,:); shuffResUse = shuffResUse(:);
        [axH(plotI), ~] = PlotDecodingResults(decodingResults{plotI}(dayDiffsUse),decodedWell{1}(dayDiffsUse),...
            shuffResUse,dayDiffsDecoding(dayDiffsUse),shuffDayDiffs,'none',axH(plotI),[],0);

        [statsOut(plotI,fwd).slopeDiffZero.Fval, statsOut(plotI,fwd).slopeDiffZero.dfNum,...
         statsOut(plotI,fwd).slopeDiffZero.dfDen, statsOut(plotI,fwd).slopeDiffZero.pVal] =...
            slopeDiffFromZeroFtest(decodingResults{plotI}(dayDiffsUse),dayDiffsDecoding(dayDiffsUse));
        [~, ~, ~, statsOut(plotI,fwd).slope.RR, statsOut(plotI,fwd).slope.pVal, ~] =...
            fitLinRegSL(decodingResults{plotI}(dayDiffsUse),dayDiffsDecoding(dayDiffsUse));
    
        %Ranksum
        [statsOut(plotI,fwd).rankSumAll.pVal, statsOut(plotI,fwd).rankSumAll.hVal] = ...
            ranksum(decodingResults{plotI}(dayDiffsUse),shuffResUse);
    
        %Ranksum each day
        [statsOut(plotI,fwd).ranksums.pVal, statsOut(plotI,fwd).ranksums.hVal,...
         statsOut(plotI,fwd).ranksums.whichWon, statsOut(plotI,fwd).ranksums.eachDayPair] =...
            RankSumAllDaypairsX(decodingResults{plotI}(dayDiffsUse),...
                shuffResUse,dayDiffsDecoding(dayDiffsUse),shuffDayDiffs);
    
        title([FWDorREV{fwd} ' time ' titles{plotI} ' vs shuffled'])
        xlim(xlimHere)
        ylim([0 1.05])
        xlabel('Days Apart'); 
        ylabel('Pct. Decoded Correct')
    end    
end


end