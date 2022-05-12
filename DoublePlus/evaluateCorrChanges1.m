function [corrDiffs, corrsAllAB, cellPairsOverDays] = evaluateCorrChanges1(cellPairsUsed,traitLogical, dayPairsHere,varargin)

% Set each cell of varargin as a different set of corrs to compare
nDataStreams = numel(varargin);
dataComps = GetAllCombs(1:nDataStreams,1:nDataStreams);

nCells = size(traitLogical,1);
nDays = size(traitLogical,2);

nDayPairs = size(dayPairsHere,1);

for dpH = 1:size(dayPairsHere,1)
    
    sessA = dayPairsHere(dpH,1);
    sessB = dayPairsHere(dpH,2);    
            
    cellsUseHereA = traitLogical(:,sessA);
    cellPairsUseA = cellsUseHereA(:) & cellsUseHereA(:)'; % To index into our big corr matrix
    cellsUseHereB = traitLogical(:,sessB);
    cellPairsUseB = cellsUseHereB(:) & cellsUseHereB(:)'; % To index into our big corr matrix
    
    cellsBothDays = traitLogical(:,sessA) & traitLogical(:,sessB); 
    cellPairsUseAB = cellsBothDays(:) & cellsBothDays(:)';
    cellPairsUseABupper = logical(cellPairsUseAB .* triu(true(nCells),1));
    
    cellPairsOverDays{dpH} = ind2sub([nCells, nCells],find(cellPairsUseABupper)); 
    for dsI = 1:nDataStreams
        [crossCorrMatA{dsI}] = MatrixFromInds(nCells,varargin{dsI}{sessA},cellPairsUsed{sessA},0);
        [crossCorrMatB{dsI}] = MatrixFromInds(nCells,varargin{dsI}{sessB},cellPairsUsed{sessB},0);
        
        corrDiffsH = crossCorrMatB{dsI} - crossCorrMatA{dsI};
        corrDiffs{dsI}{dpH,1} = corrDiffsH(cellPairsUseABupper);
        corrsAllAB{dsI}{dpH,1} = [crossCorrMatA{dsI}(cellPairsUseABupper), crossCorrMatB{dsI}(cellPairsUseABupper)];
    end
end

end
    