function [axH, statsOut] = PlotDecodingByThresh(decodingResults,shuffledResults,decodedWell,decodeWhich,dayDiffs,dtComps,titles)
%This one needs the whole decodeResultsPooled, then tell it LR/ST with
%decode which
%This whole function probably unnecessary, just pass a slightly altered
%input to OneVSother
dtComps = [1 2]; %In theory use this to tell it which to work with, right now only 2

numDTs = length(decodingResults);

figure;

axH(1) = subplot(3,2,1:2);
[axH(1), statsOut{1}] = PlotDecodingResults(decodingResults{1}{decodeWhich},decodedWell{1}{decodeWhich},...
    shuffledResults{1}{decodeWhich},dayDiffs,'mean',axH(1),[ ]);
title(titles{1})
xlim([min(dayDiffs)-0.5 max(dayDiffs)+0.5])
xlabel('Days Apart'); ylabel('Pct. Decoded Correct')

axH(2) = subplot(3,2,3:4);
[axH(2), statsOut{2}] = PlotDecodingResults(decodingResults{2}{decodeWhich},decodedWell{2}{decodeWhich},...
    shuffledResults{1}{decodeWhich},dayDiffs,'mean',axH(2),[ ]);
title(titles{2})
xlim([min(dayDiffs)-0.5 max(dayDiffs)+0.5])
xlabel('Days Apart'); ylabel('Pct. Decoded Correct')


axH(3) = subplot(3,2,5);
[axH(3), statsOut{3}{1}] = PlotDecodingResults(decodingResults{1}{decodeWhich}(dayDiffs<1),decodedWell{1}{decodeWhich}(dayDiffs<1),...
    [],dayDiffs(dayDiffs<1),'regress',axH(3),[ ]);
hold on
[axH(3), statsOut{3}{2}] = PlotDecodingResults(decodingResults{2}{decodeWhich}(dayDiffs<1),decodedWell{2}{decodeWhich}(dayDiffs<1),...
    [],dayDiffs(dayDiffs<1),'regress',axH(3),[ ]);
title([titles{1} ' vs ' titles{2} ', timeREV'])
xlim([min(dayDiffs)-0.5 0.5])
xlabel('Days Apart'); ylabel('Pct. Decoded Correct')

axH(4) = subplot(3,2,6);
[axH(4), statsOut{3}{1}] = PlotDecodingResults(decodingResults{1}{decodeWhich}(dayDiffs>-1),decodedWell{1}{decodeWhich}(dayDiffs>-1),...
    [],dayDiffs(dayDiffs>-1),'regress',axH(4),[ ]);
hold on
[axH(4), statsOut{3}{2}] = PlotDecodingResults(decodingResults{2}{decodeWhich}(dayDiffs>-1),decodedWell{2}{decodeWhich}(dayDiffs>-1),...
    [],dayDiffs(dayDiffs>-1),'regress',axH(4),[ ]);
title([titles{1} ' vs ' titles{2} ', timeFWD'])
xlim([-0.5 max(dayDiffs)+0.5])
xlabel('Days Apart'); ylabel('Pct. Decoded Correct')

%Stats
%Indiv. day sign test
[statsOut{5}.signTest.pVal,statsOut{5}.signTest.hVal,statsOut{5}.signTest.stats] =...
    signtest(decodingResults{1}{decodeWhich},decodingResults{2}{decodeWhich});
   
%Ranksum all day pairs
[statsOut{5}.RSallDaypairs.pVal,statsOut{5}.RSallDaypairs.hVal,statsOut{5}.RSallDaypairs.whichWon,statsOut{5}.RSallDaypairs.dayPairs] =...
    RankSumAllDaypairs(decodingResults{1}{decodeWhich},decodingResults{2}{decodeWhich},dayDiffs);
    
%Each dayDiff more out of shuffled?
eachDayDiff = unique(dayDiffs);
for dayDiffI = 1:length(eachDayDiff)
    statsOut{5}.diffOut(dayDiffI,1) = sum(decodedWell{1}{decodeWhich}(dayDiffs==eachDayDiff(dayDiffI))) - ...
            sum(decodedWell{2}{decodeWhich}(dayDiffs==eachDayDiff(dayDiffI)));
end
[statsOut{5}.diffOutSignTest.pVal,statsOut{5}.diffOutSignTest.hVal] = signtest(statsOut{5}.diffOut);

%Compare slopes FWD and REV
[statsOut{5}.TwoSlopeFWD.Fval,statsOut{5}.TwoSlopeFWD.dfNum,statsOut{5}.TwoSlopeFWD.dfDen,statsOut{5}.TwoSlopeFWD.pVal] =...
    TwoSlopeFTest(decodingResults{1}{decodeWhich}(dayDiffs>-1), decodingResults{2}{decodeWhich}(dayDiffs>-1), dayDiffs(dayDiffs>-1), dayDiffs(dayDiffs>-1));
[statsOut{5}.TwoSlopeREV.Fval,statsOut{5}.TwoSlopeREV.dfNum,statsOut{5}.TwoSlopeREV.dfDen,statsOut{5}.TwoSlopeREV.pVal] =...
    TwoSlopeFTest(decodingResults{1}{decodeWhich}(dayDiffs<1), decodingResults{2}{decodeWhich}(dayDiffs<1), dayDiffs(dayDiffs<1), dayDiffs(dayDiffs<1));
