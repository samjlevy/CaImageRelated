function [figHand] = PlotZivStyleFigure(pooledTMap,cellsUse,normRef)
%norm ref is a numCells x 2 vector, for each cell say which day (column 1), 
%which cond (column 2) to normalize to

numConds = size(pooledTMap,3);
numDays = size(pooledTMap,2);
%cellsUse needs to be a logical
cellsUse = find(cellsUse);

TMap_use = pooledTMap(cellsUse,:,:);

%Get centers of mass for cells on reference day/cond (1/1)
firingCOM = TMapFiringCOM(TMap_use);
[~,COMsortorder] = sort(firingCOM(:,1,1));   
%Alternate: Get bin of max firing 
firingCOMbin = TMapFiringCOM(TMap_use,'maxBin');
[~,COMsortorderBin] = sort(firingCOMbin(:,1,1));

for dayI = 1:numDays
    for condI = 1:numConds
        TMap_sorted(:,dayI,condI) = TMap_use(COMsortorderBin,dayI,condI);
        for cellI = 1:length(cellsUse)
            %cellJ = cellsUse(cellI);
            thisFiring = TMap_use{cellI,dayI,condI};
            firingRateGrid{dayI,condI}(cellI,:) = thisFiring;
        end
    end
end

%Get max firing rates for normalization
if isnumeric(normRef)
    for cellI = 1:length(cellsUse)
        rateMax(cellI,1) = max(firingRateGrid{normRef(cellI,1),normRef(cellI,2)}(cellI,:));
    end
elseif strcmpi(normRef,'withinCell')
    for cellI = 1:length(cellsUse)
        rateMax(cellI,1) = max([TMap_use{cellI,:,:}]);
    end 
end
    
%Normalize firing rates
for dayI = 1:numDays
    for condI = 1:numConds 
        firingRateGridNorm{dayI,condI} = firingRateGrid{dayI,condI}./rateMax;
    end
end

%Now actually plot it
figHand = figure('Position',[42 193 1763 608]);
for dayI = 1:numDays
    for condI = 1:numConds
        %subplot(3*2,2,condI+4*(dayI-1))
        subplot(2,numDays*2,condI+((numDays-1)*2*(condI>2))+2*(dayI-1))
        imagesc(firingRateGridNorm{dayI,condI})
        title(['Day ' num2str(dayI) ', cond ' num2str(condI)]) 
        caxis([0 1])
        colormap hot
        xlabel('Position')
        ylabel('Cell Number')
    end
end
    

end