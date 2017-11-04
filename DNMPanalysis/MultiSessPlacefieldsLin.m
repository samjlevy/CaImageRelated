function MultiSessPlacefieldsLin( base_path, lapThresh, reliableThresh)
lapThresh = 3;
reliableThresh = 0.25;

load(base_path,'trialbytrial.mat')

[trialReli,aboveThresh] = TrialReliability(trialbytrial, reliableThresh);%sortedReliability
[consec, enoughConsec] = ConsecutiveLaps(trialbytrial,lapThresh);%maxConsec

newUse = cell2mat(cellfun(@(x) sum(x,2) > 0,aboveThresh,'UniformOutput',false));
newUse2 = cell2mat(cellfun(@(x) sum(x,2) > 0,enoughConsec,'UniformOutput',false));

for condT = 1:4
reorgThresh(:,:,condT) = aboveThresh{condT};
reorgConsec(:,:,condT) = enoughConsec{condT};
end
threshAndConsec = reorgThresh | reorgConsec;

dayUse = sum(reorgThresh,3);
dayUse2 = sum(reorgConsec,3);

dayAllUse = dayUse + dayUse2;

threshPerDay = sum(dayUse>0,1);
consecPerDay = sum(dayUse2>0,1); 

threshUse = sum(dayUse,2)>0;
consecUse = sum(dayUse2,2)>0;

useCells = find(threshUse+consecUse > 0);

[dayAllUse, threshAndConsec] = GetUseCells(trialbytrial, lapThresh, reliableThresh);
[Conds] = GetTBTconds(trialbytrial);

xlims = [25 60]; cmperbin = 2.5; minspeed = 0; 
if exist(fullfile(base_path,'PFsLin.mat'),'file')
    disp(['Already have ' fullfile(base_path,'PFsLin.mat')])
else
	[~, ~, ~, TMap_unsmoothed, ~, TMap_gauss] =...
        PFsLinTrialbyTrial(trialbytrial, xlims, cmperbin, minspeed, 1, fullReg.BaseSession);
end

[OccMap, RunOccMap, xBin, TMap_unsmoothed, TCounts, TMap_gauss] =...
    PFsLinTrialbyTrialCONDpool(trialbytrial,xlims, cmperbin, minspeed, 1, fullReg.BaseSession, Conds);


numShuffles = 1000;
dimShuffle = 'all'; %'direction' 'studytest'
[meanCurves, ciCurves, ~, shuffTMap_gauss]=...
    PlaceTuningCurveLin(base_path, trialbytrial, aboveThresh,  xlims,...
                        cmperbin, minspeed, numShuffles, dimShuffle);





threshing = sum(newUse,2)>0 | sum(newUse2,2)>0;
useCells = find(threshing);

figDir = fullfile(base_path,'tempPlots');
if exist(figDir(1:end-4),'dir')==0
    mkdir(fullfile(base_path,'tempPlots'))
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
    PlotRasterMultiSess2(trialbytrial, thisCell, sortedSessionInds,rastPlot,orientation,dates,1);
    
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
output_file = fullfile(base_path,'Polaris Stem Rasters.pdf');
copyfile(names2{1},fullfile(output_file));
append_pdfs(output_file,names2{2:end})
rmdir(figDir,'s')
    

%sessUse = [4 5 6]
thisCell = 44;
sessUse = sortedSessionInds(thisCell,:)>0;
smallAllFiles = allfiles(sessUse);
filepts = cellfun(@(x) strsplit(x,'_'),smallAllFiles,'UniformOutput',false);
dates = cell2mat(cellfun(@(x) str2double(x{2}(1:6)),filepts,'UniformOutput',false));
smallSortedSessionInds = sortedSessionInds(:,sessUse);

for condI = 1:length(trialbytrial)
    keepRows = find(sum(trialbytrial(condI).sessID == find(sessUse),2));
    
    tbtSmall(condI).trialsX = trialbytrial(condI).trialsX(keepRows);
    tbtSmall(condI).trialsY = trialbytrial(condI).trialsY(keepRows);
    tbtSmall(condI).trialPSAbool = trialbytrial(condI).trialPSAbool(keepRows);
    tbtSmall(condI).sessID = trialbytrial(condI).sessID(keepRows);
    
    sessNumDiffs = diff([0; tbtSmall(condI).sessID],1,1);
    diffInds = flipud(find(sessNumDiffs > 1));
    diffVal = sessNumDiffs(diffInds);
    for dd = 1:length(diffInds)
        tbtSmall(condI).sessID(diffInds(dd):end) =...
            tbtSmall(condI).sessID(diffInds(dd):end) - (diffVal(dd)-1);  
    end      
end
    
rastPlot = figure('name','Raster Plot');
rastPlot.OuterPosition = [0 0 1100 850];
PlotRasterMultiSess2(tbtSmall, thisCell, smallSortedSessionInds,rastPlot,'landscape',dates,0);
suptitle(['Cell #' num2str(thisCell)])

dotlocs = [5 6; 7 8; 13 14; 15 16];
heatlocs = [1 2; 3 4; 9 10; 11 12];
%left bottom width height

dotH = 0.19;
heatH = 0.04;
tuningH = 0.19;

width = 0.4;
leftCol = 0.05;
botMarg = 0.03;
rowBuf = 0.01;
%rightCol = 0.55;

for condType = 1:4
    colMod = mod(condType+1,2);
    rowMod = condType<3;
    dotPos(condType,:) = [leftCol+0.5*colMod, botMarg+0.5*rowMod, width, dotH];
    heatPos(condType,:) = [dotPos(condType,1:3) 0] + [0 rowBuf+dotH 0 heatH]; 
    tuningPos(condType,:) = [heatPos(condType,1:3) 0] + [0 rowBuf+heatH 0 tuningH];
end







titles = {'Study Left'; 'Study Right'; 'Test Left'; 'Test Right'};
mkdir(fullfile(base_path,'tempPlots'))
figDir = 'F:\Bellatrix\Bellatrix_160831\tempPlots';
for cellI = 1:length(useCells)
    thisCell = useCells(cellI);

    dotHeat = figure;
    dotHeat.OuterPosition = [400 50 850 1000];
    dotHeat.PaperPositionMode = 'auto';
    ManyDotPlots(trialbytrial, thisCell, sortedSessionInds, aboveThresh, dotHeat, dotPos, []) %titles
    ManyHeatPlots(base_path, thisCell, dotHeat, heatPos, [])%titles
    
    ManyTuningCurves(dotHeat, base_path, thisCell, meanCurves, ciCurves, tuningPos, titles)
    
    cellnums = num2str(sortedSessionInds(thisCell,:));
    spaces = [-2 strfind(cellnums,'  ')];
    cellnums(spaces(find(diff(spaces)>1)+1))='/';
    cellnums(strfind(cellnums,' '))=[];
    cellnums(strfind(cellnums,' '))=[];

    suptitle(['Cell #: ' cellnums])
    
    resolution_use = '-r600'; % dpi - might not be necessary
    dotHeat.Renderer = 'painters';
    
    zzs = num2str(zeros(1,3-length(num2str(thisCell))));
    save_file = fullfile(figDir, ['cell_' zzs num2str(thisCell) '_heatDot']);
    print(dotHeat, save_file,'-dpdf','-fillpage',resolution_use);
    close(dotHeat)
end

fls = dir(figDir);
fls([fls.isdir]) = [];
names = {fls.name};
names2 = cellfun(@(x) fullfile(figDir,x),names,'UniformOutput',false);
output_file = fullfile(base_path,'Bellatrix DotCurveHeat.pdf');
copyfile(names2{1},fullfile(output_file));
append_pdfs(output_file,names2{2:end})
%rmdir(figDir,'s')

append_pdfs(output file, input files)



end

