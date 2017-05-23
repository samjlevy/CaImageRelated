function [strict, sloppy] = BatchCentroidsInPFs(Placefields1, Placefields2, indexIn1)
%Takes as inputs structs for both fields with placefield occmap and
%indexIn1 (same as CentroidDistances), gives yes/no in arrangement of
%indexIn1 for strict: based on exact area from occmap (probably needs to be
%adjusted for holes in the occmap) and sloppy: (squares off fields)

strict = zeros(size(PlaceFields2.centroids));
sloppy = strict;

for pairRow = 1:size(indexIn1,1)
    if any(indexIn1{pairRow})
        thisIndices = [indexIn1{pairRow}];
        for pairColumn = 1:length(thisIndices)
            if thisIndices(pairColumn) ~= 0
                centroidFrom2 = PFcentroids2{pairRow,pairColumn};
                centroidFrom1 = PFcentroids1{pairRow,thisIndices(pairColumn)};
                x1 = centroidFrom1(1);
                x2 = centroidFrom2(1);
                y1 = centroidFrom1(2); 
                y2 = centroidFrom2(2);
                Distances(pairRow,pairColumn) = hypot(abs(x1 - x2),abs(y1 - y2));
            end
        end
    end
end




end