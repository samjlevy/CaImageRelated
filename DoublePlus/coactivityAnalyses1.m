% Change in coactivity scores
% Do cells that leave an ensemble join another? End up correlated with that
% ensemble?
% Ensemble reorganization during place days?

dayPairs = GetAllCombs(1:3,7:9);
condHere = [1 2 3 4];

% X-corr of timeseries
maxLag = 20;
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
        
        if any(any(psaHere))
            % cross corrs, limited by some amount of lags?
            cellsActive = sum(dayUse{mouseI}(:,sessI,condHere),3)>0;
            
            cellPairsHere = nchoosek(find(cellsActive),2);
            numCellPairs = size(cellPairsHere,1);
            
            r = zeros(maxLag*2+1,numCellPairs);
            %lags = zeros(numCellPairs,maxLag*2+1);
            tic
            for cpI = 1:size(cellPairsHere,1)
                %[r(:,cpI),lags] = xcorr(psaHere(cellPairsHere(cpI,1),:)',psaHere(cellPairsHere(cpI,2),:)',maxLag);
                [rr(cpI,1),pp(cpI,1)] = corr(psaHere(cellPairsHere(cpI,1),:)',psaHere(cellPairsHere(cpI,2),:)','type','Pearson');
            end
            toc
            
            %crossCorrs{mouseI}{sessI} = r;
            cellPairsUsed{mouseI}{sessI} = cellPairsHere;
        end
        
        laggedCorrs = nan(size(cellPairsHere,1),maxLag*2+1);
        laggedPvals = nan(size(cellPairsHere,1),maxLag*2+1);
        
        
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
        
        %{
        laggedCorrs(:,maxLag+1) = rr;
            laggedPval(:,maxLag+1) = pp;
            save('mouse1sess1crossCorrs.mat','laggedCorrs','laggedPvals','lagsCheck','cellPairsHere')
            
        %}
    
        crossCorrs{mouseI}{sessI} = laggedCorrs;
        cellPairsUsed{mouseI}{sessI} = cellPairsHere;
        crossCorrPvals{mouseI}{sessI} = laggedPvals;
        
        disp(['Done mouse' num2str(mouseI) ', sess ' num2str(sessI)])
    end
end
try
    save(fullfile(mainFolder,'crossCorrs220127.mat'),'crossCorrs','cellPairsUsed','crossCorrPvals')
catch
    save(fullfile(mainFolder,'crossCorrs220127.mat'),'crossCorrs','cellPairsUsed','crossCorrPvals','-v7.3')
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

    for dpI = 1:size(dayPairs,1)
        dayA = dayPairs(dpI,1);
        dayB = dayPairs(dpI,2);
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
    

                
            