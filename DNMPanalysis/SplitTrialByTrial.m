function [tbtA, tbtB] = SplitTrialByTrial(trialbytrial, splitmode)

fieldsToSplit = {'trialsX','trialsY','trialPSAbool','trialRawTrace','sessID','lapNumber','trialVel'};
numSess = unique(trialbytrial(1).sessID);

for ttI = 1:length(trialbytrial)
    tbtA(ttI).trialsX = {}; tbtA(ttI).trialsY = {};
    tbtA(ttI).trialPSAbool = {}; tbtA(ttI).trialRawTrace = {};
    tbtA(ttI).sessID = []; tbtA(ttI).lapNumber = [];
    tbtA(ttI).name = trialbytrial(ttI).name;
    tbtA(ttI).trialVel = {};
    
    tbtB(ttI).trialsX = {}; tbtB(ttI).trialsY = {};
    tbtB(ttI).trialPSAbool = {}; tbtB(ttI).trialRawTrace = {};
    tbtB(ttI).sessID = []; tbtB(ttI).lapNumber = [];
    tbtB(ttI).name = trialbytrial(ttI).name;
    tbtB(ttI).trialVel = {};
    
    
    for sessI = 1:length(numSess)
        entriesSplit = find(trialbytrial(ttI).sessID==numSess(sessI));
        nEntries = length(entriesSplit);
        
        switch splitmode
            case 'alternate'
                splitInds1 = 1:2:nEntries;
                splitInds2 = 2:2:nEntries;
            case {'rand','random'}
                entries = 1:nEntries;
                entries = entries(randperm(nEntries));
                splitInds1 = entries(1:2:nEntries);
                splitInds2 = entries(2:2:nEntries);
            case 'half'
                splitInds1 = 1:floor(nEntries/2);
                splitInds2 = floor(nEntries/2)+1:nEntries;
        end
        
        splitA = entriesSplit(splitInds1);
        newIndsA = length(tbtA(ttI).trialsX)+1:length(tbtA(ttI).trialsX)+length(splitA);
        
        splitB = entriesSplit(splitInds2);
        newIndsB = length(tbtB(ttI).trialsX)+1:length(tbtB(ttI).trialsX)+length(splitB);
        
        for ffI = 1:length(fieldsToSplit)
            try
            tbtA(ttI).(fieldsToSplit{ffI})(newIndsA,1) = trialbytrial(ttI).(fieldsToSplit{ffI})(splitA);
            tbtB(ttI).(fieldsToSplit{ffI})(newIndsB,1) = trialbytrial(ttI).(fieldsToSplit{ffI})(splitB);
            end
        end
    end
end

end