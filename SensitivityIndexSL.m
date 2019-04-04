function [dPrime, pVal] = SensitivityIndexSL(vSignal,vNoise,nPerms)
% d' = (mean signal - mean noise) / 
%       square root ( 1/2 * (std(signal)^2 - std(noise)^2) )

dPrime = SensFunc(vSignal,vNoise);
dPrime = abs(dPrime);

%Get p-val from permutation test
allData = [vSignal(:); vNoise(:)];
dataMarker = [zeros(length(vSignal),1); ones(length(vNoise),1)];
for permI = 1:nPerms
    newMarker = dataMarker(randperm(length(dataMarker)));
    
    dShuff(permI) = SensFunc(allData(newMarker==0),allData(newMarker==1));
end

pVal = sum(abs(dShuff) > dPrime)/nPerms;
     
end

function dPrime = SensFunc(vSignal,vNoise)

dPrime = (nanmean(vSignal) - nanmean(vNoise)) / ...
         sqrt( 0.5*(std(vSignal)^2 + std(vNoise)^2) );
end

