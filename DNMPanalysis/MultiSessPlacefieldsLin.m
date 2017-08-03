function MultiSessPlacefieldsLin( allfiles, all_x_adj_cm, all_y_adj_cm, sessionInds, all_PSAbool, cmperbin, all_useLogical, useActual)
lapThresh = 4;
mapLoc = 'F:\Bellatrix\Bellatrix_160901';

numSessions = length(allfiles); 
%allInc = cell(4,length(allfiles));
numframes = cell2mat(cellfun(@length, all_x_adj_cm, 'UniformOutput',false));
[bounds, ~, correct] = GetMultiSessDNMPbehavior(allfiles, numframes);

correctBounds = StructCorrect(bounds, correct);

trialbytrial = PoolTrialsAcrossSessions(correctBounds,all_x_adj_cm,all_y_adj_cm,all_PSAbool,sessionInds);

[sortedReliability,aboveThresh] = TrialReliability(trialbytrial, 0.5);
[maxConsec, enoughConsec] = ConsecutiveLaps(trialbytrial,lapThresh);

newUse = cell2mat(cellfun(@(x) sum(x,2) > 0,aboveThresh,'UniformOutput',false));
newUseActual = find(sum(newUse,2));
newUse2 = cell2mat(cellfun(@(x) sum(x,2) > 0,enoughConsec,'UniformOutput',false));
newUseActual2 = find(sum(newUse2,2));

threshing = [sum(newUse,2)>0 sum(newUse2,2)>0];
threshing2 = find(sum(threshing,2));

PFsLinTrialbyTrial(trialbytrial,aboveThresh);

figDir = fullfile(base_path,'tempPlots');
if exist(figDir(1:end-4),'dir')==0
    mkdir(fullfile(base_path,'tempPlots'))
end
for cellJ = 1:length(threshing2)
    thisCell = threshing2(cellJ);
    
    rastPlot = figure('name','Raster Plot');
    rastPlot.OuterPosition = [0 0 850 1100];
    rastPlot.PaperPositionMode = 'auto';
    PlotRasterMultiSess2(trialbytrial, thisCell, sessionInds,rastPlot);
    
    resolution_use = '-r600'; %'-r600' = 600 dpi - might not be necessary
    rastPlot.Renderer = 'painters';
    %rastPlot.PaperOrientation = 'portrait';
    
    zzs = num2str(zeros(1,3-length(num2str(thisCell))));
    save_file = fullfile(figDir, ['cell_' zzs num2str(thisCell) '_heatDot']);
    print(rastPlot, save_file,'-dpdf','-fillpage',resolution_use);
    close(rastPlot)
end

fls = dir(figDir);
fls([fls.isdir]) = [];
names = {fls.name};
names2 = cellfun(@(x) fullfile(figDir,x),names,'UniformOutput',false);
output_file = fullfile(base_path,'Bellatrix Stem Rasters.pdf');
copyfile(names2{1},fullfile(output_file));
append_pdfs(output_file,names2{2:end})
rmdir(figDir,'s')
    



dotlocs = [5 6; 7 8; 13 14; 15 16];
heatlocs = [1 2; 3 4; 9 10; 11 12];
%left bottom width height

dotHeight = 0.18;
heatHeight = 0.08;
tuningHeight = 0.18;
width = 0.4;
leftCol = 0.05;
rightCol = 0.55;

titles = {'Study Left'; 'Study Right'; 'Test Left'; 'Test Right'};
mkdir(fullfile(base_path,'tempPlots'))
for cellI = 1:length(threshing2)
    thisCell = threshing2(cellI);

    dotHeat = figure;
    dotHeat.OuterPosition = [0 0 850 1100];
    dotHeat.PaperPositionMode = 'auto';
    ManyDotPlots(trialbytrial, thisCell, sessionInds, aboveThresh, dotHeat, [4 4], dotlocs, []) %titles
    ManyHeatPlots(mapLoc, thisCell, dotHeat, [4 4], heatlocs,titles)
    
    ManyTuningCurves( )
    
    
    cellnums = num2str(sessionInds(thisCell,:));
    spaces = [-2 strfind(cellnums,'  ')];
    cellnums(spaces(find(diff(spaces)>1)+1))='/';
    cellnums(strfind(cellnums,' '))=[];
    cellnums(strfind(cellnums,' '))=[];

    suptitle(['Cell #: ' cellnums])
    
    resolution_use = '-r600'; %'-r600' = 600 dpi - might not be necessary
    rastPlot.Renderer = 'painters';
    %rastPlot.PaperOrientation = 'portrait';
    
    zzs = num2str(zeros(1,3-length(num2str(thisCell))));
    save_file = fullfile(figDir, ['cell_' zzs num2str(thisCell) '_heatDot']);
    print(rastPlot, save_file,'-dpdf','-fillpage',resolution_use);
    close(rastPlot)
end

append_pdfs(output file, input files)


    
    
%make lin place fields

%plot heatmaps

plotX = [trialbytrial(condType).trialsX{:}];
plotY = [trialbytrial(condType).trialsY{:}];
blockBool = [trialbytrial(condType).trialPSAbool{:}];
spikeX = plotX(blockBool(14,:));
spikeY = plotY(blockBool(14,:));
ddd


end

