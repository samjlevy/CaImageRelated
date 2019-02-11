function [groupout] = RunGroupFunction(funcName,traitGroup,dayUse,varargin)

for ngI = 1:length(traitGroup)
    switch funcName
        case 'NNplusKChange'
            [groupout(ngI).numChange, groupout(ngI).pctChange, groupout(ngI).dayPairs] =...
                NNplusKChange(traitGroup{ngI}, dayUse);
        case 'TraitDailyPct'
            groupout{ngI} = TraitDailyPct(traitGroup{ngI},dayUse);
        case 'GetCellsOverlap'
            %varargin 1 is dayPairs
            if iscell(dayUse) && length(dayUse)==length(traitGroup)
                [groupout(ngI).activeCellsOverlap, groupout(ngI).overlapWithModel, groupout(ngI).overlapWithTest] =...
                    GetCellsOverlap(traitGroup{ngI}, dayUse{ngI},varargin{1});
            else
                [groupout(ngI).activeCellsOverlap, groupout(ngI).overlapWithModel, groupout(ngI).overlapWithTest] =...
                    GetCellsOverlap(traitGroup{ngI}, dayUse,varargin{1});
            end
        case 'GetFirstDayTrait'
            [groupout(ngI).firstDay] = GetFirstDayTrait(traitGroup{ngI});
        case 'LogicalTraitCenterofMass'
            [groupout(ngI).dayCOM,groupout(ngI).dayBias] = LogicalTraitCenterofMass(traitGroup{ngI},dayUse);
        otherwise
            disp('not a recognized option')
    end
end


end