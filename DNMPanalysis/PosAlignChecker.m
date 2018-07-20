PosAlignChecker(anchor_path,align_paths)

allpaths = [anchor_path;align_paths'];

longX = []; longY = [];
marker = [];
for apI = 1:length(allpaths)
    load(fullfile(allpaths{apI},'Pos_align.mat'),'x_adj_cm','y_adj_cm')
    cellX{apI} = x_adj_cm;
    cellY{apI} = y_adj_cm;
    longX = [longX; x_adj_cm(:)];
    longY = [longY; y_adj_cm(:)];
    marker = [marker; apI*ones(length(x_adj_cm),1)];
end