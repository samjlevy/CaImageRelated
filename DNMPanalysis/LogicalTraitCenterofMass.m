function [splitterCOM, splitterDayBias] = LogicalTraitCenterofMass(splittersLogical, dayUse)
%Day bias output: [early bias, no bias didn't split all days, late bias, split all days]
%Generalized version that describes where the center of mass of a cell
%satisfying Logical thing in order to say what proportion of cells stop
%doing this or start doing this over days of recording

numCells = size(dayUse,1);
daysEachCellActive = sum(dayUse,2);

numDaysSplitter = nan(numCells,1); 
splitterCOM = nan(numCells,1);
neverSplit = zeros(numCells,1);

for cellI = 1:numCells
    %If the cell splits LR/ST/Both ever and is active for more than one day
    numDaysPresent = sum(dayUse(cellI,:),2);
    
    splitterDays = logical(splittersLogical(cellI,:));
    numSplitterDays = sum(splittersLogical(cellI,:),2);
    if numDaysPresent > 1
        daysPresent = logical(dayUse(cellI,:));
        dayV = 1:numDaysPresent; dayAlign = zeros(1,length(daysPresent));
        dayAlign(daysPresent) = dayV;
        daysActiveCOM = sum(dayAlign)/numDaysPresent;
        splitterWeight = dayAlign;
        splitterWeight(daysPresent) = splitterWeight(daysPresent) - daysActiveCOM;
        
        
        if numSplitterDays > 0
            numDaysSplitter(cellI) = numSplitterDays;
            splitterCOM(cellI) = sum(splitterWeight(splitterDays))/numDaysPresent; %offset from active days COM
        end
        
    end
    
    if numDaysPresent > 0
        neverSplit(cellI) = numSplitterDays==0;
    end
end

everSplit = sum(sum(splittersLogical,2)>0,1);

splitterDayBias.Raw.Early = sum(splitterCOM<0); 
splitterDayBias.Raw.Late = sum(splitterCOM>0);
splitterDayBias.Raw.NoBias = sum((splitterCOM==0).*(numDaysSplitter~=daysEachCellActive));
splitterDayBias.Raw.SplitAllDays = sum((splitterCOM==0).*(numDaysSplitter==daysEachCellActive));

splitterDayBias.Pct.Early = splitterDayBias.Raw.Early / everSplit;
splitterDayBias.Pct.Late = splitterDayBias.Raw.Late / everSplit;
splitterDayBias.Pct.NoBias = splitterDayBias.Raw.NoBias / everSplit;
splitterDayBias.Pct.SplitAllDays = splitterDayBias.Raw.SplitAllDays / everSplit;

end