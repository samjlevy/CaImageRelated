function PlotDoublePlusRaster(trialbytrial,cellI,dayI,condPlot,titles,binLimsPlot,binLimsAsAxisLims)

if isempty(binLimsPlot)
    binLimsPlot = [NaN NaN];
end

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
    switch titles{condJ}
        case 'n'
            %spikePos = spikePosY{condJ};
            spikePos = cellfun(@(x) -x,yLaps,'UniformOutput',false);
            % Need to relabel lims
            binLimsX = -binLimsPlot;
        case 'w'
            %spikePos = spikePosX{condJ};
            spikePos = cellfun(@(x) -x,xLaps,'UniformOutput',false);
            % Need to relabel lims
            binLimsX = binLimsPlot;
        case 's'
            %spikePos = spikePosY{condJ};
            spikePos = yLaps;
            binLimsX = -binLimsPlot;
        case 'e'
            %spikePos = spikePosX{condJ};
            spikePos = xLaps;
            binLimsX = binLimsPlot;
    end
    
    nLaps = numel(spikePos);
    
    for lapI = 1:nLaps
        nPos = numel(spikePos{lapI});
        %{
        try
            yy = ones(nPos,1)*lapI;
            xx = spikePos{lapI};
            plot(xx,yy,'|','MarkerEdgeColor',[0.5 0.5 0.5])

            hold on

            spp = spikingH{lapI};
            plot(xx(spp)',yy(spp)','|','MarkerFaceColor','m')
        catch
        %}
            yy = [zeros(nPos,1) ones(nPos,1)]+lapI;
            xx = repmat(spikePos{lapI}(:),1,2);
        
            hold on
            plot(xx',yy','Color',[0.5 0.5 0.5])
        
            spp = spikingH{lapI};
            plot(xx(spp,:)',yy(spp,:)','Color','m')
        %end
    end

    if ~any(isnan(binLimsX))
        for bbI = 1:numel(binLimsX)
            plot([1 1]*binLimsX(bbI),[1 nLaps+1],'Color',[0.35 0.35 0.35])
        end
    end
    
    aa = gca;
    if condI == 1 || condI == 2
        set(aa,'XTickLabel',cellfun(@num2str,mat2cell(aa.XTick'*-1,ones(numel(aa.XTick),1),1),'UniformOutput',false))
    end

    if binLimsAsAxisLims==true
        xlim([min(binLimsX) max(binLimsX)])
    end
    
    if ~isempty(titles)
        title(titles{condJ})
    end
    ylim([1 nLaps+1])
    ylabel('Trial Number')
    xlabel('Arm position')
    aa.XAxis.TickLength=[0 0];
    aa.YAxis.TickLength=[0 0];
    MakePlotPrettySL(gca);
end
    
    
    
    
    
end