function [ indices, exclusive ] = MatchCentroids (PFcentroids1, row1, PFcentroids2, row2)
% , row2
%Does a row at a time, should be rebuilt to loop the entire thing

%Initial setup. Fuck cell arrays
%%{
centroids1 = zeros(size(PFcentroids1,2),2);
for aa=1:size(PFcentroids1,2)
    if any(PFcentroids1{row1,aa})
        centroids1(aa,1:2) = PFcentroids1{row1,aa};
    end
end


centroids2 = zeros(size(PFcentroids2,2),2);
for bb=1:size(PFcentroids2,2)
    if any(PFcentroids2{row1,bb})
        centroids2(bb,1:2) = PFcentroids2{row2,bb};
    end
end

%}
%centroids1=PFcentroids1; centroids2=PFcentroids2;
isCentroid1 = find(centroids1(:,1));
isCentroid2 = find(centroids2(:,1));

%Which goes with which?
for cc = 1:length(isCentroid2)
[idx(cc), distance(cc)] = findclosest2D(centroids1(isCentroid1,1),...
                                        centroids1(isCentroid1,2),...
                                        centroids2(isCentroid2(cc),1),...
                                        centroids2(isCentroid2(cc),2));
end
indices = idx;

%What if they both assign to the same?
exclusive = zeros(length(isCentroid2),1);
for dd = 1:length(isCentroid1)
    if sum(idx==isCentroid1(dd)) > 1
        [~, closer]  = min(distance(idx==isCentroid1(dd)));
        exclusive(closer) = isCentroid1(dd);
    else
        exclusive(idx==isCentroid1(dd)) = idx(idx==isCentroid1(dd));
    end
end    
   

end