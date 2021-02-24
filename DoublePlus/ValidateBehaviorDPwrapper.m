ValidateBehaviorDPwrapper

numSess = length(allfiles);

% for sessI = 1:numSess

for sessI = (numSess-8):(numSess)

xHere = daybyday.all_x_adj_cm{sessI};
yHere = daybyday.all_y_adj_cm{sessI};
originalBehavior = daybyday.behavior{sessI};

%[fixedBehavior] = FindBadLapsDoublePlus(xHere,yHere,originalBehavior);

daybyday.behavior{sessI} = fixedBehavior;

disp(['Finished session ' num2str(sessI) ])
end


mazeBoundary = [xSanity(:),ySanity(:)];
epochs(1).starts = originalBehavior.LapStart(:); 
epochs(1).stops = originalBehavior.LapStop(:);
BadPtFixer(xHere, yHere, epochs, mazeBoundary)