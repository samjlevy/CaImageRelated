function [axH, statsOut] = PlotDecodingOneVSother2(decodingResults,shuffledResults,decodedWell,dayDiffsDecoding,dayDiffsShuffled,titles,fiHand)

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

axH(1) = subplot(2,2,1:2);

dayDiffsUse = dayDiffsDecoding>0;
dayDiffsShuffUse = dayDiffsShuffled>0;
shuffDayDiffs = repmat(dayDiffsShuffled(dayDiffsShuffUse),numShuffles,1);

useColors = [1 0 0; 0.4 0.4 0.4];
shuffResUse = shuffledResults{1}(dayDiffsShuffUse,:,:); shuffResUse = shuffResUse(:);
[axH(1), ~] = PlotDecodingResults(decodingResults{1}(dayDiffsUse),decodedWell{1}(dayDiffsUse),...
    shuffResUse,dayDiffsDecoding(dayDiffsUse),shuffDayDiffs,'regress',axH(1),useColors,-0.15);

useColors = [0 0 1; 0.4 0.4 0.4];
shuffResUse = shuffledResults{2}(dayDiffsShuffUse,:,:); shuffResUse = shuffResUse(:);
[axH(1), ~] = PlotDecodingResults(decodingResults{2}(dayDiffsUse),decodedWell{2}(dayDiffsUse),...
    shuffResUse,dayDiffsDecoding(dayDiffsUse),shuffDayDiffs,'regress',axH(1),useColors,0.15);

title(['FWD time ' titles{1} ' vs ' titles{2}])
xlim([0 max(dayDiffsDecoding)+0.5])
ylim([0 1.05])
xlabel('Days Apart'); ylabel('Pct. Decoded Correct')

statsOut{1}

[statsOut.fwdSlope.Fval,statsOut.fwdSlope.dfNum,statsOut.fwdSlope.dfDen,statsOut.fwdSlope.pVal] =...
    slopeDiffFromZeroFtest(decodingResults(dayDiffs>-1),dayDiffs(dayDiffs>-1));
[~, ~, ~, statsOut.arm.slopeRR(tgI), statsOut.arm.slopePval(tgI), ~] =...
        fitLinRegSL(pooledTraitChangesARM{tgI}, pooledDaysApartARM);
    %Slopes different from each other?
    [statsOut.slopeDiffComp(compI).Fval,statsOut.slopeDiffComp(compI).dfNum,...
     statsOut.slopeDiffComp(compI).dfDen,statsOut.slopeDiffComp(compI).pVal] =...
        TwoSlopeFTest(pooledTraitChanges{comps(compI,1)},pooledTraitChanges{comps(compI,2)},...
                      pooledDaysApart,pooledDaysApart);
                  
    %Sign test each day
    [statsOut.signtests(compI).pVal,statsOut.signtests(compI).hVal,...
     statsOut.signtests(compI).whichWon,statsOut.signtests(compI).eachDayPair] =...
        SignTestAllDayPairs(pooledTraitChanges{comps(compI,1)},...
        pooledTraitChanges{comps(compI,2)},pooledDaysApart);

    
    
    
axH(2) = subplot(2,2,3:4);

dayDiffsUse = dayDiffsDecoding<0;
dayDiffsShuffUse = dayDiffsShuffled<0;
shuffDayDiffs = repmat(dayDiffsShuffled(dayDiffsShuffUse),numShuffles,1);

useColors = [1 0 0; 0.4 0.4 0.4];
shuffResUse = shuffledResults{1}(dayDiffsShuffUse,:,:); shuffResUse = shuffResUse(:);
[axH(2), statsOut{2}{1}] = PlotDecodingResults(decodingResults{1}(dayDiffsUse),decodedWell{1}(dayDiffsUse),...
    shuffResUse,dayDiffsDecoding(dayDiffsUse),shuffDayDiffs,'regress',axH(2),useColors,-0.15);

useColors = [0 0 1; 0.4 0.4 0.4];
shuffResUse = shuffledResults{2}(dayDiffsShuffUse,:,:); shuffResUse = shuffResUse(:);
[axH(2), statsOut{2}{2}] = PlotDecodingResults(decodingResults{2}(dayDiffsUse),decodedWell{2}(dayDiffsUse),...
    shuffResUse,dayDiffsDecoding(dayDiffsUse),shuffDayDiffs,'regress',axH(2),useColors,0.15);

title(['REV time ' titles{1} ' vs ' titles{2}])       
xlim([min(dayDiffsDecoding)-0.5 0])
ylim([0 1.05])
xlabel('Days Apart'); ylabel('Pct. Decoded Correct')

%{
%Stats
%Indiv. day sign test
[statsOut{5}.signTest.pVal,statsOut{5}.signTest.hVal,statsOut{5}.signTest.stats] =...
    signtest(decodingResults{1},decodingResults{2});
   
%Ranksum all day pairs
[statsOut{5}.RSallDaypairs.pVal,statsOut{5}.RSallDaypairs.hVal,statsOut{5}.RSallDaypairs.whichWon,statsOut{5}.RSallDaypairs.dayPairs] =...
    RankSumAllDaypairs(decodingResults{1},decodingResults{2},dayDiffsDecoding);
    
%Each dayDiff more out of shuffled?
eachDayDiff = unique(dayDiffsDecoding);
for dayDiffI = 1:length(eachDayDiff)
    statsOut{5}.diffOut(dayDiffI,1) = sum(decodedWell{1}(dayDiffsDecoding==eachDayDiff(dayDiffI))) - ...
            sum(decodedWell{2}(dayDiffsDecoding==eachDayDiff(dayDiffI)));
end
[statsOut{5}.diffOutSignTest.pVal,statsOut{5}.diffOutSignTest.hVal] = signtest(statsOut{5}.diffOut);
[~,statsOut{5}.diffOutSignTest.whichWon] = max([sum(decodedWell{1}) sum(decodedWell{2})]);

%Compare slopes FWD and REV
[statsOut{5}.TwoSlopeFWD.Fval,statsOut{5}.TwoSlopeFWD.dfNum,statsOut{5}.TwoSlopeFWD.dfDen,statsOut{5}.TwoSlopeFWD.pVal] =...
    TwoSlopeFTest(decodingResults{1}(dayDiffsDecoding>-1), decodingResults{2}(dayDiffsDecoding>-1),...
                                     dayDiffsDecoding(dayDiffsDecoding>-1), dayDiffsDecoding(dayDiffsDecoding>-1));
[statsOut{5}.TwoSlopeREV.Fval,statsOut{5}.TwoSlopeREV.dfNum,statsOut{5}.TwoSlopeREV.dfDen,statsOut{5}.TwoSlopeREV.pVal] =...
    TwoSlopeFTest(decodingResults{1}(dayDiffsDecoding<1), decodingResults{2}(dayDiffsDecoding<1),...
                                     dayDiffsDecoding(dayDiffsDecoding<1), dayDiffsDecoding(dayDiffsDecoding<1));
%}
end