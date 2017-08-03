function ManyDotPlots(trialbytrial, thisCell, sessionInds, aboveThresh,...
    figHand, subDims, subLocs,titles)

%figHand;

for condType = 1:4
    subHand(condType) = subplot(subDims(1),subDims(2),subLocs(condType,:));
    
    badSess = find(sessionInds(thisCell,:)==0); %| aboveThresh{condType}(thisCell,:)==0
    badLaps = trialbytrial(condType).sessID == badSess;
    badLaps = sum(badLaps,2);
    goodLaps = badLaps==0;
    
    plotX = [trialbytrial(condType).trialsX{goodLaps}];
    plotY = [trialbytrial(condType).trialsY{goodLaps}];
    
    plot(subHand(condType),60-plotX,plotY,'.k','MarkerSize',8)
    
    blockBool = [trialbytrial(condType).trialPSAbool{goodLaps}];
    blockBool = blockBool(thisCell,:);
    %if condType==4
    %    disp('stopped')
    %end
    %if any(blockBool
    spikeX = plotX(blockBool);
    spikeY = plotY(blockBool);
    hold on
    plot(subHand(condType),60-spikeX, spikeY, '.r','MarkerSize',10)
    %end
    
    if any(titles)
        title(titles{condType})
    end 
end 

end