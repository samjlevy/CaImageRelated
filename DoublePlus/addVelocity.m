for mouseI = 1:numMice
    for condI = 1:numConds
        for trialI = 1:numel(cellTBT{mouseI}(condI).trialsX)
            xHere = cellTBT{mouseI}(condI).trialsX{trialI};
            yHere = cellTBT{mouseI}(condI).trialsY{trialI};
            velocity = hypot(abs(diff(yHere)),abs(diff(xHere))) / (1/20);
            velocity = [velocity(1), velocity(:)'];
            cellTBT{mouseI}(condI).trialVelocity{trialI,1} = velocity;
        end
    end
end

for mouseI = 1:numMice
    trialbytrialThresh = cellTBT{mouseI};
    save(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'),'trialbytrialThresh','-append')
end

for mouseI = 1:numMice
    trialbytrialEachThresh = trialbytrialThresh;
    for condI = 1:4
        keepTrials = trialbytrialThresh(condI).isCorrect & ~trialbytrialThresh(condI).allowedFix;
        
        trialbytrialEachThresh(cond).trialsX(~keepTrials) = [];
        trialsY
        trialPSAbool
        trialDFDTtrace
        trialRawTrace
        sessID
        sessNumber
        lapNumber
        isCorrect
        allowedFix
        startArm
        endArm
        lapSequence
        rule