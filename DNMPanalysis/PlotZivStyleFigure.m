function [figHand] = PlotZivStyleFigure(pooledTMap,cellsUse,normRef)
%norm ref is a numCells x 2 vector, for each cell say which day (column 1), 
%which cond (column 2) to normalize to

cellsUse = find(dayUse{1}(:,1));

%Get centers of mass for cells on reference day/cond (1/1)
firingCOM = TMapFiringCOM(cellPooledTMap_unsmoothed{1}{1});
%use that to determine a sort order for all cells
[~,COMsortorder] = sort(firingCOM(cellsUse,1,1));
    %or actually just want bin w/ max firing?
    
%Get bin of max firing 
firingCOM = TMapFiringCOM(cellPooledTMap_unsmoothed{1}{1},'maxBin'); %This might still sort fine?

for dayI = 1:9
    for condI = 1:4
        for cellI = 1:length(cellsUse)
            cellJ = cellsUse(cellI);
            
            thisFiring = cellPooledTMap_unsmoothed{1}{1}{cellJ,dayI,condI};
            firingRateGrid{dayI,condI}(cellI,:) = thisFiring;
        end
    end
end

%Get max firing rates for normalization
for cellI = 1:length(cellsUse)
    rateMax(cellI,1) = max(firingRateGrid{normRef(cellI,1),normRef(cellI,2)}(cellI,:));
end


for dayI = 1:9
    for condI = 1:4 
        %Normalize by max on day 1, condition 1
        %firingRateGridNorm{dayI,condI}(cellI,:) = thisFiring / max(firingRateGrid{1,1}(cellI,:));
        firingRateGridNorm{dayI,condI} = firingRateGrid{dayI,condI}./rateMax;
        %Apply COM sort order
        firingRateGridNormSort{dayI,condI} = firingRateGridNorm{dayI,condI}(COMsortorder,:);
    end
end

%Now actually plot it
figHand = figure('Position',[42 193 1763 608]);
for dayI = 1:3
    for condI = 1:4
        %subplot(3*2,2,condI+4*(dayI-1))
        subplot(2,3*2,condI+((3-1)*2*(condI>2))+2*(dayI-1))
        imagesc(firingRateGridNorm{dayI,condI})
        title(['Day ' num2str(dayI) ', cond ' num2str(condI)]) 
        caxis([0 1])
        colormap hot
        xlabel('Position')
        ylabel('Cell Number')
    end
end
    

end