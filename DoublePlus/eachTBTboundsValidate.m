for mouseI = 1:numMice
    for sessI = 1:3
        figure;
        for condI = 1:numConds
            subplot(2,2,condI)
            lapsH = cellTBT{mouseI}(condI).sessID==sessI;
            xx = [cellTBT{mouseI}(condI).trialsX{lapsH}];
            yy = [cellTBT{mouseI}(condI).trialsY{lapsH}];
            plot(xx,yy,'.k')
            hold on
            %plot the outlines here 
            plot(eachArmBoundsT{condI}.X,eachArmBoundsT{condI}.Y,'*r')
            [inn,onn] = inpolygon(xx,yy,eachArmBoundsT{condI}.X,eachArmBoundsT{condI}.Y);
            inn = inn | onn;
            title(['m' num2str(mouseI) ' sess' num2str(sessI) ' nPtsOut' num2str(sum(inn==0))])
        end
    end
    
    for sessI = 4:6
        figure;
        for condI = 1:numConds
            subplot(2,2,condI)
            lapsH = cellTBT{mouseI}(condI).sessID==sessI;
            xx = [cellTBT{mouseI}(condI).trialsX{lapsH}];
            yy = [cellTBT{mouseI}(condI).trialsY{lapsH}];
            plot(xx,yy,'.k')
            hold on
            %plot the outlines here 
            plot(eachArmBoundsP{condI}.X,eachArmBoundsP{condI}.Y,'*r')
            [inn,onn] = inpolygon(xx,yy,eachArmBoundsP{condI}.X,eachArmBoundsP{condI}.Y);
            inn = inn | onn;
            title(['m' num2str(mouseI) ' sess' num2str(sessI) ' nPtsOut' num2str(sum(inn==0))])
        end
    end
    
    for sessI = 7:9
        figure;
        for condI = 1:numConds
            subplot(2,2,condI)
            lapsH = cellTBT{mouseI}(condI).sessID==sessI;
            xx = [cellTBT{mouseI}(condI).trialsX{lapsH}];
            yy = [cellTBT{mouseI}(condI).trialsY{lapsH}];
            plot(xx,yy,'.k')
            hold on
            %plot the outlines here 
            plot(eachArmBoundsT{condI}.X,eachArmBoundsT{condI}.Y,'*r')
            [inn,onn] = inpolygon(xx,yy,eachArmBoundsT{condI}.X,eachArmBoundsT{condI}.Y);
            inn = inn | onn;
            title(['m' num2str(mouseI) ' sess' num2str(sessI) ' nPtsOut' num2str(sum(inn==0))])
        end
    end
end