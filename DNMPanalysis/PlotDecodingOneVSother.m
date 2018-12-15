function [axH, statsOut] = PlotDecodingOneVSother(decodingResults,shuffledResults,decodedWell,dayDiffs,titles)
figure;
axH(1) = subplot(3,2,1:2);
[axH(1), statsOut{1}] = PlotDecodingResults(decodingResults{1},decodedWell{1},shuffledResults{1},dayDiffs,'mean',axH(1),[ ]);
title(titles{1})

axH(2) = subplot(3,2,3:4);
[axH(2), statsOut{2}] = PlotDecodingResults(decodingResults{2},decodedWell{2},shuffledResults{2},dayDiffs,'mean',axH(2),[ ]);
title(titles{2})

axH(3) = subplot(3,2,5);
[axH(3), statsOut{3}{1}] = PlotDecodingResults(decodingResults{1}(dayDiffs>-1),decodedWell{1}(dayDiffs>-1),...
    shuffledResults{1}(dayDiffs>-1),dayDiffs(dayDiffs>-1),'mean',axH(3),[ ]);useColors
[axH(3), statsOut{3}{2}] = PlotDecodingResults(decodingResults{2}(dayDiffs>-1),decodedWell{2}(dayDiffs>-1),...
    shuffledResults{2}(dayDiffs>-1),dayDiffs(dayDiffs>-1),'mean',axH(3),[ ]);useColors2
title(['FWD time ' titles{1} ' vs ' titles{2}])

axH(4) = subplot(3,2,6);
[axH(4), statsOut{4}{1}] = PlotDecodingResults(decodingResults{1}(dayDiffs<1),decodedWell{1}(dayDiffs<1),...
    shuffledResults{1}(dayDiffs<1),abs(dayDiffs(dayDiffs<1)),'mean',axH(4),[ ]);useColors
[axH(4), statsOut{4}{2}] = PlotDecodingResults(decodingResults{2}(dayDiffs<1),decodedWell{2}(dayDiffs<1),...
    shuffledResults{2}(dayDiffs<1),abs(dayDiffs(dayDiffs<1)),'mean',axH(4),[ ]);useColors2
title(['REV time' titles{1} ' vs ' titles{2}])       



%Stats
    %Indiv. day sign test
    [statsOut.signTest.pVal,statsOut.signTest.hVal,statsOut.signTest.stats] =...
        signtest(decodingResultsPooled{dtI}{1},decodingResultsPooled{dtI}{2});
    %Ranksum all day pairs
    [dimsDayComppVal{dtI},dimsDayComphVal{dtI},dimsDayCompwhichWon{dtI},dimsDayCompeachDayPair{dtI}] =...
        RankSumAllDaypairs(decodingResultsPooled{dtI}{1},decodingResultsPooled{dtI}{2},sessDayDiffs{dtI}{1});
    %Each dayDiff more out of shuffled?
    eachDayDiff = unique(sessDayDiffs{dtI}{1});
    for dayDiffI = 1:length(eachDayDiff)
        diffOut(dayDiffI,1) = sum(decodedWellPooled{dtI}{1}(sessDayDiffs{dtI}{1}==eachDayDiff(dayDiffI))) - ...
            sum(decodedWellPooled{dtI}{2}(sessDayDiffs{dtI}{2}==eachDayDiff(dayDiffI)));
    end

    twoslopetest