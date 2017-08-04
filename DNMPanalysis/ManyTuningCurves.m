function ManyTuningCurves(dotHeat, thisCell, TMap_gauss, shuffTMap_gauss, meanCurves, ciCurves, curveLocs, titles)

load(fullfile(mapLoc,'PFsLin.mat'),'TMap_gauss')

%figHand;
useTmaps = {TMap_gauss{thisCell,:}};
maxRate = max([useTmaps{:}]);
%scaledTmaps = cellfun(@(x) x/maxRate,useTmaps,'UniformOutput',false);

for condType = 1:4
    subHand(condType) = subplot(subDims(1),subDims(2),subLocs(condType,:));

    imagesc(subHand(condType),fliplr(useTmaps{condType}))
    caxis([0 maxRate])
    axis off
    
    if ~isempty(titles)
        title(titles{condType})
    end 
end 



end