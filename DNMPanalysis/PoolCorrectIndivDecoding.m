function correctPct = PoolCorrectIndivDecoding(correctIndiv)

numConds = size(correctIndiv,2);
numSessPairs = size(correctIndiv,1);

for sessI = 1:numSessPairs
    corrIndHere = [];
    for condI = 1:numConds
        corrIndHere = [corrIndHere; correctIndiv{sessI,condI}];
    end
    
    correctPct(sessI,1) = sum(corrIndHere) / length(corrIndHere);
end

end