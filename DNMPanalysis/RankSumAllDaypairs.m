function [pVal,hVal,whichWon,eachDayPair] = RankSumAllDaypairs(dataVecA,dataVecB,dayDiffs)
%This actually does day differences, not equipped for day pairs

%{
switch length(varargin)
    case 3
        dataVecA = varargin{1};
        dataVecB = varargin{2};
        dayPairsA = varargin{3};
        dayPairsB = varargin{3};
    case 4
        dataVecA = varargin{1};
        dataVecB = varargin{3};
        dayPairsA = varargin{2};
        dayPairsB = varargin{4};
end


%}

eachDayPair = unique(dayDiffs);

for dpI = 1:length(eachDayPair)
    datA = dataVecA(dayDiffs==eachDayPair(dpI));
    datB = dataVecB(dayDiffs==eachDayPair(dpI));
    
    %Do the stat
    [pVal(dpI),hVal(dpI)] = ranksum(datA,datB);
    
    %Return a value for plotting
    whichWon(dpI) = WhichWonRanks(datA, datB);
end

end