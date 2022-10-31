% Big heatmaps to visualize change across days
useDays = [3 8];
useConds = [1 2 3 4];
condPairs = useConds(:);

% Divide up bins more for smoothed plot
binLabels = lgDataBins.labels;
binVertices = lgBinVertices;

armMax = max(lgDataBins.X(:));
armMin = min(abs(lgDataBins.X(:)));
nBinsHere = 48;
binLimitsHere = linspace(armMin,armMax,nBinsHere+1); 
tempBin = [];
for binI = 1:nBinsHere
    xx = 1;
    yy = binI+[0 1 1 0];

    binXh = binLimitsHere(xx)*[1 1 -1 -1];
    binYh = binLimitsHere(yy);

    tempBin.X(binI,:) = binXh;
    tempBin.Y(binI,:) = binYh;
end
% Reorient these template bins into sets of arms;
% What are we doing about day 6 w/ no west? Just don't plot it? (Yes, skip
% cond 4)
% Also let's reorder them for the eventual plot order:
%  - South end>mid, east mid>end
%  - North end>mid, west mid>end
% Don't need plot bins since going to imagesc on the data matrix
%figure; 
%for binI = 1:nBinsHere
%    text(mean(tempBin.X(binI,:)),mean(tempBin.Y(binI,:)),num2str(binI)); hold on
%end
%xlim([min(tempBin.X(:)) max(tempBin.X(:))]); ylim([min(tempBin.Y(:)) max(tempBin.Y(:))])
aggBinX = [];
aggBinY = [];
aggBinN = [];
aggLabels = [];
for condI = 1:numConds
    binOrderH = 1:nBinsHere; binOrderH = binOrderH(:);
    switch armLabels{useConds(condI)}
        case 'n'
            bbX = tempBin.X;
            bbY = flipud(tempBin.Y);
            lbls = repmat(['n'],nBinsHere,1);
        case 's'
            bbX = tempBin.X;
            bbY = flipud(-tempBin.Y);
            lbls = repmat(['s'],nBinsHere,1);
        case 'e'
            bbX = tempBin.Y;
            bbY = tempBin.X;
            lbls = repmat(['e'],nBinsHere,1);
        case 'w'
            bbX = -tempBin.Y;
            bbY = tempBin.X;
            lbls = repmat(['w'],nBinsHere,1);
    end
    aggBinX = [aggBinX; bbX];
    aggBinY = [aggBinY; bbY];
    aggLabels = [aggLabels; lbls];
    aggBinN = [aggBinN; binOrderH];
end
nicePlotBins{1} = aggBinX;
nicePlotBins{2} = aggBinY;
for bbI = 1:size(nicePlotBins{1},1)
    for bbJ = 1:size(nicePlotBins{1},2)
        thisPt = [nicePlotBins{1}(bbI,bbJ) nicePlotBins{2}(bbI,bbJ)];
        if abs(thisPt(1)) < lgDataBins.X(2,3) &&...
            abs(thisPt(2)) < lgDataBins.X(2,3)
            [~,biggerPt] = max(abs(thisPt));
            nicePlotBins{1}(bbI,bbJ) = abs(nicePlotBins{biggerPt}(bbI,bbJ)) * ( nicePlotBins{1}(bbI,bbJ)/abs(nicePlotBins{1}(bbI,bbJ)) );
            nicePlotBins{2}(bbI,bbJ) = abs(nicePlotBins{biggerPt}(bbI,bbJ)) * ( nicePlotBins{2}(bbI,bbJ)/abs(nicePlotBins{2}(bbI,bbJ)) );
        elseif abs(thisPt(1)) >= lgDataBins.X(2,3) ||...
            abs(thisPt(2)) >= lgDataBins.X(2,3)
            if thisPt(1) ~= thisPt(2)
            [~,smallerPt] = min(abs(thisPt));
            nicePlotBins{smallerPt}(bbI,bbJ) = lgDataBins.X(2,3) * ( nicePlotBins{smallerPt}(bbI,bbJ)/abs(nicePlotBins{smallerPt}(bbI,bbJ)) ); 
            end
                                    % Last bit here to get the sign right


        end
    end
end

%{
figure; 
for binI = 1:size(aggBinY,1)
    text(mean(aggBinX(binI,:)),mean(aggBinY(binI,:)),[num2str(binI)]); hold on; %num2str(aggBinN(binI)) ', ' 
end
xlim([min(aggBinX(:)) max(aggBinX(:))]); ylim([min(aggBinY(:)) max(aggBinY(:))])
%}

for mouseI=1:numMice
        disp(['mouse ' num2str(mouseI)])
        pfNam = [];
        [plotMaps{mouseI},~] = RateMapsDoublePlusV2(cellTBT{mouseI}, nicePlotBins, 'vertices', condPairs, 0, 'zeroOut', pfNam, false);
        

        for condI = 1:numConds
            plotMaps{mouseI}(:,[1:3 7:9],condI) =...
                cellfun(@(x) x(aggLabels==armLabels{useConds(condI)}),plotMaps{mouseI}(:,[1:3 7:9],condI),'UniformOutput',false);
        end

        if mouseI == 1
            for condI = 1:numConds
                [plotMaps{mouseI}{:,5,condI}] = deal(zeros(nBinsHere,1));
                [plotMaps{mouseI}{:,6,condI}] = deal(zeros(nBinsHere,1));
            end
        end
end

oneEnvMaps = cell(2,2); [oneEnvMaps{:}] = deal(cell(1,4));
twoEnvMaps = cell(2,2); [twoEnvMaps{:}] = deal(cell(1,4));

oneEnvPlotCOMs = cell(1,2); [oneEnvPlotCOMs{:}] = deal(cell(1,4));
oneEnvSourceMice = cell(1,2); [oneEnvSourceMice{:}] = deal(cell(1,4));
oneEnvSourceInds = cell(1,2); [oneEnvSourceInds{:}] = deal(cell(1,4));
twoEnvPlotCOMs = cell(1,2); [twoEnvPlotCOMs{:}] = deal(cell(1,4));
twoEnvSourceMice = cell(1,2); [twoEnvSourceMice{:}] = deal(cell(1,4));
twoEnvSourceInds = cell(1,2); [twoEnvSourceInds{:}] = deal(cell(1,4));

oneEnvThisCond = cell(2,2); [oneEnvThisCond{:}] = deal(cell(1,4));
twoEnvThisCond = cell(2,2); [twoEnvThisCond{:}] = deal(cell(1,4));
oneEnvReliability = cell(1,2); [oneEnvReliability{:}] = deal(cell(1,4));
twoEnvReliability = cell(1,2); [twoEnvReliability{:}] = deal(cell(1,4));

for mouseI=1:numMice
    % Remember that cellTMap/TMap_unsmoothed in data is reordered to
    % plot from center out. May not matter here, since we're just
    % plotting for fun
    % A few metrics to look at plotting order
    % - Max of mean of within trial firing rates only for bins where actually fired
    pmMeans = cellfun(@(x) mean(x(x>0)),plotMaps{mouseI}); [~,pmMeanMaxCond] = max(pmMeans,[],3);
    % - Max of mean of within trial firing rates
    pmMeansZ = cellfun(@(x) mean(x),plotMaps{mouseI}); [~,pmMeanMaxCondZ] = max(pmMeansZ,[],3);
    % - Max bin across all conds
    pmMaxes = cellfun(@(x) max(x),plotMaps{mouseI});       [~,pmMaxCond] = max(pmMaxes,[],3);

    % Within trial center of mass of firing - for within block ordering
    pmCOM{mouseI} = TMapFiringCOM(plotMaps{mouseI});

    for ddI = 1:2
        cellsUseHere = dayUseAll{mouseI}(:,useDays(ddI)) & sum(cellSSI{mouseI}(:,useDays)>0,2)==numel(useDays);

        % Concatenate cells use maps, indexes of which mouse this is and
        % location of firing and value of the metric plotted
        for condI = 1:numConds
            cellsMaxThisCond = pmMeanMaxCond(:,useDays(ddI)) == condI;
            theseCellInds = find(cellsUseHere & cellsMaxThisCond);

            sourceMouse = mouseI*ones(numel(theseCellInds),1);
            comsHere = pmCOM{mouseI}(theseCellInds,useDays(ddI),condI);

            switch groupNum(mouseI)
                case 1
                    oneEnvPlotCOMs{ddI}{condI} = [oneEnvPlotCOMs{ddI}{condI}; comsHere];
                    oneEnvSourceMice{ddI}{condI} = [oneEnvSourceMice{ddI}{condI}; sourceMouse];
                    oneEnvSourceInds{ddI}{condI} = [oneEnvSourceInds{ddI}{condI}; theseCellInds];
                    oneEnvReliability{ddI}{condI} = [oneEnvReliability{ddI}{condI}; trialReliAll{mouseI}(theseCellInds,useDays(ddI))];
                case 2
                    twoEnvPlotCOMs{ddI}{condI} = [twoEnvPlotCOMs{ddI}{condI}; comsHere];
                    twoEnvSourceMice{ddI}{condI} = [twoEnvSourceMice{ddI}{condI}; sourceMouse];
                    twoEnvSourceInds{ddI}{condI} = [twoEnvSourceInds{ddI}{condI}; theseCellInds];
                    twoEnvReliability{ddI}{condI} = [twoEnvReliability{ddI}{condI}; trialReliAll{mouseI}(theseCellInds,useDays(ddI))];
            end

            for ddJ = 1:2
                % ddI is day getting cellsUse from
                % ddJ is day sampling maps from
                for condJ = 1:numConds
                    switch groupNum(mouseI)
                        case 1
                            oneEnvMaps{ddI,ddJ}{condJ} = [oneEnvMaps{ddI,ddJ}{condJ}; plotMaps{mouseI}(theseCellInds,useDays(ddJ),condJ)];
                            oneEnvThisCond{ddI,ddJ}{condJ} = [oneEnvThisCond{ddI,ddJ}{condJ}; (condI==condJ)*ones(numel(theseCellInds),1)];
                        case 2
                            twoEnvMaps{ddI,ddJ}{condJ} = [twoEnvMaps{ddI,ddJ}{condJ}; plotMaps{mouseI}(theseCellInds,useDays(ddJ),condJ)];
                            twoEnvThisCond{ddI,ddJ}{condJ} = [twoEnvThisCond{ddI,ddJ}{condJ}; (condI==condJ)*ones(numel(theseCellInds),1)];
                    end
                end
            end

        end

    end

end

oneEnvPlotting = cell(2,2); [oneEnvPlotting{:}] = deal(cell(1,4));
twoEnvPlotting = cell(2,2); [twoEnvPlotting{:}] = deal(cell(1,4));

for ddI = 1:2
for ddJ = 1:2
    % Need to go through each cond, and grab the cells which have their
    % peak whatever during that cond, sort them by plotCOMs, apply that to
    % all cond activity plots
    for condI = 1:numConds 
        % Get the cells with max here
        oneCellsThisCond = find(oneEnvThisCond{ddI,ddJ}{condI});
        twoCellsThisCond = find(twoEnvThisCond{ddI,ddJ}{condI});
        % Sort them by plot COM
        [~,oneCellsCOMsortOrder] = sort(oneEnvPlotCOMs{ddI}{condI});
        [~,twoCellsCOMsortOrder] = sort(twoEnvPlotCOMs{ddI}{condI});
    
        for condJ = 1:numConds
            % apply that sort order to all activity across all conds
            oneMapsH = oneEnvMaps{ddI,ddJ}{condJ}(oneCellsThisCond);
            oneEnvPlotting{ddI,ddJ}{condJ} = [oneEnvPlotting{ddI,ddJ}{condJ}; oneMapsH(oneCellsCOMsortOrder)];
            twoMapsH = twoEnvMaps{ddI,ddJ}{condJ}(twoCellsThisCond);
            twoEnvPlotting{ddI,ddJ}{condJ} = [twoEnvPlotting{ddI,ddJ}{condJ}; twoMapsH(twoCellsCOMsortOrder)];
        end
    end
end
end


% Reorient and normalize to max
for ddI = 1:2
    for condI = 1:4
        oneMaxes{ddI}(:,condI) = cellfun(@max,oneEnvPlotting{ddI,ddI}{condI});
        twoMaxes{ddI}(:,condI) = cellfun(@max,twoEnvPlotting{ddI,ddI}{condI});
    end
    oneMaxes{ddI} = max(oneMaxes{ddI},[],2);
    twoMaxes{ddI} = max(twoMaxes{ddI},[],2);

    for ddJ = 1:2
        for condI = 1:4
            oneEnvPlottingMat{ddI,ddJ}{condI} = cell2mat(cellfun(@(x) x(:)',oneEnvPlotting{ddI,ddJ}{condI},'UniformOutput',false));
            twoEnvPlottingMat{ddI,ddJ}{condI} = cell2mat(cellfun(@(x) x(:)',twoEnvPlotting{ddI,ddJ}{condI},'UniformOutput',false));
        end
    
        for condI = 1:4
            oneEnvPlottingNorm{ddI,ddJ}{condI} = oneEnvPlottingMat{ddI,ddJ}{condI} ./ oneMaxes{ddI};
            oneEnvPlottingNorm{ddI,ddJ}{condI}(oneEnvPlottingNorm{ddI,ddJ}{condI} > 1) = 1;
            twoEnvPlottingNorm{ddI,ddJ}{condI} = twoEnvPlottingMat{ddI,ddJ}{condI} ./ twoMaxes{ddI};
            twoEnvPlottingNorm{ddI,ddJ}{condI}(twoEnvPlottingNorm{ddI,ddJ}{condI} > 1) = 1;
        end
    end
end

ddI = 1; % Getting maps sorted for day 3
% OneMaze group
xlabls = {'Start','Mid';'Mid','End';'Start','Mid';'Mid','End'};
for ddJ = 1:2
    figure; 
    for condI = 1:4
        subplot(1,4,condI)
        imagesc(oneEnvPlottingNorm{ddI,ddJ}{condI})
        %colormap bone
        colormap gray
        title(armLabels{condI})
        vv = gca;
        vv.XTick = [1 nBinsHere];
        vv.XTickLabel = xlabls(condI,:);
        vv.YTick = [1 size(oneEnvPlottingNorm{ddI,ddJ}{condI},1)];
        if condI==1
            ylabel('Cell Number')
            vv.YTick = [1 size(oneEnvPlottingNorm{ddI,ddJ}{condI},1)];
        else 
            vv.YTick = [];
        end
    end
    suptitleSL(['OneMaze: Cells from day ' num2str(useDays(ddI)) ', maps day ' num2str(useDays(ddJ))])
end
% TwoMaze group
for ddJ = 1:2
    figure; 
    for condI = 1:4
        subplot(1,4,condI)
        imagesc(twoEnvPlottingNorm{ddI,ddJ}{condI})
        %colormap bone
        colormap gray
        title(armLabels{condI})
        vv = gca;
        vv.XTick = [1 nBinsHere];
        vv.XTickLabel = xlabls(condI,:);
        if condI==1
            ylabel('Cell Number')
            vv.YTick = [1 size(twoEnvPlottingNorm{ddI,ddJ}{condI},1)];
        else 
            vv.YTick = [];
        end
    end
    suptitleSL(['TwoMaze: Cells from day ' num2str(useDays(ddI)) ', maps day ' num2str(useDays(ddJ))])
end


