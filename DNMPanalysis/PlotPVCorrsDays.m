function PlotPVCorrsDays(Corrs, figHand, figTitle)

numDays = size(Corrs,1);

h = figure;
jetTrips = colormap(jet);
close(h)
jetUse = round(linspace(1,64,numDays));
plotColors = jetTrips(jetUse,:);

%StudyTestFig = figure;
if strcmpi(class(figHand),'matlab.ui.Figure')
    axes(figHand); 
    hold(figHand.Children,'on'); 
    title(figHand.Children,figTitle)
    xlabel(figHand.Children,'Start                      Choice Point'); 
    ylabel(figHand.Children,'Correlation')
    
    for uDay = 1:numDays
        plot(figHand.Children,fliplr(Corrs(uDay,:)),'-o','Color',plotColors(uDay,:))
    end
    
    plot(figHand.Children,figHand.Children.XLim,[0 0],'k') 
    ylim(figHand.Children,[-1 1]); %xlim(figHand.Children,[2 14]);
    figHand.Children.XLim(1) = 1;
elseif strcmpi(class(figHand),'matlab.graphics.axis.Axes')
    hold(figHand,'on'); 
    title(figHand,figTitle)
    xlabel(figHand,'Start                      Choice Point'); 
    ylabel(figHand,'Correlation')
    
    for uDay = 1:numDays
        plot(figHand,fliplr(Corrs(uDay,:)),'-o','Color',plotColors(uDay,:))
    end
    
    plot(figHand,figHand.XLim,[0 0],'k') 
    ylim(figHand,[-1 1]); %xlim(figHand,[2 14]);
    figHand.XLim(1) = 1;
end

%for uDay = 1:numDays
%    plot(figHand.Children,fliplr(Corrs(uDay,:)),'-o','Color',plotColors(uDay,:))
%end

%plot(figHand.Children,figHand.Children.XLim,[0 0],'k') 
%ylim(figHand.Children,[-1 1]); %xlim(figHand.Children,[2 14]);
%figHand.Children.XLim(1) = 1;
end