function [axHand,statsOut] = PlotDecodingFWDvsREVwrapper(decodingResults,decodedRight,dayDiffs,axHand)

[axHand, ~] = PlotDecodingResults(decodingResults(dayDiffs>0),decodedRight(dayDiffs>0),...
    [],dayDiffs(dayDiffs>0),[],'mean',axHand,[0 1 0; 0.4706    0.6706    0.1882],-0.25);
%(decodingResults,decodedWell,...
%    shuffledResults,dayDiffsDecoding,dayDiffsShuffled,fitType,axHand,useColors)

[axHand, ~] = PlotDecodingResults(decodingResults(dayDiffs<0),decodedRight(dayDiffs<0),...
    [],abs(dayDiffs(dayDiffs<0)),[],'mean',axHand,[1 0 0;0.6392    0.0784    0.1804],0.25);

xlim([0.5 max(dayDiffs(dayDiffs>0))+0.5])
ylabel('Decoding Performance')
xlabel('Day Lag')

%Comparison of the two slopes
[statsOut.slopeComp.Fval,statsOut.slopeComp.dfNum,statsOut.slopeComp.dfDen,statsOut.slopeComp.pVal] =...
    TwoSlopeFTest(decodingResults(dayDiffs>0), decodingResults(dayDiffs<0),...
            dayDiffs(dayDiffs>0), abs(dayDiffs(dayDiffs<0)));
        
[statsOut.rankSumAll.pVal,statsOut.rankSumAll.hVal] = ranksum(decodingResults(dayDiffs>0), decodingResults(dayDiffs<0));
statsOut.rankSumAll.whichWon = WhichWonRanks(decodingResults(dayDiffs>0), decodingResults(dayDiffs<0));

%{
[statsOut.ranksums.pVal, statsOut.ranksums.hVal,...
     statsOut.ranksums.whichWon, statsOut.ranksums.eachDayPair] =...
        RankSumAllDaypairs(decodingResults(dayDiffs>0),decodingResults(dayDiffs<0)
%}

%Is each slope different from zero
[statsOut.fwdSlope.Fval,statsOut.fwdSlope.dfNum,statsOut.fwdSlope.dfDen,statsOut.fwdSlope.pVal] =...
    slopeDiffFromZeroFtest(decodingResults(dayDiffs>0),dayDiffs(dayDiffs>0));
[statsOut.revSlope.Fval,statsOut.revSlope.dfNum,statsOut.revSlope.dfDen,statsOut.revSlope.pVal] =...
    slopeDiffFromZeroFtest(decodingResults(dayDiffs<0),dayDiffs(dayDiffs<0));

end