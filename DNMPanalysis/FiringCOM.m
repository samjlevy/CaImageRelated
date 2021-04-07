function thisCOM = FiringCOM(OneTmap)

numBins = length(OneTmap);

%lineup = (1:numBins)-0.5;
lineup = 1:numBins;

thisCOM = sum(OneTmap(:)'.*lineup) / sum(OneTmap);
%thisCOM = sum(OneTmap.*lineup)*mean(lineup(OneTmap~=0));

end