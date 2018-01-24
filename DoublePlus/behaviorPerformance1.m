numTrials = length(starts);

%Need to add: right/left when shouldn't

for trialI = 1:numTrials
    switch starts{trialI}
        case {'l','L','s','S'}
            fixedStarts{trialI,1} = 'S';
        case {'r','R','n','N'}
            fixedStarts{trialI,1} = 'N';
    end
    
    switch responses{trialI}
        case {'s','S'}
            fixedResponses{trialI,1} = 'S';
        case {'n','N'}
            fixedResponses{trialI,1} = 'N';
        case {'e','E'}
            fixedResponses{trialI,1} = 'E';
        case {'w','W'}
            fixedResponses{trialI,1} = 'W';
    end
end

%Allocentric Alternation
alloAlternate = NaN;
for trialI = 2:numTrials
    if (strcmpi(fixedResponses{trialI},'E') && strcmpi(fixedResponses{trialI-1},'W'))...
            || (strcmpi(fixedResponses{trialI},'W') && strcmpi(fixedResponses{trialI-1},'E'))
        alloAlternate(trialI,1) = 1;
    else
        alloAlternate(trialI,1) = 0;
    end
end

%Get egocentric turn
for trialI = 1:numTrials
    if (strcmpi(fixedStarts{trialI},'S') && strcmpi(fixedResponses{trialI},'E'))...
            || (strcmpi(fixedStarts{trialI},'N') && strcmpi(fixedResponses{trialI},'W'))
        egoTurn{trialI,1} = 'R';
    elseif (strcmpi(fixedStarts{trialI},'S') && strcmpi(fixedResponses{trialI},'W'))...
            || (strcmpi(fixedStarts{trialI},'N') && strcmpi(fixedResponses{trialI},'E'))
        egoTurn{trialI,1} = 'L';
    else
        egoTurn{trialI,1} = 'E';
    end
end

%Egocentric Alternation
egoAlternate = NaN;
for trialI = 2:numTrials
    if (strcmpi(egoTurn{trialI},'L') && strcmpi(egoTurn{trialI-1},'R'))...
            || (strcmpi(egoTurn{trialI},'R') && strcmpi(egoTurn{trialI-1},'L'))
        egoAlternate(trialI,1) = 1;
    else
        egoAlternate(trialI,1) = 0;
    end
end
        


windowLength = 5;
windowGet = windowLength - 1;
for trialI = 1:numTrials-windowGet
    leftBias(trialI,1) = sum(strcmpi({egoTurn{trialI:trialI+windowGet}},'L'))/windowLength;
    rightBias(trialI,1) = sum(strcmpi({egoTurn{trialI:trialI+windowGet}},'R'))/windowLength;
    eastBias(trialI,1) = sum(strcmpi({fixedResponses{trialI:trialI+windowGet}},'E'))/windowLength;
    westBias(trialI,1) = sum(strcmpi({fixedResponses{trialI:trialI+windowGet}},'W'))/windowLength;
    
    egoAltBias(trialI,1) = sum(egoAlternate(trialI:trialI+windowGet))/windowLength;
    alloAltBias(trialI,1) = sum(alloAlternate(trialI:trialI+windowGet))/windowLength;
end
    
figure;
plotThings = [leftBias rightBias eastBias westBias egoAltBias alloAltBias];
for plI = 1:size(plotThings,2)
    hold on
    plot(windowLength:numTrials,plotThings(:,plI))
end
legend('left','right','east','west','egoAlt','alloAlt','Location','northwest')
    
    
    