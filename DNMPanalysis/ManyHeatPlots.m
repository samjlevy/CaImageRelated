function ManyHeatPlots(mapLoc, thisCell, figHand, subDims, subLocs,titles)

load(fullfile(mapLoc,'PFsLin.mat'),'TMap_gauss')

figHand;

for condType = 1:4
    subHand(condType) = subplot(subDims(1),subDims(2),subLocs(condType,:));
    
    maxRate = max([TMap_gauss{thisCell,:}]);
    scaledTmaps = cellfun(@(x) x/maxRate,TMap_gauss,'UniformOutput',false);

    imagesc(subHand(condType),fliplr(scaledTmaps{condType})
    
    if any(titles)
        title(titles{condType})
    end 
end 