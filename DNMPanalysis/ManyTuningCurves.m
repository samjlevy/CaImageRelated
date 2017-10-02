function ManyTuningCurves(dotHeat, base_path, thisCell, meanCurves, ciCurves, subPos, titles)

load(fullfile(base_path,'PFsLin.mat'),'TMap_gauss')

plotColors = [1 0 0.65;... %magenta
              0 0.65 1;... %cyan
              1 0 0;... %red
              0 0 1];   %blue

%figHand;
useTmaps = {TMap_gauss{thisCell,:}};
useMean = {meanCurves{thisCell,:}};
useCI = {ciCurves{thisCell,:}};
maxRate = max([max([useTmaps{:}]) max([useCI{:}])]);
xx = 1:size(useTmaps{1,1},2);
%scaledTmaps = cellfun(@(x) x/maxRate,useTmaps,'UniformOutput',false);

for condType = 1:4
    subHand(condType) = subplot('Position',subPos(condType,:));

    hold on
    plot(subHand(condType),xx,fliplr(useTmaps{1,condType}),'Color',plotColors(4,:),'LineWidth',3)
    plot(subHand(condType),xx,fliplr(useCI{1,condType}(1,:)),'Color',plotColors(1,:),'LineWidth',1)
    plot(subHand(condType),xx,fliplr(useCI{1,condType}(2,:)),'Color',plotColors(1,:),'LineWidth',1)
    plot(subHand(condType),xx,fliplr(useMean{1,condType}),'Color',plotColors(3,:),'LineWidth',1)
    
    ylim([0 ceil(maxRate)])
    subHand(condType).XTickLabel = [];
    
    if ~isempty(titles)
        title(titles{condType})
    end 
end 



end