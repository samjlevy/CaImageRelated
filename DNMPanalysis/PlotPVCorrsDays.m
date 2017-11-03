function PlotPVCorrsDays(Corrs, figHand, figTitle, colorOrder)
%plots each day's corrs, one condition against self for that day
numDays = size(Corrs,1);

h = figure;
jetTrips = colormap(jet);
close(h)
jetUse = round(linspace(1,64,numDays));
plotColors = jetTrips(jetUse,:);

if isempty(colorOrder)
    colorOrder = 1:numDays;
else
    bins = [0.25:1:numDays+0.25];
    [counts] = histcounts(colorOrder,bins);
    tooMany = find(counts>=2);%This means it's this rank and the one below
    for tm = 1:length(tooMany)
        problemRank = colorOrder(bins(tooMany(tm)) <= colorOrder & colorOrder <= bins(tooMany(tm)+1));
        if length(unique(problemRank))~=1
            disp('iono man'); keyboard
        else
            numWrong = length(problemRank);
            problemRank = problemRank(1);

            switch rem(problemRank,floor(problemRank))
                case 0
                    reach = (numWrong-1)/2;
                    rankFills = problemRank-reach:1:problemRank+reach;
                case 0.5
                    reach = numWrong/2;
                    rankFills = (problemRank+0.5-reach):1:(problemRank-0.5+reach);
            end
        end
        
        inds = find(colorOrder==problemRank);
        if length(inds)~=length(rankFills); disp('spaghetti'); keyboard; end
        for ii = 1:length(inds)
            colorOrder(inds(ii)) = rankFills(ii);
        end
        %colorOrder(inds(1)) = colorOrder(inds(1))-0.5;
        %colorOrder(inds(2)) = colorOrder(inds(2))+0.5;
    end
end

plotColors = plotColors(colorOrder,:);
        

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