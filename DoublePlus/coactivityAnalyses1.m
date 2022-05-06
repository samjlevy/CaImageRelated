% Change in coactivity scores
% Do cells that leave an ensemble join another? End up correlated with that
% ensemble?
% Ensemble reorganization during place days?

dayPairsHere = GetAllCombs(1:3,7:9);
daysHere = [1 2 3 7 8 9];
condHere = [1 2 3 4];

% X-corr of timeseries
maxLag = 20;
if ~exist(fullfile(mainFolder,'temporalCorrs.mat'),'file')
for mouseI = 1:numMice
    for sessI = 1:9
        psaHere = [];
        florHere = [];
        for condI = 1:numel(condHere)
            trialsH = cellTBT{mouseI}(condHere(condI)).sessID == sessI;
            if any(trialsH)
                psaHere = [psaHere, cellTBT{mouseI}(condHere(condI)).trialPSAbool{trialsH}];
                florHere = [florHere, cellTBT{mouseI}(condHere(condI)).trialDFDTtrace{trialsH}];
                %pp = [cellTBT{mouseI}(condHere(condI)).trialPSAbool{trialsH}];
                %ff = [cellTBT{mouseI}(condHere(condI)).trialDFDTtrace{trialsH}];
            end
        end
        
        cellsActive = sum(dayUse{mouseI}(:,sessI,condHere),3)>0;
        
        cellPairsHere = nchoosek(find(cellsActive),2);
        
        if any(any(psaHere))
            % cross corrs, limited by some amount of lags?
          
            numCellPairs = size(cellPairsHere,1);
            
            r = zeros(maxLag*2+1,numCellPairs);
            %lags = zeros(numCellPairs,maxLag*2+1);
            tic
            rr = nan(size(cellPairsHere,1),1);
            pp = nan(size(cellPairsHere,1),1);
            for cpI = 1:size(cellPairsHere,1)
                %[r(:,cpI),lags] = xcorr(psaHere(cellPairsHere(cpI,1),:)',psaHere(cellPairsHere(cpI,2),:)',maxLag);
                [rr(cpI,1),pp(cpI,1)] = corr(psaHere(cellPairsHere(cpI,1),:)',psaHere(cellPairsHere(cpI,2),:)','type','Pearson');
            end
            toc
            
            %crossCorrs{mouseI}{sessI} = r;
            cellPairsUsed{mouseI}{sessI} = cellPairsHere;
        
            temporalCorrsR{mouseI}{sessI} = rr;
            temporalCorrsP{mouseI}{sessI} = pp;
        
            laggedCorrs = nan(size(cellPairsHere,1),maxLag*2+1);
            laggedPvals = nan(size(cellPairsHere,1),maxLag*2+1);

            %{
            lagsCheck = -maxLag:1:maxLag;
            tic
            for lagI = 1:maxLag
                zeroBlock = zeros(numCells(mouseI),lagI);
                falseBlock = false(numCells(mouseI),lagI);
                demoBlock = zeros(1,lagI);

                laggedPSA = [];
                laggedFlor = [];
                laggedDemo = [];
                for condI = 1:numel(condHere)
                    trialsH = cellTBT{mouseI}(condHere(condI)).sessID == sessI;


                    if any(trialsH)
                        trialsHinds = find(trialsH);

                        zeroCells = cell(numel(trialsHinds),1);
                        [zeroCells{:}] = deal(falseBlock);
                        psaTrialsCell = cellTBT{mouseI}(condHere(condI)).trialPSAbool(trialsH);
                        psaTrialsWithZerosCell = cell(numel(zeroCells)+numel(psaTrialsCell),1);
                        [psaTrialsWithZerosCell{1:2:2*numel(zeroCells)-1,1}] = deal(zeroCells{:});
                        [psaTrialsWithZerosCell{2:2:2*numel(psaTrialsCell),1}] = deal(psaTrialsCell{:});
                        psaTrialsWithZerosCell = psaTrialsWithZerosCell';
                        laggedPSA = [laggedPSA, cell2mat(psaTrialsWithZerosCell)];

                        zeroCells = cell(numel(trialsHinds),1);
                        [zeroCells{:}] = deal(zeroBlock);
                        florTrialsCell = cellTBT{mouseI}(condHere(condI)).trialDFDTtrace(trialsH);
                        florTrialsWithZerosCell = cell(numel(zeroCells)+numel(florTrialsCell),1);
                        [florTrialsWithZerosCell{1:2:2*numel(zeroCells),1}] = deal(zeroCells{:});
                        [florTrialsWithZerosCell{2:2:2*numel(florTrialsCell),1}] = deal(florTrialsCell{:});
                        florTrialsWithZerosCell = florTrialsWithZerosCell';
                        laggedFlor = [laggedFlor, cell2mat(florTrialsWithZerosCell)];

                        zeroCells = cell(numel(trialsHinds),1);
                        [zeroCells{:}] = deal(demoBlock);
                        trialLengths = cellfun(@(x) size(x,2),cellTBT{mouseI}(condHere(condI)).trialPSAbool(trialsH),'UniformOutput',false);
                        demoTrials = cellfun(@(x) ones(1,x),trialLengths,'UniformOutput',false);
                        demoTrialsCell = cell(numel(zeroCells)+numel(psaTrialsCell),1);
                        [demoTrialsCell{1:2:2*numel(zeroCells)-1,1}] = deal(zeroCells{:});
                        [demoTrialsCell{2:2:2*numel(psaTrialsCell),1}] = deal(demoTrials{:});
                        demoTrialsCell = demoTrialsCell';
                        laggedDemo = [laggedDemo, cell2mat(demoTrialsCell)];
                    end
                end

                laggedPSA = [laggedPSA, falseBlock]; %laggedPSA = logical(laggedPSA);
                laggedFlor = [laggedFlor, zeroBlock];
                laggedDemo = [laggedDemo, demoBlock];

                % Need to run this twice, once to trim the lag off of end
                % cpI,1/beginning of cpI,2, and alternate
                demoA = laggedDemo(1:end-lagI);
                demoB = laggedDemo(lagI+1:end);
                for cpI = 1:size(cellPairsHere,1)
                    datA = laggedPSA(cellPairsHere(cpI,1),:)';
                    datB = laggedPSA(cellPairsHere(cpI,2),:)';

                    datA(1:end-lagI);
                    datB(lagI+1:end);
                    lagColPos = maxLag+1+lagI;
                    lagColNeg = maxLag+1-lagI;
                    [laggedCorrs(cpI,lagColPos),laggedPvals(cpI,lagColPos)] = corr( datA(lagI+1:end), datB(1:end-lagI),'type','Pearson');
                    [laggedCorrs(cpI,lagColNeg),laggedPvals(cpI,lagColNeg)] = corr( datA(1:end-lagI), datB(lagI+1:end),'type','Pearson');
                end
 
            end
                
            %}
        end
        
        %{
        laggedCorrs(:,maxLag+1) = rr;
            laggedPval(:,maxLag+1) = pp;
            save('mouse1sess1crossCorrs.mat','laggedCorrs','laggedPvals','lagsCheck','cellPairsHere')
            
        %}
    
        %crossCorrs{mouseI}{sessI} = laggedCorrs;
        
        %crossCorrPvals{mouseI}{sessI} = laggedPvals;
        
        
        disp(['Done mouse' num2str(mouseI) ', sess ' num2str(sessI)])
    end
    %{
    try
        save(fullfile(mainFolder,'crossCorrs220127.mat'),'crossCorrs','cellPairsUsed','crossCorrPvals')
    catch
        save(fullfile(mainFolder,'crossCorrs220127.mat'),'crossCorrs','cellPairsUsed','crossCorrPvals','-v7.3')
    end
    %}
    

end
save(fullfile(mainFolder,'temporalCorrs.mat'),'temporalCorrsR','temporalCorrsP','cellPairsUsed')
else
    load(fullfile(mainFolder,'temporalCorrs.mat'))
end

[xcorrmaxes,xcmlags] = max(laggedCorrs,[],2);
figure; histogram(xcmlags); title('Most cell pairs seem to have a maximum correlation at 1s lag')

figure; subplot(1,2,1); histogram(laggedCorrs(:,21),'BinLimits',[-0.2 0.9],'Normalization','probability')
title(['Temporal correlations at 0 lag, ' num2str(sum(laggedCorrs(:,21)>0)) ' > 0'])
subplot(1,2,2); cdfplot(laggedCorrs(:,21))

figure; subplot(1,2,1); histogram(xcorrmaxes,'BinLimits',[-0.2 0.9],'Normalization','probability')
title(['Max Temporal correlations up to +/- ' num2str(maxLag) ' lags, ' num2str(sum(xcorrmaxes>0)) ' > 0'])
subplot(1,2,2); cdfplot(xcorrmaxes)


figure; plot(laggedCorrs(:,21), xcorrmaxes, '.'); xlabel('Corr at 0'); ylabel(['Max corr +/- ' num2str(maxLag)])
figure; histogram(xcorrmaxes - laggedCorrs(:,21)); xlabel('corr max - corr at 0')

% Sweep across correlation thresholds, 0.1:0.05:1
% number cell pairs with this threshold
% number each are partnered with (matlab network functions?)
% For session pairs: how similar among these neurons is the corr
% matrix/network graph, hub cells to stay hub cells
% change in spatial corr and change in temporal corr


% For sessions pairs, did we ever just check how many registered,
% likelihood of coming back, still being active, still being active on a
% given arm (absolute change in activity rate) across Turn1-Turn1?





mouseI = 1;
sessI = 1;
xcorrmaxes = max(crossCorrs{mouseI}{sessI},[],1);

 tmapHere = cell(numCells(mouseI),9);
    for condI = 1:4
        tmapHere = cellfun(@(x,y) [x;y],tmapHere,cellTMap{mouseI}(:,:,condI),'UniformOutput',false);
    end
cellPairsHere = cellPairsUsed{mouseI}{sessI};
cphInds = sub2ind([numCells(mouseI) numCells(mouseI)],cellPairsHere(:,1),cellPairsHere(:,2));
for cpI = 1:size(cellPairsHere,1)
[tRhosHere(cpI,1),tPsHere(cpI,1)] = corr(tmapHere{cellPairsHere(cpI,1),sessI},tmapHere{cellPairsHere(cpI,2),sessI},'type','Spearman');
end
figure; plot(tRhosHere,xcorrmaxes,'.')
figure; plot(tRhosHere,rr,'.'); xlabel('Spatial Map Correlation'); ylabel('Fluoresence Timeseries Correlation')
hold on; plot([0 0],[-1 1],'--k'); plot([-1 1],[0 0],'--k'); ylim([-0.2 1])
datacursormode on
dcm_obj = datacursormode(gcf);
set( dcm_obj, 'UpdateFcn', @clickedPtIndex );

cpI = 51124
cc = cellPairsHere(cpI,:)
PlotDoublePlusRaster(cellTBT{mouseI},cc(1),sessI,condPlot,armLabels)
suptitleSL(num2str(cc(1)))
PlotDoublePlusRaster(cellTBT{mouseI},cc(2),sessI,condPlot,armLabels)
suptitleSL(num2str(cc(2)))

oneEnvCoactChange = cell(4,1);
twoEnvCoactChange = cell(4,1);
for mouseI = 1:numMice
    coactLoad = load(fullfile(mainFolder,mice{mouseI},coactFileN),coactVariable);
    coactLoad = coactLoad.(coactVariable);

    for dpI = 1:size(dayPairsHere,1)
        dayA = dayPairsHere(dpI,1);
        dayB = dayPairsHere(dpI,2);
        for condI = 1:numel(condHere)
            condH = condHere(condI);
            for binI = 1:nCoactBins
                cellsActiveA = dayUse{mouseI}(:,dayA,condH) & trialReli{mouseI}(:,dayA,condH)<1;
                cellsActiveB = dayUse{mouseI}(:,dayB,condH) & trialReli{mouseI}(:,dayB,condH)<1;
                %Also have to eliminate cells active all trials

                cellsActive = cellsActiveA & cellsActiveB;

                cellPairsHere = nchoosek(find(cellsActive),2); 
                cphInds = sub2ind([numCells(mouseI) numCells(mouseI)],cellPairsHere(:,1),cellPairsHere(:,2));

                if any(cphInds)
                % Overall change in coactivity scores
                coactA = coactLoad{condH,dayA,binI};
                coactB = coactLoad{condH,dayB,binI};

                coactDiffs = coactB - coactA;
                % Does this need to be normalized somehow? Probably... by max?
                % Is this question also answered with a correlation of the
                % entire time series?
                
                % This doesn't really work for binned, because cell could be active on the lap but miss the bin
                coactDiffsH = coactDiffs(cellsActive,:);
                coactDiffsH = coactDiffsH(:,cellsActive);
                
                uniquePairs = logical(triu(ones(sum(cellsActive)),1));
                
                switch groupNum(mouseI)
                    case 1
                        oneEnvCoactChange{condH} = [oneEnvCoactChange{condH}; coactDiffsH(uniquePairs)];
                    case 2
                        twoEnvCoactChange{condH} = [twoEnvCoactChange{condH}; coactDiffsH(uniquePairs)];
                        
                end
                
                
                end
                
            end
        end
    end
end
           
figure; 
for condI = 1:4
    subplot(2,4,condI); histogram(oneEnvCoactChange{condI}); xlim([-7.5 7.5])
    subplot(2,4,condI+4); histogram(twoEnvCoactChange{condI}); xlim([-7.5 7.5])
end

figure;
for condI = 1:4
    subplot(1,4,condI)
    [f,x] = ecdf(oneEnvCoactChange{condI});
    plot(x,f,'Color',groupColors{1})
    hold on
    [f,x] = ecdf(twoEnvCoactChange{condI});
    plot(x,f,'Color',groupColors{2})
    [~,p] = kstest2(oneEnvCoactChange{condI},twoEnvCoactChange{condI});
    title(['p = ' num2str(p)])
end
    

                
% This section runs on the simple correlation, no lags
edgeThreshes = [0:0.05:0.35];
nEdgeThreshes = numel(edgeThreshes);

dealHere = cell(nEdgeThreshes,1); 
oneEnvTcorrs = cell(9,1);
twoEnvTcorrs = cell(9,1);
oneEnvNcorrEdges = cell(9,1); [oneEnvNcorrEdges{:}] = deal(cell(nEdgeThreshes,1));
oneEnvPctCorrEdges = cell(9,1); [oneEnvPctCorrEdges{:}] = deal(cell(nEdgeThreshes,1));
twoEnvNcorrEdges = cell(9,1); [twoEnvNcorrEdges{:}] = deal(cell(nEdgeThreshes,1));
twoEnvPctCorrEdges = cell(9,1); [twoEnvPctCorrEdges{:}] = deal(cell(nEdgeThreshes,1));                        
oneEnvNcomps = cellAndDeal([9, 1],dealHere);
oneEnvPctComps = cellAndDeal([9, 1],dealHere);
oneEnvCompPctSizes = cellAndDeal([9, 1],dealHere);
twoEnvNcomps = cellAndDeal([9, 1],dealHere);
twoEnvPctComps = cellAndDeal([9, 1],dealHere);
twoEnvCompPctSizes = cellAndDeal([9, 1],dealHere);
oneEnvPctCellsInComp = cellAndDeal([9, 1],dealHere);
twoEnvPctCellsInComp = cellAndDeal([9, 1],dealHere);
for mouseI = 1:numMice
    corrsBlank = zeros(numCells(mouseI));
    
    % Distribution of corrs, edges at each edge threshold
    for sessI = 1:9 %sessJ = 1:numel(daysHere)
        %if any(any(temporalCorrsR{mouseI}{sessI}))
        if any(daysHere == sessI)
            %sessI = daysHere(sessJ);
            % First, build a correlation matrix out of the pairwise corrs
            crossCorrMat = corrsBlank;
            [cellPairsInds] = sub2ind([1 1]*numCells(mouseI),cellPairsUsed{mouseI}{sessI}(:,1),cellPairsUsed{mouseI}{sessI}(:,2));
            [cellPairsIndss] = sub2ind([1 1]*numCells(mouseI),cellPairsUsed{mouseI}{sessI}(:,2),cellPairsUsed{mouseI}{sessI}(:,1));
            crossCorrMat(cellPairsInds) = temporalCorrsR{mouseI}{sessI};
            crossCorrMat(cellPairsIndss) = temporalCorrsR{mouseI}{sessI};
            
            cellsUseHere = dayUseAll{mouseI}(:,sessI);
            cellPairsUse = cellsUseHere(:) & cellsUseHere(:)'; % To index into our big corr matrix
            
            corrsHere = crossCorrMat(cellPairsUse);
            
            switch groupNum(mouseI)
                case 1
                    oneEnvTcorrs{sessI} = [oneEnvTcorrs{sessI}; corrsHere];
                case 2
                    twoEnvTcorrs{sessI} = [twoEnvTcorrs{sessI}; corrsHere];
            end
            
            % Threshold the correlation matrix as a "significant" correlation
            % Could also take top x % of correlation scores...
            for edgeI = 1:nEdgeThreshes
                edgeThresh = edgeThreshes(edgeI);
                corrEdges = crossCorrMat > edgeThresh;
                nCorrEdges = sum(corrEdges,2);
                pctCorrEdges = nCorrEdges / sum(cellsUseHere);
                
                G = graph(corrEdges);
                [graphBins,graphBinSizes] = conncomp(G);
                compsOverOne = graphBinSizes > 1; % Connected components with more than 1 member
                nConnComps = sum(graphBinSizes > 1);
                connCompSizes = graphBinSizes(compsOverOne); % Sizes of connected components greater than 1
                
                theseBinSizes = graphBinSizes(graphBins); % The size of the bin this cell is part of
                %pctCellsInConnComp{groupNum(mouseI)(edgeI,sessI) = sum(theseBinSizes > 1) / numel(theseBinSizes);
                %meanConnCompSizes = mean(connCompSizes);
                
                % unrelated note: would be good to go back to the lags with
                % zero padding and visualize that to make sure it was run
                % right
                
                switch groupNum(mouseI)
                    case 1
                        oneEnvNcorrEdges{sessI}{edgeI} = [oneEnvNcorrEdges{sessI}{edgeI}; nCorrEdges(cellsUseHere)];
                        oneEnvPctCorrEdges{sessI}{edgeI} = [oneEnvPctCorrEdges{sessI}{edgeI}; pctCorrEdges(cellsUseHere)];
                        oneEnvNcomps{sessI}{edgeI} = [oneEnvNcomps{sessI}{edgeI}; nConnComps];
                        % number of comps as pct of cells here
                        oneEnvPctComps{sessI}{edgeI} = [oneEnvPctComps{sessI}{edgeI}; nConnComps/sum(cellsUseHere)];
                        % Sizes of connComps as pct of cells here
                        oneEnvCompPctSizes{sessI}{edgeI} = [oneEnvCompPctSizes{sessI}{edgeI}; connCompSizes(:)/sum(cellsUseHere)]; %As pct of cells here
                        % percent of active cells in a comp
                        oneEnvPctCellsInComp{sessI}{edgeI} = [oneEnvPctCellsInComp{sessI}{edgeI}; sum(theseBinSizes > 1) / sum(cellsUseHere)];
                        
                        %if (connCompSizes(:)/sum(cellsUseHere)) ~= (sum(theseBinSizes > 1) / sum(cellsUseHere))
                        %    disp('pop pop')
                        %    keyboard
                        %end
                            
                    case 2
                        twoEnvNcorrEdges{sessI}{edgeI} = [twoEnvNcorrEdges{sessI}{edgeI}; nCorrEdges(cellsUseHere)];
                        twoEnvPctCorrEdges{sessI}{edgeI} = [twoEnvPctCorrEdges{sessI}{edgeI}; pctCorrEdges(cellsUseHere)];
                        twoEnvNcomps{sessI}{edgeI} = [twoEnvNcomps{sessI}{edgeI}; nConnComps];
                        twoEnvPctComps{sessI}{edgeI} = [twoEnvPctComps{sessI}{edgeI}; nConnComps/sum(cellsUseHere)];
                        twoEnvCompPctSizes{sessI}{edgeI} = [twoEnvCompPctSizes{sessI}{edgeI}; connCompSizes(:)/sum(cellsUseHere)];
                        twoEnvPctCellsInComp{sessI}{edgeI} = [twoEnvPctCellsInComp{sessI}{edgeI}; sum(theseBinSizes > 1) / sum(cellsUseHere)];
                end
            end
            
        end
    end
end

figure;
for sessJ = 1:numel(daysHere)
    sessI = daysHere(sessJ);
    subplot(2,numel(daysHere),sessJ)
    
    for edgeI = 4:nEdgeThreshes
        datH = oneEnvPctComps{sessI}{edgeI};
        plot(edgeThreshes(edgeI)*ones(size(datH)),datH,'.')
        hold on
    end
    title(['Day ' num2str(sessI)])
    
    if sessJ == 1; ylabel('nComps / cellsActive'); end
    
    subplot(2,numel(daysHere),sessJ+numel(daysHere))
    
    for edgeI = 4:nEdgeThreshes
        datH = twoEnvPctComps{sessI}{edgeI};
        plot(edgeThreshes(edgeI)*ones(size(datH)),datH,'.')
        hold on
    end
    if sessJ == 1; ylabel('nComps / cellsActive'); end
    xlabel('Corr Edge Thresh')
end
suptitleSL(' number of comps as pct of cells here (xxxEnvPctComps)')

figure;
for sessJ = 1:numel(daysHere)
    sessI = daysHere(sessJ);
    subplot(2,numel(daysHere),sessJ)
    
    for edgeI = 4:nEdgeThreshes
        datH = oneEnvPctCellsInComp{sessI}{edgeI};
        plot(edgeThreshes(edgeI)*ones(size(datH)),datH,'.')
        hold on
    end
    title(['Day ' num2str(sessI)])
    
    if sessJ == 1; ylabel('cellsInComp / cellsActive'); end
    
    subplot(2,numel(daysHere),sessJ+numel(daysHere))
    
    for edgeI = 4:nEdgeThreshes
        datH = twoEnvPctCellsInComp{sessI}{edgeI};
        plot(edgeThreshes(edgeI)*ones(size(datH)),datH,'.')
        hold on
    end
    if sessJ == 1; ylabel('cellsInComp / cellsActive'); end
    xlabel('Corr Edge Thresh')
end
suptitleSL(' pact active cells in a comt (xxxEnvPctCellsInComp)')

figure;
for edgeI = 1:nEdgeThreshes
    subplot(1,nEdgeThreshes,edgeI)
    datH = [];
    datJ = [];
    for sessJ = 1:numel(daysHere)
        sessI = daysHere(sessJ);
        datH = [datH; oneEnvPctCellsInComp{sessI}{edgeI}];
        datJ = [datJ; twoEnvPctCellsInComp{sessI}{edgeI}];
    end
    
    plot(1*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{1})
    hold on
    plot(2*ones(size(datJ)),datJ,'.','MarkerEdgeColor',groupColors{2})
    
    ylabel('pct cellsInComp / cellsActive')
    title(['Thresh = ' num2str(edgeThreshes(edgeI))])
    xlim([0.9 2.1])
    ylim([0 1.05])
end


% Across day pairs, among cells active both days:
% - number of cells that were in a connected comp, now are not
% - change in comp sizes among just these cells
% - are each pair of cells still in a comp togehter, are cells that weren't
% now in a comp together

function  (corrs, cellPairsUsed, dayPairsHere, corrs, 
for mouseI = 1:numMice
    corrsBlank = zeros(numCells(mouseI));
    
    for dpH = 1:size(dayPairsHere,1)
        
        sessA = dayPairsHere(dpH,1);
        [cellPairsInds] = sub2ind([1 1]*numCells(mouseI),cellPairsUsed{mouseI}{sessA}(:,1),cellPairsUsed{mouseI}{sessA}(:,2));
        [cellPairsIndss] = sub2ind([1 1]*numCells(mouseI),cellPairsUsed{mouseI}{sessA}(:,2),cellPairsUsed{mouseI}{sessA}(:,1));
        crossCorrMatA = corrsBlank;
        crossCorrMatA(cellPairsInds) = temporalCorrsR{mouseI}{sessA};
        crossCorrMatA(cellPairsIndss) = temporalCorrsR{mouseI}{sessA};
        
        sessB = dayPairsHere(dpH,2);
        [cellPairsInds] = sub2ind([1 1]*numCells(mouseI),cellPairsUsed{mouseI}{sessB}(:,1),cellPairsUsed{mouseI}{sessB}(:,2));
        [cellPairsIndss] = sub2ind([1 1]*numCells(mouseI),cellPairsUsed{mouseI}{sessB}(:,2),cellPairsUsed{mouseI}{sessB}(:,1));
        crossCorrMatB = corrsBlank;
        crossCorrMatB(cellPairsInds) = temporalCorrsR{mouseI}{sessB};
        crossCorrMatB(cellPairsIndss) = temporalCorrsR{mouseI}{sessB};
            
        cellsUseHereA = dayUseAll{mouseI}(:,sessA);
        cellPairsUseA = cellsUseHereA(:) & cellsUseHereA(:)'; % To index into our big corr matrix
        cellsUseHereB = dayUseAll{mouseI}(:,sessB);
        cellPairsUseB = cellsUseHereB(:) & cellsUseHereB(:)'; % To index into our big corr matrix
        
        %corrsHere = crossCorrMat(cellPairsUseA & cellPairsUseB);
        
        cellsBothDays = dayUseAll{mouseI}(:,sessA) & dayUseAll{mouseI}(:,sessB); 
        cellPairsUseAB = cellsBothDays(:) & cellsBothDays(:)';
        cellPairsUseABupper = logical(cellPairsUseAB .* triu(true(numCells(mouseI)),1));
        numCellPairsAB = sum(sum(cellPairsUseABupper));
        
        % Did pairs of cells change their status of being above corr threshold
        for edgeI = 1:nEdgeThreshes
            edgeThresh = edgeThreshes(edgeI);
            corrEdgesA = crossCorrMatA > edgeThresh;
            corrEdgesB = crossCorrMatB > edgeThresh;
            
            pairsEverCorrelated = corrEdgesA | corrEdgesB;
            pairsStillCorrelated = corrEdgesA & corrEdgesB;
            pairsBecomeUncorr = corrEdgesA & ~corrEdgesB;
            pairsBecomeCorr = ~corrEdgesA & corrEdgesB;
            pairsStillUncorrelated = ~corrEdgesA & ~corrEdgesB;
            
            pairsEverCorrelated = pairsEverCorrelated.*cellPairsUseABupper;
            pairsStillCorrelated = pairsStillCorrelated.*cellPairsUseABupper;
            pairsBecomeUncorr = pairsBecomeUncorr.*cellPairsUseABupper;
            pairsBecomeCorr = pairsBecomeCorr.*cellPairsUseABupper;
            pairsStillUncorrelated = pairsStillUncorrelated.*cellPairsUseABupper;
            
            if sum(sum(cellPairsUseABupper)) ~= ...
            sum(sum(pairsStillCorrelated)) + sum(sum(pairsBecomeUncorr)) + sum(sum(pairsBecomeCorr)) + sum(sum(pairsStillUncorrelated))
                disp('cell pairs indexing error')
                keyboard
            end
            
            % Should we also evaluate graph/cluster/ensembles?
            
            % Aggregate how?...
            numPairsStillCorr = sum(sum(pairsStillCorrelated));
            numPairsBecomeUncorr = sum(sum(pairsBecomeUncorr));
            numPairsBecomeCorr = sum(sum(pairsBecomeCorr));
            numPairsStillUncorr = sum(sum(pairsStillUncorrelated));
            
            numCellPairsEverCorr = sum(sum(pairsEverCorrelated)); % Something still a bit wrong here...
            denomH = sum(sum(cellPairsUseABupper));
            %denomH = numCellPairsEverCorr;
            switch groupNum(mouseI)
                case 1
                    oneEnvPctStillCorr{dpH}(mouseI,edgeI) = numPairsStillCorr / denomH;
                    oneEnvPctStillUncorr{dpH}(mouseI,edgeI) = numPairsStillUncorr / denomH;
                    oneEnvPctBecomeUncorr{dpH}(mouseI,edgeI) = numPairsBecomeUncorr / denomH;
                    oneEnvPctBecomeCorr{dpH}(mouseI,edgeI) = numPairsBecomeCorr / denomH;
                case 2
                    twoEnvPctStillCorr{dpH}(mouseI-3,edgeI) = numPairsStillCorr / denomH;
                    twoEnvPctStillUncorr{dpH}(mouseI-3,edgeI) = numPairsStillUncorr / denomH;
                    twoEnvPctBecomeUncorr{dpH}(mouseI-3,edgeI) = numPairsBecomeUncorr / denomH;
                    twoEnvPctBecomeCorr{dpH}(mouseI-3,edgeI) = numPairsBecomeCorr / denomH;
            end
            
            
        end
    end
end

oneEnvPctStillCorrAgg = cell(nEdgeThreshes,1);
oneEnvPctBecomeCorrAgg = cell(nEdgeThreshes,1);
oneEnvPctBecomeUncorrAgg = cell(nEdgeThreshes,1);
oneEnvPctStillUncorrAgg = cell(nEdgeThreshes,1);
twoEnvPctStillCorrAgg = cell(nEdgeThreshes,1);
twoEnvPctBecomeCorrAgg = cell(nEdgeThreshes,1);
twoEnvPctBecomeUncorrAgg = cell(nEdgeThreshes,1);
twoEnvPctStillUncorrAgg = cell(nEdgeThreshes,1);
for edgeI = 1:nEdgeThreshes
    for dpH = 1:size(dayPairsHere,1)
        oneEnvPctStillCorrAgg{edgeI} = [oneEnvPctStillCorrAgg{edgeI}; oneEnvPctStillCorr{dpH}(:,edgeI)];
        oneEnvPctBecomeCorrAgg{edgeI} = [oneEnvPctBecomeCorrAgg{edgeI}; oneEnvPctBecomeCorr{dpH}(:,edgeI)];
        oneEnvPctBecomeUncorrAgg{edgeI} = [oneEnvPctBecomeUncorrAgg{edgeI}; oneEnvPctBecomeUncorr{dpH}(:,edgeI)];
        oneEnvPctStillUncorrAgg{edgeI} = [oneEnvPctStillUncorrAgg{edgeI}; oneEnvPctStillUncorr{dpH}(:,edgeI)];
        
        twoEnvPctStillCorrAgg{edgeI} = [twoEnvPctStillCorrAgg{edgeI}; twoEnvPctStillCorr{dpH}(:,edgeI)];
        twoEnvPctBecomeCorrAgg{edgeI} = [twoEnvPctBecomeCorrAgg{edgeI}; twoEnvPctBecomeCorr{dpH}(:,edgeI)];
        twoEnvPctBecomeUncorrAgg{edgeI} = [twoEnvPctBecomeUncorrAgg{edgeI}; twoEnvPctBecomeUncorr{dpH}(:,edgeI)];
        twoEnvPctStillUncorrAgg{edgeI} = [twoEnvPctStillUncorrAgg{edgeI}; twoEnvPctStillUncorr{dpH}(:,edgeI)];
    end
end

xlabs = {'C-C','U-C','C-U'};
figure;
for edgeI = 1:nEdgeThreshes
    subplot(1,nEdgeThreshes,edgeI)
    
    datH = oneEnvPctStillCorrAgg{edgeI};
    plot(0.9*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{1})
    hold on
    datJ = twoEnvPctStillCorrAgg{edgeI};
    plot(1.1*ones(size(datJ)),datJ,'.','MarkerEdgeColor',groupColors{2})
    [hh,pp] = ranksum(datH,datJ);
    
    datH = oneEnvPctBecomeCorrAgg{edgeI};
    plot(1.9*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{1})
    hold on
    datJ = twoEnvPctBecomeCorrAgg{edgeI};
    plot(2.1*ones(size(datJ)),datJ,'.','MarkerEdgeColor',groupColors{2})
    [hh,pp] = ranksum(datH,datJ);
    
    datH = oneEnvPctBecomeUncorrAgg{edgeI};
    plot(2.9*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{1})
    hold on
    datJ = twoEnvPctBecomeUncorrAgg{edgeI};
    plot(3.1*ones(size(datJ)),datJ,'.','MarkerEdgeColor',groupColors{2})
    [hh,pp] = ranksum(datH,datJ);
    
    xlabel('Corr category')
    ylabel('Pct')
    title(['thresh=' num2str(edgeThreshes(edgeI))])
    aa = gca;
    aa.XTick = [1 2 3];
    aa.XTickLabel = xlabs;
    xlim([0.8 3.2])
end
suptitleSL('Pct cell pairs correlated across day pairs 1:3 vs. 7:9')
    
    
        

figure;
%xlabs = {'C-C','U-C','C-U','U-U'};
xlabs = {'C-C','U-C','C-U'};
for dpH = 1:size(dayPairsHere,1)
    for edgeI = 4:nEdgeThreshes
        subplot(2,numel(4:nEdgeThreshes),edgeI - 3)
        xlabel('Corr category')
        ylabel('Pct')
        title(['One Env, th=' num2str(edgeThreshes(edgeI))])
        
        datH = oneEnvPctStillCorr{dpH}(:,edgeI);
        plot(1*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{1})
        hold on
        datH = oneEnvPctBecomeCorr{dpH}(:,edgeI);
        plot(2*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{1})
        hold on
        datH = oneEnvPctBecomeUncorr{dpH}(:,edgeI);
        plot(3*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{1})
        %hold on
        %datH = oneEnvPctStillUncorr{dpH}(:,edgeI);
        %plot(4*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{1})
        
        aa = gca; aa.XTickLabel = xlabs;
        xlim([0.9 3.1])
        
        subplot(2,numel(4:nEdgeThreshes),edgeI+numel(4:nEdgeThreshes)-3)
        xlabel('Corr category')
        ylabel('Pct')
        title(['Two Env, th=' num2str(edgeThreshes(edgeI))])
        
        datH = twoEnvPctStillCorr{dpH}(:,edgeI);
        plot(1*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{2})
        hold on
        datH = twoEnvPctBecomeCorr{dpH}(:,edgeI);
        plot(2*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{2})
        hold on
        datH = twoEnvPctBecomeUncorr{dpH}(:,edgeI);
        plot(3*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{2})
        %hold on
        %datH = twoEnvPctStillUncorr{dpH}(:,edgeI);
        %plot(4*ones(size(datH)),datH,'.','MarkerEdgeColor',groupColors{2})
        
        aa = gca; aa.XTickLabel = xlabs;
        %xlim([0.9 4.1])
        xlim([0.9 3.1])
    end
end
suptitleSL('Need to aggregate these by category, across dayPairs, ranksum test')
        
for sessJ = 1:numel(daysHere)
    sessI = daysHere(sessJ);
    subplot(2,numel(daysHere),sessJ)
    
    for edgeI = 4:nEdgeThreshes
        datH = oneEnvPctComps{sessI}{edgeI};
        plot(edgeThreshes(edgeI)*ones(size(datH)),datH,'.')
        hold on
    end
    title(['Day ' num2str(sessI)])
    
    if sessJ == 1; ylabel('nComps / cellsActive'); end
    
    subplot(2,numel(daysHere),sessJ+numel(daysHere))
    
    for edgeI = 4:nEdgeThreshes
        datH = twoEnvPctComps{sessI}{edgeI};
        plot(edgeThreshes(edgeI)*ones(size(datH)),datH,'.')
        hold on
    end
    if sessJ == 1; ylabel('nComps / cellsActive'); end
    xlabel('Corr Edge Thresh')
end
suptitleSL(' number of comps as pct of cells here (xxxEnvPctComps)')


figure;
for sessJ = 1:numel(daysHere)
    sessI = daysHere(sessJ);
    
    subplot(2,numel(daysHere),sessJ)
    histogram(oneEnvTcorrs{sessI},[-1.05:0.1:1.05],'FaceColor',groupColors{1})
    title(['OneMaze tCorrs day ' num2str(sessI)])
    xlabel('Pearson R')
    
    subplot(2,numel(daysHere),sessJ+numel(daysHere))
    histogram(twoEnvTcorrs{sessI},[-1.05:0.1:1.05],'FaceColor',groupColors{2})
    title(['TwoMaze tCorrs day ' num2str(sessI)])
    xlabel('Pearson R')
    
    ppp = ranksum(oneEnvTcorrs{sessI},twoEnvTcorrs{sessI});
    [~,pppks] = kstest2(oneEnvTcorrs{sessI},twoEnvTcorrs{sessI});
    disp(['day ' num2str(sessI) ' ranksum p = ' num2str(ppp) ', ks p = ' num2str(pppks)])
end
suptitleSL('Distribution of corrs each day')

oneEnvTcorrsBefore = cell2mat(oneEnvTcorrs(1:3));
oneEnvTcorrsAfter = cell2mat(oneEnvTcorrs(7:9));
twoEnvTcorrsBefore = cell2mat(twoEnvTcorrs(1:3));
twoEnvTcorrsAfter = cell2mat(twoEnvTcorrs(7:9));
figure; 
subplot(2,2,1)
histogram(oneEnvTcorrsBefore,[-1.05:0.1:1.05],'FaceColor',groupColors{1})
subplot(2,2,3)
histogram(twoEnvTcorrsBefore,[-1.05:0.1:1.05],'FaceColor',groupColors{2})
subplot(2,2,2)
histogram(oneEnvTcorrsAfter,[-1.05:0.1:1.05],'FaceColor',groupColors{1})
subplot(2,2,4)
histogram(twoEnvTcorrsAfter,[-1.05:0.1:1.05],'FaceColor',groupColors{2})
ppp = ranksum(oneEnvTcorrsBefore,twoEnvTcorrsBefore);
[~,pppks] = kstest2(oneEnvTcorrsBefore,twoEnvTcorrsBefore);
disp(['days 1:3 ranksum p = ' num2str(ppp) ', ks p = ' num2str(pppks)])
ppp = ranksum(oneEnvTcorrsAfter,twoEnvTcorrsAfter);
[~,pppks] = kstest2(oneEnvTcorrsAfter,twoEnvTcorrsAfter);
disp(['days 7:9 ranksum p = ' num2str(ppp) ', ks p = ' num2str(pppks)])
suptitleSL('Distribution of corrs days 1:3, 7:9')

for edgeI = 1:nEdgeThreshes
    figure;
    for sessJ = 1:numel(daysHere)
        sessI = daysHere(sessJ);
        subplot(2,numel(daysHere),sessJ)
        %histogram(oneEnvNcorrEdges{sessI}{edgeI},'FaceColor',groupColors{1})
        histogram(oneEnvPctCorrEdges{sessI}{edgeI},'FaceColor',groupColors{1})
        
        subplot(2,numel(daysHere),sessJ+numel(daysHere))
        %histogram(twoEnvNcorrEdges{sessI}{edgeI},'FaceColor',groupColors{2})
        histogram(twoEnvPctCorrEdges{sessI}{edgeI},'FaceColor',groupColors{2})
        
        %ppp = ranksum(oneEnvNcorrEdges{sessI}{edgeI},twoEnvNcorrEdges{sessI}{edgeI});
        %[~,pppKS] = kstest2(oneEnvNcorrEdges{sessI}{edgeI},twoEnvNcorrEdges{sessI}{edgeI});
        ppp = ranksum(oneEnvPctCorrEdges{sessI}{edgeI},twoEnvPctCorrEdges{sessI}{edgeI});
        [~,pppKS] = kstest2(oneEnvPctCorrEdges{sessI}{edgeI},twoEnvPctCorrEdges{sessI}{edgeI});
        title([num2str(ppp) ' ' num2str(pppKS)])
    end
    suptitleSL(['edgeThreshold ' num2str(edgeThreshes(edgeI))])
end

oneEnvTcorrChanges = cell(size(dayPairsHere,1),1);
oneEnvNcorrEdgeChanges = cell(size(dayPairsHere,1),1); [oneEnvNcorrEdgeChanges{:}] = deal(cell(nEdgeThreshes,1));
oneEnvPctCorrEdgeChanges = cell(size(dayPairsHere,1),1); [oneEnvPctCorrEdgeChanges{:}] = deal(cell(nEdgeThreshes,1));
twoEnvTcorrChanges = cell(size(dayPairsHere,1),1);
twoEnvNcorrEdgeChanges = cell(size(dayPairsHere,1),1); [twoEnvNcorrEdgeChanges{:}] = deal(cell(nEdgeThreshes,1));
twoEnvPctCorrEdgeChanges = cell(size(dayPairsHere,1),1); [twoEnvPctCorrEdgeChanges{:}] = deal(cell(nEdgeThreshes,1));


for mouseI = 1:numMice
    corrsBlank = zeros(numCells(mouseI));
    
    % Distribution of corr changes
    for dpI = 1:size(dayPairsHere,1)
        dayA = dayPairsHere(dpI,1);
        dayB = dayPairsHere(dpI,2);
        if any(any(cellPairsUsed{mouseI}{dayA})) && any(any(cellPairsUsed{mouseI}{dayB}))
            crossCorrMatA = corrsBlank;
            [cellPairsInds] = sub2ind([1 1]*numCells(mouseI),cellPairsUsed{mouseI}{dayA}(:,1),cellPairsUsed{mouseI}{dayA}(:,2));
            [cellPairsIndss] = sub2ind([1 1]*numCells(mouseI),cellPairsUsed{mouseI}{dayA}(:,2),cellPairsUsed{mouseI}{dayA}(:,1));
            crossCorrMatA(cellPairsInds) = temporalCorrsR{mouseI}{dayA};
            crossCorrMatA(cellPairsIndss) = temporalCorrsR{mouseI}{dayA};
            
            crossCorrMatB = corrsBlank;
            [cellPairsInds] = sub2ind([1 1]*numCells(mouseI),cellPairsUsed{mouseI}{dayB}(:,1),cellPairsUsed{mouseI}{dayB}(:,2));
            [cellPairsIndss] = sub2ind([1 1]*numCells(mouseI),cellPairsUsed{mouseI}{dayB}(:,2),cellPairsUsed{mouseI}{dayB}(:,1));
            crossCorrMatB(cellPairsInds) = temporalCorrsR{mouseI}{dayB};
            crossCorrMatB(cellPairsIndss) = temporalCorrsR{mouseI}{dayB};
            
            cellsUseHere = dayUseAll{mouseI}(:,dayA) & dayUseAll{mouseI}(:,dayB);
            cellPairsUse = cellsUseHere(:) & cellsUseHere(:)';
            
            % Distribution of all corr changes
            corrChanges = crossCorrMatB(cellPairsUse) -  crossCorrMatA(cellPairsUse);
            
            switch groupNum(mouseI)
                case 1
                    oneEnvTcorrChanges{dpI} = [oneEnvTcorrChanges{dpI}; corrChanges];
                case 2
                    twoEnvTcorrChanges{dpI} = [twoEnvTcorrChanges{dpI}; corrChanges];
            end
            
            for edgeI = 1:numel(edgeThreshes)
                edgeThresh = edgeThreshes(edgeI);
                
                % Edge changes
                crossCorrEdgesA = crossCorrMatA > edgeThresh;
                crossCorrEdgesB = crossCorrMatB > edgeThresh;

                nEdgesA = sum(crossCorrEdgesA,2);
                nEdgesB = sum(crossCorrEdgesB,2);
                nEdgeChanges = nEdgesB - nEdgesA;
                pctEdgesA = nEdgesA / sum(cellsUseHere);
                pctEdgesB = nEdgesB / sum(cellsUseHere);
                pctEdgeChanges = pctEdgesB - pctEdgesA;

                switch groupNum(mouseI)
                    case 1
                        oneEnvNcorrEdgeChanges{dpI}{edgeI} = [oneEnvNcorrEdgeChanges{dpI}{edgeI}; nEdgeChanges(cellsUseHere)];
                        oneEnvPctCorrEdgeChanges{dpI}{edgeI} = [oneEnvPctCorrEdgeChanges{dpI}{edgeI}; pctEdgeChanges(cellsUseHere)];
                    case 2
                        twoEnvNcorrEdgeChanges{dpI}{edgeI} = [twoEnvNcorrEdgeChanges{dpI}{edgeI}; nEdgeChanges(cellsUseHere)];
                        twoEnvPctCorrEdgeChanges{dpI}{edgeI} = [twoEnvPctCorrEdgeChanges{dpI}{edgeI}; pctEdgeChanges(cellsUseHere)];
                end

            end
            
            % Other metrics from gava, chokanathan
            
        end
    end
end
            
oneEnvNedgeChanges = cell(numel(edgeThreshes),1);
twoEnvNedgeChanges = cell(numel(edgeThreshes),1);
oneEnvPctEdgeChanges = cell(numel(edgeThreshes),1);
twoEnvPctEdgeChanges = cell(numel(edgeThreshes),1);
for edgeI = 1:numel(edgeThreshes)
    for dpI = 1:size(dayPairsHere,1)
        oneEnvNedgeChanges{edgeI} = [oneEnvNedgeChanges{edgeI}; oneEnvNcorrEdgeChanges{dpI}{edgeI}];
        twoEnvNedgeChanges{edgeI} = [twoEnvNedgeChanges{edgeI}; twoEnvNcorrEdgeChanges{dpI}{edgeI}];
        oneEnvPctEdgeChanges{edgeI} = [oneEnvPctEdgeChanges{edgeI}; oneEnvNcorrEdgeChanges{dpI}{edgeI}];
        twoEnvPctEdgeChanges{edgeI} = [twoEnvPctEdgeChanges{edgeI}; twoEnvNcorrEdgeChanges{dpI}{edgeI}];
    end
end

for edgeI = 1:nEdgeThreshes
    ppp = ranksum(oneEnvNedgeChanges{edgeI},twoEnvNedgeChanges{edgeI});
    [~,pppKS] = kstest2(oneEnvNedgeChanges{edgeI},twoEnvNedgeChanges{edgeI});
    disp(['Number: Edge ' num2str(edgeThreshes(edgeI)) ': ranksum = ' num2str(ppp) ', ks = ' num2str(pppKS)])
    ppp = ranksum(oneEnvPctEdgeChanges{edgeI},twoEnvPctEdgeChanges{edgeI});
    [~,pppKS] = kstest2(oneEnvPctEdgeChanges{edgeI},twoEnvPctEdgeChanges{edgeI});
    disp(['Pct: Edge ' num2str(edgeThreshes(edgeI)) ': ranksum = ' num2str(ppp) ', ks = ' num2str(pppKS)])
end
        
        
        
        