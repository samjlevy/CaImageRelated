ValidateBehaviorDPwrapper

numSess = length(allfiles);

load(fullfile('F:\DoublePlus\sanityBins.mat'))
mazeBoundary = [xSanity(:) ySanity(:)];
% for sessI = 1:numSess

for sessI = (numSess-8):(numSess) %1:length(sessRun)

    %sessI = sessRun(sessJ);
    xHere = daybyday.all_x_adj_cm{sessI};
    yHere = daybyday.all_y_adj_cm{sessI};
    originalBehavior = daybyday.behavior{sessI};

    epochs(1).starts = originalBehavior.LapStart(:);
    epochs(1).stops = originalBehavior.LapStop(:);
    [fixedepochs] = BadPtFixer(xHere, yHere, epochs, mazeBoundary);
    originalBehavior.LapStart = fixedepochs(1).starts;
    originalBehavior.LapStop = fixedepochs(1).stops;

    [fixedBehavior] = FindBadLapsDoublePlus(xHere,yHere,originalBehavior);
    
if strcmpi(input('Did you see any laps that need to be adjusted forwards or back? (y/n)>>','s'),'y');
    
end

if strcmpi(input('Did you see any pts that need to be addressed? (y/n)>>','s'),'y');
    epochs(1).starts = fixedBehavior.LapStart(:);
    epochs(1).stops = fixedBehavior.LapStop(:);
    [fixedEpochs] = AddressLapPts(x_adj_cm,y_adj_cm,epochs);
    
    fixedBehavior.LapStart = fixedepochs(1).starts;
    fixedBehavior.LapStop = fixedepochs(1).stops;
end

daybyday.behavior{sessI} = fixedBehavior;
disp(['Finished session ' num2str(sessI) ])

end



