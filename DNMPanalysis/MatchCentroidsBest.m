function [CentroidsA, CentroidsB, matches] = MatchCentroidsBest...
    (PFcentroidsA, bestPFA, PFcentroidsB, bestPFB)
%Matches places fields using best place field (from PFstats); means these
%only 1 place field per cell

matches = zeros(size(PFcentroidsA,1),1);
for pfa=1:size(PFcentroidsA,1)
    if any([PFcentroidsA{pfa,:}]) && any([PFcentroidsB{pfa,:}])
        CentroidsA{pfa,1}=PFcentroidsA{pfa,bestPFA(pfa)};
        CentroidsB{pfa,1}=PFcentroidsB{pfa,bestPFB(pfa)};
        matches(pfa) = 1;
    end
end

end