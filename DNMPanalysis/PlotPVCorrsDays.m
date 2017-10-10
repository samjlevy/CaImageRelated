function PlotPVCorrsDays(Corrs, figHand, figTitle)

numDays = size(Corrs,1);

h = figure;
jetTrips = colormap(jet);
close(h)
jetUse = round(linspace(1,64,numDays));
plotColors = jetTrips(jetUse,:);

%StudyTestFig = figure; 
axes(figHand); hold(figHand.Children,'on'); title(figHand.Children,figTitle)
xlabel(figHand.Children,'Start                      Choice Point'); ylabel('Correlation')
for uDay = 1:numDays
    plot(figHand.Children,fliplr(Corrs(uDay,:)),'-o','Color',plotColors(uDay,:))
end
ylim(figHand.Children,[-1 1]); %xlim(figHand.Children,[2 14]);

end