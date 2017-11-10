function [StudyTestProps, LeftRightProps, spikeCounts] = LookAtSplitters(trialbytrial, xlims, numBins)

sessions = unique(trialbytrial(1).sessID);
numSess = length(sessions);
numCells = length(trialbytrial(1).trialPSAbool{1,1});
numConds = length(trialbytrial);
Conds = GetTBTconds(trialbytrial);

xmin = xlims(1); 
xmax = xlims(2);
binEdges = linspace(xmin,xmax,numBins+1);

blank = zeros(1,numBins);

ss = fieldnames(Conds);

spikeCounts = cell(numCells,4,numSess);
%first get the counts
p = ProgressBar(100);
update_points = round(linspace(1,numCells,101));
update_points = update_points(2:end);
for cellI = 1:numCells
    for tSess = 1:numSess
        for condType = 1:4            
            lapsUseA = logical(trialbytrial(Conds.(ss{condType})(1)).sessID == sessions(tSess));
            lapsUseB = logical(trialbytrial(Conds.(ss{condType})(2)).sessID == sessions(tSess));
            
            if any(lapsUseA) || any(lapsUseB)  
                posXA = [trialbytrial(Conds.(ss{condType})(1)).trialsX{lapsUseA}];
                %posYA = [trialbytrial(Conds.(ss{condType})(1)).trialsY{lapsUseA,1}];
                spikeTsA = [trialbytrial(Conds.(ss{condType})(1)).trialPSAbool{lapsUseA}];
                spikeTsA = spikeTsA(cellI,:);

                posXB = [trialbytrial(Conds.(ss{condType})(2)).trialsX{lapsUseB}];
                %posYB = [trialbytrial(Conds.(ss{condType})(2)).trialsY{lapsUseB,1}];
                spikeTsB = [trialbytrial(Conds.(ss{condType})(2)).trialPSAbool{lapsUseB}];
                spikeTsB = spikeTsB(cellI,:);

                posX = [posXA posXB];
                %posY = [posYA posYB];
                spikeTs = [spikeTsA spikeTsB];

                spikePos = posX(spikeTs);

                spikeCounts{cellI,condType,tSess} = histcounts(spikePos,binEdges);
            else
                spikeCounts{cellI,condType,tSess} = blank;
            end
        end
    end
    
    if sum(update_points==cellI)==1
        p.progress;
    end
end
p.stop;

%now normalize appropriately
condPairs = [1 2; 3 4];
for cellI = 1:numCells
    for tSess = 1:numSess
        countsA = spikeCounts{cellI,condPairs(1,1),tSess};
        countsB = spikeCounts{cellI,condPairs(1,2),tSess};

        countsC = spikeCounts{cellI,condPairs(2,1),tSess};
        countsD = spikeCounts{cellI,condPairs(2,2),tSess};
        
        %sanity check
        if sum(sum([countsA; countsB],1)) ~= sum(sum([countsC; countsD],1))
            disp('bad counting of spike positions')
            keyboard
        end
        
        numSpikes = sum(sum([countsA; countsB],1));
        
        StudyTestProps{cellI,tSess} = [countsA/numSpikes; countsB/numSpikes];
        LeftRightProps{cellI,tSess} = [countsC/numSpikes; countsD/numSpikes];
    end
end
            
end            
            
            
            
            
            
            