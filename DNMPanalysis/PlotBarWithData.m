function [statsOut] = PlotBarWithData(dataMat,plotColors,plotError,plotIndiv,xLabels)

global realDatMarkerSize

if isempty(realDatMarkerSize)
    realDatMarkerSize = 6;
end

jitterIndiv = false;
if ischar(plotIndiv) || isstring(plotIndiv)
    if strcmpi(plotIndiv,'jitter')
            plotIndiv = true;
        jitterIndiv = true;
    end
end
    
statsOut.means = nanmean(dataMat,1);
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
    if jitterIndiv==false
        plot(scI*ones(size(dataMat,1),1),dataMat(:,scI),'.','Color',[0.4 0.4 0.4],'MarkerSize',realDatMarkerSize)
    elseif jitterIndiv==true
        jitRange = 0.15;
        thisJitter = (rand(size(dataMat,1),1)-0.5)*(jitRange/0.5);
        plot((scI*ones(size(dataMat,1),1))+thisJitter,dataMat(:,scI),'.','Color',[0.4 0.4 0.4],'MarkerSize',realDatMarkerSize)
    end
end
end
if ~isempty(xLabels)
b.Parent.XTickLabel = xLabels;
b.Parent.XTickLabelRotation = 55;
end
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

for catI = 1:size(dataMat,2)
    allOthers = 1:size(dataMat,2);
    allOthers(allOthers==catI) = [];
    statsOut.pctMoreThanAllOthers(catI) = sum(sum(dataMat(:,catI) >= dataMat(:,allOthers),2)==(size(dataMat,2)-1))/size(dataMat,1);
end

end