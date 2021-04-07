function [eDist] = euclideanDistanceSL1(vecA,vecB,norm)

vecA = vecA(:);
vecB = vecB(:);

if isempty(norm)
    norm = length(vecA);
end

diffs = abs(vecA-vecB);
diffsP = diffs.^norm;
eDist = sum(diffsP)^(1/norm);

end
