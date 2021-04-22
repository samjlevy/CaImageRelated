function PlotColorbar(gradientPlot,labels)

nRows = size(gradientPlot,1);
gradientPlot = flipud(reshape(gradientPlot,nRows,1,3));

gg = figure('Position',[564 254.5000 116 360.5000]);
imagesc(gradientPlot)
gg.Children.Position(3) = 0.4;
tickSpacing = round(linspace(1,nRows,numel(labels)));
gg.Children.YTick = tickSpacing;
gg.Children.YTickLabels = labels;
gg.Children.XTick = [];
gg.Children.YAxisLocation = 'right';
gg.Children.FontName= 'Arial';
gg.Children.FontSize = 14;

end