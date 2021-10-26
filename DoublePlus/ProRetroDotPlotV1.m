function ProRetroDotPlotV1(trialbytrialAll,condAB,lapsAB,cellI)


figure('Position',[402.5000 191 715.5000 283.5000]);
for condI = 1:length(condAB)
    subplot(1,length(condAB),condI)
    %{
    xPos = [prospecTBT(condI).trialsX{:}];
    yPos = [prospecTBT(condI).trialsY{:}];
    cellPSA = [prospecTBT(condI).trialPSAbool{:}];
    cellSpiking = cellPSA(cellI,:);
    %}
    xPos = [trialbytrialAll(condAB(condI)).trialsX{lapsAB{condI}}];
    yPos = [trialbytrialAll(condAB(condI)).trialsY{lapsAB{condI}}];
    cellPSA = [trialbytrialAll(condAB(condI)).trialPSAbool{lapsAB{condI}}];
    cellSpiking = cellPSA(cellI,:);
    
    plot(xPos,yPos,'.k')
    hold on
    plot(xPos(cellSpiking),yPos(cellSpiking),'.r','MarkerSize',8)
    xlim([-60 60])
    ylim([-60 60])
end
    

