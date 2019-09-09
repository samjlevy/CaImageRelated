function [imageCorrs] = getAllCellImageCorrelations(imagesA,imagesB)
%{
tic
p=ProgressBar(length(imagesA));
parfor imAI = 1:length(imagesA)
    imageCorrs(imAI,:) = cell2mat(cellfun(@(x) corr(imagesA{imAI}(:),x(:),'type','Spearman'), imagesB, 'UniformOutput',false));
    p.progress;
end
p.stop;
toc
%}
imA2 = cellfun(@(x) x(:),imagesA,'UniformOutput',false);
imA3 = cell2mat(imA2);
imB2 = cellfun(@(x) x(:),imagesB,'UniformOutput',false);
imB3 = cell2mat(imB2);
imageCorrs = corr(imA3,imB3);

end
