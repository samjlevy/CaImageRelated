function [splitterLR, splitterST, splitterBOTH] = SplitterCenterOfMass(dayUse, splittersLR, splittersST, splittersBoth)
%Day bias output: [early bias, no bias didn't split all days, late bias, split all days]
numCells = size(dayUse,1);
daysEachCellActive = sum(dayUse,2);

numDaysSplitterLR = nan(numCells,1); splitterLR.COM = nan(numCells,1);
numDaysSplitterST = nan(numCells,1); splitterST.COM = nan(numCells,1);
numDaysSplitterBOTH = nan(numCells,1); splitterBOTH.COM = nan(numCells,1);
for cellI = 1:numCells
    %If the cell splits LR/ST/Both ever and is active for more than one day
    numDaysPresent = sum(dayUse(cellI,:),2);
    if numDaysPresent > 1
        daysPresent = dayUse(cellI,:);
        dayV = 1:numDaysPresent; dayAlign = zeros(1,length(daysPresent));
        dayAlign(daysPresent) = dayV;
        daysActiveCOM = sum(dayAlign)/numDaysPresent;
        splitterWeight = dayAlign;
        splitterWeight(daysPresent) = splitterWeight(daysPresent) - daysActiveCOM;
        
        LRsplitterDays = splittersLR(cellI,:);
        numLRsplitterDays = sum(splittersLR(cellI,:),2);
        if numLRsplitterDays > 0
            numDaysSplitterLR(cellI) = numLRsplitterDays;
            splitterLR.COM(cellI) = sum(splitterWeight(LRsplitterDays))/numDaysPresent; %offset from active days COM
        end
        
        STsplitterDays = splittersST(cellI,:);
        numSTsplitterDays = sum(STsplitterDays,2);
        if numSTsplitterDays > 0
            numDaysSplitterST(cellI) = numSTsplitterDays;
            splitterST.COM(cellI) = sum(splitterWeight(STsplitterDays))/numDaysPresent; %offset from active days COM
        end
        
        BOTHsplitterDays = splittersBoth(cellI,:);
        numBothsplitterDays = sum(splittersBoth(cellI,:),2);
        if numLRsplitterDays > 0
            numDaysSplitterBOTH(cellI) = numBothsplitterDays;
            splitterBOTH.COM(cellI) = sum(splitterWeight(BOTHsplitterDays))/numDaysPresent; %offset from active days COM
        end
    end
end

% Only includes cells that show up more than 1 day and split at least 1 day; won't equal some number of splitters or active cells
% early bias, no bias didn't split all days, late bias, split all days
splitterLR.dayBias(1,[1 3]) = [sum(splitterLR.COM<0) sum(splitterLR.COM>0)];
splitterLR.dayBias(1, 2) = sum((splitterLR.COM==0).*(numDaysSplitterLR~=daysEachCellActive));
splitterLR.dayBias(1, 4) = sum((splitterLR.COM==0).*(numDaysSplitterLR==daysEachCellActive));
splitterST.dayBias(1,[1 3]) = [sum(splitterST.COM<0) sum(splitterST.COM>0)];
splitterST.dayBias(1, 2) = sum((splitterST.COM==0).*(numDaysSplitterST~=daysEachCellActive));
splitterST.dayBias(1, 4) = sum((splitterST.COM==0).*(numDaysSplitterST==daysEachCellActive));
splitterBOTH.dayBias(1,[1 3]) = [sum(splitterBOTH.COM<0) sum(splitterBOTH.COM>0)];
splitterBOTH.dayBias(1, 2) = sum((splitterBOTH.COM==0).*(numDaysSplitterBOTH~=daysEachCellActive));
splitterBOTH.dayBias(1, 4) = sum((splitterBOTH.COM==0).*(numDaysSplitterBOTH==daysEachCellActive));
        
end