function [singleCellCorrsRho, singleCellCorrsP] = singleNeuronCorrelations(rateMaps,dayPairs,binsInclude)

numCells = size(rateMaps,1);
numDays = size(rateMaps,2);
numConds = size(rateMaps,3);

numDayPairs = size(dayPairs,1);

% Revise corrs to bins needed
% binsInclude is a cell, each cell for a cond
if ~isempty(binsInclude)
    %binsInclude = true(size(rateMaps{1}));
    %binsInclude = repmat(binsInclude,1,1,numConds);
    for condI = 1:numConds
        binsH = binsInclude{condI};
        rateMaps(:,:,condI) = cellfun(@(x) x(binsH),rateMaps(:,:,condI),'UniformOutput',false);
    end
end

for condI = 1:numConds
    for dpI = 1:numDayPairs
        %cellsUse = cellsInclude(:,dayPairs(dpI,1),cpI) & cellsInclude{mouseI}(:,sessPairs(spI,2),cpI);

        [singleCellCorrsRho{condI}{dpI}, singleCellCorrsP{condI}{dpI}]= cellfun(@(x,y) corr(x(:),y(:),'type','Spearman'),...
                rateMaps(:,dayPairs(dpI,1),condI),rateMaps(:,dayPairs(dpI,2),condI));
    end
end



end