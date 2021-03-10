function [sessGood] = PlotSessPositions(trialbytrial)

sessHere = unique(trialbytrial(1).sessID);
numConds = length(trialbytrial);

for sessI = 1:length(sessHere)
    lapFig = figure('Position',[270.5000 213.5000 1.0305e+03 474]);
    for condI = 1:numConds
        lapsH = trialbytrial(condI).sessID == sessHere(sessI);
        xPos = [trialbytrial(condI).trialsX{lapsH}];
        yPos = [trialbytrial(condI).trialsY{lapsH}];
        subplot(1,numConds,condI)
        plot(xPos,yPos,'.k')
        
        title(['Condition ' num2str(condI)])
    end
    
    suptitleSL(['Session ' num2str(sessHere(sessI))])
    
    sessGood(sessI) = strcmpi(input('Is this session good points? (y/n)>>','s'),'y');
    figure(lapFig);
    
    close(lapFig);
end

end
        
