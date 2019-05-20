function [statsOut] = PlotBarWithData(dataMat,plotColors,plotError,plotIndiv,xLabels)

global realDatMarkerSize

if isempty(realDatMarkerSize)
    realDatMarkerSize = 8;
end

%Plot the bar graph
b = bar(1:size(dataMat,2),nanmean(dataMat,1),'LineWidth',1.2,'BarWidth',1,'FaceColor','flat');
b.CData = plotColors;
hold on
if plotError == true
    err = nanstd(dataMat,1);
    g = errorbar(1:size(dataMat,2),nanmean(dataMat,1),-1*err,err);
    g.Color = [0 0 0];
    g.LineStyle = 'none';
end

%Overlay the raw data
if plotIndiv==true
for scI = 1:size(dataMat,2)
    plot(scI*ones(size(dataMat,1),1),dataMat(:,scI),'.','Color',[0.4 0.4 0.4],'MarkerSize',realDatMarkerSize)
end
end
b.Parent.XTickLabel = xLabels;
b.Parent.XTickLabelRotation = 55;
xlim([0.25 size(dataMat,2)+0.75])
ylim([0 1])

%Do a stats
combs = flipud(combnk(1:size(dataMat,2),2));
for combI = 1:size(combs,1)
    [statsOut.signtest.pVal(combI),statsOut.signtest.hVal(combI)] =...
        signtest(dataMat(:,combs(combI,1)),dataMat(:,combs(combI,2)));
    statsOut.signtest.comparisons(combI,:) = combs(combI,:);
end

[statsOut.ksANOVA.p,statsOut.ksANOVA.tbl,statsOut.ksANOVA.stats] = kruskalwallis(dataMat,[],'off');
statsOut.ksANOVA.multComps = multcompare(statsOut.ksANOVA.stats,'Display','off');

end