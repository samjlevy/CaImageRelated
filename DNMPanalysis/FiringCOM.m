function thisCOM = FiringCOM(OneTmap)

numBins = length(OneTmap);

lineup = 1:numBins;

thisCOM = (OneTmap.*lineup) / sum(OneTmap)

end