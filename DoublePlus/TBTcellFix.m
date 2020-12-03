function outputTBT = TBTcellFix(inputTBT)

outputTBT = inputTBT;
for condI = 1:length(inputTBT)
    numLaps = length(inputTBT(condI).trialsX);
    for trialI = 1:numLaps
        outputTBT(condI).trialsX{trialI} = inputTBT(condI).trialsX{trialI}{1};
        outputTBT(condI).trialsY{trialI} = inputTBT(condI).trialsY{trialI}{1};
        outputTBT(condI).trialPSAbool{trialI} = inputTBT(condI).trialPSAbool{trialI}{1};
        outputTBT(condI).trialRawTrace{trialI} = inputTBT(condI).trialRawTrace{trialI}{1};
    end
end