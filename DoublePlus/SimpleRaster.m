function SimpleRaster(lapPositions,lapSpiking)
%Assumes these are cell arrays

numLaps = numel(lapPositions);
figure;
for lapI = 1:numLaps
    nPos = numel(lapPositions{lapI});

    yy = [zeros(nPos,1) ones(nPos,1)]+lapI;
    xx = repmat(lapPositions{lapI}(:),1,2);
        
    hold on
    plot(xx',yy','Color',[0.5 0.5 0.5])

    spp = lapSpiking{lapI};
    plot(xx(spp,:)',yy(spp,:)','Color','m')
end

end