function lapString = ParseLapDirection(epochs,leftArea,rightArea,xPos,yPos)

for epochI = 1:size(epochs,1)
    ti = epochs(epochI,:);
    [leftPts,~] = inpolygon(xPos(ti(1):ti(2)),yPos(ti(1):ti(2)),leftArea(:,1),leftArea(:,2));
    [rightPts,~] = inpolygon(xPos(ti(1):ti(2)),yPos(ti(1):ti(2)),rightArea(:,1),rightArea(:,2));
    if sum(leftPts) > sum(rightPts)
        lapString{epochI,1} = 'l';
    elseif sum(rightPts) > sum(leftPts)
        lapString{epochI,1} = 'r';
    else
        disp('no pts?')
    end

end

end