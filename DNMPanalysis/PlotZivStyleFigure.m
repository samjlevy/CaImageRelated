function [figHand] = PlotZivStyleFigure(pooledTMap,cellsUse,COMbinUse,normRef)
%norm ref is a numCells x 2 vector, for each cell say which day (column 1), 
%which cond (column 2) to normalize to

numConds = size(pooledTMap,3);
numDays = size(pooledTMap,2);
%cellsUse needs to be a logical
%cellsUse = find(cellsUse);
numBins = length(pooledTMap{1,1,1});
numCells = length(cellsUse);

%First normalize firing activity
rateNorm = cell(size(pooledTMap));
for cellI = 1:numCells
    %Normalizes by the max out of this inclusion criteria
    switch normRef
        case 'allCondsAllDays'
            ratesHere = [pooledTMap{cellI,:,:}];
            rateNorm(cellI,:,:) = {max(ratesHere)};
        case 'allDaysCond1'
            ratesHere = [pooledTMap{cellI,:,1}];
            rateNorm(cellI,:,:) = {max(ratesHere)};
        case 'day1cond1'
            ratesHere = [pooledTMap{cellI,1,1}];
            rateNorm(cellI,:,:) = {max(ratesHere)};
        case 'day1AllConds'
            ratesHere = [pooledTMap{cellI,1,:}];
            rateNorm(cellI,:,:) = {max(ratesHere)};
        case 'day1EachCond'
            for condI = 1:numConds
                ratesHere = [pooledTMap{cellI,1,condI}];
                rateNorm(cellI,:,condI) = {max(ratesHere)};
            end
    end
    
end
%Do the normalization
TMap_normalized = cellfun(@(x,y) x/y,pooledTMap,rateNorm,'UniformOutput',false);

%Now sort by center of mass
if isempty(COMbinUse)
    firingCOM = TMapFiringCOM(TMap_use);
    [~,COMsortorder] = sort(firingCOM(:,1,1));   
    
    %Alternate: Get bin of max firing 
    firingCOMbin = TMapFiringCOM(TMap_use,'maxBin');
    [~,COMsortorderBin] = sort(firingCOMbin(:,1,1));
else
    [aa,COMsortorderBin] = sort(COMbinUse(:,1));
    %Could amend this to have options like rate normalization
end
TMap_sorted = TMap_normalized(COMsortorderBin,:,:);
cellsUseSorted = cellsUse(COMsortorderBin);

%Now strip down to just cells use
TMap_use = TMap_sorted(logical(cellsUseSorted),:,:);

%Reformat for plotting
for dayI = 1:numDays
    for condI = 1:numConds
        firingRateGridNorm{dayI,condI} = cell2mat(TMap_use(:,dayI,condI));
    end
end
        
%Now actually plot it
figHand = figure('Position',[42 193 1763 608]);
for dayI = 1:numDays
    for condI = 1:numConds
        %subplot(3*2,2,condI+4*(dayI-1))
        subplot(2,numDays*2,condI+((numDays-1)*2*(condI>2))+2*(dayI-1))
        imagesc(firingRateGridNorm{dayI,condI})
        gg = gca;
        gg.XTick = [1 round(numBins/2) 80];
        gg.XTickLabel = {'0';'15';'30'};
        title(['Day ' num2str(dayI) ', cond ' num2str(condI)]) 
        caxis([0 1])
        colormap parula%hot
        xlabel('Position (cm)')
        ylabel('Cell Number')
    end
end    

    

end