function [statsOut] = PlotBarWithData(dataMat,plotColors,xLabels)

%Plot the bar graph
b = bar(1:size(dataMat,2),nanmean(dataMat,1),'LineWidth',1.2,'BarWidth',1,'FaceColor','flat');
b.CData = plotColors;
hold on

%Overlay the raw data
for scI = 1:size(dataMat,2)
    plot(scI*ones(size(dataMat,1),1),dataMat(:,scI),'o','Color',[0.6 0.6 0.6],'LineWidth',1.5)
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
end

end