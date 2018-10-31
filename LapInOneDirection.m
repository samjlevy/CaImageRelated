function goodDir = LapInOneDirection(xPos, yPos, epochs, axisCheck, posOrNeg)

xPos = xPos(:); xPos = xPos';
yPos = yPos(:); yPos = yPos';

goodDir = cell(length(epochs),1);
for ee = 1:length(epochs)
    nLaps = length(epochs(ee).starts);
    for lapI = 1:nLaps
        switch axisCheck
            case {'x','X'}
                posHere = xPos(epochs(ee).starts(lapI):epochs(ee).stops(lapI));
            case {'y','Y'}
                posHere = yPos(epochs(ee).starts(lapI):epochs(ee).stops(lapI));
        end
        
        
        posDiffs = diff(posHere);
        diffsSigns = posDiffs ./ abs(posDiffs);
        
        switch posOrNeg
            case 'pos'
                goodDir{ee}(lapI,1) = sum(diffsSigns==1) / length(diffsSigns);
            case 'neg'
                goodDir{ee}(lapI,1) = sum(diffsSigns==-1) / length(diffsSigns);
        end
                
    
    end
end

end


