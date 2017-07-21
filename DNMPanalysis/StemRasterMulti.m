base_path = 'F:\Bellatrix\Bellatrix_160831';
reg_paths = {'F:\Bellatrix\Bellatrix_160830';...
             'F:\Bellatrix\Bellatrix_160901'};

[allfiles, all_x_adj_cm, all_y_adj_cm, all_PSAbool, sortedSessioninds, useActual] = GetMegaStuff(base_path, reg_paths);

PlotStemHeatmaps(base_path,reg_paths)



plot_file = 'Cells Stem Rasters';
for plotCell = 1:length(useActual)
    thisCell = useActual(plotCell);
    rastPlot = PlotRasterMultiSess(all_x_adj_cm,all_epochs,all_PSAbool,sortedSessionInds,thisCell);
   % combinedPlot = PlotMultiSessDotField(all_x_adj_cm,all_y_adj_cm,all_epochs,all_PSAbool,sortedSessionInds,thisCell,allUseLogical,allfiles);

    export_fig(plot_file,'-pdf','-append')
    close(rastPlot)
end