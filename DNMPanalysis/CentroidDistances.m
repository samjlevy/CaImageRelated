function Distances = CentroidDistances(PFcentroids1, PFcentroids2, indexIn1)

Distances = zeros(size(indexIn1));

for pairRow = 1:size(indexIn1,1)
    for pairColumn = 1:size(indexIn1,2)
        if any(indexIn1{pairRow,pairColumn})
            x1 = PFcentroids2{pairRow,pairColumn}(1);
            x2 = PFcentroids1{PFrow,indexIn1{pairRow,pairColumn}}(1);
            y1 = PFcentroids2{pairRow,pairColumn}(2); 
            y2 = PFcentroids1{PFrow,indexIn1{pairRow,pairColumn}}(2);
            Distances(pairRow,pairColumn) = hypot(abs(x1 - x2),abs(y1 - y2));
        end
    end
end


end