function ManyDotPlots(trialbytrial, thisCell, sessionInds, aboveThresh,...
    figHand, subDims, subLocs,titles)

for condType = 1:4
    subHand(condType) = subplot(subDims(1),subDims(2),subLocs(condType,:));
    
    plotX = [trialbytrial(condType).trialsX{:}];
    plotY = [trialbytrial(condType).trialsY{:}];
    
    plot(60-plotX,plotY,'.k','MarkerSize',8)
    badSess = find(aboveThresh{condType}(thisCell,:)==0 |...
              sessionInds(thisCell,:)==0); 
    badLaps = trialbytrial(condType).sessID == badSess;
    badLaps = sum(badLaps,2);
    
    blockBool = [trialbytrial(condType).trialPSAbool{badLaps==0}];
    
    if any(blockBool)
        spikeX = plotX(blockBool(thisCell,:));
        spikeY = plotY(blockBool(thisCell,:));
        hold on
        plot(60-spikeX, spikeY, '.r','MarkerSize',10)
    end
    
    if any(titles)
        title(titles{condType})
    end 
end
    

end