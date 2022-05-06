function [pctStillCorr, pctStillUncorr, pctBecomeUncorr, pctBecomeCorr, numPairsStillCorr, numPairsBecomeUncorr,...
    numPairsBecomeCorr, numPairsStillUncorr, cellPairsByDayPair,numCellPairsByDayPair,...
    sessCorrs, NcorrEdges, PctCorrEdges, NconnComps, pctComps, compPctSizes, pctCellsInComp ] =...
    evaluateCorrelatedPairs1(corrs, cellPairsUsed, dayPairsHere, traitLogical, edgeThreshes) 
% corrs is a cell array, with each cell a day, that has the correlation
% from each pair of cell activities tested
% cell pairs used is same organization, but has doubles with integer
% numbers nCorrs x 2 of the cell pairs in each correlation
% dayPairs is a nPairs x 2 double to index into these sessions to test
% pairs of days
% traitLogical is a nCells x nDays
% edgeThreshes is a 1D array of the thresholds to test correlations above
numCells = size(traitLogical,1);
nDays = size(traitLogical,2);
nEdgeThreshes = numel(edgeThreshes);

corrsBlank = zeros(numCells);
    
for dpH = 1:size(dayPairsHere,1)
    
    sessA = dayPairsHere(dpH,1);
    [cellPairsInds] = sub2ind([1 1]*numCells,cellPairsUsed{sessA}(:,1),cellPairsUsed{sessA}(:,2));
    [cellPairsIndss] = sub2ind([1 1]*numCells,cellPairsUsed{sessA}(:,2),cellPairsUsed{sessA}(:,1));
    crossCorrMatA = corrsBlank;
    crossCorrMatA(cellPairsInds) = corrs{sessA};
    crossCorrMatA(cellPairsIndss) = corrs{sessA};
    
    sessB = dayPairsHere(dpH,2);
    [cellPairsInds] = sub2ind([1 1]*numCells,cellPairsUsed{sessB}(:,1),cellPairsUsed{sessB}(:,2));
    [cellPairsIndss] = sub2ind([1 1]*numCells,cellPairsUsed{sessB}(:,2),cellPairsUsed{sessB}(:,1));
    crossCorrMatB = corrsBlank;
    crossCorrMatB(cellPairsInds) = corrs{sessB};
    crossCorrMatB(cellPairsIndss) = corrs{sessB};
            
    cellsUseHereA = traitLogical(:,sessA);
    cellPairsUseA = cellsUseHereA(:) & cellsUseHereA(:)'; % To index into our big corr matrix
    cellsUseHereB = traitLogical(:,sessB);
    cellPairsUseB = cellsUseHereB(:) & cellsUseHereB(:)'; % To index into our big corr matrix
    
    cellsBothDays = traitLogical(:,sessA) & traitLogical(:,sessB); 
    cellPairsUseAB = cellsBothDays(:) & cellsBothDays(:)';
    cellPairsUseABupper = logical(cellPairsUseAB .* triu(true(numCells),1));
    numCellPairsAB = sum(sum(cellPairsUseABupper));
    
    cellPairsByDayPair{dpH} = cellPairsUseABupper;
    numCellPairsByDayPair(dpH) = sum(sum(cellPairsUseABupper));
        
    % Did pairs of cells change their status of being above corr threshold
    for edgeI = 1:nEdgeThreshes
        edgeThresh = edgeThreshes(edgeI);
        corrEdgesA = crossCorrMatA > edgeThresh;
        corrEdgesB = crossCorrMatB > edgeThresh;
        
        pairsEverCorrelated = corrEdgesA | corrEdgesB;
        pairsStillCorrelated = corrEdgesA & corrEdgesB;
        pairsBecomeUncorr = corrEdgesA & ~corrEdgesB;
        pairsBecomeCorr = ~corrEdgesA & corrEdgesB;
        pairsStillUncorrelated = ~corrEdgesA & ~corrEdgesB;
        
        pairsEverCorrelated = pairsEverCorrelated.*cellPairsUseABupper;
        pairsStillCorrelated = pairsStillCorrelated.*cellPairsUseABupper;
        pairsBecomeUncorr = pairsBecomeUncorr.*cellPairsUseABupper;
        pairsBecomeCorr = pairsBecomeCorr.*cellPairsUseABupper;
        pairsStillUncorrelated = pairsStillUncorrelated.*cellPairsUseABupper;
        
        if sum(sum(cellPairsUseABupper)) ~= ...
                sum(sum(pairsStillCorrelated)) + sum(sum(pairsBecomeUncorr)) + sum(sum(pairsBecomeCorr)) + sum(sum(pairsStillUncorrelated))
            disp('cell pairs indexing error')
            keyboard
        end
        
        numPairsStillCorr = sum(sum(pairsStillCorrelated));
        numPairsBecomeUncorr = sum(sum(pairsBecomeUncorr));
        numPairsBecomeCorr = sum(sum(pairsBecomeCorr));
        numPairsStillUncorr = sum(sum(pairsStillUncorrelated));
        
        numCellPairsEverCorr = sum(sum(pairsEverCorrelated)); % Something still a bit wrong here... ?
        denomH = sum(sum(cellPairsUseABupper));
        %denomH = numCellPairsEverCorr;
        pctStillCorr(dpH,edgeI) = numPairsStillCorr / denomH;
        pctStillUncorr(dpH,edgeI) = numPairsStillUncorr / denomH;
        pctBecomeUncorr(dpH,edgeI) = numPairsBecomeUncorr / denomH;
        pctBecomeCorr(dpH,edgeI) = numPairsBecomeCorr / denomH;
        
                % Should we also evaluate graph/cluster/ensembles?
        % Could just evaluate connected comp sizes using only cells from this day pair
        
        % In graph for sessA
        % In graph for sessB
        % in Graph for both
        
        %{
        G = graph(corrEdges);
            [graphBins,graphBinSizes] = conncomp(G);
            compsOverOne = graphBinSizes > 1; % Connected components with more than 1 member
            nConnComps = sum(graphBinSizes > 1);
            connCompSizes = graphBinSizes(compsOverOne); % Sizes of connected components greater than 1
            
            theseBinSizes = graphBinSizes(graphBins); % The size of the bin this cell is part of
                
            NcorrEdges{sessI}{edgeI} = nCorrEdges(cellsUseHere);
            PctCorrEdges{sessI}{edgeI} = pctCorrEdges(cellsUseHere);
            NconnComps{sessI}{edgeI} = nConnComps;
            % number of comps as pct of cells here
            pctComps{sessI}{edgeI} = nConnComps/sum(cellsUseHere);
            % Sizes of connComps as pct of cells here
            compPctSizes{sessI}{edgeI} = connCompSizes(:)/sum(cellsUseHere); %As pct of cells here
            % percent of active cells in a comp
            pctCellsInComp{sessI}{edgeI} = sum(theseBinSizes > 1) / sum(cellsUseHere);
        %}
    end
end

% Distribution of corrs, edges at each edge threshold
for sessI = 1:nDays %sessJ = 1:numel(daysHere)
    if any(corrs{sessI})
        crossCorrMat = corrsBlank;
        [cellPairsInds] = sub2ind([1 1]*numCells,cellPairsUsed{sessI}(:,1),cellPairsUsed{sessI}(:,2));
        [cellPairsIndss] = sub2ind([1 1]*numCells,cellPairsUsed{sessI}(:,2),cellPairsUsed{sessI}(:,1));
        crossCorrMat(cellPairsInds) = corrs{sessI};
        crossCorrMat(cellPairsIndss) = corrs{sessI};
            
        cellsUseHere = traitLogical(:,sessI);
        cellPairsUse = cellsUseHere(:) & cellsUseHere(:)'; % To index into our big corr matrix
            
        corrsHere = crossCorrMat(cellPairsUse);
            
        sessCorrs{sessI} = corrsHere;
            
        % Threshold the correlation matrix as a "significant" correlation
        for edgeI = 1:nEdgeThreshes
            edgeThresh = edgeThreshes(edgeI);
            corrEdges = crossCorrMat > edgeThresh;
            nCorrEdges = sum(corrEdges,2);
            pctCorrEdges = nCorrEdges / sum(cellsUseHere);
                
            G = graph(corrEdges);
            [graphBins,graphBinSizes] = conncomp(G);
            compsOverOne = graphBinSizes > 1; % Connected components with more than 1 member
            nConnComps = sum(graphBinSizes > 1);
            connCompSizes = graphBinSizes(compsOverOne); % Sizes of connected components greater than 1
            
            theseBinSizes = graphBinSizes(graphBins); % The size of the bin this cell is part of
                
            NcorrEdges{sessI,edgeI} = nCorrEdges(cellsUseHere);
            PctCorrEdges{sessI,edgeI} = pctCorrEdges(cellsUseHere);
            NconnComps(sessI,edgeI) = nConnComps;
            % number of comps as pct of cells here
            pctComps(sessI,edgeI) = nConnComps/sum(cellsUseHere);
            % Sizes of connComps as pct of cells here
            compPctSizes{sessI,edgeI} = connCompSizes(:)/sum(cellsUseHere); %As pct of cells here
            % percent of active cells in a comp
            pctCellsInComp(sessI,edgeI) = sum(theseBinSizes > 1) / sum(cellsUseHere);
                        
        end
            
    end
end
    