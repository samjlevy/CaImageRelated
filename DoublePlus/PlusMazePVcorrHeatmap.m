function figHand = PlusMazePVcorrHeatmap(PlotRateMaps,condNames,armAlignment,diffRank,pThresh,plotBins)
%This version assumes that the organization of rates within PlotRateMaps
%follows a particular alignment. Then it generates a grid and fits each
%firing rate into the appropriate bin location on the grid so we can just
%imagesc that bin and color it appropriately.
numBins = length(PlotRateMaps{1});

PlusMapBlank = zeros(numBins*2+3,numBins*2+3);
bins.north = [[1:numBins]'+1, (numBins+1)*ones(numBins,1)+1];
bins.south = [[1:numBins]'+ numBins+2, (numBins+1)*ones(numBins,1)+1]; %need to be flipped too?
bins.east = [(numBins+1)*ones(numBins,1)+1, [1:numBins]'+ numBins+2];
bins.west = [(numBins+1)*ones(numBins,1)+1, [1:numBins]'+1];

sigPlotLocs = [8 7; 13 18; 16 10.5; 7 13]; 
horizAlign = {'right','left','center','center'};

figure;
hh = colormap(hot);
close(gcf);
jj = flipud(fliplr(hh)); %#ok<FLUDLR>

newCmap = [hh(2:2:end,:); jj(1:2:end,:)];
%for dpI = 1:numDayPairs
       
    thisMap = PlusMapBlank;
    backgroundTransparent = PlusMapBlank;
    for cnI = 1:length(condNames)
        corrsHere = PlotRateMaps{cnI};
        if strcmpi(condNames{cnI},'west')
           corrsHere = fliplr(corrsHere); 
        end
        
        for binI = 1:numBins 
            thisMap(bins.(condNames{cnI})(binI,1),bins.(condNames{cnI})(binI,2)) = corrsHere(binI);
            
            backgroundTransparent(bins.(condNames{cnI})(binI,1),bins.(condNames{cnI})(binI,2)) = 1;
        end
    end
    %minThisMap = min(min(thisMap))
    figHand=figure; imagesc(thisMap,'AlphaData',backgroundTransparent) 
    hold on
    %colormap jet
    %caxis([-0.4 0.4]) 
    colormap(newCmap)
    caxis([-0.4 0.4])
    colorbar
    
    if length(diffRank)>0
    for cnI = 1:length(condNames)
        sBins = bins.(condNames{cnI});
        
        switch armAlignment.(condNames{cnI}){1}
            case 'Y'
                %sBins(:,1) = sBins(:,1)+0.5;
                sBins(:,2) = sBins(:,2)+ -1*armAlignment.(condNames{cnI}){2};
            case 'X'
                sBins(:,1) = sBins(:,1)+ -1.5*armAlignment.(condNames{cnI}){2};
        end
        plotHere = fliplr(mean(sBins,1));
        
        switch (1-diffRank{cnI}) < pThresh
                case 1
                    plotAdd = '*';  
                case 0
                    plotAdd = 'n.s.';
        end
        %}
        plotLab = [plotAdd ' p = ' num2str(round(1-diffRank{cnI},2))];
        text(plotHere(1),plotHere(2),plotLab,'HorizontalAlignment',horizAlign{cnI},'FontSize',12)
    end
    end
    
    if plotBins == 1
        for cnI = 1:length(condNames)
        sBins = bins.(condNames{cnI});
            for binI = 1:numBins
                xCorns = [sBins(binI,2)-0.5 sBins(binI,2)+0.5 sBins(binI,2)+0.5 sBins(binI,2)-0.5 sBins(binI,2)-0.5];
                yCorns = [sBins(binI,1)-0.5 sBins(binI,1)-0.5 sBins(binI,1)+0.5 sBins(binI,1)+0.5 sBins(binI,1)-0.5];
                plot(xCorns,yCorns,'k','LineWidth',0.5)
            end
        end
    end

    %title(['Difference of Mean PV corrs, day pair ' num2str(dayPairs(dpI,:))])
%end
end

    