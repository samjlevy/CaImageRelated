function [meanCurves, ciCurves, shuffTMap_unsmoothed, shuffTMap_gauss]=...
    PlaceTuningCurveLin(base_path, trialbytrial, aboveThresh,  xlims, cmperbin, minspeed, numShuffles, dimShuffle)

%numSess = size(aboveThresh{1,1},2);
numCells = length(trialbytrial(1).trialPSAbool{1,1});
%numConds = length(trialbytrial);
nBins = ceil(abs(diff(xlims))/cmperbin);

resol = 1;
p = ProgressBar(100/resol);
update_inc = round(numShuffles/(100/resol));
shuffTMap_gauss = cell(1,numShuffles);
shuffTMap_unsmoothed = cell(1,numShuffles);
total = 0;
for ts = 1:numShuffles
    shuffledTBT = ShuffleTrialsAcrossConditions(trialbytrial,dimShuffle);
    [~, ~, ~, shuffTMap_unsmoothed{ts}, ~, shuffTMap_gauss{ts}] = ...
        PFsLinTrialbyTrial(shuffledTBT,aboveThresh, xlims, cmperbin, minspeed, 0, base_path);

    total=total+1;
    if round(total/update_inc) == (total/update_inc) 
        p.progress;
    end
end
p.stop;

curves = cell(numCells,4);
for condType = 1:4
    for st = 1:numShuffles
        for tc = 1:numCells
            if ~isempty(shuffTMap_gauss{st}{tc,condType})
                curves{tc,condType}(st,:) = shuffTMap_gauss{st}{tc,condType};
                %curves{tc,condType}(isnan(curves{tc,condType})) = 0;
            end
        end
    end
end
        
idxci = round([0.975;0.025].*numShuffles);
     
meanCurves = cell(numCells,4);
%sortedCurves = cell(numCells,4);
ciCurves = cell(numCells,4); 
for tc = 1:numCells
    for condType = 1:4
        if ~isempty(curves{tc,condType})
            meanCurves{tc,condType} = nanmean(curves{tc,condType},1);
            sortedCurves = sort(curves{tc,condType},1);
            %ciCurves{tc,condType} = sortedCurves(idxci,:);
            ciCurves{tc,condType} = zeros(2,nBins);
            for binN = 1:nBins
                binStuff = sortedCurves(:,binN);
                binStuff = binStuff(~isnan(binStuff));
                idxci = round([0.975;0.025].*length(binStuff));
                if any(idxci)
                    ciCurves{tc,condType}(1:2,binN) = binStuff(idxci,:);
                end
            end    
                
        end
    end
end

save(fullfile(base_path,'tuningCurves.mat'),'meanCurves','ciCurves','shuffTMap_gauss','shuffTMap_unsmoothed')
disp('saved tuningCurves.mat')

end

            
            
            
            
            
            
            
            
            