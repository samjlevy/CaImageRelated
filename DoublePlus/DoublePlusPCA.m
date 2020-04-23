% load('E:\DoublePlus\Kerberos\trialbytrialLAP.mat','trialbytrial')

numConds = length(trialbytrial);
numSess = length(unique(trialbytrial(1).sessID));

for sessI = 1:numSess
    rawTraces = [];
    for condI = 1:numConds
        theseLaps = trialbytrial(condI).sessID==sessI;
        
        rawTraces = [rawTraces, trialbytrial(condI).trialRawTrace{theseLaps}];
        lapLengths = cellfun(@(x) size(x,2),trialbytrial(condI).trialRawTrace(theseLaps));
        
    end
    
    normMins = min(rawTraces,[],2);
    normMaxes = max(rawTraces,[],2);
      
    noCells = (sortedSessionInds(:,sessI)>0)==0;
    rawTraces(noCells,:) = [];
    
    normalizedTraces = normalizeRawTraces(rawTraces,'row');
    
    meanTrace = [];
    for condI = 1:numConds
        theseLaps = find(trialbytrial(condI).sessID==sessI);
        numLaps = length(theseLaps);
        for lapI = 1:numLaps
            binnedTrace = binTraces(trialbytrial(condI).trialRawTrace{theseLaps(lapI)},5,0,'mean');
            
            binnedTraces{condI}{lapI} = binnedTrace;
            binnedTraces{condI}{lapI}(noCells,:) = [];
            
            meanTrace = [meanTrace, binnedTrace];
            
        end
    end
    normalizedTraces = (meanTrace-normMins)./normMaxes;
    normalizedTraces(noCells,:) = [];

    tic
    [coeff,score,latent,tsquared,explained,mu] = pca(normalizedTraces');
    toc
    
    pcsUse = [1 2 3];
    
    figure;
    cp = {'r','b'};
    endColor = {'g','c';'k','y'};
    for condI = 1:numConds
        theseLaps = find(trialbytrial(condI).sessID==sessI);
        
        for lapI = 1:length(theseLaps)
            %rt = trialbytrial(condI).trialRawTrace{theseLaps(lapI)}(noCells==0,:); 
            rt = binnedTraces{condI}{lapI};
            
            for tI = 1:size(rt,2)
                for pcI = 1:length(pcsUse)
                    projected(pcI,tI) = sum(rt(:,tI).*coeff(:,pcsUse(pcI)));
                end
                
                plot3(projected(1,:),projected(2,:),projected(3,:),'Color',cp{condI}); hold on
                plot3(projected(1,1),projected(2,1),projected(3,1),'*','Color',endColor{condI,1})
                plot3(projected(1,end),projected(2,end),projected(3,end),'*','Color',endColor{condI,2})
            end
        end
    end
    
    title('PCA of Whole lap, 5-frame mean normalized bins, Kerberos180420')
    