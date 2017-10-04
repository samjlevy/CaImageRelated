function ManyHeatPlots(mapLoc, thisCell, figHand, subPos,titles)% subDims,

load(fullfile(mapLoc,'PFsLin.mat'),'TMap_gauss')

%figHand;
useTmaps = {TMap_gauss{thisCell,:}};
maxRate = max([useTmaps{:}]);
%scaledTmaps = cellfun(@(x) x/maxRate,useTmaps,'UniformOutput',false);

for condType = 1:4
    subHand(condType) = subplot('Position',subPos(condType,:));

    imagesc(subHand(condType),fliplr(useTmaps{condType}))
    caxis([0 maxRate])
    axis off
    
    if ~isempty(titles)
        title(titles{condType})
    end 
end 

end
