function [startHist,stopHist] = GetStartStopCounts(trialbytrial,bins)

numConds = length(trialbytrial);
sessHere = unique(trialbytrial(1).sessID);
numSess = length(sessHere);
numBins = size(bins.X,1);

for condI = 1:numConds
    
    endsAllX = cell2mat(cellfun(@(x) [x(1) x(end)],trialbytrial(condI).trialsX,'UniformOutput',false));
    endsAllY = cell2mat(cellfun(@(x) [x(1) x(end)],trialbytrial(condI).trialsY,'UniformOutput',false));
    
    for sessI = 1:numSess
        lapsHI = find(trialbytrial(condI).sessID==sessHere(sessI));
        
        startsHX = endsAllX(lapsHI,1);
        stopsHX = endsAllX(lapsHI,2);
        startsHY = endsAllY(lapsHI,1);
        stopsHY = endsAllY(lapsHI,2);
        
        for binI = 1:numBins
            [in,on] = inpolygon(startsHX,startsHY,bins.X(binI,:),bins.Y(binI,:));
            thisBin = in | on;
            
            startHist{condI}(sessHere(sessI),binI) = sum(thisBin);
            
            [in,on] = inpolygon(stopsHX,stopsHY,bins.X(binI,:),bins.Y(binI,:));
            thisBin = in | on;
            
            stopHist{condI}(sessHere(sessI),binI) = sum(thisBin);
        end
    end
end

end
            