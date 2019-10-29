function [tbtActivity] = lapbylapActivity(trialbytrial)

numConds = length(trialbytrial);
numSess = length(unique(trialbytrial(1).sessID));
numCells = size(trialbytrial(1).trialPSAbool{1},1);

minimumX = cell(4,1); 
maximumX = cell(4,1);
midX = cell(4,1);
transientDur = cell(4,1); 
transLength = cell(4,1); 
transLengthPosNorm = cell(4,1); 

fluorSum = [];
fluorAvg = [];
for condI = 1:numConds
    laps = length(trialbytrial(condI).sessID);
    
    minimumX{condI} = zeros(laps,numCells); 
    maximumX{condI} = zeros(laps,numCells);
    midX{condI} = zeros(laps,numCells);
    transientDur{condI} = zeros(laps,numCells);
    transLength{condI} = zeros(laps,numCells);
    transLengthPosNorm{condI} = zeros(laps,numCells);
    
    for lapI = 1:laps
        for cellI = 1:numCells
            
            %if lapI == 81 && cellI == 14 && condI == 14
            %    keyboard
            %end
            
            thisCellActivity = trialbytrial(condI).trialPSAbool{lapI}(cellI,:);
            thisCellPosX = trialbytrial(condI).trialsX{lapI}(thisCellActivity);
            
            minimumX{condI}(lapI,cellI) = min([0 thisCellPosX]);
            maximumX{condI}(lapI,cellI) = max([0 thisCellPosX]);
            midX{condI}(lapI,cellI) = mean([minimumX{condI}(lapI,cellI) maximumX{condI}(lapI,cellI)]);
            transientDur{condI}(lapI,cellI) = sum(thisCellActivity);
            transLength{condI}(lapI,cellI) = maximumX{condI}(lapI,cellI) - minimumX{condI}(lapI,cellI);
            transLengthPosNorm{condI}(lapI,cellI) = transLength{condI}(lapI,cellI) / transientDur{condI}(lapI,cellI);
            
            if ~isempty(trialbytrial(condI).trialRawTrace)
            thisFluor = trialbytrial(condI).trialRawTrace{lapI}(cellI,:);
            fluorSum{condI}(lapI,cellI) = sum(thisFluor);
            fluorAvg{condI}(lapI,cellI) = mean(thisFluor);
            end
        end
    end
    
    minimumX{condI}(minimumX{condI}==0) = NaN;
    maximumX{condI}(maximumX{condI}==0) = NaN;
    midX{condI}(midX{condI}==0) = NaN;
end
      
tbtActivity.minimumX = minimumX;
tbtActivity.maximumX = maximumX;
tbtActivity.midX = midX;
tbtActivity.transientDur = transientDur;
tbtActivity.transLength = transLength;
tbtActivity.transLengthPosNorm = transLengthPosNorm;
tbtActivity.fluorSum = fluorSum;
tbtActivity.fluorAvg = fluorAvg;

end