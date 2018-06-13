function [dayDist, pctDayDist, pctEdge, dayDistMeans, dayDistSEMs] = DIdistBreakdown(DImeans, traitLogical, binEdges)

DImeansHere = DImeans; 
DImeansHere(traitLogical==0) = NaN;

for dayI = 1:size(DImeans,2)
        dayDist(dayI,:) = histcounts(DImeansHere(:,dayI),binEdges); 
        pctDayDist(dayI,:) =  dayDist(dayI,:) / sum(dayDist(dayI,:)); %by percentage
        pctEdge(dayI) = sum(pctDayDist(dayI,[1 end]));
      
    for binI = 1:length(binEdges)-1
        dd = dayDist(:,binI);
        dayDistMeans(1,binI) = mean(dd(dd~=0));
        dayDistSEMs(1,binI) = standarderrorSL(dd(dd~=0));
    end
end

end