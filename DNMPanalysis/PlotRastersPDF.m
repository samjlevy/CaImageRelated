function PlotRastersPDF(trialbytrial, sortedSessionInds, allfiles, useCells, saveDir, mouseName)
orientation = 'landscape';
plotPositions = 1;
[xMax, xMin] = GetTBTlims(trialbytrial);
xlims = [min(xMin) max(xMax)];

figDir = fullfile(saveDir,'tempPlots');
if exist(figDir(1:end-4),'dir')==0
    mkdir(fullfile(saveDir,'tempPlots'))
end

filepts = cellfun(@(x) strsplit(x,'_'),allfiles,'UniformOutput',false);
dates = cell2mat(cellfun(@(x) str2double(x{2}(1:6)),filepts,'UniformOutput',false));
for cellJ = 1:length(useCells)
    thisCell = useCells(cellJ);
    
    rastPlot = figure('name','Raster Plot');
    switch orientation
        case 'landscape'
            rastPlot.OuterPosition = [0 0 1100 850];
        case 'portrait'
            rastPlot.OuterPosition = [0 0 850 1100];
    end
    rastPlot.PaperPositionMode = 'auto';
    PlotRasterMultiSess2(trialbytrial, thisCell, sortedSessionInds,rastPlot,orientation,dates,plotPositions,xlims);
    
    resolution_use = '-r600'; %'-r600' = 600 dpi - might not be necessary
    rastPlot.Renderer = 'painters';
    
    zzs = num2str(zeros(1,3-length(num2str(thisCell))));
    save_file = fullfile(figDir, ['cell_' zzs num2str(thisCell) '_heatDot']);
    print(rastPlot, save_file,'-dpdf','-fillpage',resolution_use);
    close(rastPlot)
end

fls = dir(figDir);
fls([fls.isdir]) = [];
names = {fls.name};
names2 = cellfun(@(x) fullfile(figDir,x),names,'UniformOutput',false);
output_file = fullfile(saveDir,[mouseName ' Stem Rasters.pdf']);
copyfile(names2{1},fullfile(output_file));
append_pdfs(output_file,names2{2:end})
rmdir(figDir,'s')

end