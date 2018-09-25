function tbtPooled = PoolTBTacrossConds(trialbytrial,condsPool,newLabels)

daysHere = unique(trialbytrial(1).sessID);
for cpI = 1:size(condsPool,1)
    tbtPooled(cpI).trialsX = [];
    tbtPooled(cpI).trialsY = [];
    tbtPooled(cpI).trialPSAbool = [];
    tbtPooled(cpI).trialRawTrace = [];
    tbtPooled(cpI).sessID = [];
    tbtPooled(cpI).name = newLabels{cpI};
    tbtPooled(cpI).lapNumber = [];
    
     for dayI = 1:length(daysHere)
         pileX = []; pileY = []; pilePSA = []; pileRaw = []; pileDay = []; pileLapNum = [];
         for cpK = 1:size(condsPool,2)
            getLaps = trialbytrial(condsPool(cpI,cpK)).sessID==daysHere(dayI); 
            
            pileX = [pileX; trialbytrial(condsPool(cpI,cpK)).trialsX(getLaps)];
            pileY = [pileY; trialbytrial(condsPool(cpI,cpK)).trialsY(getLaps)];
            pilePSA = [pilePSA; trialbytrial(condsPool(cpI,cpK)).trialPSAbool(getLaps)];
            pileRaw = [pileRaw; trialbytrial(condsPool(cpI,cpK)).trialRawTrace(getLaps)];
            pileDay = [pileDay; trialbytrial(condsPool(cpI,cpK)).sessID(getLaps)];
            pileLapNum = [pileLapNum; trialbytrial(condsPool(cpI,cpK)).lapNumber(getLaps)];
         end
         
         [sortedLapNum,sortOrder] = sort(pileLapNum);
         
         tbtPooled(cpI).trialsX = [tbtPooled(cpI).trialsX; pileX(sortOrder)];
         tbtPooled(cpI).trialsY = [tbtPooled(cpI).trialsY; pileY(sortOrder)]; 
         tbtPooled(cpI).trialPSAbool = [tbtPooled(cpI).trialPSAbool; pilePSA(sortOrder)];
         tbtPooled(cpI).trialRawTrace = [tbtPooled(cpI).trialRawTrace; pileRaw(sortOrder)]; 
         tbtPooled(cpI).sessID = [tbtPooled(cpI).sessID; pileDay(sortOrder)];
         tbtPooled(cpI).lapNumber = [tbtPooled(cpI).lapNumber; pileLapNum(sortOrder)];
     end
end


end