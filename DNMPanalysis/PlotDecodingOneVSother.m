function [axH, statsOut] = PlotDecodingOneVSother(decodingResults,shuffledResults,decodedWell,dayDiffs,titles)
figure;

axH(1) = subplot(3,2,1:2);
[axH(1), statsOut{1}] = PlotDecodingResults(decodingResults{1},decodedWell{1},shuffledResults{1},dayDiffs,'mean',axH(1),[ ]);
title(titles{1})
xlim([min(dayDiffs)-0.5 max(dayDiffs)+0.5])
xlabel('Days Apart'); ylabel('Pct. Decoded Correct')

axH(2) = subplot(3,2,3:4);
[axH(2), statsOut{2}] = PlotDecodingResults(decodingResults{2},decodedWell{2},shuffledResults{2},dayDiffs,'mean',axH(2),[ ]);
title(titles{2})
xlim([min(dayDiffs)-0.5 max(dayDiffs)+0.5])
xlabel('Days Apart'); ylabel('Pct. Decoded Correct')

axH(4) = subplot(3,2,6);
[axH(4), statsOut{4}{1}] = PlotDecodingResults(decodingResults{1}(dayDiffs>-1),decodedWell{1}(dayDiffs>-1),...
    shuffledResults{1}(dayDiffs>-1),dayDiffs(dayDiffs>-1),'regress',axH(3),[ ]);%useColors
[axH(4), statsOut{4}{2}] = PlotDecodingResults(decodingResults{2}(dayDiffs>-1),decodedWell{2}(dayDiffs>-1),...
    shuffledResults{2}(dayDiffs>-1),dayDiffs(dayDiffs>-1),'regress',axH(3),[ ]);%useColors2
title(['FWD time ' titles{1} ' vs ' titles{2}])
xlim([-0.5 max(dayDiffs)+0.5])
xlabel('Days Apart'); ylabel('Pct. Decoded Correct')

axH(3) = subplot(3,2,5);
[axH(3), statsOut{3}{1}] = PlotDecodingResults(decodingResults{1}(dayDiffs<1),decodedWell{1}(dayDiffs<1),...
    shuffledResults{1}(dayDiffs<1),dayDiffs(dayDiffs<1),'regress',axH(4),[ ]);%useColors
[axH(3), statsOut{3}{2}] = PlotDecodingResults(decodingResults{2}(dayDiffs<1),decodedWell{2}(dayDiffs<1),...
    shuffledResults{2}(dayDiffs<1),dayDiffs(dayDiffs<1),'regress',axH(4),[ ]);%useColors2
title(['REV time ' titles{1} ' vs ' titles{2}])       
xlim([min(dayDiffs)-0.5 0.5])
xlabel('Days Apart'); ylabel('Pct. Decoded Correct')

%Stats
%Indiv. day sign test
[statsOut{5}.signTest.pVal,statsOut{5}.signTest.hVal,statsOut{5}.signTest.stats] =...
    signtest(decodingResults{1},decodingResults{2});
   
%Ranksum all day pairs
[statsOut{5}.RSallDaypairs.pVal,statsOut{5}.RSallDaypairs.hVal,statsOut{5}.RSallDaypairs.whichWon,statsOut{5}.RSallDaypairs.dayPairs] =...
    RankSumAllDaypairs(decodingResults{1},decodingResults{2},dayDiffs);
    
%Each dayDiff more out of shuffled?
eachDayDiff = unique(dayDiffs);
for dayDiffI = 1:length(eachDayDiff)
    statsOut{5}.diffOut(dayDiffI,1) = sum(decodedWell{1}(dayDiffs==eachDayDiff(dayDiffI))) - ...
            sum(decodedWell{2}(dayDiffs==eachDayDiff(dayDiffI)));
end
[statsOut{5}.diffOutSignTest.pVal,statsOut{5}.diffOutSignTest.hVal] = signtest(statsOut{5}.diffOut);

%Compare slopes FWD and REV
[statsOut{5}.TwoSlopeFWD.Fval,statsOut{5}.TwoSlopeFWD.dfNum,statsOut{5}.TwoSlopeFWD.dfDen,statsOut{5}.TwoSlopeFWD.pVal] =...
    TwoSlopeFTest(decodingResults{1}(dayDiffs>-1), decodingResults{2}(dayDiffs>-1), dayDiffs(dayDiffs>-1), dayDiffs(dayDiffs>-1));
[statsOut{5}.TwoSlopeREV.Fval,statsOut{5}.TwoSlopeREV.dfNum,statsOut{5}.TwoSlopeREV.dfDen,statsOut{5}.TwoSlopeREV.pVal] =...
    TwoSlopeFTest(decodingResults{1}(dayDiffs<1), decodingResults{2}(dayDiffs<1), dayDiffs(dayDiffs<1), dayDiffs(dayDiffs<1));

end