function traitAB = PoolTraitAcrossTasks(reRegSSI,reRegTask,reRegSess,traitA,traitB)
 
numSess = size(reRegSSI,2);
numCells = size(reRegSSI,1);

traitAB = zeros(numCells,numSess);

for sessI = 1:numSess
    for cellI = 1:numCells
        cInd = reRegSSI(cellI,sessI);
        sessJ = reRegSess(sessI);
        
        if any(cInd)
            switch reRegTask(sessI)
                case 1            
                    valH = traitA(cInd,sessJ);
                case 2
                    valH = traitB(cInd,sessJ);
            end
            
            traitAB(cellI,sessI) = valH;
        end
    end
end

end