function [armPref] = CondFiringPreference(TMap)

numCells = size(TMap,1);
numDays = size(TMap,2);
numConds = size(TMap,3);

maxFiring = cell2mat(cellfun(@max,TMap,'UniformOutput',false));

armPref = NaN(numCells,numDays);
for cellI = 1:numCells
    for sessI = 1:numDays
        [~,armPref(cellI,sessI)] = max([maxFiring(cellI,sessI,:)]);
    end
end

end