function figHand = CentroidOverlapPlot(distances, overlaps, centroidInField)

centroidInField=centroidInField>0;
plotInds=find(distances);
centroidFound = logical(centroidInField(plotInds));
foundInds = plotInds(centroidFound);
notFoundInds = plotInds(~centroidFound);

figHand=figure;
plot(distances(foundInds),overlaps(foundInds),'og')
hold on
plot(distances(notFoundInds),overlaps(notFoundInds),'or')
%could add for 1 vs both centroids in other field
xlabel('Distance (cm)')
ylabel('Percent overlap with smaller field')
title('Green = one field has center in the other')

end