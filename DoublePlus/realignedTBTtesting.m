% Compare old and new rasters for Titan, session 9
mainFolder = 'C:\Users\Sam\Desktop\DoublePlus';
mice = {'Kerberos','Marble07','Marble11','Pandora','Styx','Titan'};
mouseI = 1; 
mainFolder = 'C:\Users\Sam\Desktop\DoublePlus';
load(fullfile(mainFolder,'armBoundariesUsed.mat'),'lgDataBins')
armLims = [min(abs(lgDataBins.Y(:)))  max(abs(lgDataBins.Y(:)))];
sessI = 1;

load(fullfile(mainFolder,mice{mouseI},'trialbytrialOriginal.mat'),'trialbytrialThresh')
tbtOrig = trialbytrialThresh;
load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'),'tbtAllEachCorrectThreshMaze')
tbtNew = tbtAllEachCorrectThreshMaze;

% First validate positions in new tbt
%{
figure;
for condI = 1:4
    subplot(2,2,condI)
    trialsH = tbtNew(condI).sessID == sessI;
    allXhere = [tbtNew(condI).trialsX{trialsH}];
    allYhere = [tbtNew(condI).trialsY{trialsH}];

    plot(allXhere,allYhere,'.k')
    hold on
    plot(lgDataBins.X(:),lgDataBins.Y(:),'*r')
end
%}

% Reliability
load(fullfile(mainFolder,mice{mouseI},'trialReli.mat'),'trialReli')
[~,trialReliNew,~,~] = TrialReliability2(tbtNew,[],0.25,3,[1; 2; 3; 4]);


% Get some cells to plot that are active in both sess
% Highly active in one cond, lower in others
upThresh = 0.4;
downThresh = 0.2;
oldCells = (sum(trialReli(:,sessI,:) > upThresh,3) == 1) & (sum(trialReli(:,sessI,:) < downThresh,3) == 3);
newCells = (sum(trialReliNew(:,sessI,:) > upThresh,3) == 1) & (sum(trialReliNew(:,sessI,:) < downThresh,3) == 3);
posCells = find(oldCells & newCells);

cellPlot = 1;
cellI = posCells(cellPlot);

cellI = 5;

condPlot = [1 2 3 4];
armLabels = {'n','w','s','e'};
PlotDoublePlusRaster(tbtOrig,cellI,sessI,condPlot,armLabels,armLims)
suptitleSL(['Old: Mouse ' num2str(mouseI) ', Cell ' num2str(cellI), ', session ' num2str(sessI)])
set(gcf,'Position',[70.3333 171 560 420])
PlotDoublePlusRaster(tbtNew,cellI,sessI,condPlot,armLabels,armLims)
suptitleSL(['New: Mouse ' num2str(mouseI) ', Cell ' num2str(cellI), ', session ' num2str(sessI)])
set(gcf,'Position',[698.3333 143.6667 560 420])


%% 
upThresh = 0.4;
downThresh = 0.2;
oldCells = (sum(trialReli(:,sessI,:) > upThresh,3) == 1) & (sum(trialReli(:,sessI,:) < downThresh,3) == 3);
newCells = (sum(trialReliNew(:,sessI,:) > upThresh,3) == 1) & (sum(trialReliNew(:,sessI,:) < downThresh,3) == 3);
posCells = find(oldCells & newCells);

cellPlot = 1;
cellI = posCells(cellPlot);

armLims = [min(abs(lgDataBins.Y(:)))  max(abs(lgDataBins.Y(:)))];
sessI = 1;
cellI = 7;
condPlot = [1 2 3 4];
armLabels = {'n','w','s','e'};
PlotDoublePlusRaster(cellTBT{mouseI},cellI,sessI,condPlot,armLabels,armLims)
suptitleSL(['New: Mouse ' num2str(mouseI) ', Cell ' num2str(cellI), ', session ' num2str(sessI)])
set(gcf,'Position',[698.3333 143.6667 560 420])

load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'),'tbtLapCorrect')
PlotDotplotDoublePlus2(tbtLapCorrect,cellI,[1 2],sessI,'classicRed',[],3)

mapHere = [cellTMap{mouseI}{cellI,sessI,:}]; mapHere = mapHere(:)'; mapHere(mapHere==0) = 0.001;
jetGrad = colormap('parula'); for ii = 1:4; jetGrad(ii,:) = [1 1 1]; end
[figHand] = PlusMazePVcorrHeatmap3(mapHere,lgPlotAll,jetGrad,[0 max(mapHere)],['Cell ' num2str(cellI) ', sess ' num2str(sessI)]);


%% tbt final evaluation
mainFolder = 'C:\Users\Sam\Desktop\DoublePlus';
mice = {'Kerberos','Marble07','Marble11','Pandora','Styx','Titan'};

wholeLapGood = false(9,6);
eachLapGood = false(9,6);
for mouseI = 1:numMice
    mouseI = 6

    load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'),'tbtLapCorrect','tbtAllEachCorrectThreshMaze')
    tbtCorrect{mouseI} = tbtLapCorrect;
    tbt{mouseI} = tbtAllEachCorrectThreshMaze;
    
    % Whole lap
    for sessI = 1:9
        gag = figure;
        for condI = 1:2
            trialsH = tbtCorrect{mouseI}(condI).sessID == sessI;
            trialInds = find(trialsH);
            for trialI = 1:numel(trialInds)
                plot(tbtCorrect{mouseI}(condI).trialsX{trialInds(trialI)},tbtCorrect{mouseI}(condI).trialsY{trialInds(trialI)},'k')
                hold on;
                plot(tbtCorrect{mouseI}(condI).trialsX{trialInds(trialI)}(1),tbtCorrect{mouseI}(condI).trialsY{trialInds(trialI)}(1),'.c')
                plot(tbtCorrect{mouseI}(condI).trialsX{trialInds(trialI)}(end),tbtCorrect{mouseI}(condI).trialsY{trialInds(trialI)}(end),'.r')
            end
        end
        title(['Mouse ' num2str(mouseI) ', day ' num2str(sessI)])
        wholeLapGood(sessI,mouseI) = strcmpi(input('this ok (y/n)?','s'),'y');
        try
            close(gag);    
        end
    end

    for sessI = 1:9
        gag = figure;
        for condI = 1:4
            trialsH = tbt{mouseI}(condI).sessID == sessI;
            trialInds = find(trialsH);
            for trialI = 1:numel(trialInds)
                plot(tbt{mouseI}(condI).trialsX{trialInds(trialI)},tbt{mouseI}(condI).trialsY{trialInds(trialI)},'k')
                hold on;
                plot(tbt{mouseI}(condI).trialsX{trialInds(trialI)}(1),tbt{mouseI}(condI).trialsY{trialInds(trialI)}(1),'.c')
                plot(tbt{mouseI}(condI).trialsX{trialInds(trialI)}(end),tbt{mouseI}(condI).trialsY{trialInds(trialI)}(end),'.r')
            end
        end
        title(['Mouse ' num2str(mouseI) ', day ' num2str(sessI)])
        eachLapGood(sessI,mouseI) = strcmpi(input('this ok (y/n)?','s'),'y');
        try
            close(gag);    
        end
    end
end

mouseI = 2;
condI = 4;
sessI = 1;
lapI = 7;
ptsDelete = [1];
lapDelLogical = false(1,numel(tbt{mouseI}(condI).lapFrames{lapIndsHere(lapI)}));
lapDelLogical(ptsDelete) = true;
lapKeepLogical = ~lapDelLogical;

mouseI = 4;
sessI = 1;
condI = 4;
lapI = 1;
lapIndsHere =  find(tbt{mouseI}(condI).sessID==sessI);
cellfun(@(x) x(end),tbt{mouseI}(condI).trialsX(lapIndsHere)) 
keepLogical = false(1,121); 
keepLogical(1:87) = true;
lapKeepLogical = keepLogical;


%figure; plot(tbt{mouseI}(condI).trialsX{lapIndsHere(lapI)},tbt{mouseI}(condI).trialsY{lapIndsHere(lapI)},'.k')

tbt{mouseI}(condI).trialsX{lapIndsHere(lapI)} = tbt{mouseI}(condI).trialsX{lapIndsHere(lapI)}(lapKeepLogical);
tbt{mouseI}(condI).trialsY{lapIndsHere(lapI)} = tbt{mouseI}(condI).trialsY{lapIndsHere(lapI)}(lapKeepLogical);
tbt{mouseI}(condI).trialVelocity{lapIndsHere(lapI)} = tbt{mouseI}(condI).trialVelocity{lapIndsHere(lapI)}(lapKeepLogical);
tbt{mouseI}(condI).trialPSAbool{lapIndsHere(lapI)} = tbt{mouseI}(condI).trialPSAbool{lapIndsHere(lapI)}(:,lapKeepLogical);
tbt{mouseI}(condI).trialRawTrace{lapIndsHere(lapI)} = tbt{mouseI}(condI).trialRawTrace{lapIndsHere(lapI)}(:,lapKeepLogical);
tbt{mouseI}(condI).trialDFDTtrace{lapIndsHere(lapI)} = tbt{mouseI}(condI).trialDFDTtrace{lapIndsHere(lapI)}(:,lapKeepLogical);
tbt{mouseI}(condI).lapFrames{lapIndsHere(lapI)} = tbt{mouseI}(condI).lapFrames{lapIndsHere(lapI)}(lapKeepLogical);

tbtAllEachCorrectThreshMaze = tbt{mouseI};
save(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'),'tbtAllEachCorrectThreshMaze','-append')

% tbt editing
for mouseI = 1:6
    sessBad = find(eachLapGood(:,mouseI)==false);
    if any(sessBad)
        % Show the plot again
        % findclosest2d to indicate the bad laps
        % trim laps approapriately
        % re-save that tbt
        % ask if we want to edit behavior braintime and finalized (and
        % behavior.mat?)
    end

    load(fullfile(mainFolder,mice{mouseI},'daybyday.mat'),'all_x_adj_cm','all_y_adj_cm')
    for condI = 1:4
        lapsHereInds = find(tbt{mouseI}(condI).sessID==sessI);
        epochs(condI).starts = cellfun(@(x) x(1),tbt{mouseI}(condI).lapFrames(lapsHereInds));
        epochs(condI).stops = cellfun(@(x) x(end),tbt{mouseI}(condI).lapFrames(lapsHereInds));
    end

    % Doesn't work, tbt already filtered for off maze and velocity
    [fixedEpochs, reporter] = FindBadLaps(all_x_adj_cm{sessI}, all_y_adj_cm{sessI}, epochs);

    % Step through and for each lap where a fixed epoch is different from
    % epochs, adjust the tbt
    for condI = 1:4
        lapsHereInds = find(tbt{mouseI}(condI).sessID==sessI);
        for lapI = 1:numel(epochs(condI).starts)
            if (fixedEpochs(condI).starts(lapI) ~= epochs(condI).starts(lapI)) || ...
               (fixedEpochs(condI).stops(lapI) ~= epochs(condI).stops(lapI))

                sharedFramesMat = (fixedEpochs(condI).starts(lapI):fixedEpochs(condI).stops(lapI)) == (epochs(condI).starts(lapI):epochs(condI).stops(lapI))'; 
                framesKeep = logical(sum(aa,2))';



            end

        end
    end

end