function FixAnchorFlipping(reg_paths)

v0Dims = [480 640];
for pathI = 1:length(reg_paths)
    load(fullfile(reg_paths{pathI},'Pos_anchor.mat'))
    if flipX == 1; floorCorners(:,1) = v0Dims(2) - floorCorners(:,1); end
    if flipY == 1; floorCorners(:,2) = v0Dims(1) - floorCorners(:,2); end
    
    save(fullfile(reg_paths{pathI},'Pos_anchor.mat'),'floorCorners','barrierX',...
                'barrierY','flipX','flipY','v0Dims')
    delete(fullfile(reg_paths{pathI},'Pos_align.mat'))
end