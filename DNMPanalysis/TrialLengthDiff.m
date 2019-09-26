function [lengthDiff,stdDiff,ranksumP,data] = TrialLengthDiff(trialbytrial,meascondPairs)

Cond = GetTBTconds(trialbytrial);

numSess = length(unique(trialbytrial(1).sessID));

for condI = 1:length(trialbytrial)
    trialLengths{condI} = cell2mat(cellfun(@length,trialbytrial(condI).trialsX,'UniformOutput',false));
end

lengthDiff = zeros(numSess,size(meascondPairs,1));
stdDiff = zeros(numSess,size(meascondPairs,1));

for mcI = 1:size(meascondPairs,1)
    mcpHere = meascondPairs(mcI,:);
    
    for sessI = 1:numSess
        lengthsA = trialLengths{mcpHere(1)}(trialbytrial(mcpHere(1)).sessID==sessI);
        lengthsB = trialLengths{mcpHere(2)}(trialbytrial(mcpHere(2)).sessID==sessI);
        
        lengthDiff(sessI,mcI) = mean(lengthsB) - mean(lengthsA);
        stdDiff(sessI,mcI) = std(lengthsB) - std(lengthsA);
        
        [ranksumP(sessI,mcI),~] = ranksum(lengthsA,lengthsB);
        
        data.meanLengthsA(sessI,mcI) = mean(lengthsA);
        data.meanLengthsB(sessI,mcI) = mean(lengthsB);
        data.stdLengthsA(sessI,mcI) = std(lengthsA);
        data.stdLengthsB(sessI,mcI) = std(lengthsB);
    end
end

end