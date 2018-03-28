function PlotAllSessPos(reg_paths)

figure; hold on
for pathI = 1:length(reg_paths)
    load(fullfile(reg_paths{pathI},'Pos_align.mat'),'x_adj_cm','y_adj_cm')
    plot(x_adj_cm,y_adj_cm,'.')
end

end
    