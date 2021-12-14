function PlotDoublePlusRaster(trialbytrial,cellI,dayI,condPlot,titles)


figure;
for condJ = 1:length(condPlot)
    subplot(2,2,condJ)
    condI = condPlot(condJ);
    
    lapsH = trialbytrial(condI).sessID == dayI;
    
    xLaps = trialbytrial(condI).trialsX(lapsH);
    yLaps = trialbytrial(condI).trialsY(lapsH);
    
    spikingH = trialbytrial(condI).trialPSAbool(lapsH);
    spikingH = cellfun(@(x) x(cellI,:),spikingH,'UniformOutput',false);
    %{
    xH{condJ} = [trialbytrial(condI).trialsX{lapsH}];
    yH{condJ} = [trialbytrial(condI).trialsY{lapsH}];
    spikingH{condJ} = [trialbytrial(condI).trialPSAbool{lapsH}];
    
    spikingH{condJ} = spikingH{condJ}(cellI,:);
    spikePosX{condJ} = xH{condJ}(spikingH{condJ});
    spikePosY{condJ} = yH{condJ}(spikingH{condJ});
         %}
    switch condI
        case 1
            %spikePos = spikePosY{condJ};
            spikePos = cellfun(@(x) -x,yLaps,'UniformOutput',false);
            % Need to relabel lims
        case 2
            %spikePos = spikePosX{condJ};
            spikePos = cellfun(@(x) -x,xLaps,'UniformOutput',false);
            % Need to relabel lims
        case 3
            %spikePos = spikePosY{condJ};
            spikePos = yLaps;
        case 4
            %spikePos = spikePosX{condJ};
            spikePos = xLaps;
    end
    
    nLaps = numel(spikePos);
    
    for lapI = 1:nLaps
        nPos = numel(spikePos{lapI});
        yy = [zeros(nPos,1) ones(nPos,1)]+lapI;
        xx = repmat(spikePos{lapI}(:),1,2);
        
        hold on
        plot(xx',yy','Color',[0.5 0.5 0.5])
        
        spp = spikingH{lapI};
        plot(xx(spp,:)',yy(spp,:)','Color','m')
    end
    
    if condI == 1 || condI == 2
        aa = gca;
        set(aa,'XTickLabel',cellfun(@num2str,mat2cell(aa.XTick'*-1,ones(numel(aa.XTick),1),1),'UniformOutput',false))
    end
    
    if ~isempty(titles)
        title(titles{condJ})
    end
    ylabel('Trial Number')
    xlabel('Arm position')
    MakePlotPrettySL(gca);
end
    
    
    
    
    
end