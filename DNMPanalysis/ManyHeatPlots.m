function ManyHeatPlots(mapLoc, thisCell, figHand, subDims, subLocs,titles)

load(fullfile(mapLoc,'PFsLin.mat'),'TMap_gauss')

%figHand;
useTmaps = {TMap_gauss{thisCell,:}};
maxRate = max([useTmaps{:}]);
scaledTmaps = cellfun(@(x) x/maxRate,useTmaps,'UniformOutput',false);

for condType = 1:4
    subHand(condType) = subplot(subDims(1),subDims(2),subLocs(condType,:));

    imagesc(subHand(condType),fliplr(scaledTmaps{condType}))
    caxis([0 1])
    axis off
    
    if ~isempty(titles)
        title(titles{condType})
    end 
end 

end
