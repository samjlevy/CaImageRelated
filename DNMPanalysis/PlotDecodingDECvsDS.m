function [axH, statsOut] = PlotDecodingDECvsDS(decodingResults,downsampledResults,shuffledResults,...
    regDecodedWell,dsDecodedWell,dayDiffsDecoding,dayDiffsDownsampled,dayDiffsShuffled,titles,figHand)

%Maybe this should compare the lines for performance over shuffle (decodingresults(decodedWell)) vs. 
%                                        performance over downsampled (decodingresults(decodedAboveDS))

%shuffledResults = squeeze(shuffledResults);
numShuffles = size(shuffledResults,3);

%Reshape decoding data 
numDDs = size(dayDiffsDecoding,1);
if iscell(regDecodedWell{1}(1))
    resOrig = decodingResults;      decodingResults = [];
    wellOrig = regDecodedWell;         regDecodedWell = [];
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
    	regDecodedWell{dtI} = dcCorrect;
    	dayDiffsDecoding = dcResDays;
    end
end

FWDorREV = {'REV','FWD'};
numPlots = length(decodingResults);

for plotI = 1:numPlots
    for fwd = 1:length(FWDorREV)
        axH(plotI,fwd) = subplot(numPlots,2,plotI*2-rem(fwd,2));

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
        
        useColorsA = [0 0 1; 0.4 0.4 0.4];
        [axHand, lineOut] = PlotDecodingResults2(downsampledResults{plotI}(dayDiffsUse,:,:),dsDecodedWell{plotI}(dayDiffsUse),...
            shuffledResults{plotI}(dayDiffsShuffUse,:,:),dayDiffsDecoding(dayDiffsUse),dayDiffsShuffled(dayDiffsUse),...
            'regress',axH(plotI),useColorsA,0,'all',false,[]);
        
        useColorsB = [1 0 0; 0.4 0.4 0.4];
        [axHand, ~] = PlotDecodingResults2(decodingResults{plotI}(dayDiffsUse),regDecodedWell{plotI}(dayDiffsUse),...
            shuffledResults{plotI}(dayDiffsShuffUse,:,:),dayDiffsDecoding(dayDiffsUse),dayDiffsShuffled(dayDiffsUse),...
            'regress',axH(plotI),useColorsB,0,'all',false,[]);

        hold on
        switch FWDorREV{fwd}
            case 'FWD'
                plot(lineOut.daysPlotFWD,lineOut.plotRegFWD,'Color',useColorsA(1,:),'LineWidth',2)
            case 'REV'
                plot(lineOut.daysPlotREV,lineOut.plotRegREV,'Color',useColorsA(1,:),'LineWidth',2)
        end
        
        %Comparison of the two slopes
        %[statsOut(plotI,fwd).slopeComp.Fval,statsOut(plotI,fwd).slopeComp.dfNum,...
        % statsOut(plotI,fwd).slopeComp.dfDen,statsOut(plotI,fwd).slopeComp.pVal] =...
        %    TwoSlopeFTest(decodingResults{plotI}(dayDiffsUse), downsampledResults{plotI}(dayDiffsUse,:,:),...
        %        dayDiffs(dayDiffs>0), abs(dayDiffs(dayDiffs<0)));
            
        %[statsOut(plotI,fwd).slopeDiffZero.Fval, statsOut(plotI,fwd).slopeDiffZero.dfNum,...
        % statsOut(plotI,fwd).slopeDiffZero.dfDen, statsOut(plotI,fwd).slopeDiffZero.pVal] =...
        %    slopeDiffFromZeroFtest(decodingResults{plotI}(dayDiffsUse & regDecodedWell{plotI}),dayDiffsDecoding(dayDiffsUse & regDecodedWell{plotI}));
        %[~, ~, ~, statsOut(plotI,fwd).slope.RR, statsOut(plotI,fwd).slope.pVal, ~] =...
        %    fitLinRegSL(decodingResults{plotI}(dayDiffsUse & regDecodedWell{plotI}),dayDiffsDecoding(dayDiffsUse & regDecodedWell{plotI}));
    
        [allDS, allDSwell] = LinearizeCell(downsampledResults{plotI}(dayDiffsUse,:,:),dsDecodedWell{plotI}(dayDiffsUse));
        %Ranksum
        [statsOut(plotI,fwd).rankSumAll.pVal, statsOut(plotI,fwd).rankSumAll.hVal] = ...
            ranksum(decodingResults{plotI}(dayDiffsUse),allDS);

        cellDSdds = mat2cell(dayDiffsDownsampled,ones(length(dayDiffsDownsampled),1),1);
        dsWellDDs = cellfun(@(x,y) x*ones(1,length(y)),cellDSdds,dsDecodedWell{plotI},'UniformOutput',false);
        dsUseDDs = [dsWellDDs{dayDiffsUse}];
        %Ranksum each day
        [statsOut(plotI,fwd).ranksums.pVal, statsOut(plotI,fwd).ranksums.hVal,...
         statsOut(plotI,fwd).ranksums.whichWon, statsOut(plotI,fwd).ranksums.eachDayPair] =...
            RankSumAllDaypairsX(decodingResults{plotI}(dayDiffsUse),...
                allDS,dayDiffsDecoding(dayDiffsUse),dsUseDDs);
    
        title([FWDorREV{fwd} ' time ' titles{plotI} ' vs shuffled'])
        xlim(xlimHere)
        ylim([0 1.05])
        xlabel('Days Apart'); 
        ylabel('Pct. Decoded Correct')
    end    
end


end