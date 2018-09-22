function [groupout] = RunGroupFunction(funcName,traitGroup,dayUse,varargin)

for ngI = 1:length(traitGroup)
    switch funcName
        case 'NNplusKChange'
            [groupout(ngI).numChange, groupout(ngI).pctChange, groupout(ngI).dayPairs] =...
                NNplusKChange(traitGroup{ngI}, dayUse);
        case 'TraitDailyPct'
            groupout{ngI} = TraitDailyPct(traitGroup{ngI},dayUse);
        %case 'slopeRankWrapper'
        %    days = varargin{1}; 
        %    numPerms = varargin{2};
        %    [groupout(ngI).slopeRank, groupout(ngI).RsquaredRank] = slopeRankWrapper(dataVec, days, numPerms);
        otherwise
            disp('not a recognized option')
    end
end


end