function [rhoSlope,pSpearman,comSlope,pSlope,nTrialsActive] = GetTBTcom(trialbytrial)

numCells = size(trialbytrial(1).trialPSAbool{1},1);

for condI = 1:length(trialbytrial)
    for trialI = 1:numel(trialbytrial(condI).trialsX)
        xHere = trialbytrial(condI).trialsX{trialI};
        yHere = trialbytrial(condI).trialsY{trialI};
        psaHere = trialbytrial(condI).trialPSAbool{trialI};
        pfCOMsX{condI}(:,trialI) = arrayfun(@(x) centerOfMassPts(xHere(psaHere(x,:))),[1:numCells]');
        pfCOMsY{condI}(:,trialI) = arrayfun(@(x) centerOfMassPts(yHere(psaHere(x,:))),[1:numCells]');
    end
end

sessHere = unique(trialbytrial(1).sessID);

rhoSlope = nan(numCells,max(sessHere),length(trialbytrial));
pSpearman = nan(numCells,max(sessHere),length(trialbytrial));
comSlope = nan(numCells,max(sessHere),length(trialbytrial));
intercept = nan(numCells,max(sessHere),length(trialbytrial));
pSlope = nan(numCells,max(sessHere),length(trialbytrial));
nTrialsActive = nan(numCells,max(sessHere),length(trialbytrial));

for condI = 1:length(trialbytrial)
    for sessI = 1:max(sessHere)
        trialsH = trialbytrial(condI).sessID == sessI;
        
        xLaps = trialbytrial(condI).trialsX(trialsH);
        yLaps = trialbytrial(condI).trialsY(trialsH);
        for cellI = 1:numCells
            if sum(~isnan(pfCOMsX{condI}(cellI,trialsH))) >= 3
                % Calculate the slope of the drift (CM/Trial)
                %disp('Got one')
                %keyboard
                switch condI
                    case {1,3}
                        comsHere = pfCOMsY{condI}(cellI,trialsH); comsHere = comsHere(:);
                    case {2,4}
                        comsHere = pfCOMsX{condI}(cellI,trialsH); comsHere = comsHere(:);
                end
                %comsHere = pfCOMs{condI}(cellI,trialsH); comsHere = comsHere(:);
                lapInds = find(~isnan(comsHere)); lapInds = lapInds(:); comsHere = comsHere(lapInds);
                [rhoSlope(cellI,sessI,condI), pSpearman(cellI,sessI,condI)] = corr(lapInds,comsHere,'type','Spearman');
                [comSlope(cellI,sessI,condI), intercept(cellI,sessI,condI), fitLine, ~, pSlope(cellI,sessI,condI), ~] = fitLinRegSL(comsHere, lapInds);
                nTrialsActive(cellI,sessI,condI) = sum(~isnan(pfCOMsX{condI}(cellI,trialsH)));
                %{
                    trialsPSA = cellfun(@(x) x(cellI,:),trialbytrial(condI).trialPSAbool(trialsH),'UniformOutput',false);
                    lapPositions = xLaps; if condI == 1 || condI ==3; lapPositions = yLaps; end
                    SimpleRaster(lapPositions,trialsPSA); hold on;
                    [slope, intercept, fitLine, rr, pSlope, pInt] = fitLinRegSL(lapInds,comsHere);
                    [sortedCOMs,reorderedFitLapInds] = SortAndReorder(fitLine(:,1),fitLine(:,2));
                    plot(sortedCOMs,reorderedFitLapInds,'k')
                 %}
            end
        end
    end
end

