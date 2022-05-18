%function [singleCellCorrsRho, singleCellCorrsP] = GatherSingleCellCorrs

dayPairsH = CombinationMatcher(corrsLoaded.allDayPairs, dayPairsForward);

% Rate map correlations
singleCellCorrsRho = []; singleCellCorrsP = [];
%{
oneEnvCorrsAll = cell(numDayPairs,1); oneEnvCorrsEach = cell(numDayPairs,numConds);
twoEnvCorrsAll = cell(numDayPairs,1); twoEnvCorrsEach = cell(numDayPairs,numConds);
oneEnvCorrsPall = cell(numDayPairs,1); oneEnvCorrsPeach = cell(numDayPairs,numConds);
twoEnvCorrsPall = cell(numDayPairs,1); twoEnvCorrsPeach = cell(numDayPairs,numConds);
oneEnvCorrsPallPct = cell(numDayPairs,1); oneEnvCorrsPeachPct = cell(numDayPairs,numConds);
twoEnvCorrsPallPct = cell(numDayPairs,1); twoEnvCorrsPeachPct = cell(numDayPairs,numConds);
oneEnvCorrsSingle = cell(numDayPairs,1); oneEnvCorrsSingleP = cell(numDayPairs,1);
twoEnvCorrsSingle = cell(numDayPairs,1); twoEnvCorrsSingleP = cell(numDayPairs,1);
%}
for mouseI = 1:numMice
    
  
    switch length(condsUse)
        case 3
            disp('Assuming condsUse is [1 3 4]')
            singleCellAllCorrsRho{mouseI}{1} = corrsLoaded.singleCellThreeCorrsRho{mouseI}{1}(dayPairsH);
            singleCellAllCorrsP{mouseI}{1} = corrsLoaded.singleCellThreeCorrsP{mouseI}{1}(dayPairsH);
        case 4
            singleCellAllCorrsRho{mouseI}{1} = corrsLoaded.singleCellAllCorrsRho{mouseI}{1}(dayPairsH);
            singleCellAllCorrsP{mouseI}{1} = corrsLoaded.singleCellAllCorrsP{mouseI}{1}(dayPairsH);
        otherwise
            disp('Unaccounted for conds use')
    end
end