function figHand = PlusMazeHeatmap(cellTMap_unsmoothed,cellUse,realDays,condNames,transparentBkg) 

numBins = length(cellTMap_unsmoothed{1,1,1});
if isempty(transparentBkg); transparentBkg=0; end
bins.north = [[1:numBins]'+1, (numBins+1)*ones(numBins,1)+1];
bins.south = [[1:numBins]'+ numBins+2, (numBins+1)*ones(numBins,1)+1];
bins.south(:,1) = flipud(bins.south(:,1));
bins.east = [(numBins+1)*ones(numBins,1)+1, [1:numBins]'+ numBins+2];
bins.west = [(numBins+1)*ones(numBins,1)+1, [1:numBins]'+1];

%Colormap
figure;
jj = colormap(jet);
jj(end-1,:) = jj(end,:);
jj(end,:) = [1 1 1];
close(gcf);
%Scaling for imagesc
allData = [];
for sessJ = 1:3
    for cnI = 1:length(condNames)
        allData = [allData cellTMap_unsmoothed{cellUse,sessJ,cnI}];
    end
end
roundSteps = [0:0.1:1];
maxRateHere = max(allData);
rateScaleMax = roundSteps(find(roundSteps>maxRateHere,1,'first'));
PlusMapBlank = ones(numBins*2+3,numBins*2+3)*(rateScaleMax + 0.01);

numSess = size(cellTMap_unsmoothed,2);

figHand=figure('Position',[65 398 1775 580]);
for sessI = 1:numSess
    thisMap = PlusMapBlank;
    
    bkgTransparent = thisMap*0;
    
    for cnI = 1:length(condNames)
        ratesHere = cellTMap_unsmoothed{cellUse,sessI,cnI};
        if strcmpi(condNames{cnI},'west')
            ratesHere = fliplr(ratesHere);
        end
        for binI = 1:numBins
            thisMap(bins.(condNames{cnI})(binI,1),bins.(condNames{cnI})(binI,2)) = ratesHere(binI);
            bkgTransparent(bins.(condNames{cnI})(binI,1),bins.(condNames{cnI})(binI,2)) = 1;
        end
    end
    
    subplot(1,3,sessI)
    if transparentBkg==1
        imagesc(thisMap,'AlphaData',bkgTransparent)
    else
        imagesc(thisMap)
    end
    
    hold on
    colormap(jj)
    %caxis([0 1])
    qq=colorbar;
    qq.Limits = [0 rateScaleMax];
    axis equal
    xlim([1 23])
    ylim([1 23])
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
    
    title(['Day ' num2str(realDays(sessI))])
end
    
end
