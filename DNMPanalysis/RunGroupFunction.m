function [groupout] = RunGroupFunction(funcName,traitGroup,dayUse,varargin)

for ngI = 1:length(traitGroup)
    switch funcName
        case 'NNplusKChange'
            [groupout(ngI).numChange, groupout(ngI).pctChange, groupout(ngI).dayPairs] =...
                NNplusKChange(traitGroup{ngI}, dayUse);
        case 'TraitDailyPct'
            groupout{ngI} = TraitDailyPct(traitGroup{ngI},dayUse);
        case 'GetCellsOverlap'
            if iscell(dayUse) && length(dayUse)==length(traitGroup)
                [groupout(ngI).activeCellsOverlap, groupout(ngI).overlapWithModel, groupout(ngI).overlapWithTest] =...
                    GetCellsOverlap(traitGroup{ngI}, dayUse{ngI},varargin{1});
            else
                [groupout(ngI).activeCellsOverlap, groupout(ngI).overlapWithModel, groupout(ngI).overlapWithTest] =...
                    GetCellsOverlap(traitGroup{ngI},dayUse,varargin{1});
            end
        otherwise
            disp('not a recognized option')
    end
end


end