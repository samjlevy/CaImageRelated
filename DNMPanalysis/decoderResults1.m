function [outResults] = decoderResults1(testLapConds, testCondDecoded)

inCs = length(unique(testLapConds(:,1)));
outCs = length(unique(testCondDecoded(:,1)));
for inputCond = 1:inCs
    for outputCond = 1:outCs
        %outResults(inputCond,outputCond) = sum(testCondDecoded(testLapConds==inputCond)==outputCond);
        rowsUse = testLapConds(:,1)==inputCond;
        outResults(inputCond,outputCond) = sum(testCondDecoded(rowsUse,1)==outputCond);
    end
    outResults(inputCond,:) = outResults(inputCond,:)/sum(outResults(inputCond,:));
end

end