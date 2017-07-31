function PlaceTuningCurveLin(trialbytrial, aboveThresh, nPerms, xlims, cmperbin, xEdges)
 
%Randomly shuffle each trial's spike times or positions?
%Shift whole position vector to preserve temporal autocorrelogram of spiking
 
sessionUse = false(size(aboveThresh{1,1}));
for ss = 1:numConds
    sessionUse = sessionUse + aboveThresh{1,ss}(:,:);
end
sessionUse = sessionUse > 0;

for cellI = 1:numCells
    for condType = 1:4
        lapsUse = logical(sum(trialbytrial(condType).sessID == find(sessionUse(cellI,:)),2));
        theseLaps = find(lapsUse);
        
        for thisLap = 1:length(theseLaps)
            posX = trialbytrial(condType).trialsX{theseLaps(thisLap),1};
            spikeTs = trialbytrial(condType).trialPSAbool{theseLaps(thisLap),1}(cellI,:);
            
            SR=20;
            dx = diff(posX);
            speed = dx*SR;
            %velocity = convtrim(speed,ones(1,2*20))./(2*20);
            good = true(1,length(posX));
            isrunning = good;                                   %Running frames that were not excluded. 
            %isrunning(velocity < minspeed) = false;
            
            [OccMap,RunOccMap,xBin] =...
                MakeOccMapLin(posX,good,isrunning,xEdges);
            [~,~,Lap_gauss(thisLap,:)] = ...
                MakePlacefieldLin(logical(spikeTs),posX,xEdges,RunOccMap,...
                'cmperbin',cmperbin,'smooth',true);
        end
        
        numBins = length(xEdges)-1;
        shuffledRates = zeros(length(theseLaps),numBins,nPerms);
        for thisPerm = 1:nPerms
            offset = randi(length(xEdges)-1);
            shuff = Lap_gauss(:,[offset:numBins 1:offset-1]);
            shuff(isnan(shuff)) = 0;
            shuffledRates(:,:,thisPerm) = shuff;
            shuffleCurves(:,thisPerm) = mean(shuffledRates(:,:,thisPerm),1);
        end

        TMap_test = TMap_gauss{cellI,thisCond}';
        TMap_test(isnan(TMap_test)) = 0;
        smoothfit = fit([1:numBins]',TMap_test,'smoothingspline');
        bins = 1:0.1:numBins;
        smoothed = feval(smoothfit,bins);
        
        
        %{
        posX = [trialbytrial(condType).trialsX{lapsUse,1}];
        spikeTs = [trialbytrial(condType).trialPSAbool{lapsUse,1}];
        spikeTs = spikeTs(cellI,:);
        spikeX = posX(spikeTs);
        
        binStep = 0.5;
        binLedge = xlims(1):cmperbin:(xlims(2)-cmperbin);
        
        for bb = 1:length(binLedge)
            xbin(bb) = sum(posX >= binLedge(bb) & posX <= binLedge(bb) + cmperbin);
            spikebin(bb) = sum(spikeX >= binLedge(bb) & spikeX <= binLedge(bb) + cmperbin);
            rate(bb) = spikebin(bb) / xbin(bb);
        end
        
        permutedPos = zeros(nPerms,length(posX));
        permutedSpike = zeros(nPerms,length(spikeX));
        for thisPerm = 1:nPerms
            offset = rand(1)*(xlims(2) - xlims(1));
            pPos = posX + offset;
            pPos(pPos > xlims(2)) = pPos(pPos > xlims(2)) - (xlims(2) - xlims(1));
            pspikeX = spikeX + offset;
            pspikeX(pspikeX > xlims(2)) = pspikeX(pspikeX > xlims(2)) - (xlims(2) - xlims(1));
            
            permutedPos(thisPerm,:) = pPos;
            permutedSpike(thisPerm,:) = pspikeX;
        end
        %}
        
        %Make tuning curve here
        
        
        
        
    end
end